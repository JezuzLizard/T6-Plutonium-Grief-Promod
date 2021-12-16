#include maps/mp/zombies/_load;
#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/zombies/_zm_zonemgr;
#include maps/mp/gametypes_zm/_zm_gametype;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_melee_weapon;
#include maps/mp/zombies/_zm_weap_claymore;
#include maps/mp/zombies/_zm_weap_ballistic_knife;
#include maps/mp/zombies/_zm_equipment;
#include maps/mp/zombies/_zm_magicbox;
#include maps/mp/zombies/_zm_laststand;

add_struct( s_struct )
{
	if ( isDefined( s_struct.targetname ) )
	{
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

register_map_initial_spawnpoint( spawnpoint_coordinates, spawnpoint_angles ) //custom function
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
	spawnpoint_struct.script_string = getDvar( "g_gametype" ) + "_" + getDvar( "ui_zm_mapstartlocation" );
	spawnpoint_struct.locked = 0;
	player_respawn_point_size = level.struct_class_names[ "targetname" ][ "player_respawn_point" ].size;
	player_initial_spawnpoint_size = level.struct_class_names[ "script_noteworthy" ][ "initial_spawn" ].size;
	level.struct_class_names[ "targetname" ][ "player_respawn_point" ][ player_respawn_point_size ] = spawnpoint_struct;
	level.struct_class_names[ "script_noteworthy" ][ "initial_spawn" ][ player_initial_spawnpoint_size ] = spawnpoint_struct;
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
	// level.survival_barriers[ level.survival_barriers_index ] disconnectPaths();  
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
	spawn_points = maps/mp/gametypes_zm/_zm_gametype::get_player_spawns_for_gametype();
	for ( i = 0; i < spawn_points.size; i++ )
	{
		spawn_points[ i ].locked = 1;
	}
	if ( isDefined( level.zone_manager_init_func ) )
	{
		[[ level.zone_manager_init_func ]]();
	}
	for ( i = 0; i < initial_zone.size; i++ )
	{
		zone_init( initial_zone[ i ] );
		enable_zone( initial_zone[ i ] );
	}
	if ( array_validate( level.location_zones ) )
	{
		for ( i = 0; i < level.location_zones.size; i++ )
		{
			zone_init( level.location_zones[ i ] );
			enable_zone( level.location_zones[ i ] );
		}
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
	flag_wait( "match_start" );
	while ( true )
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
			if ( isdefined( level.zone_occupied_func ) )
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
				if ( !isdefined( oldzone ) || oldzone != newzone )
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
			level.zones[ initial_zone[ 0 ] ].is_active = 1;
			level.zones[ initial_zone[ 0 ] ].is_occupied = 1;
			level.zones[ initial_zone[ 0 ] ].is_spawning_allowed = 1;
		}
		[[ level.create_spawner_list_func ]]( zkeys );
		level.active_zone_names = maps/mp/zombies/_zm_zonemgr::get_active_zone_names();
		wait 1;
	}
}

rungametypeprecache_override( gamemode )
{
	if ( !isDefined( level.gamemode_map_location_main ) || !isDefined( level.gamemode_map_location_main[ gamemode ] ) )
	{
		return;
	}
	if ( isDefined( level.gamemode_map_precache ) )
	{
		if ( isDefined( level.gamemode_map_precache[ gamemode ] ) )
		{
			[[ level.gamemode_map_precache[ gamemode ] ]]();
		}
	}
	if ( isDefined( level.gamemode_map_location_precache ) )
	{
		if ( isDefined( level.gamemode_map_location_precache[ gamemode ] ) )
		{
			loc = getDvar( "ui_zm_mapstartlocation" );
			if ( loc == "" && isDefined( level.default_start_location ) )
			{
				loc = level.default_start_location;
			}
			if ( isDefined( level.gamemode_map_location_precache[ gamemode ][ loc ] ) )
			{
				[[ level.gamemode_map_location_precache[ gamemode ][ loc ] ]]();
			}
		}
	}
	if ( isDefined( level.precachecustomcharacters ) )
	{
		self [[ level.precachecustomcharacters ]]();
	}
}

