#include maps\mp\zombies\_zm_game_module;
#include maps\mp\zombies\_zm_utility;
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm;
#include scripts\zm\_gametype_setup;

struct_init()
{
	if ( !level.grief_ffa )
	{
		level.spawnpoint_system_using_script_ints = true;
	}
	scripts\zm\_gametype_setup::register_perk_struct( "specialty_armorvest", "zombie_vending_jugg", ( 0, 176, 0 ), ( -3634, -7464, -58 ) );
	scripts\zm\_gametype_setup::register_perk_struct( "specialty_rof", "zombie_vending_doubletap2", ( 0, -90, 0 ), ( -4170, -7610, -61 ) );
	scripts\zm\_gametype_setup::register_perk_struct( "specialty_longersprint", "zombie_vending_marathon", ( 0, 4, 0 ), ( -4576, -6704, -61 ) );
	scripts\zm\_gametype_setup::register_perk_struct( "specialty_scavenger", "zombie_vending_tombstone", ( 0, 90, 0 ), ( -6496, -7691, 0 ) );
	scripts\zm\_gametype_setup::register_perk_struct( "specialty_weapupgrade", "p6_anim_zm_buildable_pap_on", ( 0, 175, 0 ), ( -6351, -7778, 227 ) );
	scripts\zm\_gametype_setup::register_perk_struct( "specialty_quickrevive", "zombie_vending_quickrevive", ( 0, 137, 0 ), ( -5424, -7920, -64 ) );
	scripts\zm\_gametype_setup::register_perk_struct( "specialty_fastreload", "zombie_vending_sleight", ( 0, 270, 0 ), ( -5470, -7859.5, 0 ) );

	coordinates_1 = array( ( -4160, -7428, -63 ), ( -4240, -7428, -60 ), ( -4320, -7428, -54 ), ( -4400, -7428, -58 ) );
	angles_1 = array( ( 0, 90, 0 ), ( 0, 90, 0 ), ( 0, 90, 0 ), ( 0, 90, 0 ) );
	for ( i = 0; i < coordinates_1.size; i++ )
	{
		scripts\zm\_gametype_setup::register_map_initial_spawnpoint( coordinates_1[ i ], angles_1[ i ], 1 );
	}
	coordinates_2 = array( ( -4160, -7228, -64 ), ( -4240, -7228, -60 ), ( -4320, -7228, -54 ), ( -4400, -7228, -58 ) );
	angles_2 = array( ( 0, -90, 0 ), ( 0, -90, 0 ), ( 0, -90, 0 ), ( 0, -90, 0 ) );
	for ( i = 0; i < coordinates_2.size; i++ )
	{
		scripts\zm\_gametype_setup::register_map_initial_spawnpoint( coordinates_2[ i ], angles_2[ i ], 2 );
	}
}

precache()
{
	normalChests = getstructarray( "treasure_chest_use", "targetname" );
	start_chest_zbarrier = getEnt( "depot_chest_zbarrier", "script_noteworthy" );
	start_chest_zbarrier.origin = ( -5708, -7968, 232 );
	start_chest_zbarrier.angles = ( 0, 1, 0 );
	start_chest = spawnStruct();
	start_chest.origin = ( -5708, -7968, 232 );
	start_chest.angles = ( 0, 1, 0 );
	start_chest.script_noteworthy = "depot_chest";
	start_chest.zombie_cost = 950;
	collision = spawn( "script_model", start_chest_zbarrier.origin );
	collision.angles = start_chest_zbarrier.angles;
	collision setmodel( "collision_clip_32x32x128" );
	collision = spawn( "script_model", start_chest_zbarrier.origin - ( 32, 0, 0 ) );
	collision.angles = start_chest_zbarrier.angles;
	collision setmodel( "collision_clip_32x32x128" );
	collision = spawn( "script_model", start_chest_zbarrier.origin + ( 32, 0, 0 ) );
	collision.angles = start_chest_zbarrier.angles;
	collision setmodel( "collision_clip_32x32x128" );
	level.chests = [];
	level.chests[ 0 ] = normalChests[ 3 ];
	level.chests[ 1 ] = start_chest;

	generatebuildabletarps();
}

