#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zm_prison;
#include scripts/zm/zm_prison/locs/location_common;

struct_init()
{
	scripts/zm/grief/gametype_modules/_gametype_setup::register_perk_struct( "specialty_armorvest", "zombie_vending_jugg", ( 0, 102, 0 ), ( 473.92, 6638.99, 208 ) );
	coordinates = array( ( -335, 5512, -71 ), ( -589, 5452, -71 ), ( -1094, 5426, -71 ), ( -1200, 5882, -71 ),
						 ( 669, 6785, 209 ), ( 476, 6774, 196 ), ( 699, 6562, 208 ), ( 344, 6472, 264 ) );
	angles = array( ( 0, 0, 0 ), ( 0, 0, 0 ), ( 0, 180, 0 ), ( 0, 0, 0 ),
					( 0, 180, 0 ), ( 0, 180, 0), ( 0, 0, 0 ), ( 0, 0, 0) );
	level.struct_class_names[ "targetname" ][ "player_respawn_point" ] = [];
	level.struct_class_names[ "script_noteworthy" ][ "initial_spawn" ] = [];
	for ( i = 0; i < coordinates.size; i++ )
	{
		scripts/zm/grief/gametype_modules/_gametype_setup::register_map_initial_spawnpoint( coordinates[ i ], angles[ i ] );
	}
	level.location_zones = [];
	level.location_zones[ 0 ] = "zone_dock";
	level.location_zones[ 1 ] = "zone_dock_puzzle";
	level.location_zones[ 2 ] = "zone_dock_gondola";
}

precache()
{
	
}

