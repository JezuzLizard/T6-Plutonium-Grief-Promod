
docks_ambiance()
{
	for ( i = 0; i < 6; i++ )
	{
		add_random_sound( "ambiance", "seagull_0" + i, 10 );
	}
	for ( i = 0; i < 2; i++ )
	{
		add_random_sound( "ambiance", "wave_0" + i, 10 );
	}
}