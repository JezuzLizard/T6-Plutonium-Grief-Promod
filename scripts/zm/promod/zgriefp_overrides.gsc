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

#include scripts/zm/promod/utility/_grief_util;
#include scripts/zm/promod/zgriefp;
#include scripts/zm/promod/_hud;
#include scripts/zm/promod/utility/_com;

treasure_chest_init_o( start_chest_name ) //checked changed to match cerberus output
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

track_players_intersection_tracker_o() //checked partially changed to match cerberus output //did not change while loop to for loop because continues in for loops go infinite
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
				if ( is_true( players[ j ].is_grief_jumped_on ) )
				{
					obituary_message = create_griefed_obituary_msg( players[ i ], players[ j ], "none", "MOD_IMPACT" );
					players = array( players[ i ], players[ j ] );
					COM_PRINTF( "obituary g_log", "obituary", obituary_message, players );
					players[ i ].is_grief_jumped_on = undefined;
				}
				else if ( is_true( players[ i ].is_grief_jumped_on ) )
				{
					obituary_message = create_griefed_obituary_msg( players[ j ], players[ i ], "none", "MOD_IMPACT" );
					players = array( players[ j ], players[ i ] );
					COM_PRINTF( "obituary g_log", "obituary", obituary_message, players );
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

init_zombie_run_cycle_o() //checked matches cerberus output
{
	self set_zombie_run_cycle();
}

change_zombie_run_cycle_o() //checked matches cerberus output
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

rungametypeprecache_o( gamemode )
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

rungametypemain_o( gamemode, mode_main_func, use_round_logic )
{
	if ( !isDefined( level.gamemode_map_location_main ) || !isDefined( level.gamemode_map_location_main[ gamemode ] ) )
	{
		return;
	}
	level thread game_objects_allowed_o( getDvar( "g_gametype" ), getDvar( "ui_zm_mapstartlocation" ) );
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
		level thread non_round_logic_o( gamemode, mode_main_func );
	}
	level thread game_end_func();
}

non_round_logic_o( gamemode, mode_logic_func )
{
	if ( gamemode == "zgrief" )
	{
		level thread zgrief_main_o();
	}
	else 
	{
		level thread [[ mode_logic_func ]]();
	}
}

game_objects_allowed_o( mode, location )
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

setup_standard_objects_o( location )
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

setup_classic_gametype_o()
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

playleaderdialogonplayer_o( dialog, team, waittime )
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

check_for_match_winner( winner )
{
	if ( level.data_maps[ "encounters_teams" ][ "score" ][ level.teamIndex[ winner ] ] == level.grief_gamerules[ "scorelimit" ] )
	{
		return true;
	}
	if ( grief_team_forfeit() )
	{
		return true;
	}
	return false;
}

match_end( winner )
{
	loser = get_loser( winner );
	mapname = get_map_display_name_from_location( getDvar( "ui_zm_mapstartlocation" ) );
	match_length = to_mins( getGameLength() );
	level.gamemodulewinningteam = level.data_maps[ "encounters_teams" ][ "eteam" ][ level.teamIndex[ winner ] ];
	players = getPlayers();
	winning_team_size = 0;
	losing_team_size = 0;
	for ( i = 0; i < players.size; i++ )
	{
		players[ i ] freezecontrols( 1 );
		if ( players[ i ].team == winner )
		{
			players[ i ] thread maps/mp/zombies/_zm_audio_announcer::leaderdialogonplayer( "grief_won" );
			players[ i ].pers[ "wins" ]++;
			winning_team_size++;
		}
		else 
		{
			players[ i ] thread maps/mp/zombies/_zm_audio_announcer::leaderdialogonplayer( "grief_lost" );
			players[ i ].pers[ "losses" ]++;
			losing_team_size++;
		}
	}
	level._game_module_game_end_check = undefined;
	maps/mp/gametypes_zm/_zm_gametype::track_encounters_win_stats( level.gamemodulewinningteam );
	level notify( "end_game" );
	// logline1 = "GAMEEND;MAP:" + mapname + ";W:" + winner + ";WTS:" + winning_team_size + ";L:" + loser + ";LTS:" + losing_team_size + ";ML:" + match_length + ";D:" + time() + "\n";
	// logprint( logline1 );
}

