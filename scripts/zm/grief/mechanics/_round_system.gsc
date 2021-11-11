#include maps/mp/zombies/_zm_utility;
#include maps/mp/zombies/_zm;
#include common_scripts/utility;
#include scripts/zm/grief/gametype/_pregame;

init_replacements()
{
	//replaceFunc( maps/mp/zombies/_zm::round_start, ::round_start_override );
}

generate_storage_maps()
{
	key_list = "str:player_name|str:team_name|bool:is_perm|bool:is_banned";
	key_names = "value_types|keys";
	scripts/zm/grief/gametype_modules/_gamerules::generate_map( "grief_preset_teams", key_list, key_names );
	key_list = "allies:B:false:0|axis:A:false:0"; //|team3:C:false:0|team4:D:false:0|team5:E:false:0|team6:F:false:0|team7:G:false:0|team8:H:false:0
	key_names = "team|e_team|alive|score";
	scripts/zm/grief/gametype_modules/_gamerules::generate_map( "encounters_teams", key_list, key_names );
}

grief_save_loadouts()
{
	while ( true )
	{
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
	level thread kill_all_zombies();
	level thread freeze_all_players_controls();
	level thread maps/mp/zombies/_zm_audio::change_zombie_music( "round_end" );
	level thread round_change_hud();
	wait level.grief_gamerules[ "next_round_time" ];
	flag_clear( "timer_pause" );
	level thread start_new_round( false );
}

check_for_surviving_team()
{
	level endon( "end_game" );
	level thread grief_save_loadouts();
	while ( 1 )
	{
		flag_wait( "spawn_zombies" );
		if ( count_alive_teams() == 0 )
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
	level.pause_timer = false;
	scripts/zm/grief/gametype/_pregame::pregame();
	unfreeze_all_players_controls();
	level thread maps/mp/zombies/_zm_audio::change_zombie_music( "round_start" );
	level thread scripts/zm/grief/mechanics/_zombies::zombie_spawning();
	// level thread check_for_surviving_team();
	flag_set( "first_round" );
	level.rounds_played = 1;
	// start_new_round( false, level.grief_gamerules[ "zombie_round" ] );
	flag_clear( "first_round" );
	flag_set( "match_start" );
	// scripts/zm/grief/gametype/_hud::hud_init();
	// scripts/zm/grief/gametype/_hud::fadein_grief_hud();
	// level thread update_grief_score();
	// level thread timed_rounds();
}

start_new_round( is_restart, round_number )
{
	level.new_round_started = true;
	if ( isDefined( round_number ) )
	{
		scripts/zm/grief/mechanics/_zombies::set_zombie_power_level( round_number );
	}
	if ( is_true( is_restart ) )
	{
		flag_clear( "spawn_zombies" );
		level thread kill_all_zombies();
		level thread grief_reset_message();
	}
	else 
	{
		level.rounds_played++;
	}
	all_surviving_players_vulnerable();
	scripts/zm/grief/mechanics/_griefing::reset_players_last_griefed_by();
	if ( !flag( "first_round" ) )
	{
		flag_set( "spawn_players" );
		respawn_players();
	}
	unfreeze_all_players_controls();
	level thread maps/mp/zombies/_zm_audio::change_zombie_music( "round_start" );
	level notify( "grief_new_round" );
	wait level.grief_gamerules[ "round_zombie_spawn_delay" ];
	flag_clear( "spawn_players" );
	flag_set( "spawn_zombies" );
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
			scripts/zm/grief/gametype/_hud::countdown_pulse( level.round_countdown_timer, timer );
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

timed_rounds() //checked matches cerberus output
{
	level endon( "end_game" );
	create_round_timer();
	timelimit_in_seconds = int( level.grief_gamerules[ "timelimit" ] * 60 );
	time_left = parse_minutes( to_mins( timelimit_in_seconds ) );
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
			timelimit_in_seconds = int( level.grief_gamerules[ "timelimit" ] * 60 );
			time_left = parse_minutes( to_mins( timelimit_in_seconds ) );
			level.round_time_elem setText( time_left[ "minutes" ] + ":" + time_left[ "seconds" ] );
		}
		wait 1;
		timelimit_in_seconds--;
		if ( timelimit_in_seconds % 20 == 0 )
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
			scripts/zm/grief/mechanics/_zombies::powerup_zombies();
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
	seconds_display.foreground = 1;
	seconds_display.font = "default";
	seconds_display.fontscale = 1.5;
	seconds_display.color = ( 1, 1, 1 );
	seconds_display.alpha = 1;
	level.round_time_elem = seconds_display;
	level.round_time_elem thread scripts/zm/grief/gametype/_hud::destroy_on_end_game();
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
			wait randomfloatrange( 0.10, 0.30 );
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
		player freezeControls( 1 );
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

update_grief_score()
{
	level endon( "end_game" );
	while ( 1 )
	{
		level waittill( "grief_point", team );
		level.grief_score_hud[ team ] SetValue( level.data_maps[ "encounters_teams" ][ "score" ][ level.teamIndex[ team ] ] );
	}	
}

grief_reset_message()
{
	msg = &"ZOMBIE_GRIEF_RESET";
	players = getPlayers();
	if ( isDefined( level.hostmigrationtimer ) )
	{
		while ( isDefined( level.hostmigrationtimer ) )
		{
			wait 0.05;
		}
		wait 4;
	}
	foreach ( player in players )
	{
		player thread scripts/zm/grief/gametype/_grief_hud::show_grief_hud_msg( msg );
	}
	level thread maps/mp/zombies/_zm_audio_announcer::leaderdialog( "grief_restarted" );
}