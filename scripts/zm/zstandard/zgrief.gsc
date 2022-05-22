// T6 GSC SOURCE
// Decompiled by https://github.com\xensik\gsc-tool
#include maps\mp\_utility;
#include maps\mp\gametypes_zm\_hud_util;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\gametypes_zm\_zm_gametype;
#include maps\mp\zombies\_zm_stats;
#include maps\mp\zombies\_zm_powerups;
#include maps\mp\zombies\_zm;
#include maps\mp\zombies\_zm_game_module;
#include maps\mp\zombies\_zm_magicbox;
#include maps\mp\zombies\_zm_weap_cymbal_monkey;
#include maps\mp\zombies\_zm_laststand;
#include maps\mp\_demo;
#include maps\mp\zombies\_zm_zonemgr;
#include maps\mp\zombies\_zm_audio_announcer;
#include maps\mp\zombies\_zm_weapons;
#include maps\mp\zombies\_zm_equipment;

main()
{
	level.custom_spectate_permissions = ::setspectatepermissionsgrief;
	level._supress_survived_screen = 1;
	level._game_module_player_laststand_callback = ::grief_laststand_weapon_save;
	level.onplayerspawned_restore_previous_weapons = ::grief_laststand_weapons_return;
	level.game_module_onplayerconnect = ::grief_onplayerconnect;
}

init()
{
	level.powerup_drop_count = 0;
	level.no_end_game_check = 1;
	level._game_module_game_end_check = ::grief_game_end_check_func;
	level.round_end_custom_logic = ::grief_round_end_custom_logic;
	level thread maps\mp\gametypes_zm\_zm_gametype::init();
	level thread maps\mp\zombies\_zm::round_start();
	level thread maps\mp\gametypes_zm\_zm_gametype::kill_all_zombies();
	flag_wait( "initial_blackscreen_passed" );
	level.prevent_player_damage = ::player_prevent_damage;
	level thread maps\mp\zombies\_zm_game_module::wait_for_team_death_and_round_end();
	players = getPlayers();

	foreach ( player in players )
		player.is_hotjoin = 0;
}

grief_onplayerconnect()
{
	self thread zgrief_player_bled_out_msg();
}

setspectatepermissionsgrief()
{
	self allowspectateteam( "allies", 1 );
	self allowspectateteam( "axis", 1 );
	self allowspectateteam( "freelook", 0 );
	self allowspectateteam( "none", 1 );
}

grief_game_end_check_func()
{
	return 0;
}

player_prevent_damage( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime )
{
	if ( isdefined( eattacker ) && isplayer( eattacker ) && self != eattacker && !eattacker hasperk( "specialty_noname" ) && !( isdefined( self.is_zombie ) && self.is_zombie ) )
		return true;

	return false;
}

zgrief_player_bled_out_msg()
{
	level endon( "end_game" );
	self endon( "disconnect" );
	if ( !level.grief_ffa )
	{
		while ( true )
		{
			self waittill( "bled_out" );

			level thread update_players_on_bleedout_or_disconnect( self);
		}
	}
}

show_grief_hud_msg( msg, msg_parm, offset, cleanup_end_game )
{
	self endon( "disconnect" );

	while ( isdefined( level.hostmigrationtimer ) )
		wait 0.05;

	zgrief_hudmsg = newclienthudelem( self );
	zgrief_hudmsg.alignx = "center";
	zgrief_hudmsg.aligny = "middle";
	zgrief_hudmsg.horzalign = "center";
	zgrief_hudmsg.vertalign = "middle";
	zgrief_hudmsg.y -= 130;
	if ( isdefined( offset ) )
		zgrief_hudmsg.y += offset;

	zgrief_hudmsg.foreground = 1;
	zgrief_hudmsg.fontscale = 5;
	zgrief_hudmsg.alpha = 0;
	zgrief_hudmsg.color = ( 1, 1, 1 );
	zgrief_hudmsg.hidewheninmenu = 1;
	zgrief_hudmsg.font = "default";

	if ( isdefined( cleanup_end_game ) && cleanup_end_game )
	{
		level endon( "end_game" );
		zgrief_hudmsg thread show_grief_hud_msg_cleanup();
	}

	if ( isdefined( msg_parm ) )
		zgrief_hudmsg settext( msg, msg_parm );
	else
		zgrief_hudmsg settext( msg );

	zgrief_hudmsg changefontscaleovertime( 0.25 );
	zgrief_hudmsg fadeovertime( 0.25 );
	zgrief_hudmsg.alpha = 1;
	zgrief_hudmsg.fontscale = 2;
	wait 3.25;
	zgrief_hudmsg changefontscaleovertime( 1 );
	zgrief_hudmsg fadeovertime( 1 );
	zgrief_hudmsg.alpha = 0;
	zgrief_hudmsg.fontscale = 5;
	wait 1;
	zgrief_hudmsg notify( "death" );

	if ( isdefined( zgrief_hudmsg ) )
		zgrief_hudmsg destroy();
}

