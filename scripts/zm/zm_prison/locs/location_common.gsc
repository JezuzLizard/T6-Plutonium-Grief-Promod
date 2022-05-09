#include maps\mp\_utility;
#include maps\mp\zombies\_zm_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_weapons;
#include maps\mp\zm_alcatraz_traps;
#include scripts\zm\_gametype_setup;
#include maps\mp\zombies\_zm_score;

common_init()
{
	level.enemy_location_override_func = ::enemy_location_override;
	flag_wait( "initial_blackscreen_passed" );
	flag_wait( "start_zombie_round_logic" );
	t_temp = getent( "tower_trap_activate_trigger", "targetname" );
	t_temp delete();
	t_temp = getent( "tower_trap_range_trigger", "targetname" );
	t_temp delete();
	e_model = getent( "trap_control_docks", "targetname" );
	e_model delete();
	e_brush = getent( "tower_shockbox_door", "targetname" );
	e_brush delete();
	a_afterlife_props = getentarray( "afterlife_show", "targetname" );
	foreach ( m_prop in a_afterlife_props )
	{
		m_prop delete();
	}
	a_t_travel_triggers = getentarray( "travel_trigger", "script_noteworthy" );
	foreach ( trigger in a_t_travel_triggers )
	{
		trigger delete();
	}
	t_ride_trigger = getent( "gondola_ride_trigger", "targetname" );
	t_ride_trigger delete();
	t_crafting_table = getentarray( "open_craftable_trigger", "targetname" );
	foreach ( trigger in t_crafting_table )
	{
		trigger delete();
	}
	for ( i = 1; i <= 5; i++ )
	{
		m_key_lock = getent( "masterkey_lock_" + i, "targetname" );
		m_key_lock delete();
	}
	level thread maps\mp\zm_alcatraz_traps::init_fan_trap_trigs();
	level thread maps\mp\zm_alcatraz_traps::init_acid_trap_trigs();
	level.custom_grief_brutus_logic = ::grief_brutus_logic;
	if ( level.grief_gamerules[ "grief_brutus_enabled" ].current )
	{
		level thread [[ level.custom_grief_brutus_logic ]]();
	}
	level.global_brutus_powerup_prevention = true;
}

enemy_location_override( zombie, enemy )
{
	location = enemy.origin;
	if ( is_true( self.reroute ) )
	{
		if ( isDefined( self.reroute_origin ) )
		{
			location = self.reroute_origin;
		}
	}
	return location;
}

zgrief_preinit()
{
	registerclientfield( "toplayer", "meat_stink", 1, 1, "int" );
	level.givecustomloadout = maps\mp\zm_prison::givecustomloadout;
	zgrief_init();
}

zgrief_init()
{
	encounter_init();
	flag_wait( "start_zombie_round_logic" );
}

encounter_init()
{
	level._game_module_player_laststand_callback = ::alcatraz_grief_laststand_weapon_save;
	level.precachecustomcharacters = ::precache_team_characters;
	level.givecustomcharacters = ::give_team_characters;
	level.gamemode_post_spawn_logic = ::give_player_shiv;
}

