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

init()
{
	if ( getDvarInt( "grief_new_map_set" ) == 1 )
	{
		setDvar( "grief_new_map_set", 0 );
		setDvar( "sv_maprotation", getDvar( "grief_original_rotation" ) );
		setDvar( "sv_maprotationCurrent", getDvar( "grief_original_rotation" ) );
	}
	level thread monitor_players_connecting_status();
	level thread emptyLobbyRestart();
	level.basepath = getDvar( "fs_basepath" ) + "/" + getDvar( "fs_basegame" ) + "/" + "scriptdata" + "/";
	initialize_no_permissions_required_commands();
    setup_permissions();
    level thread commands();
	//level thread monitor_players_connection_status();
	//level thread monitor_players_expected_and_connected();
    if ( getDvar( "g_gametype" ) == "zgrief" )
    {
		init_gamerules();
		level.round_spawn_func = ::round_spawning;
		level._game_module_player_damage_callback = ::game_module_player_damage_callback;
		level._game_module_player_damage_grief_callback = ::game_module_player_damage_grief_callback;
		level.meat_bounce_override = ::meat_bounce_override;
		setDvar( "g_friendlyfireDist", 0 );
		//promod custom overrides
		level.grief_round_win_next_round_countdown = ::round_change_hud;
		level.grief_round_intermission_countdown = ::intermission_hud;
		level.grief_loadout_save = ::grief_loadout_save;
		grief_parse_perk_restrictions();
		grief_parse_powerup_restrictions();
		level thread reduce_starting_ammo();
        level thread on_player_connect();
		level thread draw_hud();
		wait 15;
		level thread instructions_on_all_players();
		if ( getDvar( "mapname" ) == "zm_prison" )
		{
			flag_init( "grief_brutus_can_spawn", 1 );
			level thread grief_brutus_logic();
		}
		if ( getDvarInt( "grief_tournament_mode" ) == 1 )
		{
			init_tournament_mode();
		}
    }
}

emptyLobbyRestart()
{
	level endon( "end_game" );
	while ( 1 )
	{
		players = get_players();
		if ( players.size > 0 )
		{
			while ( 1 )
			{
				players = get_players();
				if ( players.size < 1  )
				{
					cmdexecute( "map_restart" );
				}
				wait 1;
			}
		}
		wait 1;
	}
}

monitor_players_connecting_status()
{
	level.num_players_connecting = 0;
	while ( true )
	{
		level waittill( "connecting", player );
		if ( is_true( player.pers[ "IsBot" ] ) )
		{
			player.custom_team = "team4";
		}
		player parse_ban_list();
		player set_clan_tag();
		if ( !flag( "initial_players_connected" ) )
		{
			logline1 = "P: " + player.name + " is connecting during loadscreen" + "\n";
			logprint( logline1 );
			player thread kick_player_if_dont_spawn_in_time();
		}
	}
}

set_clan_tag()
{
	for ( i = 0; i < level.server_users[ "Admins" ].guids.size; i++ )
	{
		if ( self getGUID() == level.server_users[ "Admins" ].guids[ i ] )
		{
			self setClanTag( "Admin" );
			self.grief_is_admin = 1;
		}
	}
}

parse_ban_list()
{
	ban_list = fopen( level.basepath + "bans.txt", "r+" );
    buffer = "";
	i = 0;
    while ( 1 ) 
    {
        eof = feof( ban_list );
        if ( eof )
        {
			if ( i == 1 )
			{
				fclose( ban_list ); 
				return;
			}
            break;
        }
        buffer += fgetc( ban_list );
		i++;
	}
	fclose( ban_list ); 
	names_and_guids = strTok( buffer, ";" );
	for ( i = 0; i < names_and_guids.size; i++ )
	{
		printF( names_and_guids[ i ] );
	}
	for ( i = 0; i < names_and_guids.size; i++ )
	{
		// printF( "parse_ban_list() names_and_guids[ " + i + " ] " + names_and_guids[ i ] );
		guids = strTok( names_and_guids[ i ], ":" );
		guid = int( guids[ 1 ] );
		// printF( "parse_ban_list() guid " + guid );
		// printF( "Player " + self.name + " guid " + self getGUID() );
		if ( self getGUID() == guid )
		{
			kick( self getEntityNumber() );
		}
	}
}

ban_player( player_ban_name )
{
	foreach ( player in level.players )
	{
		if ( clean_player_name_of_clantag( player.name ) == player_ban_name )
		{
			player_to_be_banned = player;
			break;
		}
	}
	ban_list = fopen( level.basepath + "bans.txt", "a+" );
	fprintf( ";" + clean_player_name_of_clantag( player_to_be_banned.name ) + ":" + player_to_be_banned getGUID(), ban_list );
	fclose( ban_list );
	say( clean_player_name_of_clantag( player_to_be_banned.name ) + " has been banned!" );
	kick( player_to_be_banned getEntityNumber() );
}

temp_ban_player( player_ban_name )
{
	foreach ( player in level.players )
	{
		if ( clean_player_name_of_clantag( player.name ) == player_ban_name )
		{
			player_to_be_banned = player;
			break;
		}
	}
	ban_list = fopen( level.basepath + "tempbans.txt", "a+" );
	fprintf( ";" + clean_player_name_of_clantag( player_to_be_banned.name ) + ":" + player_to_be_banned getGUID(), ban_list );
	fclose( ban_list );
	say( clean_player_name_of_clantag( player_to_be_banned.name ) + " has been banned!" );
	kick( player_to_be_banned getEntityNumber() );
}

kick_player_if_dont_spawn_in_time()
{
	self endon( "begin" );
	wait 20;
	logline1 = "Kicking player because they failed to notify begin in less than 20 seconds during the loadscreen" + "\n";
	logprint( logline1 );
	kick( self getEntityNumber() );
}

instructions_on_all_players()
{
	level endon( "end_game" );
	flag_wait( "initial_blackscreen_passed" );
	players = getPlayers();
	if ( isDefined( players ) && ( players.size > 0 ) )
	{
		foreach ( player in players )
		{
			player thread instructions();
		}
	}
}

instructions()
{
	level endon( "end_game" );
	self endon( "disconnect" );
	level waittill( "grief_begin" );
	rounds = level.grief_gamerules[ "scorelimit" ];
	self iPrintLn( "Welcome to Grief!" );
	wait 3;
	self iPrintLn( "Your goal is to win " + rounds + " rounds" );
	wait 3;
	self iPrintLn( "Win a round by downing the entire other team" );
	wait 3;
	self iPrintLn( "Good luck!" );
	wait 3;
}

monitor_players_expected_and_connected()
{
	level endon( "end_game" );
	i = 0;
	while ( true )
	{
		logline1 = "getNumExpectedPlayers(): " + getnumexpectedplayers() + " getNumConnectedPlayers(): " + getnumconnectedplayers() + "\n";
		logprint( logline1 );
		wait 1;
		i++;
		if ( i == 30 )
		{
			break;
		}
	}
}

on_player_connect()
{
	level endon( "end_game" );

    while ( true )
    {
    	level waittill( "connected", player );
		player setClientDvar( "aim_automelee_range", 0 );
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
       	player set_team();
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
	}
}

