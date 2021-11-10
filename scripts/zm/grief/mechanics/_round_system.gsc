
grief_save_loadouts2()
{
	if ( isDefined( level.grief_loadout_save ) )
	{
		while ( true )
		{
			players = getPlayers();
			foreach ( player in players )
			{
				if ( is_player_valid( player ) )
				{
					player [[ level.grief_loadout_save ]]();
				}
			}
			wait 1;
		}
	}
}

grief_team_forfeit()
{
	if ( getDvarInt( "grief_testing" ) == 1 )
	{
		return false;
	}
	if ( ( getPlayers( "axis" ).size == 0 ) || ( getPlayers( "allies" ).size == 0 ) )
	{
		return true;
	}
	return false;
}

check_for_match_winner( winner )
{
	if ( level.data_maps[ "encounters_teams" ][ "score" ][ level.teamIndex[ winner ] ] == level.grief_gamerules[ "scorelimit" ] )
	{
		return true;
	}
	if ( grief_team_forfeit() )
	{
		return true;
	}
	return false;
}

match_end( winner )
{
	level.gamemodulewinningteam = level.data_maps[ "encounters_teams" ][ "eteam" ][ level.teamIndex[ winner ] ];
	players = getPlayers();
	for ( i = 0; i < players.size; i++ )
	{
		players[ i ] freezecontrols( 1 );
		if ( players[ i ].team == winner )
		{
			players[ i ] thread maps/mp/zombies/_zm_audio_announcer::leaderdialogonplayer( "grief_won" );
			players[ i ].pers[ "wins" ]++;
		}
		else 
		{
			players[ i ] thread maps/mp/zombies/_zm_audio_announcer::leaderdialogonplayer( "grief_lost" );
			players[ i ].pers[ "losses" ]++;
		}
	}
	level._game_module_game_end_check = undefined;
	maps/mp/gametypes_zm/_zm_gametype::track_encounters_win_stats( level.gamemodulewinningteam );
	level notify( "end_game" );
}

round_winner( winner )
{
	level.data_maps[ "encounters_teams" ][ "score" ][ level.teamIndex[ winner ] ]++;
	level notify( "grief_point", winner );
	if ( check_for_match_winner( winner ) )
	{
		match_end( winner );
		return;
	}
	flag_clear( "spawn_zombies" );
	level.pause_timer = true;
	flag_set( "timer_pause" );
	level thread all_surviving_players_invulnerable();
	level thread scripts/zm/promod/utility/_grief_util::kill_all_zombies();
	if ( isDefined( level.grief_round_win_next_round_countdown ) && !in_grief_intermission() )
	{
		level thread freeze_players( 1 );
		level thread maps/mp/zombies/_zm_audio::change_zombie_music( "round_end" );
		level thread [[ level.grief_round_win_next_round_countdown ]]();
		wait level.grief_gamerules[ "next_round_time" ];
	}
	else if ( isDefined( level.grief_round_intermission_countdown ) && level.grief_gamerules[ "intermission_time" ] > 0 )
	{
		level.grief_intermission_done = false;
		players = getPlayers();
		foreach ( player in players )
		{
			if ( player player_is_in_laststand() )
			{
				player auto_revive( player );
			}
			else if ( player.sessionstate == "spectator" )
			{	
				player [[ level.spawnplayer ]]();
			}
		}
		level thread maps/mp/zombies/_zm_audio::change_zombie_music( "round_end" );
		level thread [[ level.grief_round_intermission_countdown ]]();
		wait level.grief_gamerules[ "intermission_time" ];
	}
	flag_clear( "timer_pause" );
	level thread start_new_round( false );
}

check_for_surviving_team()
{
	level endon( "end_game" );
	level.rounds_played = 1;
	// setroundsplayed( level.rounds_played );
	level thread grief_save_loadouts2();
	while ( 1 )
	{
		flag_wait( "spawn_zombies" );
		alive_teams = count_alive_teams();
		if ( alive_teams == 0 )
		{
			start_new_round( true );
		}
		else if ( alive_teams == 1 && isDefined( level.predicted_round_winner ) )
		{
			wait level.grief_gamerules[ "suicide_check" ];
			if ( count_alive_teams() == 0 )
			{
				start_new_round( true );
				continue;
			}
			round_winner( level.predicted_round_winner );
		}
		wait 0.05;
	}
}

