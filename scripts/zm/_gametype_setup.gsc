#include maps\mp\zombies\_load;
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_zonemgr;
#include maps\mp\gametypes_zm\_zm_gametype;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_weapons;
#include maps\mp\zombies\_zm_melee_weapon;
#include maps\mp\zombies\_zm_weap_claymore;
#include maps\mp\zombies\_zm_weap_ballistic_knife;
#include maps\mp\zombies\_zm_equipment;
#include maps\mp\zombies\_zm_magicbox;
#include maps\mp\zombies\_zm_unitrigger;

main()
{
	replaceFunc( common_scripts\utility::struct_class_init, ::struct_class_init_override );
	level.perk_machine_targetname = "zm_perk_machine";
	if ( getDvar( "mapname" ) == "zm_highrise" )
	{
		level.perk_machine_targetname = "zm_perk_machine_override";
	}
}

struct_class_init_override()
{
	level.struct_class_names = [];
	level.struct_class_names[ "target" ] = [];
	level.struct_class_names[ "targetname" ] = [];
	level.struct_class_names[ "script_noteworthy" ] = [];
	level.struct_class_names[ "script_linkname" ] = [];
	level.struct_class_names[ "script_unitrigger_type" ] = [];
	foreach ( s_struct in level.struct )
	{
		add_struct( s_struct );
	}
	gametype = getDvar( "g_gametype" );
	location = getDvar( "ui_zm_mapstartlocation" );
	if ( array_validate( level.add_struct_gamemode_location_funcs ) )
	{
		if ( array_validate( level.add_struct_gamemode_location_funcs[ gametype ] ) )
		{
			if ( array_validate( level.add_struct_gamemode_location_funcs[ gametype ][ location ] ) )
			{
				for ( i = 0; i < level.add_struct_gamemode_location_funcs[ gametype ][ location ].size; i++ )
				{
					[[ level.add_struct_gamemode_location_funcs[ gametype ][ location ][ i ] ]]();
				}
			}
		}
	}
	scripts\zm\promod_grief\_gamerules::override_perk_struct_locations();
}

register_perk_struct( perk_name, perk_model, perk_angles, perk_coordinates )
{
	if ( perk_name == "specialty_scavenger" )
	{
		return;
	}
	perk_struct = spawnStruct();
	perk_struct.script_noteworthy = perk_name;
	perk_struct.model = perk_model;
	perk_struct.angles = perk_angles;
	perk_struct.origin = perk_coordinates;
	perk_struct.targetname = level.perk_machine_targetname;
	if ( perk_name == "specialty_weapupgrade" )
	{
		flag_struct = spawnStruct();
		flag_struct.targetname = "weapupgrade_flag_targ";
		flag_struct.model = "zombie_sign_please_wait";
		flag_struct.angles = perk_angles + ( 0, 180, 180 );
		flag_struct.origin = perk_coordinates + ( anglesToForward( perk_angles ) * 29 ) + ( anglesToRight( perk_angles ) * -13.5 ) + ( anglesToUp( perk_angles ) * 49.5 );
		perk_struct.target = flag_struct.targetname;
		add_struct( flag_struct );
	}
	add_struct( perk_struct );
}

//Parse restrictions here for perks.
add_struct( s_struct )
{
	if ( isDefined( s_struct.targetname ) )
	{
		if ( s_struct.targetname == level.perk_machine_targetname && level.grief_restrictions[ "perks" ].enabled && array_validate( level.grief_restrictions[ "perks" ].list ) )
		{
			if ( isDefined( s_struct.script_noteworthy ) )
			{
				if ( scripts\zm\promod_grief\_gamerules::is_perk_restricted( s_struct.script_noteworthy ) )
				{
					scripts\zm\promod_grief\_gamerules::kill_perk_machine_thread( s_struct.script_noteworthy );
					return;
				}
			}
		}
		if ( !isDefined( level.struct_class_names[ "targetname" ][ s_struct.targetname ] ) )
		{
			level.struct_class_names[ "targetname" ][ s_struct.targetname ] = [];
		}
		size = level.struct_class_names[ "targetname" ][ s_struct.targetname ].size;
		level.struct_class_names[ "targetname" ][ s_struct.targetname ][ size ] = s_struct;
	}
	if ( isDefined( s_struct.script_noteworthy ) )
	{
		if ( !isDefined( level.struct_class_names[ "script_noteworthy" ][ s_struct.script_noteworthy ] ) )
		{
			level.struct_class_names[ "script_noteworthy" ][ s_struct.script_noteworthy ] = [];
		}
		size = level.struct_class_names[ "script_noteworthy" ][ s_struct.script_noteworthy ].size;
		level.struct_class_names[ "script_noteworthy" ][ s_struct.script_noteworthy ][ size ] = s_struct;
	}
	if ( isDefined( s_struct.target ) )
	{
		if ( !isDefined( level.struct_class_names[ "target" ][ s_struct.target ] ) )
		{
			level.struct_class_names[ "target" ][ s_struct.target ] = [];
		}
		size = level.struct_class_names[ "target" ][ s_struct.target ].size;
		level.struct_class_names[ "target" ][ s_struct.target ][ size ] = s_struct;
	}
	if ( isDefined( s_struct.script_linkname ) )
	{
		level.struct_class_names[ "script_linkname" ][ s_struct.script_linkname ][ 0 ] = s_struct;
	}
	if ( isDefined( s_struct.script_unitrigger_type ) )
	{
		if ( !isDefined( level.struct_class_names[ "script_unitrigger_type" ][ s_struct.script_unitrigger_type ] ) )
		{
			level.struct_class_names[ "script_unitrigger_type" ][ s_struct.script_unitrigger_type ] = [];
		}
		size = level.struct_class_names[ "script_unitrigger_type" ][ s_struct.script_unitrigger_type ].size;
		level.struct_class_names[ "script_unitrigger_type" ][ s_struct.script_unitrigger_type ][ size ] = s_struct;
	}
}

