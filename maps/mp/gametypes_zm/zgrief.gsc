#include maps/mp/zombies/_zm_equipment;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_audio_announcer;
#include maps/mp/zombies/_zm_zonemgr;
#include maps/mp/_demo;
#include maps/mp/zombies/_zm_laststand;
#include maps/mp/zombies/_zm_weap_cymbal_monkey;
#include maps/mp/zombies/_zm_magicbox;
#include maps/mp/zombies/_zm_game_module;
#include maps/mp/zombies/_zm;
#include maps/mp/zombies/_zm_game_module_meat_utility;
#include maps/mp/zombies/_zm_powerups;
#include maps/mp/gametypes_zm/zmeat;
#include maps/mp/zombies/_zm_stats;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/_utility;
#include maps/mp/zombies/_zm_spawner;

main() //checked matches cerberus output
{
	maps/mp/gametypes_zm/_zm_gametype::main();
	level.onprecachegametype = ::onprecachegametype;
	level.onstartgametype = ::onstartgametype;
	level.custom_spectate_permissions = ::setspectatepermissionsgrief;
	level._game_module_custom_spawn_init_func = maps/mp/gametypes_zm/_zm_gametype::custom_spawn_init_func;
	level._game_module_stat_update_func = maps/mp/zombies/_zm_stats::grief_custom_stat_update;
	level._game_module_player_damage_callback = maps/mp/gametypes_zm/_zm_gametype::game_module_player_damage_callback;
	level.custom_end_screen = ::custom_end_screen;
	level.gamemode_map_postinit[ "zgrief" ] = ::postinit_func;
	level._supress_survived_screen = 1;
	level.prevent_player_damage = ::player_prevent_damage;
	maps/mp/gametypes_zm/_zm_gametype::post_gametype_main( "zgrief" );
}

setspectatepermissionsgrief() //checked matches cerberus output
{
	self allowspectateteam( "allies", 1 );
	self allowspectateteam( "axis", 1 );
	self allowspectateteam( "freelook", 0 );
	self allowspectateteam( "none", 1 );
}

