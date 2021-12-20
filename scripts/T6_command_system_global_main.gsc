
#include scripts/cmd_system_modules/_cmd_util;
#include scripts/cmd_system_modules/_com;
#include scripts/cmd_system_modules/_text_parser;
#include scripts/cmd_system_modules/_vote;
#include scripts/cmd_system_modules/_listener;
#include scripts/cmd_system_modules/_perms;
#include scripts/cmd_system_modules/global_commands;
#include scripts/cmd_system_modules/global_threaded_commands;
#include scripts/cmd_system_modules/global_voteables;
#include scripts/cmd_system_modules/_filesystem;

#include common_scripts/utility;
#include maps/mp/_utility;

main()
{
	if ( getDvar( "sv_maprotation_old" ) == "" )
	{
		setDvar( "sv_maprotation_old", getDvar( "sv_maprotation" ) );
	}
	COM_INIT();
	FS_INIT();
	level.server = spawnStruct();
	level.server.name = "Server";
	level.server.is_server = true;
	level.custom_commands_restart_countdown = 5;
	level.custom_commands_namespaces_total = 0;
	level.custom_commands_total = 0;
	level.custom_commands_page_count = 0;
	level.custom_commands_page_max = 5;
	level.custom_commands_listener_timeout = getDvarIntDefault( "tcs_cmd_listener_timeout", 12 );
	level.custom_commands_cooldown_time = getDvarIntDefault( "tcs_cmd_cd", 5 );
	level.custom_commands_tokens = getDvarStringDefault( "tcs_cmd_tokens", "/" ); //separated by spaces, good tokens are generally not used at the start of a normal message 
	// "/" is recommended for anonymous command usage, other tokens are not anonymous
	CMD_INIT_PERMS();
	INIT_MOD_INTEGRATIONS();
	level.custom_commands = [];
	CMD_ADDCOMMAND( "admin a", "cvar cv", "admin:cvar <name|guid|clientnum> <cvarname> <newval>", ::CMD_CVAR_f );
	CMD_ADDCOMMAND( "admin a", "kick k", "admin:kick <name|guid|clientnum>", ::CMD_ADMIN_KICK_f );
	CMD_ADDCOMMAND( "admin a", "lock l", "admin:lock <password>", ::CMD_LOCK_SERVER_f );
	CMD_ADDCOMMAND( "admin a", "unlock ul", "admin:unlock", ::CMD_UNLOCK_SERVER_f );
	CMD_ADDCOMMAND( "admin a", "dvar d", "admin:dvar <dvarname> <newval>", ::CMD_SERVER_DVAR_f );
	CMD_ADDCOMMAND( "admin a", "cvarall ca", "admin:cvarall <dvarname> <newval", ::CMD_CVARALL_f );
	CMD_ADDCOMMAND( "admin a", "nextmap nm", "admin:nextmap <mapalias>", ::CMD_NEXTMAP_f );
	CMD_ADDCOMMAND( "admin a", "resetrotation rr", "admin:resetrotation", ::CMD_RESETROTATION_f );
	CMD_ADDCOMMAND( "admin a", "randomnextmap rnm", "admin:randomnextmap", ::CMD_RANDOMNEXTMAP_f );
	CMD_ADDCOMMAND( "utility u", "cmdlist cl", "utility:cmdlist [namespace]", ::CMD_UTILITY_CMDLIST_f, true );
	CMD_ADDCOMMAND( "admin a", "playerlist plist", "admin:playerlist [team]", ::CMD_PLAYERLIST_f, true );
	CMD_ADDCOMMAND( "admin a", "restart mr", "admin:restart", ::CMD_RESTART_f, true );
	CMD_ADDCOMMAND( "admin a", "rotate r", "admin:rotate", ::CMD_ROTATE_f, true );
	CMD_ADDCOMMAND( "admin a", "changemap cm", "admin:changemap <mapalias>", ::CMD_CHANGEMAP_f, true );
	CMD_ADDCOMMAND( "vote v", "start s", "vote:start <voteable> [arg1] [arg2] [arg3] [arg4]", ::CMD_VOTESTART_f, true );
	CMD_ADDCOMMAND( "vote v", "list l", "vote:list", ::CMD_UTILITY_VOTELIST_f, true );

	VOTE_INIT();

	CMD_ADDCOMMANDLISTENER( "listener_cmdlist", "showmore" );
	CMD_ADDCOMMANDLISTENER( "listener_cmdlist", "page" );
	CMD_ADDCOMMANDLISTENER( "listener_playerlist", "showmore" );
	CMD_ADDCOMMANDLISTENER( "listener_playerlist", "page" );

	level thread COMMAND_BUFFER();
	level thread dvar_command_watcher();
	level thread end_commands_on_end_game();
	level notify( "tcs_init_done" );
}

