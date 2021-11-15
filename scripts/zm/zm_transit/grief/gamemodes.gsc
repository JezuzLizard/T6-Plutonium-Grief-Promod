#include maps/mp/zm_transit;
#include maps/mp/gametypes_zm/_zm_gametype;
#include maps/mp/zm_transit_utility;
#include maps/mp/zombies/_zm_game_module;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/zm_transit_grief_town;
#include maps/mp/zm_transit_grief_farm;
#include maps/mp/zm_transit_grief_station;
#include maps/mp/zm_transit_standard_town;
#include maps/mp/zm_transit_standard_farm;
#include maps/mp/zm_transit_standard_station;
#include maps/mp/zm_transit_classic;

#include scripts/zm/zm_transit/locs/loc_cornfield;
#include scripts/zm/zm_transit/locs/loc_diner;
#include scripts/zm/zm_transit/locs/loc_farm;
#include scripts/zm/zm_transit/locs/loc_power;
#include scripts/zm/zm_transit/locs/loc_town;
#include scripts/zm/zm_transit/locs/loc_transit;
#include scripts/zm/zm_transit/locs/loc_tunnel;

init_override()
{
	add_map_gamemode( "zclassic", maps/mp/zm_transit::zclassic_preinit, undefined, undefined );
	add_map_gamemode( "zgrief", maps/mp/zm_transit::zgrief_preinit, undefined, undefined );
	add_map_gamemode( "zstandard", maps/mp/zm_transit::zstandard_preinit, undefined, undefined );
	add_map_location_gamemode( "zclassic", "transit", maps/mp/zm_transit_classic::precache, maps/mp/zm_transit_classic::main );
	add_map_location_gamemode( "zstandard", "transit", maps/mp/zm_transit_standard_station::precache, maps/mp/zm_transit_standard_station::main );
	add_map_location_gamemode( "zstandard", "farm", maps/mp/zm_transit_standard_farm::precache, maps/mp/zm_transit_standard_farm::main );
	add_map_location_gamemode( "zstandard", "town", maps/mp/zm_transit_standard_town::precache, maps/mp/zm_transit_standard_town::main );
	add_map_location_gamemode( "zgrief", "diner", scripts/zm/zm_transit/locs/loc_diner::precache, scripts/zm/zm_transit/locs/loc_diner::diner_main );
	add_map_location_gamemode( "zgrief", "tunnel", scripts/zm/zm_transit/locs/loc_tunnel::precache, scripts/zm/zm_transit/locs/loc_tunnel::tunnel_main );
	add_map_location_gamemode( "zgrief", "power", scripts/zm/zm_transit/locs/loc_power::precache, scripts/zm/zm_transit/locs/loc_power::power_main );
	add_map_location_gamemode( "zgrief", "cornfield", scripts/zm/zm_transit/locs/loc_cornfield::precache, scripts/zm/zm_transit/locs/loc_cornfield::cornfield_main );
	add_map_location_gamemode( "zgrief", "transit", scripts/zm/zm_transit/locs/loc_transit::precache, scripts/zm/zm_transit/locs/loc_transit::transit_main );
	add_map_location_gamemode( "zgrief", "farm", scripts/zm/zm_transit/locs/loc_farm::precache, scripts/zm/zm_transit/locs/loc_farm::farm_main );
	add_map_location_gamemode( "zgrief", "town", scripts/zm/zm_transit/locs/loc_town::precache, scripts/zm/zm_transit/locs/loc_town::town_main );

	scripts/zm/grief/gametype_modules/_gametype_setup::add_struct_location_gamemode_func( "zgrief", "diner", scripts/zm/zm_transit/locs/loc_diner::struct_init );
	scripts/zm/grief/gametype_modules/_gametype_setup::add_struct_location_gamemode_func( "zgrief", "tunnel", scripts/zm/zm_transit/locs/loc_tunnel::struct_init );
	scripts/zm/grief/gametype_modules/_gametype_setup::add_struct_location_gamemode_func( "zgrief", "power", scripts/zm/zm_transit/locs/loc_power::struct_init );
	scripts/zm/grief/gametype_modules/_gametype_setup::add_struct_location_gamemode_func( "zgrief", "cornfield", scripts/zm/zm_transit/locs/loc_cornfield::struct_init );
	scripts/zm/grief/gametype_modules/_gametype_setup::add_struct_location_gamemode_func( "zgrief", "transit", scripts/zm/zm_transit/locs/loc_transit::struct_init );
	scripts/zm/grief/gametype_modules/_gametype_setup::add_struct_location_gamemode_func( "zgrief", "farm", scripts/zm/zm_transit/locs/loc_farm::struct_init );
	scripts/zm/grief/gametype_modules/_gametype_setup::add_struct_location_gamemode_func( "zgrief", "town", scripts/zm/zm_transit/locs/loc_town::struct_init );
}