round_winner( winner )
{
	level.data_maps[ "encounters_teams" ][ "score" ][ level.teamIndex[ winner ] ]++;
	level notify( "grief_point", winner );
	if ( check_for_match_winner( winner ) )
	{
		match_end( winner );
		return;
	}
	flag_clear( "spawn_zombies" );
	level.pause_timer = true;
	flag_set( "timer_pause" );
	level thread all_surviving_players_invulnerable();
	level thread scripts/zm/promod/utility/_grief_util::kill_all_zombies();
	if ( isDefined( level.grief_round_win_next_round_countdown ) && !in_grief_intermission() )
	{
		level thread freeze_players( 1 );
		level thread maps/mp/zombies/_zm_audio::change_zombie_music( "round_end" );
		level thread [[ level.grief_round_win_next_round_countdown ]]();
		wait level.grief_gamerules[ "next_round_time" ];
	}
	else if ( isDefined( level.grief_round_intermission_countdown ) && level.grief_gamerules[ "intermission_time" ] > 0 )
	{
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
		level thread maps/mp/zombies/_zm_audio::change_zombie_music( "round_end" );
		level thread [[ level.grief_round_intermission_countdown ]]();
		wait level.grief_gamerules[ "intermission_time" ];
	}
	flag_clear( "timer_pause" );
	level thread start_new_round( false );
}

check_for_surviving_team()
{
	level endon( "end_game" );
	level.rounds_played = 1;
	// setroundsplayed( level.rounds_played );
	level thread grief_save_loadouts2();
	while ( 1 )
	{
		flag_wait( "spawn_zombies" );
		alive_teams = count_alive_teams();
		if ( alive_teams == 0 )
		{
			start_new_round( true );
		}
		else if ( alive_teams == 1 && isDefined( level.predicted_round_winner ) )
		{
			wait level.grief_gamerules[ "suicide_check" ];
			if ( count_alive_teams() == 0 )
			{
				start_new_round( true );
				continue;
			}
			round_winner( level.predicted_round_winner );
		}
		wait 0.05;
	}
}

count_alive_teams()
{
	level.alive_players = [];
	foreach ( team in level.teams )
	{
		level.alive_players[ team ] = [];
		level.data_maps[ "encounters_teams" ][ "alive" ][ level.teamIndex[ team ] ] = 0;
	}
	players = getPlayers();
	for ( i = 0; i < players.size; i++ )
	{
		if ( level.data_maps[ "encounters_teams" ][ "alive" ][ level.teamIndex[ players[ i ].team ] ] )
		{
			level.alive_players[ players[ i ].team ] = players[ i ];
		}
		else if ( players[ i ]._encounters_team == level.data_maps[ "encounters_teams" ][ "e_team" ][ level.teamIndex[ players[ i ].team ] ] )
		{
			if ( is_player_valid( players[ i ] ) )
			{
				level.alive_players[ players[ i ].team ] = players[ i ];
				level.data_maps[ "encounters_teams" ][ "alive" ][ level.teamIndex[ players[ i ].team ] ] = 1;
			}
		}
	}
	alive_teams = 0;
	level.predicted_round_winner = undefined;
	foreach ( team in level.teams )
	{
		if ( level.data_maps[ "encounters_teams" ][ "alive" ][ level.teamIndex[ team ] ] )
		{
			alive_teams++;
			level.predicted_round_winner = level.data_maps[ "encounters_teams" ][ "team" ][ level.teamIndex[ team ] ];
		}
	}
	return alive_teams;
}

zgrief_main_o()
{
	zgriefp_init();
	flag_wait( "initial_blackscreen_passed" );
	game_start();
	players = getPlayers();
	foreach ( player in players )
	{
		player.is_hotjoin = 0;
	}
	wait 1;
}

