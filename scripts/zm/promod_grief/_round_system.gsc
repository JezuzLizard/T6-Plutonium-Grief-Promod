#include maps\mp\zombies\_zm_game_module;
#include maps\mp\zombies\_zm_laststand;
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;

wait_for_players()
{
	level endon( "end_game" );
	flag_init( "grief_begin" );
	flag_clear( "spawn_zombies" );
	level.initial_spawn_players = true;

	if ( level.grief_ffa )
	{
		players = getPlayers();
		while ( players.size < 2 )
		{
			players = getPlayers();
			for ( i = 0; i < players.size; i++ )
			{
				players[ i ] iPrintLn( "Waiting for 2 players" );
			}
			wait 1;
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
			}
			wait 1;
		}
	}
	flag_set( "grief_begin" );
	flag_set( "spawn_zombies" );
	respawn_players();
	level.initial_spawn_players = false;
	if ( !level.grief_ffa )
	{
		scripts/zm/promod_grief/_hud::hud_init();
	}
}

team_suicide_check()
{
	wait level.grief_gamerules[ "suicide_check" ];
}

wait_for_team_death_and_round_end_override()
{
	if ( level.grief_ffa ) 
	{
		level thread round_system_ffa();
		return;
	}
	level endon( "game_module_ended" );
	level endon( "end_game" );
	level endon( "restart_round_check" );
	if ( !isDefined( level.initial_spawn_players ) )
	{
		wait_for_players();
		level.grief_teams = [];
		level.grief_teams[ "B" ] = spawnStruct();
		level.grief_teams[ "B" ].score = 0;
		level.grief_teams[ "A" ] = spawnStruct();
		level.grief_teams[ "A" ].score = 0;
		level thread grief_save_loadouts2();
	}
	level.checking_for_round_end = 0;
	level.isresetting_grief = 0;
	while ( 1 )
	{
		cdc_alive = 0;
		cia_alive = 0;
		players = getPlayers();
		i = 0;
		while ( i < players.size )
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
			i++;
		}
		if ( cia_alive == 0 && cdc_alive == 0 && !level.isresetting_grief && !is_true( level.host_ended_game ) )
		{
			wait 0.5;
			if ( is_true( level.grief_team_suicide_check_over ) )
			{
				continue;
			}
			if ( isDefined( level._grief_reset_message ) )
			{
				level thread [[ level._grief_reset_message ]]();
			}
			level.isresetting_grief = 1;
			level notify( "end_round_think" );
			level.zombie_vars[ "spectators_respawn" ] = 1;
			level notify( "keep_griefing" );
			level.checking_for_round_end = 0;
			zombie_goto_round( level.round_number );
			level thread reset_grief();
			level thread maps/mp/zombies/_zm::round_think( 1 );
			level notify( "grief_give_points" );
		}
		else if ( !level.checking_for_round_end )
		{
			if ( cia_alive == 0 )
			{
				level thread check_for_round_end( "B" );
				level.checking_for_round_end = 1;
			}
			else if ( cdc_alive == 0 )
			{
				level thread check_for_round_end( "A" );
				level.checking_for_round_end = 1;
			}
		}
		if ( cia_alive > 0 && cdc_alive > 0 )
		{
			//level notify( "stop_round_end_check" );
			level.checking_for_round_end = 0;
		}
		wait 0.05;
	}
}

round_system_ffa()
{
	level endon( "game_module_ended" );
	level endon( "end_game" );
	level endon( "restart_round_check" );
	if ( !isDefined( level.initial_spawn_players ) )
	{
		wait_for_players();
		level thread grief_save_loadouts2();
	}
	level.checking_for_round_end = 0;
	level.isresetting_grief = 0;
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
		if ( players_alive == 0 && !level.isresetting_grief && !is_true( level.host_ended_game ) )
		{
			wait 0.5;
			if ( is_true( level.grief_team_suicide_check_over ) )
			{
				continue;
			}
			if ( isDefined( level._grief_reset_message ) )
			{
				level thread [[ level._grief_reset_message ]]();
			}
			level.isresetting_grief = 1;
			level notify( "end_round_think" );
			level.zombie_vars[ "spectators_respawn" ] = 1;
			level notify( "keep_griefing" );
			level.checking_for_round_end = 0;
			zombie_goto_round( level.round_number );
			level thread reset_grief();
			level thread maps/mp/zombies/_zm::round_think( 1 );
			level notify( "grief_give_points" );
		}
		else if ( !level.checking_for_round_end )
		{
			if ( players_alive == 1 )
			{
				level thread check_for_round_end_ffa( alive_player );
				level.checking_for_round_end = 1;
			}
		}
		if ( players_alive > 1 )
		{
			//level notify( "stop_round_end_check" );
			level.checking_for_round_end = 0;
		}
		wait 0.05;
	}
}

