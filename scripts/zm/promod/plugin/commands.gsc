#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include scripts/zm/promod/utility/_grief_util;
#include maps/mp/zombies/_zm_perks;
#include scripts/zm/promod/zgriefp;
#include scripts/zm/promod/zgriefp_overrides;
#include scripts/zm/promod/utility/_vote;
#include scripts/zm/promod/utility/_com;
#include scripts/zm/promod/_gametype_setup;
#include scripts/zm/promod/utility/_text_parser;

CMD_INIT()
{
	if ( getDvar( "grief_original_rotation" ) == "" )
	{
		setDvar( "grief_original_rotation", getDvar( "sv_maprotation" ) );
	}
	level.server = spawnStruct();
	level.server.name = getDvar( "sv_hostname" );
	level.server.is_server = true;
	level.custom_commands_restart_countdown = 5;
	CMD_ADDCOMMAND( "team t", "add a", ::CMD_TEAM_ADD_f );
	CMD_ADDCOMMAND( "team t", "remove r", ::CMD_TEAM_REMOVE_f );
	CMD_ADDCOMMAND( "team t", "set s", ::CMD_TEAM_SET_f );
	CMD_ADDCOMMAND( "team t", "ban b", ::CMD_TEAM_BAN_f );
	CMD_ADDCOMMAND( "team t", "unban u", ::CMD_TEAM_UNBAN_f );
	CMD_ADDCOMMAND( "team t", "perm p", ::CMD_TEAM_PERM_f );
	CMD_ADDCOMMAND( "team t", "unperm up", ::CMD_TEAM_UNPERM_f );
	CMD_ADDCOMMAND( "utility u", "cmdlist cl", ::CMD_UTILITY_CMDLIST_f, true );
	CMD_ADDCOMMAND( "client c", "cvar cv", ::CMD_CLIENT_CVAR_f );
	CMD_ADDCOMMAND( "admin a", "kick k", ::CMD_ADMIN_KICK_f );
	CMD_ADDCOMMAND( "admin a", "lock l", ::CMD_LOCK_SERVER_f );
	CMD_ADDCOMMAND( "admin a", "unlock ul", ::CMD_UNLOCK_SERVER_f );
	CMD_ADDCOMMAND( "admin a", "playerlist plist", ::CMD_PLAYERLIST_f, true );
	CMD_ADDCOMMAND( "admin a", "dvar d", ::CMD_SERVER_DVAR_f );
	CMD_ADDCOMMAND( "admin a", "cvarall ca", ::CMD_CLIENT_CVARALL_f );
	CMD_ADDCOMMAND( "admin a", "restart mr", ::CMD_RESTART_f, true );
	CMD_ADDCOMMAND( "admin a", "rotate r", ::CMD_ROTATE_f, true );
	CMD_ADDCOMMAND( "admin a", "nextmap nm", ::CMD_NEXTMAP_f );
	CMD_ADDCOMMAND( "admin a", "changemap cm", ::CMD_CHANGEMAP_f, true );
	CMD_ADDCOMMAND( "admin a", "resetrotation rr", ::CMD_RESETROTATION_f );
	CMD_ADDCOMMAND( "admin a", "randomnextmap rnm", ::CMD_RANDOMNEXTMAP_f );
	CMD_ADDCOMMAND( "gamerule g", "togmagic tm", ::CMD_TOGGLEMAGIC_f );
	CMD_ADDCOMMAND( "gamerule g", "togallpowerups togallpups", ::CMD_TOGGLEALLPOWERUPS_f );
	CMD_ADDCOMMAND( "gamerule g", "togallperks togallpks", ::CMD_TOGGLEALLPERKS_f );
	CMD_ADDCOMMAND( "gamerule g", "togpower togpow", ::CMD_TOGGLEPOWER_f );
	CMD_ADDCOMMAND( "gamerule g", "togperkrestrictions togpkr", ::CMD_TOGGLEPERKRESTRICTIONS_f );
	CMD_ADDCOMMAND( "gamerule g", "togperk togpk", ::CMD_TOGGLEPERK_f );
	CMD_ADDCOMMAND( "vote v", "start s", ::CMD_VOTESTART_f, true );
	VOTE_INIT();

	CMD_ADDCOMMANDLISTENER( "listener_cmdlist", "showmore" );
	CMD_ADDCOMMANDLISTENER( "listener_cmdlist", "page" );
	CMD_ADDCOMMANDLISTENER( "listener_playerlist", "showmore" );
	CMD_ADDCOMMANDLISTENER( "listener_playerlist", "page" );
	CMD_ADDCOMMANDLISTENER( "listener_vote", "yes" );
	CMD_ADDCOMMANDLISTENER( "listener_vote", "no" );

	level thread COMMAND_BUFFER();
}

