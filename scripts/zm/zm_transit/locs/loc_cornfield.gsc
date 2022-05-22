#include maps\mp\zombies\_zm_utility;
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm;
#include scripts\zm\_gametype_setup;
#include maps\mp\zombies\_zm_zonemgr;

struct_init()
{
	scripts\zm\_gametype_setup::register_perk_struct( "specialty_armorvest", "zombie_vending_jugg", ( 0, 179, 0 ), ( 13936, -649, -189 ) );
	scripts\zm\_gametype_setup::register_perk_struct( "specialty_rof", "zombie_vending_doubletap2", ( 0, -137, 0 ), ( 12052, -1943, -160 ) );
	scripts\zm\_gametype_setup::register_perk_struct( "specialty_longersprint", "zombie_vending_marathon", ( 0, -35, 0 ), ( 9944, -725, -211 ) );
	scripts\zm\_gametype_setup::register_perk_struct( "specialty_scavenger", "zombie_vending_tombstone", ( 0, 133, 0 ), ( 13551, -1384, -188 ) );
	scripts\zm\_gametype_setup::register_perk_struct( "specialty_weapupgrade", "p6_anim_zm_buildable_pap_on", ( 0, 123, 0), ( 9960, -1288, -217 ) );
	scripts\zm\_gametype_setup::register_perk_struct( "specialty_quickrevive", "zombie_vending_quickrevive", ( 0, -90, 0 ), ( 7831, -464, -203 ) );
	scripts\zm\_gametype_setup::register_perk_struct( "specialty_fastreload", "zombie_vending_sleight", ( 0, -4, 0 ), ( 13255, 74, -195 ) );
	coordinates = array( ( 7521, -545, -198 ), ( 7751, -522, -202 ), ( 7691, -395, -201 ), ( 7536, -432, -199 ), 
							( 13745, -336, -188 ), ( 13758, -681, -188 ), ( 13816, -1088, -189 ), ( 13752, -1444, -182 ) );
	angles = array( ( 0, 40, 0 ), ( 0, 145, 0 ), ( 0, -131, 0 ), ( 0, -24, 0 ), ( 0, -178, 0 ), ( 0, -179, 0 ), ( 0, -177, 0 ), ( 0, -177, 0 ) );
	for ( i = 0; i < coordinates.size; i++ )
	{
		scripts\zm\_gametype_setup::register_map_initial_spawnpoint( coordinates[ i ], angles[ i ] );
	}
}

precache()
{
	level.delayed_struct_add_funcs = [];
	level.delayed_struct_add_funcs[ 1 ] = ::cornfield_structs;
	level notify( "delayed_struct_definitions" );
	start_chest_zbarrier = getEnt( "start_chest_zbarrier", "script_noteworthy" );
	start_chest_zbarrier.origin = ( 13566, -541, -188 );
	start_chest_zbarrier.angles = ( 0, -90, 0 );
	start_chest = spawnStruct();
	start_chest.origin = ( 13566, -541, -188 );
	start_chest.angles = ( 0, -90, 0 );
	start_chest.script_noteworthy = "start_chest";
	start_chest.zombie_cost = 950;
	collision = spawn( "script_model", start_chest_zbarrier.origin );
	collision.angles = start_chest_zbarrier.angles;
	collision setmodel( "collision_clip_32x32x128" );
	collision = spawn( "script_model", start_chest_zbarrier.origin - ( 0, 32, 0 ) );
	collision.angles = start_chest_zbarrier.angles;
	collision setmodel( "collision_clip_32x32x128" );
	collision = spawn( "script_model", start_chest_zbarrier.origin + ( 0, 32, 0 ) );
	collision.angles = start_chest_zbarrier.angles;
	collision setmodel( "collision_clip_32x32x128" );
	start_chest2_zbarrier = getEnt( "depot_chest_zbarrier", "script_noteworthy" );
	start_chest2_zbarrier.origin = ( 7458, -464, -196 );
	start_chest2_zbarrier.angles = ( 0, -90, 0 );
	start_chest2 = spawnStruct();
	start_chest2.origin = ( 7458, -464, -196 );
	start_chest2.angles = ( 0, -90, 0 );
	start_chest2.script_noteworthy = "depot_chest";
	start_chest2.zombie_cost = 950;
	collision = spawn( "script_model", start_chest2_zbarrier.origin );
	collision.angles = start_chest2_zbarrier.angles;
	collision setmodel( "collision_clip_32x32x128" );
	collision = spawn( "script_model", start_chest2_zbarrier.origin - ( 0, 32, 0 ) );
	collision.angles = start_chest2_zbarrier.angles;
	collision setmodel( "collision_clip_32x32x128" );
	collision = spawn( "script_model", start_chest2_zbarrier.origin + ( 0, 32, 0 ) );
	collision.angles = start_chest2_zbarrier.angles;
	collision setmodel( "collision_clip_32x32x128" );
	start_chest3_zbarrier = getEnt( "farm_chest_zbarrier", "script_noteworthy" );
	start_chest3_zbarrier.origin = ( 10158, 49, -220 );
	start_chest3_zbarrier.angles = ( 0, -185, 0 );
	start_chest3 = spawnStruct();
	start_chest3.origin = ( 10158, 49, -220 );
	start_chest3.angles = ( 0, -185, 0 );
	start_chest3.script_noteworthy = "farm_chest";
	start_chest3.zombie_cost = 950;
	collision = spawn( "script_model", start_chest3_zbarrier.origin );
	collision.angles = start_chest3_zbarrier.angles;
	collision setmodel( "collision_clip_32x32x128" );
	collision = spawn( "script_model", start_chest3_zbarrier.origin - ( 32, 0, 0 ) );
	collision.angles = start_chest3_zbarrier.angles;
	collision setmodel( "collision_clip_32x32x128" );
	collision = spawn( "script_model", start_chest3_zbarrier.origin + ( 32, 0, 0 ) );
	collision.angles = start_chest3_zbarrier.angles;
	collision setmodel( "collision_clip_32x32x128" );
	level.chests = [];
	level.chests[ 0 ] = start_chest;
	level.chests[ 1 ] = start_chest2;
	level.chests[ 2 ] = start_chest3;
}

