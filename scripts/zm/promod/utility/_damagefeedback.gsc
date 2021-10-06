
damage_feedback_init() //checked matches cerberus output
{
	precacheshader( "damage_feedback" );
	precacheshader( "damage_feedback_flak" );
	precacheshader( "damage_feedback_tac" );
	level thread onplayerconnect();
}

onplayerconnect() //checked matches cerberus output
{
	for ( ;; )
	{
		level waittill( "connecting", player );
		player.hud_damagefeedback = newdamageindicatorhudelem( player );
		player.hud_damagefeedback.horzalign = "center";
		player.hud_damagefeedback.vertalign = "middle";
		player.hud_damagefeedback.x = -12;
		player.hud_damagefeedback.y = -12;
		player.hud_damagefeedback.alpha = 0;
		player.hud_damagefeedback.archived = 1;
		player.hud_damagefeedback setshader( "damage_feedback", 24, 48 );
		player.hitsoundtracker = 1;
	}
}

updatedamagefeedback( mod ) //checked matches cerberus output
{
	if ( mod == "gun" || mod == "grenade" || mod == "impact" )
	{
		self playlocalsound( "spl_hit_alert" );
		self.hud_damagefeedback setshader( "damage_feedback", 24, 48 );
		self.hud_damagefeedback.alpha = 1;
		self.hud_damagefeedback fadeovertime( 1 );
		self.hud_damagefeedback.alpha = 0;
	}
}