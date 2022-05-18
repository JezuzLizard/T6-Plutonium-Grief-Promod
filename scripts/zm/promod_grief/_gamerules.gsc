#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_magicbox;
#include maps\mp\zombies\_zm_perks;

init_gamerules()
{
	level.grief_gamerule_dvar_name = "grief_gamerule_";
	level.grief_restriction_dvar_name = "grief_restriction_";

	initialize_gamerule( "scorelimit", 3 );
	initialize_gamerule( "next_round_time", 5 );
	initialize_gamerule( "spawn_zombies_wait_time", 5 );
	initialize_gamerule( "suicide_check_time", 5.0 );
	initialize_gamerule( "zombie_round", 20 );
	initialize_gamerule( "round_restart_points", 10000 );
	initialize_gamerule( "magic", 1, ::gamerule_adjust_magic );
	initialize_gamerule( "mystery_box_enabled", 0, ::gamerule_toggle_mysterybox );
	initialize_gamerule( "powerups_disabled", 0, ::gamerule_toggle_powerups );
	initialize_gamerule( "buildables", 0 );
	initialize_gamerule( "disable_doors", 1 );
	initialize_gamerule( "shock_on_pain", 1, ::gamerule_toggle_shock_on_pain );
	initialize_gamerule( "self_bleedout", 1 );
	initialize_gamerule( "player_health", 100, ::gamerule_adjust_player_health );
	initialize_gamerule( "knife_lunge", 0, ::gamerule_adjust_knife_lunge );
	initialize_gamerule( "reduce_mp5_ammo", 1 );
	initialize_gamerule( "reduced_pistol_ammo", 1 );
	initialize_gamerule( "bullet_shellshock_time", 0.25 );
	initialize_gamerule( "melee_shellshock_time", 0.75 );
	initialize_gamerule( "shellshock_cooldown", 0.75 );
	initialize_gamerule( "depot_remove_debris_over_lava", 1 );
	initialize_gamerule( "grief_brutus_enabled", 1, ::gamerule_toggle_grief_brutus_logic );
	initialize_gamerule( "display_instructions", 0 );
	initialize_gamerule( "grief_messages", 0 );
	initialize_gamerule( "fog_disabled", 1, ::gamerule_toggle_fog );
	initialize_gamerule( "visionset_enabled", 1, ::gamerule_toggle_visionset );
	initialize_gamerule( "max_walkers", 0 );
	initialize_gamerule( "max_zombies", 24 );

	// initialize_gamerule( "perks_disabled", 0 );
	// initialize_gamerule( "auto_balance_teams", 0 );

	initialize_restriction( "perks" );
	initialize_restriction( "powerups" );

	set_ffa_vars();
	level.allow_teamchange = getGametypeSetting( "allowInGameTeamChange" );
	if ( level.grief_ffa ) 
	{
		level.allow_teamchange = 0;
	}
}

initialize_gamerule( rulename, rulevalue, callback )
{
	if ( !isDefined( level.grief_gamerules ) )
	{
		level.grief_gamerules = [];
	}
	dvar_string = level.grief_gamerule_dvar_name + rulename;
	original_value_string = dvar_string + "_resetvalue";
	num_matches_string = dvar_string + "_matches_remaining";
	type = typeOf( rulevalue );
	switch ( type )
	{
		case "int":
			level.grief_gamerules[ rulename ] = spawnStruct();
			level.grief_gamerules[ rulename ].current = getDvarIntDefault( dvar_string, rulevalue );
			break;
		case "float":
			level.grief_gamerules[ rulename ] = spawnStruct();
			level.grief_gamerules[ rulename ].current = getDvarFloatDefault( dvar_string, rulevalue );
			break;
		case "string":
			level.grief_gamerules[ rulename ] = spawnStruct();
			level.grief_gamerules[ rulename ].current = getDvarStringDefault( dvar_string, rulevalue );
			break;
	}
	if ( isDefined( level.grief_gamerules[ rulename ] ) )
	{
		level.grief_gamerules[ rulename ].lastvalue_this_match = level.grief_gamerules[ rulename ].current;
		if ( isDefined( callback ) )
		{
			level.grief_gamerules[ rulename ].callback = callback;
		}
		level.grief_gamerules[ rulename ].type = type;
		matches_remaining_value = getDvarInt( num_matches_string ) - 1;
		if ( getDvar( original_value_string ) == "" )
		{
			setDvar( original_value_string, level.grief_gamerules[ rulename ].current );
		}
		if ( getDvar( num_matches_string ) == "" )
		{
			setDvar( num_matches_string, -1 );
		}
		else 
		{
			matches_remaining_value = getDvarInt( num_matches_string );
			if ( matches_remaining_value > -1 )	
			{
				if ( matches_remaining_value > 0 )
				{
					matches_remaining_value = matches_remaining_value - 1;
					setDvar( num_matches_string, matches_remaining_value );
				}
				else 
				{
					reset_gamerule( rulename );
				}
			}
		}
	}
}

