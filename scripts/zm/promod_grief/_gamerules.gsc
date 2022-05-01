#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;

init_gamerules()
{
	level.default_solo_laststandpistol = "m1911_zm";
	level.is_forever_solo_game = undefined;
	level.speed_change_round = undefined;
	level.grief_gamerules = [];
	level.grief_gamerules[ "scorelimit" ] = getDvarIntDefault( "grief_gamerule_scorelimit", 3 );
	level.grief_gamerules[ "mystery_box_enabled" ] = getDvarIntDefault( "grief_gamerule_mystery_box_enabled", 0 );
	level.grief_gamerules[ "magic" ] = getDvarIntDefault( "grief_gamerule_magic", 1 );
    
	level.grief_gamerules[ "zombie_round" ] = getDvarIntDefault( "grief_gamerule_zombie_round", 20 );
	level.grief_gamerules[ "next_round_time" ] = getDvarIntDefault( "grief_gamerule_next_round_timer", 5 );
	level.grief_gamerules[ "round_restart_points" ] = getDvarIntDefault( "grief_gamerule_round_restart_points", 10000 );
	level.grief_gamerules[ "suicide_check" ] = getDvarFloatDefault( "grief_gamerule_suicide_check_wait", 5 );

	level.grief_gamerules[ "instructions" ] = getDvarIntDefault( "grief_gamerule_display_instructions", 0 );
	level.grief_gamerules[ "grief_messages" ] = getDvarIntDefault( "grief_gamerule_display_grief_messages", 0 );

	level.grief_gamerules[ "knife_lunge" ] = getDvarIntDefault( "grief_gamerule_knife_lunge", 1 );
	level.grief_gamerules[ "reduced_pistol_ammo" ] = getDvarIntDefault( "grief_gamerule_reduced_pistol_ammo", 1 );

	level.grief_gamerules[ "player_health" ] = getDvarIntDefault( "grief_gamerule_player_health", 100 );
	level.grief_gamerules[ "buildables" ] = getDvarIntDefault( "grief_gamerule_buildables", 1 );
	level.grief_gamerules[ "disable_doors" ] = getDvarIntDefault( "grief_gamerule_disable_doors", 1 );

    init_restrictions();
}

init_restrictions()
{
	if ( !isDefined( level.data_maps ) )
	{
		level.data_maps = [];
	}
	level.data_maps[ "perks" ] = [];
	level.data_maps[ "perks" ][ "specialties" ] = [];
	level.data_maps[ "perks" ][ "specialties" ][ 0 ] = "weapupgrade";
	level.data_maps[ "perks" ][ "specialties" ][ 1 ] = "armorvest";
	level.data_maps[ "perks" ][ "specialties" ][ 2 ] = "quickrevive";
	level.data_maps[ "perks" ][ "specialties" ][ 3 ] = "fastreload";
	level.data_maps[ "perks" ][ "specialties" ][ 4 ] = "rof";
	level.data_maps[ "perks" ][ "specialties" ][ 5 ] = "longersprint";
	level.data_maps[ "perks" ][ "specialties" ][ 6 ] = "deadshot";
	level.data_maps[ "perks" ][ "specialties" ][ 7 ] = "additionalprimaryweapon";
	level.data_maps[ "perks" ][ "specialties" ][ 8 ] = "scavenger";
	level.data_maps[ "perks" ][ "specialties" ][ 9 ] = "finalstand";
	level.data_maps[ "perks" ][ "specialties" ][ 10 ] = "grenadepulldeath";
	level.data_maps[ "perks" ][ "specialties" ][ 11 ] = "flakjacket";
	level.data_maps[ "perks" ][ "specialties" ][ 12 ] = "nomotionsensor";
	level.data_maps[ "perks" ][ "power_notifies" ] = [];
	level.data_maps[ "perks" ][ "power_notifies" ][ 0 ] = "Pack_A_Punch";
	level.data_maps[ "perks" ][ "power_notifies" ][ 1 ] = "juggernog";
	level.data_maps[ "perks" ][ "power_notifies" ][ 2 ] = "revive";
	level.data_maps[ "perks" ][ "power_notifies" ][ 3 ] = "sleight";
	level.data_maps[ "perks" ][ "power_notifies" ][ 4 ] = "doubletap";
	level.data_maps[ "perks" ][ "power_notifies" ][ 5 ] = "marathon";
	level.data_maps[ "perks" ][ "power_notifies" ][ 6 ] = "deadshot";
	level.data_maps[ "perks" ][ "power_notifies" ][ 7 ] = "additionalprimaryweapon";
	level.data_maps[ "perks" ][ "power_notifies" ][ 8 ] = "tombstone";
	level.data_maps[ "perks" ][ "power_notifies" ][ 9 ] = "chugabud";
	level.data_maps[ "perks" ][ "power_notifies" ][ 10 ] = "electric_cherry";
	level.data_maps[ "perks" ][ "power_notifies" ][ 11 ] = "divetonuke";
	level.data_maps[ "perks" ][ "power_notifies" ][ 12 ] = "specialty_nomotionsensor";

	level.data_maps[ "powerups" ] = [];
	level.data_maps[ "powerups" ][ "names" ] = [];
	level.data_maps[ "powerups" ][ "names" ][ 0 ] = "nuke";
	level.data_maps[ "powerups" ][ "names" ][ 1 ] = "insta_kill";
	level.data_maps[ "powerups" ][ "names" ][ 2 ] = "full_ammo";
	level.data_maps[ "powerups" ][ "names" ][ 3 ] = "double_points";
	level.data_maps[ "powerups" ][ "names" ][ 4 ] = "meat_stink";
	level.data_maps[ "powerups" ][ "names" ][ 5 ] = "fire_sale";
	level.data_maps[ "powerups" ][ "names" ][ 6 ] = "zombie_blood";
	level.data_maps[ "powerups" ][ "allowed" ] = [];
	level.data_maps[ "powerups" ][ "allowed" ][ 0 ] = true;
	level.data_maps[ "powerups" ][ "allowed" ][ 1 ] = true;
	level.data_maps[ "powerups" ][ "allowed" ][ 2 ] = true;
	level.data_maps[ "powerups" ][ "allowed" ][ 3 ] = true;
	level.data_maps[ "powerups" ][ "allowed" ][ 4 ] = true;
	level.data_maps[ "powerups" ][ "allowed" ][ 5 ] = true;
	level.data_maps[ "powerups" ][ "allowed" ][ 6 ] = true;

	level.grief_restrictions = [];

    // getDvarIntDefault
	level.grief_restrictions[ "perks" ] = getDvar( "grief_restrictions_perks" );
	level.grief_restrictions[ "powerups" ] = getDvar( "grief_restrictions_powerups" );

    level thread restrictions();
}

