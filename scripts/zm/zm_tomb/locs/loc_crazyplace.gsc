struct_init()
{
	// scripts/zm/_gametype_setup::register_perk_struct( "specialty_armorvest", "zombie_vending_jugg", ( 0, 330, 0 ), (1757, 92, 2876) );

	if ( !level.grief_ffa )
	{
		level.spawnpoint_system_using_script_ints = true;
	}
	level.struct_class_names[ "targetname" ][ "player_respawn_point" ] = [];
	level.struct_class_names[ "script_noteworthy" ][ "initial_spawn" ] = [];
	coordinates_1 = array( ( 11164, -6942, -351 ), ( 11301, -7129, -351 ), ( 9531, -7056, -351 ), ( 9683, -7028, -345 ) );

	angles_1 = array( ( 0, 223, 0 ), ( 0, 206, 0 ), ( 0, 282, 0 ), ( 0, 255, 0 ) );
	for ( i = 0; i < coordinates_1.size; i++ )
	{
		scripts\zm\_gametype_setup::register_map_initial_spawnpoint( coordinates_1[ i ], angles_1[ i ], 1 );
	}
	coordinates_2 = array( ( 9469, -8501, -403 ), ( 9480, -8635, -397 ), ( 11198, -8728, -413 ), ( 11318, -8613, -412 ) );
	angles_2 = array( ( 0, 349, 0 ), ( 0, 9, 0 ), ( 0, 152, 0 ), ( 0, 150, 0 ) );
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
	enable_zones();
}