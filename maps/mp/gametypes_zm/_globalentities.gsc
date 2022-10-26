#include maps\mp\zombies\_zm_game_module;
#include maps\mp\zm_transit_utility;
#include maps\mp\gametypes_zm\_zm_gametype;
#include maps\mp\zombies\_zm_magicbox;
#include maps\mp\zombies\_zm_race_utility;
#include maps\mp\zombies\_zm_utility;
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_weapons;
#include maps\mp\zombies\_zm_unitrigger;
#include maps\mp\zombies\_zm_weap_claymore;
#include maps\mp\zombies\_zm_melee_weapon;
#include maps\mp\zombies\_zm;

treasure_chest_init()
{
	mystery_box_zbarriers = getEntArray( "zbarrier_zmcore_MagicBox", "classname" );
	normalChests = getstructarray( "treasure_chest_use", "targetname" );
	level.chests = [];
	switch ( getDvar( "ui_zm_mapstartlocation" ) )
	{
		case "tunnel":
			start_chest_zbarrier = getEnt( "start_chest_zbarrier", "script_noteworthy" );
			start_chest_zbarrier.origin = ( -11090, -349, 193 );
			start_chest_zbarrier.angles = ( 0, -100, 0 );
			start_chest = spawnStruct();
			start_chest.origin = ( -11090, -349, 193 );
			start_chest.angles = ( 0, -100, 0 );
			start_chest.script_noteworthy = "start_chest";
			start_chest.zombie_cost = 950;
			collision = spawn( "script_model", start_chest_zbarrier.origin );
			collision.angles = start_chest_zbarrier.angles;
			collision setmodel( "collision_clip_32x32x128" );
			collision disconnectpaths();
			collision = spawn( "script_model", start_chest_zbarrier.origin - ( 4, 30, 0 ) );
			collision.angles = start_chest_zbarrier.angles;
			collision setmodel( "collision_clip_32x32x128" );
			collision disconnectpaths();
			collision = spawn( "script_model", start_chest_zbarrier.origin + ( 4, 30, 0 ) );
			collision.angles = start_chest_zbarrier.angles;
			collision setmodel( "collision_clip_32x32x128" );
			collision disconnectpaths();
			start_chest2_zbarrier = getEnt( "farm_chest_zbarrier", "script_noteworthy" );
			start_chest2_zbarrier.origin = ( -11772, -2501, 232 );
			start_chest2_zbarrier.angles = ( 0, 0, 0 );
			start_chest2 = spawnStruct();
			start_chest2.origin = ( -11772, -2501, 232 );
			start_chest2.angles = ( 0, 0, 0 );
			start_chest2.script_noteworthy = "farm_chest";
			start_chest2.zombie_cost = 950;
			collision = spawn( "script_model", start_chest2_zbarrier.origin );
			collision.angles = start_chest2_zbarrier.angles;
			collision setmodel( "collision_clip_32x32x128" );
			collision disconnectpaths();
			collision = spawn( "script_model", start_chest2_zbarrier.origin - ( 36, 0, 0 ) );
			collision.angles = start_chest2_zbarrier.angles;
			collision setmodel( "collision_clip_32x32x128" );
			collision disconnectpaths();
			collision = spawn( "script_model", start_chest2_zbarrier.origin + ( 36, 0, 0 ) );
			collision.angles = start_chest2_zbarrier.angles;
			collision setmodel( "collision_clip_32x32x128" );
			collision disconnectpaths();
			level.chests[ 0 ] = start_chest;
			level.chests[ 1 ] = start_chest2;
			randy = randomIntRange( 0, 3 );
			if ( randy == 1 )
			{
				treasure_chest_init( "start_chest" );
			}
			else
			{
				treasure_chest_init( "farm_chest" );
			}
			break;
		case "cornfield":
			start_chest_zbarrier = getEnt( "start_chest_zbarrier", "script_noteworthy" );
			start_chest_zbarrier.origin = ( 13566, -541, -188 );
			start_chest_zbarrier.angles = ( 0, -90, 0 );
			start_chest = spawnStruct();
			start_chest.origin = ( 13566, -541, -188 );
			start_chest.angles = ( 0, -90, 0 );
			start_chest.script_noteworthy = "start_chest";
			start_chest.zombie_cost = 950;
			collision = spawn( "script_model", start_chest_zbarrier.origin );
			collision.angles = start_chest_zbarrier.angles;
			collision setmodel( "collision_clip_32x32x128" );
			collision disconnectpaths();
			collision = spawn( "script_model", start_chest_zbarrier.origin - ( 0, 32, 0 ) );
			collision.angles = start_chest_zbarrier.angles;
			collision setmodel( "collision_clip_32x32x128" );
			collision disconnectpaths();
			collision = spawn( "script_model", start_chest_zbarrier.origin + ( 0, 32, 0 ) );
			collision.angles = start_chest_zbarrier.angles;
			collision setmodel( "collision_clip_32x32x128" );
			collision disconnectpaths();
			start_chest2_zbarrier = getEnt( "depot_chest_zbarrier", "script_noteworthy" );
			start_chest2_zbarrier.origin = ( 7458, -464, -196 );
			start_chest2_zbarrier.angles = ( 0, -90, 0 );
			start_chest2 = spawnStruct();
			start_chest2.origin = ( 7458, -464, -196 );
			start_chest2.angles = ( 0, -90, 0 );
			start_chest2.script_noteworthy = "depot_chest";
			start_chest2.zombie_cost = 950;
			collision = spawn( "script_model", start_chest2_zbarrier.origin );
			collision.angles = start_chest2_zbarrier.angles;
			collision setmodel( "collision_clip_32x32x128" );
			collision disconnectpaths();
			collision = spawn( "script_model", start_chest2_zbarrier.origin - ( 0, 32, 0 ) );
			collision.angles = start_chest2_zbarrier.angles;
			collision setmodel( "collision_clip_32x32x128" );
			collision disconnectpaths();
			collision = spawn( "script_model", start_chest2_zbarrier.origin + ( 0, 32, 0 ) );
			collision.angles = start_chest2_zbarrier.angles;
			collision setmodel( "collision_clip_32x32x128" );
			collision disconnectpaths();
			start_chest3_zbarrier = getEnt( "farm_chest_zbarrier", "script_noteworthy" );
			start_chest3_zbarrier.origin = ( 10158, 49, -220 );
			start_chest3_zbarrier.angles = ( 0, -185, 0 );
			start_chest3 = spawnStruct();
			start_chest3.origin = ( 10158, 49, -220 );
			start_chest3.angles = ( 0, -185, 0 );
			start_chest3.script_noteworthy = "farm_chest";
			start_chest3.zombie_cost = 950;
			collision = spawn( "script_model", start_chest3_zbarrier.origin );
			collision.angles = start_chest3_zbarrier.angles;
			collision setmodel( "collision_clip_32x32x128" );
			collision disconnectpaths();
			collision = spawn( "script_model", start_chest3_zbarrier.origin - ( 32, 0, 0 ) );
			collision.angles = start_chest3_zbarrier.angles;
			collision setmodel( "collision_clip_32x32x128" );
			collision disconnectpaths();
			collision = spawn( "script_model", start_chest3_zbarrier.origin + ( 32, 0, 0 ) );
			collision.angles = start_chest3_zbarrier.angles;
			collision setmodel( "collision_clip_32x32x128" );
			collision disconnectpaths();
			level.chests[ 0 ] = start_chest;
			level.chests[ 1 ] = start_chest2;
			level.chests[ 2 ] = start_chest3;
			randy = randomIntRange( 0, 3 );
			if ( randy == 1 )
			{
				treasure_chest_init( "start_chest" );
			}
			else if ( randy == 2 )
			{
				treasure_chest_init( "farm_chest" );
			}
			else
			{
				treasure_chest_init( "depot_chest" );
			}
			break;
		case "power":
			start_chest_zbarrier = getEnt( "depot_chest_zbarrier", "script_noteworthy" );
			start_chest_zbarrier.origin = ( 10806, 8518, -407 );
			start_chest_zbarrier.angles = ( 0, 180, 0 );
			start_chest = spawnStruct();
			start_chest.origin = ( 10806, 8518, -407 );
			start_chest.angles = ( 0, 180, 0 );
			start_chest.script_noteworthy = "depot_chest";
			start_chest.zombie_cost = 950;
			collision = spawn( "script_model", start_chest_zbarrier.origin );
			collision.angles = start_chest_zbarrier.angles;
			collision setmodel( "collision_clip_32x32x128" );
			collision disconnectpaths();
			collision = spawn( "script_model", start_chest_zbarrier.origin - ( 32, 0, 0 ) );
			collision.angles = start_chest_zbarrier.angles;
			collision setmodel( "collision_clip_32x32x128" );
			collision disconnectpaths();
			collision = spawn( "script_model", start_chest_zbarrier.origin + ( 32, 0, 0 ) );
			collision.angles = start_chest_zbarrier.angles;
			collision setmodel( "collision_clip_32x32x128" );
			collision disconnectpaths();
			level.chests[ 0 ] = normalChests[ 2 ];
			level.chests[ 1 ] = start_chest;
			treasure_chest_init( "pow_chest" );
			break;
		case "diner":
			start_chest_zbarrier = getEnt( "depot_chest_zbarrier", "script_noteworthy" );
			start_chest_zbarrier.origin = ( -5708, -7968, 232 );
			start_chest_zbarrier.angles = ( 0, 1, 0 );
			start_chest = spawnStruct();
			start_chest.origin = ( -5708, -7968, 232 );
			start_chest.angles = ( 0, 1, 0 );
			start_chest.script_noteworthy = "depot_chest";
			start_chest.zombie_cost = 950;
			collision = spawn( "script_model", start_chest_zbarrier.origin );
			collision.angles = start_chest_zbarrier.angles;
			collision setmodel( "collision_clip_32x32x128" );
			collision disconnectpaths();
			collision = spawn( "script_model", start_chest_zbarrier.origin - ( 32, 0, 0 ) );
			collision.angles = start_chest_zbarrier.angles;
			collision setmodel( "collision_clip_32x32x128" );
			collision disconnectpaths();
			collision = spawn( "script_model", start_chest_zbarrier.origin + ( 32, 0, 0 ) );
			collision.angles = start_chest_zbarrier.angles;
			collision setmodel( "collision_clip_32x32x128" );
			collision disconnectpaths();
			level.chests[ 0 ] = normalChests[ 3 ];
			level.chests[ 1 ] = start_chest;
			treasure_chest_init( "start_chest" );
			break;
	}
}

