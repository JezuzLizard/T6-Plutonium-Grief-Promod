
game_start_timer() //checked matches bo3 _globallogic.gsc within reason
{	
	visionSetNaked( "cheat_bw", 0 );
	matchStartText = createServerFontString( "objective", 1.5 );
	matchStartText setPoint( "CENTER", "CENTER", 0, -40 );
	matchStartText.sort = 1001;
	matchStartText setText( game["strings"]["waiting_for_teams"] );
	matchStartText.foreground = false;
	matchStartText.hidewheninmenu = true;
	flag_wait( "game_start" );
	matchStartText setText( game["strings"]["match_starting_in"] );
	matchStartTimer = createServerFontString( "objective", 2.2 );
	matchStartTimer setPoint( "CENTER", "CENTER", 0, 0 );
	matchStartTimer.sort = 1001;
	matchStartTimer.color = ( 1, 1, 0 );
	matchStartTimer.foreground = false;
	matchStartTimer.hidewheninmenu = true;
	matchStartTimer maps\mp\gametypes_zm\_hud::fontPulseInit();
	countTime = level.grief_gamerules[ "pregame_time" ];
	if ( countTime >= 2 )
	{
		while ( countTime > 0 )
		{
			matchStartTimer setValue( countTime );
			matchStartTimer thread maps\mp\gametypes_zm\_hud::fontPulse( level );
			if ( countTime == 2 )
			{
				visionSetNaked( GetDvar( "mapname" ), 3.0 );
			}
			countTime--;
			wait 1;
		}
	}
	else
	{
		visionSetNaked( GetDvar( "mapname" ), 1.0 );
	}
	matchStartTimer destroyElem();
	matchStartText destroyElem();
}

pregame()
{
	flag_clear( "spawn_zombies" );
	level thread game_start_timer();
	scripts/zm/promod/zgriefp::wait_for_players();
	//respawn_players();
	respawn_spectators_and_freeze_players();
	flag_set( "game_start" );
	playsoundatposition( "vox_zmba_grief_intro_0", ( 0, 0, 0 ) );
	wait level.grief_gamerules[ "pregame_time" ];
}

wait_for_players()
{
	level endon( "end_game" );
	teamplayersallies = getPlayers( "allies");
	teamplayersaxis = getPlayers( "axis");
	while ( ( teamplayersaxis.size < 1 ) || ( teamplayersallies.size < 1 ) )
	{
		teamplayersallies = getPlayers( "allies");
		teamplayersaxis = getPlayers( "axis");
		players = getPlayers();
		for ( i = 0; i < players.size; i++ )
		{
			players[ i ] iPrintLn( "Waiting for 1 player on each team" );
		}
		wait 1;
	}
	// if ( getDvarInt( "grief_tournament_mode" ) == 1 )
	// {
	// 	players = getPlayers();
	// 	while ( getDvarInt( "zombies_minplayers" ) > players.size )
	// 	{
	// 		players = getPlayers();
	// 		for ( i = 0; i < players.size; i++ )
	// 		{
	// 			players[ i ] iPrintLn( "Waiting for all players to connect" );
	// 		}
	// 		wait 1;
	// 	}
	// }
}