
set_team()
{
	if ( isDefined( self.custom_team ) )
	{
		self.team = self.custom_team;
		self.sessionteam = self.custom_team;
		self._encounters_team = undefined;
		self [[ level.givecustomcharacters ]]();
		return;
	}
	teamplayersallies = countplayers( "allies");
	teamplayersaxis = countplayers( "axis");
	if ( getDvarInt( "grief_gamerule_use_preset_teams" ) == 1 )
	{
	 	allies_team_members = getDvar( "grief_allies_team_player_names" );
		team_keys = strTok( allies_team_members, "+" ); 
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
		if ( !is_true( team_is_defined ) )
		{
			teamplayersaxis = countplayers( "axis");
			if ( teamplayersaxis < 4 )
			{
				self.team = "axis";
				self.sessionteam = "axis";
				self.pers[ "team" ] = "axis";
				self._encounters_team = "A"; 
				team_is_defined = 1;
				logline1 = "player didn't have name match: " + self.name + " to preset team: " + self.team + "\n";
				logprint( logline1 );
			}
			else 
			{
				self.team = "allies";
				self.sessionteam = "allies";
				self.pers[ "team" ] = "allies";
				self._encounters_team = "B";
				team_is_defined = 1;
				logline1 = "player team failsafe: " + self.name + " to preset team: " + self.team + "\n";
				logprint( logline1 );
			}
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
		if ( self.sessionstate == "playing" )
		{
			self.switching_teams = 1;
			self.joining_team = team;
			self.leaving_team = self.pers[ "team" ];
		}
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
	else if ( self.team_change_timer_count > 0 )
	{
		self iPrintLn( "You cannot change teams for another" + self.team_change_timer_count + " seconds." );
	}
	else if ( self.team_num_times_changed_teams > level.team_change_max )
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
		self.team_num_times_changed_teams++;
	}
	return can_change_teams;
}

player_banned_from_changing_teams()
{
	return false;
}

team_change_timer()
{
	self.team_change_timer_count = level.team_change_cooldown;
	while ( self.team_change_timer_count > 0 )
	{
		self.team_change_timer_count--;
		wait 1;
	}
}