#include maps/mp/zombies/_zm_utility;
#include maps/mp/zombies/_zm;
#include common_scripts/utility;
#include scripts/zm/grief/gametype/_pregame;
#include scripts/zm/grief/gametype/_hud;

generate_storage_maps()
{
	key_list = "str:player_name|str:team_name|bool:is_perm|bool:is_banned";
	key_names = "value_types|keys";
	scripts/zm/grief/gametype_modules/_gamerules::generate_map( "grief_preset_teams", key_list, key_names );
	key_list = "allies:B:0|axis:A:0"; //|team3:C:false:0|team4:D:false:0|team5:E:false:0|team6:F:false:0|team7:G:false:0|team8:H:false:0
	key_names = "team|e_team|score";
	scripts/zm/grief/gametype_modules/_gamerules::generate_map( "encounters_teams", key_list, key_names );
	level.data_maps[ "encounters_teams" ][ "score" ][ 0 ] = 0;
	level.data_maps[ "encounters_teams" ][ "score" ][ 1 ] = 0;
	level.team_index_grief[ "allies" ] = 0;
	level.team_index_grief[ "axis" ] = 1;
	team_count = getGametypeSetting( "teamCount" );
	for ( teamindex = 3; teamindex <= team_count; teamIndex++ )
	{
		level.team_index_grief[ "team" + teamindex ] = teamIndex - 1;
	}
	level.e_team_index_grief[ "B" ] = 0;
	level.e_team_index_grief[ "A" ] = 1;
	// team_count = getGametypeSetting( "teamCount" );
	// for ( teamindex = 3; teamindex <= team_count; teamIndex++ )
	// {
	// 	level.e_team_index_grief[ "team" + teamindex ] = teamIndex - 1;
	// }
}

grief_save_loadouts()
{
	while ( true )
	{
		flag_wait( "spawn_zombies" );
		players = getPlayers();
		foreach ( player in players )
		{
			if ( is_player_valid( player ) )
			{
				player scripts/zm/grief/mechanics/loadout/_weapons::grief_loadout_save();
			}
		}
		wait 1;
	}
}

