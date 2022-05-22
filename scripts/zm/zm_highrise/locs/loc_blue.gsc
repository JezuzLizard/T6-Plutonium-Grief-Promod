struct_init()
{
	scripts\zm\_gametype_setup::register_perk_struct( "specialty_armorvest", "zombie_vending_jugg", ( 0, 330, 0 ), (1757, 92, 2876) );

	if ( !level.grief_ffa )
	{
		level.spawnpoint_system_using_script_ints = true;
	}
	level.struct_class_names[ "targetname" ][ "player_respawn_point" ] = [];
	level.struct_class_names[ "script_noteworthy" ][ "initial_spawn" ] = [];
	coordinates_1 = array( ( 1960.39, 358.795, 2880.13 ), ( 1904.38, 262.504, 2880.13 ), ( 1861.64, 178.39, 2880.13 ), ( 1834.66, 101.629, 2880.13 ) );

	angles_1 = array( ( 0, -30.3558, 0 ), ( 0, -32.1685, 0 ), ( 0, -32.1685, 0 ), ( 0, -31.9158, 0 ) );
	for ( i = 0; i < coordinates_1.size; i++ )
	{
		scripts\zm\_gametype_setup::register_map_initial_spawnpoint( coordinates_1[ i ], angles_1[ i ], 1 );
	}
	coordinates_2 = array( ( 2143.99, 252.099, 2880.13 ), ( 2079.16, 150.115, 2880.13 ), ( 2061.76, 53.6637, 2880.13 ), ( 2011.59, -19.6268, 2880.13 ) );
	angles_2 = array( ( 0, 147.013, 0 ), ( 0, 147.013, 0 ), ( 0, 145.2, 0 ), ( 0, 145.2, 0 ) );
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
	maps\mp\zm_highrise_classic::precache();
	preCacheModel("collision_player_wall_256x256x10");
	preCacheModel("collision_player_wall_64x64x10");
}

main()
{
	spawn_barriers();
	maps\mp\zm_highrise_classic::main();
}

spawn_barriers()
{
	building1topbarrier1 = Spawn("script_model", (2627, 1003, 2673));
	building1topbarrier1 SetModel("collision_player_wall_256x256x10");
	building1topbarrier1 RotateTo((0,0,0),.1);
	elevatorbarrier1 = Spawn("script_model", (3033, 34, 2704) + (0,0,32));
	elevatorbarrier1 SetModel("collision_player_wall_64x64x10");
	elevatorbarrier1 RotateTo((0,60,0),.1);
	elevatorbarrier2 = Spawn("script_model", (2437, -696, 2704) + (0,0,32));
	elevatorbarrier2 SetModel("collision_player_wall_64x64x10");
	elevatorbarrier2 RotateTo((0,-30,0),.1);
	elevatorbarrier3 = Spawn("script_model", (2677, -631, 2704) + (0,0,32));
	elevatorbarrier3 SetModel("collision_player_wall_64x64x10");
	elevatorbarrier3 RotateTo((0,60,0),.1);
	elevatorbarrier4 = Spawn("script_model", (1433, -570, 2704) + (0,0,32));
	elevatorbarrier4 SetModel("collision_player_wall_64x64x10");
	elevatorbarrier4 RotateTo((0,-30,0),.1);
	elevatorbarrier5 = Spawn("script_model", (2435, -695, 2880) + (0,0,32));
	elevatorbarrier5 SetModel("collision_player_wall_64x64x10");
	elevatorbarrier5 RotateTo((0,150,0),.1); //good
	elevatorbarrier6 = Spawn("script_model", (2672, -631, 2880) + (0,0,32));
	elevatorbarrier6 SetModel("collision_player_wall_64x64x10");
	elevatorbarrier6 RotateTo((0,60,0),.1); //good
}