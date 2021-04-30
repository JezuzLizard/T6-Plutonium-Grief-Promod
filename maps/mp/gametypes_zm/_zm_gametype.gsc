#include maps/mp/zombies/_zm_spawner;
#include maps/mp/zombies/_zm_game_module;
#include maps/mp/zombies/_zm_pers_upgrades_functions;
#include maps/mp/zombies/_zm_blockers;
#include maps/mp/gametypes_zm/_spawning;
#include maps/mp/zombies/_zm_stats;
#include maps/mp/gametypes_zm/_hud;
#include maps/mp/zombies/_zm_audio_announcer;
#include maps/mp/zombies/_zm_audio;
#include maps/mp/zombies/_zm;
#include maps/mp/zombies/_zm_laststand;
#include maps/mp/gametypes_zm/_globallogic_ui;
#include maps/mp/gametypes_zm/_hud_message;
#include maps/mp/gametypes_zm/_globallogic_score;
#include maps/mp/gametypes_zm/_globallogic_defaults;
#include maps/mp/gametypes_zm/_globallogic_spawn;
#include maps/mp/gametypes_zm/_gameobjects;
#include maps/mp/gametypes_zm/_weapons;
#include maps/mp/gametypes_zm/_callbacksetup;
#include maps/mp/gametypes_zm/_globallogic;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/_utility;
#include maps/mp/zombies/_zm_perks;
#include maps/mp/zombies/_zm_zonemgr;
#include maps/mp/zombies/_zm_magicbox;

main() //checked matches cerberus output
{
	//uncomment when replacefunc is available on production.
	// replaceFunc( common_scripts/utility::struct_class_init, ::struct_class_init_override );
	// replaceFunc( maps/mp/zombies/_zm_utility::set_run_speed, ::set_run_speed_override );
	// replaceFunc( maps/mp/zombies/_zm_zonemgr::manage_zones, ::manage_zones_override );
	// replaceFunc( maps/mp/zombies/_zm_audio_announcer::playleaderdialogonplayer, ::playleaderdialogonplayer_override );
	// replaceFunc( maps/mp/zombies/_zm_magicbox::treasure_chest_init, ::treasure_chest_init_override );

	// replaceFunc( maps/mp/zombies/_zm_game_module::kill_all_zombies, ::kill_all_zombies_override );
	// replaceFunc( maps/mp/zombies/_zm_game_module::respawn_players, ::respawn_players_override );
	// replaceFunc( maps/mp/zombies/_zm_game_module::wait_for_team_death_and_round_end, ::wait_for_team_death_and_round_end_override );
	// replaceFunc( maps/mp/zombies/_zm_game_module::check_for_round_end, ::check_for_round_end_override );
	location = getDvar( "ui_zm_mapstartlocation" );
	map = getDvar( "mapname" );
	if ( map == "zm_transit" )
	{
		if ( location == "diner" ||  location == "cornfield" || location == "power" || location == "tunnel" )
		{
			set_location_ents();
		}
	}
	level.custom_spawnplayer = ::grief_spectator_respawn;
	maps/mp/gametypes_zm/_globallogic::init();
	maps/mp/gametypes_zm/_callbacksetup::setupcallbacks();
	globallogic_setupdefault_zombiecallbacks();
	menu_init(); 
	registerroundlimit( 1, 1 );
	registertimelimit( 0, 0 );
	registerscorelimit( 0, 0 );
	registerroundwinlimit( 0, 0 );
	registernumlives( 1, 1 );
	maps/mp/gametypes_zm/_weapons::registergrenadelauncherduddvar( level.gametype, 10, 0, 1440 );
	maps/mp/gametypes_zm/_weapons::registerthrowngrenadeduddvar( level.gametype, 0, 0, 1440 );
	maps/mp/gametypes_zm/_weapons::registerkillstreakdelay( level.gametype, 0, 0, 1440 );
	maps/mp/gametypes_zm/_globallogic::registerfriendlyfiredelay( level.gametype, 15, 0, 1440 );
	level.takelivesondeath = 1;
	level.teambased = 1;
	level.disableprematchmessages = 1;
	level.disablemomentum = 1;
	level.overrideteamscore = 0;
	level.overrideplayerscore = 0;
	level.displayhalftimetext = 0;
	level.displayroundendtext = 0;
	level.allowannouncer = 0;
	level.endgameonscorelimit = 0;
	level.endgameontimelimit = 0;
	level.resetplayerscoreeveryround = 1;
	level.doprematch = 0;
	level.nopersistence = 1;
	level.scoreroundbased = 0;
	level.forceautoassign = 1;
	level.dontshowendreason = 1;
	level.forceallallies = 0;
	level.allow_teamchange = 0;
	setdvar( "scr_disable_team_selection", 1 );
	makedvarserverinfo( "scr_disable_team_selection", 1 );
	setmatchflag( "hud_zombie", 1 );
	setdvar( "scr_disable_weapondrop", 1 );
	setdvar( "scr_xpscale", 0 );
	level.onstartgametype = ::onstartgametype;
	level.onspawnplayer = ::blank;
	level.onspawnplayerunified = ::onspawnplayerunified; 
	level.onroundendgame = ::onroundendgame;
	level.mayspawn = ::mayspawn;
	set_game_var( "ZM_roundLimit", 1 );
	set_game_var( "ZM_scoreLimit", 1 );
	set_game_var( "_team1_num", 0 );
	set_game_var( "_team2_num", 0 );
	map_name = level.script;
	mode = getDvar( "ui_gametype" );
	if ( !isDefined( mode ) && isDefined( level.default_game_mode ) || mode == "" && isDefined( level.default_game_mode ) )
	{
		mode = level.default_game_mode;
	}
	set_gamemode_var_once( "mode", mode );
	set_game_var_once( "side_selection", 1 );
	location = getDvar( "ui_zm_mapstartlocation" );
	if ( location == "" && isDefined( level.default_start_location ) )
	{
		location = level.default_start_location;
	}
	set_gamemode_var_once( "location", location );
	set_gamemode_var_once( "randomize_mode", getDvarInt( "zm_rand_mode" ) );
	set_gamemode_var_once( "randomize_location", getDvarInt( "zm_rand_loc" ) );
	set_gamemode_var_once( "team_1_score", 0 );
	set_gamemode_var_once( "team_2_score", 0 );
	set_gamemode_var_once( "current_round", 0 );
	set_gamemode_var_once( "rules_read", 0 );
	set_game_var_once( "switchedsides", 0 );
	gametype = getDvar( "ui_gametype" );
	game[ "dialog" ][ "gametype" ] = gametype + "_start";
	game[ "dialog" ][ "gametype_hardcore" ] = gametype + "_start";
	game[ "dialog" ][ "offense_obj" ] = "generic_boost";
	game[ "dialog" ][ "defense_obj" ] = "generic_boost";
	set_gamemode_var( "pre_init_zombie_spawn_func", undefined );
	set_gamemode_var( "post_init_zombie_spawn_func", undefined );
	set_gamemode_var( "match_end_notify", undefined );
	set_gamemode_var( "match_end_func", undefined );
	setscoreboardcolumns( "score", "stabs", "killsconfirmed", "revives", "downs" );
	onplayerconnect_callback( ::onplayerconnect_check_for_hotjoin );
}

game_objects_allowed( mode, location ) //checked partially changed to match cerberus output changed at own discretion
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

post_init_gametype() //checked matches cerberus output
{
	if ( isDefined( level.gamemode_map_postinit ) )
	{
		if ( isDefined( level.gamemode_map_postinit[ level.scr_zm_ui_gametype ] ) )
		{
			[[ level.gamemode_map_postinit[ level.scr_zm_ui_gametype ] ]]();
		}
	}
}

post_gametype_main( mode ) //checked matches cerberus output
{
	set_game_var( "ZM_roundWinLimit", get_game_var( "ZM_roundLimit" ) * 0.5 );
	level.roundlimit = get_game_var( "ZM_roundLimit" );
	if ( isDefined( level.gamemode_map_preinit ) )
	{
		if ( isDefined( level.gamemode_map_preinit[ mode ] ) )
		{
			[[ level.gamemode_map_preinit[ mode ] ]]();
		}
	}
}

globallogic_setupdefault_zombiecallbacks() //checked matches cerberus output
{
	level.spawnplayer = maps/mp/gametypes_zm/_globallogic_spawn::spawnplayer;
	level.spawnplayerprediction = maps/mp/gametypes_zm/_globallogic_spawn::spawnplayerprediction;
	level.spawnclient = maps/mp/gametypes_zm/_globallogic_spawn::spawnclient;
	level.spawnspectator = maps/mp/gametypes_zm/_globallogic_spawn::spawnspectator;
	level.spawnintermission = maps/mp/gametypes_zm/_globallogic_spawn::spawnintermission;
	level.onplayerscore = ::blank;
	level.onteamscore = ::blank;
	
	//doesn't exist in any dump or any other script no idea what its trying to override to
	level.wavespawntimer = maps/mp/gametypes_zm/_globallogic::wavespawntimer;
	level.onspawnplayer = ::blank;
	level.onspawnplayerunified = ::blank;
	level.onspawnspectator = ::onspawnspectator;
	level.onspawnintermission = ::onspawnintermission;
	level.onrespawndelay = ::blank;
	level.onforfeit = ::blank;
	level.ontimelimit = ::blank;
	level.onscorelimit = ::blank;
	level.ondeadevent = ::ondeadevent;
	level.ononeleftevent = ::blank;
	level.giveteamscore = ::blank;
	level.giveplayerscore = ::blank;
	level.gettimelimit = maps/mp/gametypes_zm/_globallogic_defaults::default_gettimelimit;
	level.getteamkillpenalty = ::blank;
	level.getteamkillscore = ::blank;
	level.iskillboosting = ::blank;
	level._setteamscore = maps/mp/gametypes_zm/_globallogic_score::_setteamscore;
	level._setplayerscore = ::blank;
	level._getteamscore = ::blank;
	level._getplayerscore = ::blank;
	level.onprecachegametype = ::blank;
	level.onstartgametype = ::blank;
	level.onplayerconnect = ::blank;
	level.onplayerdisconnect = ::onplayerdisconnect;
	level.onplayerdamage = ::blank;
	level.onplayerkilled = ::blank;
	level.onplayerkilledextraunthreadedcbs = [];
	level.onteamoutcomenotify = maps/mp/gametypes_zm/_hud_message::teamoutcomenotifyzombie;
	level.onoutcomenotify = ::blank;
	level.onteamwageroutcomenotify = ::blank;
	level.onwageroutcomenotify = ::blank;
	level.onendgame = ::onendgame;
	level.onroundendgame = ::blank;
	level.onmedalawarded = ::blank;
	level.autoassign = maps/mp/gametypes_zm/_globallogic_ui::menuautoassign;
	level.spectator = maps/mp/gametypes_zm/_globallogic_ui::menuspectator;
	level.class = maps/mp/gametypes_zm/_globallogic_ui::menuclass;
	level.allies = ::menuallieszombies;
	level.teammenu = maps/mp/gametypes_zm/_globallogic_ui::menuteam;
	level.callbackactorkilled = ::blank;
	level.callbackvehicledamage = ::blank;
}

setup_standard_objects( location ) //checked partially used cerberus output
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


is_survival_object() //checked changed to cerberus output
{
	if ( !isdefined( self.script_parameters ) )
	{
		return 0;
	}
	tokens = strtok( self.script_parameters, " " );
	remove = 0;
	foreach ( token in tokens )
	{
		if ( token == "survival_remove" )
		{
			remove = 1;
		}
	}
	return remove;
}

