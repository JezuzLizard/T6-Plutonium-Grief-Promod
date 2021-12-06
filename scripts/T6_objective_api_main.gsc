#include maps/mp/gametypes_zm/_hud;
#include maps/mp/gametypes_zm/_hud_message;
#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/_utility;
#include common_scripts/utility;

init()
{
	if( getDvarIntDefault( "hud_health_indicators", 0 ) )
	{
		level.health_indicators_thresholds = [];
		level.health_indicators_thresholds[ "damaged" ] = 0.6;
		level.health_indicators_thresholds[ "hurt" ] = 0.2;
		level.health_indicators_thresholds[ "near_death" ] = 0.01;
		level.health_indicators_thresholds[ "dead" ] = 0.0;
		level.waypoint_size = 2;
		level.waypoint_height_offset = ( 0, 0, 80 );
		level.location_pings_feature_enabled = getDvarIntDefault( "obj_player_waypoints_location_pings_enabled", 0 );
		level.health_indicators_feature_enabled = getDvarIntDefault( "obj_player_waypoints_health_indicators_enabled", 1 );
		level.health_indicators_show_on_full_health = getDvarIntDefault( "obj_player_waypoints_health_indicators_show_on_full_health", 0 );
		level.location_pings_duration = 5;
		if ( level.location_pings_feature_enabled )
		{
			OBJ_ADD_NEW( "location_pings", ::LOCATION_INDICATOR_UPDATE );
		}
		if ( level.health_indicators_feature_enabled )
		{
			OBJ_ADD_NEW( "overhead_health_indicator", ::HEALTH_INDICATOR_UPDATE );
		}
		level.location_pings_player_colors = array( ( 1, 1, 1 ), ( 0.49, 0.81, 0.93 ), ( 0.96, 0.79, 0.31 ), ( 0.51, 0.93, 0.53 ), ( 0.47, 0.34, 0.08 ), ( 0.24, 0.91, 0.93 ), ( 0.93, 0.24, 0.27 ), ( 0.97, 0.54, 0.06 ) );
		level.location_pings_hud_index = 0;
		level thread on_player_connect();
		level thread destroy_all_hud_on_end_game();
	}
}

on_player_connect()
{
	level endon("end_game");
	level endon("game_ended");
	for(;;)
	{
		level waittill( "connected", player );
		waittillframeend;
		wait 1;
		if ( level.health_indicators_feature_enabled )
		{
			hud_ref = player OBJ_ADD_PLAYER( "overhead_health_indicator", "all", true, 2, false );
		}
		if ( level.location_pings_feature_enabled )
		{
			player thread watch_for_location_ping();
		}
		player thread on_player_disconnect();
	}
}

on_player_disconnect()
{
	guid = self getGUID();
	self waittill( "disconnect" );
	hud_keys = getArrayKeys( level.custom_objectives );
	foreach ( key in hud_keys )
	{
		index = level.custom_objectives[ key ] OBJ_FIND_ENT_INDEX( guid );
		level.custom_objectives[ key ].players[ index ] notify( "destroy_hud_ent" );
	}
}

destroy_all_hud_on_end_game()
{
	level waittill_either( "end_game", "game_ended" );
	hud_keys = getArrayKeys( level.custom_objectives );
	foreach ( name in hud_keys )
	{
		OBJ_REMOVE( name );
	}
}

OBJ_ADD_NEW( name, update_func )
{
	if ( !isDefined( level.custom_objectives ) )
	{
		level.custom_objectives = [];
	}
	if ( !isDefined( level.custom_objectives[ name ] ) )
	{
		level.custom_objectives[ name ] = spawnStruct();
		level.custom_objectives[ name ].update_func = update_func;
		level.custom_objectives[ name ] thread OBJ_DESTROY_THREAD( name );
	}
}

OBJ_REMOVE( name )
{
	level.custom_objectives[ name ] notify( "destroy_hud" );
}

OBJ_DESTROY_THREAD( name )
{
	self waittill( "destroy_hud" );
	foreach ( elem in self.players )
	{
		elem OBJ_REMOVE_PLAYER();
	}
	self.players = undefined;
	self.update_func = undefined;
	arrayRemoveIndex( level.custom_objectives, name, true );
}

OBJ_FIND_ENT_INDEX( guid )
{
	index = 0;
	foreach ( elem in self.players )
	{
		if ( elem.guid == guid )
		{
			return index;
		}
		index++;
	}
}

