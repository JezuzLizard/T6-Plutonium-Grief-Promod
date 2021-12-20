#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/zombies/_zm;
#include maps/mp/_utility;

init_zombie_run_cycle_override()
{
	if ( !isDefined(level.zombie_vars_init) )
	{
		level.zombie_vars_init = 1;
		level.walker_num_max = level.grief_gamerules[ "max_number_walkers" ];
		level.walker_num = 0;
		// level.sprinter_num_max = level.grief_gamerules[ "max_number_super_sprinters" ];
		// level.sprinter_num = 0;
		level.zombie_ai_limit = level.grief_gamerules[ "max_number_zombies" ];
		level.zombie_move_speed = level.grief_gamerules[ "zombie_power_level_start" ] * level.zombie_vars[ "zombie_move_speed_multiplier" ];
	}

	if ( !level.walker_num_max )
	{
		self set_zombie_run_cycle();
	}
	else
	{
		speed_percent = 0.2 + ( ( level.grief_gamerules[ "zombie_power_level_start" ] - 15 ) * 0.2 );
		speed_percent = min( speed_percent, 1 );
		change_round_max = int( level.walker_num_max * speed_percent );
		change_left = change_round_max - level.walker_num;
		if ( change_left == 0 )
		{
			self set_zombie_run_cycle();
			return;
		}
		change_speed = randomint( 100 );
		if ( change_speed > 80 )
		{
			self change_zombie_run_cycle();
			return;
		}
		zombie_count = get_current_zombie_count();
		zombie_left = level.zombie_ai_limit - zombie_count;
		if ( zombie_left == change_left )
		{
			self change_zombie_run_cycle();
			return;
		}
		self set_zombie_run_cycle();
	}
}

change_zombie_run_cycle() //checked matches cerberus output
{
	level.walker_num++;
	self set_zombie_run_cycle( "walk" );
	self thread speed_change_watcher();
}

speed_change_watcher() //checked matches cerberus output
{
	self waittill( "death" );
	if ( level.walker_num > 0 )
	{
		level.walker_num--;
	}
}

set_zombie_run_cycle( new_move_speed )
{
	self.zombie_move_speed_original = self.zombie_move_speed;
	if ( isDefined( new_move_speed ) )
	{
		self.zombie_move_speed = new_move_speed;
	}
	else
	{
		self set_run_speed();
	}
	self maps/mp/animscripts/zm_run::needsupdate();
	self.deathanim = self maps/mp/animscripts/zm_utility::append_missing_legs_suffix( "zm_death" );
}

powerup_zombies()
{
	level.zombie_power_level++;
	set_zombie_spawn_speed();
	maps/mp/zombies/_zm::ai_calculate_health( level.zombie_power_level );
}

set_zombie_spawn_speed()
{
	level.zombie_vars[ "zombie_spawn_delay" ] = 2;

	for ( i = 1; i <= level.zombie_power_level; i++ )
	{
		timer = level.zombie_vars[ "zombie_spawn_delay" ];
		if ( timer > 0.08)
		{
			level.zombie_vars[ "zombie_spawn_delay" ] = timer * 0.95;
		}
		else if ( timer < 0.08 )
		{
			level.zombie_vars[ "zombie_spawn_delay" ] = 0.08;
			return;
		}
	}
}

set_zombie_power_level( round )
{
	level.zombie_power_level = round;
	set_zombie_spawn_speed();
	maps/mp/zombies/_zm::ai_calculate_health( round );
}

set_run_speed()
{

	rand = randomintrange( level.zombie_move_speed, level.zombie_move_speed + 35 );
	if ( rand <= 35 )
	{
		self.zombie_move_speed = "walk";
	}
	else if ( rand <= 70 )
	{
		self.zombie_move_speed = "run";
	}
	else
	{
		self.zombie_move_speed = "sprint";
	}
}

speedup_at_powerup()
{
	self endon( "death" );
	while ( true )
	{
		if ( level.zombie_power_level > 1 )
		{
			self.zombie_move_speed = "sprint";
			break;
		}
		wait 0.05;
	}
}

zombie_spawning() //checked changed to match cerberus output
{
	level endon( "end_game" );
	old_spawn = undefined;
	level.zombie_vars[ "zombie_spawn_delay" ] = 2;
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
		spawning_disabled_by_engine = getDvarInt( "ai_disablespawn" );
		while ( spawning_disabled_by_engine )
		{
			wait 1;
		}
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
			if ( !spawning_disabled_by_engine )
			{
				ai = spawn_zombie( spawner, spawner.targetname, spawn_point );
			}
		}
		if ( isDefined( ai ) )
		{
			ai thread maps/mp/zombies/_zm::round_spawn_failsafe();
		}
		wait level.zombie_vars[ "zombie_spawn_delay" ];
		wait_network_frame();
	}
}

zombie_spawn_delay_fix( round )
{
	i = 1;
	while ( i <= round )
	{
		timer = 2;
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