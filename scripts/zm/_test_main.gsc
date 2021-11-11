#include common_scripts/utility;
#include maps/mp/_demo;
#include maps/mp/_utility;
#include maps/mp/_visionset_mgr;
#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/gametypes_zm/_weapons;
#include maps/mp/gametypes_zm/_zm_gametype;
#include maps/mp/zombies/_zm;
#include maps/mp/zombies/_zm_ai_basic;
#include maps/mp/zombies/_zm_ai_dogs;
#include maps/mp/zombies/_zm_audio;
#include maps/mp/zombies/_zm_audio_announcer;
#include maps/mp/zombies/_zm_blockers;
#include maps/mp/zombies/_zm_bot;
#include maps/mp/zombies/_zm_buildables;
#include maps/mp/zombies/_zm_clone;
#include maps/mp/zombies/_zm_devgui;
#include maps/mp/zombies/_zm_equipment;
#include maps/mp/zombies/_zm_ffotd;
#include maps/mp/zombies/_zm_game_module;
#include maps/mp/zombies/_zm_gump;
#include maps/mp/zombies/_zm_laststand;
#include maps/mp/zombies/_zm_magicbox;
#include maps/mp/zombies/_zm_melee_weapon;
#include maps/mp/zombies/_zm_perks;
#include maps/mp/zombies/_zm_pers_upgrades;
#include maps/mp/zombies/_zm_pers_upgrades_system;
#include maps/mp/zombies/_zm_pers_upgrades_functions;
#include maps/mp/zombies/_zm_playerhealth;
#include maps/mp/zombies/_zm_powerups;
#include maps/mp/zombies/_zm_power;
#include maps/mp/zombies/_zm_score;
#include maps/mp/zombies/_zm_sidequests;
#include maps/mp/zombies/_zm_spawner;
#include maps/mp/zombies/_zm_stats;
#include maps/mp/zombies/_zm_timer;
#include maps/mp/zombies/_zm_tombstone;
#include maps/mp/zombies/_zm_traps;
#include maps/mp/zombies/_zm_unitrigger;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_zonemgr;

main()
{
	// replaceFunc( maps/mp/zombies/_zm::init, ::init );
}

// init() //checked matches cerberus output
// {
// 	logprint( "_zm::init() start\n" );
// 	level.player_out_of_playable_area_monitor = 1;
// 	level.player_too_many_weapons_monitor = 1;
// 	level.player_too_many_weapons_monitor_func = ::player_too_many_weapons_monitor;
// 	level.player_too_many_players_check = 0; 
// 	level.player_too_many_players_check_func = ::player_too_many_players_check;
// 	level._use_choke_weapon_hints = 1;
// 	level._use_choke_blockers = 1;
// 	level.passed_introscreen = 0;
// 	if ( !isDefined( level.custom_ai_type ) )
// 	{
// 		level.custom_ai_type = [];
// 	}
// 	level.custom_ai_spawn_check_funcs = [];
// 	level.spawn_funcs = [];
// 	level.spawn_funcs[ "allies" ] = [];
// 	level.spawn_funcs[ "axis" ] = [];
// 	level.spawn_funcs[ "team3" ] = [];
// 	level thread maps/mp/zombies/_zm_ffotd::main_start();
// 	level.zombiemode = 1;
// 	level.revivefeature = 0;
// 	level.swimmingfeature = 0;
// 	level.calc_closest_player_using_paths = 0;
// 	level.zombie_melee_in_water = 1;
// 	level.put_timed_out_zombies_back_in_queue = 1;
// 	level.use_alternate_poi_positioning = 1;
// 	level.zmb_laugh_alias = "zmb_laugh_richtofen";
// 	level.sndannouncerisrich = 1;
// 	level.scr_zm_ui_gametype = getDvar( "ui_gametype" );
// 	level.scr_zm_ui_gametype_group = getDvar( "ui_zm_gamemodegroup" );
// 	level.scr_zm_map_start_location = getDvar( "ui_zm_mapstartlocation" );
// 	level.curr_gametype_affects_rank = 0;
// 	gametype = tolower( getDvar( "g_gametype" ) );
// 	if ( gametype == "zclassic" || gametype == "zstandard" )
// 	{
// 		level.curr_gametype_affects_rank = 1;
// 	}
// 	level.grenade_multiattack_bookmark_count = 1;
// 	level.rampage_bookmark_kill_times_count = 3;
// 	level.rampage_bookmark_kill_times_msec = 6000;
// 	level.rampage_bookmark_kill_times_delay = 6000;
// 	level thread watch_rampage_bookmark();
	
// 	//taken from the beta dump _zm
// 	level.GAME_MODULE_CLASSIC_INDEX = 0;
// 	maps\mp\zombies\_zm_game_module::register_game_module( level.GAME_MODULE_CLASSIC_INDEX,"classic", undefined, undefined );	
// 	maps\mp\zombies\_zm_game_module::set_current_game_module( level.scr_zm_game_module );
	