restrictions()
{   
    level waittill( "initial_blackscreen_passed" );

    perk_restrictions();
	powerup_restrictions();
}

perk_restrictions()
{
    // if ( level.script != "zm_transit" )
    //     return;

    for ( i = 0; i < level.data_maps[ "perks" ][ "power_notifies" ].size; i++ )
    {
        if ( is_perk_restricted( level.data_maps[ "perks" ][ "specialties" ][ i ] ) || is_perk_restricted( level.data_maps[ "perks" ][ "power_notifies" ][ i ] ) )
        {
            iPrintLn("res");
            trigger = getent( "specialty_" + level.data_maps[ "perks" ][ "specialties" ][ i ], "script_noteworthy" );
            if ( isDefined( trigger ) && !is_true( trigger.is_restricted ) )
            {
                hide_restricted_perk( trigger );
                trigger.is_restricted = true;
            }
        }
        else 
        {
            trigger = getent( "specialty_" + level.data_maps[ "perks" ][ "specialties" ][ i ], "script_noteworthy" );
            if ( isDefined( trigger ) )
            {
                level thread server_safe_notify_thread( level.data_maps[ "perks" ][ "power_notifies" ][ i ] + "_on", i );
            }
        }
    }
}

is_perk_restricted( perk )
{
	if ( level.grief_restrictions[ "perks" ] == "" )
	{
		return false;
	}
	perk_restrictions = strTok( level.grief_restrictions[ "perks" ], " " );
	foreach ( restriction in perk_restrictions )
	{
		if ( perk == restriction || restriction == "all" )
		{
			return true;
		}
	}
	return false;
}

hide_restricted_perk( perk_trigger )
{
	perk_machine = getEnt( perk_trigger.target, "targetname" );
	if ( !is_true( perk_machine.is_restricted ) )
	{
		perk_trigger trigger_off_proc();
		perk_trigger.clip notSolid();
		perk_machine = getEnt( perk_trigger.target, "targetname" );
		perk_machine hide();
		perk_machine.is_restricted = true;
	}
}

show_restricted_perk( perk_trigger )
{
	perk_machine = getEnt( perk_trigger.target, "targetname" );
	if ( is_true( perk_machine.is_restricted ) )
	{
		perk_trigger trigger_on_proc();
		perk_trigger.clip solid();
		perk_machine = getEnt( perk_trigger.target, "targetname" );
		perk_machine show();
		perk_machine.is_restricted = false;
	}
}

server_safe_notify_thread( notify_name, index )
{
	wait( ( index * 0.05 ) + 0.05 );
	level notify( notify_name );
}

