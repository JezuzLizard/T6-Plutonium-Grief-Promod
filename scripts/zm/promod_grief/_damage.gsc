#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_score;
#include maps\mp\zombies\_zm;

do_game_mode_shellshock( attacker, meansofdeath, weapon ) //checked matched cerberus output
{
	self endon( "disconnect" );
	self._being_shellshocked = 1;
	if ( meansofdeath == "MOD_MELEE" )
	{
		self shellshock( "grief_stab_zm", 0.75 );
	}
	else 
	{
		self shellshock( "grief_stab_zm", 0.25 );
	}

	wait 0.75;
	self._being_shellshocked = 0;
}

callback_playermelee_override( eattacker, idamage, sweapon, vorigin, vdir, boneindex, shieldhit )
{
    hit = 1;

    if ( !level.grief_ffa && level.teambased && self.team == eattacker.team )
    {
        if ( level.friendlyfire == 0 )
            hit = 0;
    }

    self finishmeleehit( eattacker, sweapon, vorigin, vdir, boneindex, shieldhit, hit );
}

game_module_player_damage_grief_callback( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime )
{
	old_revives = self.revives;
	if ( eattacker != self && eattacker.team != self.team || level.grief_ffa )
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
		self player_steal_points( eattacker, "deny_revive" );
	}
	self.is_reviving_grief = false;
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
			return 1;
		default:
			return 0;
	}
}

player_steal_points( attacker, event )
{
	if ( level.intermission )
	{
		return;
	}
	if ( event == "MOD_MELEE" )
	{
		event = "knife";
	}
	else if ( event == "MOD_PISTOL_BULLET" || event == "MOD_RIFLE_BULLET" ) 
	{
		event = "gun";
	}
	else if ( event == "MOD_GRENADE" || event == "MOD_GRENADE_SPLASH")
	{
		event = "grenade";
	}
	else if ( event == "MOD_IMPACT" || event == "MOD_HIT_BY_OBJECT" )
	{
		event = "impact";
	}
	if ( isDefined( attacker ) && isDefined( self ) && !self maps/mp/zombies/_zm_laststand::player_is_in_laststand() )
	{
		points_to_steal = 0;
		switch( event )
		{
			case "meat":
				points_to_steal = 1000;
				break;
			case "knife":
				points_to_steal = 100;
				break;
			case "gun":
				points_to_steal = 20;
				break;
			case "grenade":
				points_to_steal = 100;
				break;
			case "impact":
				points_to_steal = 50;
				break;
			case "down_player":
				points_to_steal = 200;
				break;
			case "deny_revive":
				points_to_steal = 200;
				break;
			case "deny_box_weapon_pickup":
				points_to_steal = 100;
				break;
			case "emp_pap_with_weapon":
				break;
			case "emp_box_roll":
				break;
			case "emp_player":
				points_to_steal = 100;
				break;
		}
		if ( points_to_steal == 0 )
		{
			return;
		}
		if ( ( self.score - points_to_steal ) < 0 )
		{
			return;
		}
		attacker maps/mp/zombies/_zm_score::add_to_player_score( points_to_steal );
		self minus_to_player_score( points_to_steal, true );
	}
}

