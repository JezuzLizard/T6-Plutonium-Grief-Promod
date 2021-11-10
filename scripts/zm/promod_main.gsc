/*
	This script sets up all global overrides and includes for the mod.
*/

#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/zombies/_zm_magicbox;
#include maps/mp/gametypes_zm/_zm_gametype;
#include maps/mp/zombies/_zm_game_module;
#include maps/mp/zombies/_zm_audio_announcer;


#include scripts/zm/grief/audio/_announcer_fix; //VERIFIED
//scripts/zm/grief/audio/_zombie_headshot_sfx;
//scripts/zm/grief/commands/promod_commands;
#include scripts/zm/grief/gametype/_grief_hud;
#include scripts/zm/grief/gametype/_health_bar;
#include scripts/zm/grief/gametype/_hud;
//scripts/zm/grief/gametype/_intermission;
#include scripts/zm/grief/gametype/_obituary;
#include scripts/zm/grief/gametype/_pregame;

#include scripts/zm/grief/gametype_modules/_gamerules;
#include scripts/zm/grief/gametype_modules/_gametype_setup;
#include scripts/zm/grief/gametype_modules/_player_spawning;

#include scripts/zm/grief/mechanics/loadout/_perks;
#include scripts/zm/grief/mechanics/loadout/_weapons;

#include scripts/zm/grief/mechanics/_griefing;
#include scripts/zm/grief/mechanics/_player_health;
#include scripts/zm/grief/mechanics/_point_steal;
#include scripts/zm/grief/mechanics/_powerups;
#include scripts/zm/grief/mechanics/_round_system;
#include scripts/zm/grief/mechanics/_zombies;

#include scripts/zm/grief/persistence/_session_data;

#include scripts/zm/grief/team/_teams;

main()
{
	scripts/zm/grief/gametype_modules/_gamerules::init_gamerules();
	scripts/zm/grief/gametype_modules/_gamerules::init_replacements();
	scripts/zm/grief/audio/_announcer_fix::init_replacements();
	scripts/zm/grief/mechanics/loadout/_perks::init_replacements();
	scripts/zm/grief/gametype/_obituary::init_replacements();
	scripts/zm/grief/gametype_modules/_gametype_setup::init_replacements();
	scripts/zm/grief/gametype_modules/_player_spawning::init_replacements();
	scripts/zm/grief/mechanics/_player_health::init_replacements();
	//scripts/zm/grief/mechanics/_powerups::init_replacements();
	scripts/zm/grief/mechanics/_round_system::init_replacements();
	scripts/zm/grief/mechanics/_round_system::generate_storage_maps();
	scripts/zm/grief/team/_teams::init_replacements();
	scripts/zm/grief/mechanics/_zombies::init_replacements();
	replaceFunc( common_scripts/utility::struct_class_init, ::struct_class_init_override );
	replaceFunc( maps/mp/gametypes_zm/_zm_gametype::init, ::game_module_init_override );
	replaceFunc( maps/mp/zombies/_zm::onallplayersready, ::onallplayersready_override );
	replaceFunc( maps/mp/gametypes_zm/_zm_gametype::onplayerconnect_check_for_hotjoin, ::onplayerconnect_check_for_hotjoin_override );
	level.crash_delay = 20;
	level thread on_player_connect();
	level thread emptyLobbyRestart();
	scripts/zm/grief/gametype/_hud::hud_init();

	flag_init( "match_start", 0 );
	flag_init( "timer_pause", 0 );
	flag_init( "first_round", 0 );
	flag_init( "spawn_players", 1 );
}

init()
{
	level.noroundnumber = 1;
	setDvar( "g_friendlyfireDist", 0 );
	level.game_module_onplayerconnect = scripts/zm/grief/gametype/_grief_hud::grief_onplayerconnect;
	level.game_mode_custom_onplayerdisconnect = scripts/zm/grief/gametype/_grief_hud::grief_onplayerdisconnect;
	level.custom_spawnplayer = scripts/zm/grief/gametype_modules/_player_spawning::grief_spectator_respawn;
	level._game_module_player_damage_callback = scripts/zm/grief/mechanics/_griefing::game_module_player_damage_callback;
	level.onspawnplayerunified = scripts/zm/grief/gametype_modules/_player_spawning::onspawnplayerunified; 
	level.custommayspawnlogic = scripts/zm/grief/gametype_modules/_player_spawning::mayspawn;
	level.autoassign = scripts/zm/grief/team/_teams::default_menu_autoassign;
}

