#include maps\mp\zombies\_zm_game_module;
#include maps\mp\zombies\_zm_laststand;
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;

#include scripts\zm\promod_grief\_hud;


wait_for_players()
{
	level endon( "end_game" );
	flag_clear( "spawn_zombies" );
	waiting_for_players = false;

	if ( level.grief_ffa )
	{
		players = getPlayers();
		while ( players.size < 2 )
		{
			players = getPlayers();
			for ( i = 0; i < players.size; i++ )
			{
				players[ i ] iPrintLn( "Waiting for 2 players" );
				waiting_for_players = true;
			}
			wait 2;
		}
	}
	else 
	{
		players_axis = getPlayers( "axis" );
		players_allies = getPlayers( "allies" );
		while ( ( players_axis.size < 1 ) || ( players_allies.size < 1 ) )
		{
			players_axis = getPlayers( "axis" );
			players_allies = getPlayers( "allies" );
			players = getPlayers();
			for ( i = 0; i < players.size; i++ )
			{
				players[ i ] iPrintLn( "Waiting for 1 player on each team" );
				waiting_for_players = true;

			}
			wait 2;
		}
	}

	return waiting_for_players;
}

wait_for_team_death_and_round_end_override()
{
	level endon( "game_module_ended" );
	level endon( "end_game" );

	checking_for_round_end = 0;
	checking_for_round_tie = 0;
	level.isresetting_grief = 0;
 
	level.grief_score = [];
	level.grief_score["A"] = 0;
	level.grief_score["B"] = 0;

	if ( wait_for_players() )
		respawn_players();

	if ( !level.grief_ffa )
		scripts/zm/promod_grief/_hud::hud_init();

	round_start_wait();
	flag_set( "grief_begin" );

	while ( 1 )
	{
		cdc_alive = 0;
		cia_alive = 0;
		players = get_players();
		for ( i = 0; i < players.size; i++ )
		{
			if ( !isDefined( players[ i ]._encounters_team ) )
			{
				i++;
				continue;
			}
			if ( players[ i ]._encounters_team == "A" )
			{
				if ( is_player_valid( players[ i ] ) )
				{
					cia_alive++;
				}
				i++;
				continue;
			}
			if ( is_player_valid( players[ i ] ) )
			{
				cdc_alive++;
			}
		}

		if ( !checking_for_round_tie )
		{
			if(cia_alive == 0 && cdc_alive == 0)
			{
				level notify( "stop_round_end_check" );
				level thread check_for_round_end();
				checking_for_round_tie = 1;
				checking_for_round_end = 1;
			}
		}

		if ( !checking_for_round_end )
		{
			if ( cia_alive == 0 )
			{
				level thread check_for_round_end( "B" );
				checking_for_round_end = 1;
			}
			else if ( cdc_alive == 0 )
			{
				level thread check_for_round_end( "A" );
				checking_for_round_end = 1;
			}
		}

		if ( cia_alive > 0 && cdc_alive > 0 )
		{
			level notify( "stop_round_end_check" );
			checking_for_round_end = 0;
			checking_for_round_tie = 0;
		}

		wait 0.05;
	}
}

check_for_round_end(winner)
{
	level endon( "stop_round_end_check" );
	level endon( "end_game" );

	if(isDefined(winner))
	{
		wait level.grief_gamerules[ "suicide_check" ];
	}
	else
	{
		wait 0.5;
	}

	level thread round_end(winner);
}