is_cut_map()
{
	location = getDvar( "ui_zm_mapstartlocation" );
	if ( location == "diner" || location == "tunnel" || location == "power" || location == "cornfield" )
	{
		return true;
	}
	return false;
}

main()
{
	if ( is_cut_map() )
	{
		level.create_spawner_list_func = ::create_spawner_list;
	}
	switch ( getDvar( "ui_zm_mapstartlocation" ) )
	{
		case "diner":
			level thread diner_hatch_access();
			_weapon_spawner( ( 0, 0, 0 ), ( -4280, -7486, -5 ), "m14_zm_fx", "m14_zm", "t6_wpn_ar_m14_world", "m14", "weapon_upgrade" );
			_weapon_spawner( ( 0, 0, 0 ), ( -5085, -7807, -5 ), "rottweil72_zm_fx", "rottweil72_zm", "t6_wpn_shotty_olympia_world", "olympia", "weapon_upgrade" );
			_weapon_spawner( ( 0, 180, 0 ), ( -3578, -7181, 0 ), "m16_zm_fx", "m16_zm", "t6_wpn_ar_m16a2_world", "m16", "weapon_upgrade" );
			_weapon_spawner( ( 0, 1, 0 ), ( -5489, -7982.7, 62 ), "mp5k_zm_fx", "mp5k_zm", "t6_wpn_smg_mp5_world", "mp5", "weapon_upgrade" );
			//_weapon_spawner( ( 0, 270, 0 ), ( -6399.2, -7938.5, 207.25 ), "tazer_knuckles_zm_fx", "tazer_knuckles_zm", "t6_wpn_taser_knuckles_world", "tazer_knuckles", "tazer_upgrade" );
			break;
		case "tunnel":
			_weapon_spawner( ( 0, -86, 0 ), ( -11166, -2844, 247 ), "m14_zm_fx", "m14_zm", "t6_wpn_ar_m14_world", "m14", "weapon_upgrade" );
			_weapon_spawner( ( 0, 83, 0 ), ( -10790, -1430, 247 ), "rottweil72_zm_fx", "rottweil72_zm", "t6_wpn_shotty_olympia_world", "olympia", "weapon_upgrade" );
			_weapon_spawner( ( 0, 270, 0 ), ( -11839, -1695.1, 287 ), "m16_zm_fx", "m16_zm", "t6_wpn_ar_m16a2_world", "m16", "weapon_upgrade" );
			_weapon_spawner( ( 0, 83, 0 ), ( -10625, -545, 247 ), "mp5k_zm_fx", "mp5k_zm", "t6_wpn_smg_mp5_world", "mp5", "weapon_upgrade" );
			//_weapon_spawner( ( 0, -93, 0 ), ( -11839, -2406, 283 ), "tazer_knuckles_zm_fx", "tazer_knuckles_zm", "t6_wpn_taser_knuckles_world", "tazer_knuckles", "tazer_upgrade" );
			break;
		case "power":
			//_weapon_spawner( ( 0, 90, 0), ( 10559, 8226, -504 ), "m14_zm_fx", "m14_zm", "t6_wpn_ar_m14_world", "m14", "weapon_upgrade" );
			_weapon_spawner( ( 0, -180, 0 ), ( 10620, 8135, -490 ), "mp5k_zm_fx", "mp5k_zm", "t6_wpn_smg_mp5_world", "mp5", "weapon_upgrade" );
			//_weapon_spawner( ( 0, 170, 0 ), ( 11769, 7662, -701 ), "rottweil72_zm_fx", "rottweil72_zm", "t6_wpn_shotty_olympia_world", "olympia", "weapon_upgrade" );
			_weapon_spawner( ( 0, 0, 0 ), ( 10859, 8146, -353 ), "m16_zm_fx", "m16_zm", "t6_wpn_ar_m16a2_world", "m16", "weapon_upgrade" );
			_weapon_spawner( ( 0, 90, 0 ), ( 11452, 8692, -521 ), "mp5k_zm_fx", "mp5k_zm", "t6_wpn_smg_mp5_world", "mp5", "weapon_upgrade" );
			//_weapon_spawner( ( 0, 180, 0 ), ( -4280, -7486, -5 ), "bowie_knife_zm_fx", "bowie_knife_zm", "world_knife_bowie", "bowie_knife", "bowie_upgrade" );
			level thread falling_death_init();
			break;
		case "cornfield":
			//_weapon_spawner( ( 0, -180, 0 ), ( 13603, -1282, -134 ), "claymore_zm_fx", "claymore_zm", "t6_wpn_claymore_world", "claymore", "claymore_purchase" );
			_weapon_spawner( ( 0, -90, 0 ), ( 13663, -1166, -134 ), "rottweil72_zm_fx", "rottweil72_zm", "t6_wpn_shotty_olympia_world", "olympia", "weapon_upgrade" );
			//_weapon_spawner( ( 0, 90, 0 ), ( 14092, -351, -133 ), "m16_zm_fx", "m16_zm", "t6_wpn_ar_m16a2_world", "m16", "weapon_upgrade" );
			_weapon_spawner( ( 0, 90, 0 ), ( 13542, -764, -133 ), "mp5k_zm_fx", "mp5k_zm", "t6_wpn_smg_mp5_world", "mp5", "weapon_upgrade" );
			//_weapon_spawner( ( 0, 90, 0 ), ( 13502, -12, -125 ), "tazer_knuckles_zm_fx", "tazer_knuckles_zm", "t6_wpn_taser_knuckles_world", "tazer_knuckles", "tazer_upgrade" );
			level thread increase_cornfield_zombie_speed();
			break;
	}
	init_barriers_for_cut_locations();
	treasure_chest_init();
	level.enemy_location_override_func = ::enemy_location_override;
	//level.player_out_of_playable_area_monitor = 0;
	flag_wait( "initial_blackscreen_passed" );
	turn_power_on_and_open_doors();
	flag_wait( "start_zombie_round_logic" );
	wait 1;
	level notify( "revive_on" );
	wait_network_frame();
	level notify( "doubletap_on" );
	wait_network_frame();
	level notify( "marathon_on" );
	wait_network_frame();
	level notify( "juggernog_on" );
	wait_network_frame();
	level notify( "sleight_on" );
	wait_network_frame();
	level notify( "tombstone_on" );
	wait_network_frame();
	level notify( "Pack_A_Punch_on" );
}

