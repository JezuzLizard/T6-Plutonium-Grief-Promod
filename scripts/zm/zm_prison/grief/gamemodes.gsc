#include maps\mp\zm_alcatraz_classic;
#include maps\mp\zm_alcatraz_grief_cellblock;
#include maps\mp\zm_prison;
#include maps\mp\gametypes_zm\_zm_gametype;
#include maps\mp\zombies\_zm_game_module;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\_utility;
#include common_scripts\utility;

#include scripts\zm\zm_prison\locs\loc_cellblock;
#include scripts\zm\zm_prison\locs\loc_citadel;
#include scripts\zm\zm_prison\locs\loc_docks;

init_override()
{
	level.custom_vending_precaching = maps\mp\zm_prison::custom_vending_precaching;
	add_map_gamemode( "zclassic", maps\mp\zm_prison::zclassic_preinit, undefined, undefined );
	add_map_gamemode( "zgrief", scripts\zm\zm_prison\locs\location_common::zgrief_preinit, undefined, undefined );
	add_map_location_gamemode( "zclassic", "prison", maps\mp\zm_alcatraz_classic::precache, maps\mp\zm_alcatraz_classic::main );
	fake_location = getDvar( "scr_zm_location" );
	switch ( fake_location )
	{
		case "docks":
			add_map_location_gamemode( "zgrief", "cellblock", scripts\zm\zm_prison\locs\loc_docks::precache, scripts\zm\zm_prison\locs\loc_docks::main );
			scripts\zm\_gametype_setup::add_struct_location_gamemode_func( "zgrief", "cellblock", scripts\zm\zm_prison\locs\loc_docks::struct_init );
			break;
		case "citadel":
			add_map_location_gamemode( "zgrief", "cellblock", scripts\zm\zm_prison\locs\loc_citadel::precache, scripts\zm\zm_prison\locs\loc_citadel::main );
			scripts\zm\_gametype_setup::add_struct_location_gamemode_func( "zgrief", "cellblock", scripts\zm\zm_prison\locs\loc_citadel::struct_init );
			break;
		case "cellblock":
			add_map_location_gamemode( "zgrief", "cellblock", scripts\zm\zm_prison\locs\loc_cellblock::precache, scripts\zm\zm_prison\locs\loc_cellblock::main );
			scripts\zm\_gametype_setup::add_struct_location_gamemode_func( "zgrief", "cellblock", scripts\zm\zm_prison\locs\loc_cellblock::struct_init );
			break;
		default:
			break;
	}
}
