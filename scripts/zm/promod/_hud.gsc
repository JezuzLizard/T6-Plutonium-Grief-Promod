#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/gametypes_zm/_hud;
#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/gametypes_zm/_hud_message;

draw_hud()
{
	level thread grief_score();
	level thread grief_score_shaders();
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
	countdown setText( "Next Round Starts In" );
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
}

grief_score()
{   
	flag_wait( "initial_blackscreen_passed" );
	level.grief_score_hud = [];
	level.grief_score_hud[ "A" ] = create_simple_hud();
	level.grief_score_hud[ "A" ].x += 440;
	level.grief_score_hud[ "A" ].y += 20;
	level.grief_score_hud[ "A" ].fontscale = 2.5;
	level.grief_score_hud[ "A" ].color = ( 0.423, 0.004, 0 );
	level.grief_score_hud[ "A" ].alpha = 1;
	level.grief_score_hud[ "A" ].hidewheninmenu = 1;
	level.grief_score_hud[ "A" ] setValue( 0 );
	level.grief_score_hud[ "B" ] = create_simple_hud();
	level.grief_score_hud[ "B" ].x += 240;
	level.grief_score_hud[ "B" ].y += 20;
	level.grief_score_hud[ "B" ].fontscale = 2.5;
	level.grief_score_hud[ "B" ].color = ( 0.423, 0.004, 0 );
	level.grief_score_hud[ "B" ].alpha = 1;
	level.grief_score_hud[ "B" ].hidewheninmenu = 1;
	level.grief_score_hud[ "B" ] setValue( 0 );

	while ( 1 )
	{
		level waittill( "grief_point", team );
		level.grief_score_hud[ team ] SetValue( level.grief_teams[ team ].score );
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

instructions_on_all_players()
{
	level endon( "end_game" );
	flag_wait( "initial_blackscreen_passed" );
	players = getPlayers();
	if ( isDefined( players ) && ( players.size > 0 ) )
	{
		foreach ( player in players )
		{
			player thread instructions();
		}
	}
}

instructions()
{
	level endon( "end_game" );
	self endon( "disconnect" );
	level waittill( "grief_begin" );
	rounds = level.grief_gamerules[ "scorelimit" ];
	self iPrintLn( "Welcome to Grief!" );
	wait 3;
	self iPrintLn( "Your goal is to win " + rounds + " rounds" );
	wait 3;
	self iPrintLn( "Win a round by downing the entire other team" );
	wait 3;
	self iPrintLn( "Good luck!" );
	wait 3;
}