powerup_restrictions()
{	
	if ( level.grief_restrictions[ "powerups" ] == "" )
	{
		return;
	}
	powerup_restrictions = strTok( level.grief_restrictions[ "powerups" ], " " );
	for ( i = 0; i < level.data_maps[ "powerups" ][ "names" ].size; i++ )
	{
		for ( j = 0; j < powerup_restrictions.size; j++ )
		{
			if ( isSubStr( level.data_maps[ "powerups" ][ "names" ][ i ], powerup_restrictions[ j ] ) || level.grief_restrictions[ "powerups" ] == "all" )
			{
				level.data_maps[ "powerups" ][ "allowed" ][ i ] = false;
				break;
			}
		}
	}
}

struct_class_init_override()
{
	level.struct_class_names = [];
	level.struct_class_names[ "target" ] = [];
	level.struct_class_names[ "targetname" ] = [];
	level.struct_class_names[ "script_noteworthy" ] = [];
	level.struct_class_names[ "script_linkname" ] = [];
	level.struct_class_names[ "script_unitrigger_type" ] = [];
	foreach ( s_struct in level.struct )
	{
		if ( isDefined( s_struct.targetname ) )
		{
			if ( !isDefined( level.struct_class_names[ "targetname" ][ s_struct.targetname ] ) )
			{
				level.struct_class_names[ "targetname" ][ s_struct.targetname ] = [];
			}
			size = level.struct_class_names[ "targetname" ][ s_struct.targetname ].size;
			level.struct_class_names[ "targetname" ][ s_struct.targetname ][ size ] = s_struct;
		}
		if ( isDefined( s_struct.target ) )
		{
			if ( !isDefined( level.struct_class_names[ "target" ][ s_struct.target ] ) )
			{
				level.struct_class_names[ "target" ][ s_struct.target ] = [];
			}
			size = level.struct_class_names[ "target" ][ s_struct.target ].size;
			level.struct_class_names[ "target" ][ s_struct.target ][ size ] = s_struct;
		}
		if ( isDefined( s_struct.script_noteworthy ) )
		{
			if ( !isDefined( level.struct_class_names[ "script_noteworthy" ][ s_struct.script_noteworthy ] ) )
			{
				level.struct_class_names[ "script_noteworthy" ][ s_struct.script_noteworthy ] = [];
			}
			size = level.struct_class_names[ "script_noteworthy" ][ s_struct.script_noteworthy ].size;
			level.struct_class_names[ "script_noteworthy" ][ s_struct.script_noteworthy ][ size ] = s_struct;
		}
		if ( isDefined( s_struct.script_linkname ) )
		{
			level.struct_class_names[ "script_linkname" ][ s_struct.script_linkname ][ 0 ] = s_struct;
		}
		if ( isDefined( s_struct.script_unitrigger_type ) )
		{
			if ( !isDefined( level.struct_class_names[ "script_unitrigger_type" ][ s_struct.script_unitrigger_type ] ) )
			{
				level.struct_class_names[ "script_unitrigger_type" ][ s_struct.script_unitrigger_type ] = [];
			}
			size = level.struct_class_names[ "script_unitrigger_type" ][ s_struct.script_unitrigger_type ].size;
			level.struct_class_names[ "script_unitrigger_type" ][ s_struct.script_unitrigger_type ][ size ] = s_struct;
		}
	}
	gametype = getDvar( "g_gametype" );
	location = getDvar( "ui_zm_mapstartlocation" );
	if ( array_validate( level.add_struct_gamemode_location_funcs ) )
	{
		if ( array_validate( level.add_struct_gamemode_location_funcs[ gametype ] ) )
		{
			if ( array_validate( level.add_struct_gamemode_location_funcs[ gametype ][ location ] ) )
			{
				for ( i = 0; i < level.add_struct_gamemode_location_funcs[ gametype ][ location ].size; i++ )
				{
					[[ level.add_struct_gamemode_location_funcs[ gametype ][ location ][ i ] ]]();
				}
			}
		}
	}
	override_perk_struct_locations();
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

set_knife_lunge( arg )
{
	if ( arg == 1 )
	{	
		setDvar( "grief_gamerule_knife_lunge", arg );
		foreach ( player in level.players )
		{	
			player setClientDvar( "aim_automelee_range", 120 );
		}
	}
	else if ( arg == 0 )
	{	
		setDvar( "grief_gamerule_knife_lunge", arg );
		foreach ( player in level.players )
		{	
			player setClientDvar( "aim_automelee_range", 0 );
		}
	}
}

reduce_starting_ammo()
{	
	wait 0.05;
	if ( self hasweapon( "m1911_zm" ) && ( self getammocount( "m1911_zm" ) > 16 ) )
	{
		self setweaponammostock( "m1911_zm", 8 );
	}
}