reduce_starting_ammo()
{	
	level endon( "game_ended" );
	flag_wait( "initial_blackscreen_passed" );
	wait 2;
	players = get_players();
	for(i = 0; i < players.size; i++)
	{	
		weapon = players[ i ] getcurrentweapon();
		players[ i ] setweaponammostock( weapon, 8 );
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
    while( 1 )
    {   
		if ( self.sessionstate == "spectator" )
		{	
			wait 1;
			continue;
		}
        if( self usebuttonpressed() || self jumpbuttonpressed() || self meleebuttonpressed() || self attackbuttonpressed() || self adsbuttonpressed() || self sprintbuttonpressed() )
        {
            time = 0;
        }
        if( time == 6000 ) //5mins
        {
            say( clean_player_name_of_clantag( self.name ) + " has been kicked for inactivity!" );
            kick( self getEntityNumber() );
        }

        wait 0.05;
        time++;
    }
}

give_points_on_restart_and_round_change()
{
	level endon( "end_game" );
	while ( true )
	{
		level waittill( "grief_give_points" );
		if ( self.score < level.grief_gamerules[ "round_restart_points" ] )
		{
			self.score = level.grief_gamerules[ "round_restart_points" ];
		}
	}
}

set_team()
{
	if ( isDefined( self.custom_team ) )
	{
		self.team = self.custom_team;
		self.sessionteam = self.custom_team;
		self._encounters_team = undefined;
		self [[ level.givecustomcharacters ]]();
		return;
	}
	teamplayersallies = countplayers( "allies");
	teamplayersaxis = countplayers( "axis");
	if ( getDvarInt( "grief_gamerule_use_preset_teams" ) == 1 )
	{
	 	allies_team_members = getDvar( "grief_allies_team_player_names" );
		team_keys = strTok( allies_team_members, "+" ); 
		if ( teamplayersallies < 4 )
		{
			foreach ( key in team_keys )
			{
				logline1 = "Checking player: " + self.name + " comparing with: " + key + "\n";
				logprint( logline1 );
				if ( self.name == key )
				{
					self.team = "allies";
					self.sessionteam = "allies";
					self.pers[ "team" ] = "allies";
					self._encounters_team = "B";
					team_is_defined = 1;
					logline1 = "trying to set player based on name: " + self.name + " to preset team: " + self.team + "\n";
					logprint( logline1 );
					break;
				}
			}
		}
		if ( !is_true( team_is_defined ) )
		{
			teamplayersaxis = countplayers( "axis");
			if ( teamplayersaxis < 4 )
			{
				self.team = "axis";
				self.sessionteam = "axis";
				self.pers[ "team" ] = "axis";
				self._encounters_team = "A"; 
				team_is_defined = 1;
				logline1 = "player didn't have name match: " + self.name + " to preset team: " + self.team + "\n";
				logprint( logline1 );
			}
			else 
			{
				self.team = "allies";
				self.sessionteam = "allies";
				self.pers[ "team" ] = "allies";
				self._encounters_team = "B";
				team_is_defined = 1;
				logline1 = "player team failsafe: " + self.name + " to preset team: " + self.team + "\n";
				logprint( logline1 );
			}
		}
	}
	else if ( getDvarInt( "grief_gamerule_use_mmr_teams" ) == 1 )
	{
		self.mmr = self get_mmr();
		total_mmr = get_total_mmr();
		equal_mmr = total_mmr / 2;

	}
	else 
	{
		teamplayersallies = countplayers( "allies");
		teamplayersaxis = countplayers( "axis");
		if ( teamplayersallies > teamplayersaxis && !level.isresetting_grief )
		{
			self.team = "axis";
			self.sessionteam = "axis";
			self.pers[ "team" ] = "axis";
			self._encounters_team = "A";
		}
		else if ( teamplayersallies < teamplayersaxis && !level.isresetting_grief)
		{
			self.team = "allies";
			self.sessionteam = "allies";
			self.pers[ "team" ] = "allies";
			self._encounters_team = "B";
		}
		else
		{
			self.team = "allies";
			self.sessionteam = "allies";
			self.pers[ "team" ] = "allies";
			self._encounters_team = "B";
		}
	}
	self [[ level.givecustomcharacters ]]();
}

get_mmr()
{
	//total_kills = self get_stat( "kills" );
	//kill_stat_scalar = 0.5;
	total_stabs = self get_stat( "stabs" );
	total_stabs_scalar = 5;
	total_kills_confirmed = self get_stat( "kills_confirmed" );
	total_kills_confirmed_scalar = 25;
	total_revives = self get_stat( "revives" );
	total_revives_scalar = 15;
	total_assists = self get_stat( "assists" );
	total_assists_scalar = 15;
	total_wins = self get_stat( "wins" );
	total_wins_scalar = 100;
	total_games = self get_stat( "total_games" );
	total_games_scalar = 50;
	win_rate_percent = total_wins / total_games;
	win_rate = int( ( win_rate_percent * 100 ) );
	
}

get_total_mmr()
{

}

get_stat( statname )
{
	statvalue = look_up_player_stat_table( statname, self.name, self getXUID() );
}

look_up_player_stat_table( statname, player_name, player_xuid )
{

}

is_weapon_shotgun( sweapon )
{
	switch ( sweapon )
	{
		case "saiga12_zm":
		case "saiga12_upgraded_zm":
		case "srm1216_zm":
		case "srm1216_upgraded_zm":
		case "rottweil72_zm":
		case "rottweil72_upgraded_zm":
		case "ksg_zm":
		case "ksg_upgraded_zm":
		case "870mcs_zm":
		case "870mcs_upgraded_zm":
			return 1;
		default:
			return 0;
	}
}

test_bots()
{
	add_bots();
}

add_bots()
{
	//Wait for the host!
	players = get_players();
	while ( players.size < 1 )
	{
		players = get_players();
		wait 1;
		if ( getDvarInt( "debugModBotsWaitForPlayers" ) == 0 )
		{
			break;
		}
	}
	wait 5;
	//Then spawn bots
	botsToSpawn = getDvarIntDefault( "debugModBotsToSpawn", 7 );
	for ( currentBots = 0; currentBots < botsToSpawn; currentBots++ )
	{
		wait 0.25;
		zbot_spawn();
	}
	SetDvar("bot_AllowMovement", "1");
	SetDvar("bot_PressAttackBtn", "1");
	SetDvar("bot_PressMeleeBtn", "1");
}

zbot_spawn()
{
	bot = AddTestClient();			
	bot.equipment_enabled = false;
	bot [[ level.spawnplayer ]]();
	return bot;
}

init_tournament_mode()
{
	team_size = getDvarIntDefault( "grief_tournament_team_size", 4 );
	minplayers = team_size * 2;
	setDvar( "zombies_minplayers", minplayers );
}

grief_track_stats()
{
}

init_gamerules()
{
	level.default_solo_laststandpistol = "m1911_zm";
	level.is_forever_solo_game = undefined;
	level.speed_change_round = undefined;
	level.grief_gamerules = [];
	level.grief_gamerules[ "scorelimit" ] = getDvarIntDefault( "grief_gamerule_scorelimit", 3 );
	level.grief_gamerules[ "zombies_per_round" ] = getDvarIntDefault( "grief_gamerule_zombies_per_round", 3 );
	level.grief_gamerules[ "perk_restrictions" ] = getDvar( "grief_gamerule_perk_restrictions" );
	level.grief_gamerules[ "mystery_box_enabled" ] = getDvarIntDefault( "grief_gamerule_mystery_box_enabled", 0 );
	level.grief_gamerules[ "wall_weapon_restrictions" ] = getDvar( "grief_gamerule_wall_weapon_restrictions" );
	level.grief_gamerules[ "next_round_time" ] = getDvarIntDefault( "grief_gamerule_next_round_timer", 5 );
	level.grief_gamerules[ "intermission_time" ] = getDvarIntDefault( "grief_gamerule_intermission_time", 0 );
	level.grief_gamerules[ "door_restrictions" ] = getDvar( "grief_gamerule_door_restrictions" );
	level.grief_gamerules[ "round_restart_points" ] = getDvarIntDefault( "grief_gamerule_round_restart_points", 8000 );
	level.grief_gamerules[ "use_preset_teams" ] = getDvarIntDefault( "grief_gamerule_use_preset_teams", 0 );
	level.grief_gamerules[ "disable_zombie_special_runspeeds" ] = getDvarIntDefault( "grief_gamerules_disable_zombie_special_runspeeds", 1 );
	level.grief_gamerules[ "suicide_check" ] = getDvarFloatDefault( "grief_gamerule_suicide_check_wait", 5 );
	level.grief_gamerules[ "player_health" ] = getDvarIntDefault( "grief_gamerule_player_health", 100 );
	level.grief_gamerules[ "perk_limit" ] = getDvarIntDefault( "grief_gamerule_perk_limit", 4 );
	level.grief_gamerules[ "powerup_restrictions" ] = getDvar( "grief_gamerule_powerup_restrictions" );
	 //location farm perkA specialty_armorvest perkB specialty_fastreload
	//init_gamelengths();
}
/*
init_gamelengths()
{
	if ( getDvar( "grief_game_length_override" ) != "" )
	{
		switch ( getDvar( "grief_game_length_override" ) )
		{
			case "short":
				setup_grief_rule_for_game_length( "perk_restrictions", "specialty_quickrevive specialty_armorvest specialty_weapupgrade" );
				setup_grief_rule_for_game_length( "zombies_per_round", 3 );
				setup_grief_rule_for_game_length( "scorelimit", 3 );
				setup_grief_rule_for_game_length( "mystery_box_enabled", 0 );
				setup_grief_rule_for_game_length( "door_restrictions", "" );
				setup_grief_rule_for_game_length( "start_round", 20 );
				restart_points = level.round_number * 500;
				setup_grief_rule_for_game_length( "restart_points", restart_points );
				break;
			case "medium":
				setup_grief_rule_for_game_length( "perk_restrictions", "specialty_weapupgrade" );
				setup_grief_rule_for_game_length( "zombies_per_round", 3 );
				setup_grief_rule_for_game_length( "scorelimit", 3 );
				setup_grief_rule_for_game_length( "mystery_box_enabled", 1 );
				setup_grief_rule_for_game_length( "door_restrictions", "" );
				setup_grief_rule_for_game_length( "start_round", 10 );
				break;
			case "long":
				setup_grief_rule_for_game_length( "perk_restrictions", "" );
				setup_grief_rule_for_game_length( "zombies_per_round", 3 );
				setup_grief_rule_for_game_length( "scorelimit", 2 );
				setup_grief_rule_for_game_length( "mystery_box_enabled", 1 );
				setup_grief_rule_for_game_length( "door_restrictions", "" );
				setup_grief_rule_for_game_length( "start_round", 1 );
				break;
			default:
				logline1 = "Invalid game length" + "\n";
				logprint( logline1 );
				break;
		}
	}
}
*/
setup_grief_rule_for_game_length( rule, value )
{
	level.grief_gamerules[ rule ] = value;
}

//doesn't work yet
grief_restrict_wallbuy( weapon )
{
	if ( level.grief_gamerules[ "wall_weapon_restrictions" ] == "" )
	{
		return false;
	}
	weapon_keys = strTok( level.grief_gamerules[ "wall_weapon_restrictions" ], " " );
	foreach ( key in weapon_keys )
	{
		if ( key == weapon )
		{
			return true;
		}
	}
	return false;
}

grief_parse_perk_restrictions()
{
	if ( level.grief_gamerules[ "perk_restrictions" ] == "" )
	{
		return;
	}
	perk_keys = strTok( level.grief_gamerules[ "perk_restrictions" ], " " );
	foreach ( key in perk_keys )
	{
		if ( key == "specialty_weapupgrade" )
		{
			trig = getent( key, "script_noteworthy" );
			if ( isdefined( trig.target ) )
			{
				machine = getent( trig.target, "targetname" );
				machine.wait_flag delete();
			}
		}
		level thread perk_machine_removal( key );
	}
}

grief_parse_powerup_restrictions()
{
	powerups = strTok( level.grief_gamerules[ "powerup_restrictions" ], " " );
	for ( i = 0; i < powerups.size; i++ )
	{
		remove_powerup( powerups[ i ] );
	}
}

remove_powerup( powerup )
{	
	arrayremoveindex(level.zombie_include_powerups, powerup);
	arrayremoveindex(level.zombie_powerups, powerup);
	arrayremovevalue(level.zombie_powerup_array, powerup);
}

no_magic()
{	
	no_drops();
	machines = getentarray( "zombie_vending", "targetname" );
	for( i = 0; i < machines.size; i++ )
	{
		level thread perk_machine_removal( machines[ i ].script_noteworthy );
	}
}

no_drops()
{
	flag_clear( "zombie_drop_powerups" );
	level.zombie_include_powerups = [];
	level.zombie_powerup_array= [];
	level.zombie_include_powerups = [];
}

//HUD Grouping
draw_hud()
{
	level thread zombiesleft_hud();
	level thread grief_score();
	level thread grief_score_shaders();
	level thread destroy_hud_on_game_end();
}

round_change_hud()
{   
	level endon( "end_game" );
	if ( isDefined( level.round_countdown_text ) )
	{
		level.round_countdown_text destroy();
	}
	if ( isDefined( level.round_countdown_timer ) )
	{
		level.round_countdown_timer destroy();
	}
	remaining = create_simple_hud();
  	remaining.horzAlign = "center";
  	remaining.vertAlign = "middle";
   	remaining.alignX = "center";
   	remaining.alignY = "middle";
   	remaining.y = 20;
   	remaining.x = 0;
   	remaining.foreground = 1;
   	remaining.fontscale = 2.0;
   	remaining.alpha = 1;
   	remaining.color = ( 0.98, 0.549, 0 );
	remaining.hidewheninmenu = 1;
	remaining maps/mp/gametypes_zm/_hud::fontpulseinit();

   	countdown = create_simple_hud();
   	countdown.horzAlign = "center"; 
   	countdown.vertAlign = "middle";
   	countdown.alignX = "center";
   	countdown.alignY = "middle";
   	countdown.y = -20;
   	countdown.x = 0;
   	countdown.foreground = 1;
   	countdown.fontscale = 2.0;
   	countdown.alpha = 1;
   	countdown.color = ( 1.000, 1.000, 1.000 );
	countdown.hidewheninmenu = 1;
   	countdown setText( "Next Round Starts In" );
	level.round_countdown_timer = remaining;
	level.round_countdown_text = countdown;
	timer = level.grief_gamerules[ "next_round_time" ];
	while ( 1 )
	{
		level.round_countdown_timer setValue( timer ); 
		wait 1;
		timer--;
		if ( timer <= 5 )
		{
			countdown_pulse( level.round_countdown_timer, timer );
			break;
		}
	}
	if ( isDefined( level.round_countdown_text ) )
	{
		level.round_countdown_text destroy();
	}
	if ( isDefined( level.round_countdown_timer ) )
	{
		level.round_countdown_timer destroy();
	}
}

countdown_pulse( hud_elem, duration )
{
	level endon( "end_game" );
	waittillframeend;
	while ( duration > 0 && !level.gameended )
	{
		hud_elem thread maps/mp/gametypes_zm/_hud::fontpulse( level );
		wait ( hud_elem.inframes * 0.05 );
		hud_elem setvalue( duration );
		duration--;
		wait ( 1 - ( hud_elem.inframes * 0.05 ) );
	}
}

intermission_hud()
{   
	level endon( "end_game" );
	remaining = create_simple_hud();
  	remaining.horzAlign = "center";
  	remaining.vertAlign = "middle";
   	remaining.alignX = "center";
   	remaining.alignY = "middle";
   	remaining.y = 20;
   	remaining.x = 0;
   	remaining.foreground = 1;
   	remaining.fontscale = 2.0;
   	remaining.alpha = 1;
   	remaining.color = ( 0.98, 0.549, 0 );
	remaining.hidewheninmenu = 1;
	remaining maps/mp/gametypes_zm/_hud::fontpulseinit();

   	countdown = create_simple_hud();
   	countdown.horzAlign = "center"; 
   	countdown.vertAlign = "middle";
   	countdown.alignX = "center";
   	countdown.alignY = "middle";
   	countdown.y = -20;
   	countdown.x = 0;
   	countdown.foreground = 1;
   	countdown.fontscale = 2.0;
   	countdown.alpha = 1;
   	countdown.color = ( 1.000, 1.000, 1.000 );
	countdown.hidewheninmenu = 1;
   	countdown setText( "Intermission" );
	level.intermission_countdown = remaining;
	level.intermission_text = countdown;
	timer = level.grief_gamerules[ "intermission_time" ];
	while ( 1 )
	{
		level.intermission_countdown setValue( timer ); 
		wait 1;
		timer--;
		if ( timer <= 5 )
		{
			countdown_pulse( level.intermission_countdown, timer );
			break;
		}
	}
	if ( isDefined( level.intermission_countdown ) )
	{
		level.intermission_countdown destroy();
	}
	if ( isDefined( level.intermission_text ) )
	{
		level.intermission_text destroy();
	}
}

zombiesleft_hud()
{   
	level endon( "end_game" );
	flag_wait( "initial_blackscreen_passed" );

	level.remaining_zombies_hud = create_simple_hud();
	level.remaining_zombies_hud.alignx = "left";
    level.remaining_zombies_hud.aligny = "top";
    level.remaining_zombies_hud.horzalign = "user_left";
    level.remaining_zombies_hud.vertalign = "user_top";
    level.remaining_zombies_hud.x += 5;
    level.remaining_zombies_hud.y += 2;
    level.remaining_zombies_hud.fontscale = 1.5;
    level.remaining_zombies_hud.color = ( 0.423, 0.004, 0 );
	level.remaining_zombies_hud.alpha = 1;
    level.remaining_zombies_hud.hidewheninmenu = 1;
    level.remaining_zombies_hud.label = &"Zombies Left: "; 

	while ( true )
	{
		remaining_zombies = get_current_zombie_count() + level.zombie_total;
		level.remaining_zombies_hud setValue( remaining_zombies );
		wait 0.05;
	}		
}

destroy_hud_on_game_end()
{
	level waittill_either( "end_game", "disable_all_hud" );
	if ( isDefined( level.round_countdown_timer ) )
	{
		level.round_countdown_timer destroy();
	}
	if ( isDefined( level.round_countdown_text ) )
	{
		level.round_countdown_text destroy();
	}
	if ( isDefined( level.grief_score_hud[ "A" ] ) )
	{
		//level.grief_score_hud[ "A" ] destroy();
	}
	if ( isDefined( level.grief_score_hud[ "B" ] ) )
	{
		//level.grief_score_hud[ "B" ] destroy();
	}
	if ( isDefined( level.team_shader1 ) ) 
	{
		//level.team_shader1 destroy();
	}
	if ( isDefined( level.team_shader2 ) ) 
	{
		//level.team_shader2 destroy();
	}
	if ( isDefined( level.remaining_zombies_hud ) )
	{
		level.remaining_zombies_hud destroy();
	}
	if ( isDefined( level.intermission_countdown ) )
	{
		level.intermission_countdown destroy();
	}
	if ( isDefined( level.intermission_text ) )
	{
		level.intermission_text destroy();
	}
}

grief_score()
{   
	flag_wait( "initial_blackscreen_passed" );
	level.grief_score_hud = [];
	level.grief_score_hud[ "A" ] = create_simple_hud();
    level.grief_score_hud[ "A" ].x += 440;
    level.grief_score_hud[ "A" ].y += 20;
    level.grief_score_hud[ "A" ].fontscale = 2.5;
    level.grief_score_hud[ "A" ].color = ( 0.423, 0.004, 0 );
	level.grief_score_hud[ "A" ].alpha = 1;
    level.grief_score_hud[ "A" ].hidewheninmenu = 1;
	level.grief_score_hud[ "A" ] setValue( 0 );
	level.grief_score_hud[ "B" ] = create_simple_hud();
    level.grief_score_hud[ "B" ].x += 240;
    level.grief_score_hud[ "B" ].y += 20;
    level.grief_score_hud[ "B" ].fontscale = 2.5;
    level.grief_score_hud[ "B" ].color = ( 0.423, 0.004, 0 );
	level.grief_score_hud[ "B" ].alpha = 1;
    level.grief_score_hud[ "B" ].hidewheninmenu = 1;
	level.grief_score_hud[ "B" ] setValue( 0 );

	while ( 1 )
	{
		level waittill( "grief_point", team );
		level.grief_score_hud[ team ] SetValue( level.grief_teams[ team ].score );
	}	
}

grief_score_shaders()
{
	flag_wait( "initial_blackscreen_passed" );
	if ( level.script == "zm_prison" )
	{
		level.team_shader1 = create_simple_hud();
		level.team_shader2 = create_simple_hud();
		text = 1;
	}
	else
	{
		level.team_shader1 = createservericon( game[ "icons" ][ "axis" ], 35, 35 );
		level.team_shader2 = createservericon( game[ "icons" ][ "allies" ], 35, 35 );
	}
	if ( is_true( text ) )
	{
		level.team_shader1.x += 360;
		level.team_shader1.y += 20;
		level.team_shader1.fontscale = 2.5;
		level.team_shader1.color = ( 1, 0.333, 0.333 );
		level.team_shader1.alpha = 1;
		level.team_shader1.hidewheninmenu = 1;
		level.team_shader1.label = &"Inmates "; 
		level.team_shader2.x += 170;
		level.team_shader2.y += 20;
		level.team_shader2.fontscale = 2.5;
		level.team_shader2.color = ( 0, 0.004, 0.423 );
		level.team_shader2.alpha = 1;
		level.team_shader2.hidewheninmenu = 1;
		level.team_shader2.label = &"Guards "; 
	}
	else 
	{
		level.team_shader1.x += 90;
		level.team_shader1.y += -20;
		level.team_shader1.hideWhenInMenu = 1;
		level.team_shader2.x += -110;
		level.team_shader2.y += -20;
		level.team_shader2.hideWhenInMenu = 1;
	}
}

grief_loadout_save( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration )
{
	self.grief_savedweapon_weapons = self getweaponslist();
	self.grief_savedweapon_weaponsammo_stock = [];
	self.grief_savedweapon_weaponsammo_clip = [];
	self.grief_savedweapon_currentweapon = self getcurrentweapon();
	self.grief_savedweapon_grenades = self get_player_lethal_grenade();
	if ( isDefined( self.grief_savedweapon_grenades ) )
	{
		self.grief_savedweapon_grenades_clip = self getweaponammoclip( self.grief_savedweapon_grenades );
	}
	self.grief_savedweapon_tactical = self get_player_tactical_grenade();
	if ( isDefined( self.grief_savedweapon_tactical ) )
	{
		self.grief_savedweapon_tactical_clip = self getweaponammoclip( self.grief_savedweapon_tactical );
	}
	for ( i = 0; i < self.grief_savedweapon_weapons.size; i++ )
	{
		self.grief_savedweapon_weaponsammo_clip[ i ] = self getweaponammoclip( self.grief_savedweapon_weapons[ i ] );
		self.grief_savedweapon_weaponsammo_stock[ i ] = self getweaponammostock( self.grief_savedweapon_weapons[ i ] );
	}
	if ( isDefined( self.hasriotshield ) && self.hasriotshield )
	{
		self.grief_hasriotshield = 1;
	}
	if ( self hasweapon( "claymore_zm" ) )
	{
		self.grief_savedweapon_claymore = 1;
		self.grief_savedweapon_claymore_clip = self getweaponammoclip( "claymore_zm" );
	}
}

//Function Overrides
round_spawning() //checked changed to match cerberus output
{
	level endon( "intermission" );
	level endon( "end_of_round" );
	level endon( "restart_round" );
	if ( level.intermission )
	{
		return;
	}
	if ( level.zombie_spawn_locations.size < 1 )
	{
		return;
	}
	ai_calculate_health( level.round_number );
	players = get_players();
	for ( i = 0; i < players.size; i++ )
	{
		players[ i ].zombification_time = 0;
	}
	player_num = get_players().size;
	level.zombie_total = ( level.grief_gamerules[ "zombies_per_round" ] * level.round_number ) + ( player_num * 2 );
	level notify( "zombie_total_set" );
	old_spawn = undefined;
	while ( 1 )
	{
		while ( get_current_zombie_count() >= level.zombie_ai_limit || level.zombie_total <= 0 )
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
			level.zombie_total--;

			ai thread round_spawn_failsafe();
			count++;
		}
		wait level.zombie_vars[ "zombie_spawn_delay" ];
		wait_network_frame();
	}
}

