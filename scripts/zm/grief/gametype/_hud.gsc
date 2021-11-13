#include maps/mp/gametypes_zm/_hud_util;
#include common_scripts/utility;
#include maps/mp/zombies/_zm_utility;

hud_init()
{
	HUDELEM_SERVER_ADD( "timer", "text", ::create_round_timer );
	HUDELEM_SERVER_ADD( "grief_score_axis", "value", ::grief_score_axis );
	HUDELEM_SERVER_ADD( "grief_score_allies", "value", ::grief_score_allies );
	if ( level.script == "zm_prison" )
	{
		HUDELEM_SERVER_ADD( "grief_score_axis_icon_prison", "text", ::grief_score_axis_icon_prison );
		HUDELEM_STORE_TEXT( "grief_score_axis_icon_prison", "Inmates " );
		HUDELEM_SERVER_ADD( "grief_score_allies_icon_prison", "text", ::grief_score_allies_icon_prison );
		HUDELEM_STORE_TEXT( "grief_score_axis_icon_prison", "Guards " );
	}
	else 
	{
		HUDELEM_SERVER_ADD( "grief_score_axis_icon_normal", "shader", ::grief_score_axis_icon_normal );
		// //HUDELEM_STORE_SHADER( "grief_score_axis_icon_normal", game[ "icons" ][ "axis" ], 35, 35 );
		HUDELEM_SERVER_ADD( "grief_score_allies_icon_normal", "shader", ::grief_score_allies_icon_normal );
		// //HUDELEM_STORE_SHADER( "grief_score_allies_icon_normal", game[ "icons" ][ "allies" ], 35, 35 );
	}
	// level thread HUDELEM_OVERFLOW_FIX();
	level thread destroy_all_on_end_game();
}

HUDELEM_SERVER_ADD( name, type, hudelem_constructor )
{
	if ( !isDefined( level.server_hudelems ) )
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
	level.server_hudelems[ name ].type = type;
	switch ( type )
	{
		case "value":
			level.server_hudelems[ name ].cur_value = 0;
			break;
		case "shader":
			level.server_hudelems[ name ].cur_shader = [];
			level.server_hudelems[ name ].cur_shader[ "name" ] = "";
			level.server_hudelems[ name ].cur_shader[ "height" ] = 0;
			level.server_hudelems[ name ].cur_shader[ "width" ] = 0;
			break;
		case "text":
			level.server_hudelems[ name ].cur_text = "";
			break;
	}
}

// HUDELEM_OVERFLOW_FIX()
// {
// 	level endon( "end_game" );
// 	while ( true )
// 	{
// 		level waittill( "hudelem_text" );
// 		if ( level.hudelem_text_set >= 40 )
// 		{
// 			level.overflow_elem ClearAllTextAfterHudElem();
// 			keys = getArrayKeys( level.server_hudelems );
// 			for ( i = 0; i < keys.size; i++ )
// 			{
// 				switch ( level.server_hudelems[ keys[ i ] ].type )
// 				{
// 					// case "value":
// 					// 	break;
// 					// case "shader":
// 					// 	break;
// 					case "text":
// 						level.server_hudelems[ keys[ i ] ].hudelem destroy();
// 						level.server_hudelems[ keys[ i ] ].hudelem = [[ level.server_hudelem_funcs[ keys[ i ] ] ]]();
// 						level.server_hudelems[ keys[ i ] ].hudelem setText( level.server_hudelems[ keys[ i ] ].cur_text );
// 						break;
// 					default:
// 						break;
// 				}
// 			}
// 			level.hudelem_text_set = 0;
// 		}
// 	}
// }

HUDELEM_STORE_SHADER( name, shader, height, width )
{
	if ( !isDefined( level.server_hudelems[ name ] ) )
	{
		return;
	}
	level.server_hudelems[ name ].cur_shader[ "name" ] = shader;
	level.server_hudelems[ name ].cur_shader[ "height" ] = height;
	level.server_hudelems[ name ].cur_shader[ "width" ] = width;
}

HUDELEM_STORE_TEXT( name, text )
{
	level.server_hudelems[ name ].cur_text = text;
}

HUDELEM_STORE_VALUE( name, value )
{
	level.server_hudelems[ name ].cur_value = value;
}

