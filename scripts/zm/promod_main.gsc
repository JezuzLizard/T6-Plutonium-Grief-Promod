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

#include scripts/zm/promod/zgriefp;
#include scripts/zm/promod/zgriefp_overrides;
#include scripts/zm/promod/_gametype_setup;
#include scripts/zm/promod/utility/_grief_util;
#include scripts/zm/promod/plugin/commands;
#include scripts/zm/promod/_gamerules;
#include scripts/zm/promod/_gametype_setup;
#include scripts/zm/promod/_hud;
#include scripts/zm/promod/_player_spawning;
#include scripts/zm/promod/_teams;
#include scripts/zm/promod/utility/_com;

//Function that sets up all the overrides automatically.
main()
{
	level.SERVER_FRAME = 0.05;
	replaceFunc( common_scripts/utility::struct_class_init, ::struct_class_init_o );
	replaceFunc( maps/mp/zombies/_zm_magicbox::treasure_chest_init, scripts/zm/promod/zgriefp_overrides::treasure_chest_init_o );
	replaceFunc( maps/mp/zombies/_zm_utility::track_players_intersection_tracker, scripts/zm/promod/zgriefp_overrides::track_players_intersection_tracker_o );
	replaceFunc( maps/mp/zombies/_zm_utility::init_zombie_run_cycle, scripts/zm/promod/zgriefp_overrides::init_zombie_run_cycle_o );
	replaceFunc( maps/mp/zombies/_zm_utility::change_zombie_run_cycle, scripts/zm/promod/zgriefp_overrides::change_zombie_run_cycle_o );
	replaceFunc( maps/mp/gametypes_zm/_zm_gametype::rungametypeprecache, scripts/zm/promod/zgriefp_overrides::rungametypeprecache_o );
	replaceFunc( maps/mp/gametypes_zm/_zm_gametype::rungametypemain, scripts/zm/promod/zgriefp_overrides::rungametypemain_o );
	replaceFunc( maps/mp/gametypes_zm/_zm_gametype::game_objects_allowed, scripts/zm/promod/zgriefp_overrides::game_objects_allowed_o );
	replaceFunc( maps/mp/gametypes_zm/_zm_gametype::setup_standard_objects, scripts/zm/promod/zgriefp_overrides::setup_standard_objects_o );
	replaceFunc( maps/mp/gametypes_zm/_zm_gametype::setup_classic_gametype, scripts/zm/promod/zgriefp_overrides::setup_classic_gametype_o );
	replaceFunc( maps/mp/gametypes_zm/_zm_gametype::init, scripts/zm/promod/zgriefp_overrides::game_module_init_o );
	replaceFunc( maps/mp/zombies/_zm_audio_announcer::playleaderdialogonplayer, scripts/zm/promod/zgriefp_overrides::playleaderdialogonplayer_o );
	replaceFunc( maps/mp/zombies/_zm::round_start, scripts/zm/promod/zgriefp_overrides::game_start );
	replaceFunc( maps/mp/zombies/_zm_spawner::zombie_head_gib, scripts/zm/promod/zgriefp_overrides::zombie_head_gib_o );
	replaceFunc( maps/mp/zombies/_zm::onallplayersready, scripts/zm/promod/zgriefp_overrides::onallplayersready_o );
	replaceFunc( maps/mp/gametypes_zm/_zm_gametype::menu_onmenuresponse, scripts/zm/promod/_teams::menu_onmenuresponse_o );
	replaceFunc( maps/mp/zombies/_zm_powerups::randomize_powerups, scripts/zm/promod/zgriefp_overrides::randomize_powerups_o );
	replaceFunc( maps/mp/zombies/_zm_powerups::get_next_powerup, scripts/zm/promod/zgriefp_overrides::get_next_powerup_o );
	replaceFunc( maps/mp/zombies/_zm_powerups::get_valid_powerup, scripts/zm/promod/zgriefp_overrides::get_valid_powerup_o );
	replaceFunc( maps/mp/gametypes_zm/_zm_gametype::get_player_spawns_for_gametype, scripts/zm/promod/_player_spawning::get_player_spawns_for_gametype_o );
	COM_INIT();
	CMD_INIT();
	damage_feedback_init();
}

struct_class_init_o()
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
	// if ( array_validate( level.struct_add_funcs ) )
	// {
	// 	foreach ( func in level.struct_add_funcs )
	// 	{
	// 		[[ func ]]();
	// 	}
	// }
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
					}
				}
			}
		}
	}
}