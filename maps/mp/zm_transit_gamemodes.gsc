#include maps\mp\zm_transit;
#include maps\mp\gametypes_zm\_zm_gametype;
#include maps\mp\zm_transit_utility;
#include maps\mp\zombies\_zm_game_module;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zm_transit_grief_town;
#include maps\mp\zm_transit_grief_farm;
#include maps\mp\zm_transit_grief_station;
#include maps\mp\zm_transit_standard_town;
#include maps\mp\zm_transit_standard_farm;
#include maps\mp\zm_transit_standard_station;
#include maps\mp\zm_transit_classic;

init()
{
	add_map_gamemode( "zclassic", maps\mp\zm_transit::zclassic_preinit, undefined, undefined );
	add_map_gamemode( "zgrief", maps\mp\zm_transit::zgrief_preinit, undefined, undefined );
	add_map_gamemode( "zstandard", maps\mp\zm_transit::zstandard_preinit, undefined, undefined );
	add_map_location_gamemode( "zclassic", "transit", maps\mp\zm_transit_classic::precache, maps\mp\zm_transit_classic::main );
	add_map_location_gamemode( "zstandard", "transit", maps\mp\zm_transit_standard_station::precache, maps\mp\zm_transit_standard_station::main );
	add_map_location_gamemode( "zstandard", "farm", maps\mp\zm_transit_standard_farm::precache, maps\mp\zm_transit_standard_farm::main );
	add_map_location_gamemode( "zstandard", "town", maps\mp\zm_transit_standard_town::precache, maps\mp\zm_transit_standard_town::main );
	//Initialize cut locations gamemode functions //These functions are all placeholders for now
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////\
	add_map_location_gamemode( "zstandard", "diner", maps\mp\zm_transit_standard_town::precache, maps\mp\zm_transit_standard_town::main );
	add_map_location_gamemode( "zstandard", "tunnel", maps\mp\zm_transit_standard_town::precache, maps\mp\zm_transit_standard_town::main );
	add_map_location_gamemode( "zstandard", "power", maps\mp\zm_transit_standard_town::precache, maps\mp\zm_transit_standard_town::main );
	add_map_location_gamemode( "zstandard", "cornfield", maps\mp\zm_transit_standard_town::precache, maps\mp\zm_transit_standard_town::main );
	add_map_location_gamemode( "zgrief", "diner", maps\mp\zm_transit_standard_town::precache, maps\mp\zm_transit_standard_town::main );
	add_map_location_gamemode( "zgrief", "tunnel", maps\mp\zm_transit_standard_town::precache, maps\mp\zm_transit_standard_town::main );
	add_map_location_gamemode( "zgrief", "power", maps\mp\zm_transit_standard_town::precache, maps\mp\zm_transit_standard_town::main );
	add_map_location_gamemode( "zgrief", "cornfield", maps\mp\zm_transit_standard_town::precache, maps\mp\zm_transit_standard_town::main );
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	add_map_location_gamemode( "zgrief", "transit", maps\mp\zm_transit_grief_station::precache, maps\mp\zm_transit_grief_station::main );
	add_map_location_gamemode( "zgrief", "farm", maps\mp\zm_transit_grief_farm::precache, maps\mp\zm_transit_grief_farm::main );
	add_map_location_gamemode( "zgrief", "town", maps\mp\zm_transit_grief_town::precache, maps\mp\zm_transit_grief_town::main );
}
