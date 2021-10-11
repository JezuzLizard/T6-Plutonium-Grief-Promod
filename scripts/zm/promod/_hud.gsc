#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/gametypes_zm/_hud;
#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/gametypes_zm/_hud_message;
#include maps/mp/zombies/_zm;

draw_hud()
{
	level thread grief_score();
	level thread grief_score_shaders();
	level thread round_time_hud();
	level thread destroy_hud_on_game_end();
}

round_change_hud()
{   
	level endon( "end_game" );
	if ( isDefined( level.round_countdown_text ) )
	{
		level.round_countdown_text destroy();
	}
	if ( isDefined( level.round_countdown_timer ) )
	{
		level.round_countdown_timer destroy();
	}
	remaining = create_simple_hud();
	remaining.horzAlign = "center";
	remaining.vertAlign = "middle";
	remaining.alignX = "center";
	remaining.alignY = "middle";
	remaining.y = 20;
	remaining.x = 0;
	remaining.foreground = 1;
	remaining.fontscale = 2.0;
	remaining.alpha = 1;
	remaining.color = ( 0.98, 0.549, 0 );
	remaining.hidewheninmenu = 1;
	remaining maps/mp/gametypes_zm/_hud::fontpulseinit();

	countdown = create_simple_hud();
	countdown.horzAlign = "center"; 
	countdown.vertAlign = "middle";
	countdown.alignX = "center";
	countdown.alignY = "middle";
	countdown.y = -20;
	countdown.x = 0;
	countdown.foreground = 1;
	countdown.fontscale = 2.0;
	countdown.alpha = 1;
	countdown.color = ( 1.000, 1.000, 1.000 );
	countdown.hidewheninmenu = 1;
	countdown setText( "Next Round In" );
	level.round_countdown_timer = remaining;
	level.round_countdown_text = countdown;
	timer = level.grief_gamerules[ "next_round_time" ];
	while ( 1 )
	{
		level.round_countdown_timer setValue( timer ); 
		wait 1;
		timer--;
		if ( timer <= 5 )
		{
			countdown_pulse( level.round_countdown_timer, timer );
			break;
		}
	}
	if ( isDefined( level.round_countdown_text ) )
	{
		level.round_countdown_text destroy();
	}
	if ( isDefined( level.round_countdown_timer ) )
	{
		level.round_countdown_timer destroy();
	}
}

countdown_pulse( hud_elem, duration )
{
	level endon( "end_game" );
	waittillframeend;
	while ( duration > 0 && !level.gameended )
	{
		hud_elem thread maps/mp/gametypes_zm/_hud::fontpulse( level );
		wait ( hud_elem.inframes * 0.05 );
		hud_elem setvalue( duration );
		duration--;
		wait ( 1 - ( hud_elem.inframes * 0.05 ) );
	}
}

intermission_hud()
{   
	level endon( "end_game" );
	remaining = create_simple_hud();
	remaining.horzAlign = "center";
	remaining.vertAlign = "middle";
	remaining.alignX = "center";
	remaining.alignY = "middle";
	remaining.y = 20;
	remaining.x = 0;
	remaining.foreground = 1;
	remaining.fontscale = 2.0;
	remaining.alpha = 1;
	remaining.color = ( 0.98, 0.549, 0 );
	remaining.hidewheninmenu = 1;
	remaining maps/mp/gametypes_zm/_hud::fontpulseinit();

	countdown = create_simple_hud();
	countdown.horzAlign = "center"; 
	countdown.vertAlign = "middle";
	countdown.alignX = "center";
	countdown.alignY = "middle";
	countdown.y = -20;
	countdown.x = 0;
	countdown.foreground = 1;
	countdown.fontscale = 2.0;
	countdown.alpha = 1;
	countdown.color = ( 1.000, 1.000, 1.000 );
	countdown.hidewheninmenu = 1;
	countdown setText( "Intermission" );
	level.intermission_countdown = remaining;
	level.intermission_text = countdown;
	timer = level.grief_gamerules[ "intermission_time" ];
	while ( 1 )
	{
		level.intermission_countdown setValue( timer ); 
		wait 1;
		timer--;
		if ( timer <= 5 )
		{
			countdown_pulse( level.intermission_countdown, timer );
			break;
		}
	}
	if ( isDefined( level.intermission_countdown ) )
	{
		level.intermission_countdown destroy();
	}
	if ( isDefined( level.intermission_text ) )
	{
		level.intermission_text destroy();
	}
}

