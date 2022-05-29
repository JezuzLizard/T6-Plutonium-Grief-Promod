#include maps\mp\gametypes_zm\_hud_util;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\_utility;


hud_init()
{
	HUDELEM_SERVER_ADD( "grief_score_A", ::grief_score_axis );
	HUDELEM_SERVER_ADD( "grief_score_B", ::grief_score_allies );
	HUDELEM_SERVER_ADD( "grief_score_A_icon", ::grief_score_axis_icon );
	HUDELEM_SERVER_ADD( "grief_score_B_icon", ::grief_score_allies_icon );
	HUDELEM_SERVER_ADD( "grief_countdown_timer", ::grief_countdown );
	set_server_hud_alpha( getDvarIntDefault( "hud_scoreboard", 1 ) );
	level.axis_revive_waypoint_color_b = round_to_decimal( 205/255, 4 );
}

HUDELEM_SERVER_ADD( name, hudelem_constructor )
{
	if ( !isDefined( level.server_hudelem_funcs ) )
	{
		level.server_hudelem_funcs = [];
	}
	if ( !isDefined( level.server_hudelems ) )
	{
		level.server_hudelems = [];
	}
	level.server_hudelem_funcs[ name ] = hudelem_constructor;
	level.server_hudelems[ name ] = spawnStruct();
	level.server_hudelems[ name ].hudelem = [[ hudelem_constructor ]]();
}

HUDELEM_CLIENT_ADD( name, hudelem_constructor )
{
	if ( !isDefined( self.server_hudelem_funcs ) )
	{
		self.server_hudelem_funcs = [];
	}
	if ( !isDefined( self.server_hudelems ) )
	{
		self.server_hudelems = [];
	}
	self.server_hudelem_funcs[ name ] = hudelem_constructor;
	self.server_hudelems[ name ] = spawnStruct();
	self.server_hudelems[ name ].hudelem = [[ hudelem_constructor ]]();
}

set_server_hud_alpha( alpha )
{
	level.server_hudelems[ "grief_score_A" ].hudelem.alpha = alpha;
	level.server_hudelems[ "grief_score_B" ].hudelem.alpha = alpha;
	level.server_hudelems[ "grief_score_A_icon" ].hudelem.alpha = alpha;
	level.server_hudelems[ "grief_score_B_icon" ].hudelem.alpha = alpha;
}

grief_score_allies()
{
	grief_score_hud = newhudelem();
	grief_score_hud.x += 240;
	grief_score_hud.y += 20;
	grief_score_hud.fontscale = 2.5;
	grief_score_hud.color = ( 0.423, 0.004, 0 );
	grief_score_hud.alpha = 1;
	grief_score_hud.hidewheninmenu = 1;
	grief_score_hud setValue( 0 );
	return grief_score_hud;
}

grief_score_allies_icon()
{
	mapname = getDvar( "mapname" );
	color = undefined;
	if ( mapname == "zm_prison" )
	{
		icon = "faction_guards";
	}
	else if ( mapname == "zm_highrise" )
	{
		icon = "faction_highrise";
		// blue = int( ( 205 / 255 ) * 1000 ) / 1000;
		// color = ( 0, 0, blue );
	}
	else if ( mapname == "zm_tomb" )
	{
		icon = "faction_tomb";
	}
	else 
	{
		icon = "faction_cdc";
	}
	team_shader2 = createservericon( icon, 35, 35 );
	team_shader2.x += -110;
	team_shader2.y += -20;
	team_shader2.hideWhenInMenu = 1;
	team_shader2.alpha = 1;
	if ( isDefined( color ) )
	{
		team_shader2.color = color;
	}
	return team_shader2;
}

grief_score_axis()
{
	grief_score_hud = newhudelem();
	grief_score_hud.x += 440;
	grief_score_hud.y += 20;
	grief_score_hud.fontscale = 2.5;
	grief_score_hud.color = ( 0.423, 0.004, 0 );
	grief_score_hud.alpha = 1;
	grief_score_hud.hidewheninmenu = 1;
	grief_score_hud setValue( 0 );
	return grief_score_hud;
}