register_map_initial_spawnpoint( spawnpoint_coordinates, spawnpoint_angles, script_int ) //custom function
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
	if ( !isDefined( script_int ) )
	{
		script_int = 2048;
	}
	spawnpoint_struct.script_int = script_int;
	spawnpoint_struct.script_string = getDvar( "g_gametype" ) + "_" + getDvar( "ui_zm_mapstartlocation" );
	spawnpoint_struct.locked = 0;
	player_respawn_point_size = level.struct_class_names[ "targetname" ][ "player_respawn_point" ].size;
	player_initial_spawnpoint_size = level.struct_class_names[ "script_noteworthy" ][ "initial_spawn" ].size;
	level.struct_class_names[ "targetname" ][ "player_respawn_point" ][ player_respawn_point_size ] = spawnpoint_struct;
	level.struct_class_names[ "script_noteworthy" ][ "initial_spawn" ][ player_initial_spawnpoint_size ] = spawnpoint_struct;
}

wallbuy( weapon_name, target, targetname, origin, angles )
{
	unitrigger_stub = spawnstruct();
	unitrigger_stub.origin = origin;
	unitrigger_stub.angles = angles;

	model_name = undefined;
	if ( weapon_name == "claymore_zm" )
	{
		model_name = "t6_wpn_claymore_world"; // getWeaponModel for claymore is wrong model
	}

	wallmodel = spawn_weapon_model( weapon_name, model_name, origin, angles );
	wallmodel.targetname = target;
	wallmodel useweaponhidetags( weapon_name );
	wallmodel hide();

	absmins = wallmodel getabsmins();
	absmaxs = wallmodel getabsmaxs();
	bounds = absmaxs - absmins;

	unitrigger_stub.script_length = 64;
	unitrigger_stub.script_width = bounds[ 1 ];
	unitrigger_stub.script_height = bounds[ 2 ];
	unitrigger_stub.target = target;
	unitrigger_stub.targetname = targetname;
	unitrigger_stub.cursor_hint = "HINT_NOICON";

	// move model foreward so it always shows in front of chalk
	move_amount = anglesToRight( wallmodel.angles ) * -0.3;
	wallmodel.origin += move_amount;
	unitrigger_stub.origin += move_amount;

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
		melee_weapon = undefined;
		foreach(melee_weapon in level._melee_weapons)
		{
			if(melee_weapon.weapon_name == weapon_name)
			{
				break;
			}
		}

		if(isDefined(melee_weapon))
		{
			unitrigger_stub.cost = melee_weapon.cost;
			unitrigger_stub.hint_string = melee_weapon.hint_string;
			unitrigger_stub.weapon_name = melee_weapon.weapon_name;
			unitrigger_stub.flourish_weapon_name = melee_weapon.flourish_weapon_name;
			unitrigger_stub.ballistic_weapon_name = melee_weapon.ballistic_weapon_name;
			unitrigger_stub.ballistic_upgraded_weapon_name = melee_weapon.ballistic_upgraded_weapon_name;
			unitrigger_stub.vo_dialog_id = melee_weapon.vo_dialog_id;
			unitrigger_stub.flourish_fn = melee_weapon.flourish_fn;

			if(is_true(level.disable_melee_wallbuy_icons))
			{
				unitrigger_stub.cursor_hint = "HINT_NOICON";
				unitrigger_stub.cursor_hint_weapon = undefined;
			}
			else
			{
				unitrigger_stub.cursor_hint = "HINT_WEAPON";
				unitrigger_stub.cursor_hint_weapon = melee_weapon.weapon_name;
			}
		}

		if(weapon_name == "tazer_knuckles_zm")
		{
			unitrigger_stub.origin += anglesToForward(angles) * -7;
			unitrigger_stub.origin += anglesToRight(angles) * -2;
		}

		wallmodel.origin += anglesToForward(angles) * -8; // _zm_melee_weapon::melee_weapon_show moves this back

		maps\mp\zombies\_zm_unitrigger::register_static_unitrigger( unitrigger_stub, ::melee_weapon_think );
	}
	else
	{
		unitrigger_stub.prompt_and_visibility_func = ::wall_weapon_update_prompt;
		maps\mp\zombies\_zm_unitrigger::register_static_unitrigger( unitrigger_stub, ::weapon_spawn_think );
	}

	chalk_fx = weapon_name + "_fx";
	level thread playchalkfx( chalk_fx, origin, angles );
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