game_module_player_damage_callback( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime ) //checked partially changed output to cerberus output
{
	self.last_damage_from_zombie_or_player = 0;
	if ( isDefined( eattacker ) )
	{
		if ( isplayer( eattacker ) && eattacker == self )
		{
			return;
		}
		if ( isDefined( eattacker.is_zombie ) || eattacker.is_zombie && isplayer( eattacker ) )
		{
			self.last_damage_from_zombie_or_player = 1;
		}
	}
	if ( is_true( self._being_shellshocked ) || self maps/mp/zombies/_zm_laststand::player_is_in_laststand() )
	{
		return;
	}
	if ( isplayer( eattacker ) && isDefined( eattacker._encounters_team ) && eattacker._encounters_team != self._encounters_team )
	{
		if ( is_true( self.hasriotshield ) && isDefined( vdir ) )
		{
			if ( is_true( self.hasriotshieldequipped ) )
			{
				if ( self maps/mp/zombies/_zm::player_shield_facing_attacker( vdir, 0.2 ) && isDefined( self.player_shield_apply_damage ) )
				{
					return;
				}
			}
			else if ( !isdefined( self.riotshieldentity ) )
			{
				if ( !self maps/mp/zombies/_zm::player_shield_facing_attacker( vdir, -0.2 ) && isdefined( self.player_shield_apply_damage ) )
				{
					return;
				}
			}
		}
		if ( isDefined( level._game_module_player_damage_grief_callback ) )
		{
			self [[ level._game_module_player_damage_grief_callback ]]( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime );
		}
		if ( isDefined( level._effect[ "butterflies" ] ) )
		{
			if ( isDefined( sweapon ) && weapontype( sweapon ) == "grenade" )
			{
				playfx( level._effect[ "butterflies" ], self.origin + vectorScale( ( 1, 1, 1 ), 40 ) );
			}
			else
			{
				playfx( level._effect[ "butterflies" ], vpoint, vdir );
			}
		}
		self thread do_game_mode_shellshock();
		self playsound( "zmb_player_hit_ding" );
	}
}

do_game_mode_shellshock() //checked matched cerberus output
{
	self endon( "disconnect" );
	self._being_shellshocked = 1;
	self shellshock( "grief_stab_zm", 0.75 );
	wait 0.75;
	self._being_shellshocked = 0;
}

add_map_gamemode( mode, preinit_func, precache_func, main_func ) //checked matches cerberus output
{
	if ( !isDefined( level.gamemode_map_location_init ) )
	{
		level.gamemode_map_location_init = [];
	}
	if ( !isDefined( level.gamemode_map_location_main ) )
	{
		level.gamemode_map_location_main = [];
	}
	if ( !isDefined( level.gamemode_map_preinit ) )
	{
		level.gamemode_map_preinit = [];
	}
	if ( !isDefined( level.gamemode_map_postinit ) )
	{
		level.gamemode_map_postinit = [];
	}
	if ( !isDefined( level.gamemode_map_precache ) )
	{
		level.gamemode_map_precache = [];
	}
	if ( !isDefined( level.gamemode_map_main ) )
	{
		level.gamemode_map_main = [];
	}
	level.gamemode_map_preinit[ mode ] = preinit_func;
	level.gamemode_map_main[ mode ] = main_func;
	level.gamemode_map_precache[ mode ] = precache_func;
	level.gamemode_map_location_precache[ mode ] = [];
	level.gamemode_map_location_main[ mode ] = [];
}

add_map_location_gamemode( mode, location, precache_func, main_func ) //checked matches cerberus output
{
	if ( !isDefined( level.gamemode_map_location_precache[ mode ] ) )
	{
		return;
	}
	level.gamemode_map_location_precache[ mode ][ location ] = precache_func;
	level.gamemode_map_location_main[ mode ][ location ] = main_func;
}

rungametypeprecache( gamemode ) //checked matches cerberus output
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

rungametypemain( gamemode, mode_main_func, use_round_logic ) //checked matches cerberus output
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


round_logic( mode_logic_func ) //checked matches cerberus output
{
	level.skit_vox_override = 1;
	if ( isDefined( level.flag[ "start_zombie_round_logic" ] ) )
	{
		flag_wait( "start_zombie_round_logic" );
	}
	flag_wait( "start_encounters_match_logic" );
	if ( !isDefined( game[ "gamemode_match" ][ "rounds" ] ) )
	{
		game[ "gamemode_match" ][ "rounds" ] = [];
	}
	set_gamemode_var_once( "current_round", 0 );
	set_gamemode_var_once( "team_1_score", 0 );
	set_gamemode_var_once( "team_2_score", 0 );
	if ( isDefined( is_encounter() ) && is_encounter() )
	{
		[[ level._setteamscore ]]( "allies", get_gamemode_var( "team_2_score" ) );
		[[ level._setteamscore ]]( "axis", get_gamemode_var( "team_1_score" ) );
	}
	flag_set( "pregame" );
	waittillframeend;
	level.gameended = 0;
	cur_round = get_gamemode_var( "current_round" );
	set_gamemode_var( "current_round", cur_round + 1 );
	game[ "gamemode_match" ][ "rounds" ][ cur_round ] = spawnstruct();
	game[ "gamemode_match" ][ "rounds" ][ cur_round ].mode = getDvar( "ui_gametype" );
	level thread [[ mode_logic_func ]]();
	flag_wait( "start_encounters_match_logic" );
	level.gamestarttime = getTime();
	level.gamelengthtime = undefined;
	level notify( "clear_hud_elems" );
	level waittill( "game_module_ended", winner );
	game[ "gamemode_match" ][ "rounds" ][ cur_round ].winner = winner;
	level thread kill_all_zombies();
	level.gameendtime = getTime();
	level.gamelengthtime = level.gameendtime - level.gamestarttime;
	level.gameended = 1;
	if ( winner == "A" )
	{
		score = get_gamemode_var( "team_1_score" );
		set_gamemode_var( "team_1_score", score + 1 );
	}
	else
	{
		score = get_gamemode_var( "team_2_score" );
		set_gamemode_var( "team_2_score", score + 1 );
	}
	if ( is_true( is_encounter() ) )
	{
		[[ level._setteamscore ]]( "allies", get_gamemode_var( "team_2_score" ) );
		[[ level._setteamscore ]]( "axis", get_gamemode_var( "team_1_score" ) );
		if ( get_gamemode_var( "team_1_score" ) == get_gamemode_var( "team_2_score" ) )
		{
			level thread maps/mp/zombies/_zm_audio::zmbvoxcrowdonteam( "win" );
			level thread maps/mp/zombies/_zm_audio_announcer::announceroundwinner( "tied" );
		}
		else
		{
			level thread maps/mp/zombies/_zm_audio::zmbvoxcrowdonteam( "win", winner, "lose" );
			level thread maps/mp/zombies/_zm_audio_announcer::announceroundwinner( winner );
		}
	}
	level thread delete_corpses();
	level delay_thread( 5, ::revive_laststand_players );
	level notify( "clear_hud_elems" );
	while ( startnextzmround( winner ) )
	{
		level clientnotify( "gme" );
		while ( 1 )
		{
			wait 1;
		}
	}
	level.match_is_ending = 1;
	if ( is_true( is_encounter() ) )
	{
		matchwonteam = "";
		if ( get_gamemode_var( "team_1_score" ) > get_gamemode_var( "team_2_score" ) )
		{
			matchwonteam = "A";
		}
		else
		{
			matchwonteam = "B";
		}
		level thread maps/mp/zombies/_zm_audio::zmbvoxcrowdonteam( "win", matchwonteam, "lose" );
		level thread maps/mp/zombies/_zm_audio_announcer::announcematchwinner( matchwonteam );
		level create_final_score();
		track_encounters_win_stats( matchwonteam );
	}
	maps/mp/zombies/_zm::intermission();
	level.can_revive_game_module = undefined;
	level notify( "end_game" );
}

end_rounds_early( winner ) //checked matches cerberus output
{
	level.forcedend = 1;
	cur_round = get_gamemode_var( "current_round" );
	set_gamemode_var( "ZM_roundLimit", cur_round );
	if ( isDefined( winner ) )
	{
		level notify( "game_module_ended" );
	}
	else
	{
		level notify( "end_game" );
	}
}


checkzmroundswitch() //checked matches cerberus output
{
	if ( !isDefined( level.zm_roundswitch ) || !level.zm_roundswitch )
	{
		return 0;
	}
	
	return 1;
	return 0;
}

create_hud_scoreboard( duration, fade ) //checked matches cerberus output
{
	level endon( "end_game" );
	level thread module_hud_full_screen_overlay();
	level thread module_hud_team_1_score( duration, fade );
	level thread module_hud_team_2_score( duration, fade );
	level thread module_hud_round_num( duration, fade );
	respawn_spectators_and_freeze_players();
	waittill_any_or_timeout( duration, "clear_hud_elems" );
}

respawn_spectators_and_freeze_players() //checked changed to match cerberus output
{
	players = get_players();
	foreach ( player in players )
	{
		if ( player.sessionstate == "spectator" )
		{
			if ( isdefined( player.spectate_hud ) )
			{
				player.spectate_hud destroy();
			}
			player [[ level.spawnplayer ]]();
		}
		player freeze_player_controls( 1 );
	}
}

module_hud_team_1_score( duration, fade ) //checked matches cerberus output
{
	level._encounters_score_1 = newhudelem();
	level._encounters_score_1.x = 0;
	level._encounters_score_1.y = 260;
	level._encounters_score_1.alignx = "center";
	level._encounters_score_1.horzalign = "center";
	level._encounters_score_1.vertalign = "top";
	level._encounters_score_1.font = "default";
	level._encounters_score_1.fontscale = 2.3;
	level._encounters_score_1.color = ( 1, 1, 1 );
	level._encounters_score_1.foreground = 1;
	level._encounters_score_1 settext( "Team CIA:  " + get_gamemode_var( "team_1_score" ) );
	level._encounters_score_1.alpha = 0;
	level._encounters_score_1.sort = 11;
	level._encounters_score_1 fadeovertime( fade );
	level._encounters_score_1.alpha = 1;
	level waittill_any_or_timeout( duration, "clear_hud_elems" );
	level._encounters_score_1 fadeovertime( fade );
	level._encounters_score_1.alpha = 0;
	wait fade;
	level._encounters_score_1 destroy();
}

module_hud_team_2_score( duration, fade ) //checked matches cerberus output
{
	level._encounters_score_2 = newhudelem();
	level._encounters_score_2.x = 0;
	level._encounters_score_2.y = 290;
	level._encounters_score_2.alignx = "center";
	level._encounters_score_2.horzalign = "center";
	level._encounters_score_2.vertalign = "top";
	level._encounters_score_2.font = "default";
	level._encounters_score_2.fontscale = 2.3;
	level._encounters_score_2.color = ( 1, 1, 1 );
	level._encounters_score_2.foreground = 1;
	level._encounters_score_2 settext( "Team CDC:  " + get_gamemode_var( "team_2_score" ) );
	level._encounters_score_2.alpha = 0;
	level._encounters_score_2.sort = 12;
	level._encounters_score_2 fadeovertime( fade );
	level._encounters_score_2.alpha = 1;
	level waittill_any_or_timeout( duration, "clear_hud_elems" );
	level._encounters_score_2 fadeovertime( fade );
	level._encounters_score_2.alpha = 0;
	wait fade;
	level._encounters_score_2 destroy();
}

