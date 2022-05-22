#include maps\mp\gametypes_zm\zmeat;
#include maps\mp\zombies\_zm_game_module;
#include maps\mp\gametypes_zm\_zm_gametype;
#include maps\mp\zombies\_zm_magicbox;
#include maps\mp\zombies\_zm_utility;
#include common_scripts\utility;
#include maps\mp\_utility;
#include scripts\zm\_gametype_setup;

struct_init()
{
	
}

precache()
{
	precachemodel( "zm_collision_transit_town_survival" );
	chest1 = getstruct( "town_chest", "script_noteworthy" );
	chest2 = getstruct( "town_chest_2", "script_noteworthy" );
	setdvar( "disable_rope", 1 );
	setdvar( "disableLookAtEntityLogic", 1 );
	level.chests = [];
	level.chests[ level.chests.size ] = chest1;
	level.chests[ level.chests.size ] = chest2;
}

town_main()
{
	maps\mp\gametypes_zm\_zm_gametype::setup_standard_objects( "town" );
	maps\mp\zombies\_zm_magicbox::treasure_chest_init( "town_chest" );
	collision = spawn( "script_model", ( 1363, 471, 0 ), 1 );
	collision setmodel( "zm_collision_transit_town_survival" );
	scripts\zm\zm_transit\locs\location_common::common_init();
}