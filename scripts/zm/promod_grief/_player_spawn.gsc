#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;

getFreeSpawnpoint_override( spawnpoints, player )
{
	if ( !isdefined( spawnpoints ) )
	{
		return undefined;
	}
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
	else
	{
		foreach ( spawnpoint in spawnpoints )
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

hide_gump_loading_for_hotjoiners_override()
{
	self endon( "disconnect" );
	self.rebuild_barrier_reward = 1;
	self.is_hotjoining = 1;
	if ( flag( "grief_begin" ) )
	{
		num = self getsnapshotackindex();
		while ( num == self getsnapshotackindex() )
			wait 0.25;
		wait 0.5;
		self maps\mp\zombies\_zm::spawnspectator();
	}
	self.is_hotjoining = 0;
	self.is_hotjoin = 1;

	if ( is_true( level.intermission ) || is_true( level.host_ended_game ) )
	{
		setclientsysstate( "levelNotify", "zi", self );
		self setclientthirdperson( 0 );
		self resetfov();
		self.health = 100;
		self thread [[ level.custom_intermission ]]();
	}
}

game_mode_spawn_player_logic_override()
{
	if ( flag( "grief_begin" ) && !level.zombie_vars[ "spectators_respawn" ]  )
	{
		self.is_hotjoin = 1;
		return true;
	}
	return false;
}