#include maps/mp/gametypes_zm/_hud_util;
#include common_scripts/utility;
#include maps/mp/zombies/_zm_utility;

hud_init()
{
	HUDELEM_SERVER_ADD( "timer", "text", ::create_round_timer );
	HUDELEM_SERVER_ADD( "grief_score_axis", "value", ::grief_score_axis );
	HUDELEM_SERVER_ADD( "grief_score_allies", "value", ::grief_score_allies );
	HUDELEM_SERVER_ADD( "grief_score_axis_icon", "shader", ::grief_score_axis_icon );
	HUDELEM_SERVER_ADD( "grief_score_allies_icon", "shader", ::grief_score_allies_icon );
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
	if ( getDvar( "mapname" ) == "zm_prison" )
	{
		icon = "faction_guards";
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
	if ( getDvar( "mapname" ) == "zm_prison" )
	{
		icon = "faction_inmates";
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
	return team_shader1;
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
	remaining.hidewheninmenu = true;
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
	countdown.label = &"Next Round In";
	return countdown;
}

round_timer_hud_elem()
{
	timerdisplay = createservertimer( "objective", 1.4 );
	timerdisplay setgamemodeinfopoint();
	timerdisplay.font = "small";
	timerdisplay.alpha = 0;
	timerdisplay.archived = false;
	timerdisplay.hidewheninmenu = true;
	timerdisplay.hidewheninkillcam = true;
	timerdisplay.showplayerteamhudelemtospectator = 1;
	timerdisplay thread hidetimerdisplayongameend();
	return timerdisplay;
}

hidetimerdisplayongameend() //checked matches cerberus output
{
	level waittill( "game_ended" );
	self.alpha = 0;
}