HUDELEM_SET_TEXT( text )
{
	if ( !isDefined( level.hudelem_text_set ) )
	{
		level.hudelem_text_set = 0;
	}
	level.hudelem_text_set++;
	self setText( text );
	level notify( "hudelem_text" );
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

grief_score_allies()
{
	grief_score_hud = create_simple_hud();
	grief_score_hud.x += 240;
	grief_score_hud.y += 20;
	grief_score_hud.fontscale = 2.5;
	grief_score_hud.color = ( 0.423, 0.004, 0 );
	grief_score_hud.alpha = 1;
	grief_score_hud.hidewheninmenu = 1;
	grief_score_hud setValue( 0 );
	return grief_score_hud;
}

grief_score_allies_icon_normal()
{
	team_shader2 = createservericon( game[ "icons" ][ "allies" ], 35, 35 );
	team_shader2.x += -110;
	team_shader2.y += -20;
	team_shader2.hideWhenInMenu = 1;
	team_shader2.alpha = 1;
	return team_shader2;
}

grief_score_allies_icon_prison()
{
	team_shader2 = create_simple_hud();
	team_shader2.x += 170;
	team_shader2.y += 20;
	team_shader2.fontscale = 2.5;
	team_shader2.color = ( 0, 0.004, 0.423 );
	team_shader2.alpha = 1;
	team_shader2.hidewheninmenu = 1;
	//HUDELEM_STORE_TEXT( "grief_score_allies_icon_prison" , "Guards " );
	team_shader2.label HUDELEM_SET_TEXT( "Guards " ); 
	return team_shader2;
}

grief_score_axis()
{
	grief_score_hud = create_simple_hud();
	grief_score_hud.x += 440;
	grief_score_hud.y += 20;
	grief_score_hud.fontscale = 2.5;
	grief_score_hud.color = ( 0.423, 0.004, 0 );
	grief_score_hud.alpha = 1;
	grief_score_hud.hidewheninmenu = 1;
	grief_score_hud setValue( 0 );
	return grief_score_hud;
}

grief_score_axis_icon_normal()
{
	team_shader1 = createservericon( game[ "icons" ][ "axis" ], 35, 35 );
	team_shader1.x += 90;
	team_shader1.y += -20;
	team_shader1.hideWhenInMenu = 1;
	team_shader1.alpha = 1;
	return team_shader1;
}

grief_score_axis_icon_prison()
{
	team_shader1 = create_simple_hud();
	team_shader1.x += 360;
	team_shader1.y += 20;
	team_shader1.fontscale = 2.5;
	team_shader1.color = ( 1, 0.333, 0.333 );
	team_shader1.alpha = 1;
	team_shader1.hidewheninmenu = 1;
	//HUDELEM_STORE_TEXT( "grief_score_axis_icon_normal", "Inmates " );
	team_shader1.label HUDELEM_SET_TEXT( "Inmates " );
	return team_shader1;
}

destroy_all_on_end_game()
{
	level waittill( "end_game" );
	keys = getArrayKeys( level.server_hudelems );
	for ( i = 0; i < keys.size; i++ )
	{
		foreach ( elem in level.server_hudelems[ keys[ i ] ] )
		{
			elem.hudelem destroy();
		}
	}
}

create_round_timer()
{
	seconds_display = newhudelem();
	seconds_display.hidewheninmenu = 1;
	seconds_display.horzalign = "user_left";
	seconds_display.vertalign = "user_bottom";
	seconds_display.foreground = 1;
	seconds_display.font = "objective";
	seconds_display.fontscale = 3;
	seconds_display.color = ( 1, 1, 1 );
	seconds_display.alpha = 1;
	seconds_display.x += 120;
	seconds_display.y -= 40;
	return seconds_display;
}

round_change_hud_timer_elem()
{
	remaining = createServerFontString( "objective", 2.2 );
	remaining setPoint( "CENTER", "CENTER", 0, 0 );
	remaining.foreground = false;
	remaining.alpha = 1;
	remaining.color = ( 1, 1, 0 );
	remaining.hidewheninmenu = 1;
	remaining maps/mp/gametypes_zm/_hud::fontpulseinit();
	remaining thread round_change_hud_timer();
	return remaining;
}

round_change_hud_timer()
{
	timer = level.grief_gamerules[ "next_round_time" ];
	while ( true )
	{
		self setValue( timer ); 
		wait 1;
		timer--;
		if ( timer <= 5 )
		{
			self thread countdown_pulse( self, timer );
			break;
		}
	}
	level.server_hudelems[ "round_change_hud_timer_elem" ].hudelem destroy();
	level.server_hudelems[ "round_change_hud_text" ].hudelem destroy();
}

round_change_hud_text()
{
	countdown = createServerFontString( "objective", 1.5 );
	countdown setPoint( "CENTER", "CENTER", 0, -40 );
	countdown.foreground = false;
	countdown.alpha = 1;
	countdown.color = ( 1.000, 1.000, 1.000 );
	countdown.hidewheninmenu = true;
	//HUDELEM_STORE_TEXT( "round_change_hud_text", "Next Round In" );
	countdown HUDELEM_SET_TEXT("Next Round In");
	return countdown;
}