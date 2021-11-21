//checked includes match cerberus output
#include maps/mp/gametypes_zm/zmeat;
#include maps/mp/zombies/_zm_game_module;
#include maps/mp/zombies/_zm_perks;
#include maps/mp/gametypes_zm/_zm_gametype;
#include maps/mp/zombies/_zm_magicbox;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include scripts/zm/promod/_gametype_setup;

struct_init()
{
	scripts/zm/grief/gametype_modules/_gametype_setup::register_perk_struct( "specialty_armorvest", "zombie_vending_jugg", ( 0, 180, 0 ), ( -6706, 5016, -56 ) );
	scripts/zm/grief/gametype_modules/_gametype_setup::register_perk_struct( "specialty_quickrevive", "zombie_vending_revive", ( 0, 180, 0 ), ( -6122, 4110, -52 ) );
	scripts/zm/grief/gametype_modules/_gametype_setup::register_perk_struct( "specialty_rof", "zombie_vending_doubletap2", ( 0, 180, 0 ), ( -6241, 5337, -56 ) );
	scripts/zm/grief/gametype_modules/_gametype_setup::register_perk_struct( "specialty_fastreload", "zombie_vending_sleight", ( 0, 120, 0 ), ( -7489, 4217, -64 ) );
	scripts/zm/grief/gametype_modules/_gametype_setup::register_perk_struct( "specialty_weapupgrade", "p6_anim_zm_buildable_pap", ( 0, 230, 0 ), ( -6834, 4553, -65 ) );
}

precache() //checked matches cerberus output
{
	precachemodel( "zm_collision_transit_busdepot_survival" );
	chest1 = getstruct( "depot_chest", "script_noteworthy" );
	level.chests = [];
	level.chests[ level.chests.size ] = chest1;
}

transit_main() //checked changed to match cerberus output
{
	maps/mp/gametypes_zm/_zm_gametype::setup_standard_objects( "station" );
	maps/mp/zombies/_zm_magicbox::treasure_chest_init( "depot_chest" );
	collision = spawn( "script_model", ( -6896, 4744, 0 ), 1 );
	collision setmodel( "zm_collision_transit_busdepot_survival" );
	collision disconnectpaths();
	scripts/zm/zm_transit/locs/location_common::common_init();
	nodes = getnodearray( "classic_only_traversal", "targetname" );
	foreach ( node in nodes )
	{
		unlink_nodes( node, getnode( node.target, "targetname" ) );
	}
}
