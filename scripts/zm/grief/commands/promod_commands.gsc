
#include scripts/cmd_system_modules/_cmd_util;
#include scripts/cmd_system_modules/_com;
#include scripts/cmd_system_modules/_text_parser;
#include scripts/cmd_system_modules/_vote;
#include scripts/cmd_system_modules/_listener;
#include scripts/cmd_system_modules/_perms;
#include scripts/cmd_system_modules/_filesystem;

#include common_scripts/utility;
#include maps/mp/_utility;

main()
{
	level waittill( "tcs_init_done" );
	CMD_ADDCOMMAND( "team t", "add a", ::CMD_TEAM_ADD_f );
	CMD_ADDCOMMAND( "team t", "remove r", ::CMD_TEAM_REMOVE_f );
	CMD_ADDCOMMAND( "team t", "set s", ::CMD_TEAM_SET_f );
	CMD_ADDCOMMAND( "team t", "ban b", ::CMD_TEAM_BAN_f );
	CMD_ADDCOMMAND( "team t", "unban u", ::CMD_TEAM_UNBAN_f );
	CMD_ADDCOMMAND( "team t", "perm p", ::CMD_TEAM_PERM_f );
	CMD_ADDCOMMAND( "team t", "unperm up", ::CMD_TEAM_UNPERM_f );
	CMD_ADDCOMMAND( "gamerule g", "togmagic tm", ::CMD_TOGGLEMAGIC_f );
	CMD_ADDCOMMAND( "gamerule g", "togallpowerups togallpups", ::CMD_TOGGLEALLPOWERUPS_f );
	CMD_ADDCOMMAND( "gamerule g", "togallperks togallpks", ::CMD_TOGGLEALLPERKS_f );
	CMD_ADDCOMMAND( "gamerule g", "togpower togpow", ::CMD_TOGGLEPOWER_f );
	CMD_ADDCOMMAND( "gamerule g", "togperkrestrictions togpkr", ::CMD_TOGGLEPERKRESTRICTIONS_f );
	CMD_ADDCOMMAND( "gamerule g", "togperk togpk", ::CMD_TOGGLEPERK_f );
}

CMD_TOGGLEPOWER_f( arg_list )
{
	new_power_state = !level.grief_gamerules[ "power_state" ];
	set_power_state( new_power_state );
	result[ "message" ] = va( "gamerule:power_state: Power is now %s", cast_bool_to_str( new_power_state, "on off" ) );
	result[ "channels" ] = "con say g_log";
	result[ "filter" ] = "cmdinfo";
	return result;
}

CMD_TOGGLEPERKRESTRICTIONS_f( args_list )
{
	original_restrictions = getDvar( "grief_restrictions_perks" );
	new_perk_restrictions_value = original_restrictions == level.grief_restrictions[ "perks" ] ? "" : original_restrictions;
	new_perks_restrictions_state = new_perk_restrictions_value == "";
	level.grief_restrictions[ "perks" ] = new_perk_restrictions_value;
	perk_speciality_names = level.data_maps[ "perks" ][ "specialties" ];
	perk_power_notify_names = level.data_maps[ "perks" ][ "power_notifies" ];
	if ( new_perk_restrictions_value == "" )
	{
		for ( i = 0; i < perk_speciality_names.size; i++ )
		{
			level thread server_safe_notify_thread( level.data_maps[ "perks" ][ "power_notifies" ][ i ] + "_on", i );
			level.data_maps[ "perks" ][ "is_active" ][ i ] = "1";
			trigger = getent( level.data_maps[ "perks" ][ "specialties" ][ i ], "script_noteworthy" );
			trigger.machine show();
			trigger.clip solid();
		}
	}
	else 
	{
		for ( i = 0; i < perk_speciality_names.size; i++ )
		{
			if ( isSubStr( level.grief_restrictions[ "perks" ], perk_speciality_names[ i ] ) || isSubStr( level.grief_restrictions[ "perks" ], perk_power_notify_names[ i ] ) )
			{
				level thread server_safe_notify_thread( level.data_maps[ "perks" ][ "power_notifies" ][ i ] + "_off", i );
				level.data_maps[ "perks" ][ "is_active" ][ i ] = "0";
				trigger = getent( level.data_maps[ "perks" ][ "specialties" ][ i ], "script_noteworthy" );
				trigger.machine ghost();
				trigger.clip notSolid();
			}
		}
	}
	result[ "message" ] = va( "gamerule:perksrestrictions: Perk restrictions are %s restricted perks are powered %s", cast_bool_to_str( new_perks_restrictions_state, "disabled enabled" ), cast_bool_to_str( new_perks_restrictions_state, "on off" ) );
	result[ "channels" ] = "con say g_log";
	result[ "filter" ] = "cmdinfo";
	return result;
}

