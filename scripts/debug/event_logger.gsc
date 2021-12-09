#include maps/mp/_utility;
#include common_scripts/utility;

initialize_event_logger()
{
	level.debug_event_logging = getDvarIntDefault( "scr_debug_event_logging", 0 );
}

EVENT_START( event )
{
	if ( level.debug_event_logging )
	{
		message = event + " STARTED";
		print( ( getTime() / 1000 ) + " " + message );
		logPrint( message + "\n" );
	}
}

//If a program successfully concluded then every event should have ended.
EVENT_END( event )
{
	if ( level.debug_event_logging )
	{
		message = event + " ENDED";
		print( ( getTime() / 1000 ) + " " + message );
		logPrint( message + "\n" );
	}
}

EVENT_LOGPRINT( event, message )
{
	if ( level.debug_event_logging )
	{
		log = event + ": " + message;
		print( ( getTime() / 1000 ) + " " + log );
		logPrint( log + "\n" );
	}
}