enemy_location_override( zombie, enemy )
{
	location = enemy.origin;
	if ( is_true( self.reroute ) )
	{
		if ( isDefined( self.reroute_origin ) )
		{
			location = self.reroute_origin;
		}
	}
	return location;
}

diner_hatch_access()
{
	diner_hatch = getent( "diner_hatch", "targetname" );
	diner_hatch_col = getent( "diner_hatch_collision", "targetname" );
	diner_hatch_mantle = getent( "diner_hatch_mantle", "targetname" );
	if ( !isDefined( diner_hatch ) || !isDefined( diner_hatch_col ) )
	{
		return;
	}
	diner_hatch hide();
	diner_hatch_mantle.start_origin = diner_hatch_mantle.origin;
	diner_hatch_mantle.origin += vectorScale( ( 0, 0, 0 ), 500 );
	diner_hatch show();
	diner_hatch_col delete();
	diner_hatch_mantle.origin = diner_hatch_mantle.start_origin;
	level.players[ 0 ] maps\mp\zombies\_zm_buildables::track_placed_buildables( "dinerhatch" );
}

_weapon_spawner( weapon_angles, weapon_coordinates, chalk_fx, weapon_name, weapon_model, target, targetname )
{
	tempmodel = spawn( "script_model", ( 0, 0, 0 ) );
	precachemodel( weapon_model );
	unitrigger_stub = spawnstruct();
	unitrigger_stub.origin = weapon_coordinates;
	unitrigger_stub.angles = weapon_angles;
	tempmodel.origin = weapon_coordinates;
	tempmodel.angles = weapon_angles;
	mins = undefined;
	maxs = undefined;
	absmins = undefined;
	absmaxs = undefined;
	tempmodel setmodel( weapon_model );
	tempmodel useweaponhidetags( weapon_name );
	mins = tempmodel getmins();
	maxs = tempmodel getmaxs();
	absmins = tempmodel getabsmins();
	absmaxs = tempmodel getabsmaxs();
	bounds = absmaxs - absmins;
	unitrigger_stub.script_length = bounds[ 0 ] * 0.25;
	unitrigger_stub.script_width = bounds[ 1 ];
	unitrigger_stub.script_height = bounds[ 2 ];
	unitrigger_stub.origin -= anglesToRight( unitrigger_stub.angles ) * ( unitrigger_stub.script_length * 0.4 );
	unitrigger_stub.target = target;
	unitrigger_stub.targetname = targetname;
	unitrigger_stub.cursor_hint = "HINT_NOICON";
	if ( unitrigger_stub.targetname == "weapon_upgrade" )
	{
		unitrigger_stub.cost = get_weapon_cost( weapon_name );
		if ( !is_true( level.monolingustic_prompt_format ) )
		{
			unitrigger_stub.hint_string = get_weapon_hint( weapon_name );
			unitrigger_stub.hint_parm1 = unitrigger_stub.cost;
		}
		else
		{
			unitrigger_stub.hint_parm1 = get_weapon_display_name( weapon_name );
			if ( !isDefined( unitrigger_stub.hint_parm1 ) || unitrigger_stub.hint_parm1 == "" || unitrigger_stub.hint_parm1 == "none" )
			{
				unitrigger_stub.hint_parm1 = "missing weapon name " + weapon_name;
			}
			unitrigger_stub.hint_parm2 = unitrigger_stub.cost;
			unitrigger_stub.hint_string = &"ZOMBIE_WEAPONCOSTONLY";
		}
	}
	unitrigger_stub.weapon_upgrade = weapon_name;
	unitrigger_stub.script_unitrigger_type = "unitrigger_box_use";
	unitrigger_stub.require_look_at = 1;
	unitrigger_stub.require_look_from = 0;
	unitrigger_stub.zombie_weapon_upgrade = weapon_name;
	maps\mp\zombies\_zm_unitrigger::unitrigger_force_per_player_triggers( unitrigger_stub, 1 );
	if ( is_melee_weapon( weapon_name ) )
	{
		if ( weapon_name == "tazer_knuckles_zm" && isDefined( level.taser_trig_adjustment ) )
		{
			unitrigger_stub.origin += level.taser_trig_adjustment;
		}
		maps\mp\zombies\_zm_unitrigger::register_static_unitrigger( unitrigger_stub, ::melee_weapon_think );
	}
	else if ( weapon_name == "claymore_zm" )
	{
		unitrigger_stub.prompt_and_visibility_func = ::claymore_unitrigger_update_prompt;
		maps\mp\zombies\_zm_unitrigger::register_static_unitrigger( unitrigger_stub, ::buy_claymores );
	}
	else
	{
		unitrigger_stub.prompt_and_visibility_func = ::wall_weapon_update_prompt;
		maps\mp\zombies\_zm_unitrigger::register_static_unitrigger( unitrigger_stub, ::weapon_spawn_think );
	}
	tempmodel delete();
	thread playchalkfx( chalk_fx, weapon_coordinates, weapon_angles );
}