custom_end_screen() //checked changed to match cerberus output
{
	players = get_players();
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
		if ( players[ i ] issplitscreen() )
		{
			players[ i ].game_over_hud.fontscale = 2;
			players[ i ].game_over_hud.y += 40;
		}
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
		if ( players[ i ] issplitscreen() )
		{
			players[ i ].survived_hud.fontscale = 1.5;
			players[ i ].survived_hud.y += 40;
		}
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

postinit_func() //checked matches cerberus output
{
	level.prevent_player_damage = ::player_prevent_damage;
	level.powerup_drop_count = 0;
	level.is_zombie_level = 1;
	level.meat_bounce_override = ::meat_bounce_override;
	level._effect[ "meat_impact" ] = loadfx( "maps/zombie/fx_zmb_meat_impact" );
	level._effect[ "spawn_cloud" ] = loadfx( "maps/zombie/fx_zmb_race_zombie_spawn_cloud" );
	level._effect[ "meat_stink_camera" ] = loadfx( "maps/zombie/fx_zmb_meat_stink_camera" );
	level._effect[ "meat_stink_torso" ] = loadfx( "maps/zombie/fx_zmb_meat_stink_torso" );
	include_powerup("meat_stink");
	maps/mp/zombies/_zm_powerups::add_zombie_powerup( "meat_stink", "t6_wpn_zmb_meat_world", &"ZOMBIE_POWERUP_MAX_AMMO", ::func_should_drop_meat, 0, 0, 0 );
	setmatchtalkflag( "DeadChatWithDead", 1 );
	setmatchtalkflag( "DeadChatWithTeam", 1 );
	setmatchtalkflag( "DeadHearTeamLiving", 1 );
	setmatchtalkflag( "DeadHearAllLiving", 1 );
	setmatchtalkflag( "EveryoneHearsEveryone", 1 );
}

func_should_drop_meat() //checked matches cerberus output
{
	if ( minigun_no_drop() )
	{
		return 0;
	}
	return 1;
}

minigun_no_drop() //checked matches cerberus output
{
	players = get_players();
	for ( i = 0; i < players.size; i++ )
	{
		if ( players[ i ].ignoreme == 1 )
		{
			return 1;
		}
	}
	if ( is_true( level.meat_on_ground) )
	{
		return 1;
	}
	return 0;
}

grief_game_end_check_func() //checked matches cerberus output
{
	return 0;
}

player_prevent_damage( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime ) //checked matches cerberus output
{
	if ( isDefined( eattacker ) && isplayer( eattacker ) && self != eattacker && !eattacker hasperk( "specialty_noname" ) && !is_true( self.is_zombie ))
	{
		return 1;
	}
	return 0;
}

onprecachegametype() //checked matches cerberus output
{
	level.playersuicideallowed = 1;
	level.suicide_weapon = "death_self_zm";
	precacheitem( "death_self_zm" );
	precacheshellshock( "grief_stab_zm" );
	precacheshader( "faction_cdc" );
	precacheshader( "faction_cia" );
	precacheshader( "waypoint_revive_cdc_zm" );
	precacheshader( "waypoint_revive_cia_zm" );
	level._effect[ "butterflies" ] = loadfx( "maps/zombie/fx_zmb_impact_noharm" );
	level thread maps/mp/zombies/_zm_game_module_meat_utility::init_item_meat("zgrief");
	level thread maps/mp/gametypes_zm/_zm_gametype::init();
	maps/mp/gametypes_zm/_zm_gametype::rungametypeprecache( "zgrief" );
}

onstartgametype() //checked matches cerberus output
{
	level.no_end_game_check = 1;
	level._game_module_game_end_check = ::grief_game_end_check_func;
	maps/mp/gametypes_zm/_zm_gametype::setup_classic_gametype();
	maps/mp/gametypes_zm/_zm_gametype::rungametypemain( "zgrief", scripts/zm/grief/mechanics/_round_system::zgrief_main_override );
}

meat_stink_powerup_grab( powerup, who ) //checked matches cerberus output
{
	switch ( powerup.powerup_name )
	{
		case "meat_stink":
			level thread meat_stink( who );
			break;
	}
}

meat_stink( who ) //checked matches cerberus output
{
	weapons = who getweaponslist();
	has_meat = 0;
	foreach ( weapon in weapons )
	{
		if ( weapon == "item_meat_zm" )
		{
			has_meat = 1;
		}
	}
	if ( has_meat )
	{
		return;
	}
	who.pre_meat_weapon = who getcurrentweapon();
	level notify( "meat_grabbed" );
	who notify( "meat_grabbed" );
	who playsound( "zmb_pickup_meat" );
	who increment_is_drinking();
	who giveweapon( "item_meat_zm" );
	who switchtoweapon( "item_meat_zm" );
	who setweaponammoclip( "item_meat_zm", 1 );
}

meat_stink_on_ground( position_to_play ) //checked matches cerberus output
{
	level.meat_on_ground = 1;
	attractor_point = spawn( "script_model", position_to_play );
	attractor_point setmodel( "tag_origin" );
	attractor_point playsound( "zmb_land_meat" );
	wait 0.2 ;
	playfxontag( level._effect[ "meat_stink_torso" ], attractor_point, "tag_origin" );
	attractor_point playloopsound( "zmb_meat_flies" );
	attractor_point create_zombie_point_of_interest( 1536, 32, 10000 );
	attractor_point.attract_to_origin = 1;
	attractor_point thread create_zombie_point_of_interest_attractor_positions( 4, 45 );
	attractor_point thread maps/mp/zombies/_zm_weap_cymbal_monkey::wait_for_attractor_positions_complete();
	attractor_point delay_thread( 15, ::self_delete );
	wait 16 ;
	level.meat_on_ground = undefined;
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
				ent scripts/zm/grief/mechanics/_point_steal::attacker_steal_points( self.owner, "meat" );
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

meat_stink_player( who ) //checked matches cerberus output
{
	level notify( "new_meat_stink_player" );
	level endon( "new_meat_stink_player" );
	who.ignoreme = 0;
	players = get_players();
	foreach ( player in players )
	{
		player thread meat_stink_player_cleanup();
		if ( player != who ) 
		{
			player.ignoreme = 1;
		}
	}
	who thread meat_stink_player_create();
	who waittill_any_or_timeout( 30, "disconnect", "player_downed", "bled_out" );
	players = get_players();
	foreach ( player in players )
	{
		player thread meat_stink_player_cleanup();
		player.ignoreme = 0;
	}
}

meat_stink_player_create() //checked matches cerberus output
{
	self maps/mp/zombies/_zm_stats::increment_client_stat( "contaminations_received" );
	self endon( "disconnect" );
	self endon( "death" );
	tagname = "J_SpineLower";
	self.meat_stink_3p = spawn( "script_model", self gettagorigin( tagname ) );
	self.meat_stink_3p setmodel( "tag_origin" );
	self.meat_stink_3p linkto( self, tagname );
	wait 0.5;
	playfxontag( level._effect[ "meat_stink_torso" ], self.meat_stink_3p, "tag_origin" );
	self setclientfieldtoplayer( "meat_stink", 1 );
}

meat_stink_player_cleanup() //checked matches cerberus output
{
	if ( isdefined( self.meat_stink_3p ) )
	{
		self.meat_stink_3p unlink();
		self.meat_stink_3p delete();
	}
	self setclientfieldtoplayer( "meat_stink", 0 );
}