grief_score_axis_icon()
{
	mapname = getDvar( "mapname" );
	color = undefined;
	if ( mapname == "zm_prison" )
	{
		icon = "faction_inmates";
	}
	else if ( mapname == "zm_highrise" )
	{
		icon = "faction_highrise";
		// blue = int( ( 205 / 255 ) * 1000 ) / 1000;
		// color = ( 1, 1, 0.9 );
	}
	else if ( mapname == "zm_tomb" )
	{
		icon = "faction_tomb";
	}
	else 
	{
		icon = "faction_cia";
	}
	team_shader1 = createservericon( icon, 35, 35 );
	team_shader1.x += 90;
	team_shader1.y += -20;
	team_shader1.hideWhenInMenu = 1;
	team_shader1.alpha = 1;
	if ( isDefined( color ) )
	{
		team_shader1.color = color;
	}
	return team_shader1;
}

grief_countdown()
{
	level.countdown_hud = createServerFontString( "objective", 2.2 );
	level.countdown_hud setPoint( "CENTER", "CENTER", 0, 0 );
	level.countdown_hud.foreground = 1;
	level.countdown_hud.color = ( 1, 1, 0 );
	level.countdown_hud.hidewheninmenu = true;
	level.countdown_hud.alpha = 0;
	level.countdown_hud maps\mp\gametypes_zm\_hud::fontpulseinit();
	level.countdown_hud thread round_start_countdown_hud_end_game_watcher();
	return level.countdown_hud;
}

round_start_countdown_hud_end_game_watcher()
{
	level waittill( "end_game" );

	self.alpha = 0;
	self destroy();
}

hide_score_hud( state )
{
	level waittill("initial_blackscreen_passed");
	wait 2;
	if( !level.grief_gamerules[ "hide_score" ].current )
	{
		return;
	}
	players = get_players();
	for ( i = 0; i < players.size; i++ )
	{
		players[ i ] setclientminiscoreboardhide( state );
	}
}

hide_ammo_hud( state )
{
	level waittill("initial_blackscreen_passed");
	if( !level.grief_gamerules[ "hide_ammo" ].current )
	{
		return;
	}
	players = get_players();
	for ( i = 0; i < players.size; i++ )
	{
		players[ i ] setclientammocounterhide( state );
	}
}


round_start_countdown_hud(time)
{
	level.server_hudelems[ "grief_countdown_timer" ].hudelem thread round_start_countdown_hud_timer(time);
	level.server_hudelems[ "grief_countdown_timer" ].hudelem.alpha = 1;

	wait time;
}

round_start_countdown_hud_timer(time)
{
	level endon("end_game");

	while(time > 0)
	{
		self setvalue(time);
		self thread maps\mp\gametypes_zm\_hud::fontpulse(level);
		wait 1;
		time--;
	}

	self.alpha = 0;
}


