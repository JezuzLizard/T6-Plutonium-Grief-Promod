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

init()
{
	level thread monitor_players_connecting_status();
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
        level thread on_player_connect();
		if ( getDvarInt( "grief_testing" ) )
		{
			level thread test_bots();
		}
		level thread draw_hud();
		wait 15;
		level thread instructions_on_all_players();
		
    }
}

monitor_players_connecting_status()
{
	level.num_players_connecting = 0;
	while ( true )
	{
		level waittill( "connecting", player );
		level.num_players_connecting++;
		logline1 = "Player: " + player.name + " is connecting " + "\n";
		logprint( logline1 );
		if ( level.num_players_connecting > 0 )
		{
			player thread kick_player_if_dont_spawn_in_time();
		}
		player thread watch_for_disconnect();
	}
}

watch_for_disconnect()
{
	self waittill_either( "disconnect", "begin" );
	level.num_players_connecting--;
}

kick_player_if_dont_spawn_in_time()
{
	self endon( "begin" );
	wait 20;
	logline1 = "Kicking player because they failed to notify begin in less than 12 seconds" + "\n";
	logprint( logline1 );
	kick( self getEntityNumber() );

}

monitor_players_connection_status()
{
	while ( true )
	{
		level waittill( "connected", player );
		logline1 = "Player: " + player.name + " is connected " + "\n";
		logprint( logline1 );
	}
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
		//player thread grief_spawn_protection(); //too op for the game
		if ( !isDefined( player.last_griefed_by ) )
		{
			player.last_griefed_by = spawnStruct();
			player.last_griefed_by.attacker = undefined;
			player.last_griefed_by.meansofdeath = undefined;
			player.last_griefed_by.weapon = undefined;
		}
		player thread give_points_on_restart_and_round_change();
       	player set_team();
		player [[ level.givecustomcharacters ]]();
		player.killsconfirmed = 0;
		player.stabs = 0;
		player.assists = 0;
		player thread watch_for_down();
    }
}

give_points_on_restart_and_round_change()
{
	level endon( "end_game" );
	while ( true )
	{
		level waittill( "start_of_round" );
		if ( self.score < 8000 )
		{
			self.score = 8000;
		}
	}
}

grief_spawn_protection()
{
	self.has_grief_spawn_protection = true;
	wait 10;
	self.has_grief_spawn_protection = false;
}

set_team()
{
	teamplayersallies = countplayers( "allies");
	teamplayersaxis = countplayers( "axis");
	if ( getDvarInt( "grief_gamerule_use_preset_teams" ) )
	{
	 	allies_team_members = getDvar( "grief_allies_team_player_names" );
		team_keys = strTok( allies_team_members, " " ); 
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
					team_is_defined = true;
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
				team_is_defined = true;
				logline1 = "player didn't have name match: " + self.name + " to preset team: " + self.team + "\n";
				logprint( logline1 );
			}
			else 
			{
				self.team = "allies";
				self.sessionteam = "allies";
				self.pers[ "team" ] = "allies";
				self._encounters_team = "B";
				team_is_defined = true;
				logline1 = "player team failsafe: " + self.name + " to preset team: " + self.team + "\n";
				logprint( logline1 );
			}
		}
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