alcatraz_grief_laststand_weapon_save( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration )
{
	if ( self hasperk( "specialty_additionalprimaryweapon" ) )
	{
		primary_weapons_that_can_be_taken = [];
		primaryweapons = self getweaponslistprimaries();
		for ( i = 0; i < primaryweapons.size; i++ )
		{
			if ( maps\mp\zombies\_zm_weapons::is_weapon_included( primaryweapons[ i ] ) || maps\mp\zombies\_zm_weapons::is_weapon_upgraded( primaryweapons[ i ] ) )
			{
				primary_weapons_that_can_be_taken[ primary_weapons_that_can_be_taken.size ] = primaryweapons[ i ];
			}
		}
		if ( primary_weapons_that_can_be_taken.size >= 3 )
		{
			weapon_to_take = primary_weapons_that_can_be_taken[ primary_weapons_that_can_be_taken.size - 1 ];
			self takeweapon( weapon_to_take );
			self.weapon_taken_by_losing_specialty_additionalprimaryweapon = weapon_to_take;
		}
	}
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

precache_team_characters()
{
	precachemodel( "c_zom_player_grief_guard_fb" );
	precachemodel( "c_zom_oleary_shortsleeve_viewhands" );
	precachemodel( "c_zom_player_grief_inmate_fb" );
	precachemodel( "c_zom_grief_guard_viewhands" );
}

give_team_characters()
{
	self detachall();
	self set_player_is_female( 0 );
	if ( !isDefined( self.characterindex ) )
	{
		self.characterindex = 1;
		if ( self.team == "axis" )
		{
			self.characterindex = 0;
		}
	}
	switch( self.characterindex )
	{
		case 0:
		case 2:
			self setmodel( "c_zom_player_grief_inmate_fb" );
			self.voice = "american";
			self.skeleton = "base";
			self setviewmodel( "c_zom_oleary_shortsleeve_viewhands" );
			self.characterindex = 0;
			break;
		case 1:
		case 3:
			self setmodel( "c_zom_player_grief_guard_fb" );
			self.voice = "american";
			self.skeleton = "base";
			self setviewmodel( "c_zom_grief_guard_viewhands" );
			self.characterindex = 1;
			break;
	}
	self setmovespeedscale( 1 );
	self setsprintduration( 4 );
	self setsprintcooldown( 0 );
}

give_player_shiv()
{
	self takeweapon( "knife_zm" );
	self giveweapon( "knife_zm_alcatraz" );
}

grief_brutus_logic()
{
	level endon( "end_game" );
	level notify( "end_grief_brutus_logic" );
	level endon( "end_grief_brutus_logic" );
	while ( true )
	{
		flag_wait( "spawn_zombies" );
		random_wait = randomIntRange( 360, 720 );
		for ( i = 0; i < random_wait; i++ )
		{
			wait 1;
		}
		flag_wait( "spawn_zombies" );
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
		level.music_round_override = 1;
		level thread maps\mp\zombies\_zm_audio::change_zombie_music( "brutus_round_start" );
		level thread sndforcewait();
	}
}

sndforcewait()
{
	wait 10;
	level.music_round_override = 0;
}

turn_afterlife_interact_on()
{
	if ( self.script_string == "cell_1_powerup_activate" || self.script_string == "intro_powerup_activate" || self.script_string == "cell_2_powerup_activate" || self.script_string == "wires_shower_door" )
	{
		return;
	}
	if ( self.script_string == "electric_cherry_on" || self.script_string == "sleight_on" || self.script_string == "wires_admin_door" )
	{
	}
	else
	{
		self delete();
	}
}

acid_trap_think()
{
	triggers = getentarray( self.targetname, "targetname" );
	self.is_available = 1;
	self.has_been_used = 0;
	self.cost = 1000;
	self.in_use = 0;
	self.zombie_dmg_trig = getent( self.target, "targetname" );
	self.zombie_dmg_trig.in_use = 0;
	light_name = self get_trap_light_name();
	zapper_light_red( light_name );
	self sethintstring( &"ZM_PRISON_ACID_TRAP_UNAVAILABLE" );
	flag_wait_any( "activate_cafeteria", "activate_infirmary" );
	zapper_light_green( light_name );
	self hint_string( &"ZM_PRISON_ACID_TRAP", self.cost );
	while ( 1 )
	{
		self waittill( "trigger", who );
		if ( who in_revive_trigger() )
		{
			continue;
		}
		if ( !isDefined( self.is_available ) )
		{
			continue;
		}
		if ( is_player_valid( who ) )
		{
			if ( who.score >= self.cost )
			{
				if ( !self.zombie_dmg_trig.in_use )
				{
					if ( !self.has_been_used )
					{
						self.has_been_used = 1;
						level thread maps\mp\zombies\_zm_audio::sndmusicstingerevent( "trap" );
						who do_player_general_vox( "general", "discover_trap" );
					}
					else
					{
						who do_player_general_vox( "general", "start_trap" );
					}
					self.zombie_dmg_trig.in_use = 1;
					self.zombie_dmg_trig.active = 1;
					self playsound( "zmb_trap_activate" );
					self thread acid_trap_move_switch( self );
					self waittill( "switch_activated" );
					who minus_to_player_score( self.cost );
					level.trapped_track[ "acid" ] = 1;
					level notify( "trap_activated" );
					who maps\mp\zombies\_zm_stats::increment_client_stat( "prison_acid_trap_used", 0 );
					array_thread( triggers, ::hint_string, &"ZOMBIE_TRAP_ACTIVE" );
					self thread activate_acid_trap();
					self.zombie_dmg_trig waittill( "acid_trap_fx_done" );
					clientnotify( self.script_string + "off" );
					if ( isDefined( self.fx_org ) )
					{
						self.fx_org delete();
					}
					if ( isDefined( self.zapper_fx_org ) )
					{
						self.zapper_fx_org delete();
					}
					if ( isDefined( self.zapper_fx_switch_org ) )
					{
						self.zapper_fx_switch_org delete();
					}
					self.zombie_dmg_trig notify( "acid_trap_finished" );
					self.zombie_dmg_trig.active = 0;
					array_thread( triggers, ::hint_string, &"ZOMBIE_TRAP_COOLDOWN" );
					wait 10;
					self playsound( "zmb_trap_available" );
					self notify( "available" );
					self.zombie_dmg_trig.in_use = 0;
					array_thread( triggers, ::hint_string, &"ZM_PRISON_ACID_TRAP", self.cost );
				}
			}
		}
	}
}