CMD_VOTESTART_f( arg_list )
{
	channel = is_true( self.is_server ) ? "con" : "tell";
	if ( !is_true( self.is_server ) && !is_true( self.is_admin ) )
	{
		if ( is_true( self.vote_started ) )
		{
			COM_PRINTF( channel, "cmderror", "vote:start: You cannot start a new vote for the remainder of this match.", self );
			return;
		}
	}
	if ( is_true( level.vote_in_progress ) )
	{
		COM_PRINTF( channel, "cmderror", va( "vote:start: You cannot start a new vote until the current vote is finished in %s seconds.", level.vote_in_progress_timeleft ), self );
		return;
	}
	key_type = arg_list[ 0 ];
	key_value_or_cmd_arg_0 = arg_list[ 1 ];
	if ( key_value_or_cmd_arg_0 == "start" || key_value_or_cmd_arg_0 == "s" )
	{
		COM_PRINTF( channel, "cmderror", "vote:start: Nice try.", self );
		return;
	}
	cmd_arg_1 = arg_list[ 2 ];
	cmd_arg_2 = arg_list[ 3 ];
	cmd_arg_3 = arg_list[ 4 ];
	if ( !isDefined( key_type ) || !isDefined( key_value_or_cmd_arg_0 ) )
	{
		COM_PRINTF( channel, "cmderror", "vote:start: Missing params, 2 args required <key_type>, <key_value>.", self );
		return;
	}
	if ( level.vote_start_anonymous )
	{
		name = "Anon";
	}
	else 
	{
		name = self.name;
	}
	switch ( key_type )
	{
		// case "d":
		// case "dvar":
		// 	if ( isDefined( cmd_arg_1 ) )
		// 	{
		// 		COM_PRINTF( "con say g_log", "cmdinfo", va( "vote:start: %s would like to set %s to %s", name, key_value_or_cmd_arg_0, cmd_arg_1 ), self );
		// 	}
		// 	else 
		// 	{
		// 		COM_PRINTF( channel, "cmderror", "vote:start: Dvar set requires <dvar name>, and <dvar value>.", self );
		// 		return;
		// 	}
		// 	break;
		case "ca":
		case "cvarall":
			if ( isDefined( cmd_arg_1 ) && getDvar( key_value_or_cmd_arg_0 ) != "" )
			{
				COM_PRINTF( "con say g_log", "cmdinfo", va( "vote:start: %s would like to set %s to %s", name, key_value_or_cmd_arg_0, cmd_arg_1 ), self );
			}
			else 
			{
				COM_PRINTF( channel, "cmderror", "vote:start: Cvar set requires a valid <dvar name>, and <dvar value>.", self );
				return;
			}
			break;
		case "k":
		case "kick":
			player_data = find_player_in_server( key_value_or_cmd_arg_0 );
			if ( isDefined( key_value_or_cmd_arg_0 ) && isDefined( player_data ) )
			{
				COM_PRINTF( "con say g_log", "cmdinfo", va( "vote:start: %s would like to kick %s.", name, player_data[ "name" ] ), self );
			}
			else 
			{
				COM_PRINTF( channel, "cmderror", "vote:start: Could not find player.", self );
				return;
			}
			break;
		case "nm":
		case "nextmap":
			rotation_data = find_map_data_from_alias( alias );
			if ( rotation_data[ "mapname" ] != "" )
			{
				COM_PRINTF( "con say g_log", "cmdinfo", va( "vote:start: %s would like to set the next map to %s.", name, get_map_display_name_from_location( rotation_data[ "location" ] ) ), self );
			}
			else 
			{
				COM_PRINTF( channel, "cmderror", "vote:start: Could not find map from alias.", self );
				return;
			}
			break;
		case "g":
		case "gamerule":
			is_threaded_cmd = false;
			indexable_cmdname = "";
			screen_name = "";
			cmd_keys = getArrayKeys( level.custom_commands[ "gamerule g" ] );
			for ( i = 0; ( i < cmd_keys.size ) && indexable_cmdname == ""; i++ )
			{
				cmd_aliases = strTok( cmd_keys[ i ], " " );
				for ( j = 0; j < cmd_aliases.size; j++ )
				{
					if ( key_value_or_cmd_arg_0 == cmd_aliases[ j ] )
					{
						indexable_cmdname = cmd_keys[ i ];
						screen_name = cmd_aliases[ 0 ];
						if ( isDefined( level.custom_threaded_commands[ cmd_aliases[ j ] ] ) )
						{
							is_threaded_cmd = true;
						}
						break;
					}
				}
			}
			if ( indexable_cmdname != "" )
			{
				COM_PRINTF( "con say g_log", "cmdinfo", va( "vote:start: %s would like to execute gamerule cmd %s.", name, screen_name ), self );
			}
			else 
			{
				COM_PRINTF( channel, "cmderror", "vote:start: Could not find gamerule cmd from alias.", self );
				return;
			}
			break;
		default:
			COM_PRINTF( channel, "cmderror", va( "vote:start: Unsupported key_type %s recevied." ), self );
			return;
	}
	COM_PRINTF( "con say", "notitle", va( "You have %s seconds to cast your vote.", level.vote_timeout ), self );
	COM_PRINTF( "con say", "notitle", "Do /yes or /no to vote.", self );
	COM_PRINTF( "con say", "notitle", "Outcome is determined from players who cast a vote, not from the total players.", self );
	level thread vote_timeout_countdown();
	level.vote_in_progress_votes = [];
	foreach ( player in level.players )
	{
		player thread player_track_vote();
	}
	level thread count_votes();
	level.vote_in_progress = true;
	self.vote_started = true;
	level waittill( "vote_ended", result );
	level.vote_in_progress = false;
	if ( !result )
	{
		return;
	}
	switch ( key_type )
	{
		// case "c":
		// case "command":
		// 	CMD_EXECUTE( namespace, cmdname, arg_list )
		// 	break;
		// case "d":
		// case "dvar":
		// 	setDvar( key_value_or_cmd_arg_0, cmd_arg_1 );
		// 	break;
		case "cv":
		case "cvar":
			args = [];
			args[ 0 ] = key_value_or_cmd_arg_0;
			args[ 1 ] = cmd_arg_1;
			CMD_CLIENT_CVARALL_f( args );
			break;
		case "k":
		case "kick":
			args = [];
			args[ 0 ] = player_data[ "guid" ];
			CMD_ADMIN_KICK_f( args );
			break;
		case "nm":
		case "nextmap":
			args = [];
			args[ 0 ] = key_value_or_cmd_arg_0;
			CMD_NEXTMAP_f( arg_list );
			break;
		case "g":
		case "gamerule":
			CMD_EXECUTE( "gamerule", screen_name, undefined );
			break;
	}
}

