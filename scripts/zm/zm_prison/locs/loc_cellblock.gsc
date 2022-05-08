#include maps/mp/gametypes_zm/zmeat;
#include maps/mp/zm_alcatraz_traps;
#include maps/mp/zombies/_zm_game_module;
#include maps/mp/zombies/_zm_blockers;
#include maps/mp/zombies/_zm_ai_brutus;
#include maps/mp/gametypes_zm/_zm_gametype;
#include maps/mp/zombies/_zm_magicbox;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zm_prison;
#include maps/mp/zombies/_zm_race_utility;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include scripts/zm/zm_prison/locs/location_common;

struct_init()
{
	if ( !level.grief_ffa )
	{
		//level.spawnpoint_system_using_script_ints = true;
	}
	scripts/zm/_gametype_setup::register_perk_struct( "specialty_armorvest", "zombie_vending_jugg", ( 0, 86, 0 ), ( 1403, 9662, 1336 ) );
	coordinates = array( ( 1422, 9597, 1336 ), ( 1432, 9745, 1336 ), ( 2154, 9062, 1336 ), ( 1969, 9950, 1336 ),
							( 2150, 9496, 1336 ), ( 2144, 9931, 1336 ), ( 1665, 9053, 1336 ), ( 1661, 9211, 1336 ) );
	angles = array( ( 0, 0, 0 ), ( 0, 0, 0 ), ( 0, 180, 0 ), ( 0, 0, 0 ),
					( 0, 180, 0 ), ( 0, 180, 0), ( 0, 0, 0 ), ( 0, 0, 0) );
	level.struct_class_names[ "targetname" ][ "player_respawn_point" ] = [];
	level.struct_class_names[ "script_noteworthy" ][ "initial_spawn" ] = [];
	for ( i = 0; i < coordinates.size; i++ )
	{
		scripts/zm/_gametype_setup::register_map_initial_spawnpoint( coordinates[ i ], angles[ i ] );
	}
}

precache()
{
	setdvar( "disableLookAtEntityLogic", 1 );
	level.chests = [];
	level.chests[ level.chests.size ] = getstruct( "start_chest", "script_noteworthy" );
	level.chests[ level.chests.size ] = getstruct( "cafe_chest", "script_noteworthy" );
}

