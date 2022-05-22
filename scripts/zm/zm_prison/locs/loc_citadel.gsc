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
	scripts\zm\_gametype_setup::register_perk_struct( "specialty_deadshot", "zombie_vending_ads_on", ( 0, 86, 0  ), ( 255.641, 10029.9, 1128.13 ) );
	scripts\zm\_gametype_setup::register_perk_struct( "specialty_fastreload", "zombie_vending_sleight", ( 0, 221.122, 0 ), ( 202.425, 8134.68, 276.125 ) );
	scripts\zm\_gametype_setup::register_perk_struct( "specialty_armorvest", "zombie_vending_jugg", ( 0, 0, 0  ), ( 730.46, 10096.4, 1128.13 ) );
	scripts\zm\_gametype_setup::register_perk_struct( "specialty_rof", "zombie_vending_doubletap2", ( 0, 0, 0  ), ( 326, 9144, 1128 ) );
	level.struct_class_names[ "targetname" ][ "player_respawn_point" ] = [];
	level.struct_class_names[ "script_noteworthy" ][ "initial_spawn" ] = [];
	coordinates_1 = array( ( 844.359, 9345.09, 1104.13 ), ( 844.359, 9439.99, 1104.13 ), ( 843.434, 9611.9, 1104.13 ), ( 844.249, 9715.15, 1104.13 ) );

	angles_1 = array( ( 0, 180, 0  ), ( 0, 180, 0  ), ( 0, 180, 0  ), ( 0, 180, 0  ) );
	for ( i = 0; i < coordinates_1.size; i++ )
	{
		scripts\zm\_gametype_setup::register_map_initial_spawnpoint( coordinates_1[ i ], angles_1[ i ], 1 );
	}
	coordinates_2 = array( ( 637.641, 9350.77, 1104.13 ), ( 623.862, 9446.74, 1104.13 ), ( 624.35, 9614.36, 1104.13 ), ( 625.579, 9739.78, 1104.13 ) );
	angles_2 = array( ( 0, 0, 0 ), ( 0, 0, 0 ), ( 0, 0, 0 ), ( 0, 0, 0 ) );
	for ( i = 0; i < coordinates_2.size; i++ )
	{
		scripts\zm\_gametype_setup::register_map_initial_spawnpoint( coordinates_2[ i ], angles_2[ i ], 2 );
	}
}

precache()
{
	setdvar( "disableLookAtEntityLogic", 1 );
	level.chests = [];
	level.chests[ 0 ] = getstruct( "citadel_chest", "script_noteworthy" );
}

enable_zones()
{
	// zone_init( "zone_citadel" );
	// enable_zone( "zone_citadel" );
	// zone_init( "zone_citadel_stairs" );
	// enable_zone( "zone_citadel_stairs" );
	// zone_init( "zone_citadel_warden" );
	// enable_zone( "zone_citadel_warden" );
	flag_set( "activate_citadel_stair" );
}

main()
{
	m_lock = getent( "masterkey_lock_1", "targetname" );
	m_lock delete();
	door = getent( "tomahawk_room_door", "targetname" );
	door trigger_off();
	door connectpaths();
	shower_key_door = getent( "shower_key_door", "targetname" );
	shower_key_door moveto( shower_key_door.origin + vectorScale( ( 1, 0, 0 ), 80 ), 0.25 );
	shower_key_door connectpaths();
	shower_key_door playsound( "zmb_chainlink_open" );
	maps\mp\gametypes_zm\_zm_gametype::setup_standard_objects( "cellblock" );
	maps\mp\zombies\_zm_magicbox::treasure_chest_init( "citadel_chest" );
	precacheshader( "zm_al_wth_zombie" );
	array_thread( level.zombie_spawners, ::add_spawn_function, ::remove_zombie_hats_for_grief );
	maps\mp\zombies\_zm_ai_brutus::precache();
	maps\mp\zombies\_zm_ai_brutus::init();
	level._effect["butterflies"] = loadfx( "maps\zombie_alcatraz\fx_alcatraz_skull_elec" );
	scripts\zm\_gametype_setup::wallbuy( "mp5k_zm", "mp5", "weapon_upgrade", ( 1557, 10166, 1199 ), ( 0, -90, 0 ) );
	enable_zones();
	scripts\zm\zm_prison\locs\location_common::common_init();
	delete_door_trigs();
	level notify( "sleight_on" );
	wait_network_frame();
	level notify( "doubletap_on" );
	wait_network_frame();
	level notify( "juggernog_on" );
	wait_network_frame();
	level notify( "deadshot_on" );
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
		if (  door.target == "pf3664_auto2507" || door.target == "pf3762_auto2526" || door.target == "pf3765_auto2463" )    //dt, staircase, to cell
		{
			door delete();
		}
	}
}