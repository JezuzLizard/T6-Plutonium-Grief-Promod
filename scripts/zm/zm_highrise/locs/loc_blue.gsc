struct_init()
{
	if ( !level.grief_ffa )
	{
		level.spawnpoint_system_using_script_ints = true;
	}
	level.struct_class_names[ "targetname" ][ "player_respawn_point" ] = [];
	level.struct_class_names[ "script_noteworthy" ][ "initial_spawn" ] = [];
	coordinates_1 = array( ( 1960.39, 358.795, 2880.13 ), ( 1904.38, 262.504, 2880.13 ) ( 1861.64, 178.39, 2880.13 ), ( 1834.66, 101.629, 2880.13 ) );

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
	maps/mp/zm_highrise_classic::precache();
}

main()
{
	maps/mp/zm_highrise_classic::main();
}