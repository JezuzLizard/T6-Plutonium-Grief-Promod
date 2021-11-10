#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;

health_bar_hud()
{
	level endon( "end_game" );
	self endon("disconnect");
	health_bar = self createprimaryprogressbar();
	health_bar setpoint( undefined, "TOP", 0, -27.5 );
	health_bar.hidewheninmenu = 1;
	health_bar.bar.hidewheninmenu = 1;
	health_bar.barframe.hidewheninmenu = 1;
	health_bar_text = self createprimaryprogressbartext();
	health_bar_text setpoint( undefined, "TOP", 0, -15 );
	health_bar_text.hidewheninmenu = 1;
	health_bar thread cleanup_health_bar_on_disconnect( self );
	health_bar thread cleanup_health_bar_on_end_game();
	health_bar fadein_post_pregame();
	while ( true )
	{
		if ( isDefined( self.e_afterlife_corpse ) || !is_player_valid( self ) || !is_true( self.health_bar_visible ) )
		{
			if (health_bar.alpha != 0)
			{
				health_bar.alpha = 0;
				health_bar.bar.alpha = 0;
				health_bar.barframe.alpha = 0;
				health_bar_text.alpha = 0;
			}
			wait 0.05;
			continue;
		}
		if (health_bar.alpha != 1)
		{
			health_bar.alpha = 1;
			health_bar.bar.alpha = 1;
			health_bar.barframe.alpha = 1;
			health_bar_text.alpha = 1;
		}
		health_bar updatebar( self.health / self.maxhealth );
		health_bar_text setvalue( self.health );
		wait 0.05;
	}
}

cleanup_health_bar_on_disconnect( player )
{
	level endon( "end_game" );
	player waittill( "disconnect" );
	self destroyelem();
}

cleanup_health_bar_on_end_game()
{
	level waittill( "end_game" );
	self destroyelem();
}

fadein_post_pregame()
{
	flag_wait( "match_start" );
	self fadeOverTime( 3.0 );
	self.alpha = 0.9;
	wait 3;
}