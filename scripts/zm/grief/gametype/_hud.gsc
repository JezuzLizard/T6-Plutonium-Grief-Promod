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
	if ( isDefined( level.grief_score_hud[ "axis" ] ) )
	{
		level.grief_score_hud[ "A" ] destroy();
	}
	if ( isDefined( level.grief_score_hud[ "allies" ] ) )
	{
		level.grief_score_hud[ "B" ] destroy();
	}
	if ( isDefined( level.team_shader1 ) ) 
	{
		level.team_shader1 destroy();
	}
	if ( isDefined( level.team_shader2 ) ) 
	{
		level.team_shader2 destroy();
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