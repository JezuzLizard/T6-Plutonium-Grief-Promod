#include maps/mp/gametypes_zm/zmeat;
#include maps/mp/zombies/_zm_game_module;
#include maps/mp/zombies/_zm_zonemgr;
#include maps/mp/gametypes_zm/_zm_gametype;
#include maps/mp/zombies/_zm_magicbox;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include scripts/zm/promod/utility/_grief_util;

struct_init()
{
	if ( !level.grief_ffa )
	{
		level.spawnpoint_system_using_script_ints = true;
	}
	level.struct_class_names[ "targetname" ][ "player_respawn_point" ] = [];
	level.struct_class_names[ "script_noteworthy" ][ "initial_spawn" ] = [];
	coordinates_1 = array( ( 7990, -5608, 19 ), ( 7910, -5608, 11 ), ( 7830, -5608, 8 ), ( 7750, -5608, 3 ) );
	angles_1 = array( ( 0, -90, 0 ), ( 0, -90, 0 ), ( 0, -90, 0 ), ( 0, -90, 0 ) );
	for ( i = 0; i < coordinates_1.size; i++ )
	{
		scripts/zm/_gametype_setup::register_map_initial_spawnpoint( coordinates_1[ i ], angles_1[ i ], 1 );
	}
	coordinates_2 = array( ( 7990, -5808, 12 ), ( 7910, -5808, 9 ), ( 7830, -5808, 3 ), ( 7750, -5808, -1 ) );
	angles_2 = array( ( 0, 90, 0 ), ( 0, 90, 0 ), ( 0, 90, 0 ), ( 0, 90, 0 ) );
	for ( i = 0; i < coordinates_2.size; i++ )
	{
		scripts/zm/_gametype_setup::register_map_initial_spawnpoint( coordinates_2[ i ], angles_2[ i ], 2 );
	}
}

precache()
{
	chest1 = getstruct( "farm_chest", "script_noteworthy" );
	level.chests = [];
	level.chests[ level.chests.size ] = chest1;
	// add_farm_ambiance();
}

farm_main()
{
	maps/mp/gametypes_zm/_zm_gametype::setup_standard_objects( "farm" );
	init_standard_farm();
	maps/mp/zombies/_zm_magicbox::treasure_chest_init( "farm_chest" );
	flag_wait( "initial_blackscreen_passed" );
	level thread maps/mp/zombies/_zm_zonemgr::enable_zone( "zone_far_ext" );
	level thread maps/mp/zombies/_zm_zonemgr::enable_zone( "zone_brn" );
	scripts/zm/zm_transit/locs/location_common::common_init();
}

init_standard_farm()
{
	ents = getentarray();
	foreach ( ent in ents )
	{
		if ( isDefined( ent.script_flag ) && ent.script_flag == "OnFarm_enter" )
		{
			ent delete();
			break;
		}
	}
}