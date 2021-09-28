#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/zombies/_zm_magicbox;
#include maps/mp/zombies/_zm_laststand;
#include maps/mp/animscripts/zm_utility;
#include maps/mp/animscripts/zm_run;
#include maps/mp/zombies/_zm;

#include maps/mp/zombies/_zm_spawner;
#include maps/mp/zombies/_zm_game_module;
#include maps/mp/zombies/_zm_pers_upgrades_functions;
#include maps/mp/zombies/_zm_blockers;
#include maps/mp/gametypes_zm/_spawning;
#include maps/mp/zombies/_zm_stats;
#include maps/mp/gametypes_zm/_hud;
#include maps/mp/zombies/_zm_audio_announcer;
#include maps/mp/zombies/_zm_audio;
#include maps/mp/gametypes_zm/_globallogic_ui;
#include maps/mp/gametypes_zm/_hud_message;
#include maps/mp/gametypes_zm/_globallogic_score;
#include maps/mp/gametypes_zm/_globallogic_defaults;
#include maps/mp/gametypes_zm/_globallogic_spawn;
#include maps/mp/gametypes_zm/_gameobjects;
#include maps/mp/gametypes_zm/_weapons;
#include maps/mp/gametypes_zm/_callbacksetup;
#include maps/mp/gametypes_zm/_globallogic;
#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_perks;
#include maps/mp/zombies/_zm_zonemgr;

#include maps/mp/gametypes_zm/_zm_gametype;
#include maps/mp/zombies/_zm_game_module;

treasure_chest_init( start_chest_name ) //checked changed to match cerberus output
{
	flag_init( "moving_chest_enabled" );
	flag_init( "moving_chest_now" );
	flag_init( "chest_has_been_used" );
	level.chest_moves = 0;
	level.chest_level = 0;
	if ( level.chests.size == 0 )
	{
		return;
	}
	for ( i = 0; i < level.chests.size; i++ )
	{
		level.chests[ i ].box_hacks = [];
		level.chests[ i ].orig_origin = level.chests[ i ].origin;
		level.chests[ i ] get_chest_pieces();
		if ( isDefined( level.chests[ i ].zombie_cost ) )
		{
			level.chests[ i ].old_cost = level.chests[ i ].zombie_cost;
		}
		else 
		{
			level.chests[ i ].old_cost = 950;
		}
	}
	if ( !level.enable_magic || !level.grief_gamerules[ "mystery_box_enabled" ] )
	{
		foreach( chest in level.chests )
		{
			chest hide_chest();
		}
		return;
	}
	level.chest_accessed = 0;
	if ( level.chests.size > 1 )
	{
		flag_set( "moving_chest_enabled" );
		level.chests = array_randomize( level.chests );
	}
	else
	{
		level.chest_index = 0;
		level.chests[ 0 ].no_fly_away = 1;
	}
	init_starting_chest_location( start_chest_name );
	array_thread( level.chests, ::treasure_chest_think );
}