// 	if ( !isDefined( level._zombies_round_spawn_failsafe ) )
// 	{
// 		level._zombies_round_spawn_failsafe = ::round_spawn_failsafe;
// 	}
// 	level.zombie_visionset = "zombie_neutral";
// 	if ( getDvar( "anim_intro" ) == "1" )
// 	{
// 		level.zombie_anim_intro = 1;
// 	}
// 	else
// 	{
// 		level.zombie_anim_intro = 0;
// 	}
// 	precache_shaders();
// 	precache_models();
// 	precacherumble( "explosion_generic" );
// 	precacherumble( "dtp_rumble" );
// 	precacherumble( "slide_rumble" );
// 	precache_zombie_leaderboards();
// 	level._zombie_gib_piece_index_all = 0;
// 	level._zombie_gib_piece_index_right_arm = 1;
// 	level._zombie_gib_piece_index_left_arm = 2;
// 	level._zombie_gib_piece_index_right_leg = 3;
// 	level._zombie_gib_piece_index_left_leg = 4;
// 	level._zombie_gib_piece_index_head = 5;
// 	level._zombie_gib_piece_index_guts = 6;
// 	level._zombie_gib_piece_index_hat = 7;
// 	if ( !isDefined( level.zombie_ai_limit ) )
// 	{
// 		level.zombie_ai_limit = 24;
// 	}
// 	if ( !isDefined( level.zombie_actor_limit ) )
// 	{
// 		level.zombie_actor_limit = 31;
// 	}
// 	maps/mp/_visionset_mgr::init();
// 	init_dvars();
// 	init_strings();
// 	init_levelvars();
// 	init_sounds();
// 	init_shellshocks();
// 	init_flags();
// 	init_client_flags();
// 	registerclientfield( "world", "zombie_power_on", 1, 1, "int" );
// 	if ( !is_true( level._no_navcards ) )
// 	{
// 		if ( level.scr_zm_ui_gametype_group == "zclassic" && !level.createfx_enabled )
// 		{
// 			registerclientfield( "allplayers", "navcard_held", 1, 4, "int" );
// 			level.navcards = [];
// 			level.navcards[ 0 ] = "navcard_held_zm_transit";
// 			level.navcards[ 1 ] = "navcard_held_zm_highrise";
// 			level.navcards[ 2 ] = "navcard_held_zm_buried";
// 			level thread setup_player_navcard_hud();
// 		}
// 	}
// 	maps/mp/zombies/_zm_utility::register_offhand_weapons_for_level_defaults();
// 	level thread drive_client_connected_notifies();

// 	maps/mp/zombies/_zm_zonemgr::init();
// 	maps/mp/zombies/_zm_unitrigger::init();
// 	maps/mp/zombies/_zm_audio::init();
// 	maps/mp/zombies/_zm_blockers::init();
// 	//maps/mp/zombies/_zm_bot::init();
// 	maps/mp/zombies/_zm_clone::init();
// 	maps/mp/zombies/_zm_buildables::init();
// 	maps/mp/zombies/_zm_equipment::init();
// 	maps/mp/zombies/_zm_laststand::init();
// 	maps/mp/zombies/_zm_magicbox::init();
// 	maps/mp/zombies/_zm_perks::init();
	
// 	maps/mp/zombies/_zm_playerhealth::init();
	
// 	maps/mp/zombies/_zm_power::init();
// 	maps/mp/zombies/_zm_powerups::init();
// 	maps/mp/zombies/_zm_score::init();
// 	maps/mp/zombies/_zm_spawner::init();
// 	maps/mp/zombies/_zm_gump::init();
// 	//maps/mp/zombies/_zm_timer::init();
// 	maps/mp/zombies/_zm_traps::init();
// 	maps/mp/zombies/_zm_weapons::init();
// 	init_function_overrides();
// 	level thread last_stand_pistol_rank_init();
// 	level thread maps/mp/zombies/_zm_tombstone::init();
// 	level thread post_all_players_connected();
// 	init_utility();
// 	maps/mp/_utility::registerclientsys( "lsm" );
// 	maps/mp/zombies/_zm_stats::init();
// 	initializestattracking();
// 	if ( get_players().size <= 1 )
// 	{
// 		incrementcounter( "global_solo_games", 1 );
// 	}
// 	/*
// 	else if ( level.systemlink )
// 	{
// 		incrementcounter( "global_systemlink_games", 1 );
// 	}
// 	else if ( getDvarInt( "splitscreen_playerCount" ) == get_players().size )
// 	{
// 		incrementcounter( "global_splitscreen_games", 1 );
// 	}
// 	*/
// 	else
// 	{
// 		incrementcounter( "global_coop_games", 1 );
// 	}
// 	maps/mp/zombies/_zm_utility::onplayerconnect_callback( ::zm_on_player_connect );
// 	maps/mp/zombies/_zm_pers_upgrades::pers_upgrade_init();
// 	set_demo_intermission_point();
// 	level thread maps/mp/zombies/_zm_ffotd::main_end();
// 	level thread track_players_intersection_tracker();
// 	level thread onallplayersready();
// 	level thread startunitriggers();
// 	level thread maps/mp/gametypes_zm/_zm_gametype::post_init_gametype();
// 	logprint( "_zm::init() done\n" );
// }