show_grief_hud_msg_cleanup()
{
	self endon( "death" );

	level waittill( "end_game" );

	if ( isdefined( self ) )
		self destroy();
}

grief_laststand_weapon_save( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration )
{
	self.grief_savedweapon_weapons = self getweaponslist();
	self.grief_savedweapon_weaponsammo_stock = [];
	self.grief_savedweapon_weaponsammo_clip = [];
	self.grief_savedweapon_currentweapon = self getcurrentweapon();
	self.grief_savedweapon_grenades = self get_player_lethal_grenade();

	if ( isdefined( self.grief_savedweapon_grenades ) )
		self.grief_savedweapon_grenades_clip = self getweaponammoclip( self.grief_savedweapon_grenades );

	self.grief_savedweapon_tactical = self get_player_tactical_grenade();

	if ( isdefined( self.grief_savedweapon_tactical ) )
		self.grief_savedweapon_tactical_clip = self getweaponammoclip( self.grief_savedweapon_tactical );

	for ( i = 0; i < self.grief_savedweapon_weapons.size; i++ )
	{
		self.grief_savedweapon_weaponsammo_clip[i] = self getweaponammoclip( self.grief_savedweapon_weapons[i] );
		self.grief_savedweapon_weaponsammo_stock[i] = self getweaponammostock( self.grief_savedweapon_weapons[i] );
	}

	if ( isdefined( self.hasriotshield ) && self.hasriotshield )
		self.grief_hasriotshield = 1;

	if ( self hasweapon( "claymore_zm" ) )
	{
		self.grief_savedweapon_claymore = 1;
		self.grief_savedweapon_claymore_clip = self getweaponammoclip( "claymore_zm" );
	}

	if ( isdefined( self.current_equipment ) )
		self.grief_savedweapon_equipment = self.current_equipment;
}