CMD_TOGGLEPOWER_f( arg_list )
{
	new_power_state = !level.grief_gamerules[ "power_start_state" ] ? true: false;
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
	new_perks_restrictions_state = new_perk_restrictions_value == "" ? true : false;
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
				cur_state = isSubStr( level.grief_restrictions[ "perks" ], perk ) ? true : false;
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
	new_powerup_restrictions_state = level.grief_restrictions[ "perks" ] == "all" ? true : false;
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
		new_powerup_restrictions_state = level.grief_restrictions[ "powerups" ] != "all" ? true : false;
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

CMD_RANDOMNEXTMAP_f( arg_list )
{
	channel = is_true( self.is_server ) ? "con" : "tell";
	string = "c s f t b d tu p";
	alias_keys = strTok( string, " " );
	random_alias = random( alias_keys );
	rotation_data = find_map_data_from_alias( random_alias );
	rotation_string = va( "exec zm_%s_%s.cfg map %s", rotation_data[ "gamemode" ], rotation_data[ "location" ], rotation_data[ "mapname" ] );
	setDvar( "sv_maprotation", rotation_string );
	setDvar( "sv_maprotationCurrent", rotation_string );
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "admin:randomnextmap: Set new secret random map";
	return result;
}

CMD_RESETROTATION_f( arg_list )
{
	setDvar( "sv_maprotation", getDvar( "grief_original_rotation" ) );
	setDvar( "sv_maprotationCurrent", getDvar( "grief_original_rotation" ) );
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "admin:resetrotation: Successfully reset the map rotation";
	return result;
}

CMD_CHANGEMAP_f( arg_list )
{
	self notify( "changemap_f" );
	self endon( "changemap_f" );
	channel = is_true( self.is_server ) ? "con" : "tell";
	if ( array_validate( arg_list ) )
	{
		alias = toLower( arg_list[ 0 ] );
		rotation_data = find_map_data_from_alias( alias );
		if ( rotation_data[ "mapname" ] != "" )
		{
			rotation_string = va( "exec zm_%s_%s.cfg map %s", rotation_data[ "gamemode" ], rotation_data[ "location" ], rotation_data[ "mapname" ] );
			message = va( "admin:changemap: %s second rotate to map %s countdown started", level.custom_commands_restart_countdown, get_map_display_name_from_location( rotation_data[ "location" ] ) );
			COM_PRINTF( "g_log " + channel, "cmdinfo", self.name + " executed " + message );
			setDvar( "sv_maprotation", rotation_string );
			setDvar( "sv_maprotationCurrent", rotation_string );
			for ( i = level.custom_commands_restart_countdown; i > 0; i-- )
			{
				COM_PRINTF( "con say", "cmdinfo", va( "%s seconds", i ) );
				wait 1;
			}
			level notify( "end_commands" );
			wait 0.5;
			exitLevel( false );
			return;
		}
	}
	COM_PRINTF( channel, "cmderror", va( "admin:changemap: alias %s is invalid", alias ), self );
}

CMD_NEXTMAP_f( arg_list )
{
	if ( array_validate( arg_list ) )
	{
		alias = toLower( arg_list[ 0 ] );
		rotation_data = find_map_data_from_alias( alias );
		if ( rotation_data[ "mapname" ] != "" )
		{
			rotation_string = va( "exec zm_%s_%s.cfg map %s", rotation_data[ "gamemode" ], rotation_data[ "location" ], rotation_data[ "mapname" ] );
			setDvar( "sv_maprotation", rotation_string );
			setDvar( "sv_maprotationCurrent", rotation_string );
			result[ "filter" ] = "cmdinfo";
			result[ "message" ] = va( "admin:nextmap: Successfully set next map to %s", get_map_display_name_from_location( rotation_data[ "location" ] ) );
		}
		else 
		{
			result[ "filter" ] = "cmderror";
			result[ "message" ] = va( "admin:nextmap: Bad map alias %s", alias );
		}
	}
	else 
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "admin:nextmap: Failed to set next map due to missing param";
	}
	return result;
}

