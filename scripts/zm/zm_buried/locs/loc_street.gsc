#include maps/mp/gametypes_zm/_zm_gametype;
#include maps/mp/zombies/_zm_buildables;
#include maps/mp/zombies/_zm_magicbox;
#include maps/mp/zombies/_zm_equip_subwoofer;
#include maps/mp/zombies/_zm_equip_springpad;
#include maps/mp/zombies/_zm_equip_turbine;
#include maps/mp/zm_buried_buildables;
#include maps/mp/zm_buried_gamemodes;
#include maps/mp/zombies/_zm_race_utility;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_unitrigger;
#include maps/mp/zombies/_zm_weap_claymore;
#include maps/mp/zombies/_zm_melee_weapon;
#include maps/mp/zombies/_zm;
#include scripts/zm/zm_buried/locs/location_common;

struct_init()
{
	coordinates = array( ( -832, -153, 132 ), ( -718, 73, -23 ), ( -1034, 210, -23 ), ( -1170, 425, 8 ),
							( -356, 169, 10 ), ( 54, 156, 10 ), ( 40, 296, -28 ), ( -94, 573, -23 ) );
	angles = array( ( 0, 68, 0 ), ( 0, 75, 0 ), ( 0, 40, 0 ), ( 0, -1, 0 ),
					( 0, 142, 0 ), ( 0, 152, 0), ( 0, 179, 0 ), ( 0, -145, 0) );
	if ( getDvar( "ui_zm_mapstartlocation" ) == "street" )
	{
		level.struct_class_names[ "targetname" ][ "player_respawn_point" ] = [];
		level.struct_class_names[ "script_noteworthy" ][ "initial_spawn" ] = [];
	} 
	for ( i = 0; i < coordinates.size; i++ )
	{
		scripts/zm/grief/gametype_modules/_gametype_setup::register_map_initial_spawnpoint( coordinates[ i ], angles[ i ] );
	}
}

precache() //checked matches cerberus output
{
	precachemodel( "collision_wall_128x128x10_standard" );
	precachemodel( "collision_wall_256x256x10_standard" );
	precachemodel( "collision_wall_512x512x10_standard" );
	precachemodel( "zm_collision_buried_street_grief" );
	precachemodel( "p6_zm_bu_buildable_bench_tarp" );
	level.chalk_buildable_pieces_hide = 1;
	griefbuildables = array( "chalk", "turbine", "springpad_zm", "subwoofer_zm" );
	maps/mp/zm_buried_buildables::include_buildables( griefbuildables );
	maps/mp/zm_buried_buildables::init_buildables( griefbuildables );
	maps/mp/zombies/_zm_equip_turbine::init();
	maps/mp/zombies/_zm_equip_turbine::init_animtree();
	maps/mp/zombies/_zm_equip_springpad::init( &"ZM_BURIED_EQ_SP_PHS", &"ZM_BURIED_EQ_SP_HTS" );
	maps/mp/zombies/_zm_equip_subwoofer::init( &"ZM_BURIED_EQ_SW_PHS", &"ZM_BURIED_EQ_SW_HTS" );
	setdvar( "disableLookAtEntityLogic", 1 );
	level.chests = [];
	level.chests[ level.chests.size ] = getstruct( "start_chest", "script_noteworthy" );
	level.chests[ level.chests.size ] = getstruct( "courtroom_chest1", "script_noteworthy" );
	level.chests[ level.chests.size ] = getstruct( "tunnels_chest1", "script_noteworthy" );
	level.chests[ level.chests.size ] = getstruct( "jail_chest1", "script_noteworthy" );
	level.chests[ level.chests.size ] = getstruct( "gunshop_chest", "script_noteworthy" );
}

main() //checked matches cerberus output
{
	disable_tunnels();
	spawn_mp5_wallbuy();
	delete_door_and_debris_trigs();
	maps/mp/gametypes_zm/_zm_gametype::setup_standard_objects( "street" );
	maps/mp/zombies/_zm_magicbox::treasure_chest_init( "start_chest" );
	spawnmapcollision( "zm_collision_buried_street_grief" );
	common_init();
}

delete_door_and_debris_trigs()
{	
	if( !level.grief_gamerules[ "disable_doors_buried" ] )
	{
		return;
	}
	spawn_barriers();
	door_trigs_to_delete = array( "pf728_auto2520", "pf728_auto2513", "pf728_auto2496" ); //"pf728_auto2516", "pf728_auto2500" //power doors
	doors_trigs = getentarray( "zombie_door", "targetname" );
	foreach ( door_trig in doors_trigs )
	{
		for ( i = 0; i < door_trigs_to_delete.size; i++ )
		{
			if ( door_trig.target == door_trigs_to_delete[ i ] )
			{
				door_trig delete();
			}
		}
	}
	debris_trigs_to_delete = array( "pf728_auto2529", "pf728_auto2528", "pf728_auto2531", "pf728_auto2530", "pf728_auto2532", "pf728_auto2534" );
	debris_trigs = getentarray( "zombie_debris", "targetname" );
	foreach ( debris_trig in debris_trigs )
	{
		for ( i = 0; i < debris_trigs_to_delete.size; i++ )
		{
			if ( debris_trig.target == debris_trigs_to_delete[ i ] )
			{
				debris_trig delete();
			}
		}
	}
}

