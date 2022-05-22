#include maps\mp\zombies\_zm_game_module;
#include maps\mp\zombies\_zm_laststand;
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;

#include scripts\zm\promod_grief\_hud;

wait_for_team_death_and_round_end_override()
{
	if ( level.grief_ffa ) 
	{
		level thread round_system_ffa();
		return;
	}

	level endon( "game_module_ended" );
	level endon( "end_game" );

	checking_for_round_end = 0;
	checking_for_round_tie = 0;
	level.isresetting_grief = 0;
 
	level.grief_score = [];
	level.grief_score["A"] = 0;
	level.grief_score["B"] = 0;

	waiting_for_players();

	if ( level.grief_gamerules[ "auto_balance_teams" ].current )
	{
		scripts\zm\promod_grief\_teams::auto_balance_teams();
	}

	scripts\zm\promod_grief\_hud::hud_init();

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

waiting_for_players()
{
	level endon( "end_game" );
	flag_clear( "spawn_zombies" );
	if ( level.grief_ffa )
	{
		while ( level.players.size < 2 )
		{
			for ( i = 0; i < level.players.size; i++ )
			{
				level.players[ i ] iPrintLn( "Waiting for 2 players" );
			}
			wait 2;
		}
	}
	else 
	{
		allies_players = getPlayers( "allies" );
		axis_players = getPlayers( "axis" );
		while ( ( allies_players.size < 1 ) || ( axis_players.size < 1 ) )
		{
			allies_players = getPlayers( "allies" );
			axis_players = getPlayers( "axis" );
			for ( i = 0; i < level.players.size; i++ )
			{
				level.players[ i ] iPrintLn( "Waiting for 1 player on each team" );
			}
			wait 2;
		}
	}
	level.zombie_vars[ "spectators_respawn" ] = 0;
}

round_system_ffa()
{
	level endon( "game_module_ended" );
	level endon( "end_game" );

	checking_for_round_end = 0;
	checking_for_round_tie = 0;
	level.isresetting_grief = 0;

	waiting_for_players();

	HUDELEM_SERVER_ADD( "grief_countdown_timer", ::grief_countdown );

	round_start_wait();
	flag_set( "grief_begin" );

	while ( 1 )
	{
		players_alive = 0;
		players = getPlayers();
		for ( i = 0; i < players.size; i++ )
		{
			if ( is_player_valid( players[ i ] ) )
			{
				alive_player = players[ i ];
				players_alive++;
			}
		}

		if ( !checking_for_round_tie )
		{
			if( players_alive == 0 )
			{
				level notify( "stop_round_end_check" );
				level thread check_for_round_end();
				checking_for_round_tie = 1;
				checking_for_round_end = 1;
			}
		}

		if ( !checking_for_round_end )
		{
			if ( players_alive == 1 )
			{
				level thread check_for_round_end( alive_player );
				checking_for_round_end = 1;
			}
		}

		if ( players_alive > 1 )
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
		wait level.grief_gamerules[ "suicide_check_time" ].current;
	}
	else
	{
		wait 0.5;
	}

	level thread round_end(winner);
}

round_end(winner)
{
	if(level.grief_ffa)
	{
		if(isDefined(winner))
		{
			winner.survived++;
			if ( winner.survived >= level.grief_gamerules[ "scorelimit" ].current )
			{
				game_won(winner);
				return;
			}
		}
	}
	else
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

			if(level.grief_score[winner] >= level.grief_gamerules[ "scorelimit" ].current)
			{
				game_won(winner);
				return;
			}
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
			player [[level._game_module_player_laststand_callback]]();
		}
	}

	level.isresetting_grief = 1;
	level notify( "end_round_think" );
	level.zombie_vars[ "spectators_respawn" ] = 1;
	level notify( "keep_griefing" );
	level notify( "restart_round" );

	if(isDefined(winner))
	{
		if(level.grief_ffa)
		{
			foreach(player in players)
			{
				if(player.name == winner.name)
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
	}
	else
	{
		foreach(player in players)
		{
			level thread maps\mp\zombies\_zm_audio_announcer::leaderdialog( "grief_restarted" );
			player thread show_grief_hud_msg( &"ZOMBIE_GRIEF_RESET" );
		}
	}

	zombie_goto_round( level.round_number );
	level thread maps\mp\zombies\_zm_game_module::reset_grief();
	level thread maps\mp\zombies\_zm::round_think( 1 );
	level.zombie_vars[ "spectators_respawn" ] = 0;
}

game_won(winner)
{
	level.grief_ffa_winner = winner.name;
	level.gamemodulewinningteam = winner;
	level.zombie_vars[ "spectators_respawn" ] = 0;
	if(!level.grief_ffa)
	{
		players = get_players();
		i = 0;
		while ( i < players.size )
		{
			players[ i ] freezecontrols( 1 );
			if ( players[ i ]._encounters_team == winner )
			{
				players[ i ] thread maps\mp\zombies\_zm_audio_announcer::leaderdialogonplayer( "grief_won" );
				i++;
				continue;
			}
			players[ i ] thread maps\mp\zombies\_zm_audio_announcer::leaderdialogonplayer( "grief_lost" );
			i++;
		}
		maps\mp\gametypes_zm\_zm_gametype::track_encounters_win_stats( level.gamemodulewinningteam );
	}
	level._game_module_game_end_check = undefined;
	level notify( "game_module_ended", winner );
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

	respawn_players();

	wait 0.05; // let all players fully respawn

	level thread maps\mp\zombies\_zm::award_grenades_for_survivors();
	level thread scripts\zm\promod_grief\_gamerules::gamerule_give_take_upgraded_melee();

	level thread round_start_wait();
}

round_start_wait()
{
	level endon("end_game");

	flag_clear("spawn_zombies");
	freeze_all_players_controls();

	round_start_countdown_hud(level.grief_gamerules[ "next_round_time" ].current);
	unfreeze_all_players_controls();

	wait level.grief_gamerules[ "spawn_zombies_wait_time" ].current;
	flag_set("spawn_zombies");
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

custom_end_screen_override()
{
	players = get_players();
	i = 0;
	while ( i < players.size )
	{
		players[ i ].game_over_hud = newclienthudelem( players[ i ] );
		players[ i ].game_over_hud.alignx = "center";
		players[ i ].game_over_hud.aligny = "middle";
		players[ i ].game_over_hud.horzalign = "center";
		players[ i ].game_over_hud.vertalign = "middle";
		players[ i ].game_over_hud.y -= 130;
		players[ i ].game_over_hud.foreground = 1;
		players[ i ].game_over_hud.fontscale = 3;
		players[ i ].game_over_hud.alpha = 0;
		players[ i ].game_over_hud.color = ( 1, 1, 1 );
		players[ i ].game_over_hud.hidewheninmenu = 1;
		players[ i ].game_over_hud settext( &"ZOMBIE_GAME_OVER" );
		players[ i ].game_over_hud fadeovertime( 1 );
		players[ i ].game_over_hud.alpha = 1;
		if ( players[ i ] issplitscreen() )
		{
			players[ i ].game_over_hud.fontscale = 2;
			players[ i ].game_over_hud.y += 40;
		}
		players[ i ].survived_hud = newclienthudelem( players[ i ] );
		players[ i ].survived_hud.alignx = "center";
		players[ i ].survived_hud.aligny = "middle";
		players[ i ].survived_hud.horzalign = "center";
		players[ i ].survived_hud.vertalign = "middle";
		players[ i ].survived_hud.y -= 100;
		players[ i ].survived_hud.foreground = 1;
		players[ i ].survived_hud.fontscale = 2;
		players[ i ].survived_hud.alpha = 0;
		players[ i ].survived_hud.color = ( 1, 1, 1 );
		players[ i ].survived_hud.hidewheninmenu = 1;
		if ( players[ i ] issplitscreen() )
		{
			players[ i ].survived_hud.fontscale = 1.5;
			players[ i ].survived_hud.y += 40;
		}

		if ( isDefined( level.host_ended_game ) && level.host_ended_game )
		{
			players[ i ].survived_hud settext( &"MP_HOST_ENDED_GAME" );
		}
		else if(level.grief_ffa)
		{
			players[ i ].survived_hud settext( level.grief_ffa_winner + " WINS!" );
		}
		else
		{
			if ( isDefined( level.gamemodulewinningteam ) && players[ i ]._encounters_team == level.gamemodulewinningteam )
			{
				players[ i ].survived_hud settext( "YOU WIN!" );
			}
			else
			{
				players[ i ].survived_hud settext( "YOU LOSE!" );
			}
		}
		players[ i ].survived_hud fadeovertime( 1 );
		players[ i ].survived_hud.alpha = 1;
		i++;
	}
}