CMD_ROTATE_f( arg_list )
{
	self notify( "rotate_f" );
	self endon( "rotate_f" );
	channel = is_true( self.is_server ) ? "con" : "tell";
	message = va( "admin:rotate: %s second rotate countdown started", level.custom_commands_restart_countdown );
	COM_PRINTF( "g_log " + channel, "cmdinfo", self.name + " executed " + message );
	for ( i = level.custom_commands_restart_countdown; i > 0; i-- )
	{
		wait 1;
		COM_PRINTF( "con say", "cmdinfo", va( "%s seconds", i ) );
	}
	level notify( "end_commands" );
	wait 0.5;
	exitLevel( false );
}

CMD_RESTART_f( arg_list )
{
	self notify( "restart_f" );
	self endon( "restart_f" );
	channel = is_true( self.is_server ) ? "con" : "tell";
	message = va( "admin:restart: %s second restart countdown started", level.custom_commands_restart_countdown );
	COM_PRINTF( "g_log " + channel, "cmdinfo", self.name + " executed " + message );
	for ( i = level.custom_commands_restart_countdown; i > 0; i-- )
	{
		wait 1;
		COM_PRINTF( "con say", "cmdinfo", va( "%s seconds", i ) );
	}
	level notify( "end_commands" );
	wait 0.5;
	map_restart( false );
}

/*private*/ COMMAND_COOLDOWN()
{
	level.players_in_session[ self.name ].command_cooldown = level.players_in_session[ self.name ].server_rank_system[ "privileges" ][ "cmd_cooldown" ];
	while ( level.players_in_session[ self.name ].command_cooldown > 0 )
	{
		level.players_in_session[ self.name ].command_cooldown--;
		wait 1;
	}
}

CMD_PLAYERLIST_f( arg_list )
{
	self notify( "playerlist_f" );
	self endon( "playerlist_f" );
	channel = is_true( self.is_server ) ? "con" : "tell";
	current_page = 1;
	user_defined_page = 1;
	if ( array_validate( arg_list ) )
	{
		team_name = arg_list[ 0 ];
	}
	if ( isDefined( team_name ) && isDefined( level.teams[ team_name ] ) )
	{
		players = getPlayers( team_name );
	}
	else 
	{
		players = getPlayers();
	}
	remaining_players = players.size;
	remaining_pages = ceil( remaining_players / level.custom_commands_page_max );
	for ( j = 0; j < players.size; j++ )
	{
		message = va( "%s %s %s", players[ i ].name, players[ i ] getGUID(), players[ i ] getEntityNumber() ); //remember to add rank as a listing option
		if ( channel == "con" )
		{
			COM_PRINTF( channel, "cmdinfo", message, self );
		}
		else 
		{
			cmds_to_display[ cmds_to_display.size ] = message;
		}
		remaining_players--;
		if ( ( cmds_to_display.size > remaining_pages ) && channel == "tell" && remaining_players != 0 )
		{
			if ( current_page == user_defined_page )
			{
				foreach ( message in cmds_to_display )
				{
					COM_PRINTF( channel, "cmdinfo", message, self );
				}
				COM_PRINTF( channel, "cmdinfo", va( "Displaying page %s out of %s do /showmore or /page(num) to display more players.", current_page, remaining_pages ), self );
				setup_temporary_command_listener( "listener_playerlist", level.custom_commands_listener_timeout, self );
				self waittill( "listener_playerlist", result, args );
				clear_temporary_command_listener( "listener_playerlist", self );
				if ( result == "timeout" )
				{
					return;
				}
				else if ( isSubStr( result, "page" ) )
				{
					user_defined_page = int( args[ 0 ] );
					if ( !isDefined( user_defined_page ) )
					{
						COM_PRINTF( channel, "cmderror", va( "Page number arg sent to utility:cmdlist is undefined. Valid inputs are 1 thru %s.", remaining_pages ), self );
						return;
					}
					if ( user_defined_page > remaining_pages || user_defined_page == 0 )
					{
						COM_PRINTF( channel, "cmderror", va( "Page number %s sent to utility:cmdlist is invalid. Valid inputs are 1 thru %s.", args[ 0 ], remaining_pages ), self );
						return;
					}
				}
				else if ( result == "showmore" )
				{
					user_defined_page++;
				}
			}
			current_page++;
			cmds_to_display = [];
		}
		else if ( remaining_players == 0 )
		{
			foreach ( message in cmds_to_display )
			{
				COM_PRINTF( channel, "cmdinfo", message, self );
			}
		}
	}
}

