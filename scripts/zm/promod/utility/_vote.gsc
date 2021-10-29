#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;
#include scripts/zm/promod/plugin/commands;
#include scripts/zm/promod/utility/_com;
#include scripts/zm/promod/utility/_grief_util;
#include scripts/zm/promod/utility/_text_parser;

VOTE_INIT()
{
	level.vote_timeout = 30;
	level.vote_start_anonymous = getDvarIntDefault( "anonymous_vote_start", 1 );
}

/*private*/ get_vote_threshold()
{
	switch ( level.players.size )
	{
		case 3:
			return 2;
		case 4:
			return 3;
		case 5:
			return 4;
		case 6:
			return 4;
		case 7:
			return 5;
		case 8:
			return 5;
		default:
			return 99;
	}
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
	setup_temporary_command_listener( "listener_vote", level.vote_timeout, self );
	self waittill( "listener_vote", result, args );
	clear_temporary_command_listener( "listener_vote", self );
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
	if ( level.vote_in_progress_votes.size >= get_vote_threshold() )
	{
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
			COM_PRINTF( "con say", "notitle", va( "vote:count: Received %s yeses, and % nos. Action executed.", yes_votes, no_votes ), self );
		}
		else if ( yes_votes < no_votes )
		{
			outcome = false;
			COM_PRINTF( "con say", "notitle", va( "vote:count: Received %s yeses, and % nos. Action not executed.", yes_votes, no_votes ), self );
		}
		else 
		{
			outcome = cointoss();
			outcome_str = cast_bool_to_str( outcome, "yes no" )
			COM_PRINTF( "con say", "notitle", va( "vote:count: Tie. Action decided by cointoss() result %s.", outcome_str ), self );
		}
	}
	else 
	{
		outcome = false;
		COM_PRINTF( "con say", "notitle", "vote:count: Not enough votes to meet threshold for player count.", self );
	}
	level notify( "vote_ended", outcome );
}