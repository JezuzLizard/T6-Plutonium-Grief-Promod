#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

struct_init()
{
	scripts/zm/_gametype_setup::register_perk_struct( "specialty_armorvest", "zombie_vending_jugg", ( 0, 270, 0 ), ( 2644, 4496, -311 ) );
	scripts/zm/_gametype_setup::register_perk_struct( "specialty_longersprint", "zombie_vending_marathon", ( 0, 178, 0 ), ( -250.068, 4296.36, -191.754 ) );
	scripts/zm/_gametype_setup::register_perk_struct( "specialty_weapupgrade", "p6_anim_zm_buildable_pap_on", ( 0, 0, 0 ), ( -6223.94, -6694.36, 152.125 ) );

	if ( !level.grief_ffa )
	{
		level.spawnpoint_system_using_script_ints = true;
	}
	level.struct_class_names[ "targetname" ][ "player_respawn_point" ] = [];
	level.struct_class_names[ "script_noteworthy" ][ "initial_spawn" ] = [];
	coordinates_1 = array( ( 2096.84, 4961.77, -299.875 ), ( 2050.48, 4656.4, -299.875 ), ( 2340.41, 4614.65, -301.92 ), ( 2328.26, 4904.16, -299.875 ) );
	angles_1 = array( ( 0, 300, 0 ), ( 0, 47, 0  ), ( 0, 134, 0  ), ( 0, 210, 0  ) );
	for ( i = 0; i < coordinates_1.size; i++ )
	{
		scripts\zm\_gametype_setup::register_map_initial_spawnpoint( coordinates_1[ i ], angles_1[ i ], 1 );
	}
	coordinates_2 = array( ( 2554.91, 5155.65, -375.875 ), ( 2895.25, 5159.11, -375.875 ), ( 2878.78, 5451.09, -367.875 ), ( 2572.78, 5430.02, -367.875 ) );
	angles_2 = array( ( 0, 50, 0 ), ( 0, 137, 0 ), ( 0, 220, 0 ), ( 0, 310, 0 ) );
	for ( i = 0; i < coordinates_2.size; i++ )
	{
		scripts\zm\_gametype_setup::register_map_initial_spawnpoint( coordinates_2[ i ], angles_2[ i ], 2 );
	}
}

enable_zones()
{
	
}

precache()
{
	maps\mp\zm_tomb_classic::precache();
}

main()
{
	// scripts/zm/_gametype_setup::wallbuy( "mp5k_zm", "mp5", "weapon_upgrade", (1455.64, 2026.42, 3105), ( 0, 270, 0 ) );
	maps\mp\zm_tomb_classic::main();
	thread disable_doors_trenches()
	thread deactivateTank();
}

disable_doors_trenches()
{
	flag_wait( "initial_blackscreen_passed" );
	zm_doors = getentarray( "zombie_door", "targetname" );
	for(i=0;i<zm_doors.size;i++)
	{
		if(zm_doors[i].origin == (-732, 2240, -64))
			zm_doors[i].origin = (0,0,-10000);
	}
}

deactivateTank()
{
	trig = getentarray( "trig_tank_station_call", "targetname" );
	foreach(t in trig)
	{
		t disable_trigger();
	}
}