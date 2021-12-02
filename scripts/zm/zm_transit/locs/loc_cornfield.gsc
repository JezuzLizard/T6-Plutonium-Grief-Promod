#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zombies/_zm;
#include scripts/zm/promod/_gametype_setup;

struct_init()
{
	scripts/zm/grief/gametype_modules/_gametype_setup::register_perk_struct( "specialty_armorvest", "zombie_vending_jugg", ( 0, 179, 0 ), ( 13936, -649, -189 ) );
	scripts/zm/grief/gametype_modules/_gametype_setup::register_perk_struct( "specialty_rof", "zombie_vending_doubletap2", ( 0, -137, 0 ), ( 12052, -1943, -160 ) );
	scripts/zm/grief/gametype_modules/_gametype_setup::register_perk_struct( "specialty_longersprint", "zombie_vending_marathon", ( 0, -35, 0 ), ( 9944, -725, -211 ) );
	scripts/zm/grief/gametype_modules/_gametype_setup::register_perk_struct( "specialty_scavenger", "zombie_vending_tombstone", ( 0, 133, 0 ), ( 13551, -1384, -188 ) );
	scripts/zm/grief/gametype_modules/_gametype_setup::register_perk_struct( "specialty_weapupgrade", "p6_anim_zm_buildable_pap_on", ( 0, 123, 0), ( 9960, -1288, -217 ) );
	scripts/zm/grief/gametype_modules/_gametype_setup::register_perk_struct( "specialty_quickrevive", "zombie_vending_quickrevive", ( 0, -90, 0 ), ( 7831, -464, -203 ) );
	scripts/zm/grief/gametype_modules/_gametype_setup::register_perk_struct( "specialty_fastreload", "zombie_vending_sleight", ( 0, -4, 0 ), ( 13255, 74, -195 ) );
	coordinates = array( ( 7521, -545, -198 ), ( 7751, -522, -202 ), ( 7691, -395, -201 ), ( 7536, -432, -199 ), 
							( 13745, -336, -188 ), ( 13758, -681, -188 ), ( 13816, -1088, -189 ), ( 13752, -1444, -182 ) );
	angles = array( ( 0, 40, 0 ), ( 0, 145, 0 ), ( 0, -131, 0 ), ( 0, -24, 0 ), ( 0, -178, 0 ), ( 0, -179, 0 ), ( 0, -177, 0 ), ( 0, -177, 0 ) );
	for ( i = 0; i < coordinates.size; i++ )
	{
		scripts/zm/grief/gametype_modules/_gametype_setup::register_map_initial_spawnpoint( coordinates[ i ], angles[ i ] );
	}

	initial_zone[ 0 ] = "zone_pri";
	initial_zone[ 1 ] = "zone_station_ext";
	initial_zone[ 2 ] = "zone_tow";
	initial_zone[ 3 ] = "zone_far_ext";
	initial_zone[ 4 ] = "zone_brn";
	//Initialize cut location zones
	////////////////////////////////////
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
	collision disconnectpaths();
	collision = spawn( "script_model", start_chest_zbarrier.origin - ( 0, 32, 0 ) );
	collision.angles = start_chest_zbarrier.angles;
	collision setmodel( "collision_clip_32x32x128" );
	collision disconnectpaths();
	collision = spawn( "script_model", start_chest_zbarrier.origin + ( 0, 32, 0 ) );
	collision.angles = start_chest_zbarrier.angles;
	collision setmodel( "collision_clip_32x32x128" );
	collision disconnectpaths();
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
	collision disconnectpaths();
	collision = spawn( "script_model", start_chest2_zbarrier.origin - ( 0, 32, 0 ) );
	collision.angles = start_chest2_zbarrier.angles;
	collision setmodel( "collision_clip_32x32x128" );
	collision disconnectpaths();
	collision = spawn( "script_model", start_chest2_zbarrier.origin + ( 0, 32, 0 ) );
	collision.angles = start_chest2_zbarrier.angles;
	collision setmodel( "collision_clip_32x32x128" );
	collision disconnectpaths();
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
	collision disconnectpaths();
	collision = spawn( "script_model", start_chest3_zbarrier.origin - ( 32, 0, 0 ) );
	collision.angles = start_chest3_zbarrier.angles;
	collision setmodel( "collision_clip_32x32x128" );
	collision disconnectpaths();
	collision = spawn( "script_model", start_chest3_zbarrier.origin + ( 32, 0, 0 ) );
	collision.angles = start_chest3_zbarrier.angles;
	collision setmodel( "collision_clip_32x32x128" );
	collision disconnectpaths();
	level.chests = [];
	level.chests[ 0 ] = start_chest;
	level.chests[ 1 ] = start_chest2;
	level.chests[ 2 ] = start_chest3;
}

cornfield_main()
{
	init_wallbuys();
	init_barriers();
	maps/mp/zombies/_zm_magicbox::treasure_chest_init( random( array( "start_chest", "farm_chest", "depot_chest" ) ) );
	scripts/zm/zm_transit/locs/location_common::common_init();
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
	level endon( "end_game2" );
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
	//wallbuy( ( 0, -180, 0 ), ( 13603, -1282, -134 ), "claymore_zm_fx", "claymore_zm", "t6_wpn_claymore_world", "claymore", "claymore_purchase" );
	scripts/zm/grief/gametype_modules/_gametype_setup::wallbuy( ( 0, -90, 0 ), ( 13663, -1166, -134 ), "rottweil72_zm_fx", "rottweil72_zm", "t6_wpn_shotty_olympia_world", "olympia", "weapon_upgrade" );
	//wallbuy( ( 0, 90, 0 ), ( 14092, -351, -133 ), "m16_zm_fx", "m16_zm", "t6_wpn_ar_m16a2_world", "m16", "weapon_upgrade" );
	scripts/zm/grief/gametype_modules/_gametype_setup::wallbuy( ( 0, 90, 0 ), ( 13542, -764, -133 ), "mp5k_zm_fx", "mp5k_zm", "t6_wpn_smg_mp5_world", "mp5", "weapon_upgrade" );
	//wallbuy( ( 0, 90, 0 ), ( 13502, -12, -125 ), "tazer_knuckles_zm_fx", "tazer_knuckles_zm", "t6_wpn_taser_knuckles_world", "tazer_knuckles", "tazer_upgrade" );
}

init_barriers()
{
	scripts/zm/grief/gametype_modules/_gametype_setup::barrier( ( 10190, 135, -159 ), "veh_t6_civ_movingtrk_cab_dead", ( 0, 172, 0 ) );
	scripts/zm/grief/gametype_modules/_gametype_setup::barrier( ( 10100, 100, -159 ), "collision_player_wall_512x512x10", ( 0, 172, 0 ) );
	scripts/zm/grief/gametype_modules/_gametype_setup::barrier( ( 10100, -1800, -217 ), "veh_t6_civ_bus_zombie", ( 0, 126, 0 ), 1 );
	scripts/zm/grief/gametype_modules/_gametype_setup::barrier( ( 10045, -1607, -181 ), "collision_player_wall_512x512x10", ( 0, 126, 0 ) );
}

cornfield_structs()
{

}