set_gamerule_for_match( rulename, rulevalue )
{
	if ( !isDefined( level.grief_gamerules[ rulename ] ) )
	{
		print( "set_gamerule() " + rulename + " is not initialized" );
		return;
	}
	level.grief_gamerules[ rulename ].lastvalue_this_match = level.grief_gamerules[ rulename ].current;
	level.grief_gamerules[ rulename ].current = rulevalue;
	if ( isDefined( level.grief_gamerules[ rulename ].callback ) )
	{
		level [[ level.grief_gamerules[ rulename ].callback ]]();
	}
}

reset_gamerule( rulename )
{
	if ( !isDefined( level.grief_gamerules[ rulename ] ) )
	{
		print( "reset_gamerule() " + rulename + " is not initialized" );
		return;
	}
	dvar_string = level.grief_gamerule_dvar_name + rulename;
	original_value_dvar = dvar_string + "_resetvalue";
	num_matches_string = dvar_string + "_matchesremaining";
	switch ( typeOf( level.grief_gamerules[ rulename ].current ) )
	{
		case "int":
			original_value = getDvarInt( original_value_dvar );
			break;
		case "float":
			original_value = getDvarFloat( original_value_dvar );
			break;
		case "string":
			original_value = getDvar( original_value_dvar );
			break;
	}
	if ( isDefined( original_value ) )
	{
		level.grief_gamerules[ rulename ].lastvalue_this_match = level.grief_gamerules[ rulename ].current;
		level.grief_gamerules[ rulename ].current = original_value;
		setDvar( dvar_string, original_value );
		setDvar( num_matches_string, -1 );
	}
}

set_gamerule_for_next_matches( rulename, rulevalue, number_of_matches )
{
	if ( number_of_matches < -1 )
	{
		number_of_matches = -1;
	}
	dvar_string = level.grief_gamerule_dvar_name + rulename;
	num_matches_string = dvar_string + "_matchesremaining";
	set_gamerule_for_match( rulename, rulevalue );
	setDvar( dvar_string, rulevalue );
	setDvar( num_matches_string, number_of_matches );
}

gamerule_remove_restricted_powerups()
{
	if ( level.grief_restrictions[ "powerups" ].enabled && array_validate( level.grief_restrictions[ "powerups" ].list ) )
	{
		foreach ( powerup in level.grief_restrictions[ "powerups" ].list )
		{
			if ( isInArray( level.zombie_powerup_array, powerup ) )
			{
				remove_powerup( powerup );
			}
		}
	}
}

remove_powerup( powerup )
{
	arrayRemoveKey( level.zombie_include_powerups, powerup );
	arrayRemoveKey( level.zombie_powerups, powerup );
	arrayRemoveValue( level.zombie_powerup_array, powerup);
}

initialize_restriction( restriction_name )
{
	if ( !isDefined( level.grief_restrictions ) )
	{
		level.grief_restrictions = [];
	}
	dvar_string = level.grief_restriction_dvar_name + restriction_name;
	restriction_dvar_value = getDvar( dvar_string );
	level.grief_restrictions[ restriction_name ] = spawnStruct();
	level.grief_restrictions[ restriction_name ].enabled = true;
	level.grief_restrictions[ restriction_name ].list = [];
	if ( restriction_dvar_value != "" )
	{
		level.grief_restrictions[ restriction_name ].list = strTok( restriction_dvar_value, " " );
	}
}