main()
{
	maps/mp/gametypes_zm/_zm_gametype::setup_standard_objects( "cellblock" );
	maps/mp/zombies/_zm_magicbox::treasure_chest_init( "start_chest" );
	precacheshader( "zm_al_wth_zombie" );
	array_thread( level.zombie_spawners, ::add_spawn_function, ::remove_zombie_hats_for_grief );
	maps/mp/zombies/_zm_ai_brutus::precache();
	maps/mp/zombies/_zm_ai_brutus::init();
	level._effect["butterflies"] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_skull_elec" );
	a_t_door_triggers = getentarray( "zombie_door", "targetname" );
	triggers = a_t_door_triggers;
	i = 0;
	while ( i < triggers.size )
	{
		if ( isDefined( triggers[ i ].script_flag ) )
		{
			if ( triggers[ i ].script_flag == "activate_cellblock_citadel" || triggers[ i ].script_flag == "activate_shower_room" || triggers[ i ].script_flag == "activate_cellblock_infirmary" || triggers[ i ].script_flag == "activate_infirmary" )
			{
				triggers[ i ] delete();
				i++;
				continue;
			}
			if ( triggers[ i ].script_flag == "activate_cafeteria" || triggers[ i ].script_flag == "activate_cellblock_east" || triggers[ i ].script_flag == "activate_cellblock_west" || triggers[ i ].script_flag == "activate_cellblock_barber" || triggers[ i ].script_flag == "activate_cellblock_gondola" || triggers[ i ].script_flag == "activate_cellblock_east_west" || triggers[ i ].script_flag == "activate_warden_office" )
			{
				i++;
				continue;
			}
			if ( isDefined( triggers[ i ].target ) )
			{
				str_target = triggers[ i ].target;
				a_door_and_clip = getentarray( str_target, "targetname" );
				foreach ( ent in a_door_and_clip )
				{
					ent delete();
				}
			}
			triggers[ i ] delete();
		}
		i++;
	}
	delete_door_trigs();
	first_room_hallway_barrier();
	zbarriers = getzbarrierarray();
	a_str_zones = [];
	a_str_zones[ 0 ] = "zone_start";
	a_str_zones[ 1 ] = "zone_library";
	a_str_zones[ 2 ] = "zone_cafeteria";
	a_str_zones[ 3 ] = "zone_cafeteria_end";
	a_str_zones[ 4 ] = "zone_warden_office";
	a_str_zones[ 5 ] = "zone_cellblock_east";
	a_str_zones[ 6 ] = "zone_cellblock_west_warden";
	a_str_zones[ 7 ] = "zone_cellblock_west_barber";
	a_str_zones[ 8 ] = "zone_cellblock_west";
	a_str_zones[ 9 ] = "zone_cellblock_west_gondola";
	foreach ( barrier in zbarriers )
	{
		if ( isDefined( barrier.script_noteworthy ) && barrier.script_noteworthy == "cafe_chest_zbarrier" || isDefined( barrier.script_noteworthy ) && barrier.script_noteworthy == "start_chest_zbarrier" )
		{		
		}
		else
		{
			str_model = barrier.model;
			b_delete_barrier = 1;
			if ( isdefined( barrier.script_string ) )
			{
				for ( i = 0; i < a_str_zones.size; i++ )
				{
					if ( str_model == a_str_zones[ i ] )
					{
						b_delete_barrier = 0;
						break;
					}
				}
			}
			else if ( b_delete_barrier == 1 )
			{
				barrier delete();
			}
		}
	}
	a_e_gondola_lights = getentarray( "gondola_state_light", "targetname" );
	foreach ( light in a_e_gondola_lights )
	{
		light delete();
	}
	a_e_gondola_landing_gates = getentarray( "gondola_landing_gates", "targetname" );
	foreach ( model in a_e_gondola_landing_gates )
	{
		model delete();
	}
	a_e_gondola_landing_doors = getentarray( "gondola_landing_doors", "targetname" );
	foreach ( model in a_e_gondola_landing_doors )
	{
		model delete();
	}
	a_e_gondola_gates = getentarray( "gondola_gates", "targetname" );
	foreach ( model in a_e_gondola_gates )
	{
		model delete();
	}
	a_e_gondola_doors = getentarray( "gondola_doors", "targetname" );
	foreach ( model in a_e_gondola_doors )
	{
		model delete();
	}
	m_gondola = getent( "zipline_gondola", "targetname" );
	m_gondola delete();
	a_classic_clips = getentarray( "classic_clips", "targetname" );
	foreach ( clip in a_classic_clips )
	{
		clip connectpaths();
		clip delete();
	}
	m_spoon_pickup = getent( "pickup_spoon", "targetname" );
	m_spoon_pickup delete();
	t_sq_bg = getent( "sq_bg_reward_pickup", "targetname" );
	t_sq_bg delete();
	t_warden_fence = getent( "warden_fence_damage", "targetname" );
	t_warden_fence delete();
	m_plane_about_to_crash = getent( "plane_about_to_crash", "targetname" );
	m_plane_about_to_crash delete();
	m_plane_craftable = getent( "plane_craftable", "targetname" );
	m_plane_craftable delete();
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
	t_elevator_door = getent( "nixie_elevator_door", "targetname" );
	t_elevator_door delete();
	e_elevator_clip = getent( "elevator_door_playerclip", "targetname" );
	e_elevator_clip delete();
	e_elevator_bottom_gate = getent( "elevator_bottom_gate_l", "targetname" );
	e_elevator_bottom_gate delete();
	e_elevator_bottom_gate = getent( "elevator_bottom_gate_r", "targetname" );
	e_elevator_bottom_gate delete();
	m_infirmary_case = getent( "infirmary_case_door_left", "targetname" );
	m_infirmary_case delete();
	m_infirmary_case = getent( "infirmary_case_door_right", "targetname" );
	m_infirmary_case delete();
	fake_plane_part = getent( "fake_veh_t6_dlc_zombie_part_control", "targetname" );
	fake_plane_part delete();
	a_afterlife_interact = getentarray( "afterlife_interact", "targetname" );
	foreach ( model in a_afterlife_interact )
	{
		model turn_afterlife_interact_on();
		wait 0.1;
	}
	scripts/zm/zm_prison/locs/location_common::common_init();
	level notify( "sleight_on" );
	wait_network_frame();
	level notify( "doubletap_on" );
	wait_network_frame();
	level notify( "juggernog_on" );
	wait_network_frame();
	level notify( "electric_cherry_on" );
	wait_network_frame();
	level notify( "deadshot_on" );
	wait_network_frame();
	level notify( "divetonuke_on" );
	wait_network_frame();
	level notify( "additionalprimaryweapon_on" );
	wait_network_frame();
	level notify( "Pack_A_Punch_on" );
	wait_network_frame();
}

remove_zombie_hats_for_grief()
{
	self detach( "c_zom_guard_hat" );
}

magicbox_face_spawn()
{
	self endon( "disconnect" );
	if ( !is_gametype_active( "zgrief" ) )
	{
		return;
	}
	while ( 1 )
	{
		self waittill( "user_grabbed_weapon" );
		if ( randomint( 50000 ) == 115 )
		{
			self playsoundtoplayer( "zmb_easteregg_face", self );
			self.wth_elem = newclienthudelem( self );
			self.wth_elem.horzalign = "fullscreen";
			self.wth_elem.vertalign = "fullscreen";
			self.wth_elem.sort = 1000;
			self.wth_elem.foreground = 0;
			self.wth_elem.alpha = 1;
			self.wth_elem setshader( "zm_al_wth_zombie", 640, 480 );
			self.wth_elem.hidewheninmenu = 1;
			wait 0.25;
			self.wth_elem destroy();
		}
		wait 0.05;
	}
}

delete_door_trigs()
{	
	if ( level.grief_gamerules[ "disable_doors" ].current )
	{
		doors = getentarray( "zombie_door", "targetname" );
		foreach ( door in doors )
		{
			if (  door.target == "pf3674_auto2581" || door.target == "cellblock_start_door" )
			{
				door delete();
			}
		}
	}
}

first_room_hallway_barrier()
{
	collision = spawn( "script_model", ( 2113, 9772, 1530 ) );
	collision.angles = ( 0, 90, 0 );
	collision setmodel( "collision_clip_wall_128x128x10" );
	gate = spawn( "script_model", ( 2111, 9728, 1458 ) );
	gate.angles = ( 0, 90, 0 );
	gate setmodel( "p6_zm_al_cell_door_r_90x102x2" );
}