destroy_hud_on_game_end()
{
	level waittill_either( "end_game", "disable_all_hud" );
	if ( isDefined( level.round_countdown_timer ) )
	{
		level.round_countdown_timer destroy();
	}
	if ( isDefined( level.round_countdown_text ) )
	{
		level.round_countdown_text destroy();
	}
	if ( isDefined( level.grief_score_hud[ "A" ] ) )
	{
		//level.grief_score_hud[ "A" ] destroy();
	}
	if ( isDefined( level.grief_score_hud[ "B" ] ) )
	{
		//level.grief_score_hud[ "B" ] destroy();
	}
	if ( isDefined( level.team_shader1 ) ) 
	{
		//level.team_shader1 destroy();
	}
	if ( isDefined( level.team_shader2 ) ) 
	{
		//level.team_shader2 destroy();
	}
	if ( isDefined( level.remaining_zombies_hud ) )
	{
		level.remaining_zombies_hud destroy();
	}
	if ( isDefined( level.intermission_countdown ) )
	{
		level.intermission_countdown destroy();
	}
	if ( isDefined( level.intermission_text ) )
	{
		level.intermission_text destroy();
	}
	if ( isDefined( level.round_time_elem ) )
	{
		level.round_time_elem destroy();
	}
}

grief_score()
{   
	flag_wait( "initial_blackscreen_passed" );
	level.grief_score_hud = [];
	level.grief_score_hud[ "axis" ] = create_simple_hud();
	level.grief_score_hud[ "axis" ].x += 440;
	level.grief_score_hud[ "axis" ].y += 20;
	level.grief_score_hud[ "axis" ].fontscale = 2.5;
	level.grief_score_hud[ "axis" ].color = ( 0.423, 0.004, 0 );
	level.grief_score_hud[ "axis" ].alpha = 1;
	level.grief_score_hud[ "axis" ].hidewheninmenu = 1;
	level.grief_score_hud[ "axis" ] setValue( 0 );
	level.grief_score_hud[ "allies" ] = create_simple_hud();
	level.grief_score_hud[ "allies" ].x += 240;
	level.grief_score_hud[ "allies" ].y += 20;
	level.grief_score_hud[ "allies" ].fontscale = 2.5;
	level.grief_score_hud[ "allies" ].color = ( 0.423, 0.004, 0 );
	level.grief_score_hud[ "allies" ].alpha = 1;
	level.grief_score_hud[ "allies" ].hidewheninmenu = 1;
	level.grief_score_hud[ "allies" ] setValue( 0 );

	while ( 1 )
	{
		level waittill( "grief_point", team );
		level.grief_score_hud[ team ] SetValue( level.data_maps[ "encounters_teams" ][ "score" ][ level.teamIndex[ team ] ] );
	}	
}

grief_score_shaders()
{
	flag_wait( "initial_blackscreen_passed" );
	if ( level.script == "zm_prison" )
	{
		level.team_shader1 = create_simple_hud();
		level.team_shader2 = create_simple_hud();
		text = 1;
	}
	else
	{
		level.team_shader1 = createservericon( game[ "icons" ][ "axis" ], 35, 35 );
		level.team_shader2 = createservericon( game[ "icons" ][ "allies" ], 35, 35 );
	}
	if ( is_true( text ) )
	{
		level.team_shader1.x += 360;
		level.team_shader1.y += 20;
		level.team_shader1.fontscale = 2.5;
		level.team_shader1.color = ( 1, 0.333, 0.333 );
		level.team_shader1.alpha = 1;
		level.team_shader1.hidewheninmenu = 1;
		level.team_shader1.label = &"Inmates "; 
		level.team_shader2.x += 170;
		level.team_shader2.y += 20;
		level.team_shader2.fontscale = 2.5;
		level.team_shader2.color = ( 0, 0.004, 0.423 );
		level.team_shader2.alpha = 1;
		level.team_shader2.hidewheninmenu = 1;
		level.team_shader2.label = &"Guards "; 
	}
	else 
	{
		level.team_shader1.x += 90;
		level.team_shader1.y += -20;
		level.team_shader1.hideWhenInMenu = 1;
		level.team_shader2.x += -110;
		level.team_shader2.y += -20;
		level.team_shader2.hideWhenInMenu = 1;
	}
}