check_for_round_end_ffa( winner )
{
	level endon( "keep_griefing" );
	flag_clear( "grief_brutus_can_spawn" );
	level.zombie_vars[ "spectators_respawn" ] = 0;
	level.grief_team_suicide_check_over = 0;
	team_suicide_check();
	level.grief_team_suicide_check_over = 1;
	winner.survived++;
	if ( winner.survived == level.grief_gamerules[ "scorelimit" ] || grief_team_forfeits() )
	{
		level.gamemodulewinningteam = winner;
		level.zombie_vars[ "spectators_respawn" ] = 0;
		players = getPlayers();
		i = 0;
		winning_team_size = 0;
		losing_team_size = 0;
		while ( i < players.size )
		{
			players[ i ] freezecontrols( 1 );
			if ( players[ i ] == winner )
			{
				players[ i ] thread maps/mp/zombies/_zm_audio_announcer::leaderdialogonplayer( "grief_won" );
				players[ i ].pers[ "wins" ]++;
				winning_team_size++;
				i++;
				continue;
			}
			players[ i ] thread maps/mp/zombies/_zm_audio_announcer::leaderdialogonplayer( "grief_lost" );
			players[ i ].pers[ "losses" ]++;
			losing_team_size++;
			i++;
		}
		level notify( "game_module_ended", winner );
		level._game_module_game_end_check = undefined;
		maps/mp/gametypes_zm/_zm_gametype::track_encounters_win_stats( level.gamemodulewinningteam );
		level notify( "end_game" );
		return;
	}
	flag_clear( "spawn_zombies" );
	level thread kill_all_zombies();
	if ( isDefined( level.grief_round_win_next_round_countdown ) && !in_grief_intermission() )
	{
		level thread freeze_players( 1 );
		level thread [[ level.grief_round_win_next_round_countdown ]]();
		level thread all_surviving_players_invulnerable();
		wait level.grief_gamerules[ "next_round_time" ];
	}
	else if ( isDefined( level.grief_round_intermission_countdown ) && level.grief_gamerules[ "intermission_time" ] > 0 )
	{
		level.isresetting_grief = true;
		level.grief_intermission_done = false;
		players = getPlayers();
		foreach ( player in players )
		{
			if ( player player_is_in_laststand() )
			{
				player auto_revive( player );
			}
			else if ( player.sessionstate == "spectator" )
			{	
				player [[ level.spawnplayer ]]();
			}
		}
		level thread all_surviving_players_invulnerable();
		level.isresetting_grief = false;
		level thread [[ level.grief_round_intermission_countdown ]]();
		wait level.grief_gamerules[ "intermission_time" ];
	}
	level thread reset_players_last_griefed_by();
	flag_set( "spawn_zombies" );
	all_surviving_players_vulnerable();
	level.isresetting_grief = 1;
	level notify( "end_round_think" );
	level.zombie_vars[ "spectators_respawn" ] = 1;
	level.checking_for_round_end = 0;
	zombie_goto_round( level.round_number );
	level thread reset_grief();
	level thread maps/mp/zombies/_zm::round_think( 1 );
	level.checking_for_round_end = 0;
	level notify( "grief_give_points" );
	flag_set( "grief_brutus_can_spawn" );
	level.grief_team_suicide_check_over = 1;
}

grief_save_loadouts2()
{
	level endon( "end_game" );
	if ( isDefined( level.grief_loadout_save ) )
	{
		while ( true )
		{
			players = getPlayers();
			foreach ( player in players )
			{
				if ( is_player_valid( player ) )
				{
					player [[ level.grief_loadout_save ]]();
				}
			}
			wait 1;
		}
	}
}

reset_grief() //checked matches cerberus output
{
	wait 1;
	level.isresetting_grief = 0;
}

grief_team_forfeits()
{
	if ( getDvarInt( "grief_testing" ) == 1 )
	{
		return false;
	}
	if ( level.grief_ffa )
	{
		if ( getPlayers().size < 2 )
		{
			return true;
		}
	}
	else if ( ( getPlayers( "axis" ).size == 0 ) || ( getPlayers( "allies" ).size == 0 ) )
	{
		return true;
	}
	return false;
}

