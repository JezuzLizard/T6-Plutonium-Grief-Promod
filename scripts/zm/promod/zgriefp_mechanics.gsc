#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/zombies/_zm_magicbox;
#include maps/mp/zombies/_zm_laststand;
#include maps/mp/animscripts/zm_utility;
#include maps/mp/animscripts/zm_run;
#include maps/mp/zombies/_zm;

treasure_chest_init( start_chest_name ) //checked changed to match cerberus output
{
	flag_init( "moving_chest_enabled" );
	flag_init( "moving_chest_now" );
	flag_init( "chest_has_been_used" );
	level.chest_moves = 0;
	level.chest_level = 0;
	if ( level.chests.size == 0 )
	{
		return;
	}
	for ( i = 0; i < level.chests.size; i++ )
	{
		level.chests[ i ].box_hacks = [];
		level.chests[ i ].orig_origin = level.chests[ i ].origin;
		level.chests[ i ] get_chest_pieces();
		if ( isDefined( level.chests[ i ].zombie_cost ) )
		{
			level.chests[ i ].old_cost = level.chests[ i ].zombie_cost;
		}
		else 
		{
			level.chests[ i ].old_cost = 950;
		}
	}
	if ( !level.enable_magic || !level.grief_gamerules[ "mystery_box_enabled" ] )
	{
		foreach( chest in level.chests )
		{
			chest hide_chest();
		}
		return;
	}
	level.chest_accessed = 0;
	if ( level.chests.size > 1 )
	{
		flag_set( "moving_chest_enabled" );
		level.chests = array_randomize( level.chests );
	}
	else
	{
		level.chest_index = 0;
		level.chests[ 0 ].no_fly_away = 1;
	}
	init_starting_chest_location( start_chest_name );
	array_thread( level.chests, ::treasure_chest_think );
}

track_players_intersection_tracker() //checked partially changed to match cerberus output //did not change while loop to for loop because continues in for loops go infinite
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
				if ( isDefined( level.player_intersection_tracker_override ) )
				{
					if ( players[ i ] [[ level.player_intersection_tracker_override ]]( players[ j ] ) )
					{
						j++;
						continue;
					}
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
				if ( is_true( players[ i ].is_grief_jumped_on ) )
				{
					obituary( players[ j ], players[ i ], "none", "MOD_IMPACT" );
					players[ i ].is_grief_jumped_on = undefined;
				}
				else if ( is_true( players[ j ].is_grief_jumped_on ) )
				{
					obituary( players[ i ], players[ j ], "none", "MOD_IMPACT" );
					players[ j ].is_grief_jumped_on = undefined;
				}
				killed_players = 1;
				j++;
			}
			i++;
		}
		wait 0.5;
	}
}

init_zombie_run_cycle() //checked matches cerberus output
{
	self set_zombie_run_cycle();
}

change_zombie_run_cycle() //checked matches cerberus output
{
	if ( level.gamedifficulty == 0 )
	{
		self set_zombie_run_cycle( "sprint" );
	}
	else
	{
		self set_zombie_run_cycle( "walk" );
	}
	self thread speed_change_watcher();
}

speed_change_watcher() //checked matches cerberus output
{
	self waittill( "death" );
}

set_zombie_run_cycle( new_move_speed ) //checked matches cerberus output
{
	self.zombie_move_speed_original = self.zombie_move_speed;
	if ( isDefined( new_move_speed ) )
	{
		self.zombie_move_speed = new_move_speed;
	}
	else if ( level.gamedifficulty == 0 )
	{
		self set_run_speed_easy();
	}
	else
	{
		self set_run_speed();
	}
	self maps/mp/animscripts/zm_run::needsupdate();
	self.deathanim = self maps/mp/animscripts/zm_utility::append_missing_legs_suffix( "zm_death" );
}

set_run_speed() //checked matches cerberus output
{
	if ( !isDefined( level.bus_sprinters ) )
	{
		level.bus_sprinters = 0;
		level.bus_sprinter_max = 1;
		logline1 = "level.bus_sprinters initialized" + "\n";
		logprint( logline1 );
	}
	if ( !isDefined( level.zombie_movespeed_type_array ) )
	{
		level.zombie_movespeed_type_array = [];
		level.zombie_movespeed_type_array[ 0 ] = "walk";
		level.zombie_movespeed_type_array[ 1 ] = "run";
		level.zombie_movespeed_type_array[ 2 ] = "sprint";
		level.zombie_movespeed_type_array[ 3 ] = "sprint";
		level.zombie_movespeed_type_array[ 4 ] = "sprint";
		level.zombie_movespeed_type_array[ 5 ] = "super_sprint";
		level.zombie_movespeed_type_array[ 6 ] = "super_sprint";
		level.zombie_movespeed_type_array[ 7 ] = "super_sprint";
		if ( level.script == "zm_transit" )
		{
			level.zombie_movespeed_type_array[ 8 ] = "chase_bus";
		}
	}
	rand = randomintrange( level.zombie_move_speed, level.zombie_move_speed + 35 );
	if ( rand <= 35 )
	{
		self.zombie_move_speed = "walk";
	}
	else if ( rand <= 70 )
	{
		self.zombie_move_speed = "run";
	}
	else if ( rand <= 200 )
	{
		self.zombie_move_speed = "sprint";
	}
	else if ( !level.grief_gamerules[ "disable_zombie_special_runspeeds" ] )
	{
		if ( rand <= 219 )
		{
			if ( !isDefined( level.grief_super_sprinter_zombies_start ) )
			{
				level.grief_super_sprinter_zombies_start = true;
			}
			self thread make_super_sprinter( "super_sprint" );
		}
		else
		{
			speed = random( level.zombie_movespeed_type_array );
			if ( speed == "chase_bus" && ( level.bus_sprinters < level.bus_sprinter_max ) )
			{
				self.is_bus_sprinter = true;
				level.bus_sprinters++;
			}
			else 
			{
				speed = "super_sprint";
			}
			if ( speed == "super_sprint" || speed == "chase_bus" )
			{
				self thread make_super_sprinter( speed );
				self thread zombie_watch_for_bus_sprinter();
			}
			else
			{
				self.zombie_move_speed = speed;
			}
		}
	}
	else
	{
		self.zombie_move_speed = "sprint";
	}
}

make_super_sprinter( special_movespeed )
{
	self.zombie_move_speed = "sprint";
	while ( 1 )
	{
		if ( self in_enabled_playable_area() )
		{
			self.zombie_move_speed = special_movespeed;
			self notify( "zombie_movespeed_set" );
			break;
		}
		wait 0.05;
	}
}

zombie_watch_for_bus_sprinter()
{
	self waittill( "zombie_movespeed_set" );
	if ( is_true( self.is_bus_sprinter ) )
	{
		self waittill( "death" );
		level.bus_sprinters--;
	}
}

set_run_speed_easy() //checked matches cerberus output
{
	rand = randomintrange( level.zombie_move_speed, level.zombie_move_speed + 25 );
	if ( rand <= 35 )
	{
		self.zombie_move_speed = "walk";
	}
	else
	{
		self.zombie_move_speed = "run";
	}
}