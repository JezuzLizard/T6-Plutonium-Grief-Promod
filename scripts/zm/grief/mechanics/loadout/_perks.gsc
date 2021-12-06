
perk_set_max_health_if_jugg_override( perk, set_premaxhealth, clamp_health_to_max_health ) //checked matches cerberus output
{
	max_total_health = undefined;
	if ( perk == "specialty_armorvest" )
	{
		if ( set_premaxhealth )
		{
			self.premaxhealth = self.maxhealth;
		}
		max_total_health = level.zombie_vars[ "zombie_perk_juggernaut_health" ];
	}
	else if ( perk == "specialty_armorvest_upgrade" )
	{
		if ( set_premaxhealth )
		{
			self.premaxhealth = self.maxhealth;
		}
		max_total_health = level.zombie_vars[ "zombie_perk_juggernaut_health_upgrade" ];
	}
	else if ( perk == "jugg_upgrade" )
	{
		if ( set_premaxhealth )
		{
			self.premaxhealth = self.maxhealth;
		}
		if ( self hasperk( "specialty_armorvest" ) )
		{
			max_total_health = level.zombie_vars[ "zombie_perk_juggernaut_health" ];
		}
		else
		{
			max_total_health = 100;
		}
	}
	else
	{
		if ( perk == "health_reboot" )
		{
			max_total_health = getDvarIntDefault( "health_player_maxhealth", 100 );
		}
	}
	if ( isDefined( max_total_health ) )
	{
		if ( self maps/mp/zombies/_zm_pers_upgrades_functions::pers_jugg_active() )
		{
			max_total_health += level.pers_jugg_upgrade_health_bonus;
		}
		self setmaxhealth( max_total_health );
		if ( isDefined( clamp_health_to_max_health ) && clamp_health_to_max_health == 1 )
		{
			if ( self.health > self.maxhealth )
			{
				self.health = self.maxhealth;
			}
		}
	}
}