rungametypemain_override( gamemode, mode_main_func, use_round_logic )
{
	if ( !isDefined( level.gamemode_map_location_main ) || !isDefined( level.gamemode_map_location_main[ gamemode ] ) )
	{
		return;
	}
	level thread game_objects_allowed_override( getDvar( "g_gametype" ), getDvar( "ui_zm_mapstartlocation" ) );
	if ( isDefined( level.gamemode_map_main ) )
	{
		if ( isDefined( level.gamemode_map_main[ gamemode ] ) )
		{
			level thread [[ level.gamemode_map_main[ gamemode ] ]]();
		}
	}
	if ( isDefined( level.gamemode_map_location_main ) )
	{
		if ( isDefined( level.gamemode_map_location_main[ gamemode ] ) )
		{
			loc = getDvar( "ui_zm_mapstartlocation" );
			if ( loc == "" && isDefined( level.default_start_location ) )
			{
				loc = level.default_start_location;
			}
			if ( isDefined( level.gamemode_map_location_main[ gamemode ][ loc ] ) )
			{
				level thread [[ level.gamemode_map_location_main[ gamemode ][ loc ] ]]();
			}
		}
	}
	level thread scripts/zm/grief/mechanics/_round_system::zgrief_main_override();
}

game_objects_allowed_override( mode, location )
{
	if ( location == "transit" )
	{
		location = "station";
	}
	allowed = [];
	allowed[ 0 ] = mode;
	entities = getentarray();
	i = 0;
	while ( i < entities.size )
	{
		if ( isDefined( entities[ i ].script_gameobjectname ) )
		{
			isallowed = maps/mp/gametypes_zm/_gameobjects::entity_is_allowed( entities[ i ], allowed );
			isvalidlocation = maps/mp/gametypes_zm/_gameobjects::location_is_allowed( entities[ i ], location );
			if ( !isallowed || !isvalidlocation && !is_classic() )
			{
				if ( isDefined( entities[ i ].spawnflags ) && entities[ i ].spawnflags == 1 )
				{
					if ( isDefined( entities[ i ].classname ) && entities[ i ].classname != "trigger_multiple" )
					{
						entities[ i ] connectpaths();
					}
				}
				entities[ i ] delete();
				i++;
				continue;
			}
			if ( isDefined( entities[ i ].script_vector ) )
			{
				entities[ i ] moveto( entities[ i ].origin + entities[ i ].script_vector, 0.05 );
				entities[ i ] waittill( "movedone" );
				if ( isDefined( entities[ i ].spawnflags ) && entities[ i ].spawnflags == 1 )
				{
					entities[ i ] disconnectpaths();
				}
				i++;
				continue;
			}
			if ( isDefined( entities[ i ].spawnflags ) && entities[ i ].spawnflags == 1 )
			{
				if ( isDefined( entities[ i ].classname ) && entities[ i ].classname != "trigger_multiple" )
				{
					entities[ i ] connectpaths();
				}
			}
		}
		i++;
	}
}

setup_standard_objects_override( location )
{
	structs = getstructarray( "game_mode_object" );
	i = 0;
	while ( i < structs.size )
	{
		if ( isdefined( structs[ i ].script_noteworthy ) && structs[ i ].script_noteworthy != location )
		{
			i++;
			continue;
		}
		if ( isdefined( structs[ i ].script_string ) )
		{
			keep = 0;
			tokens = strtok( structs[ i ].script_string, " " );
			foreach ( token in tokens )
			{
				if ( token == level.scr_zm_ui_gametype && token != "zstandard" )
				{
					keep = 1;
					continue;
				}
				else if ( token == "zstandard" )
				{
					keep = 1;
				}
			}
			if ( !keep )
			{
				i++;
				continue;
			}
		}
		barricade = spawn( "script_model", structs[ i ].origin );
		barricade.angles = structs[ i ].angles;
		barricade setmodel( structs[ i ].script_parameters );
		i++;
	}
	objects = getentarray();
	i = 0;
	while ( i < objects.size )
	{
		if ( !objects[ i ] is_survival_object() )
		{
			i++;
			continue;
		}
		if ( isdefined( objects[ i ].spawnflags ) && objects[ i ].spawnflags == 1 && objects[ i ].classname != "trigger_multiple" )
		{
			objects[ i ] connectpaths();
		}
		objects[ i ] delete();
		i++;
	}
	if ( isdefined( level._classic_setup_func ) )
	{
		[[ level._classic_setup_func ]]();
	}
}

