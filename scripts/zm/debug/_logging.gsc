telemetry_init()
{
	level.match_start_time_offset = getTime();
	level.homepath = getDvar( "fs_homepath" );
	level.telemetry_path = level.homepath + "/telemetry";
	if ( !directoryExists( level.telemetry_path ) )
	{
		createDirectory( level.telemetry_path );
	}
	level.sessions_path = level.homepath + "/telemetry/sessions";
	if ( !directoryExists( level.sessions_path ) )
	{
		createDirectory( level.sessions_path );
	}
	level.current_session_tracker_file = level.homepath + "/telemetry/sessions/session_counter.txt";
	create_new_session();
	init_event_logging();
}

create_new_session()
{
	if ( getDvar( "scr_server_current_session" ) == "" )
	{
		if ( !fileExists( level.current_session_tracker_file ) )
		{
			previous_session = "0";
			
		}
		else 
		{
			previous_session = int( readFile( level.current_session_tracker_file ) );
			previous_session++;
			previous_session = previous_session + "";
		}
		writeFile( level.current_session_tracker_file, previous_session );
		setDvar( "scr_server_current_session", previous_session );
		current_match = "0";
	}
	else 
	{
		current_match = getDvarInt( "scr_server_current_match" );
		current_match++;
		current_match = current_match + "";
	}
	level.current_session_working_directory = level.homepath + "/telemetry/sessions/" + getDvar( "scr_server_current_session" );
	if ( !directoryExists( level.current_session_working_directory ) )
	{
		createDirectory( level.current_session_working_directory );
	}
	level.matches_path = level.current_session_working_directory + "/match_" + current_match + "_" + getDvar( "mapname" ) + "_" + getDvar( "g_gametype" ) + "_" + getDvar( "ui_zm_mapstartlocation" );
	if ( !directoryExists( level.matches_path ) )
	{
		createDirectory( level.matches_path );
	}
	level.current_match_tracker_file = level.current_session_working_directory + "/match_counter.txt";
	writeFile( level.current_match_tracker_file, current_match );
	setDvar( "scr_server_current_match", current_match );
}

init_event_logging()
{
	level.current_match_event_log = level.matches_path + "/events.log";
}

format_log_message( message )
{
	new_message = "";
	current_match_time = getTime() - level.match_start_time_offset;
	new_message = current_match_time + " | " + message;
	return new_message;
}

event_log( message )
{
	new_message = format_log_message( message );
	//level.log_messages[ level.log_messages.size ] = new_message
	writeFile( level.current_match_event_log, new_message + "\n", true );
}

// filespump()
// {
// 	if ( !isDefined( level.log_messages ) )
// 	{
// 		level.log_messages = [];
// 	}
// 	while ( level.log_messages.size < 1 )
// 	{
// 		wait 0.05;
// 	}
// 	while ( true )
// 	{
// 		while ( level.log_messages.size > 0 )
// 		{
// 			level [[ level.log_messages[ 0 ].func ]]( level.log_messages[ 0 ].path, level.log_messages[ 0 ].id );
// 			arrayRemoveIndex( level.log_messages, 0 );
// 		}
// 		wait 0.05;
// 	}
// }