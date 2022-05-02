#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;

getfreespawnpoint_override( spawnpoints, player )
{
	print( "spawnpoints.size " + spawnpoints.size );
	assign_spawnpoints_player_data( spawnpoints, player );
	for ( j = 0; j < spawnpoints.size; j++ )
	{
		if ( spawnpoints[ j ].player_property == player.name )
		{
			print( "Found spawnpoint for " + player.name );
			return spawnpoints[ j ];
		}
	}
}

assign_spawnpoints_player_data( spawnpoints, player )
{
	remove_disconnected_players_spawnpoint_property( spawnpoints );
	for ( i = 0; i < spawnpoints.size; i++ )
	{
		if ( !isDefined( spawnpoints[ i ].player_property ) )
		{
			spawnpoints[ i ].player_property = player.name;
			break;
		}
	}
}

remove_disconnected_players_spawnpoint_property( spawnpoints )
{
	for ( i = 0; i < spawnpoints.size; i++ )
	{
		spawnpoints[ i ].do_not_discard_player_property = false;
	}
	players = getPlayers();
	for ( i = 0; i < spawnpoints.size; i++ )
	{
		if ( isDefined( spawnpoints[ i ].player_property ) )
		{
			for ( j = 0; j < players.size; j++ )
			{
				if ( spawnpoints[ i ].player_property == players[ j ].name )
				{
					spawnpoints[ i ].do_not_discard_player_property = true;
					break;
				}
			}
		}
	}
	for ( i = 0; i < spawnpoints.size; i++ )
	{
		if ( !spawnpoints[ i ].do_not_discard_player_property )
		{
			spawnpoints[ i ].player_property = undefined;
		}
	}
}

