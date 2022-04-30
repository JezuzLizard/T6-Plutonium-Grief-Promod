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
	scripts/zm/_gametype_setup::register_perk_struct( "specialty_armorvest", "zombie_vending_jugg", ( 0, 180, 0 ), ( -6706, 5016, -56 ) );
	scripts/zm/_gametype_setup::register_perk_struct( "specialty_quickrevive", "zombie_vending_revive", ( 0, 180, 0 ), ( -6122, 4110, -52 ) );
	scripts/zm/_gametype_setup::register_perk_struct( "specialty_rof", "zombie_vending_doubletap2", ( 0, 180, 0 ), ( -6241, 5337, -56 ) );
	scripts/zm/_gametype_setup::register_perk_struct( "specialty_fastreload", "zombie_vending_sleight", ( 0, 120, 0 ), ( -7489, 4217, -64 ) );
	scripts/zm/_gametype_setup::register_perk_struct( "specialty_weapupgrade", "p6_anim_zm_buildable_pap", ( 0, 230, 0 ), ( -6834, 4553, -65 ) );
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
	scripts/zm/zm_transit/locs/location_common::common_init();
	depot_remove_lava_collision();

	nodes = getnodearray( "classic_only_traversal", "targetname" );
	if( getDvarIntDefault( "depot_remove_debris_over_lava", 0 ) )
	{
		foreach ( node in nodes )
			unlink_nodes( node, getnode( node.target, "targetname" ) );
	}else{
		foreach (node in nodes)
			link_nodes( node, getnode( node.target, "targetname" ) );
	}

}

depot_remove_lava_collision( )
{
	if( !getDvarIntDefault( "depot_remove_debris_over_lava", 0 ) )
	{
		return;
	}

	ents = getEntArray( "script_model", "classname");
	foreach (ent in ents)
	{
		if (IsDefined(ent.model))
		{
			if (ent.model == "zm_collision_transit_busdepot_survival")
			{
				ent delete();
			}
			else if (ent.model == "veh_t6_civ_smallwagon_dead" && ent.origin[0] == -6663.96 && ent.origin[1] == 4816.34)
			{
				ent delete();
			}
			else if (ent.model == "veh_t6_civ_microbus_dead" && ent.origin[0] == -6807.05 && ent.origin[1] == 4765.23)
			{
				ent delete();
			}
			else if (ent.model == "veh_t6_civ_movingtrk_cab_dead" && ent.origin[0] == -6652.9 && ent.origin[1] == 4767.7)
			{
				ent delete();
			}
			else if (ent.model == "p6_zm_rocks_small_cluster_01")
			{
				ent delete();
			}
		}
	}

	// spawn in new map edge collisions
	// the lava collision and the map edge collisions are all the same entity
	collision1 = spawn( "script_model", ( -5898, 4653, 0 ) );
	collision1.angles = (0, 55, 0);
	collision1 setmodel( "collision_wall_512x512x10_standard" );
	collision2 = spawn( "script_model", ( -8062, 4700, 0 ) );
	collision2.angles = (0, 70, 0);
	collision2 setmodel( "collision_wall_512x512x10_standard" );
	collision3 = spawn( "script_model", ( -7881, 5200, 0 ) );
	collision3.angles = (0, 70, 0);
	collision3 setmodel( "collision_wall_512x512x10_standard" );
}
