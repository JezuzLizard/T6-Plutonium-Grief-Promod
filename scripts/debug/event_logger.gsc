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
		print( ( getTime() / 1000 ) + " " + event + " STARTED" );
	}
}

//If a program successfully concluded then every event should have ended.
EVENT_END( event )
{
	if ( level.debug_event_logging )
	{
		print( ( getTime() / 1000 ) + " " + event + " ENDED" );
	}
}

EVENT_LOGPRINT( event, message )
{
	if ( level.debug_event_logging )
	{
		print( ( getTime() / 1000 ) + " " + event + ": " + message );
	}
}