//Extended Grief Mechanics
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
	if ( isDefined( eattacker) && isplayer( eattacker ) )
	{
		if ( smeansofdeath == "MOD_MELEE" )
		{
			eattacker.pers[ "stabs" ]++;
			eattacker.stabs++;
		}
	}
	if ( isplayer( eattacker ) && isDefined( eattacker._encounters_team ) && eattacker._encounters_team != self._encounters_team )
	{
		self player_steal_points( eattacker, smeansofdeath );
	}
	if ( is_true( self._being_shellshocked ) || self maps/mp/zombies/_zm_laststand::player_is_in_laststand() )
	{
		return;
	}
	if ( isplayer( eattacker ) && isDefined( eattacker._encounters_team ) && eattacker._encounters_team != self._encounters_team )
	{
		self.last_griefed_by.attacker = eattacker;
		self.last_griefed_by.meansofdeath = smeansofdeath;
		self.last_griefed_by.weapon = sweapon;
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
		self thread watch_for_down( eattacker );
		self thread do_game_mode_shellshock( eattacker, smeansofdeath, sweapon );
		self playsound( "zmb_player_hit_ding" );
	}
}

do_game_mode_shellshock( attacker, meansofdeath, weapon ) //checked matched cerberus output
{
	self endon( "disconnect" );
	self._being_shellshocked = 1;
	if ( meansofdeath == "MOD_MELEE" )
	{
		self shellshock( "grief_stab_zm", 0.75 );
	}
	else 
	{
		self shellshock( "grief_stab_zm", 0.25 );
	}
	if ( !is_weapon_shotgun( weapon ) )
	{
		wait 0.75;
	}
	else 
	{
		wait 0.75;
	}
	self._being_shellshocked = 0;
}