grief_laststand_weapons_return()
{
	if ( !( isdefined( level.isresetting_grief ) && level.isresetting_grief ) )
		return false;

	if ( !isdefined( self.grief_savedweapon_weapons ) )
		return false;

	primary_weapons_returned = 0;

	i = 0;
	while ( i < self.grief_savedweapon_weapons.size )
	{
		weapon = self.grief_savedweapon_weapons[ i ];
		if ( isdefined( self.grief_savedweapon_grenades ) && weapon == self.grief_savedweapon_grenades || isdefined( self.grief_savedweapon_tactical ) && weapon == self.grief_savedweapon_tactical )
		{
			i++;
			continue;
		}

		if ( isweaponprimary( weapon ) )
		{
			if ( primary_weapons_returned >= 2 )
			{
				i++;
				continue;
			}
			primary_weapons_returned++;
		}
		self giveweapon( weapon, 0, self maps\mp\zombies\_zm_weapons::get_pack_a_punch_weapon_options( weapon ) );

		if ( isdefined( self.grief_savedweapon_weaponsammo_clip[i] ) )
			self setweaponammoclip( weapon, self.grief_savedweapon_weaponsammo_clip[i] );

		if ( isdefined( self.grief_savedweapon_weaponsammo_stock[i] ) )
			self setweaponammostock( weapon, self.grief_savedweapon_weaponsammo_stock[i] );
		i++;
	}

	if ( isdefined( self.grief_savedweapon_grenades ) )
	{
		self giveweapon( self.grief_savedweapon_grenades );

		if ( isdefined( self.grief_savedweapon_grenades_clip ) )
			self setweaponammoclip( self.grief_savedweapon_grenades, self.grief_savedweapon_grenades_clip );
	}

	if ( isdefined( self.grief_savedweapon_tactical ) )
	{
		self giveweapon( self.grief_savedweapon_tactical );

		if ( isdefined( self.grief_savedweapon_tactical_clip ) )
			self setweaponammoclip( self.grief_savedweapon_tactical, self.grief_savedweapon_tactical_clip );
	}

	if ( isdefined( self.current_equipment ) )
		self maps\mp\zombies\_zm_equipment::equipment_take( self.current_equipment );

	if ( isdefined( self.grief_savedweapon_equipment ) )
	{
		self.do_not_display_equipment_pickup_hint = 1;
		self maps\mp\zombies\_zm_equipment::equipment_give( self.grief_savedweapon_equipment );
		self.do_not_display_equipment_pickup_hint = undefined;
	}

	if ( isdefined( self.grief_hasriotshield ) && self.grief_hasriotshield )
	{
		if ( isdefined( self.player_shield_reset_health ) )
			self [[ self.player_shield_reset_health ]]();
	}

	if ( isdefined( self.grief_savedweapon_claymore ) && self.grief_savedweapon_claymore )
	{
		self giveweapon( "claymore_zm" );
		self set_player_placeable_mine( "claymore_zm" );
		self setactionslot( 4, "weapon", "claymore_zm" );
		self setweaponammoclip( "claymore_zm", self.grief_savedweapon_claymore_clip );
	}

	primaries = self getweaponslistprimaries();

	foreach ( weapon in primaries )
	{
		if ( isdefined( self.grief_savedweapon_currentweapon ) && self.grief_savedweapon_currentweapon == weapon )
		{
			self switchtoweapon( weapon );
			return true;
		}
	}

	if ( primaries.size > 0 )
	{
		self switchtoweapon( primaries[0] );
		return true;
	}
	return false;
}

grief_store_player_scores()
{
	players = getPlayers();

	foreach ( player in players )
		player._pre_round_score = player.score;
}

grief_restore_player_score()
{
	if ( !isdefined( self._pre_round_score ) )
		self._pre_round_score = self.score;

	if ( isdefined( self._pre_round_score ) )
	{
		self.score = self._pre_round_score;
		self.pers["score"] = self._pre_round_score;
	}
}

update_players_on_bleedout_or_disconnect( excluded_player )
{
	other_team = undefined;
	players = getPlayers();
	players_remaining = 0;

	foreach ( player in players )
	{
		if ( player == excluded_player )
		{

		}
		else if ( player.team == excluded_player.team )
		{
			if ( is_player_valid( player ) )
				players_remaining++;
		}
	}

	foreach ( player in players )
	{
		if ( player == excluded_player )
		{

		}
		else if ( player.team != excluded_player.team )
		{
			other_team = player.team;

			if ( players_remaining < 1 )
			{
				player thread show_grief_hud_msg( &"ZOMBIE_ZGRIEF_ALL_PLAYERS_DOWN", undefined, undefined, 1 );
				player delay_thread_watch_host_migrate( 2, ::show_grief_hud_msg, &"ZOMBIE_ZGRIEF_SURVIVE", undefined, 30, 1 );
			}
			else 
			{
				player thread show_grief_hud_msg( &"ZOMBIE_ZGRIEF_PLAYER_BLED_OUT", players_remaining );
			}
		}
	}
}

delay_thread_watch_host_migrate( timer, func, param1, param2, param3, param4, param5, param6 )
{
	self thread _delay_thread_watch_host_migrate_proc( func, timer, param1, param2, param3, param4, param5, param6 );
}

_delay_thread_watch_host_migrate_proc( func, timer, param1, param2, param3, param4, param5, param6 )
{
	self endon( "death" );
	self endon( "disconnect" );
	wait( timer );

	if ( isdefined( level.hostmigrationtimer ) )
	{
		while ( isdefined( level.hostmigrationtimer ) )
			wait 0.05;

		wait( timer );
	}

	single_thread( self, func, param1, param2, param3, param4, param5, param6 );
}

grief_round_end_custom_logic()
{
	waittillframeend;

	if ( isdefined( level.gamemodulewinningteam ) )
		level notify( "end_round_think" );
}