CMD_LOCK_SERVER_f( arg_list )
{
	if ( array_validate( arg_list ) )
	{
		password = arg_list[ 0 ];
		setDvar( "g_password", password );
		result[ "filter" ] = "cmdinfo";
		result[ "message" ] = va( "admin:lock: Successfully locked the server with key %s", password );
	}
	else 
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "admin:lock: Failed to lock server due to missing param";
	}
	return result;
}

CMD_UNLOCK_SERVER_f( arg_list )
{
	setDvar( "g_password", "" );
	result[ "filter" ] = "cmdinfo";
	result[ "message" ] = "admin:unlock: Successfully unlocked the server";
	return result;
}

CMD_SERVER_DVAR_f( arg_list )
{
	result = [];
	if ( array_validate( arg_list ) && arg_list.size == 2 )
	{
		dvar_name = arg_list[ 0 ];
		dvar_value = arg_list[ 1 ];
		setDvar( dvar_name, dvar_value );
		result[ "filter" ] = "cmdinfo";
		result[ "message" ] = va( "admin:dvar: Successfully set %s to %s", dvar_name, dvar_value );
	}
	else 
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "admin:dvar: Failed to set dvar due to missing params";
	}
	return result;
}

CMD_ADMIN_KICK_f( arg_list )
{
	result = [];
	kicked = false;
	if ( array_validate( arg_list ) )
	{
		player_data = find_player_in_server( arg_list[ 0 ] );
		if ( isDefined( player_data ) )
		{
			kick( player_data[ "clientnum" ] );
			kicked = true;
		}
	}
	if ( kicked )
	{
		result[ "filter" ] = "cmdinfo";
		result[ "message" ] = va( "admin:kick: Successfully kicked %s", player.name );
	}
	else 
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = va( "admin:kick: Failed to kick %s", player.name );
	}
	return result;
}

CMD_CLIENT_CVAR_f( arg_list )
{
	result = [];
	if ( array_validate( arg_list ) && arg_list.size == 2 )
	{
		dvar_name = arg_list[ 0 ];
		dvar_value = arg_list[ 1 ];
		self setClientDvar( dvar_name, dvar_value );
		result[ "filter" ] = "cmdinfo";
		result[ "message" ] = va( "client:cvar: Successfully set %s %s to %s", self.name, dvar_name, dvar_value );
	}
	else 
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = va( "client:cvar: Failed to set cvar for %s due to missing params", self.name );
	}
	return result;
}

CMD_CLIENT_CVARALL_f( arg_list )
{
	result = [];
	if ( array_validate( arg_list ) && arg_list.size == 2 )
	{
		dvar_name = arg_list[ 0 ];
		dvar_value = arg_list[ 1 ];
		foreach ( player in level.players )
		{
			player setClientDvar( dvar_name, dvar_value );
		}
		result[ "filter" ] = "cmdinfo";
		result[ "message" ] = va( "admin:cvarall: Successfully set %s to %s for all players", dvar_name, dvar_value );
	}
	else 
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = va( "admin:cvarall: Failed to set cvar for all players due to missing params", self.name );
	}
	return result;
}

CMD_ADDCOMMANDLISTENER( listener_name, listener_cmd )
{
	if ( !isDefined( level.listener_commands ) )
	{
		level.listener_commands = [];
	}
	if ( !isDefined( level.listener_commands[ listener_name ] ) )
	{
		level.listener_commands[ listener_name ] = [];
	}
	if ( !isDefined( level.listener_commands[ listener_name ][ listener_cmd ] ) )
	{
		level.listener_commands[ listener_name ][ listener_cmd ] = true;
	}
}

CMD_ISCOMMANDLISTENER( listener_name, listener_cmd )
{
	return is_true( level.listener_commands[ listener_name ][ listener_cmd ] );
}

CMD_EXECUTELISTENER( listener_name, listener_cmd, arg_list )
{
	self notify( listener_name, listener_cmd, arg_list );
}