setup_classic_gametype_override()
{
	ents = getentarray();
	i = 0;
	while ( i < ents.size )
	{
		if ( isDefined( ents[ i ].script_parameters ) )
		{
			parameters = strtok( ents[ i ].script_parameters, " " );
			should_remove = 0;
			foreach ( parm in parameters )
			{
				if ( parm == "survival_remove" )
				{
					should_remove = 1;
				}
			}
			if ( should_remove )
			{
				ents[ i ] delete();
			}
		}
		i++;
	}
	structs = getstructarray( "game_mode_object" );
	i = 0;
	while ( i < structs.size )
	{
		if ( !isdefined( structs[ i ].script_string ) )
		{
			i++;
			continue;
		}
		tokens = strtok( structs[ i ].script_string, " " );
		spawn_object = 0;
		foreach ( parm in tokens )
		{
			if ( parm == "survival" )
			{
				spawn_object = 1;
			}
		}
		if ( !spawn_object )
		{
			i++;
			continue;
		}
		barricade = spawn( "script_model", structs[ i ].origin );
		barricade.angles = structs[ i ].angles;
		barricade setmodel( structs[ i ].script_parameters );
		i++;
	}
	unlink_meat_traversal_nodes();
}

suicide_trigger_think() //checked changed to match cerberus output
{
	self endon( "disconnect" );
	self endon( "zombified" );
	self endon( "stop_revive_trigger" );
	self endon( "player_revived" );
	self endon( "bled_out" );
	self endon( "fake_death" );
	level endon( "end_game" );
	level endon( "stop_suicide_trigger" );
	self thread clean_up_suicide_hud_on_end_game();
	self thread clean_up_suicide_hud_on_bled_out();
	while ( self usebuttonpressed() )
	{
		wait 1;
	}
	if ( !isDefined( self.suicideprompt ) )
	{
		return;
	}
	while ( 1 )
	{
		wait 0.1;
		if ( !isDefined( self.suicideprompt ) )
		{
			continue;
		}
		self.suicideprompt settext( "" );
		if ( !self is_suiciding() )
		{
			continue;
		}
		self.pre_suicide_weapon = self getcurrentweapon();
		self giveweapon( level.suicide_weapon );
		self switchtoweapon( level.suicide_weapon );
		duration = self docowardswayanims();
		suicide_success = suicide_do_suicide( duration );
		self.laststand = undefined;
		self takeweapon( level.suicide_weapon );
		if ( suicide_success )
		{
			self notify( "player_suicide" );
			wait_network_frame();
			self maps/mp/zombies/_zm_stats::increment_client_stat( "suicides" );
			self bleed_out();
			return;
		}
		self switchtoweapon( self.pre_suicide_weapon );
		self.pre_suicide_weapon = undefined;
	}
}

