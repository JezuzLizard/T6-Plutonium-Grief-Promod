#include maps/mp/_utility;
#include common_scripts/utility;

initialize_unit_test_bots()
{
	level.bot_unit_testing = getDvarIntDefault( "scr_unit_tests_bot_join_leaving_active", 0 );
	if ( level.bot_unit_testing )
	{
		joining_leaving_test();
	}
}

joining_leaving_test()
{
	type = getDvar( "scr_unit_tests_bot_join_leaving_type" ); //types are regular, all, stay, and random
	min_bots = getDvarIntDefault( "scr_unit_tests_bot_join_leaving_min_bots", 1 );
	max_bots = getDvarIntDefault( "scr_unit_tests_bot_join_leaving_max_bots", 8 );
	min_time = getDvarIntDefault( "scr_unit_tests_bot_join_leaving_min_time", 30 );
	max_time = getDvarIntDefault( "scr_unit_tests_bot_join_leaving_max_time", 60 );
	switch ( type )
	{
		case "regular":
			level thread spawn_and_kick_bots_periodically( min_bots, min_time );
			break;
		case "all":
			level thread spawn_all_kick_all_bots( min_bots, min_time );
			break;
		case "random":
			level thread spawn_and_kick_bots_randomly( min_bots, max_bots, min_time, max_time );
			break;
		case "stay":
			level thread spawn_bots_stay( min_bots );
			break;
		default:
			break;
	}
	if ( getDvarIntDefault( "scr_unit_tests_bot_join_leaving_allow_game_end", 0 ) )
	{
		level thread bot_round_test();
	}
}

spawn_all_kick_all_bots( num, min_time )
{
	while ( true )
	{
		for ( ; getPlayers().size < num; i++ )
		{
			bot = addTestClient();
			bot.pers[ "isBot" ] = true;
			waittillframeend;
			if ( !isDefined( bot ) )
			{
				bot = addTestClient();
				bot.pers[ "isBot" ] = true;
				wait 0.5;
			}
		}
		for ( i = min_time; i > 0; i-- )
		{
			wait 1;
		}
		foreach ( player in getPlayers() )
		{
			player kick_bot();
		}
	}
}

spawn_and_kick_bots_periodically( num, min_time )
{
	while ( true )
	{
		for ( ; getPlayers().size < num; i++ )
		{
			bot = addTestClient();
			bot.pers[ "isBot" ] = true;
			waittillframeend;
			if ( !isDefined( bot ) )
			{
				bot = addTestClient();
				bot.pers[ "isBot" ] = true;
				wait 0.5;
			}
		}
		for ( i = min_time; i > 0; i-- )
		{
			wait 1;
		}
		players = getPlayers();
		foreach ( player in players )
		{
			if ( player kick_bot_once() )
			{
				break;
			}
		}
		for ( i = min_time; i > 0; i-- )
		{
			wait 1;
		}
	}
}

spawn_and_kick_bots_randomly( min_bots, max_bots, min_time, max_time )
{
	while ( true )
	{
		bot_num_to_spawn = random_clamped_int( min_bots, max_bots, 1, 8 );
		for ( ; getPlayers().size < bot_num_to_spawn; )
		{
			bot = addTestClient();
			bot.pers[ "isBot" ] = true;
			if ( !isDefined( bot ) )
			{
				bot = addTestClient();
				bot.pers[ "isBot" ] = true;
				wait 0.5;
			}
		}
		wait random_clamped_float( min_time, max_time, 0.05, 30 );
		players = getPlayers();
		foreach ( player in players )
		{
			if ( player kick_bot_once() )
			{
				break;
			}
		}
		wait random_clamped_float( min_time, max_time, 0.05, 30 );
	}
}

spawn_bots_stay( num )
{
	for ( ; getPlayers().size < num; i++ )
	{
		bot = addTestClient();
		bot.pers[ "isBot" ] = true;
		waittillframeend;
		if ( !isDefined( bot ) )
		{
			bot = addTestClient();
			bot.pers[ "isBot" ] = true;
			wait 0.5;
		}
	}
}

bot_round_test()
{
	level endon( "end_game" );
	teams = [];
	teams[ 0 ] = "allies";
	teams[ 1 ] = "axis";
	while ( true )
	{
		level waittill( "timer_start_pre_round" );
		bots = get_bots( random( teams ) );
		if ( bots.size > 0 )
		{
			foreach ( bot in bots )
			{
				bot.ignoreme = true;
			}
		}
	}
}

kick_bot()
{
	if ( is_true( self.pers[ "isBot" ] ) )
	{
		kick( self getEntityNumber() );
	}
}

kick_bot_once()
{
	if ( is_true( self.pers[ "isBot" ] ) )
	{
		kick( self getEntityNumber() );
		return true;
	}
	return false;
}

get_bots( team )
{
	if ( isDefined( team ) && isDefined( level.teams[ team ] ) )
	{
		players = getPlayers( team );
	}
	else 
	{
		players = getPlayers();
	}
	bots = [];
	foreach ( player in players )
	{
		if ( is_true( player.pers[ "isBot" ] ) )
		{
			bots[ bots.size ] = player;
		}
	}
	return bots;
}

count_bots()
{
	players = getPlayers();
	count = 0;
	foreach ( player in players )
	{
		if ( is_true( player.pers[ "isBot" ] ) )
		{
			count++;
		}
	}
	return count;
}

random_clamped_float( mine, max, min_clamp_val, max_clamp_val )
{
	float = randomFloatRange( min, max );
	if ( float < min_clamp_val )
	{
		float = min_clamp_val;
	}
	else if ( float > max_clamp_val )
	{
		float = max_clamp_val;
	}
	return float;
}

random_clamped_int( min, max, min_clamp_val, max_clamp_val )
{
	int = randomIntRange( min, max );
	if ( int < min_clamp_val )
	{
		int = min_clamp_val;
	}
	else if ( int > max_clamp_val )
	{
		int = max_clamp_val;
	}
	return int;
}