playchalkfx( effect, origin, angles )
{
	while ( 1 )
	{
		fx = SpawnFX( level._effect[ effect ], origin, AnglesToForward( angles ), AnglesToUp( angles ) );
		TriggerFX( fx );
		level waittill( "connected", player );
		fx Delete();
	}
}

zombie_speed_up_distance_check()
{
	if ( distance( self.origin, self.closestPlayer.origin ) > 1000 )
	{
		return 1;
	}
	return 0;
}

increase_cornfield_zombie_speed()
{
	level endon( "end_game" );
	level waittill( "connected", player );
	level.zombie_vars[ "zombie_spawn_delay" ] = 0.08;
	level.speed_change_round = undefined;
	while ( 1 )
	{
		zombies = get_round_enemy_array();
		for ( i = 0; i < zombies.size; i++ )
		{
			zombies[ i ].closestPlayer = get_closest_valid_player( zombies[ i ].origin );
		}
		zombies = get_round_enemy_array();
		for ( i = 0; i < zombies.size; i++ )
		{
			if ( zombies[ i ] zombie_speed_up_distance_check() )
			{
				zombies[ i ] set_zombie_run_cycle( "chase_bus" );
			}
			else if ( zombies[ i ].zombie_move_speed != "sprint" )
			{
				zombies[ i ] set_zombie_run_cycle( "sprint" );
			}
		}
		wait 1;
	}
}

