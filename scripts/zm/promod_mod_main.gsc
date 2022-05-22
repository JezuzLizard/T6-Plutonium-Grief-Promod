#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_zonemgr;

#include scripts\zm\promod_grief\_hud;
#include scripts\zm\promod_grief\_round_system;
#include scripts\zm\promod_grief\_gamerules;
#include scripts\zm\promod_grief\_player;
#include scripts\zm\promod_grief\_damage;
#include scripts\zm\promod_grief\_player_spawn;
#include scripts\zm\promod_grief\_scoreboard;
#include scripts\zm\promod_grief\_weapons;
#include scripts\zm\promod_grief\_zombies;
#include scripts\zm\promod_grief\_teams;
#include scripts\zm\promod_grief\_stats;

main()
{
	level.grief_meat_stink_player = getFunction( "maps\mp\gametypes_zm\zgrief", "meat_stink_player" );
	level.grief_meat_stink_on_ground = getFunction( "maps\mp\gametypes_zm\zgrief", "meat_stink_on_ground" );
	replaceFunc( maps\mp\zombies\_zm_magicbox::treasure_chest_init, scripts\zm\promod_grief\_weapons::treasure_chest_init_override );
	replaceFunc( maps\mp\zombies\_zm_game_module::wait_for_team_death_and_round_end, scripts\zm\promod_grief\_round_system::wait_for_team_death_and_round_end_override );
	replaceFunc( maps\mp\zombies\_zm::getfreespawnpoint, scripts\zm\promod_grief\_player_spawn::getfreespawnpoint_override );
	replacefunc( maps\mp\gametypes_zm\_zm_gametype::hide_gump_loading_for_hotjoiners, scripts\zm\promod_grief\_player_spawn::hide_gump_loading_for_hotjoiners_override );
	replaceFunc( maps\mp\zombies\_zm_stats::update_players_stats_at_match_end, scripts\zm\promod_grief\_stats::update_players_stats_at_match_end_override );
	replaceFunc( maps\mp\gametypes_zm\_zm_gametype::track_encounters_win_stats, scripts\zm\promod_grief\_stats::track_encounters_win_stats_override );
	replaceFunc( maps\mp\zombies\_zm_weapons::show_all_weapon_buys, scripts\zm\promod_grief\_weapons::show_all_weapon_buys_override );
	replaceFunc( maps\mp\zombies\_zm_utility::init_zombie_run_cycle, scripts\zm\promod_grief\_zombies::init_zombie_run_cycle_override );
	replaceFunc( maps\mp\zombies\_zm_zonemgr::manage_zones, scripts\zm\_gametype_setup::manage_zones_override );
	replaceFunc( maps\mp\zombies\_zm_weapons::weapon_give, scripts\zm\promod_grief\_weapons::weapon_give );
	replaceFunc( maps\mp\gametypes_zm\_zm_gametype::menu_onmenuresponse, scripts\zm\promod_grief\_teams::menu_onmenuresponse_override );
	init_gamerules();
	precache();
}

init()
{
	level.allow_teamchange = getGametypeSetting( "allowInGameTeamChange" ) + "";
	if ( level.grief_ffa ) 
	{
		level.allow_teamchange = "0";
	}
	level.game_mode_spawn_player_logic = scripts\zm\promod_grief\_player_spawn::game_mode_spawn_player_logic_override;
	level.round_spawn_func = ::round_spawning_override;
	level.round_think_func = ::round_think_override;
	level._game_module_player_damage_callback = ::game_module_player_damage_callback;
	level._game_module_player_damage_grief_callback = ::game_module_player_damage_grief_callback;
	maps\mp\zombies\_zm::register_player_damage_callback( ::player_damage );
	level.callbackplayerdamage = ::callback_playerdamage;
	level.callbackplayermelee = ::callback_playermelee_override;
	level.meat_bounce_override = ::meat_bounce_override;
	level.grief_loadout_save = ::grief_loadout_save;
	level.custom_end_screen = ::custom_end_screen_override;
	level.autoassign = ::menuautoassign_override;
	level.check_for_valid_spawn_near_team_callback = undefined;
	//level.allow_teamchange = ( getGametypeSetting( "allowInGameTeamChange" ) ? "1" : "0" );
	setDvar( "g_friendlyfireDist", 0 );
	level._supress_survived_screen = true;
	level.speed_change_round = undefined;
	level.is_forever_solo_game = undefined;
	level.shock_onpain = level.grief_gamerules[ "shock_on_pain" ].current;
	level.grief_team_changes_max = 2;
	set_default_pistol();
	setup_scoreboard();
	gamerule_disable_powerups();
	gamerule_remove_restricted_powerups();
	gamerule_toggle_fog();

	level thread on_player_connect();
	level thread monitor_players_connecting_status();
	level thread remove_status_icons_on_end_game();
	level thread check_quickrevive_for_hotjoin();
	level thread remove_round_number();
	level thread instructions_on_all_players();
	level thread emptyLobbyRestart();
}