module_hud_round_num( duration, fade ) //checked matches cerberus output
{
	level._encounters_round_num = newhudelem();
	level._encounters_round_num.x = 0;
	level._encounters_round_num.y = 60;
	level._encounters_round_num.alignx = "center";
	level._encounters_round_num.horzalign = "center";
	level._encounters_round_num.vertalign = "top";
	level._encounters_round_num.font = "default";
	level._encounters_round_num.fontscale = 2.3;
	level._encounters_round_num.color = ( 1, 1, 1 );
	level._encounters_round_num.foreground = 1;
	level._encounters_round_num settext( "Round:  ^5" + get_gamemode_var( "current_round" ) + 1 + " / " + get_game_var( "ZM_roundLimit" ) );
	level._encounters_round_num.alpha = 0;
	level._encounters_round_num.sort = 13;
	level._encounters_round_num fadeovertime( fade );
	level._encounters_round_num.alpha = 1;
	level waittill_any_or_timeout( duration, "clear_hud_elems" );
	level._encounters_round_num fadeovertime( fade );
	level._encounters_round_num.alpha = 0;
	wait fade;
	level._encounters_round_num destroy();
}

createtimer() //checked matches cerberus output
{
	flag_waitopen( "pregame" );
	elem = newhudelem();
	elem.hidewheninmenu = 1;
	elem.horzalign = "center";
	elem.vertalign = "top";
	elem.alignx = "center";
	elem.aligny = "middle";
	elem.x = 0;
	elem.y = 0;
	elem.foreground = 1;
	elem.font = "default";
	elem.fontscale = 1.5;
	elem.color = ( 1, 1, 1 );
	elem.alpha = 2;
	elem thread maps/mp/gametypes_zm/_hud::fontpulseinit();
	if ( is_true( level.timercountdown ) )
	{
		elem settenthstimer( level.timelimit * 60 );
	}
	else
	{
		elem settenthstimerup( 0.1 );
	}
	level.game_module_timer = elem;
	level waittill( "game_module_ended" );
	elem destroy();
}

revive_laststand_players() //checked changed to match cerberus output
{
	if ( is_true( level.match_is_ending ) )
	{
		return;
	}
	players = get_players();
	foreach ( player in players )
	{
		if ( player maps/mp/zombies/_zm_laststand::player_is_in_laststand() )
		{
			player thread maps/mp/zombies/_zm_laststand::auto_revive( player );
		}
	}
}

team_icon_winner( elem ) //checked matches cerberus output
{
	og_x = elem.x;
	og_y = elem.y;
	elem.sort = 1;
	elem scaleovertime( 0.75, 150, 150 );
	elem moveovertime( 0.75 );
	elem.horzalign = "center";
	elem.vertalign = "middle";
	elem.x = 0;
	elem.y = 0;
	elem.alpha = 0.7;
	wait 0.75;
}

delete_corpses() //checked changed to match cerberus output
{
	corpses = getcorpsearray();
	for(x = 0; x < corpses.size; x++)
	{
		corpses[x] delete();
	}
}

track_encounters_win_stats( matchwonteam ) //checked did not change to match cerberus output
{
	players = get_players();
	i = 0;
	while ( i < players.size )
	{
		if ( players[ i ]._encounters_team == matchwonteam )
		{
			players[ i ] maps/mp/zombies/_zm_stats::increment_client_stat( "wins" );
			players[ i ] maps/mp/zombies/_zm_stats::add_client_stat( "losses", -1 );
			players[ i ] adddstat( "skill_rating", 1 );
			players[ i ] setdstat( "skill_variance", 1 );
			if ( gamemodeismode( level.gamemode_public_match ) )
			{
				players[ i ] maps/mp/zombies/_zm_stats::add_location_gametype_stat( level.scr_zm_map_start_location, level.scr_zm_ui_gametype, "wins", 1 );
				players[ i ] maps/mp/zombies/_zm_stats::add_location_gametype_stat( level.scr_zm_map_start_location, level.scr_zm_ui_gametype, "losses", -1 );
			}
		}
		else
		{
			players[ i ] setdstat( "skill_rating", 0 );
			players[ i ] setdstat( "skill_variance", 1 );
		}
		players[ i ] updatestatratio( "wlratio", "wins", "losses" );
		i++;
	}
}

non_round_logic( mode_logic_func ) //checked matches cerberus output
{
	level thread [[ mode_logic_func ]]();
}

game_end_func() //checked matches cerberus output
{
	if ( !isDefined( get_gamemode_var( "match_end_notify" ) ) && !isDefined( get_gamemode_var( "match_end_func" ) ) )
	{
		return;
	}
	level waittill( get_gamemode_var( "match_end_notify" ), winning_team );
	level thread [[ get_gamemode_var( "match_end_func" ) ]]( winning_team );
}

setup_classic_gametype() //checked did not change to match cerberus output
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

zclassic_main() //checked matches cerberus output
{
	level thread setup_classic_gametype();
	level thread maps/mp/zombies/_zm::round_start();
}

unlink_meat_traversal_nodes() //checked changed to match cerberus output
{
	meat_town_nodes = getnodearray( "meat_town_barrier_traversals", "targetname" );
	meat_tunnel_nodes = getnodearray( "meat_tunnel_barrier_traversals", "targetname" );
	meat_farm_nodes = getnodearray( "meat_farm_barrier_traversals", "targetname" );
	nodes = arraycombine( meat_town_nodes, meat_tunnel_nodes, 1, 0 );
	traversal_nodes = arraycombine( nodes, meat_farm_nodes, 1, 0 );
	foreach ( node in traversal_nodes )
	{
		end_node = getnode( node.target, "targetname" );
		unlink_nodes( node, end_node );
	}
}

canplayersuicide() //checked matches cerberus output
{
	return self hasperk( "specialty_scavenger" );
}

onplayerdisconnect() //checked matches cerberus output
{
	if ( isDefined( level.game_mode_custom_onplayerdisconnect ) )
	{
		level [[ level.game_mode_custom_onplayerdisconnect ]]( self );
	}
	level thread maps/mp/zombies/_zm::check_quickrevive_for_hotjoin( 1 );
	self maps/mp/zombies/_zm_laststand::add_weighted_down();
	level maps/mp/zombies/_zm::checkforalldead( self );
}

ondeadevent( team ) //checked matches cerberus output
{
	thread maps/mp/gametypes_zm/_globallogic::endgame( level.zombie_team, "" );
}

onspawnintermission() //checked matches cerberus output
{
	spawnpointname = "info_intermission";
	spawnpoints = getentarray( spawnpointname, "classname" );
	if ( spawnpoints.size < 1 )
	{
		return;
	}
	spawnpoint = spawnpoints[ randomint( spawnpoints.size ) ];
	if ( isDefined( spawnpoint ) )
	{
		self spawn( spawnpoint.origin, spawnpoint.angles );
	}
}

onspawnspectator( origin, angles ) //checked matches cerberus output
{
}

mayspawn() //checked matches cerberus output
{
	if ( isDefined( level.custommayspawnlogic ) )
	{
		return self [[ level.custommayspawnlogic ]]();
	}
	if ( self.pers[ "lives" ] == 0 )
	{
		level notify( "player_eliminated" );
		self notify( "player_eliminated" );
		return 0;
	}
	return 1;
}

onstartgametype() //checked matches cerberus output
{
	setclientnamemode( "auto_change" );
	level.displayroundendtext = 0;
	maps/mp/gametypes_zm/_spawning::create_map_placed_influencers();
	if ( !isoneround() )
	{
		level.displayroundendtext = 1;
		if ( isscoreroundbased() )
		{
			maps/mp/gametypes_zm/_globallogic_score::resetteamscores();
		}
	}
}

module_hud_full_screen_overlay() //checked matches cerberus output
{
	fadetoblack = newhudelem();
	fadetoblack.x = 0;
	fadetoblack.y = 0;
	fadetoblack.horzalign = "fullscreen";
	fadetoblack.vertalign = "fullscreen";
	fadetoblack setshader( "black", 640, 480 );
	fadetoblack.color = ( 1, 1, 1 );
	fadetoblack.alpha = 1;
	fadetoblack.foreground = 1;
	fadetoblack.sort = 0;
	if ( is_encounter() || getDvar( "ui_gametype" ) == "zcleansed" )
	{
		level waittill_any_or_timeout( 25, "start_fullscreen_fade_out" );
	}
	else
	{
		level waittill_any_or_timeout( 25, "start_zombie_round_logic" );
	}
	fadetoblack fadeovertime( 2 );
	fadetoblack.alpha = 0;
	wait 2.1;
	fadetoblack destroy();
}

create_final_score() //checked matches cerberus output
{
	level endon( "end_game" );
	level thread module_hud_team_winer_score();
	wait 2;
}

module_hud_team_winer_score() //checked changed to match cerberus output
{
	players = get_players();
	for ( i = 0; i < players.size; i++ )
	{
		players[ i ] thread create_module_hud_team_winer_score();
		if ( isDefined( players[ i ]._team_hud ) && isDefined( players[ i ]._team_hud[ "team" ] ) )
		{
			players[ i ] thread team_icon_winner( players[ i ]._team_hud[ "team" ] );
		}
		if ( isDefined( level.lock_player_on_team_score ) && level.lock_player_on_team_score )
		{
			players[ i ] freezecontrols( 1 );
			players[ i ] takeallweapons();
			players[ i ] setclientuivisibilityflag( "hud_visible", 0 );
			players[ i ].sessionstate = "spectator";
			players[ i ].spectatorclient = -1;
			players[ i ].maxhealth = players[ i ].health;
			players[ i ].shellshocked = 0;
			players[ i ].inwater = 0;
			players[ i ].friendlydamage = undefined;
			players[ i ].hasspawned = 1;
			players[ i ].spawntime = getTime();
			players[ i ].afk = 0;
			players[ i ] detachall();
		}
	}
	level thread maps/mp/zombies/_zm_audio::change_zombie_music( "match_over" );
}

create_module_hud_team_winer_score() //checked changed to match cerberus output
{
	self._team_winer_score = newclienthudelem( self );
	self._team_winer_score.x = 0;
	self._team_winer_score.y = 70;
	self._team_winer_score.alignx = "center";
	self._team_winer_score.horzalign = "center";
	self._team_winer_score.vertalign = "middle";
	self._team_winer_score.font = "default";
	self._team_winer_score.fontscale = 15;
	self._team_winer_score.color = ( 0, 1, 0 );
	self._team_winer_score.foreground = 1;
	if ( self._encounters_team == "B" && get_gamemode_var( "team_2_score" ) > get_gamemode_var( "team_1_score" ) )
	{
		self._team_winer_score settext( &"ZOMBIE_MATCH_WON" );
	}
	else
	{
		if ( self._encounters_team == "B" && get_gamemode_var( "team_2_score" ) < get_gamemode_var( "team_1_score" ) )
		{
			self._team_winer_score.color = ( 1, 0, 0 );
			self._team_winer_score settext( &"ZOMBIE_MATCH_LOST" );
		}
	}
	if ( self._encounters_team == "A" && get_gamemode_var( "team_1_score" ) > get_gamemode_var( "team_2_score" ) )
	{
		self._team_winer_score settext( &"ZOMBIE_MATCH_WON" );
	}
	else
	{
		if ( self._encounters_team == "A" && get_gamemode_var( "team_1_score" ) < get_gamemode_var( "team_2_score" ) )
		{
			self._team_winer_score.color = ( 1, 0, 0 );
			self._team_winer_score settext( &"ZOMBIE_MATCH_LOST" );
		}
	}
	self._team_winer_score.alpha = 0;
	self._team_winer_score.sort = 12;
	self._team_winer_score fadeovertime( 0.25 );
	self._team_winer_score.alpha = 1;
	wait 2;
	self._team_winer_score fadeovertime( 0.25 );
	self._team_winer_score.alpha = 0;
	wait 0.25;
	self._team_winer_score destroy();
}

