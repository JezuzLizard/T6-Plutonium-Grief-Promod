init_zombie_run_cycle_o() //checked matches cerberus output
{
	self set_zombie_run_cycle();
}

change_zombie_run_cycle_o() //checked matches cerberus output
{
	self set_zombie_run_cycle( "walk" );
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
	self set_run_speed();
	self maps/mp/animscripts/zm_run::needsupdate();
	self.deathanim = self maps/mp/animscripts/zm_utility::append_missing_legs_suffix( "zm_death" );
}

set_run_speed() //checked matches cerberus output
{
	if ( !isDefined( level.bus_sprinters ) )
	{
		level.bus_sprinters = 0;
		level.bus_sprinter_max = 1;
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

zombie_watch_for_bus_sprinter()
{
	self waittill( "zombie_movespeed_set" );
	if ( is_true( self.is_bus_sprinter ) )
	{
		self waittill( "death" );
		level.bus_sprinters--;
	}
}

zombie_spawning() //checked changed to match cerberus output
{
	level endon( "end_game" );
	old_spawn = undefined;
	while ( 1 )
	{
		while ( get_current_zombie_count() >= level.zombie_ai_limit )
		{
			wait 0.1;
		}
		while ( get_current_actor_count() >= level.zombie_actor_limit )
		{
			clear_all_corpses();
			wait 0.1;
		}
		flag_wait( "spawn_zombies" );
		while ( level.zombie_spawn_locations.size <= 0 )
		{
			wait 0.1;
		}
		run_custom_ai_spawn_checks();
		spawn_point = level.zombie_spawn_locations[ randomint( level.zombie_spawn_locations.size ) ];
		if ( !isDefined( old_spawn ) )
		{
			old_spawn = spawn_point;
		}
		else if ( spawn_point == old_spawn )
		{
			spawn_point = level.zombie_spawn_locations[ randomint( level.zombie_spawn_locations.size ) ];
		}
		old_spawn = spawn_point;
		if ( isDefined( level.zombie_spawners ) )
		{
			if ( is_true( level.use_multiple_spawns ) )
			{
				if ( isDefined( spawn_point.script_int ) )
				{
					if ( isDefined( level.zombie_spawn[ spawn_point.script_int ] ) && level.zombie_spawn[ spawn_point.script_int ].size )
					{
						spawner = random( level.zombie_spawn[ spawn_point.script_int ] );
					}
				}
				else if ( isDefined( level.zones[ spawn_point.zone_name ].script_int ) && level.zones[ spawn_point.zone_name ].script_int )
				{
					spawner = random( level.zombie_spawn[ level.zones[ spawn_point.zone_name ].script_int ] );
				}
				else if ( isDefined( level.spawner_int ) && isDefined( level.zombie_spawn[ level.spawner_int ].size ) && level.zombie_spawn[ level.spawner_int ].size )
				{
					spawner = random( level.zombie_spawn[ level.spawner_int ] );
				}
				else
				{
					spawner = random( level.zombie_spawners );
				}
			}
			else
			{
				spawner = random( level.zombie_spawners );
			}
			ai = spawn_zombie( spawner, spawner.targetname, spawn_point );
		}
		if ( isDefined( ai ) )
		{
			ai thread round_spawn_failsafe();
		}
		wait level.zombie_vars[ "zombie_spawn_delay" ];
		wait_network_frame();
	}
}

zombie_spawn_delay_fix()
{
	i = 1;
	while ( i <= level.grief_gamerules[ "zombie_round" ] )
	{
		timer = level.zombie_vars[ "zombie_spawn_delay" ];
		if ( timer > 0.08 )
		{
			level.zombie_vars[ "zombie_spawn_delay" ] = timer * 0.95;
			i++;
			continue;
		}
		if ( timer < 0.08 )
		{
			level.zombie_vars[ "zombie_spawn_delay" ] = 0.08;
			break;
		}
		i++;
	}
}

zombie_speed_fix()
{
	if ( level.gamedifficulty == 0 )
	{
		level.zombie_move_speed = level.grief_gamerules[ "zombie_round" ] * level.zombie_vars[ "zombie_move_speed_multiplier_easy" ];
	}
	else
	{
		level.zombie_move_speed = level.grief_gamerules[ "zombie_round" ] * level.zombie_vars[ "zombie_move_speed_multiplier" ];
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