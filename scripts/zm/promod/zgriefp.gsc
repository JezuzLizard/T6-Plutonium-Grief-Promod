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
#include scripts\zm\promod\utility\_grief_util;
#include scripts\zm\promod\plugin\commands;
#include scripts\zm\promod\_hud;
#include scripts\zm\promod\_player_spawning;
#include scripts\zm\promod\_teams;
#include scripts\zm\promod\zgriefp_overrides;
#include scripts\zm\promod\_gamerules;
#include scripts\zm\promod\utility\_damagefeedback;
#include scripts\zm\promod\utility\_com;

zgriefp_init()
{
	//add_player_death_sounds();
	level thread monitor_players_connecting_status();
	level thread emptyLobbyRestart();
	scripts/zm/promod/plugin/commands::setup_permissions();
	scripts/zm/promod/utility/_grief_util::add_dvar_commands();
	init_gamerules();
	level._game_module_player_damage_callback = ::game_module_player_damage_callback;
	level._game_module_player_damage_grief_callback = ::game_module_player_damage_grief_callback;
	level.meat_bounce_override = ::meat_bounce_override;
	level.onspawnplayerunified = scripts/zm/promod/_player_spawning::onspawnplayerunified; 
	level.noroundnumber = 1;
	setDvar( "g_friendlyfireDist", 0 );
	teams_init();
	level.game_module_onplayerconnect = ::grief_onplayerconnect;
	level.game_mode_custom_onplayerdisconnect = ::grief_onplayerdisconnect;
	level.grief_round_win_next_round_countdown = ::round_change_hud;
	level.grief_round_intermission_countdown = ::intermission_hud;
	level.grief_loadout_save = ::grief_loadout_save;
	level.onplayerspawned_restore_previous_weapons = ::grief_laststand_weapons_return;
	level.custom_spawnplayer = scripts/zm/promod/_player_spawning::grief_spectator_respawn;
	level thread on_player_connect();
	level thread scripts/zm/promod/_hud::draw_hud();
}

monitor_players_connecting_status()
{
	while ( true )
	{
		level waittill( "connecting", player );
		player set_clan_tag();
		if ( !flag( "initial_players_connected" ) )
		{
			player thread kick_player_if_dont_spawn_in_time();
		}
	}
}

set_clan_tag()
{
	for ( i = 0; i < level.server_users[ "admins" ].guids.size; i++ )
	{
		if ( self getGUID() == level.server_users[ "admins" ].guids[ i ] )
		{
			self setClanTag( "Admin" );
			self.grief_is_admin = 1;
		}
	}
}

kick_player_if_dont_spawn_in_time()
{
	self endon( "begin" );
	wait 45;
	kick( self getEntityNumber() );
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
		player scripts/zm/promod/utility/_grief_util::init_player_session_data();
		//player scripts/zm/promod/plugin/commands::player_command_setup();
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
		if ( level.grief_gamerules[ "reduced_pistol_ammo" ] )
		{
			reduce_starting_ammo();
		}
	}
}

reduce_starting_ammo()
{	
	wait 0.05;
	if ( self hasweapon( "m1911_zm" ) && ( self getammocount( "m1911_zm" ) > 16 ) )
	{
		self setweaponammostock( "m1911_zm", 8 );
	}
}

