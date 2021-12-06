#include common_scripts/utility;
#include maps/mp/_utility;
#include scripts/cmd_system_modules/_cmd_util;
#include scripts/cmd_system_modules/_com;
#include scripts/cmd_system_modules/_listener;

get_vote_threshold()
{
	num_players = level.players.size;
	if ( num_players < 3 )
	{
		 return 99;
	}
	return ceil( num_players / 2 ) + 1;
}

vote_timeout_countdown()
{
	level.vote_in_progress_timeleft = level.vote_timeout;
	for ( ; level.vote_in_progress_timeleft > 0; level.vote_in_progress_timeleft-- )
	{
		wait 1;
	}
}

player_track_vote()
{
	self setup_command_listener( "listener_vote" );
	result = self wait_command_listener( "listener_vote" );
	self clear_command_listener( "listener_vote" );
	if ( result == "timeout" )
	{
		return;
	}
	level.vote_in_progress_votes[ level.vote_in_progress_votes.size ] = result;
}

count_votes()
{
	while ( true )
	{
		if ( level.vote_in_progress_votes.size == level.players.size || level.vote_in_progress_timeleft == 0 )
		{
			break;
		}
		wait 0.05;
	}
	yes_votes = 0;
	no_votes = 0;
	for ( i = 0; i < level.vote_in_progress_votes.size; i++ )
	{
		if ( level.vote_in_progress_votes[ i ] == "yes" )
		{
			yes_votes++;
		}
		else if ( level.vote_in_progress_votes[ i ] == "no" )
		{
			no_votes++;
		}
	}
	if ( yes_votes > no_votes )
	{
		outcome = true;
		level COM_PRINTF( "con|say|", "notitle", va( "vote:count: Received %s yeses, and % nos. Action executed.", yes_votes, no_votes ), self );
	}
	else if ( yes_votes < no_votes )
	{
		outcome = false;
		level COM_PRINTF( "con|say|", "notitle", va( "vote:count: Received %s yeses, and % nos. Action not executed.", yes_votes, no_votes ), self );
	}
	else 
	{
		outcome = cointoss();
		outcome_str = cast_bool_to_str( outcome, "yes no" );
		level COM_PRINTF( "con|say|", "notitle", va( "vote:count: Tie. Action decided by cointoss() result %s.", outcome_str ), self );
	}
	level notify( "vote_ended", outcome );
}