game_start()
{
	flag_init( "game_start", 0 );
	flag_init( "timer_pause", 0 );
	flag_init( "first_round", 0 );
	level.pause_timer = false;
	pregame();
	//level thread location_ambiance();
	unfreeze_all_players_controls();
	flag_set( "start_zombie_round_logic" );
	level thread maps/mp/zombies/_zm_audio::change_zombie_music( "round_start" );
	level thread zombie_spawning();
	level thread check_for_surviving_team();
	flag_set( "first_round" );
	start_new_round( false, level.grief_gamerules[ "zombie_round" ] );
	flag_clear( "first_round" );
}

pregame()
{
	flag_clear( "spawn_zombies" );
	level thread game_start_timer();
	scripts/zm/promod/zgriefp::wait_for_players();
	//respawn_players();
	respawn_spectators_and_freeze_players();
	flag_set( "game_start" );
	playsoundatposition( "vox_zmba_grief_intro_0", ( 0, 0, 0 ) );
	wait level.grief_gamerules[ "pregame_time" ];
}

zombie_spawning() //checked changed to match cerberus output
{
	level endon( "end_game" );
	old_spawn = undefined;
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

start_new_round( is_restart, round_number )
{
	level.new_round_started = true;
	if ( isDefined( round_number ) )
	{
		level.zombie_health = level.zombie_vars[ "zombie_health_start" ];
		level.grief_gamerules[ "zombie_round" ] = round_number;
		maps/mp/zombies/_zm::ai_calculate_health( round_number );
	}
	if ( is_true( is_restart ) )
	{
		flag_clear( "spawn_zombies" );
		level thread scripts/zm/promod/utility/_grief_util::kill_all_zombies();
		if ( isDefined( level._grief_reset_message ) )
		{
			level thread [[ level._grief_reset_message ]]();
		}
		zombie_spawn_delay_fix();
		zombie_speed_fix();
	}
	else 
	{
		level.rounds_played++;
		// setroundsplayed( level.rounds_played );
	}
	all_surviving_players_vulnerable();
	level thread reset_players_last_griefed_by();
	if ( !flag( "first_round" ) )
	{
		respawn_players();
	}
	unfreeze_all_players_controls();
	level thread maps/mp/zombies/_zm_audio::change_zombie_music( "round_start" );
	wait level.grief_gamerules[ "round_zombie_spawn_delay" ];
	flag_set( "spawn_zombies" );
	level notify( "grief_new_round" );
	level.new_round_started = false;
}

game_module_init_o() //checked matches cerberus output
{
	level thread game_module_on_player_connect();
}

game_module_on_player_connect() //checked matches cerberus output
{
	level endon( "end_game" );
	for ( ;; )
	{
		level waittill( "connected", player );
		player thread game_module_on_player_spawned();
		if ( isDefined( level.game_module_onplayerconnect ) )
		{
			player [[ level.game_module_onplayerconnect ]]();
		}
	}
}

game_module_on_player_spawned() //checked partially changed to cerberus output
{
	level endon( "end_game" );
	self endon( "disconnect" );
	for ( ;; )
	{
		self waittill_either( "spawned_player", "fake_spawned_player" );
		if ( self maps/mp/zombies/_zm_laststand::player_is_in_laststand() )
		{
			self thread maps/mp/zombies/_zm_laststand::auto_revive( self );
		}
		if ( isDefined( level.custom_player_fake_death_cleanup ) )
		{
			self [[ level.custom_player_fake_death_cleanup ]]();
		}
		self setstance( "stand" );
		self.zmbdialogqueue = [];
		self.zmbdialogactive = 0;
		self.zmbdialoggroups = [];
		self.zmbdialoggroup = "";
		self takeallweapons();
		if ( isDefined( level.givecustomcharacters ) )
		{
			self [[ level.givecustomcharacters ]]();
		}
		self giveweapon( "knife_zm" );
		if ( isDefined( level.onplayerspawned_restore_previous_weapons ) && isDefined( level.isresetting_grief ) && level.isresetting_grief )
		{
			weapons_restored = self [[ level.onplayerspawned_restore_previous_weapons ]]();
		}
		if ( isDefined( weapons_restored ) && !weapons_restored || !isDefined( weapons_restored ) )
		{
			self give_start_weapon( 1 );
		}
		weapons_restored = 0;
		if ( isDefined( level._team_loadout ) )
		{
			self giveweapon( level._team_loadout );
			self switchtoweapon( level._team_loadout );
		}
		if ( isDefined( level.gamemode_post_spawn_logic ) )
		{
			self [[ level.gamemode_post_spawn_logic ]]();
		}
	}
}

update_players_on_bleedout_or_disconnect_o( excluded_player ) //checked changed to match cerberus output
{
	other_team = undefined;
	players = get_players();
	players_remaining = 0;
	while ( i < players.size )
	{
		if ( player == excluded_player )
		{
			i++;
			continue;
		}
		if ( player.team == excluded_player.team )
		{
			if ( is_player_valid( player ) )
			{
				players_remaining++;
			}
			i++;
			continue;
		}
		i++;
	}
	while ( i < players.size )
	{
		if ( player == excluded_player )
		{
			i++;
			continue;
		}
		if ( player.team != excluded_player.team )
		{
			other_team = player.team;
			if ( players_remaining < 1 )
			{
				player thread show_grief_hud_msg( &"ZOMBIE_ZGRIEF_ALL_PLAYERS_DOWN", undefined, undefined, 1 );
				player delay_thread_watch_host_migrate( 2, ::show_grief_hud_msg, &"ZOMBIE_ZGRIEF_SURVIVE", undefined, 30, 1 );
				i++;
				continue;
			}
			player thread show_grief_hud_msg( &"ZOMBIE_ZGRIEF_PLAYER_BLED_OUT", players_remaining );
		}
		i++;
	}
	if ( players_remaining == 1 )
	{
		level thread maps/mp/zombies/_zm_audio_announcer::leaderdialog( "last_player", excluded_player.team );
	}
	if ( !isDefined( other_team ) )
	{
		return;
	}
	if ( players_remaining < 1 )
	{
		level thread maps/mp/zombies/_zm_audio_announcer::leaderdialog( "4_player_down", other_team );
	}
	else
	{
		level thread maps/mp/zombies/_zm_audio_announcer::leaderdialog( players_remaining + "_player_left", other_team );
	}
}

zombie_head_gib_o( attacker, means_of_death ) //checked changed to match cerberus output
{
	self endon( "death" );
	if ( !is_mature() )
	{
		return 0;
	}
	if ( is_true( self.head_gibbed ) )
	{
		return;
	}
	//play_head_gib_sound();
	self.head_gibbed = 1;
	self zombie_eye_glow_stop();
	size = self getattachsize();
	for ( i = 0; i < size; i++ )
	{
		model = self getattachmodelname( i );
		if ( issubstr( model, "head" ) )
		{
			if ( isDefined( self.hatmodel ) )
			{
				self detach( self.hatmodel, "" );
			}
			self detach( model, "" );
			if ( isDefined( self.torsodmg5 ) )
			{
				self attach( self.torsodmg5, "", 1 );
			}
			break;
		}
	}
	temp_array = [];
	temp_array[ 0 ] = level._zombie_gib_piece_index_head;
	if ( !is_true( self.hat_gibbed ) && isDefined( self.gibspawn5 ) && isDefined( self.gibspawntag5 ) )
	{
		temp_array[ 1 ] = level._zombie_gib_piece_index_hat;
	}
	self.hat_gibbed = 1;
	self gib( "normal", temp_array );
	if ( isDefined( level.track_gibs ) )
	{
		level [[ level.track_gibs ]]( self, temp_array );
	}
	self thread damage_over_time( ceil( self.health * 0.2 ), 1, attacker, means_of_death );
}

play_head_gib_sound()
{
	random = randomInt( 2 );
	if ( random == 0 )
	{
		variant = randomInt( 2 );
		playsoundatposition( "zombie_head_0" + variant, self.origin );
	}
	else if ( random == 1 )
	{
		variant = randomInt( 1 );
		playsoundatposition( "head_0" + variant, self.origin );
	}
	else 
	{
		variant = randomInt( 1 );
		playsoundatposition( "helmet_nd_0" + variant, self.origin );
	}
}

location_ambiance()
{
	while ( true )
	{
		play_random_sound_from_group( "ambiance", ( 0, 0, 0 ) );
		wait 30;
	}
}

onplayerconnect_check_for_hotjoin()
{
	map_logic_exists = level flag_exists( "start_zombie_round_logic" );
	map_logic_started = flag( "start_zombie_round_logic" );
	// if ( map_logic_exists && map_logic_started )
	// {
	// 	self thread hide_gump_loading_for_hotjoiners();
	// }
}

hide_gump_loading_for_hotjoiners()
{
	self endon( "disconnect" );
	self.rebuild_barrier_reward = 1;
	self.is_hotjoining = 1;
	self maps/mp/zombies/_zm::spawnspectator();
	self.is_hotjoining = 0;
	self.is_hotjoin = 1;
	if ( is_true( level.intermission ) || is_true( level.host_ended_game ) )
	{
		setclientsysstate( "levelNotify", "zi", self );
		self setclientthirdperson( 0 );
		self resetfov();
		self.health = 100;
		self thread [[ level.custom_intermission ]]();
	}
}

onallplayersready_o()
{
	while ( getPlayers().size == 0 )
	{
		wait 0.1;
	}
	game[ "state" ] = "playing";
	player_count_actual = 0;
	while ( getnumconnectedplayers() < getnumexpectedplayers() || player_count_actual != getnumexpectedplayers() )
	{
		players = getPlayers();
		player_count_actual = 0;
		for ( i = 0; i < players.size; i++ )
		{
			players[ i ] freezecontrols( 1 );
			if ( players[ i ].sessionstate == "playing" )
			{
				player_count_actual++;
			}
		}
		wait 0.1;
	}
	setinitialplayersconnected(); 
	flag_set( "initial_players_connected" );
	while ( !aretexturesloaded() )
	{
		wait 0.05;
	}
	fade_out_intro_screen_zm( 5, 1.5, 1 );
}

randomize_powerups_o() //checked matches cerberus output
{
	level.zombie_powerup_array = array_randomize( level.zombie_powerup_array );
}

get_next_powerup_o() //checked matches cerberus output
{
	powerup = level.zombie_powerup_array[ level.zombie_powerup_index ];
	level.zombie_powerup_index++;
	if ( level.zombie_powerup_index >= level.zombie_powerup_array.size )
	{
		level.zombie_powerup_index = 0;
		randomize_powerups_o();
	}
	return powerup;
}

get_valid_powerup_o() //checked partially matches cerberus output did not change
{
	if ( isDefined( level.zombie_powerup_boss ) )
	{
		i = level.zombie_powerup_boss;
		level.zombie_powerup_boss = undefined;
		return level.zombie_powerup_array[ i ];
	}
	powerup = get_next_powerup_o();
	disable_powerups = strTok( level.grief_restrictions[ "powerups" ], " " );
	while ( 1 )
	{
		for ( i = 0; i < level.data_maps[ "powerups" ][ "default_allowed_powerups" ].size; i++ )
		{
			if ( level.data_maps[ "powerups" ][ "default_allowed_powerups" ][ i ] == powerup )
			{
				if ( level.data_maps[ "powerups" ][ "is_active" ][ i ] == "1" )
				{
					return powerup;
				}
			}
		}
		powerup = get_next_powerup_o();	
	}
}