CMD_TOGGLEALLPERKS_f( args_list )
{
	forced_perks_state = arg_list[ 0 ];
	if ( isDefined( forced_perks_state ) )
	{
		new_perk_restrictions_state = forced_perks_state;
		level.grief_restrictions[ "perks" ] = !forced_perks_state ? "all" : "";
	}
	else 
	{
		level.grief_restrictions[ "perks" ] = level.grief_restrictions[ "perks" ] != "all" ? "all" : "";
		new_perk_restrictions_state = level.grief_restrictions[ "perks" ] ? "" : "all";
	}
	if ( new_perk_restrictions_state )
	{
		for ( i = 0; i < level.data_maps[ "perks" ][ "power_notifies" ].size; i++ )
		{
			level thread server_safe_notify_thread( level.data_maps[ "perks" ][ "power_notifies" ][ i ] + "_on", i );
			level.data_maps[ "perks" ][ "is_active" ][ i ] = "1";
			trigger = getent( level.data_maps[ "perks" ][ "specialties" ][ i ], "script_noteworthy" );
			trigger.machine show();
			trigger.clip solid();
		}
	}
	else 
	{
		for ( i = 0; i < level.data_maps[ "perks" ][ "power_notifies" ].size; i++ )
		{
			level thread server_safe_notify_thread( level.data_maps[ "perks" ][ "power_notifies" ][ i ] + "_off", i );
			level.data_maps[ "perks" ][ "is_active" ][ i ] = "0";
			trigger = getent( level.data_maps[ "perks" ][ "specialties" ][ i ], "script_noteworthy" );
			trigger.machine ghost();
			trigger.clip notSolid();
		}
	}
	result[ "message" ] = va( "gamerule:perks: Perks are powered %s", cast_bool_to_str( new_powerup_restrictions_state, "on off" ) );
	result[ "channels" ] = "con say g_log";
	result[ "filter" ] = "cmdinfo";
	return result;
}

//togperk(<perk_specialty_name|perk_power_notify_name>)
CMD_TOGGLEPERK_f( arg_list )
{
	if ( array_validate( arg_list ) )
	{
		perk_arg = arg_list[ 0 ];
		perk_speciality_names = level.data_maps[ "perks" ][ "specialties" ];
		perk_power_notify_names = level.data_maps[ "perks" ][ "power_notifies" ];
		for ( i = 0; i < perk_speciality_names.size; i++ )
		{
			if ( isSubStr( perk_speciality_names[ i ], perk_arg ) || isSubStr( perk_power_notify_names[ i ], perk_arg ) )
			{
				perk = perk_speciality_names[ i ];
				cur_state = isSubStr( level.grief_restrictions[ "perks" ], perk );
				cur_keys = strTok( level.grief_restrictions[ "perks" ], " " );
				trigger = getent( va( "specialty_%s", level.data_maps[ "perks" ][ "specialties" ][ i ] ), "script_noteworthy" );
				if ( !cur_state )
				{
					level thread server_safe_notify_thread( level.data_maps[ "perks" ][ "power_notifies" ][ i ] + "_off", i );
					level.data_maps[ "perks" ][ "is_active" ][ i ] = "0";
					cur_keys[ cur_keys.size ] = perk;
					level.grief_restrictions[ "perks" ] = concatenate_array( cur_keys, " " );
					trigger.machine ghost();
					trigger.clip notSolid();
				}
				else 
				{
					level thread server_safe_notify_thread( level.data_maps[ "perks" ][ "power_notifies" ][ i ] + "_on", i );
					level.data_maps[ "perks" ][ "is_active" ][ i ] = "1";
					level.grief_restrictions[ "perks" ] = concatenate_array( remove_tokens_from_array( cur_keys, perk ), " " );
					trigger.machine show();
					trigger.clip solid();
				}
				break;
			}
		}
		if ( !isDefined( perk ) )
		{
			result[ "message" ] = va( "gamerule:perks: Invalid %s perk name", perk_arg );
			result[ "filter" ] = "cmderror";
		}
		else 
		{
			result[ "message" ] = va( "gamerule:perks: Perk %s is now powered %s", perk, cast_bool_to_str( new_powerup_restrictions_state, "on off" ) );
			result[ "channels" ] = "con say g_log";
			result[ "filter" ] = "cmdinfo";
		}
	}
	else 
	{
		result[ "message" ] = "gamerule:perks: Missing perk arg";
		result[ "filter" ] = "cmderror";
	}
	new_powerup_restrictions_state = level.grief_restrictions[ "perks" ] == "all";
	new_powerup_restrictions_value = new_powerup_restrictions_state ? "" : "all";
	setDvar( "grief_restrictions_powerups", new_powerup_restrictions_value );
	return result;
}