displayroundend( round_winner ) //checked changed to match cerberus output
{
	players = get_players();
	foreach(player in players)
	{
		player thread module_hud_round_end( round_winner );
		if ( isdefined( player._team_hud ) && isdefined( player._team_hud[ "team" ] ) )
		{
			player thread team_icon_winner( player._team_hud[ "team" ] );
		}
		player freeze_player_controls( 1 );
	}
	level thread maps/mp/zombies/_zm_audio::change_zombie_music( "round_end" );
	level thread maps/mp/zombies/_zm_audio::zmbvoxcrowdonteam( "clap" );
	level thread play_sound_2d( "zmb_air_horn" );
	wait 2;
}

module_hud_round_end( round_winner ) //checked changed to match cerberus output
{
	self endon( "disconnect" );
	self._team_winner_round = newclienthudelem( self );
	self._team_winner_round.x = 0;
	self._team_winner_round.y = 50;
	self._team_winner_round.alignx = "center";
	self._team_winner_round.horzalign = "center";
	self._team_winner_round.vertalign = "middle";
	self._team_winner_round.font = "default";
	self._team_winner_round.fontscale = 15;
	self._team_winner_round.color = ( 1, 1, 1 );
	self._team_winner_round.foreground = 1;
	if ( self._encounters_team == round_winner )
	{
		self._team_winner_round.color = ( 0, 1, 0 );
		self._team_winner_round settext( "YOU WIN" );
	}
	else
	{
		self._team_winner_round.color = ( 1, 0, 0 );
		self._team_winner_round settext( "YOU LOSE" );
	}
	self._team_winner_round.alpha = 0;
	self._team_winner_round.sort = 12;
	self._team_winner_round fadeovertime( 0.25 );
	self._team_winner_round.alpha = 1;
	wait 1.5;
	self._team_winner_round fadeovertime( 0.25 );
	self._team_winner_round.alpha = 0;
	wait 0.25;
	self._team_winner_round destroy();
}

displayroundswitch() //checked changed to match cerberus output
{
	level._round_changing_sides = newhudelem();
	level._round_changing_sides.x = 0;
	level._round_changing_sides.y = 60;
	level._round_changing_sides.alignx = "center";
	level._round_changing_sides.horzalign = "center";
	level._round_changing_sides.vertalign = "middle";
	level._round_changing_sides.font = "default";
	level._round_changing_sides.fontscale = 2.3;
	level._round_changing_sides.color = ( 1, 1, 1 );
	level._round_changing_sides.foreground = 1;
	level._round_changing_sides.sort = 12;
	fadetoblack = newhudelem();
	fadetoblack.x = 0;
	fadetoblack.y = 0;
	fadetoblack.horzalign = "fullscreen";
	fadetoblack.vertalign = "fullscreen";
	fadetoblack setshader( "black", 640, 480 );
	fadetoblack.color = ( 0, 0, 0 );
	fadetoblack.alpha = 1;
	level thread maps/mp/zombies/_zm_audio_announcer::leaderdialog( "side_switch" );
	level._round_changing_sides settext( "CHANGING SIDES" );
	level._round_changing_sides fadeovertime( 0.25 );
	level._round_changing_sides.alpha = 1;
	wait 1;
	fadetoblack fadeovertime( 1 );
	level._round_changing_sides fadeovertime( 0.25 );
	level._round_changing_sides.alpha = 0;
	fadetoblack.alpha = 0;
	wait 0.25;
	level._round_changing_sides destroy();
	fadetoblack destroy();
}

module_hud_create_team_name() //checked matches cerberus ouput
{
	if ( !is_encounter() )
	{
		return;
	}
	if ( !isDefined( self._team_hud ) )
	{
		self._team_hud = [];
	}
	if ( isDefined( self._team_hud[ "team" ] ) )
	{
		self._team_hud[ "team" ] destroy();
	}
	elem = newclienthudelem( self );
	elem.hidewheninmenu = 1;
	elem.alignx = "center";
	elem.aligny = "middle";
	elem.horzalign = "center";
	elem.vertalign = "middle";
	elem.x = 0;
	elem.y = 0;
	if ( isDefined( level.game_module_team_name_override_og_x ) )
	{
		elem.og_x = level.game_module_team_name_override_og_x;
	}
	else
	{
		elem.og_x = 85;
	}
	elem.og_y = -40;
	elem.foreground = 1;
	elem.font = "default";
	elem.color = ( 1, 1, 1 );
	elem.sort = 1;
	elem.alpha = 0.7;
	elem setshader( game[ "icons" ][ self.team ], 150, 150 );
	self._team_hud[ "team" ] = elem;
}

nextzmhud( winner ) //checked matches cerberus output
{
	displayroundend( winner );
	create_hud_scoreboard( 1, 0.25 );
	if ( checkzmroundswitch() )
	{
		displayroundswitch();
	}
}

startnextzmround( winner ) //checked matches cerberus output
{
	if ( !isonezmround() )
	{
		if ( !waslastzmround() )
		{
			nextzmhud( winner );
			setmatchtalkflag( "DeadChatWithDead", level.voip.deadchatwithdead );
			setmatchtalkflag( "DeadChatWithTeam", level.voip.deadchatwithteam );
			setmatchtalkflag( "DeadHearTeamLiving", level.voip.deadhearteamliving );
			setmatchtalkflag( "DeadHearAllLiving", level.voip.deadhearallliving );
			setmatchtalkflag( "EveryoneHearsEveryone", level.voip.everyonehearseveryone );
			setmatchtalkflag( "DeadHearKiller", level.voip.deadhearkiller );
			setmatchtalkflag( "KillersHearVictim", level.voip.killershearvictim );
			game[ "state" ] = "playing";
			level.allowbattlechatter = getgametypesetting( "allowBattleChatter" );
			if ( is_true( level.zm_switchsides_on_roundswitch ) )
			{
				set_game_var( "switchedsides", !get_game_var( "switchedsides" ) );
			}
			map_restart( 1 );
			return 1;
		}
	}
	return 0;
}

start_round() //checked changed to match cerberus output
{
	flag_clear( "start_encounters_match_logic" );
	if ( !isDefined( level._module_round_hud ) )
	{
		level._module_round_hud = newhudelem();
		level._module_round_hud.x = 0;
		level._module_round_hud.y = 70;
		level._module_round_hud.alignx = "center";
		level._module_round_hud.horzalign = "center";
		level._module_round_hud.vertalign = "middle";
		level._module_round_hud.font = "default";
		level._module_round_hud.fontscale = 2.3;
		level._module_round_hud.color = ( 1, 1, 1 );
		level._module_round_hud.foreground = 1;
		level._module_round_hud.sort = 0;
	}
	players = get_players();
	for ( i = 0; i < players.size; i++ )
	{
		players[ i ] freeze_player_controls( 1 );
	}
	level._module_round_hud.alpha = 1;
	label = &"Next Round Starting In  ^2";
	level._module_round_hud.label = label;
	level._module_round_hud settimer( 3 );
	level thread maps/mp/zombies/_zm_audio_announcer::leaderdialog( "countdown" );
	level thread maps/mp/zombies/_zm_audio::zmbvoxcrowdonteam( "clap" );
	level thread maps/mp/zombies/_zm_audio::change_zombie_music( "round_start" );
	level notify( "start_fullscreen_fade_out" );
	wait 2;
	level._module_round_hud fadeovertime( 1 );
	level._module_round_hud.alpha = 0;
	wait 1;
	level thread play_sound_2d( "zmb_air_horn" );
	players = get_players();
	for ( i = 0; i < players.size; i++ )
	{
		players[ i ] freeze_player_controls( 0 );
		players[ i ] sprintuprequired();
	}
	flag_set( "start_encounters_match_logic" );
	flag_clear( "pregame" );
	level._module_round_hud destroy();
}

isonezmround() //checked matches cerberus output
{
	if ( get_game_var( "ZM_roundLimit" ) == 1 )
	{
		return 1;
	}
	return 0;
}

waslastzmround() //checked changed to match cerberus output
{
	if ( is_true( level.forcedend ) )
	{
		return 1;
	}
	if ( hitzmroundlimit() || hitzmscorelimit() || hitzmroundwinlimit() )
	{
		return 1;
	}
	return 0;
}

hitzmroundlimit() //checked matches cerberus output
{
	if ( get_game_var( "ZM_roundLimit" ) <= 0 )
	{
		return 0;
	}
	return getzmroundsplayed() >= get_game_var( "ZM_roundLimit" );
}

hitzmroundwinlimit() //checked matches cerberus output
{
	if ( !isDefined( get_game_var( "ZM_roundWinLimit" ) ) || get_game_var( "ZM_roundWinLimit" ) <= 0 )
	{
		return 0;
	}
	if ( get_gamemode_var( "team_1_score" ) >= get_game_var( "ZM_roundWinLimit" ) || get_gamemode_var( "team_2_score" ) >= get_game_var( "ZM_roundWinLimit" ) )
	{
		return 1;
	}
	if ( get_gamemode_var( "team_1_score" ) >= get_game_var( "ZM_roundWinLimit" ) || get_gamemode_var( "team_2_score" ) >= get_game_var( "ZM_roundWinLimit" ) )
	{
		if ( get_gamemode_var( "team_1_score" ) != get_gamemode_var( "team_2_score" ) )
		{
			return 1;
		}
	}
	return 0;
}

hitzmscorelimit() //checked matches cerberus output
{
	if ( get_game_var( "ZM_scoreLimit" ) <= 0 )
	{
		return 0;
	}
	if ( is_encounter() )
	{
		if ( get_gamemode_var( "team_1_score" ) >= get_game_var( "ZM_scoreLimit" ) || get_gamemode_var( "team_2_score" ) >= get_game_var( "ZM_scoreLimit" ) )
		{
			return 1;
		}
	}
	return 0;
}

getzmroundsplayed() //checked matches cerberus output
{
	return get_gamemode_var( "current_round" );
}

onspawnplayerunified() //checked matches cerberus output
{
	onspawnplayer( 0 );
}

onspawnplayer( predictedspawn ) //fixed checked changed partially to match cerberus output
{
	if ( !isDefined( predictedspawn ) )
	{
		predictedspawn = 0;
	}
	pixbeginevent( "ZSURVIVAL:onSpawnPlayer" );
	self.usingobj = undefined;
	self.is_zombie = 0;
	if ( isDefined( level.custom_spawnplayer ) && is_true( self.player_initialized ) )
	{
		self [[ level.custom_spawnplayer ]]();
		return;
	}
	match_string = "";
	location = level.scr_zm_map_start_location;
	if ( ( location == "default" || location == "" ) && isDefined( level.default_start_location ) )
	{
		location = level.default_start_location;
	}
	match_string = level.scr_zm_ui_gametype + "_" + location;
	spawnpoints = [];
	structs = getstructarray( "initial_spawn", "script_noteworthy" );
	if ( isdefined( structs ) )
	{
		i = 0;
		while ( i < structs.size )
		{
			if ( isdefined( structs[ i ].script_string ) )
			{
				tokens = strtok( structs[ i ].script_string, " " );
				foreach ( token in tokens )
				{
					if ( token == match_string )
					{
						spawnpoints[ spawnpoints.size ] = structs[ i ];
					}
				}
			}
			i++;
		}
	}
	if ( !isDefined( spawnpoints ) || spawnpoints.size == 0 )
	{
		spawnpoints = getstructarray( "initial_spawn_points", "targetname" );
	}	
	level.initial_spawnpoints = spawnpoints;
	spawnpoint = getfreespawnpoint( spawnpoints, self );
	if ( predictedspawn )
	{
		self predictspawnpoint( spawnpoint.origin, spawnpoint.angles );
		return;
	}
	else
	{
		self spawn( spawnpoint.origin, spawnpoint.angles, "zsurvival" );
	}
	self.entity_num = self getentitynumber();
	self thread maps/mp/zombies/_zm::onplayerspawned();
	self thread maps/mp/zombies/_zm::player_revive_monitor();
	self freezecontrols( 1 );
	self.spectator_respawn = spawnpoint;
	self.score = self maps/mp/gametypes_zm/_globallogic_score::getpersstat( "score" );
	self.pers[ "participation" ] = 0;
	
	self.score_total = self.score;
	self.old_score = self.score;
	self.player_initialized = 0;
	self.zombification_time = 0;
	self.enabletext = 1;
	self thread maps/mp/zombies/_zm_blockers::rebuild_barrier_reward_reset();
	if ( !is_true( level.host_ended_game ) )
	{
		self freeze_player_controls( 0 );
		self enableweapons();
	}
	if ( isDefined( level.game_mode_spawn_player_logic ) )
	{
		spawn_in_spectate = [[ level.game_mode_spawn_player_logic ]]();
		if ( spawn_in_spectate )
		{
			self delay_thread( 0.05, maps/mp/zombies/_zm::spawnspectator );
		}
	}
	pixendevent();
}


