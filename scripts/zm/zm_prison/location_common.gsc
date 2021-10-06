#include maps/mp/_utility;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zm_alcatraz_traps;

common_init()
{
	level.enemy_location_override_func = ::enemy_location_override;
	level._effect[ "butterflies" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_skull_elec" );
	flag_wait( "initial_blackscreen_passed" );
	maps/mp/zombies/_zm_game_module::turn_power_on_and_open_doors();
	flag_wait( "start_zombie_round_logic" );
	level thread maps/mp/zm_alcatraz_traps::init_fan_trap_trigs();
	level thread maps/mp/zm_alcatraz_traps::init_acid_trap_trigs();
	wait 1;
	level notify( "sleight_on" );
	wait_network_frame();
	level notify( "doubletap_on" );
	wait_network_frame();
	level notify( "juggernog_on" );
	wait_network_frame();
	level notify( "electric_cherry_on" );
	wait_network_frame();
	level notify( "deadshot_on" );
	wait_network_frame();
	level notify( "divetonuke_on" );
	wait_network_frame();
	level notify( "additionalprimaryweapon_on" );
	wait_network_frame();
	level notify( "Pack_A_Punch_on" );
	wait_network_frame();
	if ( getDvarInt( "grief_brutus_enabled") == 1 )
	{
		level thread grief_brutus_logic();
	}
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
	level.givecustomloadout = maps/mp/zm_prison::givecustomloadout;
	zgrief_init();
}

zgrief_init()
{
	encounter_init();
	flag_wait( "start_zombie_round_logic" );
	if ( level.grief_gamerules[ "zombie_round" ] < 4 && level.gamedifficulty != 0 )
	{
		level.zombie_move_speed = 35;
	}
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
			if ( maps/mp/zombies/_zm_weapons::is_weapon_included( primaryweapons[ i ] ) || maps/mp/zombies/_zm_weapons::is_weapon_upgraded( primaryweapons[ i ] ) )
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
		level thread maps/mp/zombies/_zm_audio::change_zombie_music( "brutus_round_start" );
		level thread sndforcewait();
	}
}