check_for_match_winner( winner )
{
	if ( level.data_maps[ "encounters_teams" ][ "score" ][ level.team_index_grief[ winner ] ] == level.grief_gamerules[ "scorelimit" ] )
	{
		return true;
	}
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

match_end( winner )
{
	gametype = getDvar( "g_gametype" );
	keys = getArrayKeys( level.server_hudelems );
	for ( i = 0; i < keys.size; i++ )
	{
		level.server_hudelems[ keys[ i ] ].hudelem notify( "destroy_hud" );
		level.server_hudelems[ keys[ i ] ].hudelem destroy();
	}
	level.gamemodulewinningteam = winner;
	players = getPlayers();
	for ( i = 0; i < players.size; i++ )
	{
		players[ i ] freezecontrols( 1 );
		if ( players[ i ]._encounters_team == winner )
		{
			if ( gametype == "zgrief" )
			{
				players[ i ] thread maps/mp/zombies/_zm_audio_announcer::leaderdialogonplayer( "grief_won" );
			}
			players[ i ].pers[ "wins" ]++;
		}
		else 
		{
			if ( gametype == "zgrief" )
			{
				players[ i ] thread maps/mp/zombies/_zm_audio_announcer::leaderdialogonplayer( "grief_lost" );
			}
			players[ i ].pers[ "losses" ]++;
		}
	}
	level._game_module_game_end_check = undefined;
	maps/mp/gametypes_zm/_zm_gametype::track_encounters_win_stats( level.gamemodulewinningteam );
	if ( getPlayers().size <= 1 )
	{
		exitLevel();
	}
	else 
	{
		//level notify( "end_game" );
		level notify( "end_game2" );
		end_game();
	}
}

round_winner()
{
	winner = level.data_maps[ "encounters_teams" ][ "team" ][ level.e_team_index_grief[ level.predicted_round_winner ] ];
	level.data_maps[ "encounters_teams" ][ "score" ][ level.team_index_grief[ winner ] ]++;
	level.server_hudelems[ "grief_score_" + winner ].hudelem SetValue( level.data_maps[ "encounters_teams" ][ "score" ][ level.team_index_grief[ winner ] ] );
	setTeamScore( winner, level.data_maps[ "encounters_teams" ][ "score" ][ level.team_index_grief[ winner ] ] );
	if ( check_for_match_winner( winner ) )
	{
		match_end( level.data_maps[ "encounters_teams" ][ "team" ][ level.e_team_index_grief[ level.predicted_round_winner ] ] );
		return;
	}
	start_new_round( false );
}

round_restart()
{
	start_new_round( true );
}

check_for_surviving_team()
{
	level endon( "end_game2" );
	new_round = false;
	while ( 1 )
	{
		while ( !flag( "spawn_zombies" ) || new_round )
		{
			if ( flag( "spawn_zombies" ) )
			{
				break;
			}
			wait 1;
		}
		new_round = false;
		if ( count_alive_teams() == 0 )
		{
			new_round = true;
			round_restart();
		}
		else if ( count_alive_teams() == 1 && isDefined( level.predicted_round_winner ) )
		{
			wait level.grief_gamerules[ "suicide_check" ];
			if ( count_alive_teams() == 0 )
			{
				new_round = true;
				round_restart();
				wait 0.05;
				continue;
			}
			new_round = true;
			round_winner();
		}
		wait 0.05;
	}
}

count_alive_teams()
{
	if ( !isDefined( level.times_called ) )
	{
		level.times_called = 0;
	}
	players = getPlayers();
	teams = [];
	alive_teams = 0;
	level.predicted_round_winner = undefined;
	foreach ( e_team in level.data_maps[ "encounters_teams" ][ "e_team" ] )
	{
		teams[ e_team ] = [];
		teams[ e_team ][ "alive_players" ] = 0;
		teams[ e_team ][ "is_alive" ] = false;
	}
	for ( i = 0; i < players.size; i++ )
	{
		foreach ( e_team in level.data_maps[ "encounters_teams" ][ "e_team" ] )
		{
			if ( is_player_valid( players[ i ] ) )
			{
				if ( players[ i ]._encounters_team == e_team )
				{
					teams[ e_team ][ "alive_players" ]++;
				}
			}
			if ( teams[ e_team ][ "alive_players" ] > 0 && !teams[ e_team ][ "is_alive" ] )
			{
				alive_teams++;
				teams[ e_team ][ "is_alive" ] = true;
				level.predicted_round_winner = e_team;
			}
		}
	}
	level.times_called++;
	return alive_teams;
}

zgrief_main_override()
{
	flag_wait( "initial_blackscreen_passed" );
	match_start();
	players = getPlayers();
	foreach ( player in players )
	{
		player.is_hotjoin = 0;
	}
	wait 1;
}

match_start()
{
	if ( getDvar( "g_gametype" ) == "zclassic" )
	{
		scripts/zm/grief/gametype_modules/_gametype_setup::setup_classic_gametype_override();
	}
	while ( flag( "in_pregame" ) )
	{
		wait 0.05;
	}
	freeze_all_players_controls();
	//level thread maps/mp/zombies/_zm_audio::change_zombie_music( "round_start" );
	flag_clear( "spawn_zombies" );
	level thread scripts/zm/grief/mechanics/_zombies::zombie_spawning();
	flag_set( "match_start" );
	flag_set( "first_round" );
	level.rounds_played = 0;
	level.timer_reset = false;
	scripts/zm/grief/gametype/_hud::hud_init(); //part of _hud module
	//flag_set( "timer_pause" );
	setdvar( "ui_scorelimit", level.grief_gamerules[ "scorelimit" ] );
	makeDvarServerInfo( "ui_scorelimit" );
	//level thread timed_rounds(); //3
	start_new_round( false ); //2
	level thread grief_save_loadouts();
	level thread check_for_surviving_team(); //1
	flag_clear( "first_round" );
}

start_new_round( is_restart )
{
	if ( flag( "spawn_zombies" ) )
	{
		flag_clear( "spawn_zombies" );
	}
	all_surviving_players_invulnerable();
	kill_all_zombies();
	all_surviving_players_vulnerable();
	if ( !is_restart )
	{
		scripts/zm/grief/mechanics/_zombies::set_zombie_power_level( level.grief_gamerules[ "zombie_power_level_start" ] );
	}
	level notify( "timer_end_round" );
	if ( !flag( "first_round" ) )
	{
		level thread maps/mp/zombies/_zm_audio::change_zombie_music( "round_end" );
		flag_set( "spawn_players" );
		respawn_players();
		visionSetNaked( GetDvar( "mapname" ) );
	}
	if ( is_true( is_restart ) )
	{
		level thread grief_reset_message();
		level.timer_reset = false;
	}
	else 
	{
		if ( !flag( "first_round" ) && ( level.grief_gamerules[ "next_round_time" ] > 0 ) )
		{
			freeze_all_players_controls();
			round_countdown_text = round_change_hud_text();
			round_countdown_timer = round_change_hud_timer_elem();
			visionSetNaked( GetDvar( "mapname" ), level.grief_gamerules[ "next_round_time" ] );
			wait level.grief_gamerules[ "next_round_time" ];
			round_countdown_text destroy();
			round_countdown_timer destroy();
			level.timer_reset = true;
		}
		level.rounds_played++;
	}
	scripts/zm/grief/mechanics/_griefing::reset_players_last_griefed_by();
	give_points_on_restart_and_round_change();
	level notify( "timer_start_pre_round" );
	unfreeze_all_players_controls();
	level.in_grief_pre_round = true;
	wait level.grief_gamerules[ "round_zombie_spawn_delay" ];
	level thread maps/mp/zombies/_zm_audio::change_zombie_music( "round_start" );
	maps/mp/zombies/_zm_powerups::powerup_round_start();
	flag_clear( "spawn_players" );
	if ( !flag( "spawn_zombies" ) )
	{
		flag_set( "spawn_zombies" );
	}
	level.in_grief_pre_round = false;
}

give_points_on_restart_and_round_change()
{
	players = getPlayers();
	foreach ( player in players )
	{
		if ( player.score < level.grief_gamerules[ "round_restart_points" ] )
		{
			player.score = level.grief_gamerules[ "round_restart_points" ];
		}
	}
}

// timed_rounds()
// {
// 	timelimit_in_seconds = int( level.grief_gamerules[ "timelimit" ] * 60 );
// 	time_left = parse_minutes( to_mins( timelimit_in_seconds ) );
// 	//BEG Overflow fix
// 	level.overflow_elem = maps/mp/gametypes_zm/_hud_util::createServerFontString( "default", 1.5 );
// 	level.overflow_elem setText("xTUL"); //dont remove text here
// 	level.overflow_elem.alpha = 0;
// 	//END Overflow fix
// 	cur_rounds_played = level.rounds_played;
// 	level.server_hudelems[ "timer" ].hudelem.alpha = 0;
// 	while ( true )
// 	{
// 		if ( flag( "timer_pause" ) )
// 		{
// 			level.server_hudelems[ "timer" ].hudelem.alpha = 0;
// 			while ( flag( "timer_pause" ) )
// 			{
// 				wait 1;
// 			}
// 			zombie_spawn_delay = level.grief_gamerules[ "round_zombie_spawn_delay" ];
// 			level.server_hudelems[ "timer" ].hudelem.alpha = 1;
// 			while ( zombie_spawn_delay > 0 )
// 			{
// 				time_left = parse_minutes( to_mins( zombie_spawn_delay ) );
// 				timeleft_text = time_left[ "minutes" ] + ":" + time_left[ "seconds" ];
// 				level.server_hudelems[ "timer" ].hudelem HUDELEM_SET_TEXT( timeleft_text );
// 				wait 1;
// 				zombie_spawn_delay--;
// 			}
// 			waittillframeend;
// 			if ( cur_rounds_played != level.rounds_played )
// 			{
// 				timelimit_in_seconds = int( level.grief_gamerules[ "timelimit" ] * 60 );
// 				cur_rounds_played = level.rounds_played;
// 			}
// 		}
// 		level.server_hudelems[ "timer" ].hudelem.alpha = 0; //hide the timer for now
// 		time_left = parse_minutes( to_mins( timelimit_in_seconds ) );
// 		timeleft_text = time_left[ "minutes" ] + ":" + time_left[ "seconds" ];
// 		level.server_hudelems[ "timer" ].hudelem HUDELEM_SET_TEXT( timeleft_text );
// 		wait 1;
// 		timelimit_in_seconds--;
// 		if ( ( timelimit_in_seconds % level.zombies_powerup_time ) == 0 )
// 		{
// 			if ( level.script == "zm_transit" )
// 			{
// 				play_sound_2d( "evt_nomans_warning" );
// 			}
// 			else 
// 			{
// 				level thread maps/mp/zombies/_zm_audio::change_zombie_music( "round_start" );
// 			}
// 			scripts/zm/grief/mechanics/_zombies::powerup_zombies();
// 		}
// 		if ( ( timelimit_in_seconds % 20 ) == 0 )
// 		{
// 			level.overflow_elem ClearAllTextAfterHudElem();
// 			level.server_hudelems[ "timer" ].hudelem destroy();
// 			level.server_hudelems[ "timer" ].hudelem = [[ level.server_hudelem_funcs[ "timer" ] ]]();
// 		}
// 	}
// }

timed_rounds()
{
	timer = scripts/zm/grief/gametype/_hud::round_timer_hud_elem();
	timelimit_in_seconds = int( level.grief_gamerules[ "timelimit" ] * 60 );
	level.cur_round_time = timelimit_in_seconds;
	while ( true )
	{
		timer.alpha = 0;
		time_round_end();
		time_pre_round( timer );
		flag_wait( "spawn_zombies" );
		if ( level.timer_reset )
		{
			level.cur_round_time = int( level.grief_gamerules[ "timelimit" ] * 60 );
		}
		timer setTimer( level.cur_round_time );
		time_during_round();
	}
}

time_round_end()
{
	level endon( "timer_start_pre_round" );
	while ( true )
	{
		wait 1;
	}
}

time_pre_round( timer )
{
	//timer.alpha = 1;
	timer setTimer( level.grief_gamerules[ "round_zombie_spawn_delay" ] );
	for ( zombie_spawn_delay = level.grief_gamerules[ "round_zombie_spawn_delay" ]; zombie_spawn_delay > 0; zombie_spawn_delay-- )
	{
		wait 1;
	}
}

time_during_round()
{
	level endon( "timer_end_round" );
	timelimit_in_seconds = int( level.grief_gamerules[ "timelimit" ] * 60 );
	while ( true )
	{
		wait 1;
		level.cur_round_time--;
		if ( level.cur_round_time == ceil( timelimit_in_seconds / 2 ) )
		{
			//halftime
		}
		else if ( level.cur_round_time == 0 )
		{
			//overtime
		}
		else if ( ( level.cur_round_time % level.zombies_powerup_time ) == 0 )
		{
			if ( level.script == "zm_transit" )
			{
				play_sound_2d( "evt_nomans_warning" );
			}
			else 
			{
				level thread maps/mp/zombies/_zm_audio::change_zombie_music( "round_start" );
			}
			scripts/zm/grief/mechanics/_zombies::powerup_zombies();
		}
	}
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

kill_all_zombies()
{
	zombies = getaispeciesarray( level.zombie_team, "all" );
	for ( i = 0; i < zombies.size; i++ )
	{
		if ( isDefined( zombies[ i ] ) && isAlive( zombies[ i ] ) )
		{
			zombies[ i ] dodamage( zombies[ i ].health + 666, zombies[ i ].origin );
		}
	}
}

all_surviving_players_invulnerable()
{
	players = getPlayers();
	foreach ( player in players )
	{
		if ( is_player_valid( player ) )
		{
			player enableInvulnerability();
		}
	}
}

all_surviving_players_vulnerable()
{
	players = getPlayers();
	foreach ( player in players )
	{
		if ( is_player_valid( player ) )
		{
			player disableInvulnerability();
		}
	}
}

respawn_players()
{
	players = getPlayers();
	foreach ( player in players )
	{
		player [[ level.spawnplayer ]]();
	}
}

freeze_all_players_controls()
{
	players = getPlayers();
	foreach ( player in players )
	{
		player freezeControls( 1 );
	}
}

unfreeze_all_players_controls()
{
	players = getPlayers();
	foreach ( player in players )
	{
		player freezeControls( 0 );
	}
}

grief_reset_message()
{
	msg = &"ZOMBIE_GRIEF_RESET";
	// players = getPlayers();
	// foreach ( player in players )
	// {
	// 	player thread scripts/zm/grief/gametype/_grief_hud::show_grief_hud_msg( msg );
	// }
	level thread maps/mp/zombies/_zm_audio_announcer::leaderdialog( "grief_restarted" );
}

end_game() //checked changed to match cerberus output
{
	check_end_game_intermission_delay();
	clientnotify( "zesn" );
	if ( isDefined( level.sndgameovermusicoverride ) )
	{
		level thread maps/mp/zombies/_zm_audio::change_zombie_music( level.sndgameovermusicoverride );
	}
	else
	{
		level thread maps/mp/zombies/_zm_audio::change_zombie_music( "game_over" );
	}
	players = get_players();
	for ( i = 0; i < players.size; i++ )
	{
		setclientsysstate( "lsm", "0", players[ i ] );
	}
	for ( i = 0; i < players.size; i++ )
	{
		if ( players[ i ] player_is_in_laststand() )
		{
			players[ i ] recordplayerdeathzombies();
			players[ i ] maps/mp/zombies/_zm_stats::increment_player_stat( "deaths" );
			players[ i ] maps/mp/zombies/_zm_stats::increment_client_stat( "deaths" );
			players[ i ] maps/mp/zombies/_zm_pers_upgrades_functions::pers_upgrade_jugg_player_death_stat();
		}
		if ( isdefined( players[ i ].revivetexthud) )
		{
			players[ i ].revivetexthud destroy();
		}
	}
	stopallrumbles();
	level.intermission = 1;
	level.zombie_vars[ "zombie_powerup_insta_kill_time" ] = 0;
	level.zombie_vars[ "zombie_powerup_fire_sale_time" ] = 0;
	level.zombie_vars[ "zombie_powerup_point_doubler_time" ] = 0;
	wait 0.1;
	game_over = [];
	survived = [];
	players = get_players();
	setmatchflag( "disableIngameMenu", 1 );
	foreach ( player in players )
	{
		player closemenu();
		player closeingamemenu();
	}
	if ( !isDefined( level._supress_survived_screen ) )
	{
		for ( i = 0; i < players.size; i++ )
		{
			if ( isDefined( level.custom_game_over_hud_elem ) )
			{
				game_over[ i ] = [[ level.custom_game_over_hud_elem ]]( players[ i ] );
			}
			else
			{
				game_over[ i ] = newclienthudelem( players[ i ] );
				game_over[ i ].alignx = "center";
				game_over[ i ].aligny = "middle";
				game_over[ i ].horzalign = "center";
				game_over[ i ].vertalign = "middle";
				game_over[ i ].y -= 130;
				game_over[ i ].foreground = 1;
				game_over[ i ].fontscale = 3;
				game_over[ i ].alpha = 0;
				game_over[ i ].color = ( 1, 1, 1 );
				game_over[ i ].hidewheninmenu = 1;
				game_over[ i ] settext( &"ZOMBIE_GAME_OVER" );
				game_over[ i ] fadeovertime( 1 );
				game_over[ i ].alpha = 1;
				/*
				if ( players[ i ] issplitscreen() )
				{
					game_over[ i ].fontscale = 2;
					game_over[ i ].y += 40;
				}
				*/
			}
			survived[ i ] = newclienthudelem( players[ i ] );
			survived[ i ].alignx = "center";
			survived[ i ].aligny = "middle";
			survived[ i ].horzalign = "center";
			survived[ i ].vertalign = "middle";
			survived[ i ].y -= 100;
			survived[ i ].foreground = 1;
			survived[ i ].fontscale = 2;
			survived[ i ].alpha = 0;
			survived[ i ].color = ( 1, 1, 1 );
			survived[ i ].hidewheninmenu = 1;
			/*
			if ( players[ i ] issplitscreen() )
			{
				survived[ i ].fontscale = 1.5;
				survived[ i ].y += 40;
			}
			*/
			if ( level.round_number < 2 )
			{
				if ( level.script == "zombie_moon" )
				{
					if ( !isDefined( level.left_nomans_land ) )
					{
						nomanslandtime = level.nml_best_time;
						player_survival_time = int( nomanslandtime / 1000 );
						player_survival_time_in_mins = maps/mp/zombies/_zm::to_mins( player_survival_time );
						survived[ i ] settext( &"ZOMBIE_SURVIVED_NOMANS", player_survival_time_in_mins );
					}
					else if ( level.left_nomans_land == 2 )
					{
						survived[ i ] settext( &"ZOMBIE_SURVIVED_ROUND" );
					}
				}
				else
				{
					survived[ i ] settext( &"ZOMBIE_SURVIVED_ROUND" );
				}
			}
			else
			{
				survived[ i ] settext( &"ZOMBIE_SURVIVED_ROUNDS", level.round_number );
			}
			survived[ i ] fadeovertime( 1 );
			survived[ i ].alpha = 1;
		}
	}
	if ( isDefined( level.custom_end_screen ) )
	{
		level [[ level.custom_end_screen ]]();
	}
	for ( i = 0; i < players.size; i++ )
	{
		players[ i ] setclientammocounterhide( 1 );
		players[ i ] setclientminiscoreboardhide( 1 );
	}
	uploadstats();
	maps/mp/zombies/_zm_stats::update_players_stats_at_match_end( players );
	maps/mp/zombies/_zm_stats::update_global_counters_on_match_end();
	wait 1;
	wait 3.95;
	players = get_players();
	foreach ( player in players )
	{
		if ( isdefined( player.sessionstate ) && player.sessionstate == "spectator" )
		{
			player.sessionstate = "playing";
		}
	}
	wait 0.05;
	players = get_players();
	if ( !isDefined( level._supress_survived_screen ) )
	{
		for(i = 0; i < players.size; i++)
		{
			survived[ i ] destroy();
			game_over[ i ] destroy();
		}
	}
	for ( i = 0; i < players.size; i++ )
	{
		if ( isDefined( players[ i ].survived_hud ) )
		{
			players[ i ].survived_hud destroy();
		}
		if ( isDefined( players[ i ].game_over_hud ) )
		{
			players[ i ].game_over_hud destroy();
		}
	}
	intermission();
	wait level.zombie_vars[ "zombie_intermission_time" ];
	level notify( "stop_intermission" );
	array_thread( get_players(), ::player_exit_level );
	bbprint( "zombie_epilogs", "rounds %d", level.round_number );
	wait 1.5;
	players = get_players();
	for ( i = 0; i < players.size; i++ )
	{
		players[ i ] cameraactivate( 0 );
	}
	exitlevel( 0 );
	wait 666;
}