get_player_spawns_for_gametype() //fixed checked partially changed to match cerberus output
{
	match_string = "";
	location = level.scr_zm_map_start_location;
	if ( ( location == "default" || location == "" ) && isDefined( level.default_start_location ) )
	{
		location = level.default_start_location;
	}
	match_string = level.scr_zm_ui_gametype + "_" + location;
	player_spawns = [];
	structs = getstructarray("player_respawn_point", "targetname");
	i = 0;
	while ( i < structs.size )
	{
		if ( isdefined( structs[ i ].script_string ) )
		{
			tokens = strtok( structs[ i ].script_string, " " );
			foreach ( token in tokens )
			{
				if ( token == match_string )
				{
					player_spawns[ player_spawns.size ] = structs[ i ];
				}
			}
			i++;
			continue;
		}
		player_spawns[ player_spawns.size ] = structs[ i ];
		i++;
	}
	return player_spawns;
}

onendgame( winningteam ) //checked matches cerberus output
{
}

onroundendgame( roundwinner ) //checked matches cerberus output
{
	if ( game[ "roundswon" ][ "allies" ] == game[ "roundswon" ][ "axis" ] )
	{
		winner = "tie";
	}
	else if ( game[ "roundswon" ][ "axis" ] > game[ "roundswon" ][ "allies" ] )
	{
		winner = "axis";
	}
	else
	{
		winner = "allies";
	}
	return winner;
}

menu_init() //checked matches cerberus output
{
	game[ "menu_team" ] = "team_marinesopfor";
	game[ "menu_changeclass_allies" ] = "changeclass";
	game[ "menu_initteam_allies" ] = "initteam_marines";
	game[ "menu_changeclass_axis" ] = "changeclass";
	game[ "menu_initteam_axis" ] = "initteam_opfor";
	game[ "menu_class" ] = "class";
	game[ "menu_changeclass" ] = "changeclass";
	game[ "menu_changeclass_offline" ] = "changeclass";
	game[ "menu_wager_side_bet" ] = "sidebet";
	game[ "menu_wager_side_bet_player" ] = "sidebet_player";
	game[ "menu_changeclass_wager" ] = "changeclass_wager";
	game[ "menu_changeclass_custom" ] = "changeclass_custom";
	game[ "menu_changeclass_barebones" ] = "changeclass_barebones";
	game[ "menu_controls" ] = "ingame_controls";
	game[ "menu_options" ] = "ingame_options";
	game[ "menu_leavegame" ] = "popup_leavegame";
	game[ "menu_restartgamepopup" ] = "restartgamepopup";
	precachemenu( game[ "menu_controls" ] );
	precachemenu( game[ "menu_options" ] );
	precachemenu( game[ "menu_leavegame" ] );
	precachemenu( game[ "menu_restartgamepopup" ] );
	precachemenu( "scoreboard" );
	precachemenu( game[ "menu_team" ] );
	precachemenu( game[ "menu_changeclass_allies" ] );
	precachemenu( game[ "menu_initteam_allies" ] );
	precachemenu( game[ "menu_changeclass_axis" ] );
	precachemenu( game[ "menu_class" ] );
	precachemenu( game[ "menu_changeclass" ] );
	precachemenu( game[ "menu_initteam_axis" ] );
	precachemenu( game[ "menu_changeclass_offline" ] );
	precachemenu( game[ "menu_changeclass_wager" ] );
	precachemenu( game[ "menu_changeclass_custom" ] );
	precachemenu( game[ "menu_changeclass_barebones" ] );
	precachemenu( game[ "menu_wager_side_bet" ] );
	precachemenu( game[ "menu_wager_side_bet_player" ] );
	precachestring( &"MP_HOST_ENDED_GAME" );
	precachestring( &"MP_HOST_ENDGAME_RESPONSE" );
	level thread menu_onplayerconnect();
}

menu_onplayerconnect() //checked matches cerberus output
{
	for ( ;; )
	{
		level waittill( "connecting", player );
		player thread menu_onmenuresponse();
	}
}

menu_onmenuresponse() //checked changed to match cerberus output
{
	self endon( "disconnect" );
	for ( ;; )
	{
		self waittill( "menuresponse", menu, response );
		if ( response == "back" )
		{
			self closemenu();
			self closeingamemenu();
			if ( level.console )
			{
				if ( game[ "menu_changeclass" ] != menu && game[ "menu_changeclass_offline" ] != menu || menu == game[ "menu_team" ] && menu == game[ "menu_controls" ] )
				{
					if ( self.pers[ "team" ] == "allies" )
					{
						self openmenu( game[ "menu_class" ] );
					}
					if ( self.pers[ "team" ] == "axis" )
					{
						self openmenu( game[ "menu_class" ] );
					}
				}
			}
			continue;
		}
		if ( response == "changeteam" && level.allow_teamchange == "1" )
		{
			self closemenu();
			self closeingamemenu();
			self openmenu( game[ "menu_team" ] );
		}
		if ( response == "changeclass_marines" )
		{
			self closemenu();
			self closeingamemenu();
			self openmenu( game[ "menu_changeclass_allies" ] );
			continue;
		}
		if ( response == "changeclass_opfor" )
		{
			self closemenu();
			self closeingamemenu();
			self openmenu( game[ "menu_changeclass_axis" ] );
			continue;
		}
		if ( response == "changeclass_wager" )
		{
			self closemenu();
			self closeingamemenu();
			self openmenu( game[ "menu_changeclass_wager" ] );
			continue;
		}
		if ( response == "changeclass_custom" )
		{
			self closemenu();
			self closeingamemenu();
			self openmenu( game[ "menu_changeclass_custom" ] );
			continue;
		}
		if ( response == "changeclass_barebones" )
		{
			self closemenu();
			self closeingamemenu();
			self openmenu( game[ "menu_changeclass_barebones" ] );
			continue;
		}
		if ( response == "changeclass_marines_splitscreen" )
		{
			self openmenu( "changeclass_marines_splitscreen" );
		}
		if ( response == "changeclass_opfor_splitscreen" )
		{
			self openmenu( "changeclass_opfor_splitscreen" );
		}
		if ( response == "endgame" )
		{
			if ( self issplitscreen() )
			{
				level.skipvote = 1;
				if ( is_true( level.gameended ) )
				{
					self maps/mp/zombies/_zm_laststand::add_weighted_down();
					self maps/mp/zombies/_zm_stats::increment_client_stat( "deaths" );
					self maps/mp/zombies/_zm_stats::increment_player_stat( "deaths" );
					self maps/mp/zombies/_zm_pers_upgrades_functions::pers_upgrade_jugg_player_death_stat();
					level.host_ended_game = 1;
					maps/mp/zombies/_zm_game_module::freeze_players( 1 );
					level notify( "end_game" );
				}
			}
			continue;
		}
		if ( response == "restart_level_zm" )
		{
			self maps/mp/zombies/_zm_laststand::add_weighted_down();
			self maps/mp/zombies/_zm_stats::increment_client_stat( "deaths" );
			self maps/mp/zombies/_zm_stats::increment_player_stat( "deaths" );
			self maps/mp/zombies/_zm_pers_upgrades_functions::pers_upgrade_jugg_player_death_stat();
			missionfailed();
		}
		if ( response == "killserverpc" )
		{
			level thread maps/mp/gametypes_zm/_globallogic::killserverpc();
			continue;
		}
		if ( response == "endround" )
		{
			if ( is_true( level.gameended ) )
			{
				self maps/mp/gametypes_zm/_globallogic::gamehistoryplayerquit();
				self maps/mp/zombies/_zm_laststand::add_weighted_down();
				self closemenu();
				self closeingamemenu();
				level.host_ended_game = 1;
				maps/mp/zombies/_zm_game_module::freeze_players( 1 );
				level notify( "end_game" );
			}
			else
			{
				self closemenu();
				self closeingamemenu();
				self iprintln( &"MP_HOST_ENDGAME_RESPONSE" );
			}
			continue;
		}
		if ( menu == game[ "menu_team" ] && level.allow_teamchange == "1" )
		{
			switch( response )
			{
				case "allies":
					self [[ level.allies ]]();
					break;
				case "axis":
					self [[ level.teammenu ]]( response );
					break;
				case "autoassign":
					self [[ level.autoassign ]]( 1 );
					break;
				case "spectator":
					self [[ level.spectator ]]();
					break;
			}
			continue;
		}
		else
		{
			if ( game[ "menu_changeclass" ] != menu && game[ "menu_changeclass_offline" ] != menu && game[ "menu_changeclass_wager" ] != menu || menu == game[ "menu_changeclass_custom" ] && menu == game[ "menu_changeclass_barebones" ] )
			{
				self closemenu();
				self closeingamemenu();
				if ( level.rankedmatch && issubstr( response, "custom" ) )
				{
				}
				self.selectedclass = 1;
				self [[ level.class ]]( response );
			}
		}
	}
}


menuallieszombies() //checked changed to match cerberus output
{
	self maps/mp/gametypes_zm/_globallogic_ui::closemenus();
	if ( !level.console && level.allow_teamchange == "0" && is_true( self.hasdonecombat ) )
	{
		return;
	}
	if ( self.pers[ "team" ] != "allies" )
	{
		if ( level.ingraceperiod && !isDefined( self.hasdonecombat ) || !self.hasdonecombat )
		{
			self.hasspawned = 0;
		}
		if ( self.sessionstate == "playing" )
		{
			self.switching_teams = 1;
			self.joining_team = "allies";
			self.leaving_team = self.pers[ "team" ];
			self suicide();
		}
		self.pers["team"] = "allies";
		self.team = "allies";
		self.pers["class"] = undefined;
		self.class = undefined;
		self.pers["weapon"] = undefined;
		self.pers["savedmodel"] = undefined;
		self updateobjectivetext();
		if ( level.teambased )
		{
			self.sessionteam = "allies";
		}
		else
		{
			self.sessionteam = "none";
			self.ffateam = "allies";
		}
		self setclientscriptmainmenu( game[ "menu_class" ] );
		self notify( "joined_team" );
		level notify( "joined_team" );
		self notify( "end_respawn" );
	}
}


custom_spawn_init_func() //checked matches cerberus output
{
	array_thread( level.zombie_spawners, ::add_spawn_function, maps/mp/zombies/_zm_spawner::zombie_spawn_init );
	array_thread( level.zombie_spawners, ::add_spawn_function, level._zombies_round_spawn_failsafe );
}