manage_zones_override( initial_zone )
{
	deactivate_initial_barrier_goals();
	zone_choke = 0;
	spawn_points = maps\mp\gametypes_zm\_zm_gametype::get_player_spawns_for_gametype();

	for ( i = 0; i < spawn_points.size; i++ )
	{
		spawn_points[i].locked = 1;
	}

	if ( isdefined( level.zone_manager_init_func ) )
		[[ level.zone_manager_init_func ]]();
	if ( isarray( initial_zone ) )
	{
		for ( i = 0; i < initial_zone.size; i++ )
		{
			zone_init( initial_zone[i] );
			enable_zone( initial_zone[i] );
		}
	}
	else
	{
		zone_init( initial_zone );
		enable_zone( initial_zone );
	}
	if ( isDefined( level.custom_location_zones ) )
	{
		foreach ( zone in level.custom_location_zones )
		{
			zone_init( zone );
			enable_zone( zone );
		}
	}
	setup_zone_flag_waits();
	zkeys = getarraykeys( level.zones );
	level.zone_keys = zkeys;
	level.newzones = [];

	for ( z = 0; z < zkeys.size; z++ )
		level.newzones[ zkeys[ z ] ] = spawnstruct();

	oldzone = undefined;
	flag_set( "zones_initialized" );
	flag_wait( "begin_spawning" );
	while ( true )
	{
		for ( z = 0; z < zkeys.size; z++ )
		{
			level.newzones[ zkeys[ z ] ].is_active = 0;
			level.newzones[ zkeys[ z ] ].is_occupied = 0;
		}

		a_zone_is_active = 0;
		a_zone_is_spawning_allowed = 0;
		level.zone_scanning_active = 1;

		z = 0;
		while ( z < zkeys.size  )
		{
			zone = level.zones[ zkeys[ z ] ];
			newzone = level.newzones[ zkeys[ z ] ];

			if ( !zone.is_enabled )
			{
				z++;
				continue;
			}
			if ( isdefined( level.zone_occupied_func ) )
				newzone.is_occupied = [[ level.zone_occupied_func ]]( zkeys[z] );
			else
				newzone.is_occupied = player_in_zone( zkeys[z] );

			if ( newzone.is_occupied )
			{
				newzone.is_active = 1;
				a_zone_is_active = 1;

				if ( zone.is_spawning_allowed )
					a_zone_is_spawning_allowed = 1;

				if ( !isdefined( oldzone ) || oldzone != newzone )
				{
					level notify( "newzoneActive", zkeys[z] );
					oldzone = newzone;
				}

				azkeys = getarraykeys( zone.adjacent_zones );

				for ( az = 0; az < zone.adjacent_zones.size; az++ )
				{
					if ( zone.adjacent_zones[ azkeys[ az ] ].is_connected && level.zones[ azkeys[ az ] ].is_enabled )
					{
						level.newzones[ azkeys[ az ] ].is_active = 1;

						if ( level.zones[ azkeys[ az ] ].is_spawning_allowed )
							a_zone_is_spawning_allowed = 1;
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
				level.zones[initial_zone].is_active = 1;
				level.zones[initial_zone].is_occupied = 1;
				level.zones[initial_zone].is_spawning_allowed = 1;
			}
		}

		[[ level.create_spawner_list_func ]]( zkeys );
		level.active_zone_names = maps\mp\zombies\_zm_zonemgr::get_active_zone_names();
		wait 1;
	}
}

//zm_tomb only
spawn_wunderfizz( origin, angles )
{
	newWunderfizz1 = spawn( "script_model", origin );
	newWunderfizz1.angles = angles;
	newWunderfizz1.targetname = "random_perk_machine";
	newWunderfizz1 setmodel("p6_zm_vending_diesel_magic");
	newWunderfizz1.script_string = "middle_bunker";
	newWunderfizz1.is_locked = 0;
	collision1 = spawn( "script_model", origin );
	collision1 setmodel( "collision_clip_64x64x256" );
	collision1.angles = angles;
	collision1.targetname = "random_perk_machine_middle_bunker_collision";
	collision1 ghost();
}