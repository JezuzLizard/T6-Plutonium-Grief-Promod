#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/zombies/_zm_perks;
#include maps/mp/zombies/_zm_magicbox;

init_gamerules()
{
	//level.default_solo_laststandpistol = "m1911_zm";
	level.grief_gamerules = [];
	level.grief_gamerules[ "scorelimit" ] = getDvarIntDefault( "grief_gamerule_scorelimit", 3 );
	level.grief_gamerules[ "timelimit" ] = getGametypeSetting( "timelimit" );
	level.grief_gamerules[ "mystery_box_enabled" ] = getDvarIntDefault( "grief_gamerule_mystery_box_enabled", 1 );
	level.grief_gamerules[ "next_round_time" ] = getDvarIntDefault( "grief_gamerule_next_round_timer", 5 );
	level.grief_gamerules[ "round_restart_points" ] = getDvarIntDefault( "grief_gamerule_round_restart_points", 8000 );
	level.grief_gamerules[ "suicide_check" ] = getDvarFloatDefault( "grief_gamerule_suicide_check_wait", 5 );
	level.grief_gamerules[ "player_health" ] = getDvarIntDefault( "grief_gamerule_player_health", 100 );
	level.grief_gamerules[ "knife_lunge" ] = getDvarIntDefault( "grief_gamerule_knife_lunge", 1 );
	level.grief_gamerules[ "magic" ] = getDvarIntDefault( "grief_gamerule_magic", 1 );
	level.grief_gamerules[ "reduced_pistol_ammo" ] = getDvarIntDefault( "grief_gamerule_reduced_pistol_ammo", 0 );
	level.grief_gamerules[ "buildables" ] = getDvarIntDefault( "grief_gamerule_buildables", 0 );
	level.grief_gamerules[ "disable_doors" ] = getDvarIntDefault( "grief_gamerule_disable_doors", 1 );
	level.grief_gamerules[ "zombie_power_level_start" ] = getDvarIntDefault( "grief_gamerule_zombie_power_level_start", 1 );
	level.grief_gamerules[ "power_state" ] = getDvarIntDefault( "grief_gamerule_power_start_state", 1 );
	level.grief_gamerules[ "round_zombie_spawn_delay" ] = getDvarIntDefault( "grief_gamerule_round_zombie_spawn_delay", 15 );
	level.grief_gamerules[ "pregame_time" ] = getDvarIntDefault( "grief_gamerule_pregame_time", 15 );
	level.grief_gamerules[ "health_bar" ] = getDvarIntDefault( "grief_gamerule_health_bar", 0 );
	setdvar( "ui_scorelimit", level.grief_gamerules[ "scorelimit" ] );
	//setdvar( "ui_timelimit", level.grief_gamerules[ "timelimit" ] );
	makeDvarServerInfo( "ui_scorelimit" );
	//makeDvarServerInfo( "ui_timelimit" );
	level thread init_restrictions();
}

init_restrictions()
{
	key_list = "weapupgrade:Pack_A_Punch|armorvest:juggernog|quickrevive:revive|fastreload:sleight|rof:doubletap|longersprint:marathon|deadshot:deadshot|additionalprimaryweapon:additionalprimaryweapon|scavenger:tombstone|finalstand:chugabud|grenadepulldeath:electric_cherry|flakjacket:divetonuke|nomotionsensor:specialty_nomotionsensor";
	key_names = "specialties|power_notifies";
	generate_map( "perks", key_list, key_names );
	key_list = "nuke:1|insta_kill:1|full_ammo:1|double_points:1";
	if ( getDvar( "ui_zm_gamemodegroup" ) == "zencounter" )
	{
		key_list += "|meat_stink:1";
	}
	if ( level.script != "zm_transit" && level.script != "zm_highrise" )
	{
		key_list += "|fire_sale:1";
	}
	key_names = "names|allowed";
	generate_map( "powerups", key_list, key_names );
	level.grief_restrictions = [];
	level.grief_restrictions[ "perks" ] = getDvar( "grief_restrictions_perks" );
	//level.grief_restrictions[ "weapons" ] = getDvar( "grief_restrictions_weapons" );
	level.grief_restrictions[ "powerups" ] = getDvar( "grief_restrictions_powerups" );
	powerup_restrictions();
	//level.grief_restrictions[ "doors" ] = getDvar( "grief_restrictions_doors" );
}

powerup_restrictions()
{	
	if ( level.grief_restrictions[ "powerups" ] == "" )
	{
		return;
	}
	powerup_restrictions = strTok( level.grief_restrictions[ "powerups" ], " " );
	for ( i = 0; i < level.data_maps[ "powerups" ][ "names" ].size; i++ )
	{
		for ( j = 0; j < powerup_restrictions.size; j++ )
		{
			if ( isSubStr( level.data_maps[ "powerups" ][ "names" ][ i ], powerup_restrictions[ j ] ) || level.grief_restrictions[ "powerups" ] == "all" )
			{
				level.data_maps[ "powerups" ][ "allowed" ][ i ] = "0";
				break;
			}
		}
	}
}