_spawn_tranzit_barrier( barrier_coordinates, barrier_model, barrier_angles, not_solid )
{
	if ( !isDefined( level.survival_barriers ) )
	{
		level.survival_barriers = [];
		level.survival_barriers_index = 0;
	}
	level.survival_barriers[ level.survival_barriers_index ] = spawn( "script_model", barrier_coordinates );
	level.survival_barriers[ level.survival_barriers_index ] setModel( barrier_model );
	level.survival_barriers[ level.survival_barriers_index ] rotateTo( barrier_angles, 0.1 );
	level.survival_barriers[ level.survival_barriers_index ] disconnectPaths();  
	if ( is_true( not_solid ) )
	{
		level.survival_barriers[ level.survival_barriers_index ] notSolid();
	}
	level.survival_barriers_index++;
}

init_barriers_for_cut_locations()
{
	switch ( getDvar( "ui_zm_mapstartlocation" ) )
	{
		case "tunnel":
			_spawn_tranzit_barrier( ( -11250, -520, 255 ), "veh_t6_civ_movingtrk_cab_dead", ( 0, 172, 0 ) );
			_spawn_tranzit_barrier( ( -11250, -580, 255 ), "collision_player_wall_256x256x10", ( 0, 180, 0 ) );
			_spawn_tranzit_barrier( ( -11506, -580, 255 ), "collision_player_wall_256x256x10", ( 0, 180, 0 ) );
			_spawn_tranzit_barrier( ( -10770, -3240, 255 ), "veh_t6_civ_movingtrk_cab_dead", ( 0, 214, 0 ) );
			_spawn_tranzit_barrier( ( -10840, -3190, 255 ), "collision_player_wall_256x256x10", ( 0, 214, 0 ) );
			break;
		case "diner":
			_spawn_tranzit_barrier( ( -3952, -6957, -67 ), "collision_player_wall_256x256x10", ( 0, 82, 0 ) );
			_spawn_tranzit_barrier( ( -4173, -6679, -60 ), "collision_player_wall_512x512x10", ( 0, 0, 0 ) );
			_spawn_tranzit_barrier( ( -5073, -6732, -59 ), "collision_player_wall_512x512x10", ( 0, 328, 0 ) );
			_spawn_tranzit_barrier( ( -6104, -6490, -38 ), "collision_player_wall_512x512x10", ( 0, 2, 0 ) );
			_spawn_tranzit_barrier( ( -5850, -6486, -38 ), "collision_player_wall_256x256x10", ( 0, 0, 0 ) );
			_spawn_tranzit_barrier( ( -5624, -6406, -40 ), "collision_player_wall_256x256x10", ( 0, 226, 0 ) );
			_spawn_tranzit_barrier( ( -6348, -6886, -55 ), "collision_player_wall_512x512x10", ( 0, 98, 0 ) );
			break;
		case "power":
			_spawn_tranzit_barrier( ( 9965, 8133, -556 ), "veh_t6_civ_60s_coupe_dead", ( 15, 5, 0 ) );
			_spawn_tranzit_barrier( ( 9955, 8105, -575 ), "collision_player_wall_256x256x10", ( 0, 0, 0 ) );
			_spawn_tranzit_barrier( ( 10056, 8350, -584 ), "veh_t6_civ_bus_zombie", ( 0, 340, 0 ), 1 );
			_spawn_tranzit_barrier( ( 10267, 8194, -556 ), "collision_player_wall_256x256x10", ( 0, 340, 0 ) );
			_spawn_tranzit_barrier( ( 10409, 8220, -181 ), "collision_player_wall_512x512x10", ( 0, 250, 0 ) );
			_spawn_tranzit_barrier( ( 10409, 8220, -556 ), "collision_player_wall_128x128x10", ( 0, 250, 0 ) );
			_spawn_tranzit_barrier( ( 10281, 7257, -575 ), "veh_t6_civ_microbus_dead", ( 0, 13, 0 ) );
			_spawn_tranzit_barrier( ( 10268, 7294, -569 ), "collision_player_wall_256x256x10", ( 0, 13, 0 ) );
			_spawn_tranzit_barrier( ( 10100, 7238, -575 ), "veh_t6_civ_60s_coupe_dead", ( 0, 52, 0 ) );
			_spawn_tranzit_barrier( ( 10170, 7292, -505 ), "collision_player_wall_128x128x10", ( 0, 140, 0 ) );
			_spawn_tranzit_barrier( ( 10030, 7216, -569 ), "collision_player_wall_256x256x10", ( 0, 49, 0 ) );
			_spawn_tranzit_barrier( ( 10563, 8630, -344 ), "collision_player_wall_256x256x10", ( 0, 270, 0 ) );
			break;
		case "cornfield":
			_spawn_tranzit_barrier( ( 10190, 135, -159 ), "veh_t6_civ_movingtrk_cab_dead", ( 0, 172, 0 ) );
			_spawn_tranzit_barrier( ( 10100, 100, -159 ), "collision_player_wall_512x512x10", ( 0, 172, 0 ) );
			_spawn_tranzit_barrier( ( 10100, -1800, -217 ), "veh_t6_civ_bus_zombie", ( 0, 126, 0 ), 1 );
			_spawn_tranzit_barrier( ( 10045, -1607, -181 ), "collision_player_wall_512x512x10", ( 0, 126, 0 ) );
			break;
	}
}