check_for_round_end( winner )
{
	level endon( "keep_griefing" );
	flag_clear( "grief_brutus_can_spawn" );
	//level endon( "stop_round_end_check" );
	//level waittill( "end_of_round" );
	level.zombie_vars[ "spectators_respawn" ] = 0;
	level.grief_team_suicide_check_over = 0;
	team_suicide_check();
	level.grief_team_suicide_check_over = 1;
	level.grief_teams[ winner ].score++;
	level.server_hudelems[ "grief_score_" + winner ].hudelem SetValue( level.grief_teams[ winner ].score );
	if ( level.grief_teams[ winner ].score == level.grief_gamerules[ "scorelimit" ] || grief_team_forfeits() )
	{
		level.gamemodulewinningteam = winner;
		level.zombie_vars[ "spectators_respawn" ] = 0;
		players = getPlayers();
		i = 0;
		winning_team_size = 0;
		losing_team_size = 0;
		while ( i < players.size )
		{
			players[ i ] freezecontrols( 1 );
			if ( players[ i ]._encounters_team == winner )
			{
				players[ i ] thread maps/mp/zombies/_zm_audio_announcer::leaderdialogonplayer( "grief_won" );
				players[ i ].pers[ "wins" ]++;
				winning_team_size++;
				i++;
				continue;
			}
			players[ i ] thread maps/mp/zombies/_zm_audio_announcer::leaderdialogonplayer( "grief_lost" );
			players[ i ].pers[ "losses" ]++;
			losing_team_size++;
			i++;
		}
		level notify( "game_module_ended", winner );
		level._game_module_game_end_check = undefined;
		maps/mp/gametypes_zm/_zm_gametype::track_encounters_win_stats( level.gamemodulewinningteam );
		level notify( "end_game" );
		return;
	}
	flag_clear( "spawn_zombies" );
	level thread kill_all_zombies();
	if ( isDefined( level.grief_round_win_next_round_countdown ) && !in_grief_intermission() )
	{
		level thread freeze_players( 1 );
		level thread [[ level.grief_round_win_next_round_countdown ]]();
		level thread all_surviving_players_invulnerable();
		wait level.grief_gamerules[ "next_round_time" ];
	}
	else if ( isDefined( level.grief_round_intermission_countdown ) && level.grief_gamerules[ "intermission_time" ] > 0 )
	{
		level.isresetting_grief = true;
		level.grief_intermission_done = false;
		players = getPlayers();
		foreach ( player in players )
		{
			if ( player player_is_in_laststand() )
			{
				player auto_revive( player );
			}
			else if ( player.sessionstate == "spectator" )
			{	
				player [[ level.spawnplayer ]]();
			}
		}
		level thread all_surviving_players_invulnerable();
		level.isresetting_grief = false;
		level thread [[ level.grief_round_intermission_countdown ]]();
		wait level.grief_gamerules[ "intermission_time" ];
	}
	level thread reset_players_last_griefed_by();
	flag_set( "spawn_zombies" );
	all_surviving_players_vulnerable();
	level.isresetting_grief = 1;
	level notify( "end_round_think" );
	level.zombie_vars[ "spectators_respawn" ] = 1;
	level.checking_for_round_end = 0;
	zombie_goto_round( level.round_number );
	level thread reset_grief();
	level thread maps/mp/zombies/_zm::round_think( 1 );
	level.checking_for_round_end = 0;
	level notify( "grief_give_points" );
	flag_set( "grief_brutus_can_spawn" );
	level.grief_team_suicide_check_over = 1;
}

reset_players_last_griefed_by()
{
	players = getPlayers();
	foreach ( player in players )
	{
		player.last_griefed_by.attacker = undefined;
		player.last_griefed_by.meansofdeath = undefined;
		player.last_griefed_by.weapon = undefined;
	}
}

in_grief_intermission()
{
	if ( is_true( level.grief_intermission_done ) || level.grief_gamerules[ "intermission_time" ] < 1 )
	{
		return false;
	}
	team_scores = [];
	team_scores[ "A" ] = level.grief_teams[ "A" ].score;
	team_scores[ "B" ] = level.grief_teams[ "B" ].score;
	score_limit = level.grief_gamerules[ "scorelimit" ];
	intermission_score = score_limit / 2;
	if ( team_scores[ "A" ] == int( intermission_score ) || team_scores[ "B" ] == int( intermission_score ) )
	{
		level.grief_intermission_done = true;
		return true;
	}
	return false;
}

all_surviving_players_invulnerable()
{
	players = getPlayers();
	foreach ( player in players )
	{
		if ( is_player_valid( player ) )
		{
			player enableInvulnerability();
		}
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

respawn_players()
{
	players = get_players();

	foreach ( player in players )
	{
		player [[ level.spawnplayer ]]();
		player freeze_player_controls( 1 );
	}
}

zombie_goto_round( target_round )
{
	level notify( "restart_round" );

	if ( target_round < 1 )
		target_round = 1;

	level.zombie_total = 0;
	maps\mp\zombies\_zm::ai_calculate_health( target_round );
	zombies = get_round_enemy_array();

	if ( isdefined( zombies ) )
	{
		for ( i = 0; i < zombies.size; i++ )
			zombies[i] dodamage( zombies[i].health + 666, zombies[i].origin );
	}

	respawn_players();
	wait 1;
}