count_alive_teams()
{
	level.alive_players = [];
	foreach ( team in level.teams )
	{
		level.alive_players[ team ] = [];
		level.data_maps[ "encounters_teams" ][ "alive" ][ level.teamIndex[ team ] ] = 0;
	}
	players = getPlayers();
	for ( i = 0; i < players.size; i++ )
	{
		if ( level.data_maps[ "encounters_teams" ][ "alive" ][ level.teamIndex[ players[ i ].team ] ] )
		{
			level.alive_players[ players[ i ].team ] = players[ i ];
		}
		else if ( players[ i ]._encounters_team == level.data_maps[ "encounters_teams" ][ "e_team" ][ level.teamIndex[ players[ i ].team ] ] )
		{
			if ( is_player_valid( players[ i ] ) )
			{
				level.alive_players[ players[ i ].team ] = players[ i ];
				level.data_maps[ "encounters_teams" ][ "alive" ][ level.teamIndex[ players[ i ].team ] ] = 1;
			}
		}
	}
	alive_teams = 0;
	level.predicted_round_winner = undefined;
	foreach ( team in level.teams )
	{
		if ( level.data_maps[ "encounters_teams" ][ "alive" ][ level.teamIndex[ team ] ] )
		{
			alive_teams++;
			level.predicted_round_winner = level.data_maps[ "encounters_teams" ][ "team" ][ level.teamIndex[ team ] ];
		}
	}
	return alive_teams;
}

zgrief_main_o()
{
	zgriefp_init();
	flag_wait( "initial_blackscreen_passed" );
	game_start();
	players = getPlayers();
	foreach ( player in players )
	{
		player.is_hotjoin = 0;
	}
	wait 1;
}

game_start()
{
	flag_init( "game_start", 0 );
	flag_init( "timer_pause", 0 );
	flag_init( "first_round", 0 );
	level.pause_timer = false;
	pregame();
	//level thread location_ambiance();
	unfreeze_all_players_controls();
	flag_set( "start_zombie_round_logic" );
	level thread maps/mp/zombies/_zm_audio::change_zombie_music( "round_start" );
	level thread zombie_spawning();
	level thread check_for_surviving_team();
	flag_set( "first_round" );
	start_new_round( false, level.grief_gamerules[ "zombie_round" ] );
	flag_clear( "first_round" );
}

start_new_round( is_restart, round_number )
{
	level.new_round_started = true;
	if ( isDefined( round_number ) )
	{
		level.zombie_health = level.zombie_vars[ "zombie_health_start" ];
		level.grief_gamerules[ "zombie_round" ] = round_number;
		maps/mp/zombies/_zm::ai_calculate_health( round_number );
	}
	if ( is_true( is_restart ) )
	{
		flag_clear( "spawn_zombies" );
		level thread scripts/zm/promod/utility/_grief_util::kill_all_zombies();
		if ( isDefined( level._grief_reset_message ) )
		{
			level thread [[ level._grief_reset_message ]]();
		}
		zombie_spawn_delay_fix();
		zombie_speed_fix();
	}
	else 
	{
		level.rounds_played++;
		// setroundsplayed( level.rounds_played );
	}
	all_surviving_players_vulnerable();
	level thread reset_players_last_griefed_by();
	if ( !flag( "first_round" ) )
	{
		respawn_players();
	}
	unfreeze_all_players_controls();
	level thread maps/mp/zombies/_zm_audio::change_zombie_music( "round_start" );
	wait level.grief_gamerules[ "round_zombie_spawn_delay" ];
	flag_set( "spawn_zombies" );
	level notify( "grief_new_round" );
	level.new_round_started = false;
}

