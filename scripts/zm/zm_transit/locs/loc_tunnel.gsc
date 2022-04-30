#include maps/mp/zombies/_zm_game_module;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zombies/_zm;

#include scripts/zm/_gametype_setup;

struct_init()
{
	scripts/zm/_gametype_setup::register_perk_struct( "specialty_armorvest", "zombie_vending_jugg", ( 0, -180, 0 ), ( -11541, -2630, 194 ) );
	scripts/zm/_gametype_setup::register_perk_struct( "specialty_rof", "zombie_vending_doubletap2", ( 0, -10, 0 ), ( -11170, -590, 196 ) );
	scripts/zm/_gametype_setup::register_perk_struct( "specialty_longersprint", "zombie_vending_marathon", ( 0, -19, 0 ), ( -11681, -734, 228 ) );
	scripts/zm/_gametype_setup::register_perk_struct( "specialty_scavenger", "zombie_vending_tombstone", ( 0, -98, 0 ), ( -10664, -757, 196 ) );
	scripts/zm/_gametype_setup::register_perk_struct( "specialty_weapupgrade", "p6_anim_zm_buildable_pap_on", ( 0, 115, 0 ), ( -11301, -2096, 184 ) );
	scripts/zm/_gametype_setup::register_perk_struct( "specialty_quickrevive", "zombie_vending_quickrevive", ( 0, 270, 0 ), ( -10780, -2565, 224 ) );
	scripts/zm/_gametype_setup::register_perk_struct( "specialty_fastreload", "zombie_vending_sleight", ( 0, -89, 0 ), ( -11373, -1674, 192 ) );
	coordinates = array( ( -11196, -837, 192 ), ( -11386, -863, 192 ), ( -11405, -1000, 192 ), ( -11498, -1151, 192 ),
							( -11398, -1326, 191 ), ( -11222, -1345, 192 ), ( -10934, -1380, 192 ), ( -10999, -1072, 192 ) );
	angles = array( ( 0, -94, 0 ), ( 0, -44, 0 ), ( 0, -32, 0 ), ( 0, 4, 0 ), ( 0, 50, 0 ), ( 0, 157, 0 ), ( 0, -144, 0 ) );		
	for ( i = 0; i < coordinates.size; i++ )
	{
		scripts/zm/_gametype_setup::register_map_initial_spawnpoint( coordinates[ i ], angles[ i ] );
	}
}

precache()
{
	start_chest_zbarrier = getEnt( "start_chest_zbarrier", "script_noteworthy" );
	start_chest_zbarrier.origin = ( -11090, -349, 193 );
	start_chest_zbarrier.angles = ( 0, -100, 0 );
	start_chest = spawnStruct();
	start_chest.origin = ( -11090, -349, 193 );
	start_chest.angles = ( 0, -100, 0 );
	start_chest.script_noteworthy = "start_chest";
	start_chest.zombie_cost = 950;
	collision = spawn( "script_model", start_chest_zbarrier.origin );
	collision.angles = start_chest_zbarrier.angles;
	collision setmodel( "collision_clip_32x32x128" );
	collision = spawn( "script_model", start_chest_zbarrier.origin - ( 4, 30, 0 ) );
	collision.angles = start_chest_zbarrier.angles;
	collision setmodel( "collision_clip_32x32x128" );
	collision = spawn( "script_model", start_chest_zbarrier.origin + ( 4, 30, 0 ) );
	collision.angles = start_chest_zbarrier.angles;
	collision setmodel( "collision_clip_32x32x128" );
	start_chest2_zbarrier = getEnt( "farm_chest_zbarrier", "script_noteworthy" );
	start_chest2_zbarrier.origin = ( -11772, -2501, 232 );
	start_chest2_zbarrier.angles = ( 0, 0, 0 );
	start_chest2 = spawnStruct();
	start_chest2.origin = ( -11772, -2501, 232 );
	start_chest2.angles = ( 0, 0, 0 );
	start_chest2.script_noteworthy = "farm_chest";
	start_chest2.zombie_cost = 950;
	collision = spawn( "script_model", start_chest2_zbarrier.origin );
	collision.angles = start_chest2_zbarrier.angles;
	collision setmodel( "collision_clip_32x32x128" );
	collision = spawn( "script_model", start_chest2_zbarrier.origin - ( 36, 0, 0 ) );
	collision.angles = start_chest2_zbarrier.angles;
	collision setmodel( "collision_clip_32x32x128" );
	collision = spawn( "script_model", start_chest2_zbarrier.origin + ( 36, 0, 0 ) );
	collision.angles = start_chest2_zbarrier.angles;
	collision setmodel( "collision_clip_32x32x128" );
	level.chests = [];
	level.chests[ 0 ] = start_chest;
	level.chests[ 1 ] = start_chest2;
}

enable_zones()
{
	zone_init( "zone_amb_tunnel" );
	enable_zone( "zone_amb_tunnel" );
}

tunnel_main()
{
	init_wallbuys();
	init_barriers();
	maps/mp/zombies/_zm_magicbox::treasure_chest_init( random( array( "farm_chest", "start_chest" ) ) );
	scripts/zm/zm_transit/locs/location_common::common_init();
	enable_zones();
}

init_wallbuys()
{
	scripts/zm/_gametype_setup::wallbuy( ( 0, -86, 0 ), ( -11166, -2844, 247 ), "m14_zm_fx", "m14_zm", "t6_wpn_ar_m14_world", "m14", "weapon_upgrade" );
	scripts/zm/_gametype_setup::wallbuy( ( 0, 83, 0 ), ( -10790, -1430, 247 ), "rottweil72_zm_fx", "rottweil72_zm", "t6_wpn_shotty_olympia_world", "olympia", "weapon_upgrade" );
	scripts/zm/_gametype_setup::wallbuy( ( 0, 270, 0 ), ( -11839, -1695.1, 287 ), "m16_zm_fx", "m16_zm", "t6_wpn_ar_m16a2_world", "m16", "weapon_upgrade" );
	scripts/zm/_gametype_setup::wallbuy( ( 0, 83, 0 ), ( -10625, -545, 247 ), "mp5k_zm_fx", "mp5k_zm", "t6_wpn_smg_mp5_world", "mp5", "weapon_upgrade" );
	//scripts/zm/_gametype_setup::wallbuy( ( 0, -93, 0 ), ( -11839, -2406, 283 ), "tazer_knuckles_zm_fx", "tazer_knuckles_zm", "t6_wpn_taser_knuckles_world", "tazer_knuckles", "tazer_upgrade" );
}

init_barriers()
{
	scripts/zm/_gametype_setup::barrier( ( -11250, -520, 255 ), "veh_t6_civ_movingtrk_cab_dead", ( 0, 172, 0 ) );
	scripts/zm/_gametype_setup::barrier( ( -11250, -580, 255 ), "collision_player_wall_256x256x10", ( 0, 180, 0 ) );
	scripts/zm/_gametype_setup::barrier( ( -11506, -580, 255 ), "collision_player_wall_256x256x10", ( 0, 180, 0 ) );
	scripts/zm/_gametype_setup::barrier( ( -10770, -3240, 255 ), "veh_t6_civ_movingtrk_cab_dead", ( 0, 214, 0 ) );
	scripts/zm/_gametype_setup::barrier( ( -10840, -3190, 255 ), "collision_player_wall_256x256x10", ( 0, 214, 0 ) );
}