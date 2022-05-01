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
#include maps\mp\zombies\_zm_magicbox;

#include scripts\zm\promod_grief\_hud;
#include scripts\zm\promod_grief\_round_system;
#include scripts\zm\promod_grief\_gamerules;

main()
{
	level.grief_ffa = getDvarIntDefault( "grief_ffa", 0 );
	if ( level.grief_ffa )
	{
		setGameTypeSetting( "teamCount", 1 );
		if ( !isDefined( level.grief_ffa_team_model ) )
		{
			level.grief_ffa_team_model = random( array( "allies", "axis" ) );
		}
	}
	replaceFunc( maps\mp\zombies\_zm_magicbox::treasure_chest_init, ::treasure_chest_init_override );
	replaceFunc( maps\mp\zombies\_zm_game_module::wait_for_team_death_and_round_end, scripts\zm\promod_grief\_round_system::wait_for_team_death_and_round_end_override );
	replaceFunc( common_scripts/utility::struct_class_init, ::struct_class_init_override ); // switch jug with speed
	//replaceFunc( maps\mp\zombies\_zm::getfreespawnpoint, ::getfreespawnpoint_override );
	precacheshellshock( "grief_stab_zm" );
	precacheStatusIcon( "waypoint_revive" );
	if ( getDvar( "g_gametype" ) == "zgrief" || getDvar( "mapname" ) == "zm_nuked" )
	{
		precacheshader( "faction_cdc" );
		precacheshader( "faction_cia" );
		precacheshader( "waypoint_revive_cdc_zm" );
		precacheshader( "waypoint_revive_cia_zm" );
	}
	if ( getDvar( "mapname" ) == "zm_prison" )
	{
		precacheShader( "faction_guards" );
		precacheShader( "faction_inmates" );
	}
	init_gamerules();
}

init()
{
	level thread monitor_players_connecting_status();
	level.round_spawn_func = ::round_spawning;
	level.round_think_func = ::round_think;
	level._game_module_player_damage_callback = ::game_module_player_damage_callback;
	level._game_module_player_damage_grief_callback = ::game_module_player_damage_grief_callback;
	level.callbackplayerdamage = ::callback_playerdamage;
	level.callbackplayermelee = ::callback_playermelee_override;
	level.meat_bounce_override = ::meat_bounce_override;
	setDvar( "g_friendlyfireDist", 0 );
	//promod custom overrides
	level.grief_loadout_save = ::grief_loadout_save;
	level thread on_player_connect();
	if ( level.grief_ffa )
	{
		setscoreboardcolumns( "score", "stabs", "killsconfirmed", "survived", "downs" );
		setDvar( "player_lastStandBleedoutTime", 1.0 );
		level.zombie_vars[ "penalty_downed" ] = 0;
		level.zombie_vars[ "penalty_no_revive" ] = 0;
	}
	else 
	{
		setscoreboardcolumns( "score", "stabs", "killsconfirmed", "revives", "downs" );	
	}
	if ( level.script == "zm_tomb" )
	{
		level.default_solo_laststandpistol = "c96_zm";
	}
	else 
	{
		level.default_solo_laststandpistol = "m1911_zm";
	}
	level thread remove_status_icons_on_end_game();
	level thread check_quickrevive_for_hotjoin();
	level thread remove_round_number();
	level.speed_change_round = undefined;
	wait 15;
	level thread instructions_on_all_players();
}

remove_status_icons_on_end_game()
{
	level waittill("end_game");

	wait 5;

	players = get_players();
	foreach(player in players)
	{
		player.statusicon = "";
	}
}

