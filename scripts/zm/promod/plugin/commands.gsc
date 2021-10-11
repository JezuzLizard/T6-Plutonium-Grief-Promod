#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include scripts/zm/promod/utility/_grief_util;
#include maps/mp/zombies/_zm_perks;
#include scripts/zm/promod/zgriefp;
#include scripts/zm/promod/zgriefp_overrides;

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
	level.custom_commands_magic_state_toggled = false;
	level.custom_commands_powerups_state_toggled = false;
	level.custom_commands_perks_state_toggled = false;
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
	CMD_ADDCOMMAND( "gamerule g", "togpowerups tp", ::CMD_TOGGLEPOWERUPS_f );
	CMD_ADDCOMMAND( "gamerule g", "togperks tperks", ::CMD_TOGGLEPERKS_f );
	CMD_ADDCOMMAND( "gamerule g", "addrestriction ar", ::CMD_ADDRESTRICTION_f );
	CMD_ADDCOMMAND( "gamerule g", "togperkrestrictions tperksr", ::CMD_TOGGLEPERKRESTRICTIONS_f );

	CMD_ADDCOMMANDLISTENER( "listener_cmdlist", "showmore" );
	CMD_ADDCOMMANDLISTENER( "listener_cmdlist", "page" );
	CMD_ADDCOMMANDLISTENER( "listener_playerlist", "showmore" );
	CMD_ADDCOMMANDLISTENER( "listener_playerlist", "page" );

	level thread COMMAND_BUFFER();

	self tell( "magic(bool" );
	self tell( "powerups(bool" );
	self tell( "knifelunge(bool)" );
	self tell( "roundnumber(int)" );
	wait 12;
	self tell( "buildables(bool)" );
	self tell( "reduceammo(bool)" );
	self tell( "maxzombies(int)" );
	self tell( "depotjug(bool)" );
	self tell( "cellblockjug(bool)" );
}

CMD_ADDRESTRICTION_f( arg_list )
{
	if ( array_validate( arg_list ) && arg_list.size > 1 )
	{
		category = arg_list[ 0 ];
		item = arg_list[ 1 ];

	}
}

CMD_TOGGLEPERKRESTRICTIONS_f( args_list )
{
	new_power_state = !level.custom_commands_perks_state_toggled ? true : false;
	new_perk_restrictions_value = new_power_state ? "" : "all";
	perk_restriction_keys = strTok( level.grief_gamerules[ "perk_restrictions" ], " " );
	perks = level.data_maps[ "perks" ][ "specialties" ];
	if ( new_power_state )
	{
		for ( i = 0; i < perks.size; i++ )
		{
			if ( level.grief_gamerules[ "perk_restrictions" ] == "" || !isInArray( perk_restriction_keys, "specialty_" + perks[ i ] ) )
			{
				level notify( level.data_maps[ "perks" ][ "power_notifies" ][ i ] + "_on" );
			}
		}
	}
	else 
	{
		for ( i = 0; i < perks.size; i++ )
		{
			if ( level.grief_gamerules[ "perk_restrictions" ] == "all" || isInArray( perk_restriction_keys, "specialty_" + perks[ i ] ) )
			{
				level notify( level.data_maps[ "perks" ][ "power_notifies" ][ i ] + "_off" );
			}
		}
	}
	result[ "message" ] = va( "gamerule:perks: Perks are powered %s", cast_bool_to_str( new_powerup_restrictions_state, "toggle" ) );
	result[ "channels" ] = "con say g_log";
	result[ "filter" ] = "cmdinfo";
	return result;
}