watch_for_down( attacker )
{
	if ( is_true( self.grief_already_checking_for_down ) )
	{
		return;
	}
	self.grief_already_checking_for_down = 1;
	self waittill_notify_or_timeout( "player_downed", 4 );
	if ( self player_is_in_laststand() )
	{
		if ( isDefined( self.last_griefed_by.attacker ) )
		{
			self player_steal_points( self.last_griefed_by.attacker, "down_player" );
			if ( isDefined( self.last_griefed_by.attacker ) && isDefined( self.last_griefed_by.meansofdeath ) )
			{
				if ( getDvarInt( "grief_killfeed_enable" ) == 1 )
				{
					obituary( self, self.last_griefed_by.attacker, self.last_griefed_by.weapon, self.last_griefed_by.meansofdeath );
				}
				attacker.killsconfirmed++;
				attacker.pers[ "killsconfirmed" ]++;
			}
		}
	}
	self.grief_already_checking_for_down = 0;
}

meat_bounce_override( pos, normal, ent ) //checked matches cerberus output
{
	if ( isdefined( ent ) && isplayer( ent ) )
	{
		if ( !ent maps/mp/zombies/_zm_laststand::player_is_in_laststand() )
		{
			level thread meat_stink_player( ent );
			if ( isdefined( self.owner ) )
			{
				ent player_steal_points( self.owner, "meat" );
				maps/mp/_demo::bookmark( "zm_player_meat_stink", GetTime(), ent, self.owner, 0, self );
				self.owner maps/mp/zombies/_zm_stats::increment_client_stat( "contaminations_given" );
			}
		}
	}
	else
	{
		players = getplayers();
		closest_player = undefined;
		closest_player_dist = 10000;
		player_index = 0;
		while ( player_index < players.size )
		{
			player_to_check = players[ player_index ];
			if ( self.owner == player_to_check )
			{
				player_index++;
				continue;
			}
			if ( player_to_check maps/mp/zombies/_zm_laststand::player_is_in_laststand() )
			{
				player_index++;
				continue;
			}
			distsq = distancesquared( pos, player_to_check.origin );
			if ( distsq < closest_player_dist )
			{
				closest_player = player_to_check;
				closest_player_dist = distsq;
			}
			player_index++;
		}
		if ( isdefined( closest_player ) )
		{
			level thread meat_stink_player( closest_player );
			if ( isdefined( self.owner ) )
			{
				maps/mp/_demo::bookmark( "zm_player_meat_stink", GetTime(), closest_player, self.owner, 0, self );
				self.owner maps/mp/zombies/_zm_stats::increment_client_stat( "contaminations_given" );
			}
		}
		else
		{
			valid_poi = check_point_in_enabled_zone( pos, undefined, undefined );
			if ( valid_poi )
			{
				self hide();
				level thread meat_stink_on_ground( self.origin );
			}
		}
		playfx( level._effect[ "meat_impact" ], self.origin );
	}
	self delete();
}