track_players_intersection_tracker() //checked partially changed to match cerberus output //did not change while loop to for loop because continues in for loops go infinite
{
	self endon( "disconnect" );
	self endon( "death" );
	level endon( "end_game" );
	wait 5;
	while ( 1 )
	{
		killed_players = 0;
		players = getPlayers();
		i = 0;
		while ( i < players.size )
		{
			if ( players[ i ] maps/mp/zombies/_zm_laststand::player_is_in_laststand() || players[ i ].sessionstate != "playing" )
			{
				i++;
				continue;
			}
			j = 0;
			while ( j < players.size )
			{
				if ( j == i || players[ j ] maps/mp/zombies/_zm_laststand::player_is_in_laststand() || players[ j ].sessionstate != "playing" )
				{
					j++;
					continue;
				}
				if ( isDefined( level.player_intersection_tracker_override ) )
				{
					if ( players[ i ] [[ level.player_intersection_tracker_override ]]( players[ j ] ) )
					{
						j++;
						continue;
					}
				}
				playeri_origin = players[ i ].origin;
				playerj_origin = players[ j ].origin;
				if ( abs( playeri_origin[ 2 ] - playerj_origin[ 2 ] ) > 60 )
				{
					j++;
					continue;
				}
				distance_apart = distance2d( playeri_origin, playerj_origin );
				if ( abs( distance_apart ) > 18 )
				{
					j++;
					continue;
				}
				if ( players[ i ] getStance() == "prone" )
				{
					players[ i ].is_grief_jumped_on = true;
				}
				else if ( players[ j ] getStance() == "prone" )
				{
					players[ j ].is_grief_jumped_on = true;
				}
				players[ i ] dodamage( 1000, ( 0, 0, 1 ) );
				players[ j ] dodamage( 1000, ( 0, 0, 1 ) );
				if ( !killed_players )
				{
					players[ i ] playlocalsound( level.zmb_laugh_alias );
				}
				if ( is_true( players[ i ].is_grief_jumped_on ) )
				{
					obituary( players[ j ], players[ i ], "none", "MOD_IMPACT" );
					players[ i ].is_grief_jumped_on = undefined;
				}
				else if ( is_true( players[ j ].is_grief_jumped_on ) )
				{
					obituary( players[ i ], players[ j ], "none", "MOD_IMPACT" );
					players[ j ].is_grief_jumped_on = undefined;
				}
				killed_players = 1;
				j++;
			}
			i++;
		}
		wait 0.5;
	}
}

init_zombie_run_cycle() //checked matches cerberus output
{
	self set_zombie_run_cycle();
}

change_zombie_run_cycle() //checked matches cerberus output
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

rungametypeprecache( gamemode )
{
	if ( !isDefined( level.gamemode_map_location_main ) || !isDefined( level.gamemode_map_location_main[ gamemode ] ) )
	{
		return;
	}
	if ( isDefined( level.gamemode_map_precache ) )
	{
		if ( isDefined( level.gamemode_map_precache[ gamemode ] ) )
		{
			[[ level.gamemode_map_precache[ gamemode ] ]]();
		}
	}
	if ( isDefined( level.gamemode_map_location_precache ) )
	{
		if ( isDefined( level.gamemode_map_location_precache[ gamemode ] ) )
		{
			loc = getDvar( "ui_zm_mapstartlocation" );
			if ( loc == "" && isDefined( level.default_start_location ) )
			{
				loc = level.default_start_location;
			}
			if ( isDefined( level.gamemode_map_location_precache[ gamemode ][ loc ] ) )
			{
				[[ level.gamemode_map_location_precache[ gamemode ][ loc ] ]]();
			}
		}
	}
	if ( isDefined( level.precachecustomcharacters ) )
	{
		self [[ level.precachecustomcharacters ]]();
	}
}

rungametypemain( gamemode, mode_main_func, use_round_logic )
{
	if ( !isDefined( level.gamemode_map_location_main ) || !isDefined( level.gamemode_map_location_main[ gamemode ] ) )
	{
		return;
	}
	level thread game_objects_allowed( getDvar( "g_gametype" ), getDvar( "ui_zm_mapstartlocation" ) );
	if ( isDefined( level.gamemode_map_main ) )
	{
		if ( isDefined( level.gamemode_map_main[ gamemode ] ) )
		{
			level thread [[ level.gamemode_map_main[ gamemode ] ]]();
		}
	}
	if ( isDefined( level.gamemode_map_location_main ) )
	{
		if ( isDefined( level.gamemode_map_location_main[ gamemode ] ) )
		{
			loc = getDvar( "ui_zm_mapstartlocation" );
			if ( loc == "" && isDefined( level.default_start_location ) )
			{
				loc = level.default_start_location;
			}
			if ( isDefined( level.gamemode_map_location_main[ gamemode ][ loc ] ) )
			{
				level thread [[ level.gamemode_map_location_main[ gamemode ][ loc ] ]]();
			}
		}
	}
	if ( isDefined( mode_main_func ) )
	{
		if ( is_true( use_round_logic ) )
		{
			level thread round_logic( mode_main_func );
		}
		else
		{
			level thread non_round_logic( mode_main_func );
		}
	}
	level thread game_end_func();
}

