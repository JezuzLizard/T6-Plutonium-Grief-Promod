#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;
#include maps\mp\zombies\_zm_perks;

#include scripts\zm\zm_tomb\grief\gamemodes;
#include scripts\zm\_gametype_setup;

main()
{
	replaceFunc( maps\mp\zm_tomb_gamemodes::init, scripts\zm\zm_tomb\grief\gamemodes::init_override );
	replacefunc( maps\mp\zm_tomb_dig::dig_spots_init, ::dig_spots_init );
	replacefunc( maps\mp\zm_tomb_dig::generate_shovel_unitrigger, ::generate_shovel_unitrigger );
	replacefunc( maps\mp\zm_tomb_vo::first_magic_box_seen_vo, ::first_magic_box_seen_vo );
	
	thread turn_on_power();

	fake_location = getDvar( "scr_zm_location" );
	switch ( fake_location )
	{
		case "crazyplace":
			level.custom_location_zones = [];
			level.custom_location_zones[ 0 ] = "zone_chamber_0";
			level.custom_location_zones[ 1 ] = "zone_chamber_1";
			level.custom_location_zones[ 2 ] = "zone_chamber_2";
			level.custom_location_zones[ 3 ] = "zone_chamber_3";
			level.custom_location_zones[ 4 ] = "zone_chamber_4";
			level.custom_location_zones[ 5 ] = "zone_chamber_5";
			level.custom_location_zones[ 6 ] = "zone_chamber_6";
			level.custom_location_zones[ 7 ] = "zone_chamber_7";
			level.custom_location_zones[ 8 ] = "zone_chamber_8";
			break;
		case "trenches":
			// not needed
			break;
	}
}

turn_on_power()
{
	flag_wait("capture_zones_init_done" );
	foreach(zone in level.zone_capture.zones)
	{
		zone.n_current_progress = 100;
		zone maps/mp/zm_tomb_capture_zones::handle_generator_capture();
		level setclientfield( zone.script_noteworthy, 100 / 100 );
		level setclientfield( "state_" + zone.script_noteworthy, 2 );
	}
	wait 1;
	flag_set("zone_capture_in_progress");

	level.custom_perk_validation = undefined;
}

generate_shovel_unitrigger( e_shovel ) //checked changed to match cerberus output
{
	return;
}

dig_spots_init()
{
	return;
}

first_magic_box_seen_vo()
{
	return;
}