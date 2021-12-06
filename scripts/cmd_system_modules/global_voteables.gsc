#include scripts/cmd_system_modules/_cmd_util;
#include scripts/cmd_system_modules/_com;
#include scripts/cmd_system_modules/_listener;
#include scripts/cmd_system_modules/_perms;
#include scripts/cmd_system_modules/_text_parser;

#include common_scripts/utility;
#include maps/mp/_utility;

VOTE_INIT()
{
	level.vote_timeout = getDvarIntDefault( "tcs_vote_timelimit_seconds", 30 );
	level.vote_start_anonymous = getDvarIntDefault( "tcs_anonymous_vote_start", 1 );
	CMD_ADDCOMMANDLISTENER( "listener_vote", "yes" );
	CMD_ADDCOMMANDLISTENER( "listener_vote", "no" );
	VOTE_ADDVOTEABLE( "cvarall ca", "vote:start cvarall <dvarname> <newval>", ::VOTEABLE_CVARALL_PRE_f, ::VOTEABLE_CVARALL_POST_f );
	VOTE_ADDVOTEABLE( "kick k", "vote:start kick <name|guid|clientnum>", ::VOTEABLE_KICK_PRE_f, ::VOTEABLE_KICK_POST_f );
	VOTE_ADDVOTEABLE( "nextmap nm", "vote:start <alias>", ::VOTEABLE_NEXTMAP_PRE_f, ::VOTEABLE_NEXTMAP_POST_f );
}

VOTEABLE_CVARALL_PRE_f( arg_list )
{
	name = arg_list[ 0 ];
	dvar_name = arg_list[ 1 ];
	new_value = arg_list[ 2 ];
	result = [];
	if ( isDefined( new_value ) && getDvar( dvar_name ) != "" )
	{
		result[ "message" ] = va( "%s would like to set %s to %s", name, dvar_name, new_value );
		result[ "channels" ] = "con|say|g_log|";
		result[ "filter" ] = "notitle";
	}
	else 
	{
		result[ "message" ] = "Cvarall set requires a valid <dvar name>, and <dvar value>.";
		result[ "channels" ] = self COM_GET_CMD_FEEDBACK_CHANNEL();
		result[ "filter" ] = "cmderror";
	}
	return result;
}

VOTEABLE_KICK_PRE_f( arg_list )
{
	name = arg_list[ 0 ];
	player = find_player_in_server( arg_list[ 1 ] );
	result = [];
	if ( isDefined( player ) )
	{
		result[ "message" ] = va( "%s would like to kick %s", name, player.name );
		result[ "channels" ] = "con|say|g_log|";
		result[ "filter" ] = "notitle";
	}
	else 
	{
		result[ "message" ] = "Could not find player";
		result[ "channels" ] = self COM_GET_CMD_FEEDBACK_CHANNEL();
		result[ "filter" ] = "cmderror";
	}
	return result;
}

VOTEABLE_NEXTMAP_PRE_f( arg_list )
{
	name = arg_list[ 0 ];
	rotation_data = find_map_data_from_alias( arg_list[ 1 ] );
	result = [];
	if ( rotation_data[ "mapname" ] != "" )
	{
		if ( sessionModeIsZombiesGame() )
		{
			display_name = get_ZM_map_display_name_from_location_gametype( rotation_data[ "location" ], rotation_data[ "gametype" ] );
		}
		else 
		{
			display_name = get_MP_map_name( rotation_data[ "mapname" ] );
		}
		result[ "message" ] = va( "%s would like to set the next map to %s", name, display_name );
		result[ "channels" ] = "con|say|g_log|";
		result[ "filter" ] = "cmdinfo";
	}
	else 
	{
		result[ "message" ] = "Could not find map from alias";
		result[ "channels" ] = self COM_GET_CMD_FEEDBACK_CHANNEL();
		result[ "filter" ] = "cmderror";
	}
	return result;
}

VOTEABLE_CVARALL_POST_f( arg_list )
{
	args = [];
	args[ 0 ] = arg_list[ 0 ];
	args[ 1 ] = arg_list[ 1 ];
	self CMD_EXECUTE( "admin", "cvarall", args );
}

VOTEABLE_KICK_POST_f( arg_list )
{
	args = [];
	args[ 0 ] = arg_list[ 0 ];
	self CMD_EXECUTE( "admin", "kick", args );
}

VOTEABLE_NEXTMAP_POST_f( arg_list )
{
	args = [];
	args[ 0 ] = arg_list[ 0 ];
	self CMD_EXECUTE( "admin", "nextmap", args );
}