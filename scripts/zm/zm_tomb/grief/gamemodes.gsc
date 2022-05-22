#include maps\mp\zm_tomb_classic;
#include maps\mp\zm_tomb;
#include maps\mp\gametypes_zm\_zm_gametype;
#include maps\mp\zombies\_zm_game_module;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\_utility;
#include common_scripts\utility;

#include scripts\zm\zm_tomb\locs\loc_crazyplace;
#include scripts\zm\zm_tomb\locs\loc_trenches;

init_override()
{
	add_map_gamemode( "zclassic", maps\mp\zm_tomb::zstandard_preinit, undefined, undefined );
	// add_map_location_gamemode( "zclassic", "tomb", maps\mp\zm_tomb_classic::precache, maps\mp\zm_tomb_classic::main );
	fake_location = getDvar( "scr_zm_location" );
	switch ( fake_location )
	{
		case "crazyplace":
			add_map_location_gamemode( "zclassic", "tomb", scripts\zm\zm_tomb\locs\loc_crazyplace::precache, scripts\zm\zm_tomb\locs\loc_crazyplace::main );
			scripts\zm\_gametype_setup::add_struct_location_gamemode_func( "zclassic", "tomb", scripts\zm\zm_tomb\locs\loc_crazyplace::struct_init );
			break;
		case "trenches":
			add_map_location_gamemode( "zclassic", "tomb", scripts\zm\zm_tomb\locs\loc_trenches::precache, scripts\zm\zm_tomb\locs\loc_trenches::main );
			scripts\zm\_gametype_setup::add_struct_location_gamemode_func( "zclassic", "tomb", scripts\zm\zm_tomb\locs\loc_trenches::struct_init );
			break;
	}
}