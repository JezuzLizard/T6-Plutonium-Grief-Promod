#include maps/mp/_utility;

onplayerspawned_override()
{
	for ( ;; )
	{
		self waittill( "spawned_player" );
		self scripts/zm/grief/mechanics/loadout/_perks::perk_set_max_health_if_jugg_override( "health_reboot", 1, 0 );
		self notify( "noHealthOverlay" );
		self setplayerhealth();
		self thread playerhealthregen();
	}
}

setplayerhealth()
{
	self.health = getDvarIntDefault( "health_player_maxhealth", 100 );
	self.maxhealth = self.health;
}

playerhealthregen()
{
	self notify( "playerHealthRegen" );
	self endon( "playerHealthRegen" );
	self endon( "death" );
	self endon( "disconnect" );
	if ( !isDefined( self.flag ) )
	{
		self.flag = [];
		self.flags_lock = [];
	}
	if ( !isDefined( self.flag[ "player_has_red_flashing_overlay" ] ) )
	{
		self player_flag_init( "player_has_red_flashing_overlay" );
		self player_flag_init( "player_is_invulnerable" );
	}
	self player_flag_clear( "player_has_red_flashing_overlay" );
	self player_flag_clear( "player_is_invulnerable" );
	self thread maps/mp/zombies/_zm_playerhealth::healthoverlay();
	oldratio = 1;
	veryhurt = 0;
	playerjustgotredflashing = 0;
	invultime = 0;
	hurttime = 0;
	newhealth = 0;
	lastinvulratio = 1;
	healthoverlaycutoff = 0.2;
	self thread maps/mp/zombies/_zm_playerhealth::playerhurtcheck();
	if ( !isDefined( self.veryhurt ) )
	{
		self.veryhurt = 0;
	}
	self.bolthit = 0;
	if ( getDvar( "scr_playerInvulTimeScale" ) == "" )
	{
		setdvar( "scr_playerInvulTimeScale", 1 );
	}
	playerinvultimescale = getDvarFloat( "scr_playerInvulTimeScale" );
	longregendelay = getDvarIntDefault( "health_regen_long_delay", 5000 );
	regularregendelay = getDvarIntDefault( "health_regen_delay", 2400 );
	regenrate_enabled = getDvarIntDefault( "health_regen_rate_enabled", 0 );

	for ( ;; )
	{
		wait 0.05;
		waittillframeend;
		health_ratio = self.health / self.maxhealth;
		if ( regenrate_enabled )
		{
			maxhealthratio = self.maxhealth / 100;
			regenrate = 0.05 / maxhealthratio;
		}
		else
		{
			regenrate = 0.1;
		}
		has_revive = 0;
		if ( self hasPerk("specialty_quickrevive" ) )
		{
			has_revive = 1;
		}
		if ( has_revive )
		{
			regenrate *= 1.25;
			regularregendelay *= 0.75;
			longregendelay *= 0.75;
		}
		if ( health_ratio > healthoverlaycutoff )
		{
			if ( self player_flag( "player_has_red_flashing_overlay" ) )
			{
				player_flag_clear( "player_has_red_flashing_overlay" );
			}
			lastinvulratio = 1;
			playerjustgotredflashing = 0;
			veryhurt = 0;

			if ( self.health == self.maxhealth )
			{
				continue;
			}
		}
		else if ( self.health <= 0 )
		{
			return;
		}
		wasveryhurt = veryhurt;
		if ( health_ratio <= healthoverlaycutoff )
		{
			veryhurt = 1;
			if ( !wasveryhurt )
			{
				hurttime = getTime();
				self player_flag_set( "player_has_red_flashing_overlay" );
				playerjustgotredflashing = 1;
			}
		}
		if ( self.hurtagain )
		{
			hurttime = getTime();
			self.hurtagain = 0;
		}
		if ( health_ratio >= oldratio )
		{
			if ( ( getTime() - hurttime ) < regularregendelay )
			{
				continue;
			}
			else
			{
				self.veryhurt = veryhurt;
				newhealth = health_ratio;
				if ( veryhurt )
				{
					if ( ( getTime() - hurttime ) >= longregendelay )
					{
						newhealth += regenrate;
					}
				}
				else
				{
					if ( regenrate_enabled )
					{
						newhealth += regenrate;
					}
					else
					{
						newhealth = 1;
					}
				}
			}
			if ( newhealth > 1 )
			{
				newhealth = 1;
			}

			if ( newhealth <= 0 )
			{
				return;
			}

			self setnormalhealth( newhealth );
			oldratio = self.health / self.maxhealth;
			continue;
		}
		else
		{
			invulworthyhealthdrop = ( lastinvulratio - health_ratio ) > level.worthydamageratio;
		}
		if ( self.health <= 1 )
		{
			self setnormalhealth( 1 / self.maxhealth );
			invulworthyhealthdrop = 1;
		}
		oldratio = self.health / self.maxhealth;
		self notify( "hit_again" );
		hurttime = getTime();
		if ( !invulworthyhealthdrop || playerinvultimescale <= 0 )
		{
			continue;
		}
		else
		{
			if ( self player_flag( "player_is_invulnerable" ) )
			{
				continue;
			}
			else
			{
				self player_flag_set( "player_is_invulnerable" );
				level notify( "player_becoming_invulnerable" );
				if ( playerjustgotredflashing )
				{
					invultime = level.invultime_onshield;
					playerjustgotredflashing = 0;
				}
				else if ( veryhurt )
				{
					invultime = level.invultime_postshield;
				}
				else
				{
					invultime = level.invultime_preshield;
				}
				invultime *= playerinvultimescale;
				lastinvulratio = self.health / self.maxhealth;
				self thread maps/mp/zombies/_zm_playerhealth::playerinvul( invultime );
			}
		}
	}
}