give_points_on_restart_and_round_change()
{
	level endon( "end_game" );
	while ( true )
	{
		level waittill( "grief_new_round" );
		if ( self.score < level.grief_gamerules[ "round_restart_points" ] )
		{
			self.score = level.grief_gamerules[ "round_restart_points" ];
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
			return true;
		default:
			return false;
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

do_game_mode_shellshock( attacker, meansofdeath, weapon )
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

create_griefed_obituary_msg( victim, attacker, weapon, mod )
{
	return va( "OBITUARY;%s;%s;%s;%s;%s;%s", victim.team, victim.name, attacker.team, attacker.name, weapon, mod );
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
			play_random_sound_from_group( "player_death", self.origin );
			if ( isDefined( self.last_griefed_by.attacker ) && isDefined( self.last_griefed_by.meansofdeath ) )
			{
				if ( getDvarInt( "grief_killfeed_enable" ) == 1 )
				{
					obituary_message = create_griefed_obituary_msg( self, self.last_griefed_by.attacker, self.last_griefed_by.weapon, self.last_griefed_by.meansofdeath );
					players = array( self, self.last_griefed_by.attacker );
					COM_PRINTF( "obituary g_log", "obituary", obituary_message, players );
				}
				attacker.killsconfirmed++;
				attacker.pers[ "killsconfirmed" ]++;
			}
		}
	}
	self.grief_already_checking_for_down = 0;
}

meat_bounce_override( pos, normal, ent )
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
		attacker updatedamagefeedback( event );
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

/*public*/ wait_for_players()
{
	level endon( "end_game" );
	teamplayersallies = getPlayers( "allies");
	teamplayersaxis = getPlayers( "axis");
	while ( ( teamplayersaxis.size < 1 ) || ( teamplayersallies.size < 1 ) )
	{
		teamplayersallies = getPlayers( "allies");
		teamplayersaxis = getPlayers( "axis");
		players = getPlayers();
		for ( i = 0; i < players.size; i++ )
		{
			players[ i ] iPrintLn( "Waiting for 1 player on each team" );
		}
		wait 1;
	}
	// if ( getDvarInt( "grief_tournament_mode" ) == 1 )
	// {
	// 	players = getPlayers();
	// 	while ( getDvarInt( "zombies_minplayers" ) > players.size )
	// 	{
	// 		players = getPlayers();
	// 		for ( i = 0; i < players.size; i++ )
	// 		{
	// 			players[ i ] iPrintLn( "Waiting for all players to connect" );
	// 		}
	// 		wait 1;
	// 	}
	// }
}

team_suicide_check()
{
	flag_set( "checking_team_suicide" );
	wait level.grief_gamerules[ "suicide_check" ];
	flag_clear( "checking_team_suicide" );
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

grief_team_forfeit()
{
	if ( getDvarInt( "grief_testing" ) == 1 )
	{
		return false;
	}
	if ( ( getPlayers( "axis" ).size == 0 ) || ( getPlayers( "allies" ).size == 0 ) )
	{
		return true;
	}
	return false;
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
	team_scores[ "axis" ] = level.grief_teams[ "axis" ].score;
	team_scores[ "allies" ] = level.grief_teams[ "allies" ].score;
	score_limit = level.grief_gamerules[ "scorelimit" ];
	intermission_score = score_limit / 2;
	if ( team_scores[ "axis" ] == int( intermission_score ) || team_scores[ "allies" ] == int( intermission_score ) )
	{
		level.grief_intermission_done = true;
		return true;
	}
	return false;
}

grief_laststand_weapons_return() //checked changed to match cerberus output
{
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
		if ( isdefined( self.grief_savedweapon_weaponsammo_clip[ index ] ) )
		{
			self setweaponammoclip( self.grief_savedweapon_weapons[ i ], self.grief_savedweapon_weaponsammo_clip[ index ] );
		}
		if ( isdefined( self.grief_savedweapon_weaponsammo_stock[ index ] ) )
		{
			self setweaponammostock( self.grief_savedweapon_weapons[ i ], self.grief_savedweapon_weaponsammo_stock[ index ] );
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

grief_onplayerconnect() //checked matches cerberus output
{
	self thread move_team_icons();
	self thread zgrief_player_bled_out_msg();
}

move_team_icons() //checked matches cerberus output
{
	self endon( "disconnect" );
	flag_wait( "initial_blackscreen_passed" );
	wait 0.5;
}

zgrief_player_bled_out_msg() //checked matches cerberus output
{
	level endon( "end_game" );
	self endon( "disconnect" );
	while ( 1 )
	{
		self waittill( "bled_out" );
		level thread update_players_on_bleedout_or_disconnect( self );
	}
}

grief_onplayerdisconnect( disconnecting_player ) //checked matches cerberus output
{
	level thread update_players_on_bleedout_or_disconnect( disconnecting_player );
}

update_players_on_bleedout_or_disconnect( excluded_player ) //checked changed to match cerberus output
{
	level endon( "end_game" );
	players = getPlayers();
	if ( isDefined( level.predicted_round_winner ) )
	{
		foreach ( player in level.alive_players[ level.predicted_round_winner ] )
		{
			player thread show_grief_hud_msg( &"ZOMBIE_ZGRIEF_ALL_PLAYERS_DOWN", undefined, undefined, 1 );
			player delay_thread_watch_host_migrate( 2, ::show_grief_hud_msg, &"ZOMBIE_ZGRIEF_SURVIVE", undefined, 30, 1 );
		}
		level thread maps/mp/zombies/_zm_audio_announcer::leaderdialog( "4_player_down", level.predicted_round_winner );
	}
	else 
	{
		players = getPlayers( get_other_team( excluded_player.team ) );
		foreach ( player in players )
		{
			player thread show_grief_hud_msg( &"ZOMBIE_ZGRIEF_PLAYER_BLED_OUT", level.alive_players[ player.team ].size );
		}
		level thread maps/mp/zombies/_zm_audio_announcer::leaderdialog( level.alive_players[ excluded_player.team ].size + "_player_left", get_other_team( excluded_player.team ) );
	}

	if ( level.alive_players[ excluded_player.team ].size == 1 )
	{
		level thread maps/mp/zombies/_zm_audio_announcer::leaderdialog( "last_player", excluded_player.team );
	}
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

play_random_player_griefed_sound( griefed_player )
{

}

play_random_player_downed_sound( downed_player )
{

}

add_player_death_sounds()
{
	for ( i = 0; i < 6; i++ )
	{
		add_random_sound( "player_death", "vox_us_death_0" + i, 5 );
	}
	
}


/*
round ending killcam
final killcam

"mpl_final_kill_cam_sting"
*/