kill_all_zombies() //changed to match cerberus output
{
	ai = getaiarray( level.zombie_team );
	foreach ( zombie in ai )
	{
		if ( isdefined( zombie ) )
		{
			zombie dodamage( zombie.maxhealth * 2, zombie.origin, zombie, zombie, "none", "MOD_SUICIDE" );
			wait 0.05;
		}
	}
}

init() //checked matches cerberus output
{

	flag_init( "pregame" );
	flag_set( "pregame" );
	level thread onplayerconnect();
}

onplayerconnect() //checked matches cerberus output
{
	for ( ;; )
	{
		level waittill( "connected", player );
		player thread onplayerspawned();
		if ( isDefined( level.game_module_onplayerconnect ) )
		{
			player [[ level.game_module_onplayerconnect ]]();
		}
	}
}

onplayerspawned() //checked partially changed to cerberus output
{
	level endon( "end_game" );
	self endon( "disconnect" );
	for ( ;; )
	{
		self waittill_either( "spawned_player", "fake_spawned_player" );
		if ( isDefined( level.match_is_ending ) && level.match_is_ending )
		{
			return;
		}
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
		if ( is_encounter() )
		{
			if ( self.team == "axis" )
			{
				self.characterindex = 0;
				self._encounters_team = "A";
				self._team_name = &"ZOMBIE_RACE_TEAM_1";
			}
			else
			{
				self.characterindex = 1;
				self._encounters_team = "B";
				self._team_name = &"ZOMBIE_RACE_TEAM_2";
			}
		}
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

wait_for_players() //checked matches cerberus output
{
	level endon( "end_race" );
	if ( getDvarInt( "party_playerCount" ) == 1 )
	{
		flag_wait( "start_zombie_round_logic" );
		return;
	}
	while ( !flag_exists( "start_zombie_round_logic" ) )
	{
		wait 0.05;
	}
	while ( !flag( "start_zombie_round_logic" ) && isDefined( level._module_connect_hud ) )
	{
		level._module_connect_hud.alpha = 0;
		level._module_connect_hud.sort = 12;
		level._module_connect_hud fadeovertime( 1 );
		level._module_connect_hud.alpha = 1;
		wait 1.5;
		level._module_connect_hud fadeovertime( 1 );
		level._module_connect_hud.alpha = 0;
		wait 1.5;
	}
	if ( isDefined( level._module_connect_hud ) )
	{
		level._module_connect_hud destroy();
	}
}

onplayerconnect_check_for_hotjoin() //checked matches cerberus output
{
/*
/#
	if ( getDvarInt( #"EA6D219A" ) > 0 )
	{
		return;
#/
	}
*/
	map_logic_exists = level flag_exists( "start_zombie_round_logic" );
	map_logic_started = flag( "start_zombie_round_logic" );
	if ( map_logic_exists && map_logic_started )
	{
		self thread hide_gump_loading_for_hotjoiners();
	}
}

hide_gump_loading_for_hotjoiners() //checked matches cerberus output
{
	self endon( "disconnect" );
	self.rebuild_barrier_reward = 1;
	self.is_hotjoining = 1;
	num = self getsnapshotackindex();
	while ( num == self getsnapshotackindex() )
	{
		wait 0.25;
	}
	wait 0.5;
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

blank()
{
	//empty function
}

set_location_ents()
{
	ents = getEntArray();
	door_ents = getEntArray( "zombie_door", "targetname" );
	switch ( getdvar( "ui_zm_mapstartlocation" ) )
	{  
		case "power":
			foreach ( door in door_ents )
			{
				if ( door.script_noteworthy == "electric_door" )
				{
					door.script_noteworthy = "electric_buyable_door";
					door.marked_for_deletion = 0;
				}
			}
			break;
		case "diner":
			diner_hatch = getent( "diner_hatch", "targetname" );
			diner_hatch.script_gameobjectname = "zclassic zstandard zgrief";
			diner_hatch_mantle = getent( "diner_hatch_mantle", "targetname" );
			diner_hatch_mantle.script_gameobjectname = "zclassic zstandard zgrief";
			gameObjects = getEntArray( "script_model", "classname" );
			foreach ( object in gameObjects )
			{
				if ( object.script_gameobjectname == "zcleansed zturned" )
				{
					object.script_gameobjectname = "zstandard zgrief zcleansed zturned";
				}
			} 
			break;
		case "tunnel":
			break;
		case "cornfield":
			break;
	}
	/*
	ents = getEntArray();
	foreach ( ent in ents )
	{
		if ( is_true( ent.marked_for_deletion ) )
		{
			ent delete();
		}
	}
	*/
}

location_common_ent_deletion()
{

}

getfreespawnpoint( spawnpoints, player ) //checked changed to match cerberus output
{
	assign_spawnpoints_player_data( spawnpoints, player );
	for ( j = 0; j < spawnpoints.size; j++ )
	{
		if ( spawnpoints[ j ].player_property == player.name )
		{
			return spawnpoints[ j ];
		}
	}
}

assign_spawnpoints_player_data( spawnpoints, player )
{
	remove_disconnected_players_spawnpoint_property( spawnpoints );
	for ( i = 0; i < spawnpoints.size; i++ )
	{
		if ( spawnpoints[ i ].player_property == "" )
		{
			spawnpoints[ i ].player_property = player.name;
			break;
		}
	}
}

remove_disconnected_players_spawnpoint_property( spawnpoints )
{
	for ( i = 0; i < spawnpoints.size; i++ )
	{
		spawnpoints[ i ].do_not_discard_player_property = false;
	}
	players = getPlayers();
	for ( i = 0; i < spawnpoints.size; i++ )
	{
		if ( isDefined( spawnpoints[ i ].player_property ) )
		{
			for ( j = 0; j < players.size; j++ )
			{
				if ( spawnpoints[ i ].player_property == players[ j ].name )
				{
					spawnpoints[ i ].do_not_discard_player_property = true;
					break;
				}
			}
		}
	}
	for ( i = 0; i < spawnpoints.size; i++ )
	{
		if ( !spawnpoints[ i ].do_not_discard_player_property )
		{
			spawnpoints[ i ].player_property = "";
		}
	}
}

grief_spectator_respawn() //checked changed to match cerberus output
{
	origin = self.spectator_respawn.origin;
	angles = self.spectator_respawn.angles;
	self setspectatepermissions( 0 );
	self spawn( origin, angles );
	if ( isDefined( self get_player_placeable_mine() ) )
	{
		self takeweapon( self get_player_placeable_mine() );
		self set_player_placeable_mine( undefined );
	}
	self maps/mp/zombies/_zm_equipment::equipment_take();
	self.is_burning = undefined;
	self.abilities = [];
	self.is_zombie = 0;
	self.ignoreme = 0;
	setclientsysstate( "lsm", "0", self );
	self reviveplayer();
	self notify( "spawned_player" );
	if ( isDefined( level._zombiemode_post_respawn_callback ) )
	{
		self thread [[ level._zombiemode_post_respawn_callback ]]();
	}
	self maps/mp/zombies/_zm_score::player_reduce_points( "died" );
	self maps/mp/zombies/_zm_melee_weapon::spectator_respawn_all();
	claymore_triggers = getentarray( "claymore_purchase", "targetname" );
	i = 0;
	while ( i < claymore_triggers.size )
	{
		claymore_triggers[ i ] setvisibletoplayer( self );
		claymore_triggers[ i ].claymores_triggered = 0;
		i++;
	}
	self thread player_zombie_breadcrumb();
	self thread return_retained_perks();
	return 1;
}


set_run_speed_override() //checked matches cerberus output
{
	if ( !isDefined( level.bus_sprinters ) )
	{
		level.bus_sprinters = 0;
		level.bus_sprinter_max = 1;
		logline1 = "level.bus_sprinters initialized" + "\n";
		logprint( logline1 );
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

manage_zones_override( initial_zone ) //checked changed to match cerberus output
{
	//printF( "manage_zones_override() overrides manage_zones()" );
	map = getDvar( "mapname" );
	location = getDvar( "ui_zm_mapstartlocation" ); 
	if ( map == "zm_transit" )
	{
		if ( location == "diner" || location == "cornfield" || location == "power" || location == "tunnel" )
		{
			initial_zone = [];
			initial_zone[ 0 ] = "zone_pri";
			initial_zone[ 1 ] = "zone_station_ext";
			initial_zone[ 2 ] = "zone_tow";
			initial_zone[ 3 ] = "zone_far_ext";
			initial_zone[ 4 ] = "zone_brn";
			//Initialize cut location zones
			////////////////////////////////////
			initial_zone[ 5 ] = "zone_pow";
			initial_zone[ 6 ] = "zone_pow_warehouse";
			initial_zone[ 7 ] = "zone_amb_tunnel";
			////////////////////////////////////
		}
	}
	deactivate_initial_barrier_goals();
	zone_choke = 0;
	spawn_points = maps/mp/gametypes_zm/_zm_gametype::get_player_spawns_for_gametype();
	for ( i = 0; i < spawn_points.size; i++ )
	{
		spawn_points[ i ].locked = 1;
	}
	if ( isDefined( level.zone_manager_init_func ) )
	{
		[[ level.zone_manager_init_func ]]();
	}

	if ( isarray( initial_zone ) )
	{
		for ( i = 0; i < initial_zone.size; i++ )
		{
			zone_init( initial_zone[ i ] );
			enable_zone( initial_zone[ i ] );
		}
	}
	else
	{
		zone_init( initial_zone );
		enable_zone( initial_zone );
	}
	setup_zone_flag_waits();
	zkeys = getarraykeys( level.zones );
	level.zone_keys = zkeys;
	level.newzones = [];
	for ( z = 0; z < zkeys.size; z++ )
	{
		level.newzones[ zkeys[ z ] ] = spawnstruct();
	}
	oldzone = undefined;
	flag_set( "zones_initialized" );
	flag_wait( "begin_spawning" );
	while ( getDvarInt( "noclip" ) == 0 || getDvarInt( "notarget" ) != 0 )
	{	
		for( z = 0; z < zkeys.size; z++ )
		{
			level.newzones[ zkeys[ z ] ].is_active = 0;
			level.newzones[ zkeys[ z ] ].is_occupied = 0;
		}
		a_zone_is_active = 0;
		a_zone_is_spawning_allowed = 0;
		level.zone_scanning_active = 1;
		z = 0;
		while ( z < zkeys.size )
		{
			zone = level.zones[ zkeys[ z ] ];
			newzone = level.newzones[ zkeys[ z ] ];
			if( !zone.is_enabled )
			{
				z++;
				continue;
			}
			if ( isdefined(level.zone_occupied_func ) )
			{
				newzone.is_occupied = [[ level.zone_occupied_func ]]( zkeys[ z ] );
			}
			else
			{
				newzone.is_occupied = player_in_zone( zkeys[ z ] );
			}
			if ( newzone.is_occupied )
			{
				newzone.is_active = 1;
				a_zone_is_active = 1;
				if ( zone.is_spawning_allowed )
				{
					a_zone_is_spawning_allowed = 1;
				}
				if ( !isdefined(oldzone) || oldzone != newzone )
				{
					level notify( "newzoneActive", zkeys[ z ] );
					oldzone = newzone;
				}
				azkeys = getarraykeys( zone.adjacent_zones );
				for ( az = 0; az < zone.adjacent_zones.size; az++ )
				{
					if ( zone.adjacent_zones[ azkeys[ az ] ].is_connected && level.zones[ azkeys[ az ] ].is_enabled )
					{
						level.newzones[ azkeys[ az ] ].is_active = 1;
						if ( level.zones[ azkeys[ az ] ].is_spawning_allowed )
						{
							a_zone_is_spawning_allowed = 1;
						}
					}
				}
			}
			zone_choke++;
			if ( zone_choke >= 3 )
			{
				zone_choke = 0;
				wait 0.05;
			}
			z++;
		}
		level.zone_scanning_active = 0;
		for ( z = 0; z < zkeys.size; z++ )
		{
			level.zones[ zkeys[ z ] ].is_active = level.newzones[ zkeys[ z ] ].is_active;
			level.zones[ zkeys[ z ] ].is_occupied = level.newzones[ zkeys[ z ] ].is_occupied;
		}
		if ( !a_zone_is_active || !a_zone_is_spawning_allowed )
		{
			if ( isarray( initial_zone ) )
			{
				level.zones[ initial_zone[ 0 ] ].is_active = 1;
				level.zones[ initial_zone[ 0 ] ].is_occupied = 1;
				level.zones[ initial_zone[ 0 ] ].is_spawning_allowed = 1;
			}
			else
			{
				level.zones[ initial_zone ].is_active = 1;
				level.zones[ initial_zone ].is_occupied = 1;
				level.zones[ initial_zone ].is_spawning_allowed = 1;
			}
		}
		[[ level.create_spawner_list_func ]]( zkeys );
		level.active_zone_names = maps/mp/zombies/_zm_zonemgr::get_active_zone_names();
		wait 1;
	}
}

playleaderdialogonplayer_override( dialog, team, waittime ) //checked changed to match cerberus output
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

treasure_chest_init_override( start_chest_name ) //checked changed to match cerberus output
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

kill_all_zombies_override() //checked changed to match cerberus output
{
	ai = get_round_enemy_array();
	foreach ( zombie in ai )
	{
		if ( isDefined( zombie ) )
		{
			zombie dodamage( zombie.maxhealth * 2, zombie.origin, zombie, zombie, "none", "MOD_SUICIDE" );
			level.zombie_total++;
		}
	}
}

respawn_players_override() //checked changed to match cerberus output
{
	players = get_players();
	foreach ( player in players )
	{
		if ( player.sessionstate == "spectator" || player player_is_in_laststand() )
		{
			player [[ level.spawnplayer ]]();
		}
		else if ( !is_true( level.initial_spawn_players ) )
		{
			player [[ level.spawnplayer ]]();
			player freeze_player_controls( 1 );
		}
	}
}

wait_for_team_death_and_round_end_override() //checked partially changed to match cerberus output //did not use foreach with continue to prevent continue bug
{
	//printF( "wait_for_team_death_and_round_end_override() ")
	level endon( "game_module_ended" );
	level endon( "end_game" );
	level endon( "restart_round_check" );
	if ( !isDefined( level.initial_spawn_players ) )
	{
		promod_wait_for_players();
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
			//level notify( "stop_round_end_check" );
			level.checking_for_round_end = 0;
		}
		wait 0.05;
	}
}

check_for_round_end_override( winner )
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
		logline1 = "MAP:" + mapname + ";W:" + winner + ";WTS:" + winning_team_size + ";L:" + loser + ";LTS:" + losing_team_size + ";ML:" + match_length + ";D:" + time() + "\n";
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

struct_class_init_override()
{
	level.struct_class_names = [];
	level.struct_class_names[ "target" ] = [];
	level.struct_class_names[ "targetname" ] = [];
	level.struct_class_names[ "script_noteworthy" ] = [];
	level.struct_class_names[ "script_linkname" ] = [];
	level.struct_class_names[ "script_unitrigger_type" ] = [];
    foreach ( s_struct in level.struct )
    {
		if ( isDefined( s_struct.targetname ) )
		{
			if ( !isDefined( level.struct_class_names[ "targetname" ][ s_struct.targetname ] ) )
			{
				level.struct_class_names[ "targetname" ][ s_struct.targetname ] = [];
			}
			size = level.struct_class_names[ "targetname" ][ s_struct.targetname ].size;
			level.struct_class_names[ "targetname" ][ s_struct.targetname ][ size ] = s_struct;
		}
		if ( isDefined( s_struct.target ) )
		{
			if ( !isDefined( level.struct_class_names[ "target" ][ s_struct.target ] ) )
			{
				level.struct_class_names[ "target" ][ s_struct.target ] = [];
			}
			size = level.struct_class_names[ "target" ][ s_struct.target ].size;
			level.struct_class_names[ "target" ][ s_struct.target ][ size ] = s_struct;
		}
		if ( isDefined( s_struct.script_noteworthy ) )
		{
			if ( !isDefined( level.struct_class_names[ "script_noteworthy" ][ s_struct.script_noteworthy ] ) )
			{
				level.struct_class_names[ "script_noteworthy" ][ s_struct.script_noteworthy ] = [];
			}
			size = level.struct_class_names[ "script_noteworthy" ][ s_struct.script_noteworthy ].size;
			level.struct_class_names[ "script_noteworthy" ][ s_struct.script_noteworthy ][ size ] = s_struct;
		}
		if ( isDefined( s_struct.script_linkname ) )
		{
			level.struct_class_names[ "script_linkname" ][ s_struct.script_linkname ][ 0 ] = s_struct;
		}
		if ( isDefined( s_struct.script_unitrigger_type ) )
		{
			if ( !isDefined( level.struct_class_names[ "script_unitrigger_type" ][ s_struct.script_unitrigger_type ] ) )
			{
				level.struct_class_names[ "script_unitrigger_type" ][ s_struct.script_unitrigger_type ] = [];
			}
			size = level.struct_class_names[ "script_unitrigger_type" ][ s_struct.script_unitrigger_type ].size;
			level.struct_class_names[ "script_unitrigger_type" ][ s_struct.script_unitrigger_type ][ size ] = s_struct;
		}
	}
	grief_add_structs();
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

get_mapname()
{
	switch ( getDvar( "ui_zm_mapstartlocation" ) )
	{
		case "transit":
			return "Bus Depot";
		case "town":
			return "Town";
		case "farm":
			return "Farm";
		case "diner":
			return "Diner";
		case "Power":
			return "Power";
		case "cornfield":
			return "Cornfield";
		case "Tunnel":
			return "Tunnel";
		case "cellblock":
			return "Cellblock";
		case "street":
			return "Buried";
	}
	return "NULL";
}

get_loser( winner )
{
	if ( winner == "A" )
	{
		return "B";
	}
	return "A";
} 

grief_team_forfeits()
{
	if ( getDvarInt( "grief_testing" ) == 1 )
	{
		return 0;
	}
	if ( ( getPlayers( "axis" ).size == 0 ) || ( getPlayers( "allies" ).size == 0 ) )
	{
		logline1 = "other team forfeited" + "\n";
		logprint( logline1 );
		return 1;
	}
	return 0;
}

grief_save_loadouts2()
{
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

team_suicide_check()
{
	wait level.grief_gamerules[ "suicide_check" ];
}

promod_wait_for_players()
{
	level endon( "end_game" );
	flag_clear( "spawn_zombies" );
	level.initial_spawn_players = true;
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
	if ( getDvarInt( "grief_tournament_mode" ) == 1 )
	{
		players = getPlayers();
		while ( getDvarInt( "zombies_minplayers" ) > players.size )
		{
			players = getPlayers();
			for ( i = 0; i < players.size; i++ )
			{
				players[ i ] iPrintLn( "Waiting for all players to connect" );
			}
			wait 1;
		}
	}
	level notify( "grief_begin" );
	flag_set( "spawn_zombies" );
	respawn_players();
	level.initial_spawn_players = false;
}

make_super_sprinter( special_movespeed )
{
	self.zombie_move_speed = "sprint";
	while ( 1 )
	{
		if ( self in_enabled_playable_area() )
		{
			self.zombie_move_speed = special_movespeed;
			self notify( "zombie_movespeed_set" );
			break;
		}
		wait 0.05;
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

grief_add_structs()
{
	map = getDvar( "mapname" );
	location = getDvar( "ui_zm_mapstartlocation" ); 
	register_spawnpoint_structs();
	register_perk_structs();
	if ( map == "zm_transit" )
	{
		if ( location == "diner" || location == "cornfield" || location == "power" || location == "tunnel" )
		{
			level.trash_spawns = getDvarIntDefault( "grief_use_trash_spawns_power", 0 );
		}
		if ( getDvar( "grief_perk_location_override" ) != "" )
		{
			perks_moved = [];
			perk_keys = strTok( getDvar( "grief_perk_location_override" ), " " );
			for ( i = 0; i < perk_keys.size; i++ )
			{
				if ( perk_keys[ i ] == "location" )
				{
					location = perk_keys[ i + 1 ];
					if ( !isDefined( perks_index ) )
					{
						perks_index = 0;
					}
					else 
					{
						perks_index++;
					}
				}
				if ( location != getDvar( "ui_zm_mapstartlocation" ) )
				{
				}
				else 
				{
					if ( perk_keys[ i ] == "perk" )
					{
						perks_moved[ perks_index ] = spawnStruct();
						perks_moved[ perks_index ].perk = perk_keys[ i + 1 ];
						logprint( "perks_moved array: index " + perks_index + " perks_moved array: perk " + perks_moved[ perks_index ].perk + "\n" );
					}
					else if ( perk_keys[ i ] == "origin" )
					{
						perks_moved[ perks_index ].origin = cast_to_vector( perk_keys[ i + 1 ] );
						logprint( "perks_moved array: index " + perks_index + " perks_moved array: origin " + perks_moved[ perks_index ].origin + "\n" );
					}
					else if ( perk_keys[ i ] == "angles" )
					{
						perks_moved[ perks_index ].angles = cast_to_vector( perk_keys[ i + 1 ] );
						logprint( "perks_moved array: index " + perks_index + " perks_moved array: angles " + perks_moved[ perks_index ].angles + "\n" );
					}
				}
			}
			perks_location = "zgrief_perks_" + location;
			for ( i = 0; i < level.struct_class_names[ "targetname" ][ "zm_perk_machine" ].size; i++ )
			{
				for ( j = 0; j < perks_moved.size; j++ )
				{
					script_string_locations = strTok( level.struct_class_names[ "targetname" ][ "zm_perk_machine" ][ i ].script_string, " " );
					for ( k = 0; k < script_string_locations.size; k++ )
					{
						if ( level.struct_class_names[ "targetname" ][ "zm_perk_machine" ][ i ].script_noteworthy == perks_moved[ j ].perk && script_string_locations[ k ] == perks_location )
						{
							level.struct_class_names[ "targetname" ][ "zm_perk_machine" ][ i ].origin = perks_moved[ j ].origin;
							level.struct_class_names[ "targetname" ][ "zm_perk_machine" ][ i ].angles = perks_moved[ j ].angles;

							logprint( "perks_moved array: index " + j + " perks_moved array: perk " + perks_moved[ j ].perk + "\n" );
							logprint( "perks_moved array: index " + j + " perks_moved array: origin " + perks_moved[ j ].origin + "\n" );
							logprint( "perks_moved array: index " + j + " perks_moved array: angles " + perks_moved[ j ].angles + "\n" );
						}
					}
				}
			}
		}
	}
}

register_perk_structs()
{
	switch ( getDvar( "ui_zm_mapstartlocation" ) )
	{
		case "diner":
			_register_survival_perk( "specialty_armorvest", "zombie_vending_jugg", ( 0, 176, 0 ), ( -3634, -7464, -58 ) );
			_register_survival_perk( "specialty_rof", "zombie_vending_doubletap2", ( 0, -90, 0 ), ( -4170, -7610, -61 ) );
			_register_survival_perk( "specialty_longersprint", "zombie_vending_marathon", ( 0, 4, 0 ), ( -4576, -6704, -61 ) );
			_register_survival_perk( "specialty_scavenger", "zombie_vending_tombstone", ( 0, 90, 0 ), ( -6496, -7691, 0 ) );
			_register_survival_perk( "specialty_weapupgrade", "p6_anim_zm_buildable_pap_on", ( 0, 175, 0 ), ( -6351, -7778, 227 ) );
			_register_survival_perk( "specialty_quickrevive", "zombie_vending_quickrevive", ( 0, 137, 0 ), ( -5424, -7920, -64 ) );
			_register_survival_perk( "specialty_fastreload", "zombie_vending_sleight", ( 0, 270, 0 ), ( -5470, -7859.5, 0 ) );
			break;
		case "tunnel":
			_register_survival_perk( "specialty_armorvest", "zombie_vending_jugg", ( 0, -180, 0 ), ( -11541, -2630, 194 ) );
			_register_survival_perk( "specialty_rof", "zombie_vending_doubletap2", ( 0, -10, 0 ), ( -11170, -590, 196 ) );
			_register_survival_perk( "specialty_longersprint", "zombie_vending_marathon", ( 0, -19, 0 ), ( -11681, -734, 228 ) );
			_register_survival_perk( "specialty_scavenger", "zombie_vending_tombstone", ( 0, -98, 0 ), ( -10664, -757, 196 ) );
			_register_survival_perk( "specialty_weapupgrade", "p6_anim_zm_buildable_pap_on", ( 0, 115, 0 ), ( -11301, -2096, 184 ) );
			_register_survival_perk( "specialty_quickrevive", "zombie_vending_quickrevive", ( 0, 270, 0 ), ( -10780, -2565, 224 ) );
			_register_survival_perk( "specialty_fastreload", "zombie_vending_sleight", ( 0, -89, 0 ), ( -11373, -1674, 192 ) );
			break;
		case "power":
			_register_survival_perk( "specialty_armorvest", "zombie_vending_jugg", ( 0, -132, 0 ), ( 10746, 7282, -557 ) );
			_register_survival_perk( "specialty_rof", "zombie_vending_doubletap2", ( 0, 180, 0 ), ( 11402, 8159, -487 ) );
			_register_survival_perk( "specialty_longersprint", "zombie_vending_marathon", ( 0, -35, 0 ), ( 10856, 7879, -576 ) );
			_register_survival_perk( "specialty_quickrevive", "zombie_vending_quickrevive", ( 0, 270, 0 ), ( 10946, 8308.77, -408 ) );
			_register_survival_perk( "specialty_weapupgrade", "p6_anim_zm_buildable_pap_on", ( 0, 162, 0 ), ( 12625, 7434, -755 ) );
			_register_survival_perk( "specialty_scavenger", "zombie_vending_tombstone", ( 0, -4, 0 ), ( 11156, 8120, -575 ) );
			_register_survival_perk( "specialty_fastreload", "zombie_vending_sleight", ( 0, -1, 0 ), ( 11568, 7723, -755 ) );
			break;
		case "cornfield":
			_register_survival_perk( "specialty_armorvest", "zombie_vending_jugg", ( 0, 179, 0 ), ( 13936, -649, -189 ) );
			_register_survival_perk( "specialty_rof", "zombie_vending_doubletap2", ( 0, -137, 0 ), ( 12052, -1943, -160 ) );
			_register_survival_perk( "specialty_longersprint", "zombie_vending_marathon", ( 0, -35, 0 ), ( 9944, -725, -211 ) );
			_register_survival_perk( "specialty_scavenger", "zombie_vending_tombstone", ( 0, 133, 0 ), ( 13551, -1384, -188 ) );
			_register_survival_perk( "specialty_weapupgrade", "p6_anim_zm_buildable_pap_on", ( 0, 123, 0), ( 9960, -1288, -217 ) );
			_register_survival_perk( "specialty_quickrevive", "zombie_vending_quickrevive", ( 0, -90, 0 ), ( 7831, -464, -203 ) );
			_register_survival_perk( "specialty_fastreload", "zombie_vending_sleight", ( 0, -4, 0 ), ( 13255, 74, -195 ) );
			break;
		case "cellblock":
			_register_survival_perk( "specialty_armorvest", "zombie_vending_jugg", ( 0, 86, 0 ), ( 1403, 9662, 1336 ) );
			break;
		case "transit":
			_register_survival_perk( "specialty_armorvest", "zombie_vending_jugg", ( 0, -5, 0), ( -6136, 5590, -63.85 ) );
			break;
	}
}

_register_survival_perk( perk_name, perk_model, perk_angles, perk_coordinates )
{
	if ( getDvar( "g_gametype" ) == "zgrief" && perk_name == "specialty_scavenger" )
	{
		return;
	}
	perk_struct = spawnStruct();
	perk_struct.script_noteworthy = perk_name;
	perk_struct.model = perk_model;
	perk_struct.angles = perk_angles;
	perk_struct.origin = perk_coordinates;
	//perk_struct.script_string = _get_perk_script_string_for_location( getDvar( "ui_zm_mapstartlocation" ), getDvar( "g_gametype") );
	perk_struct.targetname = "zm_perk_machine";
	struct_size = level.struct_class_names[ "targetname" ][ "zm_perk_machine" ].size;
	level.struct_class_names[ "targetname" ][ "zm_perk_machine" ][ struct_size ] = perk_struct;
}

_get_perk_script_string_for_location( location, gametype )
{ 
	string = gametype + "_" + "perks" + "_" + location;
	return string;
}

register_spawnpoint_structs() //custom function
{
	switch ( getDvar( "ui_zm_mapstartlocation" ) )
	{
		case "tunnel":
			coordinates = array( ( -11196, -837, 192 ), ( -11386, -863, 192 ), ( -11405, -1000, 192 ), ( -11498, -1151, 192 ),
									( -11398, -1326, 191 ), ( -11222, -1345, 192 ), ( -10934, -1380, 192 ), ( -10999, -1072, 192 ) );
			angles = array( ( 0, -94, 0 ), ( 0, -44, 0 ), ( 0, -32, 0 ), ( 0, 4, 0 ), ( 0, 50, 0 ), ( 0, 157, 0 ), ( 0, -144, 0 ) );		
			break;
		case "diner":
			coordinates = array( ( -3991, -7317, -63 ), ( -4231, -7395, -60 ), ( -4127, -6757, -54 ), ( -4465, -7346, -58 ),
									( -5770, -6600, -55 ), ( -6135, -6671, -56 ), ( -6182, -7120, -60 ), ( -5882, -7174, -61 ) );
			angles = array( ( 0, 161, 0 ), ( 0, 120, 0 ), ( 0, 217, 0 ), ( 0, 173, 0 ), ( 0, -106, 0 ), ( 0, -46, 0 ), ( 0, 51, 0 ), ( 0, 99, 0 ) );
			break;
		case "cornfield":
			coordinates = array( ( 7521, -545, -198 ), ( 7751, -522, -202 ), ( 7691, -395, -201 ), ( 7536, -432, -199 ), 
									( 13745, -336, -188 ), ( 13758, -681, -188 ), ( 13816, -1088, -189 ), ( 13752, -1444, -182 ) );
			angles = array( ( 0, 40, 0 ), ( 0, 145, 0 ), ( 0, -131, 0 ), ( 0, -24, 0 ), ( 0, -178, 0 ), ( 0, -179, 0 ), ( 0, -177, 0 ), ( 0, -177, 0 ) );
			break;
		case "power":
			if ( !is_true( level.trash_spawns ) )
			{
				coordinates = array( ( 11288, 7988, -550 ), ( 11284, 7760, -549 ), ( 10784, 7623, -584 ), ( 10866, 7473, -580 ),
									( 10261, 8146, -580 ), ( 10595, 8055, -541 ), ( 10477, 7679, -567 ), ( 10165, 7879, -570 ) );
				angles = array( ( 0, -137, 0 ), ( 0, 177, 0 ), ( 0, -10, 0 ), ( 0, 21, 0 ), ( 0, -31, 0 ), ( 0, -43, 0 ), ( 0, -9, 0 ), ( 0, -15, 0 ) );
			}
			else 
			{
				coordinates = array( ( 11257, 8233, -487 ), ( 11403, 8245, -487 ), ( 11381, 8374, -487), ( 11269, 8360, -487 ),
									( 10871, 8433, -407 ), ( 10852, 8230, -407 ), ( 10641, 8228, -407 ), ( 10655, 8431, -407 ) );
				angles = array( ( 0, -137, 0 ), ( 0, 177, 0 ), ( 0, -10, 0 ), ( 0, 21, 0 ), ( 0, -31, 0 ), ( 0, -43, 0 ), ( 0, -9, 0 ), ( 0, -15, 0 ) );
			}
			break;
		case "cellblock":
			coordinates = array( ( 1422, 9597, 1336 ), ( 1432, 9745, 1336 ), ( 2154, 9062, 1336 ), ( 1969, 9950, 1336 ),
								  ( 2150, 9496, 1336 ), ( 2144, 9931, 1336 ), ( 1665, 9053, 1336 ), ( 1661, 9211, 1336 ) );
			angles = array( ( 0, 0, 0 ), ( 0, 0, 0 ), ( 0, 180, 0 ), ( 0, 0, 0 ),
							( 0, 180, 0 ), ( 0, 180, 0), ( 0, 0, 0 ), ( 0, 0, 0) );
			break;
	}
	if ( getDvar( "ui_zm_mapstartlocation" ) == "cellblock" )
	{
		level.struct_class_names[ "targetname" ][ "player_respawn_point" ] = [];
		level.struct_class_names[ "script_noteworthy" ][ "initial_spawn" ] = [];
	} 
	for ( i = 0; i < 8; i++ )
	{
		if ( isDefined( angles ) )
		{
			_register_map_initial_spawnpoint( coordinates[ i ], angles[ i ] );
		}
		else 
		{
			_register_map_initial_spawnpoint( coordinates[ i ], undefined );
		}

	}
}

_register_map_initial_spawnpoint( spawnpoint_coordinates, spawnpoint_angles ) //custom function
{
	spawnpoint_struct = spawnStruct();
	spawnpoint_struct.origin = spawnpoint_coordinates;
	if ( isDefined( spawnpoint_angles ) )
	{
		spawnpoint_struct.angles = spawnpoint_angles;
	}
	else 
	{
		spawnpoint_struct.angles = ( 0, 0, 0 );
	}
	spawnpoint_struct.radius = 32;
	spawnpoint_struct.script_noteworthy = "initial_spawn";
	spawnpoint_struct.script_int = 2048;
	spawnpoint_struct.script_string = _get_spawnpoint_script_string_for_location( getDvar( "ui_zm_mapstartlocation" ), getDvar( "g_gametype" ) );
	spawnpoint_struct.locked = 0;
	player_respawn_point_size = level.struct_class_names[ "targetname" ][ "player_respawn_point" ].size;
	player_initial_spawnpoint_size = level.struct_class_names[ "script_noteworthy" ][ "initial_spawn" ].size;
	level.struct_class_names[ "targetname" ][ "player_respawn_point" ][ player_respawn_point_size ] = spawnpoint_struct;
	level.struct_class_names[ "script_noteworthy" ][ "initial_spawn" ][ player_initial_spawnpoint_size ] = spawnpoint_struct;
}

_get_spawnpoint_script_string_for_location( location, gametype )
{
	string = gametype + "_" + location;
	return string;
}

cast_to_vector( vector_string )
{
	logprint( vector_string + "\n" );
	keys = strTok( vector_string, "," );
	logprint( keys[ 0 ] + "\n" );
	vector_array = [];
	for ( i = 0; i < keys.size; i++ )
	{
		vector_array[ i ] = float( keys[ i ] ); 
		logprint( vector_array[ i ] + "\n" );
	}
	vector = ( vector_array[ 0 ], vector_array[ 1 ], vector_array[ 2 ] );
	return vector;
}