CMD_TOGGLEPERKS_f( args_list )
{
	new_power_state = !level.custom_commands_perks_state_toggled ? true : false;
	new_perk_restrictions_value = new_power_state ? "" : "all";
	if ( new_power_state )
	{
		for ( i = 0; i < perks.size; i++ )
		{
			level notify( level.data_maps[ "perks" ][ "power_notifies" ][ i ] + "_on" );
		}
	}
	else 
	{
		for ( i = 0; i < perks.size; i++ )
		{
			level notify( level.data_maps[ "perks" ][ "power_notifies" ][ i ] + "_off" );
		}
	}
	result[ "message" ] = va( "gamerule:perks: Perks are powered %s", cast_bool_to_str( new_powerup_restrictions_state, "toggle" ) );
	result[ "channels" ] = "con say g_log";
	result[ "filter" ] = "cmdinfo";
	return result;
}

CMD_TOGGLEPERK_f( arg_list )
{
	new_powerup_restrictions_state = level.grief_gamerules[ "powerup_restrictions" ] == "all" ? true : false;
	new_powerup_restrictions_value = new_powerup_restrictions_state ? "" : "all";
	setDvar( "grief_gamerule_powerup_restrictions", new_powerup_restrictions_value );
	level.grief_gamerules[ "powerup_restrictions" ] = new_powerup_restrictions_value;
	if ( !level.custom_commands_powerups_state_toggled )
	{
		level.custom_commands_powerups_state_toggled = true;
		result[ "message" ] = va( "gamerule:powerups: Powerups are %s", cast_bool_to_str( new_powerup_restrictions_state, "abled" ) );
	}
	else 
	{
		result[ "message" ] = va( "gamerule:powerups: Powerups will be %s next match", cast_bool_to_str( new_powerup_restrictions_state, "abled" ) );
	}
	result[ "channels" ] = "con say g_log";
	result[ "filter" ] = "cmdinfo";
	return result;
}

CMD_TOGGLEPOWERUPS_f( arg_list )
{
	new_powerup_restrictions_state = level.grief_gamerules[ "powerup_restrictions" ] == "all" ? true : false;
	new_powerup_restrictions_value = new_powerup_restrictions_state ? "" : "all";
	// setDvar( "grief_gamerule_powerup_restrictions", new_powerup_restrictions_value );
	level.grief_gamerules[ "powerup_restrictions" ] = new_powerup_restrictions_value;
	if ( !new_powerup_restrictions_state || !is_true( args_list[ 0 ] ) )
	{
		flag_clear( "zombie_drop_powerups" );
	}
	else 
	{
		flag_set( "zombie_drop_powerups" );
	}
	result[ "message" ] = va( "gamerule:powerups: Powerups are %s", cast_bool_to_str( new_powerup_restrictions_state, "abled" ) );
	result[ "channels" ] = "con say g_log";
	result[ "filter" ] = "cmdinfo";
	return result;
}

