#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_stats;

update_players_stats_at_match_end_override( players )
{
	if ( is_true( level.zm_disable_recording_stats ) )
		return;

	game_mode = getdvar( "ui_gametype" );
	game_mode_group = level.scr_zm_ui_gametype_group;
	map_location_name = level.scr_zm_map_start_location;

	if ( map_location_name == "" )
		map_location_name = "default";

	if ( isdefined( level.gamemodulewinningteam ) && !isPlayer( level.gamemodulewinningteam ) )
	{
		if ( level.gamemodulewinningteam == "B" )
			matchrecorderincrementheaderstat( "winningTeam", 1 );
		else if ( level.gamemodulewinningteam == "A" )
			matchrecorderincrementheaderstat( "winningTeam", 2 );
	}

	recordmatchsummaryzombieendgamedata( game_mode, game_mode_group, map_location_name, level.round_number );
	newtime = gettime();

	for ( i = 0; i < players.size; i++ )
	{
		player = players[i];

		if ( player is_bot() )
			continue;

		distance = player get_stat_distance_traveled();
		player addplayerstatwithgametype( "distance_traveled", distance );
		player add_location_gametype_stat( level.scr_zm_map_start_location, level.scr_zm_ui_gametype, "time_played_total", player.pers["time_played_total"] );
		recordplayermatchend( player );
		recordplayerstats( player, "presentAtEnd", 1 );
		player maps\mp\zombies\_zm_weapons::updateweapontimingszm( newtime );

		if ( isdefined( level._game_module_stat_update_func ) )
			player [[ level._game_module_stat_update_func ]]();

		old_high_score = player get_game_mode_stat( game_mode, "score" );

		if ( player.score_total > old_high_score )
			player set_game_mode_stat( game_mode, "score", player.score_total );

		if ( gamemodeismode( level.gamemode_public_match ) )
		{
			player gamehistoryfinishmatch( 4, 0, 0, 0, 0, 0 );

			if ( isdefined( player.pers["matchesPlayedStatsTracked"] ) )
			{
				gamemode = maps\mp\gametypes_zm\_globallogic::getcurrentgamemode();
				player maps\mp\gametypes_zm\_globallogic::incrementmatchcompletionstat( gamemode, "played", "completed" );

				if ( isdefined( player.pers["matchesHostedStatsTracked"] ) )
				{
					player maps\mp\gametypes_zm\_globallogic::incrementmatchcompletionstat( gamemode, "hosted", "completed" );
					player.pers["matchesHostedStatsTracked"] = undefined;
				}

				player.pers["matchesPlayedStatsTracked"] = undefined;
			}
		}

		if ( !isdefined( player.pers["previous_distance_traveled"] ) )
			player.pers["previous_distance_traveled"] = 0;

		distancethisround = int( player.pers["distance_traveled"] - player.pers["previous_distance_traveled"] );
		player.pers["previous_distance_traveled"] = player.pers["distance_traveled"];
		player incrementplayerstat( "distance_traveled", distancethisround );
		if ( isDefined( player.player_fields ) )
		{
			if ( level.grief_ffa )
			{
				player.player_fields[ "stats" ][ "ffa_matches_completed" ]++;
				if ( player == level.gamemodulewinningteam )
				{
					player.player_fields[ "stats" ][ "ffa_wins" ]++;
					player.player_fields[ "stats" ][ "total_wins" ]++;
				}
				else 
				{
					player.player_fields[ "stats" ][ "ffa_losses" ]++;
					player.player_fields[ "stats" ][ "total_losses" ]++;
				}
			}
			else 
			{
				player.player_fields[ "stats" ][ "revives" ] += player.revives;
				player.player_fields[ "stats" ][ "4v4_matches_completed" ]++;
				if ( player._encounters_team == level.gamemodulewinningteam )
				{
					player.player_fields[ "stats" ][ "4v4_wins" ]++;
					player.player_fields[ "stats" ][ "total_wins" ]++;
				}
				else 
				{
					player.player_fields[ "stats" ][ "4v4_losses" ]++;
					player.player_fields[ "stats" ][ "total_losses" ]++;
				}
			}
			player.player_fields[ "stats" ][ "confirms" ] += player.killsconfirmed;
			player.player_fields[ "stats" ][ "downs" ] += player.downs;
			player.player_fields[ "stats" ][ "stabs" ] += player.stabs;
			player.player_fields[ "stats" ][ "total_matches_completed" ]++;	
			player.player_fields[ "stats" ][ "seconds_played" ] += floor( ( getTime() - player.stats_start_time ) / 1000 ); 
			player [[ level.tcs_add_pers_fs_func_to_queue ]]( "update" );
		}
	}
}

track_encounters_win_stats_override( matchwonteam )
{
    players = getPlayers();
	if ( level.grief_ffa )
	{
		for ( i = 0; i < players.size; i++ )
		{
			if ( players[i] == matchwonteam )
			{
				players[i] maps\mp\zombies\_zm_stats::increment_client_stat( "wins" );
				players[i] maps\mp\zombies\_zm_stats::add_client_stat( "losses", -1 );
				players[i] adddstat( "skill_rating", 1.0 );
				players[i] setdstat( "skill_variance", 1.0 );

				if ( gamemodeismode( level.gamemode_public_match ) )
				{
					players[i] maps\mp\zombies\_zm_stats::add_location_gametype_stat( level.scr_zm_map_start_location, level.scr_zm_ui_gametype, "wins", 1 );
					players[i] maps\mp\zombies\_zm_stats::add_location_gametype_stat( level.scr_zm_map_start_location, level.scr_zm_ui_gametype, "losses", -1 );
				}
			}
			else
			{
				players[i] setdstat( "skill_rating", 0.0 );
				players[i] setdstat( "skill_variance", 1.0 );
			}

			players[i] updatestatratio( "wlratio", "wins", "losses" );
		}
	}
	else 
	{
		for ( i = 0; i < players.size; i++ )
		{
			if ( players[i]._encounters_team == matchwonteam )
			{
				players[i] maps\mp\zombies\_zm_stats::increment_client_stat( "wins" );
				players[i] maps\mp\zombies\_zm_stats::add_client_stat( "losses", -1 );
				players[i] adddstat( "skill_rating", 1.0 );
				players[i] setdstat( "skill_variance", 1.0 );

				if ( gamemodeismode( level.gamemode_public_match ) )
				{
					players[i] maps\mp\zombies\_zm_stats::add_location_gametype_stat( level.scr_zm_map_start_location, level.scr_zm_ui_gametype, "wins", 1 );
					players[i] maps\mp\zombies\_zm_stats::add_location_gametype_stat( level.scr_zm_map_start_location, level.scr_zm_ui_gametype, "losses", -1 );
				}
			}
			else
			{
				players[i] setdstat( "skill_rating", 0.0 );
				players[i] setdstat( "skill_variance", 1.0 );
			}

			players[i] updatestatratio( "wlratio", "wins", "losses" );
		}
	}
}