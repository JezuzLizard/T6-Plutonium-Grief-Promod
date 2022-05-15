struct_init()
{
	scripts/zm/_gametype_setup::register_perk_struct( "specialty_quickrevive", "zombie_vending_quickrevive", (-10, 180, 0 ), (1435, 1225, 3390) );
	scripts/zm/_gametype_setup::register_perk_struct( "specialty_armorvest", "zombie_vending_jugg", ( 0, 270, 0 ), (1444.47, 2713.98, 3048.52) );
	scripts/zm/_gametype_setup::register_perk_struct( "specialty_fastreload", "zombie_vending_sleight", ( 0, 135, 0 ), (1916.92, 1139.1, 3216.13) );
	scripts/zm/_gametype_setup::register_perk_struct( "specialty_rof", "zombie_vending_doubletap2", ( 0, 270, 0 ), (2286.36, 2122.6, 3040.13) );
	scripts/zm/_gametype_setup::register_perk_struct( "specialty_weapupgrade", "p6_anim_zm_buildable_pap_on", (0, 90, 0), (1195.34, 1281.47, 3392.13) );

	if ( !level.grief_ffa )
	{
		level.spawnpoint_system_using_script_ints = true;
	}
	level.struct_class_names[ "targetname" ][ "player_respawn_point" ] = [];
	level.struct_class_names[ "script_noteworthy" ][ "initial_spawn" ] = [];
	coordinates_1 = array( ( 1800.81, 1200.72, 3216.13 ), ( 1800.81, 1280.72, 3216.13 ), ( 1800.81, 1360.72, 3216.13 ), ( 1800.81, 1440.72, 3216.13 ) );
	angles_1 = array( ( 0, 180, 0  ), ( 0, 180, 0  ), ( 0, 180, 0  ), ( 0, 180, 0  ) );
	for ( i = 0; i < coordinates_1.size; i++ )
	{
		scripts\zm\_gametype_setup::register_map_initial_spawnpoint( coordinates_1[ i ], angles_1[ i ], 1 );
	}
	coordinates_2 = array( ( 1600.81, 1200.72, 3216.13 ), ( 1600.81, 1280.72, 3216.13 ), ( 1600.81, 1360.72, 3216.13 ), ( 1600.81, 1440.72, 3216.13 ) );
	angles_2 = array( ( 0, 0, 0 ), ( 0, 0, 0 ), ( 0, 0, 0 ), ( 0, 0, 0 ) );
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
	maps/mp/zm_highrise_classic::precache();
}

main()
{
	spawn_barriers();
	scripts/zm/_gametype_setup::wallbuy( "mp5k_zm", "mp5", "weapon_upgrade", (1455.64, 2026.42, 3105), ( 0, 270, 0 ) );
}

spawn_barriers()
{
	preCacheModel("collision_player_wall_256x256x10");
	preCacheModel("collision_player_wall_64x64x10");
	collision2 = Spawn( "script_model", (1195.34, 1281.47, 3392.13) + (0,50,0) );
	collision2 RotateTo((0,90,0), .1);
	collision2 SetModel( "collision_player_wall_256x256x10" );
	building1topbarrier1 = Spawn("script_model", (2179.74, 1110.85, 3206.64));
	building1topbarrier1 SetModel("collision_player_wall_256x256x10");
	building1topbarrier1 RotateTo((0,0,0),.1);
	building1topbarrier2 = Spawn("script_model", (2248.78, 1541.87, 3350));
	building1topbarrier2 SetModel("collision_player_wall_256x256x10");
	building1topbarrier2 RotateTo((0,90,0),.1);
	elevatorbarrier1 = Spawn("script_model", (1651.49, 2168.44, 3392.01) + (0,0,32));
	elevatorbarrier1 SetModel("collision_player_wall_64x64x10");
	elevatorbarrier1 RotateTo((0,0,0),.1);
	elevatorbarrier2 = Spawn("script_model", (1958.84, 1676.59, 3391.99) + (0,0,32));
	elevatorbarrier2 SetModel("collision_player_wall_64x64x10");
	elevatorbarrier2 RotateTo((0,0,0),.1);
	elevatorbarrier3 = Spawn("script_model", (1957.68, 1676.22, 3216.03) + (0,0,32));
	elevatorbarrier3 SetModel("collision_player_wall_64x64x10");
	elevatorbarrier3 RotateTo((0,0,0),.1);
	elevatorbarrier4 = Spawn("script_model", (1475.31, 1218.09, 3218.16) + (0,0,32));
	elevatorbarrier4 SetModel("collision_player_wall_64x64x10");
	elevatorbarrier4 RotateTo((0,90,0),.1);
	elevatorbarrier5 = Spawn("script_model", (1647.22, 2171.76, 3215.57) + (0,0,32));
	elevatorbarrier5 SetModel("collision_player_wall_64x64x10");
	elevatorbarrier5 RotateTo((0,0,0),.1);
	elevatorbarrier6 = Spawn("script_model", (1647.7, 2167.82, 3040.09) + (0,0,32));
	elevatorbarrier6 SetModel("collision_player_wall_64x64x10");
	elevatorbarrier6 RotateTo((0,0,0),.1);
}