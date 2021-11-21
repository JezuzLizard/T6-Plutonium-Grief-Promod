/*
	This script sets up all global overrides and includes for the mod.
*/

#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/zombies/_zm_magicbox;
#include maps/mp/gametypes_zm/_zm_gametype;
#include maps/mp/zombies/_zm_game_module;
#include maps/mp/zombies/_zm_audio_announcer;
#include maps/mp/gametypes_zm/_hud_util;


#include scripts/zm/grief/audio/_announcer_fix;
//scripts/zm/grief/commands/promod_commands;
#include scripts/zm/grief/gametype/_grief_hud;
#include scripts/zm/grief/gametype/_health_bar;
#include scripts/zm/grief/gametype/_hud;
#include scripts/zm/grief/gametype/_obituary;
#include scripts/zm/grief/gametype/_pregame;

#include scripts/zm/grief/gametype_modules/_gamerules;
#include scripts/zm/grief/gametype_modules/_gametype_setup;
#include scripts/zm/grief/gametype_modules/_player_spawning;
#include scripts/zm/grief/gametype_modules/_power;

#include scripts/zm/grief/mechanics/loadout/_perks;
#include scripts/zm/grief/mechanics/loadout/_weapons;

#include scripts/zm/grief/mechanics/_griefing;
#include scripts/zm/grief/mechanics/_player_health;
#include scripts/zm/grief/mechanics/_point_steal;
#include scripts/zm/grief/mechanics/_powerups;
#include scripts/zm/grief/mechanics/_round_system;
#include scripts/zm/grief/mechanics/_zombies;

#include scripts/zm/grief/persistence/_session_data;

#include scripts/zm/grief/team/_teams;