create_spawner_list( zkeys )
{
	level.zombie_spawn_locations = [];
	level.inert_locations = [];
	level.enemy_dog_locations = [];
	level.zombie_screecher_locations = [];
	level.zombie_avogadro_locations = [];
	level.quad_locations = [];
	level.zombie_leaper_locations = [];
	level.zombie_astro_locations = [];
	level.zombie_brutus_locations = [];
	level.zombie_mechz_locations = [];
	level.zombie_napalm_locations = [];
	for ( z = 0; z < zkeys.size; z++ )
	{
		zone = level.zones[ zkeys[ z ] ];
		if ( zone.is_enabled && zone.is_active && zone.is_spawning_allowed )
		{
			i = 0;
			while ( i < zone.spawn_locations.size )
			{
				if ( !is_true( zone.spawn_locations[ i ].checked ) )
				{
					if ( zone.spawn_locations[ i ].origin == ( 8394, -2545, -205.16 ) )
					{
						zone.spawn_locations[ i ].is_enabled = false;
					}
					else if ( zone.spawn_locations[ i ].origin == ( 10705, 7347, -576 ) )
					{
						zone.spawn_locations[ i ].is_enabled = false;
					}
					else if ( zone.spawn_locations[ i ].origin == ( 10015, 6931, -571.7 ) )
					{
						zone.spawn_locations[ i ].origin = ( 10249.4, 7691.71, -569.875 );
					}
					else if ( zone.spawn_locations[ i ].origin == ( 9339, 6411, -566.9 ) )
					{
						zone.spawn_locations[ i ].origin = ( 9993.29, 7486.83, -582.875 );
					}
					else if ( zone.spawn_locations[ i ].origin == ( 9914, 8408, -576 ) )
					{
						zone.spawn_locations[ i ].origin = ( 9993.29, 7550, -582.875 );
					}
					else if ( zone.spawn_locations[ i ].origin == ( 9429, 5281, -539.6 ) )
					{
						zone.spawn_locations[ i ].is_enabled = false;
					}
					else if ( zone.spawn_locations[ i ].origin == ( 10015, 6931, -571.7 ) )
					{
						zone.spawn_locations[ i ].is_enabled = false;
					}
					else if ( zone.spawn_locations[ i ].origin == ( 13019.1, 7382.5, -754 ) )
					{
						zone.spawn_locations[ i ].is_enabled = false;
					}
					else if ( zone.spawn_locations[ i ].origin == ( -3825, -6576, -52.7 ) )
					{
						zone.spawn_locations[ i ].origin = ( -4061.03, -6754.44, -58.0897 );
					}
					else if ( zone.spawn_locations[ i ].origin == ( -3450, -6559, -51.9 ) )
					{
						zone.spawn_locations[ i ].origin = ( -4060.93, -6968.64, -65.3446 );
					}
					else if ( zone.spawn_locations[ i ].origin == ( -4165, -6098, -64 ) )
					{
						zone.spawn_locations[ i ].origin = ( -4239.78, -6902.81, -57.0494 );
					}
					else if ( zone.spawn_locations[ i ].origin == ( -5058, -5902, -73.4 ) )
					{
						zone.spawn_locations[ i ].origin = ( -4846.77, -6906.38, 54.8145 );
					}
					else if ( zone.spawn_locations[ i ].origin == ( -6462, -7159, -64 ) )
					{
						zone.spawn_locations[ i ].origin = ( -6201.18, -7107.83, -59.7182 );
					}
					else if ( zone.spawn_locations[ i ].origin == ( -5130, -6512, -35.4 ) )
					{
						zone.spawn_locations[ i ].origin = ( -5396.36, -6801.88, -60.0821 );
					}
					else if ( zone.spawn_locations[ i ].origin == ( -6531, -6613, -54.4 ) )
					{
						zone.spawn_locations[ i ].origin = ( -6116.62, -6586.81, -50.8905 );
					}
					else if ( zone.spawn_locations[ i ].origin == ( -5373, -6231, -51.9 ) )
					{
						zone.spawn_locations[ i ].origin = ( -4827.92, -7137.19, -62.9082 );
					}
					else if ( zone.spawn_locations[ i ].origin == ( -5752, -6230, -53.4 ) )
					{
						zone.spawn_locations[ i ].origin = ( -5572.47, -6426, -39.1894 );
					}
					else if ( zone.spawn_locations[ i ].origin == ( -5540, -6508, -42 ) )
					{
						zone.spawn_locations[ i ].origin = ( -5789.51, -6935.81, -57.875 );
					}
					else if ( zone.spawn_locations[ i ].origin == ( -11093 , 393 , 192 ) )
					{
						zone.spawn_locations[ i ].origin = ( -11431.3, -644.496, 192.125 );
					}
					else if ( zone.spawn_locations[ i ].origin == ( -10944, -3846, 221.14 ) )
					{
						zone.spawn_locations[ i ].origin = ( -11351.7, -1988.58, 184.125 );
					}
					else if ( zone.spawn_locations[ i ].origin == ( -11251, -4397, 200.02 ) )
					{
						zone.spawn_locations[ i ].origin = ( -11431.3, -644.496, 192.125 );
					}
					else if ( zone.spawn_locations[ i ].origin == ( -11334 , -5280, 212.7 ) )
					{
						zone.spawn_locations[ i ].origin = ( -11600.6, -1918.41, 192.125 );
						zone.spawn_locations[ i ].script_noteworthy = "riser_location";
					}
					else if (zone.spawn_locations[ i ].origin == ( -10836, 1195, 209.7 ) )
					{
						zone.spawn_locations[ i ].origin = ( -11241.2, -1118.76, 184.125 );
					}
					/*
					else if ( zone.spawn_locations[ i ].origin == ( -10747, -63, 203.8 ) )
					{
						zone.spawn_locations[ i ].is_enabled = 0;
					}
					else if ( zone.spawn_locations[ i ].origin == ( -11347, -3134, 283.9 ) )
					{
						zone.spawn_locations[ i ].is_enabled = 0;
					}
					else if ( zone.spawn_locations[ i ].origin == ( -11447, -3424, 254.2 ) )
					{
						zone.spawn_locations[ i ].is_enabled = 0;
					}
					else if ( zone.spawn_locations[ i ].origin == ( -10761, 155, 236.8 ) )
					{
						zone.spawn_locations[ i ].is_enabled = 0;
					}
					else if ( zone.spawn_locations[ i ].origin == ( -11110, -2921, 195.79 ) )
					{
						zone.spawn_locations[ i ].is_enabled = 0;
					}
					*/
					else if ( zone.spawn_locations[ i ].targetname == "zone_trans_diner_spawners")
					{
						zone.spawn_locations[ i ].is_enabled = false;
					}
					else
					{
						zone.spawn_locations[ i ].is_enabled = true;
					}
					zone.spawn_locations[ i ].checked = true;
				}
				if ( !is_true( zone.spawn_locations[ i ].is_enabled ) )
				{
					i++;
					continue;
				}
				level.zombie_spawn_locations[ level.zombie_spawn_locations.size ] = zone.spawn_locations[ i ];
				i++;
			}
			x = 0;
			while ( x < zone.dog_locations.size )
			{
				if ( !is_true( zone.dog_locations[ x ].checked ) )
				{

					if ( zone.dog_locations[ x ].origin == ( -11428.5, 764.5, 220 ) )
					{
						zone.dog_locations[ x ].origin = ( -10952, -1950, 220 );
					}
					else if ( zone.dog_locations[ x ].origin == ( -11228.5, -4553, 205.7 ) )
					{
						zone.dog_locations[ x ].origin = ( -11550, -2372, 220 );
					}
					else if ( zone.dog_locations[ x ].origin == ( -10476.5, -3987, 220 ) )
					{
						zone.dog_locations[ x ].origin = ( -11518, -1088, 220 );
					}
					else if ( zone.dog_locations[ x ].origin == ( 8627.5, 1092.5, -145.1 ) )
					{
						zone.dog_locations[ x ].origin = ( 10465, -710, -203.2 );
					}
					else if ( zone.dog_locations[ x ].origin == ( -6180, -5698, -30.7 ) )
					{
						zone.dog_locations[ x ].is_enabled = false;
					}
					else if ( zone.dog_locations[ x ].origin == ( -4989, -5696, -68.9 ) )
					{
						zone.dog_locations[ x ].is_enabled = false;
					}
					else if ( zone.dog_locations[ x ].origin == ( -5295, -5557, -61.5 ) )
					{
						zone.dog_locations[ x ].is_enabled = false;
					}
					else if ( zone.dog_locations[ x ].origin == ( -5752, -6230, -49.4 ) )
					{
						zone.dog_locations[ x ].is_enabled = false;
					}
					else if ( zone.dog_locations[ x ].origin == ( -5888, -6110, -68.3 ) )
					{
						zone.dog_locations[ x ].is_enabled = false;
					}
					else if ( zone.dog_locations[ x ].origin == ( -6366, -6381, -36.7 ) )
					{						
						zone.dog_locations[ x ].is_enabled = false;
					}
					else if ( zone.dog_locations[ x ].origin == ( -4165, -6098, -64 ) )
					{
						zone.dog_locations[ x ].is_enabled = false;
					}
					else if ( zone.dog_locations[ x ].origin == ( -3919, -6425, -32.3 ) )
					{
						zone.dog_locations[ x ].is_enabled = false;
					}
					else if ( zone.dog_locations[ x ].origin == (-4274, -5965, -70.9) )
					{
						zone.dog_locations[ x ].is_enabled = false;
					}
					else if ( zone.dog_locations[ x ].origin == ( 10434, 8453, -568 ) )
					{
						zone.dog_locations[ x ].is_enabled = false;
					}
					else
					{
						zone.dog_locations[ x ].is_enabled = true;
					}
					zone.dog_locations[ x ].checked = true;
				}
				if ( !is_true( zone.dog_locations[ x ].is_enabled ) )
				{
					x++;
					continue;
				}
				level.enemy_dog_locations[ level.enemy_dog_locations.size ] = zone.dog_locations[ x ];
				x++;
			}
		}
	}
}
turn_power_on_and_open_doors()
{
	level.local_doors_stay_open = 1;
	level.power_local_doors_globally = 1;
	flag_set( "power_on" );
	level setclientfield( "zombie_power_on", 1 );
	zombie_doors = getentarray( "zombie_door", "targetname" );
	foreach ( door in zombie_doors )
	{
		if ( isDefined( door.script_noteworthy ) && door.script_noteworthy == "electric_door" )
		{
			door notify( "power_on" );
		}
		if ( isDefined( door.script_noteworthy ) && door.script_noteworthy == "local_electric_door" )
		{
			if ( getDvar( "ui_zm_mapstartlocation" ) != "power" )
			{
				door notify( "local_power_on" );
			}
		}
	}
}