player_steal_points( attacker, event )
{
	if ( level.intermission )
	{
		return;
	}
	if ( event == "MOD_MELEE" )
	{
		event = "knife";
	}
	else if ( event == "MOD_PISTOL_BULLET" || event == "MOD_RIFLE_BULLET" ) 
	{
		event = "gun";
	}
	else if ( event == "MOD_GRENADE" || event == "MOD_GRENADE_SPLASH")
	{
		event = "grenade";
	}
	else if ( event == "MOD_IMPACT" || event == "MOD_HIT_BY_OBJECT" )
	{
		event = "impact";
	}
	if ( isDefined( attacker ) && isDefined( self ) && !self maps/mp/zombies/_zm_laststand::player_is_in_laststand() )
	{
		points_to_steal = 0;
		switch( event )
		{
			case "meat":
				points_to_steal = 1000;
				break;
			case "knife":
				points_to_steal = 100;
				break;
			case "gun":
				points_to_steal = 20;
				break;
			case "grenade":
				points_to_steal = 100;
				break;
			case "impact":
				points_to_steal = 50;
				break;
			case "down_player":
				points_to_steal = 200;
				break;
			case "deny_revive":
				points_to_steal = 200;
				break;
			case "deny_box_weapon_pickup":
				points_to_steal = 100;
				break;
			case "emp_pap_with_weapon":
				break;
			case "emp_box_roll":
				break;
			case "emp_player":
				points_to_steal = 100;
				break;
		}
		if ( points_to_steal == 0 )
		{
			return;
		}
		if ( ( self.score - points_to_steal ) < 0 )
		{
			return;
		}
		attacker add_to_player_score( points_to_steal );
		self minus_to_player_score( points_to_steal, true );
	}
}

game_module_player_damage_grief_callback( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime )
{
	old_revives = self.revives;
	if ( isDefined( eattacker ) && isplayer( eattacker ) && eattacker != self && eattacker.team != self.team )
	{
		if ( smeansofdeath == "MOD_MELEE" )
		{
			//check if player is reviving before knockback
			if ( self is_reviving_any() )
			{
				self.is_reviving_grief = 1;
			}
			self applyknockback( idamage, vdir );
		}
		else if ( is_weapon_shotgun( sweapon ) )
		{
			if ( self is_reviving_any() )
			{
				self.is_reviving_grief = 1;
			}
			self applyknockback( idamage, vdir );
		}
	}
	if ( is_true( self.is_reviving_grief ) )
	{
		if ( self.revives == old_revives )
		{
			if ( !self is_reviving_any() )
			{
				knocked_off_revive = 1;
			}
		}
	}
	if ( is_true( knocked_off_revive ) )
	{
		self player_steal_points( eattacker, "deny_revive" );
	}
	self.is_reviving_grief = false;
}

grief_brutus_logic()
{
	level endon( "end_game" );
	level waittill( "grief_begin" );
	while ( true )
	{
		random_wait = randomIntRange( 360, 720 );
		for ( i = 0; i < random_wait; i++ )
		{
			wait 1;
		}
		flag_wait( "grief_brutus_can_spawn" );
		wait 10;
		if ( coinToss() )
		{
			level notify( "spawn_brutus", randomIntRange( 1, 2 ) );
		}
		else if ( randomInt( 60 ) )
		{
			level notify( "spawn_brutus", randomIntRange( 2, 4 ) );
		}
		else 
		{
			level notify( "spawn_brutus", 1 );
		}
	}
}

clean_player_name_of_clantag( name )
{
	if ( isSubStr( name, "]" ) )
	{
		keys = strTok( name, "]" );
		return keys[ 1 ];
	}
	return name;
}

