#include maps/mp/zm_alcatraz_classic;
#include maps/mp/zm_alcatraz_grief_cellblock;
#include maps/mp/zm_prison;
#include maps/mp/gametypes_zm/_zm_gametype;
#include maps/mp/zombies/_zm_game_module;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

init_o()
{
	level.custom_vending_precaching = maps/mp/zm_prison::custom_vending_precaching;
	add_map_gamemode( "zclassic", maps/mp/zm_prison::zclassic_preinit, undefined, undefined );
	add_map_gamemode( "zgrief", scripts/zm/zm_prison/location_common::zgrief_preinit, undefined, undefined );
	add_map_location_gamemode( "zclassic", "prison", maps/mp/zm_alcatraz_classic::precache, maps/mp/zm_alcatraz_classic::main );
	add_map_location_gamemode( "zgrief", "cellblock", scripts/zm/zm_prison/loc_cellblock::precache, scripts/zm/zm_prison/loc_cellblock::main );
	//add_map_location_gamemode( "zgrief", "docks", maps/mp/zm_alcatraz_grief_cellblock::precache, maps/mp/zm_alcatraz_grief_cellblock::main );

	add_struct_location_gamemode_func( "zgrief", "cellblock", scripts/zm/zm_prison/loc_cellblock::struct_init );
}
