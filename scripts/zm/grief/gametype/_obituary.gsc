#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;

// create_griefed_obituary_msg( victim, attacker, weapon, mod )
// {
// 	//return va( "OBITUARY;%s;%s;%s;%s;%s;%s", victim.team, victim.name, attacker.team, attacker.name, weapon, mod );
// }

init_replacements()
{
	replaceFunc( maps/mp/zombies/_zm_utility::track_players_intersection_tracker, ::track_players_intersection_tracker_override );
}

watch_for_down( attacker )
{
	if ( is_true( self.grief_already_checking_for_down ) )
	{
		return;
	}
	self.grief_already_checking_for_down = 1;
	self waittill_notify_or_timeout( "player_downed", 4 );
	if ( self maps/mp/zombies/_zm_laststand::player_is_in_laststand() )
	{
		if ( isDefined( self.last_griefed_by.attacker ) )
		{
			self scripts/zm/grief/mechanics/_point_steal::player_steal_points( self.last_griefed_by.attacker, "down_player" );
			if ( isDefined( self.last_griefed_by.attacker ) && isDefined( self.last_griefed_by.meansofdeath ) )
			{
				if ( getDvarInt( "grief_killfeed_enable" ) == 1 )
				{
					//obituary_message = create_griefed_obituary_msg( self, self.last_griefed_by.attacker, self.last_griefed_by.weapon, self.last_griefed_by.meansofdeath );
					//players = array( self, self.last_griefed_by.attacker );
					//COM_PRINTF( "obituary g_log", "obituary", obituary_message, players );
					obituary( self, self.last_griefed_by.attacker, self.last_griefed_by.weapon, self.last_griefed_by.meansofdeath );
				}
				attacker.killsconfirmed++;
				attacker.pers[ "killsconfirmed" ]++;
			}
		}
	}
	self.grief_already_checking_for_down = 0;
}

track_players_intersection_tracker_override() //checked partially changed to match cerberus output //did not change while loop to for loop because continues in for loops go infinite
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