commands()
{
	level endon( "end_commands" );
	level thread end_commands_on_end_game();
	while ( true )
    {
        level waittill( "say", player, message );
        if ( !isSubStr( message, "!" ) )
        {
            continue;
        }
		args = strTok( message, ":" );
        keys = strTok( args[ 0 ], "!" );
        command = keys[ 0 ];
        if ( player has_permissions_for_command( command, args ) )
        {
            switch ( command )
            {
				case "b":
				case "ban":
					if ( args[ 1 ] == clean_player_name_of_clantag( player.name ) )
					{
						break;
					}
					logline1 = "CMD:" + player.name + ";B:" + args[ 1 ] + "\n";
					logprint( logline1 );
					ban_player( args[ 1 ] );
					break;
				case "fr":
				case "restart":
				case "maprestart":
					logline1 = "CMD:" + player.name + ";FR" + "\n";
					logprint( logline1 );
					level thread change_level();
					level notify( "end_commands", 0 );
					break;
				case "nm":
				case "nextmap":
                case "setnextmap":
					logline1 = "CMD:" + player.name + ";NM:" + args[ 1 ] + "\n";
					logprint( logline1 );
                    find_alias_and_set_map( toLower( args[ 1 ] ), player, 0 );
                    break;
				case "mr":
                case "maprotate":
					logline1 = "CMD:" + player.name + ";MR" + "\n";
					logprint( logline1 );
					level thread change_level();
					level notify( "end_commands", 1 );
                    break;
				case "m":
				case "map":
					logline1 = "CMD:" + player.name + ";MAP:" + args[ 1 ] + "\n";
					logprint( logline1 );
					find_alias_and_set_map( toLower( args[ 1 ] ), player, 1 );
					break;
				case "rr":
				case "resetrotation":
					logline1 = "CMD:" + player.name + ";RR" + "\n";
					logprint( logline1 );
					player tell( "Map rotation reset to the default" );
					setDvar( "sv_maprotation", getDvar( "grief_original_rotation" ) );
					setDvar( "sv_maprotationCurrent", getDvar( "grief_original_rotation" ) );
					break;
				// case "s":
				// case "swap":
				// case "switchteam":
				// 	player1 = grief_set_buffer_team( clean_player_name_of_clantag( args[ 1 ] ) );
				// 	if ( !isDefined( player1 ) )
				// 	{
				// 		continue;
				// 	}
				// 	player2 = grief_set_buffer_team( clean_player_name_of_clantag( args[ 1 ] ) );
				// 	if ( !isDefined( player2 ) )
				// 	{
				// 		continue;
				// 	}
				// 	player1.grief_desired_team = player2.grief_og_team;
				// 	player2.grief_desired_team = player1.grief_og_team;
				// 	player1 set_team( 1 );
				// 	player2 set_team( 1 );
				// 	break;
				case "k":
				case "kick":
					foreach ( player in level.players )
					{
						if ( clean_player_name_of_clantag( player.name ) == clean_player_name_of_clantag( args[ 1 ] ) )
						{
							logline1 = "CMD:" + player.name + ";K:" + args[ 1 ] + "\n";
							logprint( logline1 );
							say( clean_player_name_of_clantag( player.name ) + " has been kicked!" );
							kick( player getEntityNumber() );
							break;
						}
					}
					break;
				case "vm":
				case "votemap":
					if ( !is_true( level.mapvote_in_progress ) )
					{
						logline1 = "CMD:" + player.name + ";MVS:" + args[ 1 ] + "\n";
						logprint( logline1 );
						level thread mapvote_started();
						level thread mapvote_count_votes();
						level thread mapvote_end();
						level.mapvote_in_progress = 1;
						say( "Mapvote started!" );
					}
					level notify( "grief_mapvote", args[ 1 ], player );
					break;
				case "vk":
				case "votekick":
					if ( level.players.size < 3 )
					{
						player tell( "Not enough players to initiate a votekick" );
						break;
					}
					if ( !is_true( level.votekick_in_progress ) )
					{
						logline1 = "CMD:" + player.name + ";VKS:" + args[ 1 ] + "\n";
						logprint( logline1 );
						level thread vote_kick_started();
						level thread votekick_count_votes();
						level.votekick_in_progress = 1;
						say( "Votekick started!" );
					}
					level notify( "grief_votekick", args[ 1 ], player );
					break;
				// case "gts":
				// 	if ( !isDefined( args[ 1 ] ) || !isDefined( args[ 2 ] ) )
				// 	{
				// 		player tell( "You need to specify a gts and its value" );
				// 		break;
				// 	}
				// 	player tell( "Gametype setting set " + args[ 1 ] + " to " + args[ 2 ] );
				// 	logline1 = "CMD:" + player.name + ";GTS:" + args[ 1 ] + ";VAL:" + args[ 2 ] + "\n";
				// 	logprint( logline1 );
				// 	setgametypeSetting( args[ 1 ], args[ 2 ] );
				// 	break;
				case "mag":
				case "magic":
				case "nomagic":
					logline1 = "CMD:" + player.name + ";TOGMAG" + "\n";
					logprint( logline1 );
					say( "Magic is disabled" );
					no_magic();
					break;
				case "np":
				case "drops":
				case "powerups":
					logline1 = "CMD:" + player.name + ";TOGDROPS" + "\n";
					logprint( logline1 );
					say( "Powerups are disabled" );
					no_drops();
					break;
				case "rn":
				case "roundnumber":
					if ( !isDefined( args[ 1 ] ) )
					{
						player tell( "You need to specify a round number" );
						break;
					}
					logline1 = "CMD:" + player.name + ";ROUND:" + args[ 1 ] + "\n";
					logprint( logline1 );
					say( "The round is set to " + args[ 1 ] );
					set_round( int( args[ 1 ] ) );
					break;
				case "d":
				case "dvar":
					if ( !isDefined( args[ 1 ] ) || !isDefined( args[ 2 ] ) )
					{
						player tell( "You need to specify a dvar and its value" );
						break;
					}
					player tell( "Dvar set " + args[ 1 ] + " to " + args[ 2 ] );
					logline1 = "CMD:" + player.name + ";DVAR:" + args[ 1 ] + ";VAL:" + args[ 2 ] + "\n";
					logprint( logline1 );
					setDvar( args[ 1 ], args[ 2 ] );
					break;
				case "cv":
				case "cvar":
					if ( !isDefined( args[ 1 ] ) || !isDefined( args[ 2 ] ) )
					{
						player tell( "You need to specify a dvar and its value" );
						break;
					}
					player tell( "Cvar set " + args[ 1 ] + " to " + args[ 2 ] );
					logline1 = "CMD:" + player.name + ";CVAR:" + args[ 1 ] + ";VAL:" + args[ 2 ] + "\n";
					logprint( logline1 );
					player setClientDvar( args[ 1 ], args[ 2 ] );
					break;
				case "cva":
				case "cvarall":
					if ( !isDefined( args[ 1 ] ) || !isDefined( args[ 2 ] ) )
					{
						player tell( "You need to specify a dvar and its value" );
						break;
					}
					foreach ( player in level.players )
					{
						player tell( "Cvar set " + args[ 1 ] + " to " + args[ 2 ] );
						logline1 = "CMD:" + player.name + ";CVARA:" + args[ 1 ] + ";VAL:" + args[ 2 ] + "\n";
						logprint( logline1 );
						player setClientDvar( args[ 1 ], args[ 2 ] );
					} 
					break;
				case "l":
				case "lock":
				case "lockserver":
					if ( !isDefined( args[ 1 ] ) )
					{
						player tell( "You need to specify a password to lock the server" );
						break;
					}
					player tell( "Server is now password protected" );
					logline1 = "CMD:" + player.name + ";LOCK:" + args[ 1 ] + "\n";
					logprint( logline1 );
					setDvar( "g_password", args[ 1 ] );
					break;
				case "ul":
				case "unlock":
				case "unlockserver":
					player tell( "Server is now open" );
					logline1 = "CMD:" + player.name + ";UNLOCK:" + "\n";
					logprint( logline1 );
					setDvar( "g_password", "" );
					break;
				// case "im":
				// case "intermission":
				// 	level.grief_gamerules[ "intermission_time" ] = args[ 1 ];
				// 	say( "Intermission will take place after next round and last " + args[ 1 ] );
				// 	logline1 = "CMD:" + player.name + ";IM" + ";TIME:" + args[ 1 ] + "\n";
				// 	logprint( logline1 );
				// 	break;
				case "bot":
				case "spawnbot":
					bot = addtestClient();
					bot.pers[ "IsBot" ] = 1;
					if ( isDefined( args[ 1 ] ) )
					{
						say( "Bot spawned on team " + args[ 1 ] );
						logline1 = "CMD:" + player.name + ";BOT" + ";TEAM:" + args[ 1 ] + "\n";
						logprint( logline1 );
						bot.custom_team = args[ 1 ];
					}
					else 
					{
						say( "Bot spawned in" );
						logline1 = "CMD:" + player.name + ";BOT:" + "\n";
						logprint( logline1 );
					}
					break;
				default:
					player tell( "No such command exists" );
					break;
            }
        }
    }
}