CMD_TOGGLEMAGIC_f( arg_list )
{
	new_magic_state = !level.grief_gamerules[ "magic" ] ? 1 : 0;
	setDvar( "grief_gamerule_magic", new_magic_state );
	level.grief_gamerules[ "magic" ] = new_magic_state;
	args = [];
	args[ 0 ] = false;
	self CMD_EXECUTE( "gamerule", "togpowerups", args );
	self CMD_EXECUTE( "gamerule", "togperks", args );
	result[ "message" ] = va( "gamerule:magic: Magic is %s", cast_bool_to_str( new_magic_state, "abled" ) );
	result[ "channels" ] = "con say g_log";
	result[ "filter" ] = "cmdinfo";
	return result;
}
	case "rn":
	case "roundnumber":
		if ( !isDefined( args[ 0 ] ) )
		{
			player tell( "You need to specify a round number" );
			break;
		}
		cmd_outcome_log = "CMD:" + player.name + ";ROUND:" + args[ 0 ] + "\n";
		say( "The round is set to " + args[ 0 ] );
		set_round( int( args[ 0 ] ) );
		break;
	case "kl":
	case "knifelunge":
		cmd_outcome_log = "CMD:" + player.name + ";KNIFE:" + args[ 0 ] + "\n";
		set_knife_lunge( int( args[ 0 ] ) );
		break;
	case "mobjug":
	case "celljug":
	case "cellblockjug":
		if ( !isDefined( args[ 0 ] ) )
		{
			player tell( "You need to specify 1 or 0" );
			break;
		}
		if ( args[ 0 ] == "1" )
		{	
			say( "Jug is enabled on Cellblock" );
			setDvar( "grief_gamerule_cellblock_jug", 1 );
		}
		else if ( args[ 0 ] == "0" )
		{	
			say( "Jug is disabled on Cellblock" );
			setDvar( "grief_gamerule_cellblock_jug", 0 );
		}
		cmd_outcome_log = "CMD:" + player.name + ";MOBJUG:" + args[ 0 ] + "\n";
		break;
	case "depotjug":
		if ( !isDefined( args[ 0 ] ) )
		{
			player tell( "You need to specify 1 or 0" );
			break;
		}
		if ( args[ 0 ] == "1" )
		{	
			say( "Jug is enabled on Bus Depot" );
			setDvar("grief_gamerule_depot_jug", 1 );
		}
		else if ( args[ 0 ] == "0" )
		{	
			say( "Jug is disabled on Bus Depot" );
			setDvar("grief_gamerule_depot_jug", 0 );
		}
		cmd_outcome_log = "CMD:" + player.name + ";DEPOTJUG:" + args[ 0 ] + "\n";
		break;
	case "rsa":
	case "reducedammo":
		cmd_outcome_log = "CMD:" + player.name + ";AMMO:" + args[ 0 ] + "\n";
		if ( !isDefined( args[ 0 ] ) )
		{
			player tell( "You need to specify 1 or 0" );
			break;
		}
		if( int( args[ 0 ] ) == 1 )
		{
			level.grief_gamerules[ "reduced_pistol_ammo" ] = 1;
			say( "Reduced pistol starting ammo is enabled" );
		}
		else if( int( args[ 0 ] ) == 0 )
		{
			level.grief_gamerules[ "reduced_pistol_ammo" ] = 0;
			say( "Reduced pistol starting ammo is disabled" );
		}
		break;
	case "build":
	case "buildables":
		cmd_outcome_log = "CMD:" + player.name + ";BUILD:" + args[ 0 ] + "\n";
		if ( !isDefined( args[ 0 ] ) )
		{
			player tell( "You need to specify 1 or 0" );
			break;
		}
		if( int( args[ 0 ] ) == 1 )
		{
			level.grief_gamerules[ "buildables" ] = 1;
			say( "Buildables are enabled" );
		}
		else if( int( args[ 0 ] ) == 0 )
		{
			level.grief_gamerules[ "buildables" ] = 0;
			say( "Buildables are disabled" );
		}
		break;
	case "zombies":
	case "maxzombies":
		cmd_outcome_log = "CMD:" + player.name + ";MAXZM:" + args[ 0 ] + "\n";
		if ( !isDefined( args[ 0 ] ) )
		{
			player tell( "You need to specify a number" );
			break;
		}
		int_args = int( args[ 0 ] );
		if( int_args <= 32 )
		{
			level.zombie_ai_limit = int_args;
			level.zombie_actor_limit = int_args;
			say( "The max amount of zombies on the map is set to " + int_args );
		}
		else 
		{
			player tell( "The max amount of zombies you can set is 32" );
		}
		break;

	if ( map_rotate && !set_map )
	{
		setDvar( "grief_new_map_kept", 1 );
		level thread change_level();
	}
	else if ( is_true( set_map ) )
	{	
		setDvar( "grief_new_map_kept", 0 );
		level thread change_level();
	}
	else
	{
		say( "Next map set to " + mapname + " " + location );
		setDvar( "grief_new_map_kept", 1 );
	}