main()
{
	//BEG _announcer_fix module
	replaceFunc( maps/mp/zombies/_zm_audio_announcer::playleaderdialogonplayer, scripts/zm/grief/audio/_announcer_fix::playleaderdialogonplayer_override );
	//END _announcer_fix module

	//BEG _obituary module
	replaceFunc( maps/mp/zombies/_zm_utility::track_players_intersection_tracker, scripts/zm/grief/gametype/_obituary::track_players_intersection_tracker_override );
	//END _obituary module

	//BEG _gamerules module
	scripts/zm/grief/gametype_modules/_gamerules::init_gamerules();
	replaceFunc( maps/mp/zombies/_zm_magicbox::treasure_chest_init, scripts/zm/grief/gametype_modules/_gamerules::treasure_chest_init_override );
	//END _gamerules module

	//BEG _gametype_setup module 
	replaceFunc( maps/mp/gametypes_zm/_zm_gametype::rungametypeprecache, scripts/zm/grief/gametype_modules/_gametype_setup::rungametypeprecache_override );
	replaceFunc( maps/mp/gametypes_zm/_zm_gametype::rungametypemain, scripts/zm/grief/gametype_modules/_gametype_setup::rungametypemain_override );
	replaceFunc( maps/mp/gametypes_zm/_zm_gametype::game_objects_allowed, scripts/zm/grief/gametype_modules/_gametype_setup::game_objects_allowed_override );
	replaceFunc( maps/mp/gametypes_zm/_zm_gametype::setup_standard_objects, scripts/zm/grief/gametype_modules/_gametype_setup::setup_standard_objects_override );
	replaceFunc( maps/mp/gametypes_zm/_zm_gametype::setup_classic_gametype, scripts/zm/grief/gametype_modules/_gametype_setup::setup_classic_gametype_override );
	replaceFunc( maps/mp/zombies/_zm_zonemgr::manage_zones, scripts/zm/grief/gametype_modules/_gametype_setup::manage_zones_override );
	//END _gametype_setup module 

	//BEG _player_spawning module
	replaceFunc( maps/mp/gametypes_zm/_zm_gametype::get_player_spawns_for_gametype, scripts/zm/grief/gametype_modules/_player_spawning::get_player_spawns_for_gametype_override );
	//END _player_spawning module

	//BEG _power module
	replaceFunc( maps/mp/zombies/_zm_blockers::waittill_door_can_close, scripts/zm/grief/gametype_modules/_power::waittill_door_can_close_override );
	//END _power module

	//BEG _perks module
	replaceFunc( maps/mp/zombies/_zm_perks::perk_set_max_health_if_jugg, scripts/zm/grief/mechanics/loadout/_perks::perk_set_max_health_if_jugg_override );
	//END _perks module

	//BEG _player_health module
	replaceFunc( maps/mp/zombies/_zm_playerhealth::onplayerspawned, scripts/zm/grief/mechanics/_player_health::onplayerspawned_override );
	//END _player_health module
	
	//BEG _pregame module
	level.player_movement_suppressed = true;
	flag_init( "in_pregame", 0 );
	flag_init( "player_quota", 0 );
	level thread scripts/zm/grief/gametype/_pregame::pregame();
	//END _pregame module

	//BEG promod_main module
	replaceFunc( common_scripts/utility::struct_class_init, ::struct_class_init_override );
	replaceFunc( maps/mp/zombies/_zm::onallplayersready, ::onallplayersready_override );
	replaceFunc( maps/mp/gametypes_zm/_zm_gametype::hide_gump_loading_for_hotjoiners, ::hide_gump_loading_for_hotjoiners_override );
	level.crash_delay = 20;
	level thread on_player_connect();
	level thread emptyLobbyRestart();
	//END promod_main module

	//BEG _powerups module
	// replaceFunc( maps/mp/zombies/_zm_powerups::randomize_powerups, scripts/zm/grief/mechanics/_powerups::randomize_powerups_override );
	// replaceFunc( maps/mp/zombies/_zm_powerups::get_next_powerup, scripts/zm/grief/mechanics/_powerups::get_next_powerup_override );
	// replaceFunc( maps/mp/zombies/_zm_powerups::get_valid_powerup, scripts/zm/grief/mechanics/_powerups::get_valid_powerup_override );
	//replaceFunc( maps/mp/zombies/_zm_powerups::powerup_drop, scripts/zm/grief/mechanics/_powerups::powerup_drop_override );
	//END _powerups module

	//BEG _round_system module
	scripts/zm/grief/mechanics/_round_system::generate_storage_maps();
	flag_init( "match_start", 0 );
	flag_init( "timer_pause", 0 );
	flag_init( "first_round", 0 );
	flag_init( "spawn_players", 1 );
	flag_init( "timer_reset", 0 );
	//END _round_system module

	//BEG _teams module
	replaceFunc( maps/mp/gametypes_zm/_zm_gametype::menu_onmenuresponse, scripts/zm/grief/team/_teams::menu_onmenuresponse_override );
	level.team_change_cooldown = 60;
	level.team_change_max = 2;
	level.grief_team_members = [];
	level.grief_team_members[ "allies" ] = 0;
	level.grief_team_members[ "axis" ] = 0;
	//END _teams module

	//BEG _zombies module
	replaceFunc( maps/mp/zombies/_zm_utility::init_zombie_run_cycle, scripts/zm/grief/mechanics/_zombies::init_zombie_run_cycle_override );
	level.zombies_power_level = 1;
	level.zombies_powerup_time = 20;
	//END _zombies module

	//BEG _point_steal module
	replaceFunc( maps/mp/zombies/_zm_score::player_reduce_points, scripts/zm/grief/mechanics/_point_steal::player_reduce_points_override );
	//END _point_steal module
}

init()
{
	level.playerSuicideAllowed = false;
	level.noroundnumber = 1;
	setDvar( "g_friendlyfireDist", 0 );
	level.game_mode_custom_onplayerdisconnect = scripts/zm/grief/gametype/_grief_hud::grief_onplayerdisconnect; //part of _grief_hud module
	level._game_module_player_damage_callback = scripts/zm/grief/mechanics/_griefing::game_module_player_damage_callback; //part of _griefing module
	level.onspawnplayerunified = scripts/zm/grief/gametype_modules/_player_spawning::onspawnplayerunified; //part of _player_spawning module
	level.autoassign = scripts/zm/grief/team/_teams::default_menu_autoassign; //part of _teams module
	level.onplayerdisconnect = ::onplayerdisconnect;
	check_quickrevive_for_hotjoin();
}

emptyLobbyRestart()
{
	level endon( "end_game" );
	while ( true )
	{
		if ( getPlayers().size > 0 )
		{
			while ( true )
			{
				if ( getPlayers().size < 1  )
				{
					map_restart( false );
				}
				wait 1;
			}
		}
		wait 1;
	}
}