CMD_ADDCOMMAND( namespace_aliases, cmdaliases, cmdfunc, is_thread_cmd )
{
	if ( !isDefined( level.custom_commands ) )
	{
		level.custom_commands = [];
		level.custom_commands_namespaces_total = 0;
		level.custom_commands_total = 0;
		level.custom_commands_page_count = 0;
		level.custom_commands_page_max = 5;
		level.custom_commands_listener_timeout = 12;
	}
	if ( !isDefined( level.custom_commands[ namespace_aliases ] ) )
	{
		level.custom_commands[ namespace_aliases ] = [];
		level.custom_commands_namespaces_total++;
	}
	if ( !isDefined( level.custom_commands[ namespace_aliases ][ cmdaliases ] ) )
	{
		level.custom_commands[ namespace_aliases ][ cmdaliases ] = cmdfunc;
		level.custom_commands_total++;
		if ( level.custom_commands_total % 6 )
		{
			level.custom_commands_page_count++;
		}
		if ( is_true( is_threaded_cmd ) )
		{
			level.custom_threaded_commands[ cmdaliases ] = true;
		}
	}
	else 
	{
		COM_PRINTF( "con con_log", "error", va( "Command %s is already defined in namespace %s", cmdaliases, namespace_aliases ) );
	}
}