dvar_command_watcher()
{
	level endon( "end_commands" );
	while ( true )
	{
		dvar_value = getDvar( "scrcmd" );
		if ( dvar_value != "" )
		{
			level notify( "say", dvar_value, undefined );
			setDvar( "scrcmd", "" );
		}
		wait 0.05;
	}
}

COMMAND_BUFFER()
{
	level endon( "end_commands" );
	while ( true )
	{
		level waittill( "say", message, player, isHidden );
		if ( isDefined( player ) && !isHidden && !is_command_token( message[ 0 ] ) )
		{
			continue;
		}
		if ( !isDefined( player ) )
		{
			player = level.server;
		}
		if ( isDefined( player.cmd_cooldown ) && player.cmd_cooldown > 0 )
		{
			level COM_PRINTF( channel, "cmderror", va( "You cannot use another command for %s seconds", player.cmd_cooldown + "" ), player );
			continue;
		}
		message = toLower( message );
		if ( array_validate( player.cmd_listeners ) )
		{
			listener_cmds_args = strTok( message, " " );
			cmdname = listener_cmds_args[ 0 ];
			listener_keys = getArrayKeys( player.cmd_listeners );
			found_listener = false;
			foreach ( listener in listener_keys )
			{
				if ( CMD_ISCOMMANDLISTENER( listener, cmdname ) && player CMD_ISCOMMANDLISTENER_ACTIVE( listener ) )
				{
					player CMD_EXECUTELISTENER( listener, listener_cmds_args );
					found_listener = true;
					break;
				}
			}
			if ( found_listener )
			{
				continue;
			}
		}
		channel = player COM_GET_CMD_FEEDBACK_CHANNEL();
		multi_cmds = parse_cmd_message( message );
		if ( !array_validate( multi_cmds ) )
		{
			continue;
		}
		if ( multi_cmds.size > 1 && !player can_use_multi_cmds() )
		{
			temp_array_index = multi_cmds[ 0 ];
			multi_cmds = [];
			multi_cmds[ 0 ] = temp_array_index;
			level COM_PRINTF( channel, "cmdwarning", "You do not have permission to use multi cmds; only executing the first cmd" );
		}
		for ( cmd_index = 0; cmd_index < multi_cmds.size; cmd_index++ )
		{
			namespace = multi_cmds[ cmd_index ][ "namespace" ];
			cmdname = multi_cmds[ cmd_index ][ "cmdname" ];
			args = multi_cmds[ cmd_index ][ "args" ];
			if ( !player has_permission_for_cmd( namespace, cmdname ) )
			{
				level COM_PRINTF( channel, "cmderror", va( "You do not have permission to use %s command.", cmdname ), player );
			}
			else 
			{
				player CMD_EXECUTE( namespace, cmdname, args );
				player thread CMD_COOLDOWN();
			}
		}
	}
}

end_commands_on_end_game()
{
	level waittill( "end_game" );
	wait 15;
	level notify( "end_commands" );
}

INIT_MOD_INTEGRATIONS()
{
	if ( !isDefined( level.mod_integrations ) )
	{
		level.mod_integrations = [];
	}
	level.mod_integrations[ "cut_tranzit_locations" ] = getDvarIntDefault( "tcs_integrations_cut_tranzit_locations", 0 );
}