#include maps/mp/gametypes_zm/zmeat;
#include maps/mp/zombies/_zm_game_module;
#include maps/mp/zombies/_zm_zonemgr;
#include maps/mp/gametypes_zm/_zm_gametype;
#include maps/mp/zombies/_zm_magicbox;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include scripts/zm/promod/utility/_grief_util;

struct_init()
{
	
}

precache()
{
	chest1 = getstruct( "farm_chest", "script_noteworthy" );
	level.chests = [];
	level.chests[ level.chests.size ] = chest1;
	// add_farm_ambiance();
}

farm_main()
{
	maps/mp/gametypes_zm/_zm_gametype::setup_standard_objects( "farm" );
	init_standard_farm();
	maps/mp/zombies/_zm_magicbox::treasure_chest_init( "farm_chest" );
	flag_wait( "initial_blackscreen_passed" );
	level thread maps/mp/zombies/_zm_zonemgr::enable_zone( "zone_far_ext" );
	level thread maps/mp/zombies/_zm_zonemgr::enable_zone( "zone_brn" );
	scripts/zm/zm_transit/locs/location_common::common_init();
}

init_standard_farm()
{
	ents = getentarray();
	foreach ( ent in ents )
	{
		if ( isDefined( ent.script_flag ) && ent.script_flag == "OnFarm_enter" )
		{
			ent delete();
			break;
		}
	}
}