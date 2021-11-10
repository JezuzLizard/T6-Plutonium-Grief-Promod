#include common_scripts/utility;

init_replacements()
{
	replaceFunc( maps/mp/zombies/_zm_powerups::randomize_powerups, ::randomize_powerups_override );
	replaceFunc( maps/mp/zombies/_zm_powerups::get_next_powerup, ::get_next_powerup_override );
	replaceFunc( maps/mp/zombies/_zm_powerups::get_valid_powerup, ::get_valid_powerup_override );
}

randomize_powerups_override() //checked matches cerberus output
{
	level.zombie_powerup_array = array_randomize( level.zombie_powerup_array );
}

get_next_powerup_override() //checked matches cerberus output
{
	powerup = level.zombie_powerup_array[ level.zombie_powerup_index ];
	level.zombie_powerup_index++;
	if ( level.zombie_powerup_index >= level.zombie_powerup_array.size )
	{
		level.zombie_powerup_index = 0;
		randomize_powerups_override();
	}
	return powerup;
}

get_valid_powerup_override() //checked partially matches cerberus output did not change
{
	if ( isDefined( level.zombie_powerup_boss ) )
	{
		i = level.zombie_powerup_boss;
		level.zombie_powerup_boss = undefined;
		return level.zombie_powerup_array[ i ];
	}
	powerup = get_next_powerup_override();
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
		powerup = get_next_powerup_override();	
	}
}