#include scripts/cmd_system_modules/_cmd_util;
#include scripts/cmd_system_modules/_com;
#include scripts/cmd_system_modules/_listener;
#include scripts/cmd_system_modules/_perms;
#include scripts/cmd_system_modules/_text_parser;
#include scripts/cmd_system_modules/_vote;

#include common_scripts/utility;
#include maps/mp/_utility;

CMD_VOTESTART_f( arg_list )
{
	channel = self COM_GET_CMD_FEEDBACK_CHANNEL();
	if ( !is_true( self.is_server ) && !is_true( self.is_admin ) )
	{
		if ( is_true( self.vote_started ) )
		{
			level COM_PRINTF( channel, "cmderror", "vote:start: You cannot start a new vote for the remainder of this match.", self );
			return;
		}
	}
	if ( is_true( level.vote_in_progress ) )
	{
		level COM_PRINTF( channel, "cmderror", va( "vote:start: You cannot start a new vote until the current vote is finished in %s seconds.", level.vote_in_progress_timeleft + "" ), self );
		return;
	}
	if ( get_vote_threshold() == -1 )
	{
		level COM_PRINTF( channel, "cmderror", "vote:start: You cannot start a new vote when there is less than 3 players.", self );
		return;
	}
	key_type = arg_list[ 0 ];
	cmd_arg_1 = arg_list[ 1 ];
	cmd_arg_2 = arg_list[ 2 ];
	cmd_arg_3 = arg_list[ 3 ];
	cmd_arg_4 = arg_list[ 4 ];
	if ( !isDefined( key_type ) )
	{
		level COM_PRINTF( channel, "cmderror", "vote:start: Missing params, 2 args required <key_type>, <key_value>.", self );
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
	cmd_alias_keys = getArrayKeys( level.custom_votes );
	cmd_index = get_alias_index( key_type, cmd_alias_keys );
	if ( cmd_index != -1 )
	{
		func_args = [];
		func_args[ 0 ] = name;
		func_args[ 1 ] = cmd_arg_1;
		func_args[ 2 ] = cmd_arg_2;
		func_args[ 3 ] = cmd_arg_3;
		func_args[ 4 ] = cmd_arg_4;
		pre_message_result = self [[ level.custom_votes[ cmd_alias_keys[ cmd_index ] ].pre_func ]]( func_args );
		level COM_PRINTF( pre_message_result[ "channels" ], pre_message_result[ "filter" ], pre_message_result[ "message" ], self );
		if ( pre_message_result[ "filter" ] == "cmderror" )
		{
			return;
		}
	}
	else 
	{
		level COM_PRINTF( channel, "cmderror", va( "vote:start: Unsupported key_type %s recevied.", key_type ), self );
		return;
	}
	level COM_PRINTF( "g_log", "cmdinfo", va( "Voteables Usage: %s started vote for %s.", self.name, key_type ), self );
	level COM_PRINTF( "con|say", "notitle", va( "You have %s seconds to cast your vote.", level.vote_timeout + "" ), self );
	level COM_PRINTF( "con|say", "notitle", "Do /yes or /no to vote.", self );
	level COM_PRINTF( "con|say", "notitle", "Outcome is determined from players who cast a vote, not from the total players.", self );
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
	self [[ level.custom_votes[ cmd_alias_keys[ cmd_index ] ].post_func ]]( func_args );
}

CMD_CHANGEMAP_f( arg_list )
{
	self notify( "changemap_f" );
	self endon( "changemap_f" );
	channel = self COM_GET_CMD_FEEDBACK_CHANNEL();
	if ( array_validate( arg_list ) )
	{
		rotation_data = find_map_data_from_alias( alias );
		if ( rotation_data[ "mapname" ] != "" )
		{
			if ( sessionModeIsZombiesGame() )
			{
				display_name = get_ZM_map_display_name_from_location_gametype( rotation_data[ "location" ], rotation_data[ "gametype" ] );
				rotation_string = va( "exec zm_%s_%s.cfg map %s", rotation_data[ "gamemode" ], rotation_data[ "location" ], rotation_data[ "mapname" ] );
			}
			else 
			{
				display_name = get_MP_map_name( rotation_data[ "mapname" ] );
				rotation_string = va( "exec %s.cfg map %s", getDvar( "g_gametype" ), rotation_data[ "mapname" ] );
			}
			message = va( "admin:changemap: %s second rotate to map %s countdown started.", level.custom_commands_restart_countdown + "", display_name );
			level COM_PRINTF( "g_log", "cmdinfo", va( "Changemap Usage: %s changed map to %s.", self.name, display_name ), self );
			level COM_PRINTF( "say|con", "notitle", message, self );
			setDvar( "sv_maprotation", rotation_string );
			setDvar( "sv_maprotationCurrent", rotation_string );
			for ( i = level.custom_commands_restart_countdown; i > 0; i-- )
			{
				level COM_PRINTF( "con|say", "notitle", va( "%s seconds", i ) );
				wait 1;
			}
			level notify( "end_commands" );
			wait 0.5;
			exitLevel( false );
			return;
		}
		level COM_PRINTF( channel, "cmderror", va( "admin:changemap: alias %s is invalid.", alias ), self );
	}
	else 
	{
		level COM_PRINTF( channel, "cmderror", "admin:changemap: did not receive alias arg.", self );
	}
}

CMD_ROTATE_f( arg_list )
{
	self notify( "rotate_f" );
	self endon( "rotate_f" );
	message = va( "admin:rotate: %s second rotate countdown started", level.custom_commands_restart_countdown + "", self );
	level COM_PRINTF( "g_log", "cmdinfo", va( "Rotate Usage: %s rotated the map.", self.name ), self );
	level COM_PRINTF( "say|con", "notitle", message, self );
	for ( i = level.custom_commands_restart_countdown; i > 0; i-- )
	{
		wait 1;
		level COM_PRINTF( "con|say", "notitle", va( "%s seconds", i ) );
	}
	level notify( "end_commands" );
	wait 0.5;
	exitLevel( false );
}

CMD_RESTART_f( arg_list )
{
	self notify( "restart_f" );
	self endon( "restart_f" );
	message = va( "admin:restart: %s second restart countdown started", level.custom_commands_restart_countdown + "" );
	level COM_PRINTF( "g_log", "cmdinfo", va( "Restart Usage: %s restarted the map.", self.name ), self );
	level COM_PRINTF( "say|con", "notitle", message, self );
	for ( i = level.custom_commands_restart_countdown; i > 0; i-- )
	{
		wait 1;
		level COM_PRINTF( "con|say", "notitle", va( "%s seconds", i ) );
	}
	level notify( "end_commands" );
	wait 0.5;
	map_restart( false );
}

CMD_PLAYERLIST_f( arg_list )
{
	self notify( "listener_playerlist" );
	self endon( "listener_playerlist" );
	channel = self COM_GET_CMD_FEEDBACK_CHANNEL();
	current_page = 1;
	user_defined_page = 1;
	if ( array_validate( arg_list ) )
	{
		team_name = arg_list[ 0 ];
		if ( isDefined( level.teams[ team_name ] ) )
		{
			players = getPlayers( team_name );
			if ( players.size == 0 )
			{
				level COM_PRINTF( channel, "cmderror", va( "admin:playerlist team %s is empty", team_name ), self );
				return;
			}
		}
		else 
		{
			level COM_PRINTF( channel, "cmderror", va( "admin:playerlist: Received bad team %s", team_name ), self );
			return;
		}
	}
	else 
	{
		players = getPlayers();
	}
	remaining_players = players.size;
	remaining_pages = ceil( remaining_players / level.custom_commands_page_max );
	players_to_display = [];
	for ( i = 0; i < players.size; i++ )
	{
		if ( channel == "con" )
		{
			message = va( "%s %s %s", players[ i ].name, players[ i ] getGUID() + "", players[ i ] getEntityNumber() + "" ); //remember to add rank as a listing option
			level COM_PRINTF( channel, "cmdinfo", message, self );
		}
		else 
		{
			message = va( "^3%s ^2%s ^4%s", players[ i ].name, players[ i ] getGUID() + "", players[ i ] getEntityNumber() + "" ); //remember to add rank as a listing option
			players_to_display[ players_to_display.size ] = message;
		}
		remaining_players--;
		if ( ( players_to_display.size > level.custom_commands_page_max ) && channel == "tell" && remaining_players != 0 )
		{
			if ( current_page == user_defined_page )
			{
				foreach ( message in players_to_display )
				{
					level COM_PRINTF( channel, "cmdinfo", message, self );
				}
				level COM_PRINTF( channel, "cmdinfo", va( "Displaying page %s out of %s do /showmore or /page(num) to display more players.", current_page + "", remaining_pages + "" ), self );
				self setup_command_listener( "listener_playerlist" );
				result = self wait_command_listener( "listener_playerlist" );
				self clear_command_listener( "listener_playerlist" );
				if ( !isDefined( result[ 0 ] ) || result[ 0 ] == "timeout" )
				{
					return;
				}
				else if ( isSubStr( result[ 0 ], "page" ) )
				{
					user_defined_page = int( result[ 1 ] );
					if ( !isDefined( user_defined_page ) )
					{
						level COM_PRINTF( channel, "cmderror", va( "Page number arg sent to admin:playerlist is undefined. Valid inputs are 1 thru %s.", remaining_pages + "" ), self );
						return;
					}
					if ( user_defined_page > remaining_pages || user_defined_page == 0 )
					{
						level COM_PRINTF( channel, "cmderror", va( "Page number %s sent to admin:playerlist is invalid. Valid inputs are 1 thru %s.", result[ 1 ], remaining_pages + "" ), self );
						return;
					}
				}
				else if ( result[ 0 ] == "showmore" )
				{
					user_defined_page++;
				}
			}
			current_page++;
			players_to_display = [];
		}
		else if ( remaining_players == 0 )
		{
			foreach ( message in players_to_display )
			{
				level COM_PRINTF( channel, "cmdinfo", message, self );
			}
		}
	}
}

CMD_UTILITY_CMDLIST_f( arg_list )
{
	self notify( "listener_cmdlist" );
	self endon( "listener_cmdlist" );
	namespace_filter = arg_list[ 0 ];
	cmds_to_display = [];
	channel = self COM_GET_CMD_FEEDBACK_CHANNEL();
	namespace_keys = getArrayKeys( level.custom_commands );
	current_page = 1;
	user_defined_page = 1;
	remaining_cmds = level.custom_commands_total;
	for ( i = 0; i < namespace_keys.size; i++ )
	{
		if ( !isDefined( namespace_filter ) || isSubStr( namespace_keys[ i ], namespace_filter ) )
		{
			namespace_aliases = strTok( namespace_keys[ i ], " " );
			cmdnames = getArrayKeys( level.custom_commands[ namespace_keys[ i ] ] );
			for ( j = 0; j < cmdnames.size; j++ )
			{
				cmd_aliases = strTok( cmdnames[ j ], " " );
				if ( self has_permission_for_cmd( namespace_aliases[ 0 ], cmd_aliases[ 0 ] ) )
				{
					message = va( "^4%s", level.custom_commands[ namespace_keys[ i ] ][ cmdnames[ j ] ].usage );
					if ( channel == "con" )
					{
						level COM_PRINTF( channel, "cmdinfo", message, self );
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
							level COM_PRINTF( channel, "cmdinfo", message, self );
						}
						level COM_PRINTF( channel, "cmdinfo", va( "Displaying page %s out of %s do /showmore or /page(num) to display more commands.", current_page + "", level.custom_commands_page_count + "" ), self );
						self setup_command_listener( "listener_cmdlist" );
						result = self wait_command_listener( "listener_cmdlist" );
						self clear_command_listener( "listener_cmdlist" );
						if ( !isDefined( result[ 0 ] ) || result[ 0 ] == "timeout" )
						{
							return;
						}
						else if ( isSubStr( result[ 0 ], "page" ) )
						{
							user_defined_page = int( result[ 1 ] );
							if ( !isDefined( user_defined_page ) )
							{
								level COM_PRINTF( channel, "cmderror", va( "Page number arg sent to utility:cmdlist is undefined. Valid inputs are 1 thru %s.", level.custom_commands_page_count + "" ), self );
								return;
							}
							if ( user_defined_page > level.custom_commands_page_count || user_defined_page == 0 )
							{
								level COM_PRINTF( channel, "cmderror", va( "Page number %s sent to utility:cmdlist is invalid. Valid inputs are 1 thru %s.", result[ 1 ], level.custom_commands_page_count + "" ), self );
								return;
							}
						}
						else if ( result[ 0 ] == "showmore" )
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
						level COM_PRINTF( channel, "cmdinfo", message, self );
					}
				}
			}
		}
	}
}

