
randomize_powerups_o() //checked matches cerberus output
{
	level.zombie_powerup_array = array_randomize( level.zombie_powerup_array );
}

get_next_powerup_o() //checked matches cerberus output
{
	powerup = level.zombie_powerup_array[ level.zombie_powerup_index ];
	level.zombie_powerup_index++;
	if ( level.zombie_powerup_index >= level.zombie_powerup_array.size )
	{
		level.zombie_powerup_index = 0;
		randomize_powerups_o();
	}
	return powerup;
}

get_valid_powerup_o() //checked partially matches cerberus output did not change
{
	if ( isDefined( level.zombie_powerup_boss ) )
	{
		i = level.zombie_powerup_boss;
		level.zombie_powerup_boss = undefined;
		return level.zombie_powerup_array[ i ];
	}
	powerup = get_next_powerup_o();
	disable_powerups = strTok( level.grief_restrictions[ "powerups" ], " " );
	while ( 1 )
	{
		for ( i = 0; i < level.data_maps[ "powerups" ][ "default_allowed_powerups" ].size; i++ )
		{
			if ( level.data_maps[ "powerups" ][ "default_allowed_powerups" ][ i ] == powerup )
			{
				if ( level.data_maps[ "powerups" ][ "is_active" ][ i ] == "1" )
				{
					return powerup;
				}
			}
		}
		powerup = get_next_powerup_o();	
	}
}