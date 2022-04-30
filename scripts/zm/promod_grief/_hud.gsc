#include maps/mp/gametypes_zm/_hud_util;
#include common_scripts/utility;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;

hud_init()
{
	HUDELEM_SERVER_ADD( "grief_score_A", ::grief_score_axis );
	HUDELEM_SERVER_ADD( "grief_score_B", ::grief_score_allies );
	HUDELEM_SERVER_ADD( "grief_score_A_icon", ::grief_score_axis_icon );
	HUDELEM_SERVER_ADD( "grief_score_B_icon", ::grief_score_allies_icon );
	set_server_hud_alpha( getDvarIntDefault( "hud_scoreboard", 1 ) );
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