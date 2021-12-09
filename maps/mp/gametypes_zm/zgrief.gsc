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

main()
{
	EVENT_START( "ZGRIEF_MAIN" );
	maps/mp/gametypes_zm/_zm_gametype::main();
	level.onprecachegametype = ::onprecachegametype;
	level.onstartgametype = ::onstartgametype;
	level._game_module_custom_spawn_init_func = maps/mp/gametypes_zm/_zm_gametype::custom_spawn_init_func;
	level._game_module_stat_update_func = maps/mp/zombies/_zm_stats::grief_custom_stat_update;
	level.gamemode_map_postinit[ "zgrief" ] = ::postinit_func;
	maps/mp/gametypes_zm/_zm_gametype::post_gametype_main( "zgrief" );
	level.grief_connected_callback = ::zgrief_connected;
	EVENT_END( "ZGRIEF_MAIN" );
}

zgrief_connected()
{
	self thread maps/mp/gametypes_zm/zmeat::create_item_meat_watcher();
}

postinit_func()
{
	EVENT_START( "ZGRIEF_POSTINIT" );
	level.powerup_drop_count = 0;
	level.is_zombie_level = 1;
	level.meat_bounce_override = ::meat_bounce_override;
	level._effect[ "meat_impact" ] = loadfx( "maps/zombie/fx_zmb_meat_impact" );
	level._effect[ "spawn_cloud" ] = loadfx( "maps/zombie/fx_zmb_race_zombie_spawn_cloud" );
	level._effect[ "meat_stink_camera" ] = loadfx( "maps/zombie/fx_zmb_meat_stink_camera" );
	level._effect[ "meat_stink_torso" ] = loadfx( "maps/zombie/fx_zmb_meat_stink_torso" );
	include_powerup( "meat_stink" );
	maps/mp/zombies/_zm_powerups::add_zombie_powerup( "meat_stink", "t6_wpn_zmb_meat_world", &"ZOMBIE_POWERUP_MAX_AMMO", ::func_should_drop_meat, 0, 0, 0 );
	EVENT_END( "ZGRIEF_POSTINIT" );
}

func_should_drop_meat()
{
	players = get_players();
	for ( i = 0; i < players.size; i++ )
	{
		if ( players[ i ].ignoreme == 1 )
		{
			return false;
		}
	}
	if ( is_true( level.meat_on_ground) )
	{
		return false;
	}
	return true;
}

onprecachegametype()
{
	EVENT_START( "ZGRIEF_ONPRECACHEGAMETYPE" );
	precacheitem( "death_self_zm" );
	level._effect[ "butterflies" ] = loadfx( "maps/zombie/fx_zmb_impact_noharm" );
	level thread maps/mp/zombies/_zm_game_module_meat_utility::init_item_meat( "zgrief" );
	rungametypeprecache( "zgrief" );
	EVENT_END( "ZGRIEF_ONPRECACHEGAMETYPE" );
}

onstartgametype()
{
	EVENT_START( "ZGRIEF_ONSTARTGAMETYPE" );
	rungametypemain( "zgrief" );
	EVENT_END( "ZGRIEF_ONSTARTGAMETYPE" );
}

meat_stink_powerup_grab( powerup, who )
{
	switch ( powerup.powerup_name )
	{
		case "meat_stink":
			level thread meat_stink( who );
			break;
		default:
			break;
	}
}

meat_stink( who )
{
	weapons = who getweaponslist();
	has_meat = 0;
	foreach ( weapon in weapons )
	{
		if ( weapon == "item_meat_zm" )
		{
			has_meat = true;
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

meat_stink_on_ground( position_to_play )
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
	if ( isDefined( ent ) && isPlayer( ent ) )
	{
		if ( !ent maps/mp/zombies/_zm_laststand::player_is_in_laststand() )
		{
			level thread meat_stink_player( ent );
			if ( isDefined( self.owner ) )
			{
				//ent scripts/zm/grief/mechanics/_point_steal::attacker_steal_points( self.owner, "meat" );
				maps/mp/_demo::bookMark( "zm_player_meat_stink", GetTime(), ent, self.owner, 0, self );
				self.owner maps/mp/zombies/_zm_stats::increment_client_stat( "contaminations_given" );
			}
		}
	}
	else
	{
		players = getPlayers();
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

meat_stink_player( who )
{
	level notify( "new_meat_stink_player" );
	level endon( "new_meat_stink_player" );
	who.ignoreme = 0;
	players = getPlayers();
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
	players = getPlayers();
	foreach ( player in players )
	{
		player thread meat_stink_player_cleanup();
		player.ignoreme = 0;
	}
}

meat_stink_player_create()
{
	self maps/mp/zombies/_zm_stats::increment_client_stat( "contaminations_received" );
	self endon( "disconnect" );
	self endon( "death" );
	tagname = "J_SpineLower";
	self.meat_stink_3p = spawn( "script_model", self getTagOrigin( tagname ) );
	self.meat_stink_3p setModel( "tag_origin" );
	self.meat_stink_3p linkTo( self, tagname );
	wait 0.5;
	playFXontag( level._effect[ "meat_stink_torso" ], self.meat_stink_3p, "tag_origin" );
	self setClientfieldToPlayer( "meat_stink", 1 );
}

meat_stink_player_cleanup()
{
	if ( isDefined( self.meat_stink_3p ) )
	{
		self.meat_stink_3p unLink();
		self.meat_stink_3p delete();
	}
	self setClientfieldToPlayer( "meat_stink", 0 );
}