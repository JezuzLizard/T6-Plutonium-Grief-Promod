#include maps/mp/gametypes_zm/_hud_util;
#include common_scripts/utility;
#include maps/mp/zombies/_zm_utility;

hud_init()
{
	level.grief_server_hud_elems = [];
	grief_score();
	level thread destroy_all_on_end_game();
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

fadein_grief_hud()
{
	foreach ( elem in level.grief_server_hud_elems )
	{
		elem fadeOverTime( 3.0 );
		elem.alpha = 0.9;
	}
}

grief_score()
{   
	if ( level.script == "zm_prison" )
	{
		team_shader1 = create_simple_hud();
		team_shader2 = create_simple_hud();
		text = true;
	}
	else
	{
		team_shader1 = createservericon( game[ "icons" ][ "axis" ], 35, 35 );
		team_shader2 = createservericon( game[ "icons" ][ "allies" ], 35, 35 );
	}
	if ( is_true( text ) )
	{
		team_shader1.x += 360;
		team_shader1.y += 20;
		team_shader1.fontscale = 2.5;
		team_shader1.color = ( 1, 0.333, 0.333 );
		team_shader1.alpha = 0;
		team_shader1.hidewheninmenu = 1;
		team_shader1.label = &"Inmates "; 
		team_shader2.x += 170;
		team_shader2.y += 20;
		team_shader2.fontscale = 2.5;
		team_shader2.color = ( 0, 0.004, 0.423 );
		team_shader2.alpha = 0;
		team_shader2.hidewheninmenu = 1;
		team_shader2.label = &"Guards "; 
	}
	else 
	{
		team_shader1.x += 90;
		team_shader1.y += -20;
		team_shader1.hideWhenInMenu = 1;
		team_shader2.alpha = 0;
		team_shader2.x += -110;
		team_shader2.y += -20;
		team_shader2.hideWhenInMenu = 1;
		team_shader2.alpha = 0;
	}
	level.grief_score_hud = [];
	level.grief_score_hud[ "axis" ] = create_simple_hud();
	level.grief_score_hud[ "axis" ].x += 440;
	level.grief_score_hud[ "axis" ].y += 20;
	level.grief_score_hud[ "axis" ].fontscale = 2.5;
	level.grief_score_hud[ "axis" ].color = ( 0.423, 0.004, 0 );
	level.grief_score_hud[ "axis" ].alpha = 0;
	level.grief_score_hud[ "axis" ].hidewheninmenu = 1;
	level.grief_score_hud[ "axis" ] setValue( 0 );
	level.grief_score_hud[ "allies" ] = create_simple_hud();
	level.grief_score_hud[ "allies" ].x += 240;
	level.grief_score_hud[ "allies" ].y += 20;
	level.grief_score_hud[ "allies" ].fontscale = 2.5;
	level.grief_score_hud[ "allies" ].color = ( 0.423, 0.004, 0 );
	level.grief_score_hud[ "allies" ].alpha = 0;
	level.grief_score_hud[ "allies" ].hidewheninmenu = 1;
	level.grief_score_hud[ "allies" ] setValue( 0 );
	level.grief_server_hud_elems[ level.grief_server_hud_elems.size ] = level.grief_score_hud[ "axis" ];
	level.grief_server_hud_elems[ level.grief_server_hud_elems.size ] = level.grief_score_hud[ "allies" ];
	level.grief_server_hud_elems[ level.grief_server_hud_elems.size ] = team_shader1;
	level.grief_server_hud_elems[ level.grief_server_hud_elems.size ] = team_shader2;
}

destroy_on_end_game()
{
	self notify( "waiting" );
	self endon( "waiting" );
	level waittill( "end_game" );
	self destroyelem();
}

destroy_all_on_end_game()
{
	level waittill( "end_game" );
	foreach ( elem in level.grief_server_hud_elems )
	{
		elem destroyelem();
	}
}