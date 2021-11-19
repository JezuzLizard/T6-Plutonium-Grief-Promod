#include maps/mp/_utility;
#include common_scripts/utility;

initial_timescale_test()
{
	level.unit_test_timescale = getDvarIntDefault( "scr_unit_test_timescale", 0 );
	if ( level.unit_test_timescale )
	{
		setDvar( "timescale", 10 );
	}
}