CMD_UTILITY_VOTELIST_f( arg_list )
{
	self notify( "listener_voteables" );
	self endon( "listener_voteables" );
	voteables_to_display = [];
	channel = self COM_GET_CMD_FEEDBACK_CHANNEL();
	voteables_keys = getArrayKeys( level.custom_votes );
	current_page = 1;
	user_defined_page = 1;
	remaining_cmds = voteables_keys.size;
	for ( i = 0; i < voteables_keys.size; i++ )
	{
		if ( channel == "con" )
		{
			level COM_PRINTF( channel, "cmdinfo", level.custom_votes[ voteables_keys[ i ] ].usage, self );
		}
		else 
		{
			voteables_to_display[ voteables_to_display.size ] = va( "^4%s", level.custom_votes[ voteables_keys[ i ] ].usage );
		}
		remaining_cmds--;
		if ( ( voteables_to_display.size > level.custom_commands_page_max ) && channel == "tell" && remaining_cmds != 0 )
		{
			if ( current_page == user_defined_page )
			{
				foreach ( message in voteables_to_display )
				{
					level COM_PRINTF( channel, "cmdinfo", message, self );
				}
				level COM_PRINTF( channel, "cmdinfo", va( "Displaying page %s out of %s do /showmore or /page <num> to display more voteables.", current_page + "", level.custom_commands_page_count + "" ), self );
				self setup_command_listener( "listener_voteables" );
				result = self wait_command_listener( "listener_voteables" );
				self clear_command_listener( "listener_voteables" );
				if ( !isDefined( result[ 0 ] ) || result[ 0 ] == "timeout" )
				{
					return;
				}
				else if ( isSubStr( result[ 0 ], "page" ) )
				{
					user_defined_page = int( result[ 1 ] );
					if ( !isDefined( user_defined_page ) )
					{
						level COM_PRINTF( channel, "cmderror", va( "Page number arg sent to utility:votelist is undefined. Valid inputs are 1 thru %s.", level.custom_commands_page_count + "" ), self );
						return;
					}
					if ( user_defined_page > level.custom_commands_page_count || user_defined_page == 0 )
					{
						level COM_PRINTF( channel, "cmderror", va( "Page number %s sent to utility:votelist is invalid. Valid inputs are 1 thru %s.", result[ 1 ], level.custom_commands_page_count + "" ), self );
						return;
					}
				}
				else if ( result[ 0 ] == "showmore" )
				{
					user_defined_page++;
				}
			}
			current_page++;
			voteables_to_display = [];
		}
		else if ( remaining_cmds == 0 )
		{
			foreach ( message in voteables_to_display )
			{
				level COM_PRINTF( channel, "cmdinfo", message, self );
			}
			return;
		}
	}
}