CMD_TOGGLEALLPOWERUPS_f( arg_list )
{
	forced_powerups_state = arg_list[ 0 ];
	if ( isDefined( forced_powerups_state ) )
	{
		level.grief_restrictions[ "powerups" ] = !forced_powerups_state ? "all" : "";
		if ( !forced_powerups_state )
		{
			flag_clear( "zombie_drop_powerups" );
		}
		else 
		{
			flag_set( "zombie_drop_powerups" );
		}
		result[ "message" ] = va( "gamerule:powerups: Powerups are %s", cast_bool_to_str( forced_powerups_state, "enabled disabled" ) );
	}
	else
	{
		new_powerup_restrictions_state = level.grief_restrictions[ "powerups" ] != "all";
		level.grief_restrictions[ "powerups" ] = new_powerup_restrictions_state ? "all" : "";
		flag_toggle( "zombie_drop_powerups" );
		result[ "message" ] = va( "gamerule:powerups: Powerups are %s", cast_bool_to_str( new_powerup_restrictions_state, "enabled disabled" ) );
	}
	result[ "channels" ] = "con say g_log";
	result[ "filter" ] = "cmdinfo";
	return result;
}

CMD_TOGGLEMAGIC_f( arg_list )
{
	new_magic_state = !level.grief_gamerules[ "magic" ];
	level.grief_gamerules[ "magic" ] = new_magic_state;
	self CMD_EXECUTE( "gamerule", "togallpowerups", new_magic_state );
	self CMD_EXECUTE( "gamerule", "togallperks", new_magic_state );
	//self CMD_EXECUTE( "gamerule", "togbox" );
	result[ "message" ] = va( "gamerule:magic: Magic is %s", cast_bool_to_str( new_magic_state, "enabled disabled" ) );
	result[ "channels" ] = "con say g_log";
	result[ "filter" ] = "cmdinfo";
	return result;
}

CMD_TEAM_UNPERM_f( arg_list )
{
	result = [];
	outcome = set_key_value_from_value( "grief_preset_teams", getDvar( "grief_preset_teams" ), player_name, "is_perm", false );
	if ( outcome[ "error_msg" ] == 0 )
	{
		result[ "filter" ] = "cmdinfo";
		result[ "message" ] = va( "team:perm: Successfully set entry for %s to be temporary", player_name );
	}
	else 
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = va( "team:unperm: Failed to set entry for %s to be temporary %s", player_name, outcome[ "error_msg" ] );
	}
	return result;
}

CMD_TEAM_PERM_f( arg_list )
{
	result = [];
	outcome = set_key_value_from_value( "grief_preset_teams", getDvar( "grief_preset_teams" ), player_name, "is_perm", true );
	if ( outcome[ "error_msg" ] == 0 )
	{
		result[ "filter" ] = "cmdinfo";
		result[ "message" ] = va( "team:perm: Successfully set entry for %s to be permanent", player_name );
	}
	else 
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = va( "team:unban: Failed to set entry for %s to be permanent %s", player_name, outcome[ "error_msg" ] );
	}
	return result;
}