check_quickrevive_for_hotjoin() //checked changed to match cerberus output
{
	flag_clear( "solo_game" );
	level.using_solo_revive = false;
	level.revive_machine_is_solo = false;
	maps/mp/zombies/_zm::set_default_laststand_pistol( false );
	if ( isDefined( level.quick_revive_machine ) )
	{
		maps/mp/zombies/_zm::update_quick_revive( false );
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

monitor_players_connecting_status()
{
	level.num_players_connecting = 0;
	while ( true )
	{
		level waittill( "connecting", player );
		if ( !flag( "initial_players_connected" ) )
		{
			logline1 = "P: " + player.name + " is connecting during loadscreen" + "\n";
			logprint( logline1 );
			player thread kick_player_if_dont_spawn_in_time();
		}
	}
}

kick_player_if_dont_spawn_in_time()
{
	self endon( "spawned_player" );
	wait 20;
	logline1 = "Kicking player because they failed to notify begin in less than 20 seconds during the loadscreen" + "\n";
	logprint( logline1 );
	print("spawned slow");
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
	if(!level.grief_gamerules[ "instructions" ])
		return;

	level endon( "end_game" );
	self endon( "disconnect" );

	level waittill( "initial_blackscreen_passed" );
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
		player thread afk_kick();
		if ( !isDefined( player.last_griefed_by ) )
		{
			player.last_griefed_by = spawnStruct();
			player.last_griefed_by.attacker = undefined;
			player.last_griefed_by.meansofdeath = undefined;
			player.last_griefed_by.weapon = undefined;
			player.last_griefed_by.time = 0;
			player thread watch_for_down();
		}
		player thread on_player_spawn();
       	player set_team();
		player.killsconfirmed = 0;
		player.stabs = 0;
		player.assists = 0;
		if ( level.grief_ffa )
		{
			player.survived = 0;
		}
    }
}

on_player_spawn()
{
	level endon("end_game");
	self endon( "disconnect" );

	while(1)
	{
		self waittill( "spawned_player" );

		if ( self.score < level.grief_gamerules[ "round_restart_points" ] )
		{
			self.score = level.grief_gamerules[ "round_restart_points" ];
		}

		if ( level.grief_gamerules[ "reduced_pistol_ammo" ] )
		{
			self scripts/zm/promod_grief/_gamerules::reduce_starting_ammo();
		}
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
		if ( self.sessionstate == "spectator" || level.players.size <= 2 )
		{	
			wait 1;
			continue;
		}
        if( self usebuttonpressed() || self jumpbuttonpressed() || self meleebuttonpressed() || self attackbuttonpressed() || self adsbuttonpressed() || self sprintbuttonpressed() )
        {
            time = 0;
        }
        if( time == 4800 ) //4mins
        {
			logprint( "afk kick" );
			print("afk kick");
            kick( self getEntityNumber() );
        }

        wait 0.05;
        time++;
    }
}

set_team()
{
	if ( level.grief_ffa )
	{
		self.team = "allies";
		self.sessionteam = "allies";
		self.pers[ "team" ] = "allies";
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
	else 
	{
		teamplayersallies = countplayers( "allies");
		teamplayersaxis = countplayers( "axis");
		if ( teamplayersallies > teamplayersaxis )
		{
			self.team = "axis";
			self.sessionteam = "axis";
			self.pers[ "team" ] = "axis";
			self._encounters_team = "A";
		}
		else if ( teamplayersallies < teamplayersaxis )
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
	level.zombie_total = 999;
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
			ai thread round_spawn_failsafe();
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
		if ( isDefined( eattacker.is_zombie ) && eattacker.is_zombie && isplayer( eattacker ) )
		{
			self.last_damage_from_zombie_or_player = 1;
		}
	}
	if ( !isDefined( eattacker ) || !isplayer( eattacker ) )
	{
		return;
	}
	if ( smeansofdeath == "MOD_MELEE" )
	{
		eattacker.stabs++;
	}
	if ( level.grief_ffa )
	{
		if ( !self maps/mp/zombies/_zm_laststand::player_is_in_laststand() && !eattacker maps/mp/zombies/_zm_laststand::player_is_in_laststand() )
		{
			self player_steal_points( eattacker, smeansofdeath );
		}
	}
	else if ( isDefined( eattacker._encounters_team ) && eattacker._encounters_team != self._encounters_team )
	{
		if ( !self maps/mp/zombies/_zm_laststand::player_is_in_laststand() && !eattacker maps/mp/zombies/_zm_laststand::player_is_in_laststand() )
		{
			self player_steal_points( eattacker, smeansofdeath );
		}
	}
	if ( is_true( self._being_shellshocked ) || self maps/mp/zombies/_zm_laststand::player_is_in_laststand() )
	{
		return;
	}
	if ( isDefined( eattacker._encounters_team ) && eattacker._encounters_team != self._encounters_team || level.grief_ffa )
	{
		self.last_griefed_by.attacker = eattacker;
		self.last_griefed_by.meansofdeath = smeansofdeath;
		self.last_griefed_by.weapon = sweapon;
		self.last_griefed_by.time = getTime();
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

callback_playerdamage( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime, boneindex )
{
    if ( isdefined( eattacker ) && isplayer( eattacker ) && eattacker.sessionteam == self.sessionteam && !eattacker hasperk( "specialty_noname" ) && !( isdefined( self.is_zombie ) && self.is_zombie ) && !level.grief_ffa )
    {
        self process_friendly_fire_callbacks( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime, boneindex );

        if ( self != eattacker )
        {
            return;
        }
        else if ( smeansofdeath != "MOD_GRENADE_SPLASH" && smeansofdeath != "MOD_GRENADE" && smeansofdeath != "MOD_EXPLOSIVE" && smeansofdeath != "MOD_PROJECTILE" && smeansofdeath != "MOD_PROJECTILE_SPLASH" && smeansofdeath != "MOD_BURNED" && smeansofdeath != "MOD_SUICIDE" )
        {
            return;
        }
    }

    if ( isdefined( level.pers_upgrade_insta_kill ) && level.pers_upgrade_insta_kill )
        self maps\mp\zombies\_zm_pers_upgrades_functions::pers_insta_kill_melee_swipe( smeansofdeath, eattacker );

    if ( isdefined( self.overrideplayerdamage ) )
        idamage = self [[ self.overrideplayerdamage ]]( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime );
    else if ( isdefined( level.overrideplayerdamage ) )
        idamage = self [[ level.overrideplayerdamage ]]( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime );
    if ( isdefined( self.magic_bullet_shield ) && self.magic_bullet_shield )
    {
        maxhealth = self.maxhealth;
        self.health += idamage;
        self.maxhealth = maxhealth;
    }

    if ( isdefined( self.divetoprone ) && self.divetoprone == 1 )
    {
        if ( smeansofdeath == "MOD_GRENADE_SPLASH" )
        {
            dist = distance2d( vpoint, self.origin );

            if ( dist > 32 )
            {
                dot_product = vectordot( anglestoforward( self.angles ), vdir );

                if ( dot_product > 0 )
                    idamage = int( idamage * 0.5 );
            }
        }
    }
    if ( isdefined( level.prevent_player_damage ) )
    {
        if ( self [[ level.prevent_player_damage ]]( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime ) )
            return;
    }

    idflags |= level.idflags_no_knockback;

    if ( idamage > 0 && shitloc == "riotshield" )
        shitloc = "torso_upper";
    self finishplayerdamagewrapper( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime, boneindex );
}

watch_for_down()
{
	level endon( "end_game" );
	self endon( "disconnect" );
	while ( true )
	{
		flag_wait( "spawn_zombies" );
		in_laststand = self maps/mp/zombies/_zm_laststand::player_is_in_laststand();
		is_alive = isAlive( self );
		if ( in_laststand || !is_alive )
		{
			if ( isDefined( self.last_griefed_by.attacker ) )
			{
				self player_steal_points( self.last_griefed_by.attacker, "down_player" );
				if ( isDefined( self.last_griefed_by.weapon ) && isDefined( self.last_griefed_by.meansofdeath ) && ( ceil( ( getTime() - self.last_griefed_by.time ) / 1000 ) < 4 ) )
				{
					obituary( self, self.last_griefed_by.attacker, self.last_griefed_by.weapon, self.last_griefed_by.meansofdeath );
					self.last_griefed_by.attacker.killsconfirmed++;
				}
				else 
				{
					obituary(self, self, "none", "MOD_SUICIDE");
				}
			}
			else 
			{
				obituary(self, self, "none", "MOD_SUICIDE");
			}
			self thread change_status_icon( is_alive );
			self waittill_either( "player_revived", "spawned_player" );
			self.statusicon = "";
		}
		wait 0.05;
	}
}

change_status_icon( is_alive )
{
	if ( is_alive )
	{
		self.statusicon = "waypoint_revive";
		self thread update_icon_on_bleedout();
		
	}
	else 
	{
		self.statusicon = "hud_status_dead";
	}
}

update_icon_on_bleedout()
{
	level endon( "end_game" );
	self endon( "spawned" );
	self endon( "player_revived" );
	self waittill( "bled_out" );
	self.statusicon = "hud_status_dead";
}

track_players_intersection_tracker_override()
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
					// obituary_message = create_griefed_obituary_msg( players[ i ], players[ j ], "none", "MOD_IMPACT" );
					// players = array( players[ i ], players[ j ] );
					//COM_PRINTF( "obituary g_log", "obituary", obituary_message, players );
					players[ i ].is_grief_jumped_on = undefined;
					obituary( players[ j ], players[ i ], "none", "MOD_IMPACT" );
				}
				else if ( is_true( players[ i ].is_grief_jumped_on ) )
				{
					// obituary_message = create_griefed_obituary_msg( players[ j ], players[ i ], "none", "MOD_IMPACT" );
					// players = array( players[ j ], players[ i ] );
					//COM_PRINTF( "obituary g_log", "obituary", obituary_message, players );
					players[ j ].is_grief_jumped_on = undefined;
					obituary( players[ i ], players[ j ], "none", "MOD_IMPACT" );
				}
				killed_players = 1;
				j++;
			}
			i++;
		}
		wait 0.5;
	}
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
	if ( eattacker != self && eattacker.team != self.team || level.grief_ffa )
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