spawn_mp5_wallbuy()
{
	wallbuy( ( 0, -180, 0 ), ( -279, 886, 190 ), "mp5k_zm_fx", "mp5k_zm", "t6_wpn_smg_mp5_world", "mp5", "weapon_upgrade" );
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

spawn_barriers()
{
	//barn barrier
	barrier_model = spawn( "script_model", ( -728, -557, 117 ), 1 );
	barrier_model.angles = ( 19, 180, 0 );
	barrier_model setmodel( "p6_zm_bu_sloth_blocker_medium" );
	barrier_model disconnectpaths();
	collision = spawn( "script_model", ( -728, -529, 117 ), 1 );
	collision.angles = ( 19, 4, 0 );
	collision setModel( "collision_player_64x64x128" );
	//tunnel blockade
	collision = spawn( "script_model", (-1495, -280, 40) );
	collision.angles = ( 0, 90, 0 );
	collision setmodel( "collision_clip_wall_128x128x10" );
	couch = spawn( "script_model", (-1512, -262, 26.5) );
	couch.angles = ( 0, 90, 0 );
	couch setmodel( "p6_zm_bu_victorian_couch" );
	//mule kick barrier
	/*
	barrier_model = spawn( "script_model", ( -578, 1006, 167 ), 1 );
	barrier_model.angles = ( 9, 270, 0 );
	barrier_model setmodel( "p6_zm_bu_sloth_blocker_medium" );
	barrier_model disconnectpaths();
	*/
}

disable_tunnels() //Jbleezy
{
	// stables tunnel entrance
	origin = (-1502, -262, 26);
	angles = ( 0, 90, 5 );
	collision = spawn( "script_model", origin + anglesToUp(angles) * 64 );
	collision.angles = angles;
	collision setmodel( "collision_wall_128x128x10_standard" );
	model = spawn( "script_model", origin + (0, 60, 0) );
	model.angles = angles;
	model setmodel( "p6_zm_bu_wood_door_bare" );
	model = spawn( "script_model", origin + (0, -60, 0) );
	model.angles = angles;
	model setmodel( "p6_zm_bu_wood_door_bare_right" );

	// stables tunnel exit
	origin = (-22, -1912, 269);
	angles = ( 0, -90, -10 );
	collision = spawn( "script_model", origin + anglesToUp(angles) * 128 );
	collision.angles = angles;
	collision setmodel( "collision_wall_256x256x10_standard" );
	model = spawn( "script_model", origin );
	model.angles = angles;
	model setmodel( "p6_zm_bu_sloth_blocker_medium" );

	// saloon tunnel entrance
	origin = (488, -1778, 188);
	angles = ( 0, 0, -10 );
	collision = spawn( "script_model", origin + anglesToUp(angles) * 64 );
	collision.angles = angles;
	collision setmodel( "collision_wall_128x128x10_standard" );
	model = spawn( "script_model", origin );
	model.angles = angles;
	model setmodel( "p6_zm_bu_sloth_blocker_medium" );

	// saloon tunnel exit
	origin = (120, -1984, 228);
	angles = ( 0, 45, -10 );
	collision = spawn( "script_model", origin + anglesToUp(angles) * 128 );
	collision.angles = angles;
	collision setmodel( "collision_wall_256x256x10_standard" );
	model = spawn( "script_model", origin );
	model.angles = angles;
	model setmodel( "p6_zm_bu_sloth_blocker_medium" );

	// main tunnel saloon side
	origin = (770, -863, 320);
	angles = ( 0, 180, -35 );
	collision = spawn( "script_model", origin + anglesToUp(angles) * 128 );
	collision.angles = angles;
	collision setmodel( "collision_wall_256x256x10_standard" );
	model = spawn( "script_model", origin );
	model.angles = angles;
	model setmodel( "p6_zm_bu_sloth_blocker_medium" );

	// main tunnel courthouse side
	origin = (349, 579, 240);
	angles = ( 0, 0, -10 );
	collision = spawn( "script_model", origin + anglesToUp(angles) * 64 );
	collision.angles = angles;
	collision setmodel( "collision_wall_128x128x10_standard" );
	model = spawn( "script_model", origin );
	model.angles = angles;
	model setmodel( "p6_zm_bu_sloth_blocker_medium" );

	// main tunnel above general store
	origin = (-123, -801, 296);
	angles = ( 0, 0, 90 );
	collision = spawn( "script_model", origin );
	collision.angles = angles;
	collision setmodel( "collision_wall_128x128x10_standard" );

	// main tunnel above jail
	origin = (-852, 408, 379);
	angles = ( 0, 0, 90 );
	collision = spawn( "script_model", origin );
	collision.angles = angles;
	collision setmodel( "collision_wall_512x512x10_standard" );

	// gunsmith debris
	debris_trigs = getentarray( "zombie_debris", "targetname" );
	foreach ( debris_trig in debris_trigs )
	{
		if ( debris_trig.target == "pf728_auto2534" )
		{
			debris_trig delete();
		}
	}

	// stables tunnel spawners
	level.zones["zone_tunnel_gun2stables2"].is_enabled = 0;
	level.zones["zone_tunnel_gun2stables2"].is_spawning_allowed = 0;
	foreach ( spawn_location in level.zones["zone_stables"].spawn_locations )
	{
		if ( spawn_location.origin == ( -1551, -611, 36.69 ) )
		{
			spawn_location.is_enabled = false;
		}
	}
} 