weapon_give( weapon, is_upgrade, magic_box, nosound ) //checked changed to match cerberus output
{
	primaryweapons = self getweaponslistprimaries();
	current_weapon = self getcurrentweapon();
	current_weapon = self maps/mp/zombies/_zm_weapons::switch_from_alt_weapon( current_weapon );
	if ( !isDefined( is_upgrade ) )
	{
		is_upgrade = 0;
	}
	weapon_limit = get_player_weapon_limit( self );
	if ( is_equipment( weapon ) )
	{
		self maps/mp/zombies/_zm_equipment::equipment_give( weapon );
	}
	if ( weapon == "riotshield_zm" )
	{
		if ( isDefined( self.player_shield_reset_health ) )
		{
			self [[ self.player_shield_reset_health ]]();
		}
	}
	if ( self hasweapon( weapon ) )
	{
		if ( issubstr( weapon, "knife_ballistic_" ) )
		{
			self notify( "zmb_lost_knife" );
		}
		self givestartammo( weapon );
		if ( !is_offhand_weapon( weapon ) )
		{
			self switchtoweapon( weapon );
		}
		return;
	}
	if ( is_melee_weapon( weapon ) )
	{
		current_weapon = maps/mp/zombies/_zm_melee_weapon::change_melee_weapon( weapon, current_weapon );
	}
	else if ( is_lethal_grenade( weapon ) )
	{
		old_lethal = self get_player_lethal_grenade();
		if ( isDefined( old_lethal ) && old_lethal != "" )
		{
			self takeweapon( old_lethal );
			unacquire_weapon_toggle( old_lethal );
		}
		self set_player_lethal_grenade( weapon );
	}
	else if ( is_tactical_grenade( weapon ) )
	{
		old_tactical = self get_player_tactical_grenade();
		if ( isDefined( old_tactical ) && old_tactical != "" )
		{
			self takeweapon( old_tactical );
			unacquire_weapon_toggle( old_tactical );
		}
		self set_player_tactical_grenade( weapon );
	}
	else if ( is_placeable_mine( weapon ) )
	{
		old_mine = self get_player_placeable_mine();
		if ( isDefined( old_mine ) )
		{
			self takeweapon( old_mine );
			unacquire_weapon_toggle( old_mine );
		}
		self set_player_placeable_mine( weapon );
	}
	if ( !is_offhand_weapon( weapon ) )
	{
		self maps/mp/zombies/_zm_weapons::take_fallback_weapon();
	}
	if ( primaryweapons.size >= weapon_limit )
	{
		if ( is_placeable_mine( current_weapon ) || is_equipment( current_weapon ) )
		{
			current_weapon = undefined;
		}
		if ( isDefined( current_weapon ) )
		{
			if ( !is_offhand_weapon( weapon ) )
			{
				if ( current_weapon == "tesla_gun_zm" )
				{
					level.player_drops_tesla_gun = 1;
				}
				if ( issubstr( current_weapon, "knife_ballistic_" ) )
				{
					self notify( "zmb_lost_knife" );
				}
				self takeweapon( current_weapon );
				unacquire_weapon_toggle( current_weapon );
			}
		}
	}
	if ( isDefined( level.zombiemode_offhand_weapon_give_override ) )
	{
		if ( self [[ level.zombiemode_offhand_weapon_give_override ]]( weapon ) )
		{
			return;
		}
	}
	if ( weapon == "cymbal_monkey_zm" )
	{
		self maps/mp/zombies/_zm_weap_cymbal_monkey::player_give_cymbal_monkey();
		self play_weapon_vo( weapon, magic_box );
		return;
	}
	else if ( issubstr( weapon, "knife_ballistic_" ) )
	{
		weapon = self maps/mp/zombies/_zm_melee_weapon::give_ballistic_knife( weapon, issubstr( weapon, "upgraded" ) );
	}
	else if ( weapon == "claymore_zm" )
	{
		self thread maps/mp/zombies/_zm_weap_claymore::claymore_setup();
		self play_weapon_vo( weapon, magic_box );
		return;
	}
	if ( isDefined( level.zombie_weapons_callbacks ) && isDefined( level.zombie_weapons_callbacks[ weapon ] ) )
	{
		self thread [[ level.zombie_weapons_callbacks[ weapon ] ]]();
		play_weapon_vo( weapon, magic_box );
		return;
	}
	if ( !is_true( nosound ) )
	{
		self play_sound_on_ent( "purchase" );
	}
	if ( weapon == "ray_gun_zm" )
	{
		playsoundatposition( "mus_raygun_stinger", ( 0, 0, 0 ) );
	}
	if ( !is_weapon_upgraded( weapon ) )
	{
		self giveweapon( weapon );
	}
	else
	{
		self giveweapon( weapon, 0, self get_pack_a_punch_weapon_options( weapon ) );
	}
	acquire_weapon_toggle( weapon, self );
	self givestartammo( weapon );
	if ( !is_offhand_weapon( weapon ) )
	{
		if ( !is_melee_weapon( weapon ) )
		{
			self switchtoweapon( weapon );
		}
		else
		{
			self switchtoweapon( current_weapon );
		}
	}
	if ( weapon == "mp5k_zm" && level.grief_gamerules[ "reduce_mp5_ammo" ] )
	{
		self setweaponammostock(weapon, 0);
		self setweaponammoclip(weapon, 0);
	}
	self play_weapon_vo( weapon, magic_box );
}

disable_player_move_states_override( forcestancechange ) //checked matches cerberus output
{
	self allowcrouch( 1 );
	self allowlean( 0 );
	self allowads( 0 );
	self allowsprint( level.grief_gamerules[ "sprint_while_drinking_perks" ] );
	self allowprone( 0 );
	self allowmelee( 0 );
	if ( isDefined( forcestancechange ) && forcestancechange == 1 )
	{
		if ( self getstance() == "prone" )
		{
			self setstance( "crouch" );
		}
	}
}