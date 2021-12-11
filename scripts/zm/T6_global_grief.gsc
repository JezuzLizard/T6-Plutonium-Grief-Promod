#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/_utility;
#include maps/mp/zombies/_zm_laststand;
#include maps/mp/zombies/_zm_weap_cymbal_monkey;
#include maps/mp/zombies/_zm_magicbox;
#include maps/mp/zombies/_zm_game_module;
#include maps/mp/zombies/_zm_equipment;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_audio_announcer;
#include maps/mp/zombies/_zm_zonemgr;
#include maps/mp/zombies/_zm;
#include maps/mp/zombies/_zm_powerups;

main()
{
	gametype = getDvar( "g_gametype" );
	if ( gametype != "zgrief" )
	{
		precacheshellshock( "grief_stab_zm" );
		level.game_module_onplayerconnect = ::grief_onplayerconnect;
		level thread maps/mp/gametypes_zm/_zm_gametype::init();
	}
}

init()
{
	gametype = getDvar( "g_gametype" );
	if ( gametype != "zgrief" )
	{
		level.custom_end_screen = ::custom_end_screen;
		level._game_module_player_laststand_callback = ::grief_laststand_weapon_save;
		level.prevent_player_damage = ::player_prevent_damage;
		level.round_end_custom_logic = ::grief_round_end_custom_logic;
		level._game_module_game_end_check = ::grief_game_end_check_func;
		level._game_module_player_damage_grief_callback = ::game_module_player_damage_grief_callback;
		if ( level.script != "zm_prison" && level.script != "zm_tomb" )
		{
			level._effect[ "butterflies" ] = loadfx( "maps/zombie/fx_zmb_impact_noharm" );
		}
		level._grief_reset_message = ::grief_reset_message;
		level.game_mode_custom_onplayerdisconnect = ::grief_onplayerdisconnect;
		level._supress_survived_screen = true;
		level.custom_spectate_permissions = ::setspectatepermissionsgrief;
		level._get_game_module_players = undefined;
		level.game_mode_spawn_player_logic = ::game_mode_spawn_player_logic;
		level._game_module_player_damage_callback = maps/mp/gametypes_zm/_zm_gametype::game_module_player_damage_callback;
		level.onplayerspawned_restore_previous_weapons = ::grief_laststand_weapons_return;
		level thread run_on_blackscreen_passed();
	}
}

run_on_blackscreen_passed()
{
	flag_wait( "initial_blackscreen_passed" );
	gametype = getDvar( "g_gametype" );
	if ( gametype != "zgrief" )
	{
		level thread maps/mp/zombies/_zm_game_module::wait_for_team_death_and_round_end();
	}
}

custom_end_screen()
{
	players = getPlayers();
	for ( i = 0; i < players.size; i++ )
	{
		players[ i ].game_over_hud = newclienthudelem( players[ i ] );
		players[ i ].game_over_hud.alignx = "center";
		players[ i ].game_over_hud.aligny = "middle";
		players[ i ].game_over_hud.horzalign = "center";
		players[ i ].game_over_hud.vertalign = "middle";
		players[ i ].game_over_hud.y -= 130;
		players[ i ].game_over_hud.foreground = 1;
		players[ i ].game_over_hud.fontscale = 3;
		players[ i ].game_over_hud.alpha = 0;
		players[ i ].game_over_hud.color = ( 1, 1, 1 );
		players[ i ].game_over_hud.hidewheninmenu = 1;
		players[ i ].game_over_hud settext( &"ZOMBIE_GAME_OVER" );
		players[ i ].game_over_hud fadeovertime( 1 );
		players[ i ].game_over_hud.alpha = 1;
		players[ i ].survived_hud = newclienthudelem( players[ i ] );
		players[ i ].survived_hud.alignx = "center";
		players[ i ].survived_hud.aligny = "middle";
		players[ i ].survived_hud.horzalign = "center";
		players[ i ].survived_hud.vertalign = "middle";
		players[ i ].survived_hud.y -= 100;
		players[ i ].survived_hud.foreground = 1;
		players[ i ].survived_hud.fontscale = 2;
		players[ i ].survived_hud.alpha = 0;
		players[ i ].survived_hud.color = ( 1, 1, 1 );
		players[ i ].survived_hud.hidewheninmenu = 1;
		winner_text = &"ZOMBIE_GRIEF_WIN";
		loser_text = &"ZOMBIE_GRIEF_LOSE";
		if ( level.round_number < 2 )
		{
			winner_text = &"ZOMBIE_GRIEF_WIN_SINGLE";
			loser_text = &"ZOMBIE_GRIEF_LOSE_SINGLE";
		}
		if ( is_true( level.host_ended_game ) )
		{
			players[ i ].survived_hud settext( &"MP_HOST_ENDED_GAME" );
		}
		else
		{
			if ( isDefined( level.gamemodulewinningteam ) && players[ i ]._encounters_team == level.gamemodulewinningteam )
			{
				players[ i ].survived_hud settext( winner_text, level.round_number );
			}
			else
			{
				players[ i ].survived_hud settext( loser_text, level.round_number );
			}
		}
		players[ i ].survived_hud fadeovertime( 1 );
		players[ i ].survived_hud.alpha = 1;
	}
}