is_perk_restricted( perk )
{
	if ( level.grief_restrictions[ "perks" ] == "" )
	{
		return false;
	}
	perk_restrictions = strTok( level.grief_restrictions[ "perks" ], " " );
	foreach ( restriction in perk_restrictions )
	{
		if ( perk == restriction || restriction == "all" )
		{
			return true;
		}
	}
	return false;
}

// perk_restrictions()
// {
// 	if ( level.grief_restrictions[ "perks" ] == "" )
// 	{
// 		return;
// 	}
// 	if ( !flag( "power_on" ) )
// 	{
// 		return;
// 	}
// 	perk_speciality_names = level.data_maps[ "perks" ][ "specialties" ];
// 	perk_power_notify_names = level.data_maps[ "perks" ][ "power_notifies" ];
// 	perk_restrictions = strTok( level.grief_restrictions[ "perks" ], " " );
// 	foreach ( perk in perk_restrictions )
// 	{
// 		for ( i = 0; i < perk_speciality_names.size; i++ )
// 		{
// 			if ( perk == perk_speciality_names[ i ] || perk == perk_power_notify_names[ i ] || perk == "all" )
// 			{
// 				trigger = getent( "specialty_" + level.data_maps[ "perks" ][ "specialties" ][ i ], "script_noteworthy" );
// 				if ( isDefined( trigger ) )
// 				{
// 					level thread server_safe_notify_thread( level.data_maps[ "perks" ][ "power_notifies" ][ i ] + "_off", i );
// 					trigger trigger_off_proc();
// 					trigger.clip notSolid();
// 				}
// 				break;
// 			}
// 		}
// 	}
// }

set_power_state( state )
{
	if ( state )
	{
		flag_set( "power_on" );
		level setclientfield( "zombie_power_on", 1 );
		if ( level.script == "zm_transit" )
		{
			zombie_doors = getentarray( "zombie_door", "targetname" );
			foreach ( door in zombie_doors )
			{
				if ( isDefined( door.script_noteworthy ) && door.script_noteworthy == "electric_door" )
				{
					door notify( "power_on" );
				}
				else if ( isDefined( door.script_noteworthy ) && door.script_noteworthy == "local_electric_door" )
				{
					door notify( "local_power_on" );
				}
			}
		}
		for ( i = 0; i < level.data_maps[ "perks" ][ "power_notifies" ].size; i++ )
		{
			if ( is_perk_restricted( level.data_maps[ "perks" ][ "specialties" ][ i ] ) || is_perk_restricted( level.data_maps[ "perks" ][ "power_notifies" ][ i ] ) )
			{
				trigger = getent( "specialty_" + level.data_maps[ "perks" ][ "specialties" ][ i ], "script_noteworthy" );
				if ( isDefined( trigger ) && !is_true( trigger.is_restricted ) )
				{
					hide_restricted_perk( trigger );
					trigger.is_restricted = true;
				}
			}
			else 
			{
				trigger = getent( "specialty_" + level.data_maps[ "perks" ][ "specialties" ][ i ], "script_noteworthy" );
				if ( isDefined( trigger ) )
				{
					level thread server_safe_notify_thread( level.data_maps[ "perks" ][ "power_notifies" ][ i ] + "_on", i );
				}
			}
		}
	}
	else if ( is_true( level.grief_initial_power_on_done ) )
	{
		flag_clear( "power_on" );
		level setclientfield( "zombie_power_on", 0 );
		if ( level.script == "zm_transit" )
		{
			zombie_doors = getentarray( "zombie_door", "targetname" );
			foreach ( door in zombie_doors )
			{
				if ( isDefined( door.script_noteworthy ) && door.script_noteworthy == "electric_door" )
				{
					door notify( "power_off" );
				}
				if ( isDefined( door.script_noteworthy ) && door.script_noteworthy == "local_electric_door" )
				{
					door notify( "local_power_off" );
				}
			}
		}
		for ( i = 0; i < level.data_maps[ "perks" ][ "power_notifies" ].size; i++ )
		{
			if ( is_perk_restricted( level.data_maps[ "perks" ][ "specialties" ][ i ] ) || is_perk_restricted( level.data_maps[ "perks" ][ "power_notifies" ][ i ] ) )
			{
				trigger = getent( "specialty_" + level.data_maps[ "perks" ][ "specialties" ][ i ], "script_noteworthy" );
				if ( isDefined( trigger ) && !is_true( trigger.is_restricted ) )
				{
					level thread server_safe_notify_thread( level.data_maps[ "perks" ][ "power_notifies" ][ i ] + "_off", i );
					hide_restricted_perk( trigger );
					trigger.is_restricted = true;
				}
			}
			else
			{
				level thread server_safe_notify_thread( level.data_maps[ "perks" ][ "power_notifies" ][ i ] + "_off", i );
			}
		}
	}
	if ( !isDefined( level.grief_initial_power_on_done ) )
	{
		level.grief_initial_power_on_done = true;
	}
}

