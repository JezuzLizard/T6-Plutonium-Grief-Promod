struct_init()
{
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
	maps/mp/zm_highrise_classic::main();
}