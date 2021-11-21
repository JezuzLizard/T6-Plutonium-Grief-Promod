#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;

health_bar_hud()
{
	level endon( "end_game" );
	self endon("disconnect");
	// health_bar = self createprimaryprogressbar();
	// health_bar.hidewheninmenu = 1;
	// health_bar.horzalign = "user_left";
	// health_bar.vertalign = "user_bottom";
	// health_bar.x += 65;
	// health_bar.y -= 36;
	// health_bar.bar.hidewheninmenu = 1;
	// health_bar.bar.horzalign = "user_left";
	// health_bar.bar.vertalign = "user_bottom";
	// health_bar.bar.x += 65;
	// health_bar.bar.y -= 35;
	// health_bar.barframe.hidewheninmenu = 1;
	// health_bar.barframe.horzalign = "user_left";
	// health_bar.barframe.vertalign = "user_bottom";
	// health_bar.barframe.x += 65;
	// health_bar.barframe.y -= 36;
	// health_bar_text = self createprimaryprogressbartext();
	// health_bar_text.horzalign = "user_left";
	// health_bar_text.vertalign = "user_bottom";
	// health_bar_text.hidewheninmenu = 1;
	// health_bar_text.x += 65;
	// health_bar_text.y -= 24;
	// health_bar_r = ceil( ( 255/360 ) * 100 ) / 100;
	// health_bar_text.color = ( health_bar_r, 0, 0 );
	health_bar = self createprimaryprogressbar();
	if (level.script == "zm_buried")
	{
		health_bar setpoint(undefined, "BOTTOM", -335, -95);
	}
	else if (level.script == "zm_tomb")
	{
		health_bar setpoint(undefined, "BOTTOM", -335, -100);
	}
	else
	{
		health_bar setpoint(undefined, "BOTTOM", -335, -70);
	}
	health_bar.hidewheninmenu = 1;
	health_bar.bar.hidewheninmenu = 1;
	health_bar.barframe.hidewheninmenu = 1;

	health_bar_text = self createprimaryprogressbartext();
	if (level.script == "zm_buried")
	{
		health_bar_text setpoint(undefined, "BOTTOM", -410, -95);
	}
	else if (level.script == "zm_tomb")
	{
		health_bar_text setpoint(undefined, "BOTTOM", -410, -100);
	}
	else
	{
		health_bar_text setpoint(undefined, "BOTTOM", -410, -70);
	}
	health_bar_text.hidewheninmenu = 1;
	health_bar thread cleanup_health_bar_on_disconnect( self );
	health_bar thread cleanup_health_bar_on_end_game();
	health_bar_text thread cleanup_health_bar_on_disconnect( self );
	health_bar_text thread cleanup_health_bar_on_end_game();

	while ( true )
	{
		if( !level.grief_gamerules[ "health_bar" ] )
		{
			if (health_bar.alpha != 0)
			{
				health_bar.alpha = 0;
				health_bar.bar.alpha = 0;
				health_bar.barframe.alpha = 0;
				health_bar_text.alpha = 0;
			}
		}
		else
		{
			if ( isDefined( self.e_afterlife_corpse ) || !is_player_valid( self )  && isDefined( self.waiting_to_revive ) &&  self.waiting_to_revive || self maps/mp/zombies/_zm_laststand::player_is_in_laststand()  )
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
			if ( health_bar.alpha != 0.8 )
			{
				health_bar fadeOverTime( 0.25 );
				health_bar.alpha = 0.8;
				health_bar.bar fadeOverTime( 0.25 );
				health_bar.bar.alpha = 0.8;
				health_bar.barframe fadeOverTime( 0.25 );
				health_bar.barframe.alpha = 0.8;
				health_bar_text fadeOverTime( 0.25 );
				health_bar_text.alpha = 0.8;
				wait 0.25;
			}
			health_bar updatebar( self.health / self.maxhealth );
			health_bar_text setvalue( self.health );
		}
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