OBJ_ALLOCATE_ENT( player )
{
	return self.players.size;
}

OBJ_ADD_PLAYER( obj_name, visible_to_team, link_to_player, base_size, use_constant_size, offscreen_shader )
{
	if ( !isDefined( level.custom_objectives[ obj_name ].players ) )
	{
		level.custom_objectives[ obj_name ].players = [];
	}
	if ( visible_to_team == "all" )
	{
		elem_team = undefined;
	}
	else
	{
		elem_team = team;
	}
	index = level.custom_objectives[ obj_name ] OBJ_ALLOCATE_ENT( self );
	level.custom_objectives[ obj_name ].players[ index ] = OBJ_CREATE_SERVER_WAYPOINT( elem_team );
	level.custom_objectives[ obj_name ].players[ index ].guid = self getGUID();
	level.custom_objectives[ obj_name ].players[ index ].target_ent = OBJ_SPAWN_ENT_ON_ENT( self, level.waypoint_height_offset, link_to_player );
	level.custom_objectives[ obj_name ].players[ index ].color = ( 1, 1, 1 );
	level.custom_objectives[ obj_name ].players[ index ] setShader( "white", base_size, base_size );
	if ( isDefined( offscreen_shader ) )
	{
		level.custom_objectives[ obj_name ].players[ index ] setWayPoint( is_true( use_constant_size ), offscreen_shader );
	}
	else 
	{
		level.custom_objectives[ obj_name ].players[ index ] setWayPoint( is_true( use_constant_size ) );
	}
	level.custom_objectives[ obj_name ].players[ index ] setTargetEnt( level.custom_objectives[ obj_name ].players[ index ].target_ent );
	self thread [[ level.custom_objectives[ obj_name ].update_func ]]( level.custom_objectives[ obj_name ].players[ index ] );
	level.custom_objectives[ obj_name ].players[ index ] thread OBJ_ENT_DEATH( obj_name, index, self getGUID(), link_to_player );
	level.custom_objectives[ obj_name ].players[ index ] thread OBJ_REMOVE_FAILSAFE( self );
	return level.custom_objectives[ obj_name ].players[ index ];
}

OBJ_REMOVE_PLAYER()
{
	self notify( "destroy_hud_ent" );
}

OBJ_REMOVE_FAILSAFE( player )
{
	level endon( "end_game" );
	level endon( "game_ended" );
	while ( true )
	{
		if ( !isInArray( level.players, player ) )
		{
			break;
		}
		wait 1;
	}
	self notify( "destroy_hud_ent" );
}

OBJ_ENT_DEATH( obj_name, index, guid, link_to_player )
{
	self waittill( "destroy_hud_ent" );
	self setShader( "white", level.waypoint_size, level.waypoint_size );
	self clearTargetEnt();
	self.guid = undefined;
	if ( link_to_player )
	{
		self.target_ent unLink();
	}
	self.target_ent delete();
	self destroy();
	arrayRemoveIndex( level.custom_objectives[ obj_name ].players, index );
}

OBJ_SPAWN_ENT_ON_ENT( ent, offset, link )
{
	if ( !isDefined( offset ) )
	{
		offset = ( 0, 0, 0 );
	}
	elem_ent = spawn( "script_model", ent.origin + offset );
	elem_ent setModel( "script_origin" );
	if ( is_true( link ) )
	{
		elem_ent linkTo( ent );
	}
	return elem_ent;
}

OBJ_CREATE_SERVER_WAYPOINT( team )
{
	if ( isDefined( team ) )
	{
		barelembg = newteamhudelem( team );
	}
	else
	{
		barelembg = newhudelem();
	}
	barelembg.elemtype = "icon";
	barelembg.x = 0;
	barelembg.y = 0;
	barelembg.xoffset = 0;
	barelembg.yoffset = 0;
	barelembg.alpha = 0;
	barelembg.hidden = 0;
	return barelembg;
}

HEALTH_INDICATOR_UPDATE( health_indicator )
{
	self endon( "disconnect" );
	level endon("end_game");
	level endon("game_ended");
	
	if (flag_exists("initial_blackscreen_passed") && !flag("initial_blackscreen_passed"))
		flag_wait( "initial_blackscreen_passed" );
	health_indicator.hidewheninmenu = 1;
	while ( true )
	{
		if ( isDefined( self.e_afterlife_corpse ) || !is_player_valid( self ) )
		{
			if ( health_indicator.alpha != 0 )
			{
				health_indicator.alpha = 0;
			}
			wait 0.05;
			continue;
		}
		if ( health_indicator.alpha != 1 )
		{
			health_indicator.alpha = 1;
		}
		health_indicator set_color_from_health_fraction( float( ( self.health / self.maxhealth ) ) );
		wait 0.05;
	}
}

