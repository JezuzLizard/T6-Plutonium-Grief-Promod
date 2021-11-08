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
	maps/mp/zombies/_zm_magicbox::treasure_chest_init( "farm_chest" );
	flag_wait( "initial_blackscreen_passed" );
	level thread maps/mp/zombies/_zm_zonemgr::enable_zone( "zone_far_ext" );
	level thread maps/mp/zombies/_zm_zonemgr::enable_zone( "zone_brn" );
	scripts/zm/zm_transit/location_common::common_init();
}

init_standard_farm()
{
	maps/mp/zombies/_zm_game_module::set_current_game_module( level.game_module_standard_index );
	ents = getentarray();
	foreach ( ent in ents )
	{
		if ( isDefined( ent.script_flag ) && ent.script_flag == "OnFarm_enter" )
		{
			ent delete();
		}
		else
		{
			if ( isDefined( ent.script_parameters ) )
			{
				tokens = strtok( ent.script_parameters, " " );
				remove = 0;
				for ( i = 0; i < tokens.size; i++ )
				{
					if ( tokens[ i ] == "standard_remove" )
					{
						remove = 1;
					}
				}
				if ( remove )
				{
					ent delete();
				}
			}
		}
	}
}

// add_farm_ambiance()
// {
// 	for ( i = 0; i < 5; i++ )
// 	{
// 		add_random_sound( "ambiance", "crow_0" + i, 10 );
// 	}
// }