on_player_connect()
{
	while ( true )
	{
		level waittill( "connected", player );
		if ( is_true( level.intermission ) )
		{
			return;
		}
		player thread game_module_on_player_spawned();
		player scripts/zm/grief/gametype/_grief_hud::grief_onplayerconnect();
		if ( isDefined( level.grief_connected_callback ) )
		{
			self [[ level.grief_connected_callback ]]();
		}
		if ( level.grief_gamerules[ "knife_lunge" ] )
		{
			player setClientDvar( "aim_automelee_range", 120 );
		}
		else
		{
			player setClientDvar( "aim_automelee_range", 0 );
		}
		player thread health_bar_hud(); //part of _health_bar
		player thread afk_kick();
		if ( !isDefined( player.last_griefed_by ) )
		{
			player.last_griefed_by = spawnStruct();
			player.last_griefed_by.attacker = undefined;
			player.last_griefed_by.meansofdeath = undefined;
			player.last_griefed_by.weapon = undefined;
			player.last_griefed_by.time = 0;
			player thread scripts/zm/grief/gametype/_obituary::watch_for_down();
		}
		player thread scripts/zm/grief/mechanics/_round_system::give_points_on_restart_and_round_change();
		player scripts/zm/grief/persistence/_session_data::init_player_session_data();
		player.killsconfirmed = 0;
		player.stabs = 0;
		player.assists = 0;

		player.new_team = player.team;
	}
}

afk_kick()
{
	level endon( "end_game" );
	self endon("disconnect");
	if ( is_true( self.grief_is_admin ) )
	{
		return;
	}
	time = 0;
	while( true )
	{   
		if ( self.sessionstate == "spectator" || level.players.size <= 2 )
		{	
			wait 1;
			continue;
		}
		if( self usebuttonpressed() || self jumpbuttonpressed() || self meleebuttonpressed() || self attackbuttonpressed() || self adsbuttonpressed() || self sprintbuttonpressed() )
		{
			time = 0;
		}
		if( time == 3600 ) //3mins
		{
			kick( self getEntityNumber() );
		}
		wait 0.05;
		time++;
	}
}

game_module_on_player_spawned() //checked partially changed to cerberus output
{
	level endon( "end_game" );
	self endon( "disconnect" );
	for ( ;; )
	{
		self waittill_either( "spawned_player", "fake_spawned_player" );
		if ( self maps/mp/zombies/_zm_laststand::player_is_in_laststand() )
		{
			self thread maps/mp/zombies/_zm_laststand::auto_revive( self );
		}
		if ( isDefined( level.custom_player_fake_death_cleanup ) )
		{
			self [[ level.custom_player_fake_death_cleanup ]]();
		}
		self setstance( "stand" );
		self.zmbdialogqueue = [];
		self.zmbdialogactive = 0;
		self.zmbdialoggroups = [];
		self.zmbdialoggroup = "";
		self takeallweapons();
		if ( isDefined( level.givecustomcharacters ) )
		{
			self [[ level.givecustomcharacters ]]();
		}
		self giveweapon( "knife_zm" );
		weapons_restored = self scripts/zm/grief/mechanics/loadout/_weapons::grief_laststand_weapons_return();
		if ( !is_true( weapons_restored ) )
		{
			self maps/mp/zombies/_zm_utility::give_start_weapon( 1 );
		}
		weapons_restored = 0;
		if ( isDefined( level._team_loadout ) )
		{
			self giveweapon( level._team_loadout );
			self switchtoweapon( level._team_loadout );
		}
		if ( level.grief_gamerules[ "reduced_pistol_ammo" ] )
		{
			self scripts/zm/grief/mechanics/loadout/_weapons::reduce_starting_ammo();
		}
		if ( isDefined( level.gamemode_post_spawn_logic ) )
		{
			self [[ level.gamemode_post_spawn_logic ]]();
		}
	}
}

hide_gump_loading_for_hotjoiners_override()
{
	return;
}

onallplayersready_override()
{
	while ( getPlayers().size == 0 )
	{
		wait 0.1;
	}
	wait_for_all_players_to_connect( level.crash_delay );
	setinitialplayersconnected(); 
	flag_set( "initial_players_connected" );
	thread maps/mp/zombies/_zm::start_zombie_logic_in_x_sec( 3 );
	maps/mp/zombies/_zm::fade_out_intro_screen_zm( 5, 1.5, 1 );
}

