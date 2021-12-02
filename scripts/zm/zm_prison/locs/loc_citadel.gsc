struct_init()
{
	scripts/zm/grief/gametype_modules/_gametype_setup::register_perk_struct( "specialty_armorvest", "zombie_vending_jugg", ( 3, 180, 0 ), ( 2184, 10429, 1144 ) );
	coordinates = array( ( -12, 8735, 1128 ), ( 311, 8722, 1128 ), ( 350, 9025, 1136 ), ( 730, 9017, 1128 ),
						 ( 729, 9370, 1104 ), ( 729, 9704, 1104 ), ( 739, 10007, 1128 ), ( 1122, 10050, 1128 ) );
	angles = array( ( 0, 0, 0 ), ( 0, 0, 0 ), ( 0, 180, 0 ), ( 0, 0, 0 ),
					( 0, 180, 0 ), ( 0, 180, 0), ( 0, 0, 0 ), ( 0, 0, 0) );
	level.struct_class_names[ "targetname" ][ "player_respawn_point" ] = [];
	level.struct_class_names[ "script_noteworthy" ][ "initial_spawn" ] = [];
	for ( i = 0; i < coordinates.size; i++ )
	{
		scripts/zm/grief/gametype_modules/_gametype_setup::register_map_initial_spawnpoint( coordinates[ i ], angles[ i ] );
	}
	level.location_zones = [];
	level.location_zones[ 0 ] = "zone_citadel_shower";
	level.location_zones[ 1 ] = "zone_citadel";
	level.location_zones[ 2 ] = "zone_citadel_warden";
}

precache()
{

}

main()
{
	m_lock = getent( "masterkey_lock_1", "targetname" );
	m_lock delete();
	door = getent( "tomahawk_room_door", "targetname" );
	door trigger_off();
	door connectpaths();
	shower_key_door = getent( "shower_key_door", "targetname" );
	shower_key_door moveto( shower_key_door.origin + vectorScale( ( 1, 0, 0 ), 80 ), 0.25 );
	shower_key_door connectpaths();
	shower_key_door playsound( "zmb_chainlink_open" );
	maps/mp/gametypes_zm/_zm_gametype::setup_standard_objects( "cellblock" );
	//maps/mp/zombies/_zm_magicbox::treasure_chest_init( "start_chest" );
	precacheshader( "zm_al_wth_zombie" );
	array_thread( level.zombie_spawners, ::add_spawn_function, ::remove_zombie_hats_for_grief );
	scripts/zm/grief/gametype_modules/_gametype_setup::wallbuy( ( 359, 0, 0 ), ( 1567, 10166, 1144 ), "mp5k_zm_fx", "mp5k_zm", "t6_wpn_smg_mp5_world", "mp5", "weapon_upgrade" );
	maps/mp/zombies/_zm_ai_brutus::precache();
	maps/mp/zombies/_zm_ai_brutus::init();
	scripts/zm/zm_prison/locs/location_common::common_init();
}

remove_zombie_hats_for_grief()
{
	self detach( "c_zom_guard_hat" );
}