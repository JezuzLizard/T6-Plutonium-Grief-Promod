#include common_scripts/utility;
#include maps/mp/zombies/_zm_audio_announcer;
#include maps/mp/_utility;

//Come back to this once grief multi-team is done.

grief_onplayerconnect() //checked matches cerberus output
{
	self thread zgrief_player_bled_out_msg();
	level.grief_team_members[ self.team ]--;
}

grief_onplayerdisconnect( disconnecting_player ) //checked matches cerberus output
{
	if ( flag( "match_start" ) )
	{
		//level thread update_players_on_bleedout_or_disconnect( disconnecting_player );
	}
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
	self thread _delay_thread_watch_host_migrate_proc( timer, func, param1, param2, param3, param4, param5, param6 );
}

_delay_thread_watch_host_migrate_proc( timer, func, param1, param2, param3, param4, param5, param6 ) //checked matches cerberus output
{
	self endon( "death" );
	self endon( "disconnect" );
	wait timer;
	single_thread( self, func, param1, param2, param3, param4, param5, param6 );
}

zgrief_player_bled_out_msg() //checked matches cerberus output
{
	level endon( "end_game" );
	self endon( "disconnect" );
	flag_wait( "match_start" );
	while ( 1 )
	{
		self waittill( "bled_out" );
		//level thread update_players_on_bleedout_or_disconnect( self );
	}
}

update_players_on_bleedout_or_disconnect( excluded_player ) //checked changed to match cerberus output
{
	level endon( "end_game" );
	players = getPlayers();
	if ( isDefined( level.predicted_round_winner ) )
	{
		foreach ( player in level.alive_players[ level.predicted_round_winner ] )
		{
			player thread show_grief_hud_msg( &"ZOMBIE_ZGRIEF_ALL_PLAYERS_DOWN", undefined, undefined, 1 );
			player delay_thread_watch_host_migrate( 2, ::show_grief_hud_msg, &"ZOMBIE_ZGRIEF_SURVIVE", undefined, 30, 1 );
		}
		level thread maps/mp/zombies/_zm_audio_announcer::leaderdialog( "4_player_down", level.predicted_round_winner );
	}
	else 
	{
		players = getPlayers( getotherteam( excluded_player.team ) );
		foreach ( player in players )
		{
			player thread show_grief_hud_msg( &"ZOMBIE_ZGRIEF_PLAYER_BLED_OUT", level.alive_players[ player.team ].size );
		}
		level thread maps/mp/zombies/_zm_audio_announcer::leaderdialog( level.alive_players[ excluded_player.team ].size + "_player_left", getotherteam( excluded_player.team ) );
	}

	if ( level.alive_players[ excluded_player.team ].size == 1 )
	{
		level thread maps/mp/zombies/_zm_audio_announcer::leaderdialog( "last_player", excluded_player.team );
	}
}