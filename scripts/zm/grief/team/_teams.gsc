#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/gametypes_zm/_globallogic_ui;

player_team_setup()
{
	teamplayersallies = countplayers( "allies" );
	teamplayersaxis = countplayers( "axis" );
	session_team = level.players_in_session[ self.name ].sessionteam;
	if ( isDefined( session_team ) && countplayers( session_team ) < 4 )
	{
		self.team = session_team;
		self.sessionteam = session_team;
		self.pers[ "team" ] = session_team;
		self._encounters_team = level.data_maps[ "encounters_teams" ][ "e_team" ][ level.teamIndex[ session_team ] ]; 
	}
	else 
	{
		if ( teamplayersallies > teamplayersaxis )
		{
			self.team = "axis";
			self.sessionteam = "axis";
			self.pers[ "team" ] = "axis";
			self._encounters_team = "A";
		}
		else if ( teamplayersallies < teamplayersaxis )
		{
			self.team = "allies";
			self.sessionteam = "allies";
			self.pers[ "team" ] = "allies";
			self._encounters_team = "B";
		}
		else
		{
			self.team = "allies";
			self.sessionteam = "allies";
			self.pers[ "team" ] = "allies";
			self._encounters_team = "B";
		}
		level.players_in_session[ self.name ].sessionteam = self.team;
	}
	self [[ level.givecustomcharacters ]]();
}

menu_onmenuresponse_override()
{
	self endon( "disconnect" );
	for ( ;; )
	{
		self waittill( "menuresponse", menu, response );
		if ( response == "back" )
		{
			self closemenus();
			continue;
		}
		if ( response == "changeteam" && self player_can_change_teams() )
		{
			self closemenus();
			self openmenu( game[ "menu_team" ] );
			continue;
		}
		if ( response == "endgame" )
		{
			if ( self issplitscreen() )
			{
				level.skipvote = 1;
				if ( is_true( level.gameended ) )
				{
					level.host_ended_game = 1;
					maps/mp/zombies/_zm_game_module::freeze_players( 1 );
					level notify( "end_game" );
				}
			}
			continue;
		}
		if ( response == "endround" )
		{
			if ( is_true( level.gameended ) )
			{
				self closemenus();
				level.host_ended_game = 1;
				maps/mp/zombies/_zm_game_module::freeze_players( 1 );
				level notify( "end_game" );
			}
			else
			{
				self closemenus();
				self iprintln( &"MP_HOST_ENDGAME_RESPONSE" );
			}
			continue;
		}
		if ( menu == game[ "menu_team" ] && self player_can_change_teams() )
		{
			if ( response == "autoassign" )
			{
				if ( self menuautoassign( response ) )
				{
					self iPrintLn( "You will change to " + self.new_team + " next round." );
				}
			}
			else 
			{
				if ( self menuteam( response ) )
				{
					self iPrintLn( "You will change to " + self.new_team + " next round." );
				}
			}
			continue;
		}
	}
}

menuteam( team )
{
	self closemenus();
	self thread change_team_next_round( team );
	return true;
}

change_team_next_round( team )
{
	level notify( "team_change_set" );
	level endon( "team_change_set" );
	self.new_team = team;
	level waittill( "grief_new_round" );
	if ( self.pers[ "team" ] != team )
	{
		self.pers[ "team" ] = team;
		self.team = team;
		self.class = undefined;
		self updateobjectivetext();
		if ( level.teambased )
		{
			self.sessionteam = team;
		}
		else
		{
			self.sessionteam = "none";
			self.ffateam = team;
		}
		self._encounters_team = level.data_maps[ "encounters_teams" ][ "e_team" ][ level.teamIndex[ team ] ];
		level.players_in_session[ self.name ].sessionteam = team;
	}
}

menuautoassign( comingfrommenu )
{
	teamkeys = getarraykeys( level.teams );
	assignment = teamkeys[ randomint( teamkeys.size ) ];
	self closemenus();
	self thread change_team_next_round( assignment );
	return true;
}

player_can_change_teams()
{
	if ( !isDefined( self.team_num_times_changed_teams ) )
	{
		self.num_times_changed_teams = 0;
	}
	can_change_teams = false;
	if ( getGameTypeSetting( "allowInGameTeamChange" ) == 0 )
	{
		self iPrintLn( "Team change is not allowed on this server." );
	}
	else if ( self player_banned_from_changing_teams() )
	{
		self iPrintLn( "You are not allowed to change teams." );
	}
	else if ( level.players_in_session[ self.name ].team_change_timer > 0 )
	{
		self iPrintLn( "You cannot change teams for another" + level.players_in_session[ self.name ].team_change_timer + " seconds." );
	}
	else if ( level.players_in_session[ self.name ].team_changed_times > level.team_change_max )
	{
		self iPrintLn( "Max team changes reached for session." );
	}
	else 
	{
		can_change_teams = true;
	}
	if ( can_change_teams )
	{
		self thread team_change_timer();
		level.players_in_session[ self.name ].team_changed_times++;
	}
	self closemenus();
	return can_change_teams;
}

player_banned_from_changing_teams()
{
	return level.players_in_session[ self.name ].team_change_ban;
}

team_change_timer()
{
	level.players_in_session[ self.name ].team_change_timer = level.team_change_cooldown;
	while ( level.players_in_session[ self.name ].team_change_timer > 0 )
	{
		level.players_in_session[ self.name ].team_change_timer--;
		wait 1;
	}
}

check_for_predefined_team()
{
	//team = get_key_value_from_value( "grief_preset_teams", getDvar( "grief_preset_teams" ), self.name, "team_name" );
	axis_guids = strTok( getDvar( "grief_teams_axis_guids" ), ";" );
	team = "";
	if ( axis_guids.size > 0 )
	{
		foreach ( guid in axis_guids )
		{
			if ( self getGUID() == int( guid ) )
			{
				team = "axis";
				break;
			}
		}
	}
	allies_guids = strTok( getDvar( "grief_teams_allies_guids" ), ";" );
	if ( allies_guids.size > 0 && team == "" )
	{
		foreach ( guid in allies_guids )
		{
			if ( self getGUID() == int( guid ) )
			{
				team = "allies";
				break;
			}
		}
	}
	if ( team != "" && isDefined( level.teams[ team ] ) && countPlayers( team ) < 4 )
	{
		self.team = team;
		self.sessionteam = team;
		self.pers[ "team" ] = team;
		self._encounters_team = level.data_maps[ "encounters_teams" ][ "e_team" ][ level.teamIndex[ team ] - 1 ];
		return true;
	}
	return false;
}

default_menu_autoassign( assignment )
{
	self closemenus();
	self player_team_setup();
	self.class = undefined;
	self updateobjectivetext();
	self notify( "joined_team" );
	level notify( "joined_team" );
	self notify( "end_respawn" );
	self beginclasschoice();
	self setclientscriptmainmenu( game[ "menu_class" ] );
}