end_commands_on_end_game()
{
	level waittill( "end_game" );
	wait 15;
	level notify( "end_commands" );
}

change_level()
{
	level waittill( "end_commands", result );
	wait 0.5;
	switch ( result )
	{
		case 0:
			cmdExecute( "map_restart" );
			break;
		case 1:
			cmdExecute( "map_rotate" );
			break;
		default:
			break;
	}
}

vote_kick_started()
{
	level endon( "end_game" );
	level endon( "grief_votekick_ended" );

	for ( i = 0; i < level.players.size; i++ )
	{
		level.players[ i ].kick_votes = 0;
	}
	while ( true )
	{
		level waittill( "grief_votekick", player_name, player );
		if ( !isDefined( player_name ) )
		{
			continue;
		}
		if ( is_true( player.vk_voted ) )
		{
			continue;
		}
		for( i = 0; i < level.players.size; i++ )
		{
			if ( clean_player_name_of_clantag( player_name ) == clean_player_name_of_clantag( level.players[ i ].name ) )
			{	
				level.players[ i ].kick_votes++;
				player tell( level.players[ i ].name + " has " + level.players[ i ].kick_votes + "/" + get_vote_threshold() + " votes needed to be kicked" );
				player.vk_voted = 1;
			}
		}
	}
}

votekick_count_votes()
{
	level endon( "end_game" );
	level endon( "grief_votekick_ended" );
	start_time = getTime() / 1000;
	while ( true )
	{
		for ( i = 0; i < level.players.size; i++ )
		{
			if ( level.players[ i ].kick_votes >= get_vote_threshold() )
			{
				kick( level.players[ i ] getEntityNumber() );
				say( level.players[ i ].name + " was kicked!" );
				level.votekick_in_progress = 0;
				logline1 = "VK;" + level.players[ i ].name + ":K" + "\n";
				logprint( logline1 );
				for ( i = 0; i < level.players.size; i++ )
				{
					level.players[ i ].vk_voted = 0;
				}
				level notify( "grief_votekick_ended" );
			}
		}
		if ( ( getTime() / 1000 ) > ( start_time + 180 ) )
		{	
			say( "Vote kick timed out!" );
			level.votekick_in_progress = 0;
			logline1 = "VK;TIMEOUT" + "\n";
			logprint( logline1 );
			for ( i = 0; i < level.players.size; i++ )
			{
				level.players[ i ].vk_voted = 0;
			}
			level notify( "grief_votekick_ended" );
		}
		wait 0.05;
	}
}

get_vote_threshold()
{
	switch ( level.players.size )
	{
		case 3:
			return 2;
		case 4:
			return 3;
		case 5:
			return 4;
		case 6:
			return 4;
		case 7:
			return 5;
		case 8:
			return 5;
		default:
			return 99;
	}
}

setup_permissions()
{
    level.server_users = [];
    level.server_users[ "Admins" ] = spawnStruct();
    level.server_users[ "Admins" ].names = [];
    level.server_users[ "Admins" ].guids = [];
	//level.server_users[ "Admins" ].guids_hex = [];
    // level.server_users[ "Moderators" ] = spawnStruct();
    // level.server_users[ "Moderators" ].names = [];
    // level.server_users[ "Moderators" ].guids = [];
    // level.server_users[ "TrustedUsers" ] = spawnStruct();
    // level.server_users[ "TrustedUsers" ].names = [];
    // level.server_users[ "TrustedUsers" ].guids = [];
    path = level.basepath + "command_permissions.txt";
    file = fopen( path, "r+" );
	buffer = fread( file );
    fclose( file );
	rank_type = strTok( buffer, ":" );
	names_and_guids = strTok( rank_type[ 1 ], "," );
	rank = rank_type[ 0 ];
	for ( j = 0; j < names_and_guids.size; j++ )
	{
		names_keys = strTok( names_and_guids[ j ], "<" );
		level.server_users[ rank ].names[ j ] = names_keys[ 0 ];
	}
	for ( j = 0; j < names_and_guids.size; j++ )
	{
		guids_keys = strTok( names_and_guids[ j ], "<" );
		level.server_users[ rank ].guids[ j ] = int( guids_keys[ 1 ] );
		// hex = DecToHex2( guids_keys[ 1 ] );
		// level.server_users[ rank ].guids_hex[ j ] = hex;
	}
}

find_alias_and_set_map( mapname, player, map_rotate )
{
    switch ( mapname )
    {
		case "c":
		case "cell":
		case "block":
        case "cellblock":
            gamemode = "grief";
            location = "cellblock";
            mapname = "zm_prison";
            break;
		case "s":
        case "street":
		case "borough":
		case "buried":
            gamemode = "grief";
            location = "street";
            mapname = "zm_buried";
            break;
		case "f":
        case "farm":
            gamemode = "grief";
            location = "farm";
            mapname = "zm_transit";
            break;
		case "t":
        case "town":
            gamemode = "grief";
            location = "town";
            mapname = "zm_transit";
            break;
		case "b":
		case "bus":
        case "depot":
            gamemode = "grief";
            location = "transit";
            mapname = "zm_transit";
            break;
		case "d":
		case "din":
		case "diner":
            gamemode = "grief";
            location = "diner";
            mapname = "zm_transit";
            break;
		case "tu":
        case "tunnel":
            gamemode = "grief";
            location = "tunnel";
            mapname = "zm_transit";
            break;
		case "p":
		case "pow":
        case "power":
            gamemode = "grief";
            location = "power";
            mapname = "zm_transit";
            break;
        default:
			if ( isDefined( player ) )
			{
				player tell( "Invalid map" );
			}
            return;
    }
	if ( getDvar( "grief_original_rotation" ) == "" )
	{
		setDvar( "grief_original_rotation", getDvar( "sv_maprotation" ) );
	}
    setDvar( "sv_maprotation", "exec zm_" + gamemode + "_" + location + ".cfg" + " map " + mapname );
	setDvar( "sv_maprotationCurrent", "exec zm_" + gamemode + "_" + location + ".cfg" + " map " + mapname );
	if ( map_rotate )
	{
		setDvar( "grief_new_map_set", 1 );
		level thread change_level();
		level notify( "end_commands", 1 );
	}
	else
	{
		say( "Next map set to " + mapname + " " + location );
		setDvar( "grief_new_map_set", 1 );
	}
}

give_player_points( points )
{
    self.score += points;
    self.pers[ "score" ] = self.score;
    self.score_total += points;
}

has_permissions_for_command( command, args )
{
	for ( i = 0; i < level.grief_no_permissions_required_commands; i++ )
	{
		if ( command == level.grief_no_permissions_required_commands[ i ] )
		{
			return 1;
		}
	}
    for ( i = 0; i < level.server_users[ "Admins" ].names.size; i++ )
    {
        if ( self getGUID() == level.server_users[ "Admins" ].guids[ i ] )
        {
            return 1;
        }
    }
    return 0;
}

