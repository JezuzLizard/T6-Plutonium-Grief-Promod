#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;

getFreeSpawnpoint_override( spawnpoints, player )
{
	if ( !isdefined( spawnpoints ) )
	{
		return undefined;
	}
	//Randomize the spawnpoints so players don't spawn at the same one each game in order of connecting.
	spawnpoints = array_randomize( spawnpoints );
	//If we are using the script_int system to make the starting teams spawn facing each other. 
	//We only spawn players if their team script_int matches the spawnpoint script_int. 
	//Treyarch's normal spawnpoints do this to a degree.
	if ( is_true( level.spawnpoint_system_using_script_ints ) )
	{
		foreach ( spawnpoint in spawnpoints )
		{
			if ( spawnpoint.script_int == self.spawnpoint_desired_script_int )
			{
				if ( isDefined( spawnpoint.player_name ) && spawnpoint.player_name == self.name )
				{
					return spawnpoint;
				}
				else if ( !isDefined( spawnpoint.player_name ) )
				{
					spawnpoint.player_name = self.name;
					return spawnpoint;
				}
			}
		}
	}
	//If we aren't using the script_int system or we are and we ran out of spawnpoints due to many players joining and leaving try to free up old spawnpoints.
	foreach ( spawnpoint in spawnpoints )
	{
		spawnpoint_is_active = false;
		foreach ( player in level.players )
		{
			if ( spawnpoint.player_name == player.name )
			{
				spawnpoint_is_active = true;
				break;
			}
		}
		if ( !spawnpoint_is_active )
		{
			if ( is_true( level.spawnpoint_system_using_script_ints ) )
			{
				if ( spawnpoint.script_int == self.spawnpoint_desired_script_int )
				{
					spawnpoint.player_name = self.name;
					return spawnpoint;
				}
			}
			else 
			{
				spawnpoint.player_name = self.name;
				return spawnpoint;
			}
		}
	}
	//This shouldn't happen but if it does something went wrong.
	print( "getFreeSpawnpoint() is returning a failsafe spawnpoint THIS SHOULD NOT HAPPEN!" );
	return spawnpoints[ 0 ];
}

