#include scripts/zm/promod/_utility;
#include scripts/zm/zm_transit/grief/gamemodes;
#include scripts/zm/zm_transit/locs/location_common;
#include scripts/zm/grief/gametype_modules/_gametype_setup;

main()
{
	replaceFunc( maps/mp/zm_transit_gamemodes::init, scripts/zm/zm_transit/grief/gamemodes::init_override );
	location = getDvar( "ui_zm_mapstartlocation" );
	ents = getEntArray();
	door_ents = getEntArray( "zombie_door", "targetname" );
	switch ( location )
	{
		case "power":
			foreach ( door in door_ents )
			{
				if ( door.script_noteworthy == "electric_door" )
				{
					door.script_noteworthy = "electric_buyable_door";
					door.marked_for_deletion = 0;
				}
			}
			break;
		case "diner":
			diner_hatch = getent( "diner_hatch", "targetname" );
			diner_hatch.script_gameobjectname = "zclassic zstandard zgrief";
			diner_hatch_mantle = getent( "diner_hatch_mantle", "targetname" );
			diner_hatch_mantle.script_gameobjectname = "zclassic zstandard zgrief";
			gameObjects = getEntArray( "script_model", "classname" );
			foreach ( object in gameObjects )
			{
				if ( isDefined( object.script_gameobjectname ) && object.script_gameobjectname == "zcleansed zturned" )
				{
					object.script_gameobjectname = "zstandard zgrief zcleansed zturned";
				}
			} 
			break;
		default:
			break;
	}
}