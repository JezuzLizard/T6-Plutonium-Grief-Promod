#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm;

//Function Overrides
round_spawning_override() //checked changed to match cerberus output
{
	level endon( "intermission" );
	level endon( "end_of_round" );
	level endon( "restart_round" );
	if ( level.intermission )
	{
		return;
	}
	if ( level.zombie_spawn_locations.size < 1 )
	{
		return;
	}
	ai_calculate_health( level.round_number );
	level.zombie_total = 999;
	level notify( "zombie_total_set" );
	old_spawn = undefined;
	while ( 1 )
	{
		while ( get_current_zombie_count() >= level.zombie_ai_limit || level.zombie_total <= 0 )
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

round_think_override( restart )
{
	flag_init( "grief_begin" );

	if ( !isdefined( restart ) )
		restart = 0;
	level endon( "end_round_think" );

	if ( !( isdefined( restart ) && restart ) )
	{
		if ( isdefined( level.initial_round_wait_func ) )
			[[ level.initial_round_wait_func ]]();

		if ( !( isdefined( level.host_ended_game ) && level.host_ended_game ) )
		{
			players = get_players();

			foreach ( player in players )
			{
				if ( !( isdefined( player.hostmigrationcontrolsfrozen ) && player.hostmigrationcontrolsfrozen ) )
				{
					player freezecontrols( 0 );
				}

				player maps\mp\zombies\_zm_stats::set_global_stat( "rounds", level.round_number );
			}
		}
	}
	if ( !isDefined( level.grief_zombies_init ) || ( level.grief_gamerules[ "zombie_round" ].current != level.grief_gamerules[ "zombie_round" ].lastvalue_this_match ) )
	{
		level.round_number = level.grief_gamerules[ "zombie_round" ].current;
		level.noroundnumber = true;
		set_zombie_spawn_rate( level.round_number );
		set_zombie_move_speed( level.round_number );
		level.grief_zombies_init = true;
	}
	setroundsplayed( 0 );

	for (;;)
	{
		maxreward = 50 * level.round_number;

		if ( maxreward > 500 )
			maxreward = 500;

		level.zombie_vars["rebuild_barrier_cap_per_round"] = maxreward;
		level.pro_tips_start_time = gettime();
		level.zombie_last_run_time = gettime();

		if ( isdefined( level.zombie_round_change_custom ) )
			[[ level.zombie_round_change_custom ]]();
		else
		{
			level thread maps\mp\zombies\_zm_audio::change_zombie_music( "round_start" );
		}

		maps\mp\zombies\_zm_powerups::powerup_round_start();
		players = get_players();
		array_thread( players, maps\mp\zombies\_zm_blockers::rebuild_barrier_reward_reset );

		if ( !( isdefined( level.headshots_only ) && level.headshots_only ) && !restart )
			level thread award_grenades_for_survivors();
		level.round_start_time = gettime();

		while ( level.zombie_spawn_locations.size <= 0 )
			wait 0.1;
		flag_wait( "grief_begin" );
		level thread [[ level.round_spawn_func ]]();
		level notify( "start_of_round" );
		recordzombieroundstart();
		players = getplayers();

		for ( index = 0; index < players.size; index++ )
		{
			zonename = players[index] get_current_zone();

			if ( isdefined( zonename ) )
				players[index] recordzombiezone( "startingZone", zonename );
		}

		if ( isdefined( level.round_start_custom_func ) )
			[[ level.round_start_custom_func ]]();

		[[ level.round_wait_func ]]();
		level.first_round = 0;
		level notify( "end_of_round" );
		level thread maps\mp\zombies\_zm_audio::change_zombie_music( "round_end" );
		uploadstats();

		if ( isdefined( level.round_end_custom_logic ) )
			[[ level.round_end_custom_logic ]]();
		array_thread( players, maps\mp\zombies\_zm_pers_upgrades_system::round_end );
		timer = level.zombie_vars["zombie_spawn_delay"];

		if ( timer > 0.08 )
			level.zombie_vars["zombie_spawn_delay"] = timer * 0.95;
		else if ( timer < 0.08 )
			level.zombie_vars["zombie_spawn_delay"] = 0.08;

		if ( level.gamedifficulty == 0 )
			level.zombie_move_speed = level.round_number * level.zombie_vars["zombie_move_speed_multiplier_easy"];
		else
			level.zombie_move_speed = level.round_number * level.zombie_vars["zombie_move_speed_multiplier"];

		level.round_number++;

		if ( 255 < level.round_number )
			level.round_number = 255;
		matchutctime = getutc();
		players = get_players();

		foreach ( player in players )
		{
			if ( level.curr_gametype_affects_rank && level.round_number > 3 + level.start_round )
				player maps\mp\zombies\_zm_stats::add_client_stat( "weighted_rounds_played", level.round_number );

			player maps\mp\zombies\_zm_stats::set_global_stat( "rounds", level.round_number );
			player maps\mp\zombies\_zm_stats::update_playing_utc_time( matchutctime );
		}

		check_quickrevive_for_hotjoin();
		level round_over();
		level notify( "between_round_over" );
		restart = 0;
	}
}

set_zombie_spawn_rate( round )
{
	level.zombie_vars["zombie_spawn_delay"] = 2;
	for ( i = 0; i < round; i++ )
	{
		level.zombie_vars["zombie_spawn_delay"] *= 0.95;
	}
}

set_zombie_move_speed( round )
{
	level.zombie_move_speed = round * level.zombie_vars["zombie_move_speed_multiplier"];
}

meat_bounce_override( pos, normal, ent ) //checked matches cerberus output
{
	if ( isdefined( ent ) && isplayer( ent ) )
	{
		if ( !ent maps\mp\zombies\_zm_laststand::player_is_in_laststand() )
		{
			if ( isDefined( level.grief_meat_stink_player ) )
			{
				level thread [[ level.grief_meat_stink_player ]]( ent );
			}
			if ( isdefined( self.owner ) )
			{
				maps\mp\_demo::bookmark( "zm_player_meat_stink", GetTime(), ent, self.owner, 0, self );
				self.owner maps\mp\zombies\_zm_stats::increment_client_stat( "contaminations_given" );
			}
		}
	}
	else
	{
		players = getplayers();
		closest_player = undefined;
		closest_player_dist = 10000;
		player_index = 0;
		while ( player_index < players.size )
		{
			player_to_check = players[ player_index ];
			if ( self.owner == player_to_check )
			{
				player_index++;
				continue;
			}
			if ( player_to_check maps\mp\zombies\_zm_laststand::player_is_in_laststand() )
			{
				player_index++;
				continue;
			}
			distsq = distancesquared( pos, player_to_check.origin );
			if ( distsq < closest_player_dist )
			{
				closest_player = player_to_check;
				closest_player_dist = distsq;
			}
			player_index++;
		}
		if ( isdefined( closest_player ) )
		{
			if ( isDefined( level.grief_meat_stink_player ) )
			{
				level thread [[ level.grief_meat_stink_player ]]( closest_player );
			}
			if ( isdefined( self.owner ) )
			{
				maps\mp\_demo::bookmark( "zm_player_meat_stink", GetTime(), closest_player, self.owner, 0, self );
				self.owner maps\mp\zombies\_zm_stats::increment_client_stat( "contaminations_given" );
			}
		}
		else
		{
			valid_poi = check_point_in_enabled_zone( pos, undefined, undefined );
			if ( valid_poi )
			{
				self hide();
				if ( isDefined( level.grief_meat_stink_on_ground ) )
				{
					level thread [[ level.grief_meat_stink_on_ground ]]( self.origin );
				}
			}
		}
		playfx( level._effect[ "meat_impact" ], self.origin );
	}
	self delete();
}

init_zombie_run_cycle_override()
{
	if ( !isDefined(level.zombie_vars_init) )
	{
		level.zombie_vars_init = 1;
		level.walker_num_max = level.grief_gamerules[ "max_walkers" ].current;
		level.walker_num = 0;
		level.zombie_ai_limit = level.grief_gamerules[ "max_zombies" ].current;
		level.zombie_move_speed = 666;
	}

	if ( !level.walker_num_max )
	{
		self set_zombie_run_cycle();
	}
	else
	{
		change_left = level.walker_num_max - level.walker_num;
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