getfreespawnpoint_override( spawnpoints, player )
{
	print( "spawnpoints.size " + spawnpoints.size );
	assign_spawnpoints_player_data( spawnpoints, player );
	for ( j = 0; j < spawnpoints.size; j++ )
	{
		if ( spawnpoints[ j ].player_property == player.name )
		{
			print( "Found spawnpoint for " + player.name );
			return spawnpoints[ j ];
		}
	}
}

assign_spawnpoints_player_data( spawnpoints, player )
{
	remove_disconnected_players_spawnpoint_property( spawnpoints );
	for ( i = 0; i < spawnpoints.size; i++ )
	{
		if ( !isDefined( spawnpoints[ i ].player_property ) )
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
			spawnpoints[ i ].player_property = undefined;
		}
	}
}

round_think( restart )
{
	flag_init( "grief_begin" );

	if ( !isdefined( restart ) )
		restart = 0;
	level endon( "end_round_think" );

	if ( !( isdefined( restart ) && restart ) )
	{
		if ( isdefined( level.initial_round_wait_func ) )
			[[ level.initial_round_wait_func ]]();

		if ( !( isdefined( level.host_ended_game ) && level.host_ended_game ) )
		{
			players = get_players();

			foreach ( player in players )
			{
				if ( !( isdefined( player.hostmigrationcontrolsfrozen ) && player.hostmigrationcontrolsfrozen ) )
				{
					player freezecontrols( 0 );
				}

				player maps\mp\zombies\_zm_stats::set_global_stat( "rounds", level.round_number );
			}
		}
	}
	level.round_number = level.grief_gamerules[ "zombie_round" ];
	level.noroundnumber = true;
	set_zombie_spawn_rate( level.round_number );
	set_zombie_move_speed( level.round_number );
	setroundsplayed( 0 );

	for (;;)
	{
		maxreward = 50 * level.round_number;

		if ( maxreward > 500 )
			maxreward = 500;

		level.zombie_vars["rebuild_barrier_cap_per_round"] = maxreward;
		level.pro_tips_start_time = gettime();
		level.zombie_last_run_time = gettime();

		if ( isdefined( level.zombie_round_change_custom ) )
			[[ level.zombie_round_change_custom ]]();
		else
		{
			level thread maps\mp\zombies\_zm_audio::change_zombie_music( "round_start" );
		}

		maps\mp\zombies\_zm_powerups::powerup_round_start();
		players = get_players();
		array_thread( players, maps\mp\zombies\_zm_blockers::rebuild_barrier_reward_reset );

		if ( !( isdefined( level.headshots_only ) && level.headshots_only ) && !restart )
			level thread award_grenades_for_survivors();
		level.round_start_time = gettime();

		while ( level.zombie_spawn_locations.size <= 0 )
			wait 0.1;
		flag_wait( "grief_begin" );
		level thread [[ level.round_spawn_func ]]();
		level notify( "start_of_round" );
		recordzombieroundstart();
		players = getplayers();

		for ( index = 0; index < players.size; index++ )
		{
			zonename = players[index] get_current_zone();

			if ( isdefined( zonename ) )
				players[index] recordzombiezone( "startingZone", zonename );
		}

		if ( isdefined( level.round_start_custom_func ) )
			[[ level.round_start_custom_func ]]();

		[[ level.round_wait_func ]]();
		level.first_round = 0;
		level notify( "end_of_round" );
		level thread maps\mp\zombies\_zm_audio::change_zombie_music( "round_end" );
		uploadstats();

		if ( isdefined( level.round_end_custom_logic ) )
			[[ level.round_end_custom_logic ]]();
		array_thread( players, maps\mp\zombies\_zm_pers_upgrades_system::round_end );
		timer = level.zombie_vars["zombie_spawn_delay"];

		if ( timer > 0.08 )
			level.zombie_vars["zombie_spawn_delay"] = timer * 0.95;
		else if ( timer < 0.08 )
			level.zombie_vars["zombie_spawn_delay"] = 0.08;

		if ( level.gamedifficulty == 0 )
			level.zombie_move_speed = level.round_number * level.zombie_vars["zombie_move_speed_multiplier_easy"];
		else
			level.zombie_move_speed = level.round_number * level.zombie_vars["zombie_move_speed_multiplier"];

		level.round_number++;

		if ( 255 < level.round_number )
			level.round_number = 255;
		matchutctime = getutc();
		players = get_players();

		foreach ( player in players )
		{
			if ( level.curr_gametype_affects_rank && level.round_number > 3 + level.start_round )
				player maps\mp\zombies\_zm_stats::add_client_stat( "weighted_rounds_played", level.round_number );

			player maps\mp\zombies\_zm_stats::set_global_stat( "rounds", level.round_number );
			player maps\mp\zombies\_zm_stats::update_playing_utc_time( matchutctime );
		}

		check_quickrevive_for_hotjoin();
		level round_over();
		level notify( "between_round_over" );
		restart = 0;
	}
}

set_zombie_spawn_rate( round )
{
	for ( i = 0; i < round; i++ )
	{
		level.zombie_vars["zombie_spawn_delay"] *= 0.95;
	}
}

set_zombie_move_speed( round )
{
	level.zombie_move_speed = round * level.zombie_vars["zombie_move_speed_multiplier"];
}

callback_playermelee_override( eattacker, idamage, sweapon, vorigin, vdir, boneindex, shieldhit )
{
    hit = 1;

    if ( !level.grief_ffa && level.teambased && self.team == eattacker.team )
    {
        if ( level.friendlyfire == 0 )
            hit = 0;
    }

    self finishmeleehit( eattacker, sweapon, vorigin, vdir, boneindex, shieldhit, hit );
}

remove_round_number()
{
	level endon("end_game");

	while(1)
	{
		level waittill("start_of_round");

		setroundsplayed(0);
	}
}