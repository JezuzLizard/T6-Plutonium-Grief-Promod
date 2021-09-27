#include maps/mp/zombies/_load;
#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/zombies/_zm_zonemgr;
#include maps/mp/gametypes_zm/_zm_gametype;
#include maps/mp/zombies/_zm_utility;

register_perk_struct( perk_name, perk_model, perk_angles, perk_coordinates )
{
	if ( getDvar( "g_gametype" ) == "zgrief" && perk_name == "specialty_scavenger" )
	{
		return;
	}
	perk_struct = spawnStruct();
	perk_struct.script_noteworthy = perk_name;
	perk_struct.model = perk_model;
	perk_struct.angles = perk_angles;
	perk_struct.origin = perk_coordinates;
	perk_struct.targetname = "zm_perk_machine";
	add_struct( perk_struct );
}

_get_perk_script_string_for_location( location, gametype )
{ 
	string = gametype + "_" + "perks" + "_" + location;
	return string;
}

_register_map_initial_spawnpoint( spawnpoint_coordinates, spawnpoint_angles ) //custom function
{
	spawnpoint_struct = spawnStruct();
	spawnpoint_struct.origin = spawnpoint_coordinates;
	if ( isDefined( spawnpoint_angles ) )
	{
		spawnpoint_struct.angles = spawnpoint_angles;
	}
	else 
	{
		spawnpoint_struct.angles = ( 0, 0, 0 );
	}
	spawnpoint_struct.radius = 32;
	spawnpoint_struct.script_noteworthy = "initial_spawn";
	spawnpoint_struct.script_int = 2048;
	spawnpoint_struct.script_string = _get_spawnpoint_script_string_for_location( getDvar( "ui_zm_mapstartlocation" ), getDvar( "g_gametype" ) );
	spawnpoint_struct.locked = 0;
	player_respawn_point_size = level.struct_class_names[ "targetname" ][ "player_respawn_point" ].size;
	player_initial_spawnpoint_size = level.struct_class_names[ "script_noteworthy" ][ "initial_spawn" ].size;
	level.struct_class_names[ "targetname" ][ "player_respawn_point" ][ player_respawn_point_size ] = spawnpoint_struct;
	level.struct_class_names[ "script_noteworthy" ][ "initial_spawn" ][ player_initial_spawnpoint_size ] = spawnpoint_struct;
}

_get_spawnpoint_script_string_for_location( location, gametype )
{
	string = gametype + "_" + location;
	return string;
}

cast_to_vector( vector_string )
{
	keys = strTok( vector_string, "," );
	vector_array = [];
	for ( i = 0; i < keys.size; i++ )
	{
		vector_array[ i ] = float( keys[ i ] ); 
	}
	vector = ( vector_array[ 0 ], vector_array[ 1 ], vector_array[ 2 ] );
	return vector;
}

wallbuy( weapon_angles, weapon_coordinates, chalk_fx, weapon_name, weapon_model, target, targetname )
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
	maps/mp/zombies/_zm_unitrigger::unitrigger_force_per_player_triggers( unitrigger_stub, 1 );
	if ( is_melee_weapon( weapon_name ) )
	{
		if ( weapon_name == "tazer_knuckles_zm" && isDefined( level.taser_trig_adjustment ) )
		{
			unitrigger_stub.origin += level.taser_trig_adjustment;
		}
		maps/mp/zombies/_zm_unitrigger::register_static_unitrigger( unitrigger_stub, ::melee_weapon_think );
	}
	else if ( weapon_name == "claymore_zm" )
	{
		unitrigger_stub.prompt_and_visibility_func = ::claymore_unitrigger_update_prompt;
		maps/mp/zombies/_zm_unitrigger::register_static_unitrigger( unitrigger_stub, ::buy_claymores );
	}
	else
	{
		unitrigger_stub.prompt_and_visibility_func = ::wall_weapon_update_prompt;
		maps/mp/zombies/_zm_unitrigger::register_static_unitrigger( unitrigger_stub, ::weapon_spawn_think );
	}
	tempmodel delete();
    thread playchalkfx( chalk_fx, weapon_coordinates, weapon_angles );
}

playchalkfx( effect, origin, angles ) //custom function
{
	while ( 1 )
	{
		fx = SpawnFX( level._effect[ effect ], origin, AnglesToForward( angles ), AnglesToUp( angles ) );
		TriggerFX( fx );
		level waittill( "connected", player );
		fx Delete();
	}
}

barrier( barrier_coordinates, barrier_model, barrier_angles, not_solid ) //custom function
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

add_struct_location_gamemode_func( gametype, location, func )
{
	if ( !isDefined( level.add_struct_gamemode_location_funcs ) )
	{
		level.add_struct_gamemode_location_funcs = [];
	}
	if ( !isDefined( level.add_struct_gamemode_location_funcs[ gametype ] ) )
	{
		level.add_struct_gamemode_location_funcs[ gametype ] = [];
	}
	if ( !isDefined( level.add_struct_gamemode_location_funcs[ gametype ][ location ] ) )
	{
		level.add_struct_gamemode_location_funcs[ gametype ][ location ] = [];
	}
	level.add_struct_gamemode_location_funcs[ gametype ][ location ][ level.add_struct_gamemode_location_funcs[ gametype ][ location ].size ] = func;
}