player_prevent_damage( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime )
{
	if ( isDefined( eattacker ) && isplayer( eattacker ) && self != eattacker && !eattacker hasperk( "specialty_noname" ) && !is_true( self.is_zombie ))
	{
		return 1;
	}
	return 0;
}

grief_laststand_weapon_save( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration )
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
	if ( isDefined( self.current_equipment ) )
	{
		self.grief_savedweapon_equipment = self.current_equipment;
	}
}

grief_round_end_custom_logic()
{
	waittillframeend;
	if ( isDefined( level.gamemodulewinningteam ) )
	{
		level notify( "end_round_think" );
	}
}

grief_game_end_check_func()
{
	return 0;
}

game_module_player_damage_grief_callback( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime )
{
	penalty = 10;
	if ( isDefined( eattacker ) && isplayer( eattacker ) && eattacker != self && eattacker.team != self.team && smeansofdeath == "MOD_MELEE" )
	{
		self applyknockback( idamage, vdir );
	}
}

grief_onplayerdisconnect( disconnecting_player )
{
	level thread update_players_on_bleedout_or_disconnect( disconnecting_player );
}

show_grief_hud_msg_cleanup()
{
	self endon( "death" );
	level waittill( "end_game" );
	if ( isDefined( self ) )
	{
		self destroy();
	}
}

grief_reset_message()
{
	msg = &"ZOMBIE_GRIEF_RESET";
	players = getPlayers();
	if ( isDefined( level.hostmigrationtimer ) )
	{
		while ( isDefined( level.hostmigrationtimer ) )
		{
			wait 0.05;
		}
		wait 4;
	}
	foreach ( player in players )
	{
		player thread show_grief_hud_msg( msg );
	}
	level thread maps/mp/zombies/_zm_audio_announcer::leaderdialog( "grief_restarted" );
}

show_grief_hud_msg( msg, msg_parm, offset, cleanup_end_game )
{
	self endon( "disconnect" );
	while ( isDefined( level.hostmigrationtimer ) )
	{
		wait 0.05;
	}
	zgrief_hudmsg = newclienthudelem( self );
	zgrief_hudmsg.alignx = "center";
	zgrief_hudmsg.aligny = "middle";
	zgrief_hudmsg.horzalign = "center";
	zgrief_hudmsg.vertalign = "middle";
	zgrief_hudmsg.y -= 130;
	if ( isDefined( offset ) )
	{
		zgrief_hudmsg.y += offset;
	}
	zgrief_hudmsg.foreground = 1;
	zgrief_hudmsg.fontscale = 5;
	zgrief_hudmsg.alpha = 0;
	zgrief_hudmsg.color = ( 1, 1, 1 );
	zgrief_hudmsg.hidewheninmenu = 1;
	zgrief_hudmsg.font = "default";
	if ( isDefined( cleanup_end_game ) && cleanup_end_game )
	{
		level endon( "end_game" );
		zgrief_hudmsg thread show_grief_hud_msg_cleanup();
	}
	if ( isDefined( msg_parm ) )
	{
		zgrief_hudmsg settext( msg, msg_parm );
	}
	else
	{
		zgrief_hudmsg settext( msg );
	}
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
	if ( isDefined( zgrief_hudmsg ) )
	{
		zgrief_hudmsg destroy();
	}
}

grief_onplayerconnect()
{
	self thread zgrief_player_bled_out_msg();
}

zgrief_player_bled_out_msg()
{
	level endon( "end_game" );
	self endon( "disconnect" );
	while ( true )
	{
		self waittill( "bled_out" );
		level thread update_players_on_bleedout_or_disconnect( self );
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
			{
				players_remaining++;
			}
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
			player thread show_grief_hud_msg( &"ZOMBIE_ZGRIEF_PLAYER_BLED_OUT", players_remaining );
		}
	}
	if ( players_remaining == 1 )
	{
		level thread maps/mp/zombies/_zm_audio_announcer::leaderdialog( "last_player", excluded_player.team );
	}
	if ( !isDefined( other_team ) )
	{
		return;
	}
	if ( players_remaining < 1 )
	{
		level thread maps/mp/zombies/_zm_audio_announcer::leaderdialog( "4_player_down", other_team );
	}
	else
	{
		level thread maps/mp/zombies/_zm_audio_announcer::leaderdialog( players_remaining + "_player_left", other_team );
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
	wait timer;
	if ( isDefined( level.hostmigrationtimer ) )
	{
		while ( isDefined( level.hostmigrationtimer ) )
		{
			wait 0.05;
		}
		wait timer;
	}
	single_thread( self, func, param1, param2, param3, param4, param5, param6 );
}