game_objects_allowed( mode, location )
{
	if ( location == "transit" )
	{
		location = "station";
	}
	allowed = [];
	allowed[ 0 ] = mode;
	entities = getentarray();
	i = 0;
	while ( i < entities.size )
	{
		if ( isDefined( entities[ i ].script_gameobjectname ) )
		{
			isallowed = maps/mp/gametypes_zm/_gameobjects::entity_is_allowed( entities[ i ], allowed );
			isvalidlocation = maps/mp/gametypes_zm/_gameobjects::location_is_allowed( entities[ i ], location );
			if ( !isallowed || !isvalidlocation && !is_classic() )
			{
				if ( isDefined( entities[ i ].spawnflags ) && entities[ i ].spawnflags == 1 )
				{
					if ( isDefined( entities[ i ].classname ) && entities[ i ].classname != "trigger_multiple" )
					{
						entities[ i ] connectpaths();
					}
				}
				entities[ i ] delete();
				i++;
				continue;
			}
			if ( isDefined( entities[ i ].script_vector ) )
			{
				entities[ i ] moveto( entities[ i ].origin + entities[ i ].script_vector, 0.05 );
				entities[ i ] waittill( "movedone" );
				if ( isDefined( entities[ i ].spawnflags ) && entities[ i ].spawnflags == 1 )
				{
					entities[ i ] disconnectpaths();
				}
				i++;
				continue;
			}
			if ( isDefined( entities[ i ].spawnflags ) && entities[ i ].spawnflags == 1 )
			{
				if ( isDefined( entities[ i ].classname ) && entities[ i ].classname != "trigger_multiple" )
				{
					entities[ i ] connectpaths();
				}
			}
		}
		i++;
	}
}

setup_standard_objects( location )
{
	structs = getstructarray( "game_mode_object" );
	i = 0;
	while ( i < structs.size )
	{
		if ( isdefined( structs[ i ].script_noteworthy ) && structs[ i ].script_noteworthy != location )
		{
			i++;
			continue;
		}
		if ( isdefined( structs[ i ].script_string ) )
		{
			keep = 0;
			tokens = strtok( structs[ i ].script_string, " " );
			foreach ( token in tokens )
			{
				if ( token == level.scr_zm_ui_gametype && token != "zstandard" )
				{
					keep = 1;
					continue;
				}
				else if ( token == "zstandard" )
				{
					keep = 1;
				}
			}
			if ( !keep )
			{
				i++;
				continue;
			}
		}
		barricade = spawn( "script_model", structs[ i ].origin );
		barricade.angles = structs[ i ].angles;
		barricade setmodel( structs[ i ].script_parameters );
		i++;
	}
	objects = getentarray();
	i = 0;
	while ( i < objects.size )
	{
		if ( !objects[ i ] is_survival_object() )
		{
			i++;
			continue;
		}
		if ( isdefined( objects[ i ].spawnflags ) && objects[ i ].spawnflags == 1 && objects[ i ].classname != "trigger_multiple" )
		{
			objects[ i ] connectpaths();
		}
		objects[ i ] delete();
		i++;
	}
	if ( isdefined( level._classic_setup_func ) )
	{
		[[ level._classic_setup_func ]]();
	}
}

setup_classic_gametype()
{
	ents = getentarray();
	i = 0;
	while ( i < ents.size )
	{
		if ( isDefined( ents[ i ].script_parameters ) )
		{
			parameters = strtok( ents[ i ].script_parameters, " " );
			should_remove = 0;
			foreach ( parm in parameters )
			{
				if ( parm == "survival_remove" )
				{
					should_remove = 1;
				}
			}
			if ( should_remove )
			{
				ents[ i ] delete();
			}
		}
		i++;
	}
	structs = getstructarray( "game_mode_object" );
	i = 0;
	while ( i < structs.size )
	{
		if ( !isdefined( structs[ i ].script_string ) )
		{
			i++;
			continue;
		}
		tokens = strtok( structs[ i ].script_string, " " );
		spawn_object = 0;
		foreach ( parm in tokens )
		{
			if ( parm == "survival" )
			{
				spawn_object = 1;
			}
		}
		if ( !spawn_object )
		{
			i++;
			continue;
		}
		barricade = spawn( "script_model", structs[ i ].origin );
		barricade.angles = structs[ i ].angles;
		barricade setmodel( structs[ i ].script_parameters );
		i++;
	}
	unlink_meat_traversal_nodes();
}