diner_main()
{
	diner_hatch_access();
	init_wallbuys();
	init_barriers();
	maps\mp\zombies\_zm_magicbox::treasure_chest_init( random( array( "start_chest", "depot_chest" ) ) );
	scripts\zm\zm_transit\locs\location_common::common_init();
}

diner_hatch_access() //modified function
{
	diner_hatch = getent( "diner_hatch", "targetname" );
	diner_hatch_col = getent( "diner_hatch_collision", "targetname" );
	diner_hatch_mantle = getent( "diner_hatch_mantle", "targetname" );
	if ( !isDefined( diner_hatch ) || !isDefined( diner_hatch_col ) )
	{
		return;
	}
	diner_hatch hide();
	diner_hatch_mantle.start_origin = diner_hatch_mantle.origin;
	diner_hatch_mantle.origin += vectorScale( ( 0, 0, 0 ), 500 );
	diner_hatch show();
	diner_hatch_col delete();
	diner_hatch_mantle.origin = diner_hatch_mantle.start_origin;
}

init_wallbuys()
{
	scripts\zm\_gametype_setup::wallbuy( "m14_zm", "m14", "weapon_upgrade", ( -5085, -7807, -5 ), ( 0, 0, 0 ) );
	scripts\zm\_gametype_setup::wallbuy( "rottweil72_zm", "olympia", "weapon_upgrade", ( -4576, -7748, 18 ), ( 0, 90, 0 ) );
	scripts\zm\_gametype_setup::wallbuy( "mp5k_zm", "mp5", "weapon_upgrade", ( -5489, -7982.7, 62 ), ( 0, 1, 0 ) );
	scripts\zm\_gametype_setup::wallbuy( "m16_zm", "m16", "weapon_upgrade", ( -3578, -7181, 0 ), ( 0, 180, 0 ) );
	scripts\zm\_gametype_setup::wallbuy( "tazer_knuckles_zm", "tazer_knuckles", "tazer_upgrade", ( -6265, -7941, 100 ), ( 0, 90, 0 ) );
}

init_barriers() //custom function
{
	// scripts\zm\_gametype_setup::barrier( ( -3952, -6957, -67 ), "collision_player_wall_256x256x10", ( 0, 82, 0 ) );
	// scripts\zm\_gametype_setup::barrier( ( -4173, -6679, -60 ), "collision_player_wall_512x512x10", ( 0, 0, 0 ) );
	// scripts\zm\_gametype_setup::barrier( ( -5073, -6732, -59 ), "collision_player_wall_512x512x10", ( 0, 328, 0 ) );
	// scripts\zm\_gametype_setup::barrier( ( -6104, -6490, -38 ), "collision_player_wall_512x512x10", ( 0, 2, 0 ) );
	// scripts\zm\_gametype_setup::barrier( ( -5850, -6486, -38 ), "collision_player_wall_256x256x10", ( 0, 0, 0 ) );
	// scripts\zm\_gametype_setup::barrier( ( -5624, -6406, -40 ), "collision_player_wall_256x256x10", ( 0, 226, 0 ) );
	// scripts\zm\_gametype_setup::barrier( ( -6348, -6886, -55 ), "collision_player_wall_512x512x10", ( 0, 98, 0 ) );
	collision = spawn( "script_model", ( -5000, -6700, 0 ), 1 );
	collision setmodel( "zm_collision_transit_diner_survival" );
}

generatebuildabletarps()
{
	tarp = spawn( "script_model", ( -4688, -7974, -64 ) );
	tarp.angles = ( 0, 0, 0 );
	tarp setModel( "p6_zm_buildable_bench_tarp" );
}
