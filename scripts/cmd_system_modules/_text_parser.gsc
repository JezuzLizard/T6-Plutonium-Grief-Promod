#include common_scripts/utility;
#include maps/mp/_utility;
#include scripts/cmd_system_modules/_cmd_util;
#include scripts/cmd_system_modules/_com;

parse_cmd_message( message )
{
	if ( message == "" )
	{
		return [];
	}
	multi_cmds = [];
	command_keys = [];
	multiple_cmds_keys = strTok( message, "," );
	for ( i = 0; i < multiple_cmds_keys.size; i++ )
	{
		cmd_args = strTok( multiple_cmds_keys[ i ], " " );
		command_keys[ "namespace" ] = get_cmd_namespace( cmd_args[ 0 ] );
		namespace_and_cmdname = strTok( cmd_args[ 0 ], ":" );
		command_keys[ "cmdname" ] = namespace_and_cmdname[ 1 ];
		arrayRemoveIndex( cmd_args, 0 );
		command_keys[ "args" ] = [];
		command_keys[ "args" ] = cmd_args;
		multi_cmds[ multi_cmds.size ] = command_keys;
	}
	return multi_cmds;
}

get_cmd_namespace( message )
{
	if ( !isSubStr( message, ":" ) )
	{
		return "";
	}
	message_tokens = strTok( message, ":" );
	for ( i = 0; i < level.custom_commands_namespaces_total; i++ )
	{
		namespace_keys = getArrayKeys( level.custom_commands );
		namespace_aliases = strTok( namespace_keys[ i ], " " );
		for ( j = 0; j < namespace_aliases.size; j++ )
		{
			if ( message_tokens[ 0 ] == namespace_aliases[ j ] )
			{
				return namespace_keys[ i ];
			}
		}
	}
	return "";
}