emptyLobbyRestart()
{
	level endon( "end_game" );
	while ( 1 )
	{
		players = getPlayers();
		if ( players.size > 0 )
		{
			while ( 1 )
			{
				players = getPlayers();
				if ( players.size < 1  )
				{
					map_restart( false );
				}
				wait 1;
			}
		}
		wait 1;
	}
}

on_player_connect()
{
	level endon( "end_game" );
	while ( true )
	{
		level waittill( "connected", player );
		if ( level.grief_gamerules[ "knife_lunge" ] )
		{
			player setClientDvar( "aim_automelee_range", 120 );
		}
		else
		{
			player setClientDvar( "aim_automelee_range", 0 );
		}
		player thread health_bar_hud();
		player thread on_player_spawned();
		player thread afk_kick();
		if ( !isDefined( player.last_griefed_by ) )
		{
			player.last_griefed_by = spawnStruct();
			player.last_griefed_by.attacker = undefined;
			player.last_griefed_by.meansofdeath = undefined;
			player.last_griefed_by.weapon = undefined;
		}
		player thread scripts/zm/grief/mechanics/_round_system::give_points_on_restart_and_round_change();
		player scripts/zm/grief/persistence/_session_data::init_player_session_data();
		player.killsconfirmed = 0;
		player.stabs = 0;
		player.assists = 0;
	}
}

afk_kick()
{   
	level endon( "game_ended" );
	self endon("disconnect");
	if ( self.grief_is_admin )
	{
		return;
	}
	time = 0;
	while( true )
	{   
		if ( self.sessionstate == "spectator" || level.players.size <= 2 )
		{	
			wait 1;
			continue;
		}
		if( self usebuttonpressed() || self jumpbuttonpressed() || self meleebuttonpressed() || self attackbuttonpressed() || self adsbuttonpressed() || self sprintbuttonpressed() )
		{
			time = 0;
		}
		if( time == 3600 ) //3mins
		{
			kick( self getEntityNumber() );
		}
		wait 0.05;
		time++;
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
			scripts/zm/grief/mechanics/loadout/_weapons::reduce_starting_ammo();
		}
	}
}

game_module_init_override() //checked matches cerberus output
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
		weapons_restored = self scripts/zm/grief/mechanics/loadout/_weapons::grief_laststand_weapons_return();
		if ( !is_true( weapons_restored ) )
		{
			self maps/mp/zombies/_zm_utility::give_start_weapon( 1 );
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

onplayerconnect_check_for_hotjoin_override()
{
	return;
}

onallplayersready_override()
{
	while ( getPlayers().size == 0 )
	{
		wait 0.1;
	}
	game[ "state" ] = "playing";
	wait_for_all_players_to_connect( level.crash_delay );
	setinitialplayersconnected(); 
	flag_set( "initial_players_connected" );
	while ( !aretexturesloaded() )
	{
		wait 0.05;
	}
	maps/mp/zombies/_zm::fade_out_intro_screen_zm( 5, 1.5, 1 );
}

wait_for_all_players_to_connect( max_wait )
{
	timeout = int( max_wait * 10 );
	cur_time = 0;
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
		cur_time++;
		if ( cur_time >= timeout )
		{
			return;
		}
	}
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
	gametype = getDvar( "g_gametype" );
	location = getDvar( "ui_zm_mapstartlocation" );
	if ( array_validate( level.add_struct_gamemode_location_funcs ) )
	{
		if ( array_validate( level.add_struct_gamemode_location_funcs[ gametype ] ) )
		{
			if ( array_validate( level.add_struct_gamemode_location_funcs[ gametype ][ location ] ) )
			{
				for ( i = 0; i < level.add_struct_gamemode_location_funcs[ gametype ][ location ].size; i++ )
				{
					[[ level.add_struct_gamemode_location_funcs[ gametype ][ location ][ i ] ]]();
				}
			}
		}
	}
	override_perk_struct_locations();
}

override_perk_struct_locations()
{
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
				}
				else if ( perk_keys[ i ] == "origin" )
				{
					perks_moved[ perks_index ].origin = cast_to_vector( perk_keys[ i + 1 ] );
				}
				else if ( perk_keys[ i ] == "angles" )
				{
					perks_moved[ perks_index ].angles = cast_to_vector( perk_keys[ i + 1 ] );
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
						break;
					}
				}
			}
		}
	}
}

cast_to_vector( vector_string )
{
	keys = strTok( vector_string, "," );
	vector_array = [];
	for ( i = 0; i < keys.size; i++ )
	{
		vector_array[ i ] = float( keys[ i ] ); 
	}
	vector = ( vector_array[ 0 ], vector_array[ 1 ], vector_array[ 2 ] );
	return vector;
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