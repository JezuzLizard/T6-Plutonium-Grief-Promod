
initial_player_team()
{
	if ( isDefined( level.players_in_session[ self.name ].sessionteam ) )
	{
		switch ( level.players_in_session[ self.name ].sessionteam )
		{
			case "axis":
				self.team = "axis";
				self.sessionteam = "axis";
				self.pers[ "team" ] = "axis";
				self._encounters_team = "A"; 
				break;
			case "allies":
				self.team = "allies";
				self.sessionteam = "allies";
				self.pers[ "team" ] = "allies";
				self._encounters_team = "B";
				break;
			default:
				break;
		}
	}
	else 
	{
		teamplayersallies = countplayers( "allies");
		teamplayersaxis = countplayers( "axis");
		if ( teamplayersallies > teamplayersaxis && !level.isresetting_grief )
		{
			self.team = "axis";
			self.sessionteam = "axis";
			self.pers[ "team" ] = "axis";
			self._encounters_team = "A";
		}
		else if ( teamplayersallies < teamplayersaxis && !level.isresetting_grief)
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
		if ( isDefined( self.team ) )
		{
			level.players_in_session[ self.name ].sessionteam = self.team;
		}
	}
	self [[ level.givecustomcharacters ]]();
}

menu_onmenuresponse()
{
	self endon( "disconnect" );
	for ( ;; )
	{
		self waittill( "menuresponse", menu, response );
		if ( response == "back" )
		{
			self closemenu();
			self closeingamemenu();
			continue;
		}
		if ( response == "changeteam" && self player_can_change_teams() )
		{
			self closemenu();
			self closeingamemenu();
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
					self maps/mp/zombies/_zm_laststand::add_weighted_down();
					self maps/mp/zombies/_zm_stats::increment_client_stat( "deaths" );
					self maps/mp/zombies/_zm_stats::increment_player_stat( "deaths" );
					self maps/mp/zombies/_zm_pers_upgrades_functions::pers_upgrade_jugg_player_death_stat();
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
				self maps/mp/gametypes_zm/_globallogic::gamehistoryplayerquit();
				self maps/mp/zombies/_zm_laststand::add_weighted_down();
				self closemenu();
				self closeingamemenu();
				level.host_ended_game = 1;
				maps/mp/zombies/_zm_game_module::freeze_players( 1 );
				level notify( "end_game" );
			}
			else
			{
				self closemenu();
				self closeingamemenu();
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
	level waittill( "end_round_think" );
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
		switch ( team )
		{
			case "allies":
				self._encounters_team = "B";
				break;
			case "axis":
				self._encounters_team = "A";
				break;
			default:
				break;
		}
		level.players_in_session[ self.name ].sessionteam = team;
	}
}

menuautoassign( comingfrommenu )
{
	teamkeys = getarraykeys( level.teams );
	assignment = teamkeys[ randomint( teamkeys.size ) ];
	self closemenus();
	self thread change_team_next_round( assignment );
	return true;;
}

player_can_change_teams()
{
	if ( !isDefined( level.team_change_cooldown ) )
	{
		level.team_change_cooldown = 60;
	}
	if ( !isDefined( level.team_change_max ) )
	{
		level.team_change_max = 2;
	}
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
	if ( !can_change_teams )
	{
		self closemenus();
	}
	else
	{
		self thread team_change_timer();
		level.players_in_session[ self.name ].team_changed_times++;
	}
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

store_player_session_data()
{
	if ( !isDefined( level.players_in_session ) )
	{
		level.players_in_session = [];
	}
	if ( !isDefined( level.players_in_session[ self.name ] ) )
	{
		level.players_in_session[ self.name ] = spawnStruct();
		if ( level.grief_gamerules[ "use_preset_teams" ] )
		{
			level.players_in_session[ self.name ].sessionteam = self check_for_predefined_team();
		}
		else 
		{
			level.players_in_session[ self.name ].sessionteam = undefined;
		}
		level.players_in_session[ self.name ].team_change_timer = 0;
		level.players_in_session[ self.name ].team_changed_times = 0;
		level.players_in_session[ self.name ].team_change_ban = false;
	}
}

//set grief_preset_teams "player_name(team_name,is_perm) player_name(team_name,is_perm) etc"

check_for_predefined_team()
{
	preset_teams = getDvar( "grief_preset_teams" );
	team_keys = strTok( preset_teams, " " ); 
	if ( teamplayersallies < 4 )
	{
		foreach ( key in team_keys )
		{
			logline1 = "Checking player: " + self.name + " comparing with: " + key + "\n";
			logprint( logline1 );
			if ( self.name == key )
			{
				self.team = "allies";
				self.sessionteam = "allies";
				self.pers[ "team" ] = "allies";
				self._encounters_team = "B";
				team_is_defined = 1;
				logline1 = "trying to set player based on name: " + self.name + " to preset team: " + self.team + "\n";
				logprint( logline1 );
				break;
			}
		}
	}
}