falling_death_init()
{
	trig = getent( "transit_falling_death", "targetname" );
	if ( isDefined( trig ) )
	{
		while ( true )
		{
			trig waittill( "trigger", who );
			if ( !is_true( who.insta_killed ) )
			{
				who thread insta_kill_player();
			}
		}
	}
}

insta_kill_player()
{
	self endon( "disconnect" );
	if ( is_true( self.insta_killed ) )
	{
		return;
	}
	self maps\mp\zombies\_zm_buildables::player_return_piece_to_original_spawn();
	if ( is_player_killable( self ) )
	{
		self.insta_killed = 1;
		in_last_stand = 0;
		if ( self maps\mp\zombies\_zm_laststand::player_is_in_laststand() )
		{
			in_last_stand = 1;
		}
		if ( getnumconnectedplayers() == 1 )
		{
			if ( isDefined( self.lives ) && self.lives > 0 )
			{
				self.waiting_to_revive = 1;
				points = getstruct( "zone_pcr", "script_noteworthy" );
				spawn_points = getstructarray( points.target, "targetname" );
				point = spawn_points[ 0 ];
				self dodamage( self.health + 1000, ( 0, 0, 0 ) );
				maps\mp\_visionset_mgr::vsmgr_activate( "overlay", "zm_transit_burn", self, 1, level.zm_transit_burn_max_duration );
				wait 0.5;
				self freezecontrols( 1 );
				wait 0.25;
				self setorigin( point.origin + vectorScale( ( 0, 0, 1 ), 20 ) );
				self.angles = point.angles;
				if ( in_last_stand )
				{
					flag_set( "instant_revive" );
					wait_network_frame();
					flag_clear( "instant_revive" );
				}
				else
				{
					self thread maps\mp\zombies\_zm_laststand::auto_revive( self );
					self.waiting_to_revive = 0;
					self.solo_respawn = 0;
					self.lives = 0;
				}
				self freezecontrols( 0 );
				self.insta_killed = 0;
			}
			else
			{
				self dodamage( self.health + 1000, ( 0, 0, 0 ) );
				maps\mp\_visionset_mgr::vsmgr_activate( "overlay", "zm_transit_burn", self, 2, level.zm_transit_burn_max_duration );
			}
		}
		else
		{
			self dodamage( self.health + 1000, ( 0, 0, 0 ) );
			maps\mp\_visionset_mgr::vsmgr_activate( "overlay", "zm_transit_burn", self, 1, level.zm_transit_burn_max_duration );
			wait_network_frame();
			self.bleedout_time = 0;
		}
		self notify( "burned" );
		self.insta_killed = 0;
	}
}

is_player_killable( player, checkignoremeflag )
{
	if ( !isDefined( player ) )
	{
		return 0;
	}
	if ( !isalive( player ) )
	{
		return 0;
	}
	if ( !isplayer( player ) )
	{
		return 0;
	}
	if ( player.sessionstate == "spectator" )
	{
		return 0;
	}
	if ( player.sessionstate == "intermission" )
	{
		return 0;
	}
	if ( isDefined( checkignoremeflag ) && player.ignoreme )
	{
		return 0;
	}
	return 1;
}