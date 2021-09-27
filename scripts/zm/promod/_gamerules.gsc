
//doesn't work yet
grief_restrict_wallbuy( weapon )
{
	if ( level.grief_gamerules[ "wall_weapon_restrictions" ] == "" )
	{
		return false;
	}
	weapon_keys = strTok( level.grief_gamerules[ "wall_weapon_restrictions" ], " " );
	foreach ( key in weapon_keys )
	{
		if ( key == weapon )
		{
			return true;
		}
	}
	return false;
}

grief_parse_perk_restrictions()
{
	if ( level.grief_gamerules[ "perk_restrictions" ] == "" )
	{
		return;
	}
	perk_keys = strTok( level.grief_gamerules[ "perk_restrictions" ], " " );
	foreach ( key in perk_keys )
	{
		if ( key == "specialty_weapupgrade" )
		{
			trig = getent( key, "script_noteworthy" );
			if ( isdefined( trig.target ) )
			{
				machine = getent( trig.target, "targetname" );
				machine.wait_flag delete();
			}
		}
		level thread perk_machine_removal( key );
	}
}

grief_parse_powerup_restrictions()
{	
	if ( level.grief_gamerules[ "powerup_restrictions" ] == "all" )
	{
		no_drops();
		return;
	}
	powerups = strTok( level.grief_gamerules[ "powerup_restrictions" ], " " );
	for ( i = 0; i < powerups.size; i++ )
	{
		remove_powerup( powerups[ i ] );
	}
}

grief_parse_magic_restrictions()
{	
	if ( level.grief_gamerules[ "magic" ] == 0 )
	{
		no_magic();
	}
}

remove_powerup( powerup )
{	
	arrayremoveindex(level.zombie_include_powerups, powerup);
	arrayremoveindex(level.zombie_powerups, powerup);
	arrayremovevalue(level.zombie_powerup_array, powerup);
}

init_gamerules()
{
	level.default_solo_laststandpistol = "m1911_zm";
	level.is_forever_solo_game = undefined;
	level.speed_change_round = undefined;
	level.grief_gamerules = [];
	level.grief_gamerules[ "scorelimit" ] = getDvarIntDefault( "grief_gamerule_scorelimit", 3 );
	level.grief_gamerules[ "zombies_per_round" ] = getDvarIntDefault( "grief_gamerule_zombies_per_round", 3 );
	level.grief_gamerules[ "perk_restrictions" ] = getDvar( "grief_gamerule_perk_restrictions" );
	level.grief_gamerules[ "mystery_box_enabled" ] = getDvarIntDefault( "grief_gamerule_mystery_box_enabled", 0 );
	level.grief_gamerules[ "wall_weapon_restrictions" ] = getDvar( "grief_gamerule_wall_weapon_restrictions" );
	level.grief_gamerules[ "next_round_time" ] = getDvarIntDefault( "grief_gamerule_next_round_timer", 5 );
	level.grief_gamerules[ "intermission_time" ] = getDvarIntDefault( "grief_gamerule_intermission_time", 0 );
	level.grief_gamerules[ "door_restrictions" ] = getDvar( "grief_gamerule_door_restrictions" );
	level.grief_gamerules[ "round_restart_points" ] = getDvarIntDefault( "grief_gamerule_round_restart_points", 8000 );
	level.grief_gamerules[ "use_preset_teams" ] = getDvarIntDefault( "grief_gamerule_use_preset_teams", 0 );
	level.grief_gamerules[ "disable_zombie_special_runspeeds" ] = getDvarIntDefault( "grief_gamerules_disable_zombie_special_runspeeds", 1 );
	level.grief_gamerules[ "suicide_check" ] = getDvarFloatDefault( "grief_gamerule_suicide_check_wait", 5 );
	level.grief_gamerules[ "player_health" ] = getDvarIntDefault( "grief_gamerule_player_health", 100 );
	level.grief_gamerules[ "perk_limit" ] = getDvarIntDefault( "grief_gamerule_perk_limit", 4 );
	level.grief_gamerules[ "powerup_restrictions" ] = getDvar( "grief_gamerule_powerup_restrictions" );
	level.grief_gamerules[ "knife_lunge" ] = getDvarIntDefault( "grief_gamerule_knife_lunge", 1 );
	level.grief_gamerules[ "magic" ] = getDvarIntDefault( "grief_gamerule_magic", 1 );
	level.grief_gamerules[ "reduced_pistol_ammo" ] = getDvarIntDefault( "grief_gamerule_reduced_pistol_ammo", 1 );
	level.grief_gamerules[ "buildables" ] = getDvarIntDefault( "grief_gamerule_buildables", 1 );
	level.grief_gamerules[ "disable_doors" ] = getDvarIntDefault( "grief_gamerule_disable_doors", 1 );
}