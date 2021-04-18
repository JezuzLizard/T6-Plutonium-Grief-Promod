#include maps/mp/gametypes_zm/_zm_gametype;
#include maps/mp/zombies/_zm_buildables;
#include maps/mp/zombies/_zm_magicbox;
#include maps/mp/zombies/_zm_equip_subwoofer;
#include maps/mp/zombies/_zm_equip_springpad;
#include maps/mp/zombies/_zm_equip_turbine;
#include maps/mp/zm_buried_buildables;
#include maps/mp/zm_buried_gamemodes;
#include maps/mp/zombies/_zm_race_utility;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;

precache() //checked matches cerberus output
{
	precachemodel( "zm_collision_buried_street_grief" );
	precachemodel( "p6_zm_bu_buildable_bench_tarp" );
	level.chalk_buildable_pieces_hide = 1;
	griefbuildables = array( "chalk", "turbine", "springpad_zm", "subwoofer_zm" );
	maps/mp/zm_buried_buildables::include_buildables( griefbuildables );
	maps/mp/zm_buried_buildables::init_buildables( griefbuildables );
	maps/mp/zombies/_zm_equip_turbine::init();
	maps/mp/zombies/_zm_equip_turbine::init_animtree();
	maps/mp/zombies/_zm_equip_springpad::init( &"ZM_BURIED_EQ_SP_PHS", &"ZM_BURIED_EQ_SP_HTS" );
	maps/mp/zombies/_zm_equip_subwoofer::init( &"ZM_BURIED_EQ_SW_PHS", &"ZM_BURIED_EQ_SW_HTS" );
}

street_treasure_chest_init() //checked matches cerberus output
{
	start_chest = getstruct( "start_chest", "script_noteworthy" );
	court_chest = getstruct( "courtroom_chest1", "script_noteworthy" );
	tunnel_chest = getstruct( "tunnels_chest1", "script_noteworthy" );
	jail_chest = getstruct( "jail_chest1", "script_noteworthy" );
	gun_chest = getstruct( "gunshop_chest", "script_noteworthy" );
	setdvar( "disableLookAtEntityLogic", 1 );
	level.chests = [];
	level.chests[ level.chests.size ] = start_chest;
	level.chests[ level.chests.size ] = court_chest;
	level.chests[ level.chests.size ] = tunnel_chest;
	level.chests[ level.chests.size ] = jail_chest;
	level.chests[ level.chests.size ] = gun_chest;
	maps/mp/zombies/_zm_magicbox::treasure_chest_init( "start_chest" );
}

main() //checked matches cerberus output
{
	//disable_buried_tunnel_zone();
	spawn_barriers();
	level.buildables_built[ "pap" ] = 1;
	level.equipment_team_pick_up = 1;
	level thread maps/mp/zombies/_zm_buildables::think_buildables();
	maps/mp/gametypes_zm/_zm_gametype::setup_standard_objects( "street" );
	street_treasure_chest_init();
	generatebuildabletarps();
	deletebuildabletarp( "courthouse" );
	deletebuildabletarp( "bar" );
	deletebuildabletarp( "generalstore" );
	delete_door_and_debris_trigs();
	deleteSlothBarricade( "juggernaut_alley" );
	deleteSlothBarricade( "jail" );
	deleteSlothBarricade( "candystore_alley" );
	//deleteSlothBarricade( "gun_store_door1" );
	deleteSlothBarricade( "darkwest_nook_door1" );
	//deleteslothbarricades();
	powerswitchstate( 1 );
	level.enemy_location_override_func = ::enemy_location_override;
	spawnmapcollision( "zm_collision_buried_street_grief" );
	flag_wait( "initial_blackscreen_passed" );
	flag_wait( "start_zombie_round_logic" );
	wait 1;
	builddynamicwallbuys();
	buildbuildables();
	turnperkon( "revive" );
	turnperkon( "doubletap" );
	turnperkon( "marathon" );
	turnperkon( "juggernog" );
	turnperkon( "sleight" );
	turnperkon( "additionalprimaryweapon" );
	turnperkon( "Pack_A_Punch" );
}