initialize_no_permissions_required_commands()
{
	level.grief_no_permissions_required_commands = [];
	level.grief_no_permissions_required_commands[ 0 ] = "mv";
	level.grief_no_permissions_required_commands[ 1 ] = "mapvote";
	level.grief_no_permissions_required_commands[ 2 ] = "v";
	level.grief_no_permissions_required_commands[ 3 ] = "vk";
	level.grief_no_permissions_required_commands[ 4 ] = "votekick";

	level.mapvote_array = [];
	level.mapvote_array[ 0 ] = spawnStruct();
	level.mapvote_array[ 0 ].mapname = "cellblock";
	level.mapvote_array[ 0 ].aliases = array( "c", "cell", "block", "cellblock", "mob" );
	level.mapvote_array[ 0 ].votes = 0;
	level.mapvote_array[ 1 ] = spawnStruct();
	level.mapvote_array[ 1 ].mapname = "borough";
	level.mapvote_array[ 1 ].aliases = array( "s", "street", "borough", "buried" );
	level.mapvote_array[ 1 ].votes = 0;
	level.mapvote_array[ 2 ] = spawnStruct();
	level.mapvote_array[ 2 ].mapname = "farm";
	level.mapvote_array[ 2 ].aliases = array( "f", "farm" );
	level.mapvote_array[ 2 ].votes = 0;
	level.mapvote_array[ 3 ] = spawnStruct();
	level.mapvote_array[ 3 ].mapname = "town";
	level.mapvote_array[ 3 ].aliases = array( "t", "town" );
	level.mapvote_array[ 3 ].votes = 0;
	level.mapvote_array[ 4 ] = spawnStruct();
	level.mapvote_array[ 4 ].mapname = "depot";
	level.mapvote_array[ 4 ].aliases = array( "b", "bus", "depot" );
	level.mapvote_array[ 4 ].votes = 0;
	level.mapvote_array[ 5 ] = spawnStruct();
	level.mapvote_array[ 5 ].mapname = "diner";
	level.mapvote_array[ 5 ].aliases = array( "d", "din", "diner" );
	level.mapvote_array[ 5 ].votes = 0;
	level.mapvote_array[ 6 ] = spawnStruct();
	level.mapvote_array[ 6 ].mapname = "tunnel";
	level.mapvote_array[ 6 ].aliases = array( "t", "tunnel" );
	level.mapvote_array[ 6 ].votes = 0;
	level.mapvote_array[ 7 ] = spawnStruct();
	level.mapvote_array[ 7 ].mapname = "power";
	level.mapvote_array[ 7 ].aliases = array( "p", "pow", "power" );
	level.mapvote_array[ 7 ].votes = 0;
}

mapvote_started()
{
	level endon( "end_game" );
	level endon( "grief_mapvote_ended" );
	while ( true )
	{
		level waittill( "grief_mapvote", vote, player );
		if ( !isDefined( vote ) )
		{
			continue;
		}
		if ( !isDefined( player.previous_votes ) )
		{
			player.previous_votes = [];
		}
		mapname = "NULL";
		for ( i = 0; i < level.mapvote_array.size; i++ )
		{
			if ( mapname != "NULL" )
			{
				player.has_mapvoted_previously = 1;
				break;
			}
			for ( j = 0; j < level.mapvote_array[ i ].aliases.size; j++ )
			{
				if ( level.mapvote_array[ i ].aliases[ j ] == vote )
				{
					mapname = level.mapvote_array[ i ].mapname;
					player.previous_votes[ player.previous_votes.size ] = mapname;
					if ( is_true( player.has_mapvoted_previously ) )
					{
						for ( k = 0; k < player.previous_votes.size; k++ )
						{
							if ( player.previous_votes[ k ] != mapname )
							{
								level.mapvote_array[ i ].votes++;
								player tell( "You voted for " + mapname + " which has " + level.mapvote_array[ i ].votes + "/" + get_vote_threshold() + " votes" );
								logline1 = "MV:" + player.name + ";V:" + mapname + "\n";
								logprint( logline1 );
								break;
							}
						}
					}
					else 
					{
						level.mapvote_array[ i ].votes++;
						player tell( "You voted for " + mapname + " which has " + level.mapvote_array[ i ].votes + "/" + get_vote_threshold() + " votes" );
						logline1 = "MV:" + player.name + ";V:" + mapname + "\n";
						logprint( logline1 );
						break;
					}
				}
			}
		}
		if ( mapname == "NULL" )
		{
			player tell( "Invalid map" );
		}
	}
}

mapvote_count_votes()
{
	level endon( "end_game" );
	level endon( "grief_mapvote_ended" );
	start_time = getTime() / 1000;
	current_time = start_time;
	while ( true )
	{
		for ( i = 0; i < level.mapvote_array.size; i++ )
		{
			if ( level.mapvote_array[ i ].votes >= get_vote_threshold() )
			{
				map = level.mapvote_array[ i ].mapname;
				break;
			}
		}
		if ( isDefined( map ) )
		{
			break;
		}
		if ( ( getTime() / 1000 ) > ( start_time + 180 ) )
		{	
			level notify( "grief_mapvote_ended" );
		}
		wait 0.05;
	}
	level notify( "grief_mapvote_ended", map );
}

mapvote_end()
{
	level waittill( "grief_mapvote_ended", result );
	if ( isDefined( result ) )
	{
		logline1 = "MV;" + "MAP:" + result + "\n";
		logprint( logline1 );
		find_alias_and_set_map( toLower( result ), undefined, 0 );
	}
	else 
	{
		logline1 = "MV:TIMEOUT;" + "\n";
		logprint( logline1 );
		say( "Mapvote timed out!" );
	}
	level.mapvote_in_progress = 0;
	foreach ( player in level.players )
	{
		player.previous_votes = [];
	}
	for ( i = 0; i < level.mapvote_array.size; i++ )
	{
		level.mapvote_array[ i ].votes = 0;
	}
}

dec2hex( dec ) //credit to fed for this function
{
	hex = "";
	digits = strTok("0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F", ",");
	while ( dec > 0 ) 
	{
		hex = digits[int(dec) % 16] + hex;
		dec = floor(dec / 16);
	}
	return hex;
}

DecToHex2( dec ) //credit to sorex for this function
{
	value = dec;
	hex = "";
	while(value > 0){
	    newVal = (int(int(value)%16));
	    if(newVal > 9){
	    	switch(newVal){
	    		case 10:
	    			hex = "A" + hex ;
	    		break;
	    		case 11:
	    			hex = "B" + hex ;
	    		break;
	    		case 12:
	    			hex = "C" + hex ;
	    		break;
	    		case 13:
	    			hex = "D" + hex ;
	    		break;
	    		case 14:
	    			hex = "E" + hex ;
	    		break;
	    		case 15:
	    			hex = "F" + hex ;
	    		break;
	    	}
	    }else
			hex = newVal + hex ;
		value = (int(int(value)/16));
	}
	if((int(value)/16) > 0)
		hex = hex + value;
	return int( hex );
}

zombie_spawn_delay_fix()
{
	i = 1;
	while ( i <= level.round_number )
	{
		timer = level.zombie_vars[ "zombie_spawn_delay" ];
		if ( timer > 0.08 )
		{
			level.zombie_vars[ "zombie_spawn_delay" ] = timer * 0.95;
			i++;
			continue;
		}
		if ( timer < 0.08 )
		{
			level.zombie_vars[ "zombie_spawn_delay" ] = 0.08;
			break;
		}
		i++;
	}
}

zombie_speed_fix()
{
	if ( level.gamedifficulty == 0 )
	{
		level.zombie_move_speed = level.round_number * level.zombie_vars[ "zombie_move_speed_multiplier_easy" ];
	}
	else
	{
		level.zombie_move_speed = level.round_number * level.zombie_vars[ "zombie_move_speed_multiplier" ];
	}
}

set_round( round_number )
{
	if ( isDefined( level._grief_reset_message ) )
	{
		level thread [[ level._grief_reset_message ]]();
	}
	level.isresetting_grief = 1;
	level notify( "end_round_think" );
	level.zombie_vars[ "spectators_respawn" ] = 1;
	level notify( "keep_griefing" );
	level.checking_for_round_end = 0;
	level.round_number = round_number;
	zombie_goto_round( round_number );
	zombie_spawn_delay_fix();
	zombie_speed_fix();
	level thread reset_grief();
	level thread maps/mp/zombies/_zm::round_think( 1 );
	level notify( "grief_give_points" );
}
