#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\gametypes_zm\_hud_message;
#include maps\mp\zombies\_zm;
#include maps\mp\gametypes_zm\zmeat;
#include maps\mp\gametypes_zm\zgrief;
#include maps\mp\zombies\_zm_score;
#include maps\mp\gametypes_zm\_zm_gametype;
#include maps\mp\zombies\_zm_laststand;
#include maps\mp\zombies\_zm_perks;
#include maps\mp\gametypes_zm\_globallogic_player;
#include maps\mp\gametypes_zm\_globallogic_spawn;
#include maps\mp\gametypes_zm\_globallogic_ui;
#include maps\mp\zombies\_zm_unitrigger;
#include maps\mp\zombies\_zm_game_module;
#include scripts\zm\promod\utility\_grief_util;
#include scripts\zm\promod\_hud;
#include scripts\zm\promod\_player_spawning;
#include scripts\zm\promod\_teams;
#include scripts\zm\promod\zgriefp_overrides;
#include scripts\zm\promod\_gamerules;
#include scripts\zm\promod\utility\_damagefeedback;

zgriefp_init()
{
	//add_player_death_sounds();
	level thread monitor_players_connecting_status();
	level thread emptyLobbyRestart();
	init_gamerules();
	// level._game_module_player_damage_callback = ::game_module_player_damage_callback;
	// level._game_module_player_damage_grief_callback = ::game_module_player_damage_grief_callback;
	// level.meat_bounce_override = ::meat_bounce_override;
	// level.onspawnplayerunified = scripts/zm/promod/_player_spawning::onspawnplayerunified; 
	level.noroundnumber = 1;
	setDvar( "g_friendlyfireDist", 0 );
	teams_init();
	// level.game_module_onplayerconnect = ::grief_onplayerconnect;
	// level.game_mode_custom_onplayerdisconnect = ::grief_onplayerdisconnect;
	// level.grief_round_win_next_round_countdown = ::round_change_hud;
	// level.grief_round_intermission_countdown = ::intermission_hud;
	// level.grief_loadout_save = ::grief_loadout_save;
	// level.onplayerspawned_restore_previous_weapons = ::grief_laststand_weapons_return;
	// level.custom_spawnplayer = scripts/zm/promod/_player_spawning::grief_spectator_respawn;
	level thread on_player_connect();
	//level thread scripts/zm/promod/_hud::draw_hud();
}

monitor_players_connecting_status()
{
	while ( true )
	{
		level waittill( "connecting", player );
		if ( !flag( "initial_players_connected" ) )
		{
			player thread kick_player_if_dont_spawn_in_time();
		}
	}
}

kick_player_if_dont_spawn_in_time()
{
	self endon( "begin" );
	wait 45;
	kick( self getEntityNumber() );
}

on_player_connect()
{
	level endon( "end_game" );

	while ( true )
	{
		level waittill( "connected", player );
		if ( level.grief_gamerules[ "knife_lunge" ] )
		{
			player setClientDvar( "aim_automelee_range", 120 ); //default
		}else{
			player setClientDvar( "aim_automelee_range", 0 );
		}
		player thread on_player_spawned();
		player thread afk_kick();
		if ( !isDefined( player.last_griefed_by ) )
		{
			player.last_griefed_by = spawnStruct();
			player.last_griefed_by.attacker = undefined;
			player.last_griefed_by.meansofdeath = undefined;
			player.last_griefed_by.weapon = undefined;
		}
		player thread give_points_on_restart_and_round_change();
		player scripts/zm/promod/utility/_grief_util::init_player_session_data();
		player.killsconfirmed = 0;
		player.stabs = 0;
		player.assists = 0;
	}
}

on_player_spawned()
{	
	level endon( "game_ended" );
	self endon( "disconnect" );

	while ( true )
	{	
		self waittill( "spawned_player" );
		self.health = level.grief_gamerules[ "player_health" ];
		self.maxHealth = self.health;
		if ( level.grief_gamerules[ "reduced_pistol_ammo" ] )
		{
			reduce_starting_ammo();
		}
	}
}

team_suicide_check()
{
	flag_set( "checking_team_suicide" );
	wait level.grief_gamerules[ "suicide_check" ];
	flag_clear( "checking_team_suicide" );
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

grief_onplayerconnect() //checked matches cerberus output
{
	self thread move_team_icons();
	self thread zgrief_player_bled_out_msg();
}

move_team_icons() //checked matches cerberus output
{
	self endon( "disconnect" );
	flag_wait( "initial_blackscreen_passed" );
	wait 0.5;
}

// init_gamemodecommonvox( prefix )
// {
// 	createvox( "rules", "rules", prefix );
// 	createvox( "countdown", "intro", prefix );
// 	createvox( "side_switch", "side_switch", prefix );
// 	createvox( "round_win", "win_rd", prefix );
// 	createvox( "round_lose", "lose_rd", prefix );
// 	createvox( "round_tied", "tied_rd", prefix );
// 	createvox( "match_win", "win", prefix );
// 	createvox( "match_lose", "lose", prefix );
// 	createvox( "match_tied", "tied", prefix );
// }

// init_griefvox( prefix )
// {
// 	init_gamemodecommonvox( prefix );
// 	createvox( "1_player_down", "1rivdown", prefix );
// 	createvox( "2_player_down", "2rivdown", prefix );
// 	createvox( "3_player_down", "3rivdown", prefix );
// 	createvox( "4_player_down", "4rivdown", prefix );
// 	createvox( "grief_restarted", "restart", prefix );
// 	createvox( "grief_lost", "lose", prefix );
// 	createvox( "grief_won", "win", prefix );
// 	createvox( "1_player_left", "1rivup", prefix );
// 	createvox( "2_player_left", "2rivup", prefix );
// 	createvox( "3_player_left", "3rivup", prefix );
// 	createvox( "last_player", "solo", prefix );
// }


/*
round ending killcam
final killcam

"mpl_final_kill_cam_sting"
*/

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

onplayerconnect_check_for_hotjoin()
{
	return;
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