enemy_location_override( zombie, enemy ) //checked matches cerberus output
{
	location = enemy.origin;
	if ( isDefined( self.reroute ) && self.reroute )
	{
		if ( isDefined( self.reroute_origin ) )
		{
			location = self.reroute_origin;
		}
	}
	return location;
}

builddynamicwallbuys() //checked matches cerberus output
{
	builddynamicwallbuy( "bank", "beretta93r_zm" );
	builddynamicwallbuy( "bar", "pdw57_zm" );
	builddynamicwallbuy( "church", "ak74u_zm" );
	builddynamicwallbuy( "courthouse", "mp5k_zm" );
	builddynamicwallbuy( "generalstore", "m16_zm" );
	builddynamicwallbuy( "mansion", "an94_zm" );
	builddynamicwallbuy( "morgue", "svu_zm" );
	builddynamicwallbuy( "prison", "claymore_zm" );
	builddynamicwallbuy( "stables", "bowie_knife_zm" );
	builddynamicwallbuy( "stablesroof", "frag_grenade_zm" );
	builddynamicwallbuy( "toystore", "tazer_knuckles_zm" );
	builddynamicwallbuy( "candyshop", "870mcs_zm" );
}

buildbuildables() //checked matches cerberus output
{
	buildbuildable( "springpad_zm" );
	buildbuildable( "subwoofer_zm" );
	buildbuildable( "turbine" );
}

spawn_barriers()
{
	//barn barrier
	barrier_model = spawn( "script_model", ( -728, -557, 117 ), 1 );
	barrier_model.angles = ( 19, 180, 0 );
	barrier_model setmodel( "p6_zm_bu_sloth_blocker_medium" );
	barrier_model disconnectpaths();
	collision = spawn( "script_model", ( -728, -529, 117 ), 1 );
	collision.angles = ( 19, 4, 0 );
	collision setModel( "collision_player_64x64x128" );
	//tunnel blockade
	collision = spawn( "script_model", (-1495, -280, 40) );
    collision.angles = ( 0, 90, 0 );
    collision setmodel( "collision_clip_wall_128x128x10" );
    couch = spawn( "script_model", (-1512, -262, 26.5) );
    couch.angles = ( 0, 90, 0 );
    couch setmodel( "p6_zm_bu_victorian_couch" );
	//mule kick barrier
	/*
	barrier_model = spawn( "script_model", ( -578, 1006, 167 ), 1 );
	barrier_model.angles = ( 9, 270, 0 );
	barrier_model setmodel( "p6_zm_bu_sloth_blocker_medium" );
	barrier_model disconnectpaths();
	*/
}

delete_door_and_debris_trigs()
{
	door_trigs_to_delete = array( "pf728_auto2520", "pf728_auto2513", "pf728_auto2496", "pf728_auto2497" );
	doors_trigs = getentarray( "zombie_door", "targetname" );
	foreach ( door_trig in doors_trigs )
	{
		for ( i = 0; i < door_trigs_to_delete.size; i++ )
		{
			if ( door_trig.target == door_trigs_to_delete[ i ] )
			{
				door_trig delete();
			}
		}
	}
	debris_trigs_to_delete = array( "pf728_auto2529", "pf728_auto2528", "pf728_auto2531", "pf728_auto2530", "pf728_auto2532", "pf728_auto2534" );
	debris_trigs = getentarray( "zombie_debris", "targetname" );
	foreach ( debris_trig in debris_trigs )
	{
		for ( i = 0; i < debris_trigs_to_delete.size; i++ )
		{
			if ( debris_trig.target == debris_trigs_to_delete[ i ] )
			{
				debris_trig delete();
			}
		}
	}
}

disable_buried_tunnel_zone()
{
	foreach ( zone in getArrayKeys( level.zones ) )
	{
		if ( zone == "zone_tunnel_gun2stables2" )
		{
			level.zones[ zone ].is_enabled = 0;
			level.zones[ zone ].is_spawning_allowed = 0;
			break;
		}
	}
}

remove_buried_spawns()
{
	foreach ( zone in level.zones )
	{
		for ( i = 0; i < zone.spawn_locations.size; i++ )
		{
			if ( zone.spawn_locations[ i ].origin == ( -1551, -611, 36.69 ) )
			{
				zone.spawn_locations[ i ].is_enabled = false;
			}
		}
	}
}