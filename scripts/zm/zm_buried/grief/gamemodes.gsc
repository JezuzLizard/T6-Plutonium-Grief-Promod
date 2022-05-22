#include maps\mp\zombies\_zm_unitrigger;
#include maps\mp\zombies\_zm_weapons;
#include maps\mp\zombies\_zm_zonemgr;
#include maps\mp\zm_buried_grief_street;
#include maps\mp\zm_buried_turned_street;
#include maps\mp\zm_buried_classic;
#include maps\mp\zm_buried;
#include maps\mp\zombies\_zm_buildables;
#include maps\mp\gametypes_zm\_zm_gametype;
#include maps\mp\zombies\_zm_game_module;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\_utility;
#include common_scripts\utility;

#include scripts\zm\zm_buried\locs\loc_street;

init_override()
{
	add_map_gamemode( "zclassic", maps\mp\zm_buried::zclassic_preinit, undefined, undefined );
	add_map_gamemode( "zcleansed", maps\mp\zm_buried::zcleansed_preinit, undefined, undefined );
	add_map_gamemode( "zgrief", maps\mp\zm_buried::zgrief_preinit, undefined, undefined );
	add_map_location_gamemode( "zclassic", "processing", maps\mp\zm_buried_classic::precache, maps\mp\zm_buried_classic::main );
	add_map_location_gamemode( "zcleansed", "street", maps\mp\zm_buried_turned_street::precache, maps\mp\zm_buried_turned_street::main );
	add_map_location_gamemode( "zgrief", "street", scripts\zm\zm_buried\locs\loc_street::precache, scripts\zm\zm_buried\locs\loc_street::main );

	scripts\zm\_gametype_setup::add_struct_location_gamemode_func( "zgrief", "street", scripts\zm\zm_buried\locs\loc_street::struct_init );
}