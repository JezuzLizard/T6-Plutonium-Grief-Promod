#include common_scripts/utility;

//Extended Grief Mechanics
game_module_player_damage_callback( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime )
{
	self.last_damage_from_zombie_or_player = 0;
	if ( isDefined( eattacker ) )
	{
		if ( isplayer( eattacker ) && eattacker == self )
		{
			return;
		}
		if ( isDefined( eattacker.is_zombie ) || eattacker.is_zombie && isplayer( eattacker ) )
		{
			self.last_damage_from_zombie_or_player = 1;
		}
	}
	if ( isDefined( eattacker) && isplayer( eattacker ) )
	{
		if ( smeansofdeath == "MOD_MELEE" )
		{
			eattacker.pers[ "stabs" ]++;
			eattacker.stabs++;
		}
	}
	if ( isplayer( eattacker ) && isDefined( eattacker._encounters_team ) && eattacker._encounters_team != self._encounters_team )
	{
		if ( !self maps/mp/zombies/_zm_laststand::player_is_in_laststand() && !eattacker maps/mp/zombies/_zm_laststand::player_is_in_laststand() )
		{
			self scripts/zm/grief/mechanics/_point_steal::attacker_steal_points( eattacker, smeansofdeath );
		}
	}
	if ( is_true( self._being_shellshocked ) )
	{
		return;
	}
	if ( isplayer( eattacker ) && isDefined( eattacker._encounters_team ) && eattacker._encounters_team != self._encounters_team )
	{
		self.last_griefed_by.attacker = eattacker;
		self.last_griefed_by.meansofdeath = smeansofdeath;
		self.last_griefed_by.weapon = sweapon;
		self.last_griefed_by.time = getTime();
		if ( is_true( self.hasriotshield ) && isDefined( vdir ) )
		{
			if ( is_true( self.hasriotshieldequipped ) )
			{
				if ( self maps/mp/zombies/_zm::player_shield_facing_attacker( vdir, 0.2 ) && isDefined( self.player_shield_apply_damage ) )
				{
					return;
				}
			}
			else if ( !isdefined( self.riotshieldentity ) )
			{
				if ( !self maps/mp/zombies/_zm::player_shield_facing_attacker( vdir, -0.2 ) && isdefined( self.player_shield_apply_damage ) )
				{
					return;
				}
			}
		}
		self do_player_knockback( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime );
		if ( isDefined( level._effect[ "butterflies" ] ) )
		{
			if ( isDefined( sweapon ) && weapontype( sweapon ) == "grenade" )
			{
				playfx( level._effect[ "butterflies" ], self.origin + ( 40, 40, 40 ) );
			}
			else
			{
				playfx( level._effect[ "butterflies" ], vpoint, vdir );
			}
		}
		self thread do_game_mode_shellshock( eattacker, smeansofdeath, sweapon );
		self playsound( "zmb_player_hit_ding" );
	}
}

do_game_mode_shellshock( attacker, meansofdeath, weapon )
{
	self endon( "disconnect" );
	self._being_shellshocked = 1;
	if ( self.score < 0 )
	{
		if ( meansofdeath == "MOD_MELEE" )
		{
			self shellshock( "grief_stab_zm", 1 );
		}
		else 
		{
			self shellshock( "grief_stab_zm", 0.4 );
		}
	}
	else 
	{
		if ( meansofdeath == "MOD_MELEE" )
		{
			self shellshock( "grief_stab_zm", 0.75 );
		}
		else 
		{
			self shellshock( "grief_stab_zm", 0.25 );
		}
	}
	wait 0.75;
	self._being_shellshocked = 0;
}

do_player_knockback( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime )
{
	old_revives = self.revives;
	if ( isDefined( eattacker ) && isplayer( eattacker ) && eattacker != self && eattacker.team != self.team )
	{
		if ( smeansofdeath == "MOD_MELEE" )
		{
			//check if player is reviving before knockback
			if ( self maps/mp/zombies/_zm_laststand::is_reviving_any() )
			{
				self.is_reviving_grief = 1;
			}
			self applyknockback( idamage, vdir );
		}
		else if ( is_weapon_shotgun( sweapon ) )
		{
			if ( self maps/mp/zombies/_zm_laststand::is_reviving_any() )
			{
				self.is_reviving_grief = 1;
			}
			self applyknockback( idamage, vdir );
		}
	}
	if ( is_true( self.is_reviving_grief ) )
	{
		if ( self.revives == old_revives )
		{
			if ( !self maps/mp/zombies/_zm_laststand::is_reviving_any() )
			{
				knocked_off_revive = 1;
			}
		}
	}
	if ( is_true( knocked_off_revive ) )
	{
		self scripts/zm/grief/mechanics/_point_steal::attacker_steal_points( eattacker, "deny_revive" );
	}
	self.is_reviving_grief = false;
}

reset_players_last_griefed_by()
{
	players = getPlayers();
	foreach ( player in players )
	{
		player.last_griefed_by.attacker = undefined;
		player.last_griefed_by.meansofdeath = undefined;
		player.last_griefed_by.weapon = undefined;
		player.last_griefed_by.time = 0;
	}
}

is_weapon_shotgun( sweapon )
{
	switch ( sweapon )
	{
		case "saiga12_zm":
		case "saiga12_upgraded_zm":
		case "srm1216_zm":
		case "srm1216_upgraded_zm":
		case "rottweil72_zm":
		case "rottweil72_upgraded_zm":
		case "ksg_zm":
		case "ksg_upgraded_zm":
		case "870mcs_zm":
		case "870mcs_upgraded_zm":
			return true;
		default:
			return false;
	}
}