CMD_EXECUTE( namespace, cmdname, arg_list )
{
	if ( array_validate( self.temp_listeners ) )
	{
		listener_keys = getArrayKeys( self.temp_listeners );
		foreach ( listener in listener_keys )
		{
			if ( CMD_ISCOMMANDLISTENER( listener, cmdname ) )
			{
				self CMD_EXECUTELISTENER( listener, cmdname, arg_list );
				return;
			}
		}
	}
	indexable_cmdname = "";
	is_threaded_cmd = false;
	if ( namespace != "" )
	{
		cmd_keys = getArrayKeys( level.custom_commands[ namespace ] );
		for ( i = 0; ( i < cmd_keys.size ) && indexable_cmdname == ""; i++ )
		{
			cmd_aliases = strTok( cmd_keys[ i ], " " );
			for ( j = 0; j < cmd_aliases.size; j++ )
			{
				if ( cmdname == cmd_aliases[ j ] )
				{
					indexable_cmdname = cmd_keys[ i ];
					if ( isDefined( level.custom_threaded_commands[ cmd_aliases[ j ] ] ) )
					{
						is_threaded_cmd = true;
					}
					break;
				}
			}
		}
	}
	can_execute_cmd = indexable_cmdname != "" ? true : false;
	if ( can_execute_cmd )
	{
		if ( is_threaded_cmd )
		{
			self thread [[ level.custom_commands[ namespace ][ indexable_cmdname ] ]]( arg_list );
		}
		else 
		{
			result = self [[ level.custom_commands[ namespace ][ indexable_cmdname ] ]]( arg_list );
		}
	}
	channel = is_true( self.is_server ) ? "con" : "tell";
	if ( isDefined( result ) && result[ "filter" ] != "cmderror" )
	{
		message = self.name + " executed " + result[ "message" ];
		if ( isDefined( result[ "channels" ] ) )
		{
			COM_PRINTF( result[ "channels" ], result[ "filter" ], message, self );
		}
		else 
		{
			COM_PRINTF( "g_log " + channel, result[ "filter" ], message, self );
		}
	}
	else if ( !is_threaded_cmd )
	{
		if ( namespace == "" )
		{
			COM_PRINTF( channel, "cmderror", "Command bad namespace", self );
		}
		else if ( indexable_cmdname == "" )
		{
			COM_PRINTF( channel, "cmderror", "Command not found in namespace", self );
			COM_PRINTF( channel, "cmdinfo", "Got:" + namespace, self );
		}
		else 
		{
			message = self.name + " executed " + result[ "message" ];
			COM_PRINTF( channel, result[ "filter" ], message, self );
		}
	}
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

//Command struture - namespace:cmd(...);
/*public*/ COMMAND_BUFFER()
{
	level endon( "end_commands" );
	level thread end_commands_on_end_game();
	while ( true )
	{
		level waittill( "say", message, player );
		if ( isDefined( player ) && !isSubStr( message, ":" ) )
		{
			continue;
		}
		if ( !isDefined( player ) )
		{
			player = level.server;
		}
		channel = is_true( player.is_server ) ? "con" : "tell";
		multi_cmds = parse_cmd_message( message );
		if ( !array_validate( multi_cmds ) )
		{
			continue;
		}
		if ( level.players_in_session[ player.name ].command_cooldown == 0 && !player.is_server )
		{
			for ( cmd_index = 0; cmd_index < multi_cmds.size; cmd_index++ )
			{
				namespace = toLower( multi_cmds[ cmd_index ][ "namespace" ] );
				cmdname = toLower( multi_cmds[ cmd_index ][ "cmdname" ] );
				args = multi_cmds[ cmd_index ][ "args" ];
				if ( !player has_permission_for_cmd( namespace, cmdname ) )
				{
					COM_PRINTF( "tell", "cmderror", va( "You do not have permission to use %s command.", cmdname ), player );
				}
				else 
				{
					COM_PRINTF( channel, "cmdinfo", va( "Used namespace %s cmd %s", namespace, cmdname ), player );
					player CMD_EXECUTE( namespace, cmdname, args );
					player thread COMMAND_COOLDOWN();
				}
			}
		}
		else 
		{
			COM_PRINTF( "tell", "cmderror", va( "You cannot use another command for %s seconds", level.players_in_session[ player.name ].command_cooldown ), player );
		}
	}
}

/*private*/ set_round( round_number )
{
	start_new_round( true, round_number );
}

/*public*/ has_permission_for_cmd( namespace, cmd )
{
	if ( is_true( self.is_server ) || is_true( self.is_admin ) )
	{
		return true;
	}
	player_guid = self getGUID();
	foreach ( guid in level.server_users[ "admins" ].guids )
	{
		if ( player_guid == guid )
		{
			self.is_admin = true;
			return true;
		}
	}
	foreach ( namespace in level.grief_no_permissions_required_namespaces )
	{
		namespace_keys = strTok( namespace, " " );
		for ( i = 0; i < namespace_keys.size; i++ )
		{
			if ( namespace == namespace_keys[ i ] )
			{
				return true;
			}
		}
	}
	return false;
}

/*private*/ CMD_UTILITY_CMDLIST_f( arg_list )
{	
	self notify( "cmdlist_f" );
	self endon( "cmdlist_f" );
	namespace_filter = arg_list[ 0 ];
	self.printing_commands = 1;
	cmds_to_display = [];
	channel = is_true( self.is_server ) ? "con" : "tell";
	namespace_keys = getArrayKeys( level.custom_commands );
	current_page = 1;
	user_defined_page = 1;
	remaining_cmds = level.custom_commands_total;
	for ( i = 0; i < level.custom_commands_namespaces_total; i++ )
	{
		if ( !isDefined( namespace_filter ) || isSubStr( namespace_filter, namespace_keys[ i ] ) )
		{
			namespace_aliases = strTok( namespace_keys[ i ], " " );
			cmdnames = getArrayKeys( level.custom_commands[ namespace_keys[ i ] ] );
			for ( j = 0; j < cmdnames.size; j++ )
			{
				cmd_aliases = strTok( cmdnames[ j ], " " );
				if ( self has_permission_for_cmd( namespace_aliases[ 0 ], cmd_aliases[ 0 ] ) )
				{
					message = va( "/%s:%s", namespace_aliases[ 0 ], cmd_aliases[ 0 ] );
					if ( channel == "con" )
					{
						COM_PRINTF( channel, "cmdinfo", message, self );
					}
					else 
					{
						cmds_to_display[ cmds_to_display.size ] = message;
					}
				}
				remaining_cmds--;
				if ( ( cmds_to_display.size > level.custom_commands_page_max ) && channel == "tell" && remaining_cmds != 0 )
				{
					if ( current_page == user_defined_page )
					{
						foreach ( message in cmds_to_display )
						{
							COM_PRINTF( channel, "cmdinfo", message, self );
						}
						COM_PRINTF( channel, "cmdinfo", va( "Displaying page %s out of %s do /showmore or /page(num) to display more commands.", current_page, level.custom_commands_page_count ), self );
						setup_temporary_command_listener( "listener_cmdlist", level.custom_commands_listener_timeout, self );
						self waittill( "listener_cmdlist", result, args );
						clear_temporary_command_listener( "listener_cmdlist", self );
						if ( result == "timeout" )
						{
							return;
						}
						else if ( isSubStr( result, "page" ) )
						{
							user_defined_page = int( args[ 0 ] );
							if ( !isDefined( user_defined_page ) )
							{
								COM_PRINTF( channel, "cmderror", va( "Page number arg sent to utility:cmdlist is undefined. Valid inputs are 1 thru %s.", level.custom_commands_page_count ), self );
								return;
							}
							if ( user_defined_page > level.custom_commands_page_count || user_defined_page == 0 )
							{
								COM_PRINTF( channel, "cmderror", va( "Page number %s sent to utility:cmdlist is invalid. Valid inputs are 1 thru %s.", args[ 0 ], level.custom_commands_page_count ), self );
								return;
							}
						}
						else if ( result == "showmore" )
						{
							user_defined_page++;
						}
					}
					current_page++;
					cmds_to_display = [];
				}
				else if ( remaining_cmds == 0 )
				{
					foreach ( message in cmds_to_display )
					{
						COM_PRINTF( channel, "cmdinfo", message, self );
					}
				}
			}
		}
	}
	players[ 0 ].printing_commands = 0;
}

setup_temporary_command_listener( listener_name, timelimit, player )
{
	if ( !isDefined( player.temp_listeners ) )
	{
		player.temp_listeners = [];
	}
	if ( !isDefined( player.temp_listeners[ listener_name ] ) )
	{
		player.temp_listeners[ listener_name ] = true;
		player thread temporary_command_listener_timelimit( listener_name, timelimit );
	}
}

clear_temporary_command_listener( listener_name, player )
{
	arrayRemoveIndex( player.temp_listeners, listener_name );
}

temporary_command_listener_timelimit( listener_name, timelimit )
{
	self endon( listener_name );
	for ( i = timelimit; i > 0; i-- )
	{
		wait 1;
	}
	self notify( listener_name, "timeout" );
}

/*private*/ end_commands_on_end_game()
{
	level waittill( "end_game" );
	wait 15;
	clear_non_perm_dvar_entries();
	level notify( "end_commands" );
}

/*public*/ setup_permissions()
{
	level.server_users = [];
	level.server_users[ "admins" ] = spawnStruct();
	level.server_users[ "admins" ].names = [];
	level.server_users[ "admins" ].guids = [];
	level.server_users[ "admins" ].cmd_rate_limit = -1;
	// level.server_users[ "moderators" ] = spawnStruct();
	// level.server_users[ "moderators" ].names = [];
	// level.server_users[ "moderators" ].guids = [];
	// level.server_users[ "moderators" ].cmd_rate_limit = -1;
	// level.server_users[ "trusted" ] = spawnStruct();
	// level.server_users[ "trusted" ].names = [];
	// level.server_users[ "trusted" ].guids = [];
	// level.server_users[ "trusted" ].cmd_rate_limit = 2;
	// level.server_users[ "default" ] = spawnStruct();
	// level.server_users[ "default" ].cmd_rate_limit = 5;
	str_keys = strTok( getDvar( "server_admin_guids" ), ";" );
	int_keys = [];
	foreach ( key in str_keys )
	{
		int_keys[ int_keys.size ] = int( key );
	}
	level.server_users[ "admins" ].guids = int_keys;
	level.grief_no_permissions_required_namespaces = [];
	level.grief_no_permissions_required_namespaces[ 0 ] = "vote v";
}

/*private*/ find_map_data_from_alias( alias )
{
	result = [];
	switch ( alias )
	{
		case "c":
		case "cell":
		case "block":
		case "cellblock":
			gamemode = "grief";
			location = "cellblock";
			mapname = "zm_prison";
			break;
		case "s":
		case "street":
		case "borough":
		case "buried":
			gamemode = "grief";
			location = "street";
			mapname = "zm_buried";
			break;
		case "f":
		case "farm":
			gamemode = "grief";
			location = "farm";
			mapname = "zm_transit";
			break;
		case "t":
		case "town":
			gamemode = "grief";
			location = "town";
			mapname = "zm_transit";
			break;
		case "b":
		case "bus":
		case "depot":
			gamemode = "grief";
			location = "transit";
			mapname = "zm_transit";
			break;
		case "d":
		case "din":
		case "diner":
			gamemode = "grief";
			location = "diner";
			mapname = "zm_transit";
			break;
		case "tu":
		case "tunnel":
			gamemode = "grief";
			location = "tunnel";
			mapname = "zm_transit";
			break;
		case "p":
		case "pow":
		case "power":
			gamemode = "grief";
			location = "power";
			mapname = "zm_transit";
			break;
		default:
			result[ "gamemode" ] = "";
			result[ "location" ] = "";
			result[ "mapname" ] = "";
			return result;
	}
	result[ "gamemode" ] = gamemode;
	result[ "location" ] = location;
	result[ "mapname" ] = mapname;
	return result;
}

/*private*/ set_knife_lunge( arg )
{
	if ( arg == 1 )
	{	
		setDvar( "grief_gamerule_knife_lunge", arg );
		say( "Knife lunge is set to default" );
		foreach ( player in level.players )
		{	
			player setClientDvar( "aim_automelee_range", 120 );
		}
	}
	else if ( arg == 0 )
	{	
		setDvar( "grief_gamerule_knife_lunge", arg );
		say( "Knife lunge is disabled" );
		foreach ( player in level.players )
		{	
			player setClientDvar( "aim_automelee_range", 0 );
		}
	}
}

//cmd structure:
//set preset_teams_cmd "remove(player_name,...);" - Removes a player from the preset teams list.
//set preset_teams_cmd "add(player_name,team_name,is_perm,is_banned_from_team_change);add(player_name2,team_name,is_perm);" - Adds a player to team. Optional is_perm arg to determine if dvar doesn't clear if the player isn't in the session.
//set dcmd "ban(player_name,...)"
//set dcmd "unban(player_name,...)"

//set grief_preset_teams "(player_name,team_name,is_perm,is_banned);(player_name,team_name,is_perm,is_banned) etc"

/*private*/ execute_rank_cmd( cmd, arg_list )
{
	//rank::remove(rank), rank::add(rank,cmds,privilges), rank::setplayer(rank), rank::setcmds(cmds), rank::setprivileges(privileges)
}

/*private*/ clear_non_perm_dvar_entries()
{
	string = getDvar( "grief_preset_teams" );
	string_keys = strTok( string, ";" );
	new_entries = [];
	for ( i = 0; i < string_keys.size; i++ )
	{
		if ( get_value_from_indexes( string, i, 2 ) == "1" )
		{
			new_entries[ new_entries.size ] = string_keys[ i ];
		}
	}
	setDvar( "grief_preset_teams", concatenate_array( new_entries, ";" ) );
}