kill_perk_machine_thread( perk )
{
	switch ( perk )
	{
		case "specialty_weapupgrade":
			if ( isdefined( level._custom_turn_packapunch_on ) )
				killThread( level._custom_turn_packapunch_on );
			else
				killThread( ::turn_packapunch_on );
			break;
		case "specialty_armorvest":
			if ( isdefined( level.zombiemode_using_juggernaut_perk ) && level.zombiemode_using_juggernaut_perk )
				killThread( ::turn_jugger_on );
			break;
		case "specialty_quickrevive":
			if ( isdefined( level.zombiemode_using_revive_perk ) && level.zombiemode_using_revive_perk )
				killThread( ::turn_revive_on );
			break;
		case "specialty_fastreload":
			if ( isdefined( level.zombiemode_using_sleightofhand_perk ) && level.zombiemode_using_sleightofhand_perk )
				killThread( ::turn_sleight_on );
			break;
		case "specialty_rof":
			if ( isdefined( level.zombiemode_using_doubletap_perk ) && level.zombiemode_using_doubletap_perk )
				killThread( ::turn_doubletap_on );
			break;
		case "specialty_longersprint":
			if ( isdefined( level.zombiemode_using_marathon_perk ) && level.zombiemode_using_marathon_perk )
				killThread( ::turn_marathon_on );
			break;
		case "specialty_deadshot":
			if ( isdefined( level.zombiemode_using_deadshot_perk ) && level.zombiemode_using_deadshot_perk )
				killThread( ::turn_deadshot_on );
			break;
		case "specialty_additionalprimaryweapon":
			if ( isdefined( level.zombiemode_using_additionalprimaryweapon_perk ) && level.zombiemode_using_additionalprimaryweapon_perk )
				killThread( ::turn_additionalprimaryweapon_on );
			break;
		case "specialty_scavenger":
			if ( isdefined( level.zombiemode_using_tombstone_perk ) && level.zombiemode_using_tombstone_perk )
				killThread( ::turn_tombstone_on );
			break;
		case "specialty_finalstand":
			if ( isdefined( level.zombiemode_using_chugabud_perk ) && level.zombiemode_using_chugabud_perk )
				killThread( ::turn_chugabud_on );
			break;
		default:
			if ( isDefined( level._custom_perks[ perk ] ) )
			{
				killThread( level._custom_perks[ perk ].perk_machine_thread );
			}
			break;
	}
}

is_perk_restricted( perk )
{
	foreach ( perk_restriction in level.grief_restrictions[ "perks" ].list )
	{
		perk_restriction_str = "specialty_" + perk_restriction;
		if ( perk_restriction_str == perk )
		{
			return true;
		}
	}
	return false;
}

override_perk_struct_locations()
{
	if ( getDvar( "grief_perk_location_override" ) != "" )
	{
		perks_moved = [];
		perk_keys = strTok( getDvar( "grief_perk_location_override" ), " " );
		for ( i = 0; i < perk_keys.size; i++ )
		{
			if ( perk_keys[ i ] == "location" )
			{
				location = perk_keys[ i + 1 ];
				if ( !isDefined( perks_index ) )
				{
					perks_index = 0;
				}
				else 
				{
					perks_index++;
				}
			}
			if ( location != getDvar( "ui_zm_mapstartlocation" ) )
			{
				return;
			}
			else 
			{
				if ( perk_keys[ i ] == "perk" )
				{
					perks_moved[ perks_index ] = spawnStruct();
					perks_moved[ perks_index ].perk = perk_keys[ i + 1 ];
				}
				else if ( perk_keys[ i ] == "origin" )
				{
					perks_moved[ perks_index ].origin = cast_to_vector( perk_keys[ i + 1 ] );
				}
				else if ( perk_keys[ i ] == "angles" )
				{
					perks_moved[ perks_index ].angles = cast_to_vector( perk_keys[ i + 1 ] );
				}
			}
		}
		perks_location = "zgrief_perks_" + location;
		for ( i = 0; i < level.struct_class_names[ "targetname" ][ "zm_perk_machine" ].size; i++ )
		{
			for ( j = 0; j < perks_moved.size; j++ )
			{
				script_string_locations = strTok( level.struct_class_names[ "targetname" ][ "zm_perk_machine" ][ i ].script_string, " " );
				for ( k = 0; k < script_string_locations.size; k++ )
				{
					if ( level.struct_class_names[ "targetname" ][ "zm_perk_machine" ][ i ].script_noteworthy == perks_moved[ j ].perk && script_string_locations[ k ] == perks_location )
					{
						level.struct_class_names[ "targetname" ][ "zm_perk_machine" ][ i ].origin = perks_moved[ j ].origin;
						level.struct_class_names[ "targetname" ][ "zm_perk_machine" ][ i ].angles = perks_moved[ j ].angles;
						break;
					}
				}
			}
		}
	}
}

cast_to_vector( vector_string )
{
	keys = strTok( vector_string, "," );
	vector_array = [];
	for ( i = 0; i < keys.size; i++ )
	{
		vector_array[ i ] = float( keys[ i ] ); 
	}
	vector = ( vector_array[ 0 ], vector_array[ 1 ], vector_array[ 2 ] );
	return vector;
}

reduce_starting_ammo()
{	
	wait 0.05;
	if ( self hasweapon( "m1911_zm" ) && ( self getammocount( "m1911_zm" ) > 16 ) )
	{
		self setweaponammostock( "m1911_zm", 8 );
	}
}

getDvarStringDefault( dvarname, default_value )
{
	cur_dvar_value = getDvar( dvarname );
	if ( cur_dvar_value != "" )
	{
		return cur_dvar_value;
	}
	else 
	{
		return default_value;
	}
}