CMD_RANDOMNEXTMAP_f( arg_list )
{
	channel = self.is_server ? "con" : "tell";
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
	channel = self.is_server ? "con" : "tell";
	if ( array_validate( arg_list ) )
	{
		alias = toLower( arg_list[ 0 ] );
		rotation_data = find_map_data_from_alias( alias );
		rotation_string = va( "exec zm_%s_%s.cfg map %s", rotation_data[ "gamemode" ], rotation_data[ "location" ], rotation_data[ "mapname" ] );
		message = va( "admin:changemap: %s second rotate to map %s countdown started", level.custom_commands_restart_countdown, get_map_display_name_from_location( rotation_data[ "location" ] ) );
		COM_PRINTF( "g_log " + channel, "cmdinfo", self.name + " executed " + message );
		setDvar( "sv_maprotation", rotation_string );
		setDvar( "sv_maprotationCurrent", rotation_string );
		for ( i = level.custom_commands_restart_countdown; i > 0; i-- )
		{
			wait 1;
			COM_PRINTF( "con say", "cmdinfo", va( "%s seconds", i ) );
		}
		level notify( "end_commands" );
		wait 0.5;
		exitLevel( false );
	}
	else 
	{
		COM_PRINTF( channel, "cmderror", va( "admin:changemap: alias %s is invalid", alias ), self );
	}
}