main()
{
	maps/mp/gametypes_zm/_zm_gametype::setup_standard_objects( "cellblock" );
	// maps/mp/zombies/_zm_magicbox::treasure_chest_init( "start_chest" );
	precacheshader( "zm_al_wth_zombie" );
	maps/mp/zombies/_zm_ai_brutus::precache();
	maps/mp/zombies/_zm_ai_brutus::init();
	array_thread( level.zombie_spawners, ::add_spawn_function, ::remove_zombie_hats_for_grief );
	t_temp = getent( "tower_trap_activate_trigger", "targetname" );
	t_temp delete();
	t_temp = getent( "tower_trap_range_trigger", "targetname" );
	t_temp delete();
	e_model = getent( "trap_control_docks", "targetname" );
	e_model delete();
	e_brush = getent( "tower_shockbox_door", "targetname" );
	e_brush delete();
	a_t_travel_triggers = getentarray( "travel_trigger", "script_noteworthy" );
	foreach ( trigger in a_t_travel_triggers )
	{
		trigger delete();
	}
	// a_e_gondola_lights = getentarray( "gondola_state_light", "targetname" );
	// foreach ( light in a_e_gondola_lights )
	// {
	// 	light delete();
	// }
	// a_e_gondola_landing_gates = getentarray( "gondola_landing_gates", "targetname" );
	// foreach ( model in a_e_gondola_landing_gates )
	// {
	// 	model delete();
	// }
	// a_e_gondola_landing_doors = getentarray( "gondola_landing_doors", "targetname" );
	// foreach ( model in a_e_gondola_landing_doors )
	// {
	// 	model delete();
	// }
	// a_e_gondola_gates = getentarray( "gondola_gates", "targetname" );
	// foreach ( model in a_e_gondola_gates )
	// {
	// 	model delete();
	// }
	// a_e_gondola_doors = getentarray( "gondola_doors", "targetname" );
	// foreach ( model in a_e_gondola_doors )
	// {
	// 	model delete();
	// }
	// m_gondola = getent( "zipline_gondola", "targetname" );
	// m_gondola delete();
	// t_ride_trigger = getent( "gondola_ride_trigger", "targetname" );
	// t_ride_trigger delete();
	// a_classic_clips = getentarray( "classic_clips", "targetname" );
	// foreach ( clip in a_classic_clips )
	// {
	// 	clip connectpaths();
	// 	clip delete();
	// }
	a_afterlife_props = getentarray( "afterlife_show", "targetname" );
	foreach ( m_prop in a_afterlife_props )
	{
		m_prop delete();
	}
	spork_portal = getent( "afterlife_show_spork", "targetname" );
	spork_portal delete();
	a_audio = getentarray( "at_headphones", "script_noteworthy" );
	foreach ( model in a_audio )
	{
		model delete();
	}
	m_spoon_pickup = getent( "pickup_spoon", "targetname" );
	m_spoon_pickup delete();
	t_sq_bg = getent( "sq_bg_reward_pickup", "targetname" );
	t_sq_bg delete();
	t_crafting_table = getentarray( "open_craftable_trigger", "targetname" );
	foreach ( trigger in t_crafting_table )
	{
		trigger delete();
	}
	t_warden_fence = getent( "warden_fence_damage", "targetname" );
	t_warden_fence delete();
	m_plane_about_to_crash = getent( "plane_about_to_crash", "targetname" );
	m_plane_about_to_crash delete();
	m_plane_craftable = getent( "plane_craftable", "targetname" );
	m_plane_craftable delete();
	for ( i = 1; i <= 5; i++ )
	{
		m_key_lock = getent( "masterkey_lock_" + i, "targetname" );
		m_key_lock delete();
	}
	m_shower_door = getent( "shower_key_door", "targetname" );
	m_shower_door delete();
	m_nixie_door = getent( "nixie_door_left", "targetname" );
	m_nixie_door delete();
	m_nixie_door = getent( "nixie_door_right", "targetname" );
	m_nixie_door delete();
	m_nixie_brush = getent( "nixie_tube_weaponclip", "targetname" );
	m_nixie_brush delete();
	for ( i = 1; i <= 3; i++ )
	{
		m_nixie_tube = getent( "nixie_tube_" + i, "targetname" );
		m_nixie_tube delete();
	}
	// t_elevator_door = getent( "nixie_elevator_door", "targetname" );
	// t_elevator_door delete();
	// e_elevator_clip = getent( "elevator_door_playerclip", "targetname" );
	// e_elevator_clip delete();
	// e_elevator_bottom_gate = getent( "elevator_bottom_gate_l", "targetname" );
	// e_elevator_bottom_gate delete();
	// e_elevator_bottom_gate = getent( "elevator_bottom_gate_r", "targetname" );
	// e_elevator_bottom_gate delete();
	// m_docks_puzzle = getent( "cable_puzzle_gate_01", "targetname" );
	// m_docks_puzzle delete();
	// m_docks_puzzle = getent( "cable_puzzle_gate_02", "targetname" );
	// m_docks_puzzle delete();
	// m_infirmary_case = getent( "infirmary_case_door_left", "targetname" );
	// m_infirmary_case delete();
	// m_infirmary_case = getent( "infirmary_case_door_right", "targetname" );
	// m_infirmary_case delete();
	// fake_plane_part = getent( "fake_veh_t6_dlc_zombie_part_control", "targetname" );
	// fake_plane_part delete();
	// for ( i = 1; i <= 3; i++ )
	// {
	// 	m_generator = getent( "generator_panel_" + i, "targetname" );
	// 	m_generator delete();
	// }
	// a_m_generator_core = getentarray( "generator_core", "targetname" );
	// foreach ( generator in a_m_generator_core )
	// {
	// 	generator delete();
	// }
	e_playerclip = getent( "electric_chair_playerclip", "targetname" );
	e_playerclip delete();
	for ( i = 1; i <= 4; i++ )
	{
		t_use = getent( "trigger_electric_chair_" + i, "targetname" );
		t_use delete();
		m_chair = getent( "electric_chair_" + i, "targetname" );
		m_chair delete();
	}
	a_afterlife_interact = getentarray( "afterlife_interact", "targetname" );
	foreach ( model in a_afterlife_interact )
	{
		model turn_afterlife_interact_on();
		wait 0.1;
	}
	scripts/zm/zm_prison/locs/location_common::common_init();
	delete_door_trigs();
}

remove_zombie_hats_for_grief()
{
	self detach( "c_zom_guard_hat" );
}

delete_door_trigs()
{	
	doors = getentarray( "zombie_door", "targetname" );
	foreach ( door in doors )
	{
		if ( door.target == "pf3762_auto2526" ) //staircase
		{
			door delete();
		}
	}
}