init_gamerules()
{
	level.default_solo_laststandpistol = "m1911_zm";
	level.is_forever_solo_game = undefined;
	level.speed_change_round = undefined;
	level.grief_gamerules = [];
	level.grief_gamerules[ "scorelimit" ] = getDvarIntDefault( "grief_gamerule_scorelimit", 3 );
	level.grief_gamerules[ "zombies_per_round" ] = getDvarIntDefault( "grief_gamerule_zombies_per_round", 3 );
	level.grief_gamerules[ "perk_restrictions" ] = getDvar( "grief_gamerule_perk_restrictions" );
	level.grief_gamerules[ "mystery_box_enabled" ] = getDvarIntDefault( "grief_gamerule_mystery_box_enabled" );
	level.grief_gamerules[ "wall_weapon_restrictions" ] = getDvar( "grief_gamerule_wall_weapon_restrictions" );
	level.grief_gamerules[ "next_round_time" ] = getDvarIntDefault( "grief_gamerule_next_round_timer", 5 );
	level.grief_gamerules[ "intermission_time" ] = getDvarIntDefault( "grief_gamerule_intermission_time", 0 );
	level.grief_gamerules[ "door_restrictions" ] = getDvar( "grief_gamerule_door_restrictions" );
	level.grief_gamerules[ "round_restart_points" ] = getDvarIntDefault( "grief_gamerule_round_restart_points" );
	level.grief_gamerules[ "use_preset_teams" ] = getDvarIntDefault( "grief_gamerule_use_preset_teams", 0 );
	level.grief_gamerules[ "disable_zombie_special_runspeeds" ] = getDvarIntDefault( "grief_gamerules_disable_zombie_special_runspeeds", 1 );
	level.grief_gamerules[ "suicide_check" ] = getDvarFloatDefault( "grief_gamerule_suicide_check_wait", 5 );
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
grief_parse_wall_weapon_restrictions( weapon )
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
		level thread perk_machine_removal( key );
	}
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
	remaining.hidewheninmenu = true;
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
	countdown.hidewheninmenu = true;
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
	remaining.hidewheninmenu = true;
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
	countdown.hidewheninmenu = true;
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
    level.remaining_zombies_hud.hidewheninmenu = true;
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
    level.grief_score_hud[ "A" ].hidewheninmenu = true;
	level.grief_score_hud[ "A" ] setValue( 0 );
	level.grief_score_hud[ "B" ] = create_simple_hud();
    level.grief_score_hud[ "B" ].x += 240;
    level.grief_score_hud[ "B" ].y += 20;
    level.grief_score_hud[ "B" ].fontscale = 2.5;
    level.grief_score_hud[ "B" ].color = ( 0.423, 0.004, 0 );
	level.grief_score_hud[ "B" ].alpha = 1;
    level.grief_score_hud[ "B" ].hidewheninmenu = true;
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
		level.team_shader1.hidewheninmenu = true;
		level.team_shader1.label = &"Inmates "; 
		level.team_shader2.x += 170;
		level.team_shader2.y += 20;
		level.team_shader2.fontscale = 2.5;
		level.team_shader2.color = ( 0, 0.004, 0.423 );
		level.team_shader2.alpha = 1;
		level.team_shader2.hidewheninmenu = true;
		level.team_shader2.label = &"Guards "; 
	}
	else 
	{
		level.team_shader1.x += 90;
		level.team_shader1.y += -20;
		level.team_shader1.hideWhenInMenu = true;
		level.team_shader2.x += -110;
		level.team_shader2.y += -20;
		level.team_shader2.hideWhenInMenu = true;
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
		self thread do_game_mode_shellshock( eattacker, smeansofdeath );
		self playsound( "zmb_player_hit_ding" );
	}
}

do_game_mode_shellshock( attacker, meansofdeath ) //checked matched cerberus output
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
	wait 0.75;
	self._being_shellshocked = 0;
}

watch_for_down( attacker, weapon, meansofdeath )
{
	if ( is_true( self.grief_already_checking_for_down ) )
	{
		return;
	}
	self.grief_already_checking_for_down = true;
	self waittill_notify_or_timeout( "player_downed", 3 );
	if ( self player_is_in_laststand() )
	{
		if ( isDefined( self.last_griefed_by.attacker ) )
		{
			self player_steal_points( self.last_griefed_by.attacker, "down_player" );
			if ( isDefined( self.last_griefed_by.attacker ) && isDefined( self.last_griefed_by.meansofdeath ) )
			{
				obituary( self, self.last_griefed_by.attacker, self.last_griefed_by.weapon, self.last_griefed_by.meansofdeath );
				attacker.pers[ "killsconfirmed" ]++;
			}
		}
	}
	self.grief_already_checking_for_down = false;
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
	if ( isDefined( attacker ) && isDefined( self ) )
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
				self.is_reviving_grief = true;
			}
			self applyknockback( idamage, vdir );
		}
		else if ( is_weapon_shotgun( sweapon ) )
		{
			if ( self is_reviving_any() )
			{
				self.is_reviving_grief = true;
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
				knocked_off_revive = true;
			}
		}
	}
	if ( is_true( knocked_off_revive ) )
	{
		self player_steal_points( eattacker, "deny_revive" );
	}
	self.is_reviving_grief = false;
}