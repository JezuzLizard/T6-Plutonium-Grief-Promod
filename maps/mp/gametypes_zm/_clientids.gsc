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
    if ( getDvar( "g_gametype" ) == "zgrief" )
    {
		init_gamemodes();
		init_gamerules();
		level.round_spawn_func = ::round_spawning;
		level._game_module_player_damage_callback = ::game_module_player_damage_callback;
		level._game_module_player_damage_grief_callback = ::game_module_player_damage_grief_callback;
		level.meat_bounce_override = ::meat_bounce_override;
		//level.allies = ::menuallieszombies;
		level.lowertexty = 0;
		setDvar( "sv_cheats", 1 );
		setDvar( "aim_automelee_enabled", 0 );
		setDvar( "g_friendlyfireDist", 0 );
		//level.czm_gamerule_weapon_restriction_list = ::grief_parse_wall_weapon_restrictions;
		level.grief_round_win_next_round_countdown = ::countdown_timer_hud;
		level.grief_round_intermission_countdown = ::intermission_hud();
		level.grief_loadout_save = ::grief_loadout_save;
		grief_parse_perk_restrictions();
        level thread on_player_connect();
		level thread draw_hud();
		if ( getDvarIntDefault( "grief_testing", 0 ) )
		{
			level.spawnclient = ::spawnclient;
			level thread test_bots();
		}
		level thread monitor_players_expected_and_connected();
		wait 10;
		//level thread shuffle_teams();
		level thread kick_players_not_playing();
    }
}

monitor_players_expected_and_connected()
{
	level endon( "end_game" );
	while ( true )
	{
		logline1 = "getNumExpectedPlayers(): " + getnumexpectedplayers() + " getNumConnectedPlayers(): " + getnumconnectedplayers();
		logprint( logline1 );
		wait 1;
		if ( flag( "initial_players_connected" ) )
		{
			break;
		}
	}
}

kick_players_not_playing()
{
	level endon( "end_game" );
	players = getPlayers();
	foreach ( player in players )
	{
		logline1 = "player.name: " + player.name + " player.sessionstate: " + player.sessionstate + "\n";
		logprint( logline1 );
		if ( player.sessionstate != "playing" )
		{
			player.sessionstate = "playing";
			if ( player.sessionstate != "playing" )
			{
				kick( player getEntityNumber() );
			}
		}
	}
}

draw_hud()
{
	level thread zombiesleft_hud();
	level thread grief_score();
	level thread grief_score_shaders();
	level thread destroy_hud_on_game_end();
}

on_player_connect()
{
	level endon( "end_game" );
    while ( true )
    {
    	level waittill( "connected", player );
		if ( !isDefined( player.last_griefed_by ) )
		{
			player.last_griefed_by = spawnStruct();
			player.last_griefed_by.attacker = undefined;
			player.last_griefed_by.meansofdeath = undefined;
			player.last_griefed_by.weapon = undefined;
		}
		player thread kick_ghost_client();
		player thread on_player_spawn();
		player thread give_points_on_restart_and_round_change();
       	player set_team();
		player [[ level.givecustomcharacters ]]();
    }
}

give_points_on_restart_and_round_change()
{
	level endon( "end_game" );
	while ( true )
	{
		level waittill( "start_of_round" );
		self.score = 10000;
	}
}

on_player_spawn()
{
	self endon( "disconnect" );
	level endon( "end_game" );
	while ( true )
	{
		self waittill( "spawned_player" );

	}
}