gamerule_adjust_magic()
{
	turn_on = is_true( level.grief_gamerules[ "magic" ].current );
	is_on = is_true( level.grief_gamerules[ "magic" ].current );
	was_on = is_true( level.grief_gamerules[ "magic" ].lastvalue_this_match );
	if ( was_on && is_on )
	{
		if ( !turn_on )
		{
			if ( isDefined( level.chests ) )
			{
				foreach ( chest in level.chests )
				{
					chest hide_chest();
					chest notify( "kill_chest_think" );
				}
			}

			//Kill the threads because they don't endon "death" to prevent script errors.
			foreach ( perk in level.data_maps[ "perks" ][ "specialties" ] )
			{
				perk_str = "specialty_" + perk;
				kill_perk_machine_thread( perk_str );
				perk_machine_removal( perk_str );
			}
			flag_clear( "zombie_drop_powerups" );
		}
	}
	else 
	{

	}
}

gamerule_adjust_knife_lunge()
{
	turn_on = is_true( level.grief_gamerules[ "knife_lunge" ].current );
	if ( turn_on )
	{
		foreach ( player in level.players )
		{
			player setClientDvar( "aim_automelee_range", 120 );
		}
	}
	else
	{
		foreach ( player in level.players )
		{
			player setClientDvar( "aim_automelee_range", 0 );
		}
	}
}

gamerule_adjust_player_health()
{

}

gamerule_toggle_mysterybox()
{
	turn_on = is_true( level.grief_gamerules[ "mystery_box_enabled" ].current );
	is_magic_on = is_true( level.grief_gamerules[ "magic" ].current );
	was_magic_on = is_true( level.grief_gamerules[ "magic" ].lastvalue_this_match );
	was_mysterybox_on = is_true( level.grief_gamerules[ "mystery_box_enabled" ].lastvalue_this_match );
	if ( was_magic_on && is_magic_on )
	{
		if ( was_mysterybox_on )
		{
			if ( !turn_on )
			{
				if ( isDefined( level.chests ) )
				{
					foreach ( chest in level.chests )
					{
						chest hide_chest();
						chest notify( "kill_chest_think" );
					}
				}
			}
		}
	}
}

gamerule_toggle_shock_on_pain()
{
	turn_on = is_true( level.grief_gamerules[ "shock_on_pain" ].current );
	level.shock_onpain = turn_on;
}

gamerule_toggle_grief_brutus_logic()
{
	is_brutus_on = is_true( level.grief_gamerules[ "grief_brutus_enabled" ].current );
	if ( is_brutus_on )
	{
		level thread [[ level.custom_grief_brutus_logic ]]();
	}
	else 
	{
		level notify( "end_grief_brutus_logic" );
	}
}

gamerule_toggle_powerups()
{
	will_powerups_be_disabled = is_true( level.grief_gamerules[ "powerups_disabled" ].current );
	if ( will_powerups_be_disabled )
	{
		level.old_powerups_array = level.zombie_include_powerups;
		level.zombie_include_powerups = [];
	}
	else 
	{
		level.zombie_include_powerups = level.old_powerups_array;
	}
}

gamerule_disable_powerups()
{
	if ( is_true( level.grief_gamerules[ "powerups_disabled" ].current ) )
	{
		level.zombie_include_powerups = [];
	}
}

gamerule_toggle_fog()
{
	if( level.grief_gamerules[ "fog_disabled" ].current )
	{
		setDvar("r_fog", 0);
	}
	else
	{
		setDvar("r_fog", 1);
	}
}

gamerule_toggle_visionset()
{
	if( level.grief_gamerules[ "visionset_enabled" ].current )
	{
		foreach(player in level.players)
			player set_visionset();
	}
	else
	{

	}
}

set_visionset()
{
	if( !level.grief_gamerules[ "visionset_enabled" ].current )
		return;

	self useservervisionset(1);
	self setvisionsetforplayer(GetDvar( "mapname" ), 1.0 );
	self setclientdvar("r_dof_enable", 0);
	self setclientdvar("r_lodBiasRigid", -1000);
	self setclientdvar("r_lodBiasSkinned", -1000);
	self setClientDvar("r_lodScaleRigid", 1);
	self setClientDvar("r_lodScaleSkinned", 1);
	self setclientdvar("sm_sunquality", 2);
	self setclientdvar("r_enablePlayerShadow", 1);
	self setclientdvar( "vc_fbm", "0 0 0 0" );
	self setclientdvar( "vc_fsm", "1 1 1 1" );
	self setclientdvar( "vc_fgm", "1 1 1 1" );
}

set_ffa_vars()
{
	level.grief_ffa = getDvarIntDefault( "grief_ffa", 0 );
	if ( level.grief_ffa )
	{
		if ( cointoss() )
		{
			level.grief_ffa_team = "allies";
		}
		else 
		{
			level.grief_ffa_team = "axis";
		}
	}
	else
	{
		setdvar( "ui_scorelimit", level.grief_gamerules[ "scorelimit" ].current );
	}
}