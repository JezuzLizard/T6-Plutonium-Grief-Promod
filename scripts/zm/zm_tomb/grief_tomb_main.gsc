
#include scripts\zm\zm_tomb\grief\gamemodes;
#include scripts\zm\_gametype_setup;

main()
{
	replaceFunc( maps\mp\zm_tomb_gamemodes::init, scripts\zm\zm_tomb\grief\gamemodes::init_override );
	replacefunc(maps/mp/zm_tomb_dig::dig_spots_init, ::dig_spots_init);
	replacefunc(maps/mp/zm_tomb_dig::generate_shovel_unitrigger, ::generate_shovel_unitrigger);

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

generate_shovel_unitrigger( e_shovel ) //checked changed to match cerberus output
{
	return;
}

dig_spots_init()
{
	return;
}