toggle_perk_power( new_power_state )
{
	if ( new_power_state )
	{
		for ( i = 0; i < level.data_maps[ "perks" ][ "power_notifies" ].size; i++ )
		{
			level thread server_safe_notify_thread( level.data_maps[ "perks" ][ "power_notifies" ][ i ] + "_on", i );
		}
	}
	else 
	{
		for ( i = 0; i < level.data_maps[ "perks" ][ "power_notifies" ].size; i++ )
		{
			level thread server_safe_notify_thread( level.data_maps[ "perks" ][ "power_notifies" ][ i ] + "_off", i );
		}
	}
}

server_safe_notify_thread( notify_name, index )
{
	wait( ( index * 0.05 ) + 0.05 );
	level notify( notify_name );
}

treasure_chest_init_override( start_chest_name ) //checked changed to match cerberus output
{
	flag_init( "moving_chest_enabled" );
	flag_init( "moving_chest_now" );
	flag_init( "chest_has_been_used" );
	level.chest_moves = 0;
	level.chest_level = 0;
	if ( level.chests.size == 0 )
	{
		return;
	}
	for ( i = 0; i < level.chests.size; i++ )
	{
		level.chests[ i ].box_hacks = [];
		level.chests[ i ].orig_origin = level.chests[ i ].origin;
		level.chests[ i ] get_chest_pieces();
		if ( isDefined( level.chests[ i ].zombie_cost ) )
		{
			level.chests[ i ].old_cost = level.chests[ i ].zombie_cost;
		}
		else 
		{
			level.chests[ i ].old_cost = 950;
		}
	}
	if ( !level.enable_magic || !level.grief_gamerules[ "mystery_box_enabled" ] )
	{
		foreach( chest in level.chests )
		{
			chest hide_chest();
		}
		return;
	}
	level.chest_accessed = 0;
	if ( level.chests.size > 1 )
	{
		flag_set( "moving_chest_enabled" );
		level.chests = array_randomize( level.chests );
	}
	else
	{
		level.chest_index = 0;
		level.chests[ 0 ].no_fly_away = 1;
	}
	init_starting_chest_location( start_chest_name );
	array_thread( level.chests, ::treasure_chest_think );
}

generate_map( map_name, arg_list, name_list )
{
	if ( !isDefined( level.data_maps ) )
	{
		level.data_maps = [];
	}
	if ( !isDefined( level.data_maps[ map_name ] ) )
	{
		name_list_keys = strTok( name_list, "|" );
		foreach ( key in name_list_keys )
		{
			if ( !isDefined( level.data_maps[ map_name ][ key ] ) )
			{
				level.data_maps[ map_name ][ key ] = [];
			}
		}
		key_value_pairs = strTok( arg_list, "|" );
		for ( i = 0; i < key_value_pairs.size; i++ )
		{
			pairs = strTok( key_value_pairs[ i ], ":" );
			for ( j = 0; j < name_list_keys.size; j++ )
			{
				size = level.data_maps[ map_name ][ name_list_keys[ j ] ].size;
				level.data_maps[ map_name ][ name_list_keys[ j ] ][ size ] = pairs[ j ];
			}
		}
	}
}

turn_perk_off_override( ishidden )
{
	self notify( "stop_loopsound" );
	newmachine = spawn( "script_model", self.origin );
	newmachine.angles = self.angles;
	newmachine.targetname = self.targetname;
	newmachine.ishidden = 1;
	newmachine hide();
	self delete();
}

perk_fx_override( fx, turnofffx )
{
	if ( isDefined( turnofffx ) )
	{
		self.perk_fx = 0;
	}
	else if ( !is_true( perk_machine.is_restricted ) )
	{
		wait 3;
		if ( isDefined( self ) && !is_true( self.perk_fx ) )
		{
			playfxontag( level._effect[ fx ], self, "tag_origin" );
			self.perk_fx = 1;
		}
	}
}

hide_restricted_perk( perk_trigger )
{
	if ( !is_true( perk_machine.is_restricted ) )
	{
		perk_trigger trigger_off_proc();
		perk_trigger.clip notSolid();
		perk_machine = getEnt( perk_trigger.target, "targetname" );
		perk_machine hide();
		perk_machine.is_restricted = true;
	}
}

show_restricted_perk( perk_trigger )
{
	if ( is_true( perk_machine_is_restricted ) )
	{
		perk_trigger trigger_on_proc();
		perk_trigger.clip solid();
		perk_machine = getEnt( perk_trigger.target, "targetname" );
		perk_machine show();
		perk_machine.is_restricted = false;
	}
}