CMD_NEXTMAP_f( arg_list )
{
	if ( array_validate( arg_list ) )
	{
		alias = toLower( arg_list[ 0 ] );
		rotation_data = find_map_data_from_alias( alias );
		if ( rotation_data[ "mapname" ] != 0)
		{
			rotation_string = va( "exec zm_%s_%s.cfg map %s", rotation_data[ "gamemode" ], rotation_data[ "location" ], rotation_data[ "mapname" ] );
			setDvar( "sv_maprotation", rotation_string );
			setDvar( "sv_maprotationCurrent", rotation_string );
			result[ "filter" ] = "cmdinfo";
			result[ "message" ] = va( "admin:nextmap: Successfully set next map to %s", get_map_display_name_from_location( rotation_data[ "location" ] );
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
	channel = self.is_server ? "con" : "tell";
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
	channel = self.is_server ? "con" : "tell";
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
	channel = self.is_server ? "con" : "tell";
	current_page = 1;
	user_defined_page = 1;
	if ( array_validate( arg_list ) )
	{
		team_name = arg_list[ 0 ];
	}
	if ( isDefined( team_name ) && isDefined( level.teams[ team_name ] ) )
	{
		players = getPlayers( team_name )
	}
	else 
	{
		players = getPlayers();
	}
	remaining_players = players.size;
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
		if ( ( cmds_to_display.size > level.custom_commands_page_max ) && channel == "tell" && remaining_players != 0 )
		{
			if ( current_page == user_defined_page )
			{
				foreach ( message in cmds_to_display )
				{
					COM_PRINTF( channel, "cmdinfo", message, self );
				}
				COM_PRINTF( channel, "cmdinfo", va( "Displaying page %s out of %s do /showmore or /page(num) to display more players.", current_page, level.custom_commands_page_count ), self );
				setup_temporary_command_listener( "listener_playerlist", 12, self );
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
	result = []
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
	clientnum_guid_or_name = arg_list[ 0 ];
	max_players_str = getDvarInt( "sv_maxclients" ) + "";
	if ( str_is_int( clientnum_guid_or_name ) && clientnum_guid_or_name.size < max_players_str.size )
	{
		client_num = int( clientnum_guid_or_name );
	}
	else if ( str_is_int( clientnum_guid_or_name ) && clientnum_guid_or_name.size > max_players_str.size )
	{
		GUID = int( clientnum_guid_or_name );
	}
	else 
	{
		name = clientnum_guid_or_name;
	}
	result = [];
	kicked = false;
	foreach ( player in level.players )
	{
		if ( isDefined( name ) )
		{
			if ( clean_player_name_of_clantag( player.name ) == clean_player_name_of_clantag( name ) || isSubStr( player.name, name ) )
			{
				kick( player getEntityNumber() );
				kicked = true;
				break;
			}
		}
		else if ( isDefined( client_num ) )
		{
			if ( player getEntityNumber() == client_num )
			{
				kick( player getEntityNumber() );
				kicked = true;
				break;
			}
		}
		else 
		{
			if ( player getGUID() == GUID )
			{
				kick( player getEntityNumber() );
				kicked = true;
				break;
			}
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
	result = []
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
	result = []
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
	if ( array_validate( self.temp_listeners )
	{
		listener_keys = getArrayKeys( self.temp_listeners );
		foreach ( listener in listener_keys )
		{
			if ( CMD_ISCOMMANDLISTENER( listener, cmdname ) )
			{
				self CMD_EXECUTELISTENER( listener, cmdname, arg_list )
				return;
			}
		}
	}
	indexable_cmdname = "";
	is_threaded_cmd = false;
	if ( namespace != "" )
	{
		cmd_keys = getArrayKeys( level.custom_commands[ namespace ] );
		for ( i = 0; i < cmd_keys.size; i++ )
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
	channel = self.is_server ? "con" : "tell";
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
		result[ "message" ] = va( "team:unperm: Failed to set entry for %s to be temporary " + outcome[ "error_msg" ], player_name );
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
		result[ "message" ] = va( "team:unban: Failed to set entry for %s to be permanent " + outcome[ "error_msg" ], player_name );
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
		result[ "message" ] = va( "team:unban: Failed to unban %s from changing teams " + outcome[ "error_msg" ], player_name );
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
		result[ "message" ] = va( "team:ban: Failed to ban %s from changing teams " + outcome1[ "error_msg" ] + " " + outcome2[ "error_msg" ], player_name );
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
			result[ "message" ] = va( "team:set: Failed to change %s to team %s " + outcome[ "error_msg" ], player_name, team_name );
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
		level waittill( "say", player, message );
		if ( isDefined( player ) && !isSubStr( message, "/" ) )
		{
			continue;
		}
		if ( !isDefined( player ) )
		{
			player = level.server;
		}
		clean_str( message, "/" );
		multi_cmds = parse_cmd_message( message );
		if ( !array_validate( multi_cmds ) )
		{
			continue;
		}
		for ( cmd_index = 0; cmd_index < multi_cmds.size; i++ )
		{
			namespace = toLower( multi_cmds[ cmd_index ][ "namespace" ] );
			cmdname = toLower( multi_cmds[ cmd_index ][ "cmdname" ] );
			args = multi_cmds[ cmd_index ][ "args" ];
			if ( level.players_in_session[ player.name ].command_cooldown == 0 && !player.is_server )
			{
				player CMD_EXECUTE( namespace, cmdname, args );
				player thread COMMAND_COOLDOWN();
			}
			else 
			{
				COM_PRINTF( "tell", "cmderror", va( "You cannot use another command for %s seconds", level.players_in_session[ player.name ].command_cooldown ), player );
			}
					case "r":
					case "rank":
						success = execute_rank_cmd( cmd, args );
						break;
					default:
						switch ( cmdname )
						{
							case "mv":
							case "mapvote":
								if ( !is_true( level.mapvote_in_progress ) )
								{
									cmd_outcome_log = "CMD:" + player.name + ";MVS:" + args[ 0 ] + "\n";
									level thread mapvote_started();
									level thread mapvote_count_votes();
									level thread mapvote_end();
									level.mapvote_in_progress = 1;
									say( "Mapvote started!" );
								}
								level notify( "grief_mapvote", args[ 0 ], player );
								break;
							case "vk":
							case "votekick":
								if ( level.players.size < 3 )
								{
									player tell( "Not enough players to initiate a votekick" );
									break;
								}
								if ( !is_true( level.votekick_in_progress ) )
								{
									cmd_outcome_log = "CMD:" + player.name + ";VKS:" + args[ 0 ] + "\n";
									level thread vote_kick_started();
									level thread votekick_count_votes();
									level.votekick_in_progress = 1;
									say( "Votekick started!" );
								}
								level notify( "grief_votekick", args[ 0 ], player );
								break;
							default:
								success = false;
								break;
						}
				}
			}
		}
	}
}

/*private*/ set_round( round_number )
{
	start_new_round( true, round_number );
}

/*private*/ mapvote_started()
{
	level endon( "end_game" );
	level endon( "grief_mapvote_ended" );
	while ( true )
	{
		level waittill( "grief_mapvote", vote, player );
		if ( !isDefined( vote ) )
		{
			continue;
		}
		if ( !isDefined( player.previous_votes ) )
		{
			player.previous_votes = [];
		}
		mapname = "NULL";
		for ( i = 0; i < level.mapvote_array.size; i++ )
		{
			if ( mapname != "NULL" )
			{
				player.has_mapvoted_previously = 1;
				break;
			}
			for ( j = 0; j < level.mapvote_array[ i ].aliases.size; j++ )
			{
				if ( level.mapvote_array[ i ].aliases[ j ] == vote )
				{
					mapname = level.mapvote_array[ i ].mapname;
					player.previous_votes[ player.previous_votes.size ] = mapname;
					if ( is_true( player.has_mapvoted_previously ) )
					{
						for ( k = 0; k < player.previous_votes.size; k++ )
						{
							if ( player.previous_votes[ k ] != mapname )
							{
								level.mapvote_array[ i ].votes++;
								player tell( "You voted for " + mapname + " which has " + level.mapvote_array[ i ].votes + "/" + get_vote_threshold() + " votes" );
								cmd_outcome_log = "MV:" + player.name + ";V:" + mapname + "\n";
								logprint( cmd_outcome_log );
								break;
							}
						}
					}
					else 
					{
						level.mapvote_array[ i ].votes++;
						player tell( "You voted for " + mapname + " which has " + level.mapvote_array[ i ].votes + "/" + get_vote_threshold() + " votes" );
						cmd_outcome_log = "MV:" + player.name + ";V:" + mapname + "\n";
						logprint( cmd_outcome_log );
						break;
					}
				}
			}
		}
		if ( mapname == "NULL" )
		{
			player tell( "Invalid map" );
		}
	}
}

/*private*/ mapvote_count_votes()
{
	level endon( "end_game" );
	level endon( "grief_mapvote_ended" );
	start_time = getTime() / 1000;
	current_time = start_time;
	while ( true )
	{
		for ( i = 0; i < level.mapvote_array.size; i++ )
		{
			if ( level.mapvote_array[ i ].votes >= get_vote_threshold() )
			{
				map = level.mapvote_array[ i ].mapname;
				break;
			}
		}
		if ( isDefined( map ) )
		{
			break;
		}
		if ( ( getTime() / 1000 ) > ( start_time + 600 ) )
		{	
			level notify( "grief_mapvote_ended" );
		}
		wait 0.05;
	}
	level notify( "grief_mapvote_ended", map );
}

/*private*/ mapvote_end()
{
	level waittill( "grief_mapvote_ended", result );
	if ( isDefined( result ) )
	{
		mapvote_outcome_log = "MV;" + "MAP:" + result + "\n";
		find_map_data_from_alias( toLower( result ), undefined, 0 );
	}
	else 
	{
		cmd_outcome_log = "MV:TIMEOUT;" + "\n";
		say( "Mapvote timed out!" );
	}
	logprint( mapvote_outcome_log );
	level.mapvote_in_progress = 0;
	foreach ( player in level.players )
	{
		player.previous_votes = [];
	}
	for ( i = 0; i < level.mapvote_array.size; i++ )
	{
		level.mapvote_array[ i ].votes = 0;
	}
}

/*public*/ has_permission_for_cmd( cmd )
{
	if ( self.is_server )
	{
		return true;
	}
	if ( isSubStr( level.players_in_session[ self.name ].server_rank_system[ "cmds" ], "all" ) )
	{
		return true;
	}
	if ( isSubStr( level.players_in_session[ self.name ].server_rank_system[ "cmds" ], cmd ) )
	{
		return true;
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
	channel = self.is_server ? "con" : "tell";
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
				if ( self has_permission_for_cmd( cmd_aliases[ 0 ] ) )
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
						setup_temporary_command_listener( "listener_cmdlist", 12, self );
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

/*private*/ vote_kick_started()
{
	level endon( "end_game" );
	level endon( "grief_votekick_ended" );

	for ( i = 0; i < level.players.size; i++ )
	{
		level.players[ i ].kick_votes = 0;
	}
	while ( true )
	{
		level waittill( "grief_votekick", player_name, player );
		if ( !isDefined( player_name ) )
		{
			continue;
		}
		if ( is_true( player.vk_voted ) )
		{
			continue;
		}
		for( i = 0; i < level.players.size; i++ )
		{
			if ( clean_player_name_of_clantag( player_name ) == clean_player_name_of_clantag( level.players[ i ].name ) )
			{	
				level.players[ i ].kick_votes++;
				player tell( level.players[ i ].name + " has " + level.players[ i ].kick_votes + "/" + get_vote_threshold() + " votes needed to be kicked" );
				player.vk_voted = 1;
			}
		}
	}
}

/*private*/ votekick_count_votes()
{
	level endon( "end_game" );
	level endon( "grief_votekick_ended" );
	start_time = getTime() / 1000;
	while ( true )
	{
		for ( i = 0; i < level.players.size; i++ )
		{
			if ( level.players[ i ].kick_votes >= get_vote_threshold() )
			{
				kick( level.players[ i ] getEntityNumber() );
				say( level.players[ i ].name + " was kicked!" );
				level.votekick_in_progress = 0;
				cmd_outcome_log = "VK;" + level.players[ i ].name + ":K" + "\n";
				logprint( cmd_outcome_log );
				for ( i = 0; i < level.players.size; i++ )
				{
					level.players[ i ].vk_voted = 0;
				}
				level notify( "grief_votekick_ended" );
			}
		}
		if ( ( getTime() / 1000 ) > ( start_time + 600 ) )
		{	
			say( "Vote kick timed out!" );
			level.votekick_in_progress = 0;
			cmd_outcome_log = "VK;TIMEOUT" + "\n";
			logprint( cmd_outcome_log );
			for ( i = 0; i < level.players.size; i++ )
			{
				level.players[ i ].vk_voted = 0;
			}
			level notify( "grief_votekick_ended" );
		}
		wait 0.05;
	}
}

/*private*/ get_vote_threshold()
{
	switch ( level.players.size )
	{
		case 3:
			return 2;
		case 4:
			return 3;
		case 5:
			return 4;
		case 6:
			return 4;
		case 7:
			return 5;
		case 8:
			return 5;
		default:
			return 99;
	}
}

/*public*/ setup_permissions()
{
	level.server_users = [];
	level.server_users[ "admins" ] = spawnStruct();
	level.server_users[ "admins" ].names = [];
	level.server_users[ "admins" ].guids = [];
	level.server_users[ "admins" ].cmd_rate_limit = -1;
	level.server_users[ "moderators" ] = spawnStruct();
	level.server_users[ "moderators" ].names = [];
	level.server_users[ "moderators" ].guids = [];
	level.server_users[ "moderators" ].cmd_rate_limit = -1;
	level.server_users[ "trusted" ] = spawnStruct();
	level.server_users[ "trusted" ].names = [];
	level.server_users[ "trusted" ].guids = [];
	level.server_users[ "trusted" ].cmd_rate_limit = 2;
	level.server_users[ "default" ] = spawnStruct();
	level.server_users[ "default" ].cmd_rate_limit = 5;
	path = level.basepath + "startup_commands.txt";
	file = fopen( path, "r+" );
	if ( file == -1 )
	{
		print( "Promod FS Error: Failed to open startup_commands.txt" );
		return;
	}
	buffer = fread( file );
	fclose( file );
	multi_cmds = parse_cmd_message( buffer );
	if ( multi_cmds.size == 0 )
	{
		print( "Promod FS Error: Found startup_commands but it was empty" );
		return;
	}
	for ( i = 0; i < multi_cmds.size; i++ )
	{
		args = multi_cmds[ i ][ "args" ];
		namespace = multi_cmds[ i ][ "namespace" ];
		cmdname = multi_cmds[ i ][ "cmdname" ];
	}
	rank_type = strTok( buffer, ":" );
	names_and_guids = strTok( rank_type[ 1 ], "," );
	rank = rank_type[ 0 ];
	for ( j = 0; j < names_and_guids.size; j++ )
	{
		names_keys = strTok( names_and_guids[ j ], "<" );
		level.server_users[ rank ].names[ j ] = names_keys[ 0 ];
	}
	for ( j = 0; j < names_and_guids.size; j++ )
	{
		guids_keys = strTok( names_and_guids[ j ], "<" );
		level.server_users[ rank ].guids[ j ] = int( guids_keys[ 1 ] );
	}
	level.grief_no_permissions_required_commands = [];
	level.grief_no_permissions_required_commands[ 0 ] = "mv";
	level.grief_no_permissions_required_commands[ 1 ] = "mapvote";
	level.grief_no_permissions_required_commands[ 2 ] = "vk";
	level.grief_no_permissions_required_commands[ 3 ] = "votekick";

	level.mapvote_array = [];
	level.mapvote_array[ 0 ] = spawnStruct();
	level.mapvote_array[ 0 ].mapname = "cellblock";
	level.mapvote_array[ 0 ].aliases = array( "c", "cell", "block", "cellblock", "mob" );
	level.mapvote_array[ 0 ].votes = 0;
	level.mapvote_array[ 1 ] = spawnStruct();
	level.mapvote_array[ 1 ].mapname = "borough";
	level.mapvote_array[ 1 ].aliases = array( "s", "street", "borough", "buried" );
	level.mapvote_array[ 1 ].votes = 0;
	level.mapvote_array[ 2 ] = spawnStruct();
	level.mapvote_array[ 2 ].mapname = "farm";
	level.mapvote_array[ 2 ].aliases = array( "f", "farm" );
	level.mapvote_array[ 2 ].votes = 0;
	level.mapvote_array[ 3 ] = spawnStruct();
	level.mapvote_array[ 3 ].mapname = "town";
	level.mapvote_array[ 3 ].aliases = array( "t", "town" );
	level.mapvote_array[ 3 ].votes = 0;
	level.mapvote_array[ 4 ] = spawnStruct();
	level.mapvote_array[ 4 ].mapname = "depot";
	level.mapvote_array[ 4 ].aliases = array( "b", "bus", "depot" );
	level.mapvote_array[ 4 ].votes = 0;
	level.mapvote_array[ 5 ] = spawnStruct();
	level.mapvote_array[ 5 ].mapname = "diner";
	level.mapvote_array[ 5 ].aliases = array( "d", "din", "diner" );
	level.mapvote_array[ 5 ].votes = 0;
	level.mapvote_array[ 6 ] = spawnStruct();
	level.mapvote_array[ 6 ].mapname = "tunnel";
	level.mapvote_array[ 6 ].aliases = array( "t", "tunnel" );
	level.mapvote_array[ 6 ].votes = 0;
	level.mapvote_array[ 7 ] = spawnStruct();
	level.mapvote_array[ 7 ].mapname = "power";
	level.mapvote_array[ 7 ].aliases = array( "p", "pow", "power" );
	level.mapvote_array[ 7 ].votes = 0;

	level.command_references = "";
	path = level.basepath + "command_references.txt";
	file = fopen( path, "r+" );
	if ( file == -1 )
	{
		print( "Promod FS: Failed to open file " + "command_references.txt" );
		print( "Place the scriptdata folder in storage\\t6 and try again." )
		return;
	}
	level.command_references = fread( file );
	fclose( file );
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
		case "mob":
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
			result[ "gamemode" ] = 0;
			result[ "location" ] = 0;
			result[ "mapname" ] = 0;
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