get_zone_magic_boxes( zone_name )
{
	if ( isDefined( zone_name ) && !zone_is_enabled( zone_name ) )
	{
		return undefined;
	}
	zone = level.zones[ zone_name ];
	return zone.magic_boxes;
}

get_zone_zbarriers( zone_name )
{
	if ( isDefined( zone_name ) && !zone_is_enabled( zone_name ) )
	{
		return undefined;
	}
	zone = level.zones[ zone_name ];
	return zone.zbarriers;
}

deactivate_initial_barrier_goals()
{
	special_goals = getstructarray( "exterior_goal", "targetname" );
	for ( i = 0; i < special_goals.size; i++ )
	{
		if ( isdefined( special_goals[ i ].script_noteworthy ) )
		{
			special_goals[ i ].is_active = 0;
			special_goals[ i ] trigger_off();
		}
	}
}

zone_init( zone_name )
{
	if ( isDefined( level.zones[ zone_name ] ) )
	{
		return;
	}
	level.zones[ zone_name ] = spawnstruct();
	zone = level.zones[ zone_name ];
	zone.is_enabled = 0; 
	zone.is_occupied = 0; 
	zone.is_active = 0;
	zone.adjacent_zones = [];
	zone.is_spawning_allowed = 0;
	spawn_points = maps/mp/gametypes_zm/_zm_gametype::get_player_spawns_for_gametype();
	for( i = 0; i < spawn_points.size; i++ )
	{
		if ( spawn_points[ i ].script_noteworthy == zone_name )
		{
			spawn_points[ i ].locked = 0;
		}
	}
	zone.volumes = [];
	volumes = getentarray( zone_name, "targetname" );
	i = 0;
	for ( i = 0; i < volumes.size; i++ )
	{
		if ( volumes[ i ].classname == "info_volume" )
		{
			zone.volumes[ zone.volumes.size ] = volumes[ i ];
		}
	}
	if ( isdefined( zone.volumes[ 0 ].target ) )
	{
		spots = getstructarray( zone.volumes[ 0 ].target, "targetname" );
		if ( isDefined( level.zone_spawn_locations_override ) )
		{
			spots = [[ level.zone_spawn_locations_override ]]( spots, zone_name );
		}
		zone.spawn_locations = [];
		zone.inert_locations = [];
		zone.leaper_locations = [];
		zone.brutus_locations = [];
		zone.mechz_locations = [];
		zone.zbarriers = [];
		zone.magic_boxes = [];
		barricades = getstructarray( "exterior_goal", "targetname" );
		box_locs = getstructarray( "treasure_chest_use", "targetname" );
		for (i = 0; i < spots.size; i++)
		{
			spots[ i ].zone_name = zone_name;
			if ( !is_true( spots[ i ].is_blocked ) )
			{
				spots[ i ].is_enabled = 1;
			}
			else
			{
				spots[ i ].is_enabled = 0;
			}
			tokens = strtok( spots[ i ].script_noteworthy, " " );
			foreach ( token in tokens )
			{
				if ( token == "inert_location" )
				{
					zone.inert_locations[ zone.inert_locations.size ] = spots[ i ];
				}
				else if ( token == "leaper_location" )
				{
					zone.leaper_locations[ zone.leaper_locations.size ] = spots[ i ];
				}
				else if ( token == "brutus_location" )
				{
					zone.brutus_locations[ zone.brutus_locations.size ] = spots[ i ];
				}
				else if ( token == "mechz_location" )
				{
					zone.mechz_locations[ zone.mechz_locations.size ] = spots[ i ];
				}
				else
				{
					zone.spawn_locations[ zone.spawn_locations.size ] = spots[ i ];
				}
			}
			if ( isdefined( spots[ i ].script_string ) )
			{
				barricade_id = spots[ i ].script_string;
				for ( k = 0; k < barricades.size; k++ )
				{
					if ( isdefined( barricades[ k ].script_string ) && barricades[ k ].script_string == barricade_id )
					{
						nodes = getnodearray( barricades[ k ].target, "targetname" );
						for ( j = 0; j < nodes.size; j++ )
						{
							if ( isdefined( nodes[ j ].type ) && nodes[ j ].type == "Begin" )
							{
								spots[ i ].target = nodes[ j ].targetname;
							}
						}
					}
				}
			}
		}
		for ( i = 0; i < barricades.size; i++ )
		{
			targets = getentarray( barricades[ i ].target, "targetname" );
			for ( j = 0; j < targets.size; j++ )
			{
				if ( targets[ j ] iszbarrier() && isdefined( targets[ j ].script_string ) && targets[ j ].script_string == zone_name )
				{
					zone.zbarriers[ zone.zbarriers.size ] = targets[ j ];
				}
			}
		}
		for ( i = 0; i < box_locs.size; i++ )
		{
			chest_ent = getent( box_locs[ i ].script_noteworthy + "_zbarrier", "script_noteworthy" );
			if ( chest_ent entity_in_zone( zone_name, 1 ) )
			{
				zone.magic_boxes[zone.magic_boxes.size] = box_locs[ i ];
			}
		}
	}
}