//1.0 == 0%, 0.61 == 100%

set_color_from_health_fraction( frac )
{
	if ( frac < 1.0 && frac > level.health_indicators_thresholds[ "damaged" ] )
	{
		red_frac = ceil( ( 255/320 ) * 100 ) / 100;
		green_frac = ceil( ( 255/320 ) * 100 ) / 100;
		self.color = ( red_frac, green_frac, 0 );
	}
	else if ( frac < 1.0 && frac > level.health_indicators_thresholds[ "hurt" ] )
	{
		green_frac = ceil( ( 100/320 ) * 100 ) / 100;
		self.color = ( 1, green_frac, 0 );
	}
	else if ( frac < 1.0 && frac >= level.health_indicators_thresholds[ "near_death" ] )
	{
		red_frac = ceil( ( 255/320 ) * 100 ) / 100;
		self.color = ( red_frac, 0, 0 );
	}
	else if ( frac <= level.health_indicators_thresholds[ "dead" ] )
	{
		self.alpha = 0;
	}
	else
	{
		green_frac = ceil( ( 255 / 320 ) * 100 ) / 100;
		self.color = ( 0, green_frac, 0 );
		if ( !level.health_indicators_show_on_full_health )
		{
			self.alpha = 0;
		}
	}
}

is_player_valid( player, checkignoremeflag, ignore_laststand_players )
{
	if ( !isDefined( player ) )
	{
		return 0;
	}
	if ( !isalive( player ) )
	{
		return 0;
	}
	if ( !isplayer( player ) )
	{
		return 0;
	}
	if ( isDefined( player.is_zombie ) && player.is_zombie == 1 )
	{
		return 0;
	}
	if ( player.sessionstate == "spectator" )
	{
		return 0;
	}
	if ( player.sessionstate == "intermission" )
	{
		return 0;
	}
	if ( is_true( self.intermission ) )
	{
		return 0;
	}
	if ( !is_true( ignore_laststand_players ) )
	{
		if ( player player_is_in_laststand() )
		{
			return 0;
		}
	}
	if ( is_true( checkignoremeflag ) && player.ignoreme )
	{
		return 0;
	}
	if ( isDefined( level.is_player_valid_override ) )
	{
		return [[ level.is_player_valid_override ]]( player );
	}
	return 1;
}

player_is_in_laststand()
{
	if ( !is_true( self.no_revive_trigger ) && isDefined( self.revivetrigger ) )
	{
		return 1;
	}
	if ( is_true( self.laststand ) )
	{
		return 1;
	}
	return 0;
}

LOCATION_INDICATOR_UPDATE( location_elem )
{
	location_elem.alpha = 1;
	location_elem.color = level.location_pings_player_colors[ self getEntityNumber() ];
	for ( i = level.location_pings_duration; i > 0; i-- )
	{
		wait 1;
	}
	location_elem OBJ_REMOVE_PLAYER();
	self.has_ping_location = false;
}

watch_for_location_ping()
{
	level endon( "end_game" );
	level endon( "game_ended" );
	self endon( "disconnect" );
	self.has_ping_location = false;
	while ( true )
	{
		if ( self.sessionState != "playing" )
		{
			wait 1;
			continue;
		}
		if ( self.has_ping_location )
		{
			wait 1;
			continue;
		}
		if ( self meleeButtonPressed() && self.sessionState == "playing" )
		{
			self thread watch_melee_button();
			self waittill_any_timeout( 3, "melee_button_up" );
			self notify( "watch_melee_button_end" );
			if ( self meleeButtonPressed() && self.sessionState == "playing" )
			{
				hud_ref = self OBJ_ADD_PLAYER( "location_pings", "all", false, 2, true, "white" );
				self.has_ping_location = true;
			}
		}
		wait 0.05;
	}
}

watch_melee_button()
{
	level endon( "end_game" );
	level endon( "game_ended" );
	self endon( "disconnect" );
	self endon( "watch_melee_button_end" );
	while ( true )
	{
		if ( !self meleeButtonPressed() )
		{
			self notify( "melee_button_up" );
			return;
		}
		wait 0.05;
	}
}