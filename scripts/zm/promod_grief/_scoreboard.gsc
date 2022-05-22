#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_score;

setup_scoreboard()
{
	if ( level.grief_ffa )
	{
		setscoreboardcolumns( "score", "stabs", "killsconfirmed", "survived", "downs" );
		setDvar( "player_lastStandBleedoutTime", 1.0 );
		level.zombie_vars[ "penalty_downed" ] = 0;
		level.zombie_vars[ "penalty_no_revive" ] = 0;
	}
	else 
	{
		setscoreboardcolumns( "score", "stabs", "killsconfirmed", "revives", "downs" );	
	}
}

change_status_icon( is_alive )
{
	if ( is_alive )
	{
		self.statusicon = "waypoint_revive";
		self thread update_icon_on_bleedout();
		
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

remove_status_icons_on_end_game()
{
	level waittill("end_game");

	wait 5;

	players = get_players();
	foreach(player in players)
	{
		player.statusicon = "";
	}
}

watch_for_down()
{
	level endon( "end_game" );
	self endon( "disconnect" );
	while ( true )
	{
		flag_wait( "spawn_zombies" );
		in_laststand = self maps\mp\zombies\_zm_laststand::player_is_in_laststand();
		is_alive = isAlive( self );
		if ( is_true( in_laststand ) || !is_true( is_alive ) )
		{
			if ( isDefined( self.last_griefed_by.attacker ) )
			{
				self scripts\zm\promod_grief\_damage::player_steal_points( self.last_griefed_by.attacker, "down_player" );
				if ( isDefined( self.last_griefed_by.weapon ) && isDefined( self.last_griefed_by.meansofdeath ) && ( ceil( ( getTime() - self.last_griefed_by.time ) / 1000 ) < 4 ) )
				{
					obituary( self, self.last_griefed_by.attacker, self.last_griefed_by.weapon, self.last_griefed_by.meansofdeath );
					self.last_griefed_by.attacker.killsconfirmed++;
				}
				else 
				{
					obituary(self, self, "none", "MOD_SUICIDE");
				}
			}
			else 
			{
				obituary(self, self, "none", "MOD_SUICIDE");
			}
			self thread change_status_icon( is_alive );
			self waittill_either( "player_revived", "spawned_player" );
			self.statusicon = "";
		}
		wait 0.05;
	}
}