wait_for_all_players_to_connect( max_wait )
{
	timeout = int( max_wait * 10 );
	cur_time = 0;
	player_count_actual = 0;
	while ( getnumconnectedplayers() < getnumexpectedplayers() || player_count_actual != getnumexpectedplayers() )
	{
		players = getPlayers();
		player_count_actual = 0;
		for ( i = 0; i < players.size; i++ )
		{
			players[ i ] freezecontrols( 1 );
			if ( players[ i ].sessionstate == "playing" )
			{
				player_count_actual++;
			}
		}
		wait 0.1;
		cur_time++;
		if ( cur_time >= timeout )
		{
			return;
		}
	}
}

struct_class_init_override()
{
	level.struct_class_names = [];
	level.struct_class_names[ "target" ] = [];
	level.struct_class_names[ "targetname" ] = [];
	level.struct_class_names[ "script_noteworthy" ] = [];
	level.struct_class_names[ "script_linkname" ] = [];
	level.struct_class_names[ "script_unitrigger_type" ] = [];
	foreach ( s_struct in level.struct )
	{
		if ( isDefined( s_struct.targetname ) )
		{
			if ( !isDefined( level.struct_class_names[ "targetname" ][ s_struct.targetname ] ) )
			{
				level.struct_class_names[ "targetname" ][ s_struct.targetname ] = [];
			}
			size = level.struct_class_names[ "targetname" ][ s_struct.targetname ].size;
			level.struct_class_names[ "targetname" ][ s_struct.targetname ][ size ] = s_struct;
		}
		if ( isDefined( s_struct.target ) )
		{
			if ( !isDefined( level.struct_class_names[ "target" ][ s_struct.target ] ) )
			{
				level.struct_class_names[ "target" ][ s_struct.target ] = [];
			}
			size = level.struct_class_names[ "target" ][ s_struct.target ].size;
			level.struct_class_names[ "target" ][ s_struct.target ][ size ] = s_struct;
		}
		if ( isDefined( s_struct.script_noteworthy ) )
		{
			if ( !isDefined( level.struct_class_names[ "script_noteworthy" ][ s_struct.script_noteworthy ] ) )
			{
				level.struct_class_names[ "script_noteworthy" ][ s_struct.script_noteworthy ] = [];
			}
			size = level.struct_class_names[ "script_noteworthy" ][ s_struct.script_noteworthy ].size;
			level.struct_class_names[ "script_noteworthy" ][ s_struct.script_noteworthy ][ size ] = s_struct;
		}
		if ( isDefined( s_struct.script_linkname ) )
		{
			level.struct_class_names[ "script_linkname" ][ s_struct.script_linkname ][ 0 ] = s_struct;
		}
		if ( isDefined( s_struct.script_unitrigger_type ) )
		{
			if ( !isDefined( level.struct_class_names[ "script_unitrigger_type" ][ s_struct.script_unitrigger_type ] ) )
			{
				level.struct_class_names[ "script_unitrigger_type" ][ s_struct.script_unitrigger_type ] = [];
			}
			size = level.struct_class_names[ "script_unitrigger_type" ][ s_struct.script_unitrigger_type ].size;
			level.struct_class_names[ "script_unitrigger_type" ][ s_struct.script_unitrigger_type ][ size ] = s_struct;
		}
	}
	gametype = getDvar( "g_gametype" );
	location = getDvar( "ui_zm_mapstartlocation" );
	if ( array_validate( level.add_struct_gamemode_location_funcs ) )
	{
		if ( array_validate( level.add_struct_gamemode_location_funcs[ gametype ] ) )
		{
			if ( array_validate( level.add_struct_gamemode_location_funcs[ gametype ][ location ] ) )
			{
				for ( i = 0; i < level.add_struct_gamemode_location_funcs[ gametype ][ location ].size; i++ )
				{
					[[ level.add_struct_gamemode_location_funcs[ gametype ][ location ][ i ] ]]();
				}
			}
		}
	}
	override_perk_struct_locations();
}

