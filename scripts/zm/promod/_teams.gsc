
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
		if ( response == "changeteam" && level.allow_teamchange == "1" )
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
		if ( menu == game[ "menu_team" ] && level.allow_teamchange == "1" )
		{
			switch( response )
			{
				case "allies":
					self [[ level.allies ]]();
					break;
				case "axis":
					self [[ level.teammenu ]]( response );
					break;
				case "autoassign":
					self [[ level.autoassign ]]( 1 );
					break;
				case "spectator":
					self [[ level.spectator ]]();
					break;
			}
			continue;
		}
	}
}

menuallieszombies()
{
	self maps/mp/gametypes_zm/_globallogic_ui::closemenus();
	if ( !level.console && level.allow_teamchange == "0" && is_true( self.hasdonecombat ) )
	{
		return;
	}
	if ( self.pers[ "team" ] != "allies" )
	{
		if ( level.ingraceperiod && !isDefined( self.hasdonecombat ) || !self.hasdonecombat )
		{
			self.hasspawned = 0;
		}
		if ( self.sessionstate == "playing" )
		{
			self.switching_teams = 1;
			self.joining_team = "allies";
			self.leaving_team = self.pers[ "team" ];
			self suicide();
		}
		self.pers["team"] = "allies";
		self.team = "allies";
		self.pers["class"] = undefined;
		self.class = undefined;
		self.pers["weapon"] = undefined;
		self.pers["savedmodel"] = undefined;
		self updateobjectivetext();
		if ( level.teambased )
		{
			self.sessionteam = "allies";
		}
		else
		{
			self.sessionteam = "none";
			self.ffateam = "allies";
		}
		self setclientscriptmainmenu( game[ "menu_class" ] );
		self notify( "joined_team" );
		level notify( "joined_team" );
		self notify( "end_respawn" );
	}
}