give_points_on_restart_and_round_change()
{
	level endon( "end_game" );
	while ( true )
	{
		level waittill( "grief_new_round" );
		if ( self.score < level.grief_gamerules[ "round_restart_points" ] )
		{
			self.score = level.grief_gamerules[ "round_restart_points" ];
		}
	}
}

round_change_hud()
{   
	level endon( "end_game" );
	if ( isDefined( level.round_countdown_text ) )
	{
		level.round_countdown_text destroy();
	}
	if ( isDefined( level.round_countdown_timer ) )
	{
		level.round_countdown_timer destroy();
	}
	remaining = create_simple_hud();
	remaining.horzAlign = "center";
	remaining.vertAlign = "middle";
	remaining.alignX = "center";
	remaining.alignY = "middle";
	remaining.y = 20;
	remaining.x = 0;
	remaining.foreground = 1;
	remaining.fontscale = 2.0;
	remaining.alpha = 1;
	remaining.color = ( 0.98, 0.549, 0 );
	remaining.hidewheninmenu = 1;
	remaining maps/mp/gametypes_zm/_hud::fontpulseinit();

	countdown = create_simple_hud();
	countdown.horzAlign = "center"; 
	countdown.vertAlign = "middle";
	countdown.alignX = "center";
	countdown.alignY = "middle";
	countdown.y = -20;
	countdown.x = 0;
	countdown.foreground = 1;
	countdown.fontscale = 2.0;
	countdown.alpha = 1;
	countdown.color = ( 1.000, 1.000, 1.000 );
	countdown.hidewheninmenu = 1;
	countdown setText( "Next Round In" );
	level.round_countdown_timer = remaining;
	level.round_countdown_text = countdown;
	timer = level.grief_gamerules[ "next_round_time" ];
	while ( 1 )
	{
		level.round_countdown_timer setValue( timer ); 
		wait 1;
		timer--;
		if ( timer <= 5 )
		{
			countdown_pulse( level.round_countdown_timer, timer );
			break;
		}
	}
	if ( isDefined( level.round_countdown_text ) )
	{
		level.round_countdown_text destroy();
	}
	if ( isDefined( level.round_countdown_timer ) )
	{
		level.round_countdown_timer destroy();
	}
}


round_time_hud() //checked matches cerberus output
{
	level endon( "end_game" );
	create_round_timer();
	timelimit_in_seconds = level.grief_gamerules[ "timelimit" ] * 60;
	time_left = parse_minutes( to_mins( timelimit_in_seconds ) );
	flag_wait( "spawn_zombies" );
	while ( true )
	{
		if ( is_true( level.pause_timer ) )
		{
			zombie_spawn_delay = level.grief_gamerules[ "round_zombie_spawn_delay" ];
			while ( flag( "timer_pause" ) )
			{
				wait 1;
			}
			while ( zombie_spawn_delay > 0 )
			{
				wait 1;
				zombie_spawn_delay--;
				time_left = parse_minutes( to_mins( zombie_spawn_delay ) );
				level.round_time_elem setText( time_left[ "minutes" ] + ":" + time_left[ "seconds" ] );
			}
			waittillframeend;
			timelimit_in_seconds = level.grief_gamerules[ "timelimit" ] * 60;
			time_left = parse_minutes( to_mins( timelimit_in_seconds ) );
			level.round_time_elem setText( time_left[ "minutes" ] + ":" + time_left[ "seconds" ] );
		}
		wait 1;
		timelimit_in_seconds--;
		if ( isInt( timelimit_in_seconds / 20 ) )
		{
			if ( level.script == "zm_transit" )
			{
				play_sound_2d( "evt_nomans_warning" );
			}
			else 
			{
				level thread maps/mp/zombies/_zm_audio::change_zombie_music( "round_start" );
			}
			level.round_time_elem clearalltextafterhudelem();
			level.round_time_elem settext( "" );
			level.round_time_elem destroy();
			create_round_timer();
			level.round_time_elem.alpha = 1;
		}
		time_left = parse_minutes( to_mins( timelimit_in_seconds ) );
		level.round_time_elem setText( time_left[ "minutes" ] + ":" + time_left[ "seconds" ] );
	}
}