callback_playerdamage( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime, boneindex )
{
    if ( isdefined( eattacker ) && isplayer( eattacker ) && eattacker.sessionteam == self.sessionteam && !eattacker hasperk( "specialty_noname" ) && !( isdefined( self.is_zombie ) && self.is_zombie ) && !level.grief_ffa )
    {
        self process_friendly_fire_callbacks( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime, boneindex );

        if ( self != eattacker )
        {
            return;
        }
        else if ( smeansofdeath != "MOD_GRENADE_SPLASH" && smeansofdeath != "MOD_GRENADE" && smeansofdeath != "MOD_EXPLOSIVE" && smeansofdeath != "MOD_PROJECTILE" && smeansofdeath != "MOD_PROJECTILE_SPLASH" && smeansofdeath != "MOD_BURNED" && smeansofdeath != "MOD_SUICIDE" )
        {
            return;
        }
    }

    if ( isdefined( level.pers_upgrade_insta_kill ) && level.pers_upgrade_insta_kill )
        self maps\mp\zombies\_zm_pers_upgrades_functions::pers_insta_kill_melee_swipe( smeansofdeath, eattacker );

    if ( isdefined( self.overrideplayerdamage ) )
        idamage = self [[ self.overrideplayerdamage ]]( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime );
    else if ( isdefined( level.overrideplayerdamage ) )
        idamage = self [[ level.overrideplayerdamage ]]( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime );
    if ( isdefined( self.magic_bullet_shield ) && self.magic_bullet_shield )
    {
        maxhealth = self.maxhealth;
        self.health += idamage;
        self.maxhealth = maxhealth;
    }

    if ( isdefined( self.divetoprone ) && self.divetoprone == 1 )
    {
        if ( smeansofdeath == "MOD_GRENADE_SPLASH" )
        {
            dist = distance2d( vpoint, self.origin );

            if ( dist > 32 )
            {
                dot_product = vectordot( anglestoforward( self.angles ), vdir );

                if ( dot_product > 0 )
                    idamage = int( idamage * 0.5 );
            }
        }
    }
    if ( isdefined( level.prevent_player_damage ) )
    {
        if ( self [[ level.prevent_player_damage ]]( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime ) )
            return;
    }

    idflags |= level.idflags_no_knockback;

    if ( idamage > 0 && shitloc == "riotshield" )
        shitloc = "torso_upper";
    self finishplayerdamagewrapper( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime, boneindex );
}

//Extended Grief Mechanics
game_module_player_damage_callback( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime ) //checked partially changed output to cerberus output
{
	self.last_damage_from_zombie_or_player = 0;
	if ( isDefined( eattacker ) )
	{
		if ( isplayer( eattacker ) && eattacker == self )
		{
			return;
		}
		if ( isDefined( eattacker.is_zombie ) && eattacker.is_zombie && isplayer( eattacker ) )
		{
			self.last_damage_from_zombie_or_player = 1;
		}
	}
	if ( !isDefined( eattacker ) || !isplayer( eattacker ) )
	{
		return;
	}
	if ( smeansofdeath == "MOD_MELEE" )
	{
		eattacker.stabs++;
	}
	if ( level.grief_ffa )
	{
		if ( !self maps/mp/zombies/_zm_laststand::player_is_in_laststand() && !eattacker maps/mp/zombies/_zm_laststand::player_is_in_laststand() )
		{
			self player_steal_points( eattacker, smeansofdeath );
		}
	}
	else if ( isDefined( eattacker._encounters_team ) && eattacker._encounters_team != self._encounters_team )
	{
		if ( !self maps/mp/zombies/_zm_laststand::player_is_in_laststand() && !eattacker maps/mp/zombies/_zm_laststand::player_is_in_laststand() )
		{
			self player_steal_points( eattacker, smeansofdeath );
		}
	}
	if ( is_true( self._being_shellshocked ) || self maps/mp/zombies/_zm_laststand::player_is_in_laststand() )
	{
		return;
	}
	if ( isDefined( eattacker._encounters_team ) && eattacker._encounters_team != self._encounters_team || level.grief_ffa )
	{
		self.last_griefed_by.attacker = eattacker;
		self.last_griefed_by.meansofdeath = smeansofdeath;
		self.last_griefed_by.weapon = sweapon;
		self.last_griefed_by.time = getTime();
		if ( isDefined( level._game_module_player_damage_grief_callback ) )
		{
			self [[ level._game_module_player_damage_grief_callback ]]( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime );
		}
		if ( isDefined( level._effect[ "butterflies" ] ) )
		{
			if ( isDefined( sweapon ) && weapontype( sweapon ) == "grenade" )
			{
				playfx( level._effect[ "butterflies" ], self.origin + vectorScale( ( 1, 1, 1 ), 40 ) );
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


