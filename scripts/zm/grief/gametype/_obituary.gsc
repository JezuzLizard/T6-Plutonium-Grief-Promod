#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;

// create_griefed_obituary_msg( victim, attacker, weapon, mod )
// {
// 	//return va( "OBITUARY;%s;%s;%s;%s;%s;%s", victim.team, victim.name, attacker.team, attacker.name, weapon, mod );
// }

watch_for_down()
{
	level endon( "end_game" );
	self endon( "disconnect" );
	while ( true )
	{
		flag_wait( "spawn_zombies" );
		in_laststand = self maps/mp/zombies/_zm_laststand::player_is_in_laststand();
		is_alive = isAlive( self );
		if ( in_laststand || !is_alive )
		{
			if ( isDefined( self.last_griefed_by.attacker ) )
			{
				self scripts/zm/grief/mechanics/_point_steal::attacker_steal_points( self.last_griefed_by.attacker, "down_player" );
				if ( isDefined( self.last_griefed_by.weapon ) && isDefined( self.last_griefed_by.meansofdeath ) && ( ceil( ( getTime() - self.last_griefed_by.time ) / 1000 ) < 4 ) )
				{
					obituary( self, self.last_griefed_by.attacker, self.last_griefed_by.weapon, self.last_griefed_by.meansofdeath );
					self.last_griefed_by.attacker.killsconfirmed++;
					//self.last_griefed_by.attacker.pers[ "killsconfirmed" ]++;
				}
				else 
				{
					obituary(self, self, "none", "MOD_SUICIDE");
				}
				//self thread scripts/zm/grief/mechanics/_point_steal::steal_points_on_bleedout( self.last_griefed_by.attacker );
			}
			else 
			{
				obituary(self, self, "none", "MOD_SUICIDE");
			}
			self thread change_status_icon( is_alive );
			self waittill_either( "player_revived", "spawned" );
			self.statusicon = "";
		}
		wait 0.05;
	}
}

change_status_icon( is_alive )
{
	if ( is_alive )
	{
		self.statusicon = "waypoint_revive";
		self thread update_icon_on_bleedout()
		
	}
	else 
	{
		self.statusicon = "hud_status_dead";
	}
}

update_icon_on_bleedout()
{
	level endon( "end_game" );
	self endon( "spawned" );
	self endon( "player_revived" );
	self waittill( "bled_out" );
	self.statusicon = "hud_status_dead";
}

track_players_intersection_tracker_override()
{
	self endon( "disconnect" );
	self endon( "death" );
	level endon( "end_game" );
	wait 5;
	while ( 1 )
	{
		killed_players = 0;
		players = getPlayers();
		i = 0;
		while ( i < players.size )
		{
			if ( players[ i ] maps/mp/zombies/_zm_laststand::player_is_in_laststand() || players[ i ].sessionstate != "playing" )
			{
				i++;
				continue;
			}
			j = 0;
			while ( j < players.size )
			{
				if ( j == i || players[ j ] maps/mp/zombies/_zm_laststand::player_is_in_laststand() || players[ j ].sessionstate != "playing" )
				{
					j++;
					continue;
				}
				playeri_origin = players[ i ].origin;
				playerj_origin = players[ j ].origin;
				if ( abs( playeri_origin[ 2 ] - playerj_origin[ 2 ] ) > 60 )
				{
					j++;
					continue;
				}
				distance_apart = distance2d( playeri_origin, playerj_origin );
				if ( abs( distance_apart ) > 18 )
				{
					j++;
					continue;
				}
				if ( players[ i ] getStance() == "prone" )
				{
					players[ i ].is_grief_jumped_on = true;
				}
				else if ( players[ j ] getStance() == "prone" )
				{
					players[ j ].is_grief_jumped_on = true;
				}
				players[ i ] dodamage( 1000, ( 0, 0, 1 ) );
				players[ j ] dodamage( 1000, ( 0, 0, 1 ) );
				if ( !killed_players )
				{
					players[ i ] playlocalsound( level.zmb_laugh_alias );
				}
				if ( is_true( players[ j ].is_grief_jumped_on ) )
				{
					// obituary_message = create_griefed_obituary_msg( players[ i ], players[ j ], "none", "MOD_IMPACT" );
					// players = array( players[ i ], players[ j ] );
					//COM_PRINTF( "obituary g_log", "obituary", obituary_message, players );
					players[ i ].is_grief_jumped_on = undefined;
					obituary( players[ j ], players[ i ], "none", "MOD_IMPACT" );
				}
				else if ( is_true( players[ i ].is_grief_jumped_on ) )
				{
					// obituary_message = create_griefed_obituary_msg( players[ j ], players[ i ], "none", "MOD_IMPACT" );
					// players = array( players[ j ], players[ i ] );
					//COM_PRINTF( "obituary g_log", "obituary", obituary_message, players );
					players[ j ].is_grief_jumped_on = undefined;
					obituary( players[ i ], players[ j ], "none", "MOD_IMPACT" );
				}
				killed_players = 1;
				j++;
			}
			i++;
		}
		wait 0.5;
	}
}