override_perk_struct_locations()
{
	if ( getDvar( "grief_perk_location_override" ) != "" )
	{
		perks_moved = [];
		perk_keys = strTok( getDvar( "grief_perk_location_override" ), " " );
		for ( i = 0; i < perk_keys.size; i++ )
		{
			if ( perk_keys[ i ] == "location" )
			{
				location = perk_keys[ i + 1 ];
				if ( !isDefined( perks_index ) )
				{
					perks_index = 0;
				}
				else 
				{
					perks_index++;
				}
			}
			if ( location != getDvar( "ui_zm_mapstartlocation" ) )
			{
			}
			else 
			{
				if ( perk_keys[ i ] == "perk" )
				{
					perks_moved[ perks_index ] = spawnStruct();
					perks_moved[ perks_index ].perk = perk_keys[ i + 1 ];
				}
				else if ( perk_keys[ i ] == "origin" )
				{
					perks_moved[ perks_index ].origin = cast_to_vector( perk_keys[ i + 1 ] );
				}
				else if ( perk_keys[ i ] == "angles" )
				{
					perks_moved[ perks_index ].angles = cast_to_vector( perk_keys[ i + 1 ] );
				}
			}
		}
		perks_location = "zgrief_perks_" + location;
		for ( i = 0; i < level.struct_class_names[ "targetname" ][ "zm_perk_machine" ].size; i++ )
		{
			for ( j = 0; j < perks_moved.size; j++ )
			{
				script_string_locations = strTok( level.struct_class_names[ "targetname" ][ "zm_perk_machine" ][ i ].script_string, " " );
				for ( k = 0; k < script_string_locations.size; k++ )
				{
					if ( level.struct_class_names[ "targetname" ][ "zm_perk_machine" ][ i ].script_noteworthy == perks_moved[ j ].perk && script_string_locations[ k ] == perks_location )
					{
						level.struct_class_names[ "targetname" ][ "zm_perk_machine" ][ i ].origin = perks_moved[ j ].origin;
						level.struct_class_names[ "targetname" ][ "zm_perk_machine" ][ i ].angles = perks_moved[ j ].angles;
						break;
					}
				}
			}
		}
	}
}

cast_to_vector( vector_string )
{
	keys = strTok( vector_string, "," );
	vector_array = [];
	for ( i = 0; i < keys.size; i++ )
	{
		vector_array[ i ] = float( keys[ i ] ); 
	}
	vector = ( vector_array[ 0 ], vector_array[ 1 ], vector_array[ 2 ] );
	return vector;
}

onplayerdisconnect() //checked matches cerberus output
{
	level [[ level.game_mode_custom_onplayerdisconnect ]]( self );
}

check_quickrevive_for_hotjoin() //checked changed to match cerberus output
{
	flag_clear( "solo_game" );
	level.using_solo_revive = false;
	level.revive_machine_is_solo = false;
	maps/mp/zombies/_zm::set_default_laststand_pistol( false );
	if ( isDefined( level.quick_revive_machine ) )
	{
		maps/mp/zombies/_zm::update_quick_revive( false );
	}
}

// init_gamemodecommonvox( prefix )
// {
// 	createvox( "rules", "rules", prefix );
// 	createvox( "countdown", "intro", prefix );
// 	createvox( "side_switch", "side_switch", prefix );
// 	createvox( "round_win", "win_rd", prefix );
// 	createvox( "round_lose", "lose_rd", prefix );
// 	createvox( "round_tied", "tied_rd", prefix );
// 	createvox( "match_win", "win", prefix );
// 	createvox( "match_lose", "lose", prefix );
// 	createvox( "match_tied", "tied", prefix );
// }

// init_griefvox( prefix )
// {
// 	init_gamemodecommonvox( prefix );
// 	createvox( "1_player_down", "1rivdown", prefix );
// 	createvox( "2_player_down", "2rivdown", prefix );
// 	createvox( "3_player_down", "3rivdown", prefix );
// 	createvox( "4_player_down", "4rivdown", prefix );
// 	createvox( "grief_restarted", "restart", prefix );
// 	createvox( "grief_lost", "lose", prefix );
// 	createvox( "grief_won", "win", prefix );
// 	createvox( "1_player_left", "1rivup", prefix );
// 	createvox( "2_player_left", "2rivup", prefix );
// 	createvox( "3_player_left", "3rivup", prefix );
// 	createvox( "last_player", "solo", prefix );
// }


/*
round ending killcam
final killcam

"mpl_final_kill_cam_sting"
*/
