#include maps\mp\zombies\_zm_utility;
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zm_prison;
#include scripts\zm\zm_prison\locs\location_common;

#include maps\mp\zombies\_zm_zonemgr;

struct_init()
{
	if ( !level.grief_ffa )
	{
		level.spawnpoint_system_using_script_ints = true;
	}
	scripts\zm\_gametype_setup::register_perk_struct( "specialty_armorvest", "zombie_vending_jugg", ( 0, 102, 0 ), ( 473.92, 6638.99, 208 ) );

	level.struct_class_names[ "targetname" ][ "player_respawn_point" ] = [];
	level.struct_class_names[ "script_noteworthy" ][ "initial_spawn" ] = [];

	coordinates_1 = array( ( 34.3866, 7024.23, 64.125 ), ( -43.3697, 7009.54, 64.125 ), ( -133.612, 7000.46, 64.125 ), ( -206.433, 6993.19, 64.125 ) );
	angles_1 = array( ( 0, 98.7451, 0  ), ( 0, 96.6797, 0  ), ( 0, 96.6797, 0  ), ( 0, 96.6797, 0  ) );
	for ( i = 0; i < coordinates_1.size; i++ )
	{
		scripts\zm\_gametype_setup::register_map_initial_spawnpoint( coordinates_1[ i ], angles_1[ i ], 1 );
	}
	coordinates_2 = array( ( 15.6214, 7184.79, 64.125 ), ( -215.015, 7141.21, 64.125 ), ( -128.887, 7157.27, 64.125 ), ( -57.776, 7171.73, 64.125 ) );
	angles_2 = array( ( 0, -82.0789, 0  ), ( 0, -77.6788, 0  ), ( 0, -77.6788, 0  ), ( 0, -82.3315, 0  ) );
	for ( i = 0; i < coordinates_2.size; i++ )
	{
		scripts\zm\_gametype_setup::register_map_initial_spawnpoint( coordinates_2[ i ], angles_2[ i ], 2 );
	}
	new_dog_powerup_drop_location = spawnStruct();
	new_dog_powerup_drop_location.targetname = "wolf_puke_powerup_origin";
	new_dog_powerup_drop_location.origin = ( 41.4695, 6096.17, 18.9326 );
	level.struct_class_names[ "targetname" ][ "wolf_puke_powerup_origin" ] = new_dog_powerup_drop_location;
}

enable_zones()
{
	// zone_init( "zone_dock" );
	// enable_zone( "zone_dock" );
	// zone_init( "zone_dock_puzzle" );
	// enable_zone( "zone_dock_puzzle" );
	// add_adjacent_zone( "zone_dock", "zone_dock_puzzle", "activate_dock_sally" );
	// add_adjacent_zone( "zone_dock", "zone_dock_puzzle", "activate_basement_gondola" );
	// zone_init( "zone_dock_gondola" );
	// enable_zone( "zone_dock_gondola" );
	// flag_set( "gondola_roof_to_dock" );
	zone_init( "zone_citadel_basement" );
	enable_zone( "zone_citadel_basement" );
	zone_init( "zone_citadel_basement_building" );
	enable_zone( "zone_citadel_basement_building" );
	add_adjacent_zone( "zone_citadel_basement", "zone_citadel_basement_building", "always_on" );
}

precache()
{
	setdvar( "disableLookAtEntityLogic", 1 );
	level.chests = [];
	start_chest = spawnstruct();
	start_chest.origin = ( -423.33, 6952, 64.125 );
	start_chest.angles = ( 0, 10, 0 );
	start_chest.script_noteworthy = "start_chest";
	start_chest.zombie_cost = 950;
	chest_box = getent( "start_chest_zbarrier", "script_noteworthy" );
	chest_box.origin = ( -423.33, 6952, 64.125 );
	chest_box.angles = ( 0, 10, 0 );
	collision = spawn( "script_model", chest_box.origin );
	collision.angles = chest_box.angles;
	collision setmodel( "collision_clip_32x32x128" );
	collision = spawn( "script_model", chest_box.origin - ( 32, 0, 0 ) );
	collision.angles = chest_box.angles;
	collision setmodel( "collision_clip_32x32x128" );
	collision = spawn( "script_model", chest_box.origin + ( 32, 0, 0 ) );
	collision.angles = chest_box.angles;
	collision setmodel( "collision_clip_32x32x128" );
	level.chests[ 0 ] = start_chest;
	level.chests[ 1 ] = getstruct( "dock_chest", "script_noteworthy" );
}

main()
{
	enable_zones();
	maps\mp\gametypes_zm\_zm_gametype::setup_standard_objects( "cellblock" );
	maps\mp\zombies\_zm_magicbox::treasure_chest_init( "start_chest" );
	precacheshader( "zm_al_wth_zombie" );
	array_thread( level.zombie_spawners, ::add_spawn_function, ::remove_zombie_hats_for_grief );
	maps\mp\zombies\_zm_ai_brutus::precache();
	maps\mp\zombies\_zm_ai_brutus::init();
	level._effect["butterflies"] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_skull_elec" );
	scripts\zm\zm_prison\locs\location_common::common_init();
	delete_door_trigs();
	wait_network_frame();
	level notify( "juggernog_on" );
}

remove_zombie_hats_for_grief()
{
	self detach( "c_zom_guard_hat" );
}

delete_door_trigs()
{	
	doors = getentarray( "zombie_door", "targetname" );
	foreach ( door in doors )
	{
		if ( door.target == "pf3762_auto2526" ) //staircase
		{
			door delete();
		}
	}
}