precache()
{
	precacheshellshock( "grief_stab_zm" );
	precacheStatusIcon( "waypoint_revive" );
	mapname = getDvar( "mapname" );
	gametype = getDvar( "g_gametype" );
	if ( gametype == "zgrief" || mapname == "zm_nuked" )
	{
		precacheshader( "faction_cdc" );
		precacheshader( "faction_cia" );
		precacheshader( "waypoint_revive_cdc_zm" );
		precacheshader( "waypoint_revive_cia_zm" );
	}
	if ( mapname == "zm_prison" )
	{
		precacheShader( "faction_guards" );
		precacheShader( "faction_inmates" );
	}
	if ( mapname == "zm_highrise" || mapname == "zm_nuked" )
	{
		if ( !isDefined( level._effect ) )
		{
			level._effect = [];
		}
		level._effect["butterflies"] = loadfx( "maps\zombie\fx_zmb_impact_noharm" );
	}
}

on_player_connect()
{
	level endon( "end_game" );
	if ( !isDefined( level.grief_team_members ) )
	{
		level.grief_team_members = [];
		level.grief_team_members[ "axis" ] = 0;
		level.grief_team_members[ "allies" ] = 0;
	}
    while ( true )
    {
    	level waittill( "connected", player );
		if ( level.grief_gamerules[ "knife_lunge" ].current )
		{
			player setClientDvar( "aim_automelee_range", 120 ); //default
		}
		else
		{
			player setClientDvar( "aim_automelee_range", 0 );
		}
		if ( !isDefined( player.last_griefed_by ) )
		{
			player.last_griefed_by = spawnStruct();
			player.last_griefed_by.attacker = undefined;
			player.last_griefed_by.meansofdeath = undefined;
			player.last_griefed_by.weapon = undefined;
			player.last_griefed_by.time = 0;
			player thread watch_for_down();
		}
		player.killsconfirmed = 0;
		player.stabs = 0;
		player.stats_start_time = getTime();
		if ( level.grief_ffa )
		{
			player.survived = 0;
		}
		player.team_changes = 0;
		player thread afk_kick();
		player thread on_player_spawn();
	}
}

on_player_spawn()
{
	level endon("end_game");
	self endon( "disconnect" );

	while(1)
	{
		self waittill( "spawned_player" );

		if ( self.score < level.grief_gamerules[ "round_restart_points" ].current )
		{
			self.score = level.grief_gamerules[ "round_restart_points" ].current;
		}

		if ( level.grief_gamerules[ "reduced_pistol_ammo" ].current )
		{
			self scripts\zm\promod_grief\_gamerules::reduce_starting_ammo();
		}

		self scripts\zm\promod_grief\_gamerules::set_visionset();
		self thread give_upgraded_melee();
	}
}

emptyLobbyRestart()
{
	while ( true)
	{
		players = getPlayers();
		if ( players.size > 0 )
		{
			while ( true )
			{
				players = getPlayers();
				if ( players.size < 1 )
				{
					map_restart( false );
				}
				wait 1;
			}
		}
		wait 1;
	}
}