setspectatepermissionsgrief()
{
	self allowspectateteam( "allies", 1 );
	self allowspectateteam( "axis", 1 );
	self allowspectateteam( "freelook", 0 );
	self allowspectateteam( "none", 1 );
}

game_mode_spawn_player_logic()
{
	if ( flag( "start_zombie_round_logic" ) && !isDefined( self.is_hotjoin ) )
	{
		self.is_hotjoin = 1;
		return 1;
	}
	return 0;
}

grief_laststand_weapons_return()
{
	if ( isDefined( level.isresetting_grief ) && !level.isresetting_grief )
	{
		return 0;
	}
	if ( !isDefined( self.grief_savedweapon_weapons ) )
	{
		return 0;
	}
	primary_weapons_returned = 0;
	i = 0;
	while ( i < self.grief_savedweapon_weapons.size )
	{
		if ( isdefined( self.grief_savedweapon_grenades ) && self.grief_savedweapon_weapons[ i ] == self.grief_savedweapon_grenades || ( isdefined( self.grief_savedweapon_tactical ) && self.grief_savedweapon_weapons[ i ] == self.grief_savedweapon_tactical ) )
		{
			i++;
			continue;
		}
		if ( isweaponprimary( self.grief_savedweapon_weapons[ i ] ) )
		{
			if ( primary_weapons_returned >= 2 )
			{
				i++;
				continue;
			}
			primary_weapons_returned++;
		}
		if ( "item_meat_zm" == self.grief_savedweapon_weapons[ i ] )
		{
			i++;
			continue;
		}
		self giveweapon( self.grief_savedweapon_weapons[ i ], 0, self maps/mp/zombies/_zm_weapons::get_pack_a_punch_weapon_options( self.grief_savedweapon_weapons[ i ] ) );
		if ( isdefined( self.grief_savedweapon_weaponsammo_clip[ i ] ) )
		{
			self setweaponammoclip( self.grief_savedweapon_weapons[ i ], self.grief_savedweapon_weaponsammo_clip[ i ] );
		}
		if ( isdefined( self.grief_savedweapon_weaponsammo_stock[ i ] ) )
		{
			self setweaponammostock( self.grief_savedweapon_weapons[ i ], self.grief_savedweapon_weaponsammo_stock[ i ] );
		}
		i++;
	}
	if ( isDefined( self.grief_savedweapon_grenades ) )
	{
		self giveweapon( self.grief_savedweapon_grenades );
		if ( isDefined( self.grief_savedweapon_grenades_clip ) )
		{
			self setweaponammoclip( self.grief_savedweapon_grenades, self.grief_savedweapon_grenades_clip );
		}
	}
	if ( isDefined( self.grief_savedweapon_tactical ) )
	{
		self giveweapon( self.grief_savedweapon_tactical );
		if ( isDefined( self.grief_savedweapon_tactical_clip ) )
		{
			self setweaponammoclip( self.grief_savedweapon_tactical, self.grief_savedweapon_tactical_clip );
		}
	}
	if ( isDefined( self.current_equipment ) )
	{
		self maps/mp/zombies/_zm_equipment::equipment_take( self.current_equipment );
	}
	if ( isDefined( self.grief_savedweapon_equipment ) )
	{
		self.do_not_display_equipment_pickup_hint = 1;
		self maps/mp/zombies/_zm_equipment::equipment_give( self.grief_savedweapon_equipment );
		self.do_not_display_equipment_pickup_hint = undefined;
	}
	if ( isDefined( self.grief_hasriotshield ) && self.grief_hasriotshield )
	{
		if ( isDefined( self.player_shield_reset_health ) )
		{
			self [[ self.player_shield_reset_health ]]();
		}
	}
	if ( isDefined( self.grief_savedweapon_claymore ) && self.grief_savedweapon_claymore )
	{
		self giveweapon( "claymore_zm" );
		self set_player_placeable_mine( "claymore_zm" );
		self setactionslot( 4, "weapon", "claymore_zm" );
		self setweaponammoclip( "claymore_zm", self.grief_savedweapon_claymore_clip );
	}
	primaries = self getweaponslistprimaries();
	foreach ( weapon in primaries )
	{
		if ( isDefined( self.grief_savedweapon_currentweapon ) && self.grief_savedweapon_currentweapon == weapon )
		{
			self switchtoweapon( weapon );
			return 1;
		}
	}
	if ( primaries.size > 0 )
	{
		self switchtoweapon( primaries[ 0 ] );
		return 1;
	}
	return 0;
}