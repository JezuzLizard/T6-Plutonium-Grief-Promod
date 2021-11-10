
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

in_grief_intermission()
{
	if ( is_true( level.grief_intermission_done ) || level.grief_gamerules[ "intermission_time" ] < 1 )
	{
		return false;
	}
	team_scores = [];
	team_scores[ "axis" ] = level.grief_teams[ "axis" ].score;
	team_scores[ "allies" ] = level.grief_teams[ "allies" ].score;
	score_limit = level.grief_gamerules[ "scorelimit" ];
	intermission_score = score_limit / 2;
	if ( team_scores[ "axis" ] == int( intermission_score ) || team_scores[ "allies" ] == int( intermission_score ) )
	{
		level.grief_intermission_done = true;
		return true;
	}
	return false;
}