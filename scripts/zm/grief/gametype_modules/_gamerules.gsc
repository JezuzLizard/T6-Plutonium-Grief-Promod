#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/zombies/_zm_perks;
#include scripts/zm/promod/utility/_grief_util;
#include scripts/zm/promod/utility/_text_parser;

parse_restrictions()
{
	//turn_restricted_perks_off();
	powerup_restrictions();
}

//doesn't work yet
grief_restrict_wallbuy( weapon )
{
	if ( level.grief_restrictions[ "weapons" ] == "" )
	{
		return false;
	}
	weapon_keys = strTok( level.grief_restrictions[ "weapons" ], " " );
	foreach ( key in weapon_keys )
	{
		if ( key == weapon )
		{
			return true;
		}
	}
	return false;
}

powerup_restrictions()
{	
	powerup_restrictions = strTok( level.grief_restrictions[ "powerups" ], " " );
	for ( i = 0; i < level.data_maps[ "powerups" ][ "default_allowed_powerups" ].size; i++ )
	{
		for ( j = 0; j < powerup_restrictions.size; j++ )
		{
			if ( level.data_maps[ "powerups" ][ "is_active" ][ i ] == "1" && level.data_maps[ "powerups" ][ "default_allowed_powerups" ][ i ] == powerup_restrictions[ j ] || level.grief_restrictions[ "powerups" ] == "all" )
			{
				level.data_maps[ "powerups" ][ "is_active" ][ i ] = "0";
				break;
			}
		}
	}
}

init_gamerules()
{
	level.default_solo_laststandpistol = "m1911_zm";
	level.is_forever_solo_game = undefined;
	level.speed_change_round = undefined;
	level.grief_gamerules = [];
	level.grief_gamerules[ "scorelimit" ] = getDvarIntDefault( "grief_gamerule_scorelimit", 3 );
	level.grief_gamerules[ "roundlimit" ] = getGametypeSetting( "roundLimit" );
	level.grief_gamerules[ "timelimit" ] = getGametypeSetting( "timelimit" );
	level.grief_gamerules[ "mystery_box_enabled" ] = getDvarIntDefault( "grief_gamerule_mystery_box_enabled", 0 );
	level.grief_gamerules[ "next_round_time" ] = getDvarIntDefault( "grief_gamerule_next_round_timer", 5 );
	level.grief_gamerules[ "intermission_time" ] = getDvarIntDefault( "grief_gamerule_intermission_time", 0 );
	level.grief_gamerules[ "round_restart_points" ] = getDvarIntDefault( "grief_gamerule_round_restart_points", 8000 );
	level.grief_gamerules[ "use_preset_teams" ] = getDvarIntDefault( "grief_gamerule_use_preset_teams", 0 );
	level.grief_gamerules[ "disable_zombie_special_runspeeds" ] = getDvarIntDefault( "grief_gamerules_disable_zombie_special_runspeeds", 1 );
	level.grief_gamerules[ "suicide_check" ] = getDvarFloatDefault( "grief_gamerule_suicide_check_wait", 5 );
	level.grief_gamerules[ "player_health" ] = getDvarIntDefault( "grief_gamerule_player_health", 100 );
	level.grief_gamerules[ "perk_limit" ] = getDvarIntDefault( "grief_gamerule_perk_limit", 4 );
	level.grief_gamerules[ "knife_lunge" ] = getDvarIntDefault( "grief_gamerule_knife_lunge", 1 );
	level.grief_gamerules[ "magic" ] = getDvarIntDefault( "grief_gamerule_magic", 1 );
	level.grief_gamerules[ "reduced_pistol_ammo" ] = getDvarIntDefault( "grief_gamerule_reduced_pistol_ammo", 1 );
	level.grief_gamerules[ "buildables" ] = getDvarIntDefault( "grief_gamerule_buildables", 1 );
	level.grief_gamerules[ "disable_doors" ] = getDvarIntDefault( "grief_gamerule_disable_doors", 1 );
	level.grief_gamerules[ "zombie_round" ] = getDvarIntDefault( "grief_gamerules_zombie_round", 20 );
	level.grief_gamerules[ "power_state" ] = getDvarIntDefault( "grief_gamerules_power_start_state", 1 );
	level.round_number = level.grief_gamerules[ "zombie_round" ];
	level.grief_gamerules[ "round_zombie_spawn_delay" ] = getDvarIntDefault( "grief_gamerule_round_zombie_spawn_delay", 15 );
	level.grief_gamerules[ "pregame_time" ] = getDvarIntDefault( "grief_gamerule_pregame_time", 15 );
	setdvar( "ui_scorelimit", level.grief_gamerules[ "scorelimit" ] );
	//setdvar( "ui_timelimit", level.grief_gamerules[ "timelimit" ] );
	makeDvarServerInfo( "ui_scorelimit" );
	//makeDvarServerInfo( "ui_timelimit" );
	init_restrictions();
}

init_restrictions()
{
	key_list = "weapupgrade:Pack_A_Punch:1|armorvest:juggernog:1|quickrevive:revive:1|fastreload:sleight:1|rof:doubletap:1|longersprint:marathon:1|deadshot:deadshot:1|additionalprimaryweapon:additionalprimaryweapon:1|scavenger:tombstone:1|finalstand:chugabud:1|grenadepulldeath:electric_cherry:1|flakjacket:divetonuke:1|nomotionsensor:specialty_nomotionsensor:1";
	key_names = "specialties|power_notifies|is_active";
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
	key_names = "default_allowed_powerups|is_active";
	generate_map( "powerups", key_list, key_names );
	level.grief_restrictions[ "perks" ] = getDvar( "grief_restrictions_perks" );
	level.grief_restrictions[ "weapons" ] = getDvar( "grief_restrictions_weapons" );
	level.grief_restrictions[ "powerups" ] = getDvar( "grief_restrictions_powerups" );
	level.grief_restrictions[ "restrictions" ] = getDvar( "grief_restrictions_doors" );
	parse_restrictions();
}

set_power_state( state )
{
	if ( state )
	{
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
				door notify( "local_power_on" );
			}
		}
		for ( i = 0; i < level.data_maps[ "perks" ][ "power_notifies" ].size; i++ )
		{
			if ( !isSubStr( level.grief_restrictions[ "perks" ], level.data_maps[ "perks" ][ "specialties" ][ i ] ) )
			{
				level thread server_safe_notify_thread( level.data_maps[ "perks" ][ "power_notifies" ][ i ] + "_on", i );
				trigger = getent( level.data_maps[ "perks" ][ "specialties" ][ i ], "script_noteworthy" );
				trigger.machine show();
				trigger.clip solid();
			}
		}
	}
	else 
	{
		flag_set( "power_on" );
		level setclientfield( "zombie_power_on", 0 );
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
		for ( i = 0; i < level.data_maps[ "perks" ][ "power_notifies" ].size; i++ )
		{
			level thread server_safe_notify_thread( level.data_maps[ "perks" ][ "power_notifies" ][ i ] + "_off", i );
			trigger = getent( level.data_maps[ "perks" ][ "specialties" ][ i ], "script_noteworthy" );
			trigger.machine ghost();
			trigger.clip notSolid();
		}
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
	wait( index * 0.05 );
	level notify( notify_name );
}

treasure_chest_init_o( start_chest_name ) //checked changed to match cerberus output
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