set_team()
{
	teamplayersallies = countplayers( "allies");
	teamplayersaxis = countplayers( "axis");
	if ( getDvarInt( "grief_gamerule_use_preset_teams" ) )
	{
	 	allies_team_members = getDvar( "grief_allies_team_player_names" );
		team_keys = strTok( allies_team_members, ";" ); 
		foreach ( key in team_keys )
		{
			if ( teamplayersallies < 4 )
			{
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
			else 
			{
				break;
			}
		}
		if ( !is_true( team_is_defined ) && ( teamplayersaxis < 4 ) )
		{
			self.team = "axis";
			self.sessionteam = "axis";
			self.pers[ "team" ] = "axis";
			self._encounters_team = "A";
			logline1 = "player didn't have name match: " + self.name + " to preset team: " + self.team + "\n";
			logprint( logline1 );
		}
		else if ( teamplayersallies < 4 )
		{
			self.team = "allies";
			self.sessionteam = "allies";
			self.pers[ "team" ] = "allies";
			self._encounters_team = "B";
			logline1 = "player axis team was full and player name didn't match:" + self.name + "to preset team: " + self.team + "\n";
			logprint( logline1 );
		}
	}
	else 
	{
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
		precacheshader( "faction_inmates" );
		precacheshader( "faction_guards" );
		//level.team_shader1 = createservericon( game[ "icons" ][ "axis" ], 35, 35 );
		//level.team_shader2 = createservericon( game[ "icons" ][ "allies" ], 35, 35 );
		level.team_shader1 = create_simple_hud();
		level.team_shader2 = create_simple_hud();
		text = 1;
	}
	else
	{
		level.team_shader1 = createservericon( game[ "icons" ][ "axis" ], 35, 35 );
		level.team_shader2 = createservericon( game[ "icons" ][ "allies" ], 35, 35 );
		//printf( "Using Tranzit/Buried shaders" );
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

	while ( 1 )
	{
		remainingZombies = get_current_zombie_count() + level.zombie_total;
		level.remaining_zombies_hud SetValue( remainingZombies );
		wait 0.05;
	}		
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
	if ( isDefined( eattacker) && isplayer( eattacker ) )
	{
		if ( smeansofdeath == "MOD_MELEE" )
		{
			eattacker.pers[ "stabs" ]++;
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
		self thread watch_for_down( eattacker, sweapon, smeansofdeath );
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
	self waittill_notify_or_timeout( "player_downed", 5 );
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
				points_to_steal = 50;
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
				points_to_steal = 100;
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

is_weapon_shotgun( sweapon )
{
	if ( weaponclass( sweapon ) == "spread" )
	{
		return 1;
	}
	return 0;
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
	//Then spawn bots
	botsToSpawn = getDvarIntDefault( "debugModBotsToSpawn", 7 );
	for ( currentBots = 0; currentBots < botsToSpawn; currentBots++ )
	{
		wait 1;
		zbot_spawn();
	}
	SetDvar("bot_AllowMovement", "1");
	SetDvar("bot_PressAttackBtn", "1");
	SetDvar("bot_PressMeleeBtn", "1");
}

zbot_spawn()
{
	bot = AddTestClient();
	if ( !IsDefined( bot ) )
	{
		logline1 = "bot is not defined! " + "\n";
		logprint( logline1 );
		return;
	}
			
	//bot.pers[ "isBot" ] = true;
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
	init_gamelengths();
}

init_gamemodes()
{
	level.grief_gamemodes = [];
	level.grief_gamemodes[ "tdm" ] = spawnStruct();
	level.grief_gamemodes[ "tdm" ].respawn_delay = 5;
	level.grief_gamemodes[ "tdm" ].optional_spawn = 1;
}

init_gamelengths()
{
	level.grief_game_lengths = [];
	level.grief_game_lengths[ "short" ] = [];
	level.grief_game_lengths[ "short" ][ "perk_restrictions" ] = "specialty_quickrevive specialty_armorvest specialty_weapupgrade";
	level.grief_game_lengths[ "short" ][ "zombies_per_round" ] = 3;
	level.grief_game_lengths[ "short" ][ "scorelimit" ] = 3;
	level.grief_game_lengths[ "short" ][ "mystery_box_enabled" ] = 0;
	level.grief_game_lengths[ "short" ][ "door_restrictions" ] = "";
	level.grief_game_lengths[ "short" ][ "start_round" ] = 20;
	level.grief_game_lengths[ "short" ][ "restart_points" ] = level.round_number * 500;
	level.grief_game_lengths[ "medium" ] = [];
	level.grief_game_lengths[ "medium" ][ "perk_restrictions" ] = "specialty_weapupgrade";
	level.grief_game_lengths[ "medium" ][ "zombies_per_round" ] = 3;
	level.grief_game_lengths[ "medium" ][ "scorelimit" ] = 5;
	level.grief_game_lengths[ "medium" ][ "mystery_box_enabled" ] = 1;
	level.grief_game_lengths[ "medium" ][ "door_restrictions" ] = "";
	level.grief_game_lengths[ "medium" ][ "start_round" ] = 10;
	level.grief_game_lengths[ "long" ] = [];
	level.grief_game_lengths[ "long" ][ "perk_restrictions" ] = "";
	level.grief_game_lengths[ "long" ][ "zombies_per_round" ] = 3;
	level.grief_game_lengths[ "long" ][ "scorelimit" ] = 5;
	level.grief_game_lengths[ "long" ][ "mystery_box_enabled" ] = 1;
	level.grief_game_lengths[ "long" ][ "door_restrictions" ] = "";
	level.grief_game_lengths[ "long" ][ "start_round" ] = 1;
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

countdown_timer_hud()
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
	level.gdm_countdown_timer = remaining;
	level.gdm_countdown_text = countdown;
	timer = level.grief_gamerules[ "next_round_time" ];
	while ( 1 )
	{
		level.gdm_countdown_timer setValue( timer ); 
		wait 1;
		timer--;
		if ( timer <= 5 )
		{
			countdown_pulse( level.gdm_countdown_timer, timer );
			break;
		}
	}
	if ( isDefined( level.gdm_countdown_text ) )
	{
		level.gdm_countdown_text destroy();
	}
	if ( isDefined( level.gdm_countdown_timer ) )
	{
		level.gdm_countdown_timer destroy();
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
	level.gdm_countdown_timer = remaining;
	level.gdm_countdown_text = countdown;
	timer = level.grief_gamerules[ "intermission_time" ];
	while ( 1 )
	{
		level.gdm_countdown_timer setValue( timer ); 
		wait 1;
		timer--;
		if ( timer <= 5 )
		{
			countdown_pulse( level.gdm_countdown_timer, timer );
			break;
		}
	}
	if ( isDefined( level.gdm_countdown_text ) )
	{
		level.gdm_countdown_text destroy();
	}
	if ( isDefined( level.gdm_countdown_timer ) )
	{
		level.gdm_countdown_timer destroy();
	}
}

destroy_hud_on_game_end()
{
	level waittill( "end_game" );
	if ( isDefined( level.gdm_countdown_timer ) )
	{
		level.gdm_countdown_timer destroy();
	}
	if ( isDefined( level.gdm_countdown_text ) )
	{
		level.gdm_countdown_text destroy();
	}
}

destroy_hud_on_game_end()
{
	level waittill( "end_game" );
	if ( isDefined( level.grief_score_hud[ "A" ] ) )
	{
		//level.grief_score_hud[ "A" ] destroy();
		//level.grief_score_hud[ "B" ].alpha = 0;
	}
	if ( isDefined( level.grief_score_hud[ "B" ] ) )
	{
		//level.grief_score_hud[ "B" ] destroy();
		//level.grief_score_hud[ "B" ].alpha = 0;
	}
	if ( isDefined( level.team_shader1 ) ) 
	{
		//level.team_shader1 destroy();
		//level.team_shader1.alpha = 0;
	}
	if ( isDefined( level.team_shader2 ) ) 
	{
		//level.team_shader2 destroy();
		//level.team_shader2.alpha = 0;
	}
	if ( isDefined( level.remaining_zombies_hud ) )
	{
		level.remaining_zombies_hud destroy();
		level.remaining_zombies_hud.alpha = 0;
	}
}

kick_ghost_client()
{
	entity_num = self getEntityNumber();
	self waittill( "disconnect" );
	kick( entity_num );
}

spawnclient( timealreadypassed ) //checked matches cerberus output
{
	pixbeginevent( "spawnClient" );
	if ( !self mayspawn() )
	{
		currentorigin = self.origin;
		currentangles = self.angles;
		self showspawnmessage();
		self thread [[ level.spawnspectator ]]( currentorigin + vectorScale( ( 0, 0, 1 ), 60 ), currentangles );
		pixendevent();
		logline1 = "client may not spawn" + "\n";
		logprint( logline1 );
		return;
	}
	if ( self.waitingtospawn )
	{
		pixendevent();
		logline1 = "client is waiting to spawn already" + "\n";
		logprint( logline1 );
		return;
	}
	self.waitingtospawn = 1;
	self.allowqueuespawn = undefined;
	self waitandspawnclient( timealreadypassed );
	if ( isDefined( self ) )
	{
		self.waitingtospawn = 0;
	}
	pixendevent();
}

waitandspawnclient( timealreadypassed ) //checked matches cerberus output
{
	logline1 = "waitAndSpawnClient() is called" + "\n";
	logprint( logline1 );
	self endon( "disconnect" );
	//self endon( "end_respawn" );
	if ( !isDefined( timealreadypassed ) )
	{
		timealreadypassed = 0;
	}
	spawnedasspectator = 0;
	if ( !isDefined( self.wavespawnindex ) && isDefined( level.waveplayerspawnindex[ self.team ] ) )
	{
		self.wavespawnindex = level.waveplayerspawnindex[ self.team ];
		level.waveplayerspawnindex[ self.team ]++;
	}
	timeuntilspawn = 5;
	if ( timeuntilspawn > timealreadypassed )
	{
		timeuntilspawn -= timealreadypassed;
		timealreadypassed = 0;
	}
	else
	{
		timealreadypassed -= timeuntilspawn;
		timeuntilspawn = 0;
	}
	if ( flag( "start_zombie_round_logic" ) && level.grief_gamemode[ "tdm" ].respawn_delay )
	{
		if ( level.playerqueuedrespawn )
		{
			setlowermessage( game[ "strings" ][ "you_will_spawn" ], timeuntilspawn );
		}
		else
		{
			setlowermessage( game[ "strings" ][ "waiting_to_spawn" ], timeuntilspawn );
		}
		if ( !spawnedasspectator )
		{
			spawnorigin = self.origin + vectorScale( ( 0, 0, 1 ), 60 );
			spawnangles = self.angles;
			if ( isDefined( level.useintermissionpointsonwavespawn ) && [[ level.useintermissionpointsonwavespawn ]]() == 1 )
			{
				spawnpoint = maps/mp/gametypes_zm/_spawnlogic::getrandomintermissionpoint();
				if ( isDefined( spawnpoint ) )
				{
					spawnorigin = spawnpoint.origin;
					spawnangles = spawnpoint.angles;
				}
			}
			self thread respawn_asspectator( spawnorigin, spawnangles );
		}
		spawnedasspectator = 1;
		self maps/mp/gametypes_zm/_globallogic_utils::waitfortimeornotify( timeuntilspawn, "force_spawn" );
		self notify( "stop_wait_safe_spawn_button" );
	}
	wavebased = level.waverespawndelay > 0;
	if ( flag( "start_zombie_round_logic" ) && level.grief_gamemode[ "tdm" ].optional_spawn )
	{
		setlowermessage( game[ "strings" ][ "press_to_spawn" ] );
		if ( !spawnedasspectator )
		{
			self thread respawn_asspectator( self.origin + vectorScale( ( 0, 0, 1 ), 60 ), self.angles );
		}
		spawnedasspectator = 1;
		self waitrespawnorsafespawnbutton();
	}
	self.waitingtospawn = 0;
	self clearlowermessage();
	self.wavespawnindex = undefined;
	self.respawntimerstarttime = undefined;
	logline1 = "waitAndSpawnClient() spawns player" + "\n";
	logprint( logline1 );
	self thread [[ level.spawnplayer ]]();
}

waitrespawnorsafespawnbutton() //checked changed to match cerberus output
{
	self endon( "disconnect" );
	//self endon( "end_respawn" );
	while ( 1 )
	{
		if ( self useButtonPressed() )
		{
			return;
		}
		wait 0.05;
	}
}

menuallieszombies() //checked changed to match cerberus output
{
	self maps/mp/gametypes_zm/_globallogic_ui::closemenus();
	if ( !level.console && level.allow_teamchange == 0 && is_true( self.hasdonecombat ) )
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

shuffle_teams()
{
	players = getPlayers();
	foreach ( player in players )
	{
		player setclientminiscoreboardhide( 1 );
		random_team = pick_weighted_random_team();
		if ( random_team == "" )
		{
			return;
		}
		if ( countplayers( random_team ) == 4 )
		{
			player team_swap( random_team );
		}
		else 
		{
			player.team = random_team;
			player.sessionteam = random_team;
			player.pers[ "team" ] = random_team;
		}
		if ( random_team == "axis" )
		{
			player._encounters_team = "A";
		}
		else 
		{
			player._encounters_team = "B";
		}
		player.team_changed = true;
		player setclientminiscoreboardhide( 0 );
	}
}

pick_weighted_random_team()
{
	if ( !isDefined( level.grief_teams_random_watcher ) )
	{
		level.grief_teams_random_watcher = [];
		level.grief_teams_random_watcher[ "axis" ].times_picked = 0;
		level.grief_teams_random_watcher[ "allies" ].times_picked = 0;
	}
	random_team = random( level.teams );
	level.grief_teams_random_watcher[ random_team ].times_picked++;
	if ( level.grief_teams_random_watcher[ random_team ].times_picked > 4 )
	{
		random_team = getOtherTeam( random_team );
	}
	if ( level.grief_teams_random_watcher[ random_team ].times_picked > 4 )
	{
		logline1 = "no free slots to swap to!" + "\n";
		logprint( logline1 );
		random_team = "";
	}
	return random_team;
}

team_swap( team )
{
	other_team_players = getPlayers( team );
	foreach ( player in other_team_players )
	{
		if ( !is_true( player.team_changed ) )
		{
			self.team = team;
			self.sessionteam = team;
			self.pers[ "team" ] = team;
			if ( team == "axis" )
			{
				self._encounters_team = "A";
			}
			else 
			{
				self._encounters_team = "B";
			}
			self.team_changed = true;
			player.team = getotherteam( team );
			player.sessionteam = getotherteam( team );
			player.pers[ "team" ] = getotherteam( team );
			if ( getotherteam( random_team ) == "axis" )
			{
				player._encounters_team = "A";
			}
			else 
			{
				player._encounters_team = "B";
			}
			player.team_changed = true;
			return;
		}
	}
}