playleaderdialogonplayer( dialog, team, waittime )
{
	self endon( "disconnect" );

	if ( level.allowzmbannouncer )
	{
		if ( !isDefined( game[ "zmbdialog" ][ dialog ] ) )
		{
			return;
		}
	}
	self.zmbdialogactive = 1;
	if ( isDefined( self.zmbdialoggroups[ dialog ] ) )
	{
		group = dialog;
		dialog = self.zmbdialoggroups[ group ];
		self.zmbdialoggroups[ group ] = undefined;
		self.zmbdialoggroup = group;
	}
	if ( level.allowzmbannouncer )
	{
		alias = game[ "zmbdialog" ][ "prefix" ] + "_" + game[ "zmbdialog" ][ dialog ];
		variant = self getleaderdialogvariant( alias );
		if ( !isDefined( variant ) )
		{
			full_alias = alias + "_" + "0";
			if ( level.script == "zm_prison" )
			{
				dialogType = strtok( game[ "zmbdialog" ][ dialog ], "_" );
				switch ( dialogType[ 0 ] )
				{
					case "powerup":
						full_alias = alias;
						break;
					case "grief":
						full_alias = alias + "_" + "0";
						break;
					default:
						full_alias = alias;
				}
			}
		}
		else
		{
			full_alias =  alias + "_" + variant;
		}
		self playlocalsound( full_alias );
	}
	if ( isDefined( waittime ) )
	{
		wait waittime;
	}
	else
	{
		wait 4;
	}
	self.zmbdialogactive = 0;
	self.zmbdialoggroup = "";
	if ( self.zmbdialogqueue.size > 0 && level.allowzmbannouncer )
	{
		nextdialog = self.zmbdialogqueue[0];
		for( i = 1; i < self.zmbdialogqueue.size; i++ )
		{
			self.zmbdialogqueue[ i - 1 ] = self.zmbdialogqueue[ i ];
		}
		self.zmbdialogqueue[ i - 1 ] = undefined;
		self thread playleaderdialogonplayer( nextdialog, team );
	}
}

check_for_round_end( winner )
{
	level endon( "keep_griefing" );
	flag_clear( "grief_brutus_can_spawn" );
	level.zombie_vars[ "spectators_respawn" ] = 0;
	level.grief_team_suicide_check_over = 0;
	team_suicide_check();
	level.grief_team_suicide_check_over = 1;
	level.grief_teams[ winner ].score++;
	level notify( "grief_point", winner );
	loser = get_loser( winner );
	mapname = get_mapname();
	match_length = to_mins( getGameLength() );
	if ( level.grief_teams[ winner ].score == level.grief_gamerules[ "scorelimit" ] || grief_team_forfeits() )
	{
		level.gamemodulewinningteam = winner;
		level.zombie_vars[ "spectators_respawn" ] = 0;
		players = get_players();
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
		logline1 = "GAMEEND;MAP:" + mapname + ";W:" + winner + ";WTS:" + winning_team_size + ";L:" + loser + ";LTS:" + losing_team_size + ";ML:" + match_length + ";D:" + time() + "\n";
		logprint( logline1 );
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

wait_for_team_death_and_round_end()
{
	level endon( "game_module_ended" );
	level endon( "end_game" );
	level endon( "restart_round_check" );
	if ( !isDefined( level.initial_spawn_players ) )
	{
		wait_for_players();
		level.grief_teams = [];
		level.grief_teams[ "B" ] = spawnStruct();
		level.grief_teams[ "B" ].score = 0;
		level.grief_teams[ "B" ].mmr = 0;
		level.grief_teams[ "A" ] = spawnStruct();
		level.grief_teams[ "A" ].score = 0;
		level.grief_teams[ "A" ].mmr = 0;
		level thread grief_save_loadouts2();
	}
	level.checking_for_round_end = 0;
	level.isresetting_grief = 0;
	while ( 1 )
	{
		cdc_alive = 0;
		cia_alive = 0;
		players = get_players();
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
			level.checking_for_round_end = 0;
		}
		wait 0.05;
	}
}