cornfield_main()
{
	init_wallbuys();
	init_barriers();
	maps\mp\zombies\_zm_magicbox::treasure_chest_init( random( array( "start_chest", "farm_chest", "depot_chest" ) ) );
	scripts\zm\zm_transit\locs\location_common::common_init();
	level thread increase_cornfield_zombie_speed();
}

zombie_speed_up_distance_check()
{
	if ( distance( self.origin, self.closestPlayer.origin ) > 1000 )
	{
		return 1;
	}
	return 0;
}

increase_cornfield_zombie_speed()
{
	level endon( "end_game" );
	level.zombie_vars[ "zombie_spawn_delay" ] = 0.08;
	level.speed_change_round = undefined;
	while ( 1 )
	{
		zombies = get_round_enemy_array();
		for ( i = 0; i < zombies.size; i++ )
		{
			zombies[ i ].closestPlayer = get_closest_valid_player( zombies[ i ].origin );
		}
		zombies = get_round_enemy_array();
		for ( i = 0; i < zombies.size; i++ )
		{
			if ( zombies[ i ] zombie_speed_up_distance_check() )
			{
				zombies[ i ] set_zombie_run_cycle( "chase_bus" );
			}
			else if ( zombies[ i ].zombie_move_speed != "sprint" )
			{
				zombies[ i ] set_zombie_run_cycle( "sprint" );
			}
		}
		wait 1;
	}
}

init_wallbuys()
{
	scripts\zm\_gametype_setup::wallbuy( "m14_zm", "m14", "weapon_upgrade", ( -11166, -2844, 247 ), ( 0, -86, 0 ) );
	scripts\zm\_gametype_setup::wallbuy( "rottweil72_zm", "olympia", "weapon_upgrade", ( 13663, -1166, -134 ), ( 0, -90, 0 ) );
	scripts\zm\_gametype_setup::wallbuy( "m16_zm", "870mcs", "weapon_upgrade", ( 14092, -351, -133 ), ( 0, 90, 0 ) );
	scripts\zm\_gametype_setup::wallbuy( "mp5k_zm", "mp5", "weapon_upgrade", ( 13542, -764, -133 ), ( 0, 90, 0 ) );
	scripts\zm\_gametype_setup::wallbuy( "tazer_knuckles_zm", "tazer_knuckles", "tazer_upgrade", ( 13502, -12, -125 ), ( 0, 90, 0 ) );
}

init_barriers()
{
	scripts\zm\_gametype_setup::barrier( ( 10190, 135, -159 ), "veh_t6_civ_movingtrk_cab_dead", ( 0, 172, 0 ) );
	scripts\zm\_gametype_setup::barrier( ( 10100, 100, -159 ), "collision_player_wall_512x512x10", ( 0, 172, 0 ) );
	scripts\zm\_gametype_setup::barrier( ( 10100, -1800, -217 ), "veh_t6_civ_bus_zombie", ( 0, 126, 0 ), 1 );
	scripts\zm\_gametype_setup::barrier( ( 10045, -1607, -181 ), "collision_player_wall_512x512x10", ( 0, 126, 0 ) );
}

cornfield_structs()
{

}