manage_zones( initial_zone )
{
	map = getDvar( "mapname" );
	location = getDvar( "ui_zm_mapstartlocation" ); 
	if ( array_validate( level.location_zones ) )
	{
		for ( i = 0; i < level.location_zones.size; i++ )
		{
			add_to_array( initial_zone, level.location_zones[ i ], false );
		}
	}
	deactivate_initial_barrier_goals();
	zone_choke = 0;
	spawn_points = maps/mp/gametypes_zm/_zm_gametype::get_player_spawns_for_gametype();
	for ( i = 0; i < spawn_points.size; i++ )
	{
		spawn_points[ i ].locked = 1;
	}
	if ( isDefined( level.zone_manager_init_func ) )
	{
		[[ level.zone_manager_init_func ]]();
	}
	if ( isarray( initial_zone ) )
	{
		for ( i = 0; i < initial_zone.size; i++ )
		{
			zone_init( initial_zone[ i ] );
			enable_zone( initial_zone[ i ] );
		}
	}
	else
	{
		zone_init( initial_zone );
		enable_zone( initial_zone );
	}
	setup_zone_flag_waits();
	zkeys = getarraykeys( level.zones );
	level.zone_keys = zkeys;
	level.newzones = [];
	for ( z = 0; z < zkeys.size; z++ )
	{
		level.newzones[ zkeys[ z ] ] = spawnstruct();
	}
	oldzone = undefined;
	flag_set( "zones_initialized" );
	flag_wait( "begin_spawning" );
	while ( getDvarInt( "noclip" ) == 0 || getDvarInt( "notarget" ) != 0 )
	{	
		for( z = 0; z < zkeys.size; z++ )
		{
			level.newzones[ zkeys[ z ] ].is_active = 0;
			level.newzones[ zkeys[ z ] ].is_occupied = 0;
		}
		a_zone_is_active = 0;
		a_zone_is_spawning_allowed = 0;
		level.zone_scanning_active = 1;
		z = 0;
		while ( z < zkeys.size )
		{
			zone = level.zones[ zkeys[ z ] ];
			newzone = level.newzones[ zkeys[ z ] ];
			if( !zone.is_enabled )
			{
				z++;
				continue;
			}
			if ( isdefined(level.zone_occupied_func ) )
			{
				newzone.is_occupied = [[ level.zone_occupied_func ]]( zkeys[ z ] );
			}
			else
			{
				newzone.is_occupied = player_in_zone( zkeys[ z ] );
			}
			if ( newzone.is_occupied )
			{
				newzone.is_active = 1;
				a_zone_is_active = 1;
				if ( zone.is_spawning_allowed )
				{
					a_zone_is_spawning_allowed = 1;
				}
				if ( !isdefined(oldzone) || oldzone != newzone )
				{
					level notify( "newzoneActive", zkeys[ z ] );
					oldzone = newzone;
				}
				azkeys = getarraykeys( zone.adjacent_zones );
				for ( az = 0; az < zone.adjacent_zones.size; az++ )
				{
					if ( zone.adjacent_zones[ azkeys[ az ] ].is_connected && level.zones[ azkeys[ az ] ].is_enabled )
					{
						level.newzones[ azkeys[ az ] ].is_active = 1;
						if ( level.zones[ azkeys[ az ] ].is_spawning_allowed )
						{
							a_zone_is_spawning_allowed = 1;
						}
					}
				}
			}
			zone_choke++;
			if ( zone_choke >= 3 )
			{
				zone_choke = 0;
				wait 0.05;
			}
			z++;
		}
		level.zone_scanning_active = 0;
		for ( z = 0; z < zkeys.size; z++ )
		{
			level.zones[ zkeys[ z ] ].is_active = level.newzones[ zkeys[ z ] ].is_active;
			level.zones[ zkeys[ z ] ].is_occupied = level.newzones[ zkeys[ z ] ].is_occupied;
		}
		if ( !a_zone_is_active || !a_zone_is_spawning_allowed )
		{
			if ( isarray( initial_zone ) )
			{
				level.zones[ initial_zone[ 0 ] ].is_active = 1;
				level.zones[ initial_zone[ 0 ] ].is_occupied = 1;
				level.zones[ initial_zone[ 0 ] ].is_spawning_allowed = 1;
			}
			else
			{
				level.zones[ initial_zone ].is_active = 1;
				level.zones[ initial_zone ].is_occupied = 1;
				level.zones[ initial_zone ].is_spawning_allowed = 1;
			}
		}
		[[ level.create_spawner_list_func ]]( zkeys );
		level.active_zone_names = maps/mp/zombies/_zm_zonemgr::get_active_zone_names();
		wait 1;
	}
}