show_grief_hud_msg( msg, msg_parm, offset, delay )
{
	if( !level.grief_gamerules[ "grief_messages" ].current )
		return;

	if(!isDefined(delay))
	{
		self notify( "show_grief_hud_msg" );
	}
	else
	{
		self notify( "show_grief_hud_msg2" );
	}

	self endon( "disconnect" );

	zgrief_hudmsg = newclienthudelem( self );
	zgrief_hudmsg.alignx = "center";
	zgrief_hudmsg.aligny = "middle";
	zgrief_hudmsg.horzalign = "center";
	zgrief_hudmsg.vertalign = "middle";
	zgrief_hudmsg.sort = 1;
	zgrief_hudmsg.y -= 130;

	if ( self issplitscreen() )
	{
		zgrief_hudmsg.y += 70;
	}

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

	zgrief_hudmsg endon( "death" );

	zgrief_hudmsg thread show_grief_hud_msg_cleanup(self, delay);

	while ( isDefined( level.hostmigrationtimer ) )
	{
		wait 0.05;
	}

	if(isDefined(delay))
	{
		wait delay;
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

	if ( isDefined( zgrief_hudmsg ) )
	{
		zgrief_hudmsg destroy();
	}
}

show_grief_hud_msg_cleanup(player, delay)
{
	self endon( "death" );

	self thread show_grief_hud_msg_cleanup_restart_round();
	self thread show_grief_hud_msg_cleanup_end_game();

	if(!isDefined(delay))
	{
		player waittill( "show_grief_hud_msg" );
	}
	else
	{
		player waittill( "show_grief_hud_msg2" );
	}

	if ( isDefined( self ) )
	{
		self destroy();
	}
}

show_grief_hud_msg_cleanup_restart_round()
{
	self endon( "death" );

	level waittill( "restart_round" );

	if ( isDefined( self ) )
	{
		self destroy();
	}
}

show_grief_hud_msg_cleanup_end_game()
{
	self endon( "death" );

	level waittill( "end_game" );

	if ( isDefined( self ) )
	{
		self destroy();
	}
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

watch_for_laststand_axis()
{
	self endon( "disconnect" );
	self notify( "changed_teams" );
	self endon( "changed_teams" );
	level endon( "end_game" );

	mapname = getDvar( "mapname" );
	switch ( mapname )
	{
		case "zm_tomb":
		case "zm_highrise":
		case "zm_nuked":
			break;
		default:
			return;
	} 
	if ( self.team != "axis" )
	{
		return;
	}
	while ( true )
	{
		self waittill( "entering_last_stand" );
		self create_axis_revive_waypoint();
	}
}

create_axis_revive_waypoint()
{
	self.revive_waypoint = newHudElem();
	self.revive_waypoint.elemtype = "icon";
	self.revive_waypoint.x = self.origin[0];
	self.revive_waypoint.y = self.origin[1];
	self.revive_waypoint.z = self.origin[2] + 30;
	self.revive_waypoint.alpha = 1;
	self.revive_waypoint.hidden = 0;
	self.revive_waypoint.color = ( 0, 0, level.axis_revive_waypoint_color_b );
	self.revive_waypoint setWayPoint( false, "waypoint_revive" );
	// self.revive_waypoint setShader( "waypoint_revive", 4, 4 );
	// self.revive_waypoint.target_ent = offset_entity( self, ( 0, 0, 30 ), true );
	// self.revive_waypoint setTargetEnt( self.revive_waypoint.target_ent );
	self thread fade_to_purple( self.revive_waypoint );
	self thread destroy_waypoint_on_disconnect();
	self thread destroy_waypoint_on_revive_or_bled_out();
	self thread destroy_waypoint_on_end_game();
}

round_to_decimal( number, places )
{
	return int( number * places ) / places;
}

offset_entity( ent, offset, link )
{
	if ( !isDefined( offset ) )
	{
		offset = ( 0, 0, 0 );
	}
	elem_ent = spawn( "script_origin", ent.origin + offset );
	if ( is_true( link ) )
	{
		elem_ent linkTo( ent );
	}
	return elem_ent;
}

fade_to_purple( waypoint )
{
	self endon( "disconnect" );
	self endon( "bled_out" );
	self endon( "spawned_player" );
	self endon( "player_revived" );
	level endon( "end_game" );
	color_r = 0;
	while ( self maps\mp\zombies\_zm_laststand::player_is_in_laststand() )
	{
		wait 0.2;
		color_r += 0.9;
		waypoint.color = ( color_r, 0, level.axis_revive_waypoint_color_b );
	}
}

destroy_waypoint_on_disconnect()
{
	self endon( "bled_out" );
	self endon( "spawned_player" );
	self endon( "player_revived" );
	level endon( "end_game" );
	waypoint = self.revive_waypoint;
	link_to_entity = self.revive_waypoint.target_ent;
	self waittill( "disconnect" );
	if ( isDefined( link_to_entity ) )
	{
		link_to_entity delete();
	}
	if ( isDefined( waypoint ) )
	{
		waypoint destroy();
	}
}

destroy_waypoint_on_revive_or_bled_out()
{
	self endon( "disconnect" );
	level endon( "end_game" );
	self waittill_any( "spawned_player", "bled_out", "player_revived" );
	if ( isDefined( self.revive_waypoint.target_ent ) )
	{
		self.revive_waypoint.target_ent delete();
	}
	if ( isDefined( self.revive_waypoint ) )
	{
		self.revive_waypoint destroy();
	}
}

destroy_waypoint_on_end_game()
{
	self endon( "disconnect" );
	self endon( "bled_out" );
	self endon( "spawned_player" );
	self endon( "player_revived" );
	level waittill( "end_game" );
	if ( isDefined( self.revive_waypoint.target_ent ) )
	{
		self.revive_waypoint.target_ent delete();
	}
	if ( isDefined( self.revive_waypoint ) )
	{
		self.revive_waypoint destroy();
	}
}