round_end(winner)
{
	team = undefined;
	if(isDefined(winner))
	{
		if(winner == "A")
		{
			team = "axis";
		}
		else
		{
			team = "allies";
		}
	}

	if(isDefined(winner))
	{
		level.grief_score[winner]++;
		level.server_hudelems[ "grief_score_" + winner ].hudelem SetValue( level.grief_score[ winner ] );
		setteamscore(team, level.grief_score[winner]);

		if(level.grief_score[winner] == level.grief_gamerules[ "scorelimit" ])
		{
			game_won(winner);
			return;
		}
	}

	players = get_players();
	foreach(player in players)
	{
		if(is_player_valid(player))
		{
			// don't give perk
			player notify("perk_abort_drinking");
			// save weapons
			// player [[level._game_module_player_laststand_callback]]();
		}
	}

	level.isresetting_grief = 1;
	level notify( "end_round_think" );
	level.zombie_vars[ "spectators_respawn" ] = 1;
	level notify( "keep_griefing" );
	level notify( "restart_round" );

	if(isDefined(winner))
	{
		foreach(player in players)
		{
			if(player.team == team)
			{
				player thread show_grief_hud_msg( "You won the round" );
			}
			else
			{
				player thread show_grief_hud_msg( "You lost the round" );
			}
		}
	}
	else
	{
		foreach(player in players)
		{
			level thread maps/mp/zombies/_zm_audio_announcer::leaderdialog( "grief_restarted" );
			player thread show_grief_hud_msg( &"ZOMBIE_GRIEF_RESET" );
		}
	}

	zombie_goto_round( level.round_number );
	level thread maps/mp/zombies/_zm_game_module::reset_grief();
	level thread maps/mp/zombies/_zm::round_think( 1 );
}

game_won(winner)
{
	level.gamemodulewinningteam = winner;
	level.zombie_vars[ "spectators_respawn" ] = 0;
	players = get_players();
	i = 0;
	while ( i < players.size )
	{
		players[ i ] freezecontrols( 1 );
		if ( players[ i ]._encounters_team == winner )
		{
			players[ i ] thread maps/mp/zombies/_zm_audio_announcer::leaderdialogonplayer( "grief_won" );
			i++;
			continue;
		}
		players[ i ] thread maps/mp/zombies/_zm_audio_announcer::leaderdialogonplayer( "grief_lost" );
		i++;
	}
	level notify( "game_module_ended", winner );
	level._game_module_game_end_check = undefined;
	maps/mp/gametypes_zm/_zm_gametype::track_encounters_win_stats( level.gamemodulewinningteam );
	level notify( "end_game" );
}

zombie_goto_round(target_round)
{
	level endon( "end_game" );

	if ( target_round < 1 )
	{
		target_round = 1;
	}

	level.zombie_total = 0;
	zombies = get_round_enemy_array();
	if ( isDefined( zombies ) )
	{
		for ( i = 0; i < zombies.size; i++ )
		{
			zombies[ i ] dodamage( zombies[ i ].health + 666, zombies[ i ].origin );
		}
	}

	game["axis_spawnpoints_randomized"] = undefined;
	game["allies_spawnpoints_randomized"] = undefined;
	set_game_var("switchedsides", !get_game_var("switchedsides"));

	respawn_players();

	wait 0.05; // let all players fully respawn

	level thread maps/mp/zombies/_zm::award_grenades_for_survivors();

	level thread round_start_wait();
}

round_start_wait()
{
	level endon("end_game");

	flag_clear("spawn_zombies");
	freeze_all_players_controls();

	round_start_countdown_hud(level.grief_gamerules[ "next_round_time" ]);

	flag_set("spawn_zombies");
	unfreeze_all_players_controls();
}

respawn_players() 
{
	players = get_players();
	foreach ( player in players )
	{
		player [[ level.spawnplayer ]]();
		// player freeze_player_controls( 1 );
	}
}

all_surviving_players_vulnerable()
{
	players = getPlayers();
	foreach ( player in players )
	{
		if ( is_player_valid( player ) )
		{
			player disableInvulnerability();
		}
	}
}

freeze_all_players_controls()
{
	players = getPlayers();
	foreach ( player in players )
	{
		player freezeControls( 1 );
	}
}

unfreeze_all_players_controls()
{
	players = getPlayers();
	foreach ( player in players )
	{
		player freezeControls( 0 );
		player notify( "controls_unfrozen");
	}
}