CMD_TEAM_UNBAN_f( arg_list )
{
	result = [];
	outcome = set_key_value_from_value( "grief_preset_teams", getDvar( "grief_preset_teams" ), player_name, "is_banned", false );
	if ( outcome[ "error_msg" ] == 0 )
	{
		result[ "filter" ] = "cmdinfo";
		result[ "message" ] = va( "team:unban: Successfully unbanned %s from changing teams", player_name );
	}
	else 
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = va( "team:unban: Failed to unban %s from changing teams %s", player_name, outcome[ "error_msg" ] );
	}
	return result;
}

CMD_TEAM_BAN_f( arg_list )
{
	result = [];
	outcome1 = set_key_value_from_value( "grief_preset_teams", getDvar( "grief_preset_teams" ), player_name, "is_banned", true );
	outcome2 = set_key_value_from_value( "grief_preset_teams", getDvar( "grief_preset_teams" ), player_name, "is_perm", true );
	if ( outcome1[ "error_msg" ] == 0 && outcome2[ "error_msg" ] == 0 )
	{
		result[ "filter" ] = "cmdinfo";
		result[ "message" ] = va( "team:ban: Successfully banned %s from changing teams", player_name );
	}
	else 
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = va( "team:ban: Failed to ban %s from changing teams %s %s", player_name, outcome2[ "error_msg" ], outcome1[ "error_msg" ] );
	}
	return result;
}

CMD_TEAM_SET_f( arg_list )
{
	player_name = arg_list[ 0 ];
	team_name = arg_list[ 1 ];
	result = [];
	if ( isDefined( level.teams[ team_name ] ) )
	{
		outcome = set_key_value_from_value( "grief_preset_teams", getDvar( "grief_preset_teams" ), player_name, "team_name", team_name );
		if ( outcome[ "error_msg" ] == 0 )
		{
			result[ "filter" ] = "cmdinfo";
			result[ "message" ] = va( "team:set: Successfully changed %s to team %s", player_name, team_name );
		}
		else 
		{
			result[ "filter" ] = "cmderror";
			result[ "message" ] = va( "team:set: Failed to change %s to team %s %s", player_name, team_name, outcome[ "error_msg" ] );
		}
	}
	else 
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = va( "team:set: Tried to set %s to invalid team %s", player_name, team_name );
	}
	return result;
}

CMD_TEAM_REMOVE_f( arg_list )
{
	player_name = arg_list[ 0 ];
	result = [];
	new_tokens = remove_tokens_from_array( strTok( getDvar( "grief_preset_teams" ), ";" ), player_name );
	setDvar( "grief_preset_teams", concatenate_array( new_tokens, ";" ) );
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = va( "team:remove: Successfully removed %s from preset teams.", player_name );
	return result;
}

CMD_TEAM_ADD_f( arg_list )
{
	player_name = arg_list[ 0 ];
	team_name = arg_list[ 1 ];
	is_perm = arg_list[ 2 ];
	is_banned = arg_list[ 3 ];
	cur_tokens = strTok( getDvar( "grief_preset_teams" ), ";" );
	new_tokens = [];
	result = [];
	if ( !isDefined( player_name ) || !isDefined( team_name ) )
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "team:add: Missing player or team name arg.";
		return result;
	}
	new_tokens = concatenate_array( remove_tokens_from_array( cur_tokens, player_name ), ";" );
	if ( !isDefined( is_perm ) )
	{
		is_perm = "0";
	}
	if ( !isDefined( is_banned ) )
	{
		is_banned = "0";
	}
	if ( is_perm == "true" )
	{
		is_perm = "1";
	}
	else if ( is_perm == "false" )
	{
		is_perm = "0";
	}
	else if ( int( is_perm ) != 0 || int( is_perm ) != 1 )
	{
		is_perm = "0";
	}
	add_new_preset_team_token( new_tokens, player_name, team_name, is_perm, is_banned );
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = va( "team:add: Successfully added %s to team %s", player_name, team_name );
	return result;
}