round_time_hud() //checked matches cerberus output
{
	level endon( "end_game" );
	create_round_timer();
	timelimit_in_seconds = level.grief_gamerules[ "timelimit" ] * 60;
	time_left = parse_minutes( to_mins( timelimit_in_seconds ) );
	flag_wait( "spawn_zombies" );
	while ( true )
	{
		if ( is_true( level.pause_timer ) )
		{
			zombie_spawn_delay = level.grief_gamerules[ "round_zombie_spawn_delay" ];
			while ( flag( "timer_pause" ) )
			{
				wait 1;
			}
			while ( zombie_spawn_delay > 0 )
			{
				wait 1;
				zombie_spawn_delay--;
				time_left = parse_minutes( to_mins( zombie_spawn_delay ) );
				level.round_time_elem setText( time_left[ "minutes" ] + ":" + time_left[ "seconds" ] );
			}
			waittillframeend;
			timelimit_in_seconds = level.grief_gamerules[ "timelimit" ] * 60;
			time_left = parse_minutes( to_mins( timelimit_in_seconds ) );
			level.round_time_elem setText( time_left[ "minutes" ] + ":" + time_left[ "seconds" ] );
		}
		wait 1;
		timelimit_in_seconds--;
		if ( timelimit_in_seconds % 20 )
		{
			if ( level.script == "zm_transit" )
			{
				play_sound_2d( "evt_nomans_warning" );
			}
			else 
			{
				level thread maps/mp/zombies/_zm_audio::change_zombie_music( "round_start" );
			}
			level.round_time_elem clearalltextafterhudelem();
			level.round_time_elem settext( "" );
			level.round_time_elem destroy();
			create_round_timer();
			level.round_time_elem.alpha = 1;
		}
		time_left = parse_minutes( to_mins( timelimit_in_seconds ) );
		level.round_time_elem setText( time_left[ "minutes" ] + ":" + time_left[ "seconds" ] );
	}
}

create_round_timer()
{
	seconds_display = newhudelem();
	seconds_display.hidewheninmenu = 1;
	seconds_display.horzalign = "user_left";
	seconds_display.vertalign = "user_bottom";
	seconds_display.alignx = "bottom";
	seconds_display.aligny = "left";
	seconds_display.x = 0;
	seconds_display.y = 0;
	seconds_display.foreground = 1;
	seconds_display.font = "default";
	seconds_display.fontscale = 1.5;
	seconds_display.color = ( 1, 1, 1 );
	seconds_display.alpha = 0;
	level.round_time_elem = seconds_display;
}

parse_minutes( start_time )
{
	time = [];
	keys = strtok( start_time, ":" );
	time[ "hours" ] = keys[ 0 ];
	time[ "minutes" ] = keys[ 1 ];
	time[ "seconds" ] = keys[ 2 ];
	return time;
}

game_start_timer() //checked matches bo3 _globallogic.gsc within reason
{	
	visionSetNaked( "mpIntro", 0 );
	matchStartText = createServerFontString( "objective", 1.5 );
	matchStartText setPoint( "CENTER", "CENTER", 0, -40 );
	matchStartText.sort = 1001;
	matchStartText setText( game["strings"]["waiting_for_teams"] );
	matchStartText.foreground = false;
	matchStartText.hidewheninmenu = true;
	flag_wait( "game_start" );
	matchStartText setText( game["strings"]["match_starting_in"] );
	matchStartTimer = createServerFontString( "objective", 2.2 );
	matchStartTimer setPoint( "CENTER", "CENTER", 0, 0 );
	matchStartTimer.sort = 1001;
	matchStartTimer.color = ( 1, 1, 0 );
	matchStartTimer.foreground = false;
	matchStartTimer.hidewheninmenu = true;
	matchStartTimer maps\mp\gametypes_zm\_hud::fontPulseInit();
	countTime = level.grief_gamerules[ "pregame_time" ];
	if ( countTime >= 2 )
	{
		while ( countTime > 0 )
		{
			matchStartTimer setValue( countTime );
			matchStartTimer thread maps\mp\gametypes_zm\_hud::fontPulse( level );
			if ( countTime == 2 )
			{
				visionSetNaked( GetDvar( "mapname" ), 3.0 );
			}
			countTime--;
			wait 1;
		}
	}
	else
	{
		visionSetNaked( GetDvar( "mapname" ), 1.0 );
	}
	matchStartTimer destroyElem();
	matchStartText destroyElem();
}

show_grief_hud_msg( msg, msg_parm, offset, cleanup_end_game ) //checked matches cerberus output
{
	self endon( "disconnect" );
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
	if ( is_true( cleanup_end_game ) )
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

show_grief_hud_msg_cleanup() //checked matches cerberus output
{
	self endon( "death" );
	level waittill( "end_game" );
	if ( isDefined( self ) )
	{
		self destroy();
	}
}

delay_thread_watch_host_migrate( timer, func, param1, param2, param3, param4, param5, param6 ) //checked matches cerberus output
{
	self thread _delay_thread_watch_host_migrate_proc( func, timer, param1, param2, param3, param4, param5, param6 );
}

_delay_thread_watch_host_migrate_proc( func, timer, param1, param2, param3, param4, param5, param6 ) //checked matches cerberus output
{
	self endon( "death" );
	self endon( "disconnect" );
	wait timer;
	single_thread( self, func, param1, param2, param3, param4, param5, param6 );
}