create_round_timer()
{
	seconds_display = newhudelem();
	seconds_display.hidewheninmenu = 1;
	seconds_display.horzalign = "user_left";
	seconds_display.vertalign = "user_bottom";
	seconds_display.alignx = "bottom";
	seconds_display.aligny = "left";
	seconds_display.x = 0;
	seconds_display.y = 0;
	seconds_display.foreground = 1;
	seconds_display.font = "default";
	seconds_display.fontscale = 1.5;
	seconds_display.color = ( 1, 1, 1 );
	seconds_display.alpha = 0;
	level.round_time_elem = seconds_display;
}

parse_minutes( start_time )
{
	time = [];
	keys = strtok( start_time, ":" );
	time[ "hours" ] = keys[ 0 ];
	time[ "minutes" ] = keys[ 1 ];
	time[ "seconds" ] = keys[ 2 ];
	return time;
}


grief_score()
{   
	flag_wait( "initial_blackscreen_passed" );
	level.grief_score_hud = [];
	level.grief_score_hud[ "axis" ] = create_simple_hud();
	level.grief_score_hud[ "axis" ].x += 440;
	level.grief_score_hud[ "axis" ].y += 20;
	level.grief_score_hud[ "axis" ].fontscale = 2.5;
	level.grief_score_hud[ "axis" ].color = ( 0.423, 0.004, 0 );
	level.grief_score_hud[ "axis" ].alpha = 1;
	level.grief_score_hud[ "axis" ].hidewheninmenu = 1;
	level.grief_score_hud[ "axis" ] setValue( 0 );
	level.grief_score_hud[ "allies" ] = create_simple_hud();
	level.grief_score_hud[ "allies" ].x += 240;
	level.grief_score_hud[ "allies" ].y += 20;
	level.grief_score_hud[ "allies" ].fontscale = 2.5;
	level.grief_score_hud[ "allies" ].color = ( 0.423, 0.004, 0 );
	level.grief_score_hud[ "allies" ].alpha = 1;
	level.grief_score_hud[ "allies" ].hidewheninmenu = 1;
	level.grief_score_hud[ "allies" ] setValue( 0 );

	while ( 1 )
	{
		level waittill( "grief_point", team );
		level.grief_score_hud[ team ] SetValue( level.data_maps[ "encounters_teams" ][ "score" ][ level.teamIndex[ team ] ] );
	}	
}

grief_score_shaders()
{
	flag_wait( "initial_blackscreen_passed" );
	if ( level.script == "zm_prison" )
	{
		level.team_shader1 = create_simple_hud();
		level.team_shader2 = create_simple_hud();
		text = 1;
	}
	else
	{
		level.team_shader1 = createservericon( game[ "icons" ][ "axis" ], 35, 35 );
		level.team_shader2 = createservericon( game[ "icons" ][ "allies" ], 35, 35 );
	}
	if ( is_true( text ) )
	{
		level.team_shader1.x += 360;
		level.team_shader1.y += 20;
		level.team_shader1.fontscale = 2.5;
		level.team_shader1.color = ( 1, 0.333, 0.333 );
		level.team_shader1.alpha = 1;
		level.team_shader1.hidewheninmenu = 1;
		level.team_shader1.label = &"Inmates "; 
		level.team_shader2.x += 170;
		level.team_shader2.y += 20;
		level.team_shader2.fontscale = 2.5;
		level.team_shader2.color = ( 0, 0.004, 0.423 );
		level.team_shader2.alpha = 1;
		level.team_shader2.hidewheninmenu = 1;
		level.team_shader2.label = &"Guards "; 
	}
	else 
	{
		level.team_shader1.x += 90;
		level.team_shader1.y += -20;
		level.team_shader1.hideWhenInMenu = 1;
		level.team_shader2.x += -110;
		level.team_shader2.y += -20;
		level.team_shader2.hideWhenInMenu = 1;
	}
}
