#include maps/mp/zombies/_zm_spawner;
#include maps/mp/zombies/_zm_game_module;
#include maps/mp/zombies/_zm_pers_upgrades_functions;
#include maps/mp/zombies/_zm_blockers;
#include maps/mp/gametypes_zm/_spawning;
#include maps/mp/zombies/_zm_stats;
#include maps/mp/gametypes_zm/_hud;
#include maps/mp/zombies/_zm_audio_announcer;
#include maps/mp/zombies/_zm_audio;
#include maps/mp/zombies/_zm;
#include maps/mp/zombies/_zm_laststand;
#include maps/mp/gametypes_zm/_globallogic_ui;
#include maps/mp/gametypes_zm/_hud_message;
#include maps/mp/gametypes_zm/_globallogic_score;
#include maps/mp/gametypes_zm/_globallogic_defaults;
#include maps/mp/gametypes_zm/_globallogic_spawn;
#include maps/mp/gametypes_zm/_gameobjects;
#include maps/mp/gametypes_zm/_weapons;
#include maps/mp/gametypes_zm/_callbacksetup;
#include maps/mp/gametypes_zm/_globallogic;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/_utility;
#include maps/mp/zombies/_zm_perks;
#include maps/mp/zombies/_zm_zonemgr;
#include maps/mp/zombies/_zm_magicbox;

rungametypeprecache( gamemode )
{
	if ( !isDefined( level.gamemode_map_location_main ) || !isDefined( level.gamemode_map_location_main[ gamemode ] ) )
	{
		return;
	}
	if ( isDefined( level.gamemode_map_precache ) )
	{
		if ( isDefined( level.gamemode_map_precache[ gamemode ] ) )
		{
			[[ level.gamemode_map_precache[ gamemode ] ]]();
		}
	}
	if ( isDefined( level.gamemode_map_location_precache ) )
	{
		if ( isDefined( level.gamemode_map_location_precache[ gamemode ] ) )
		{
			loc = getDvar( "ui_zm_mapstartlocation" );
			if ( loc == "" && isDefined( level.default_start_location ) )
			{
				loc = level.default_start_location;
			}
			if ( isDefined( level.gamemode_map_location_precache[ gamemode ][ loc ] ) )
			{
				[[ level.gamemode_map_location_precache[ gamemode ][ loc ] ]]();
			}
		}
	}
	if ( isDefined( level.precachecustomcharacters ) )
	{
		self [[ level.precachecustomcharacters ]]();
	}
}

rungametypemain( gamemode, mode_main_func, use_round_logic )
{
	if ( !isDefined( level.gamemode_map_location_main ) || !isDefined( level.gamemode_map_location_main[ gamemode ] ) )
	{
		return;
	}
	level thread game_objects_allowed( getDvar( "g_gametype" ), getDvar( "ui_zm_mapstartlocation" ) );
	if ( isDefined( level.gamemode_map_main ) )
	{
		if ( isDefined( level.gamemode_map_main[ gamemode ] ) )
		{
			level thread [[ level.gamemode_map_main[ gamemode ] ]]();
		}
	}
	if ( isDefined( level.gamemode_map_location_main ) )
	{
		if ( isDefined( level.gamemode_map_location_main[ gamemode ] ) )
		{
			loc = getDvar( "ui_zm_mapstartlocation" );
			if ( loc == "" && isDefined( level.default_start_location ) )
			{
				loc = level.default_start_location;
			}
			if ( isDefined( level.gamemode_map_location_main[ gamemode ][ loc ] ) )
			{
				level thread [[ level.gamemode_map_location_main[ gamemode ][ loc ] ]]();
			}
		}
	}
	if ( isDefined( mode_main_func ) )
	{
		if ( is_true( use_round_logic ) )
		{
			level thread round_logic( mode_main_func );
		}
		else
		{
			level thread non_round_logic( mode_main_func );
		}
	}
	level thread game_end_func();
}

game_objects_allowed( mode, location )
{
	if ( location == "transit" )
	{
		location = "station";
	}
	allowed = [];
	allowed[ 0 ] = mode;
	entities = getentarray();
	i = 0;
	while ( i < entities.size )
	{
		if ( isDefined( entities[ i ].script_gameobjectname ) )
		{
			isallowed = maps/mp/gametypes_zm/_gameobjects::entity_is_allowed( entities[ i ], allowed );
			isvalidlocation = maps/mp/gametypes_zm/_gameobjects::location_is_allowed( entities[ i ], location );
			if ( !isallowed || !isvalidlocation && !is_classic() )
			{
				if ( isDefined( entities[ i ].spawnflags ) && entities[ i ].spawnflags == 1 )
				{
					if ( isDefined( entities[ i ].classname ) && entities[ i ].classname != "trigger_multiple" )
					{
						entities[ i ] connectpaths();
					}
				}
				entities[ i ] delete();
				i++;
				continue;
			}
			if ( isDefined( entities[ i ].script_vector ) )
			{
				entities[ i ] moveto( entities[ i ].origin + entities[ i ].script_vector, 0.05 );
				entities[ i ] waittill( "movedone" );
				if ( isDefined( entities[ i ].spawnflags ) && entities[ i ].spawnflags == 1 )
				{
					entities[ i ] disconnectpaths();
				}
				i++;
				continue;
			}
			if ( isDefined( entities[ i ].spawnflags ) && entities[ i ].spawnflags == 1 )
			{
				if ( isDefined( entities[ i ].classname ) && entities[ i ].classname != "trigger_multiple" )
				{
					entities[ i ] connectpaths();
				}
			}
		}
		i++;
	}
}

setup_standard_objects( location )
{
	structs = getstructarray( "game_mode_object" );
	i = 0;
	while ( i < structs.size )
	{
		if ( isdefined( structs[ i ].script_noteworthy ) && structs[ i ].script_noteworthy != location )
		{
			i++;
			continue;
		}
		if ( isdefined( structs[ i ].script_string ) )
		{
			keep = 0;
			tokens = strtok( structs[ i ].script_string, " " );
			foreach ( token in tokens )
			{
				if ( token == level.scr_zm_ui_gametype && token != "zstandard" )
				{
					keep = 1;
					continue;
				}
				else if ( token == "zstandard" )
				{
					keep = 1;
				}
			}
			if ( !keep )
			{
				i++;
				continue;
			}
		}
		barricade = spawn( "script_model", structs[ i ].origin );
		barricade.angles = structs[ i ].angles;
		barricade setmodel( structs[ i ].script_parameters );
		i++;
	}
	objects = getentarray();
	i = 0;
	while ( i < objects.size )
	{
		if ( !objects[ i ] is_survival_object() )
		{
			i++;
			continue;
		}
		if ( isdefined( objects[ i ].spawnflags ) && objects[ i ].spawnflags == 1 && objects[ i ].classname != "trigger_multiple" )
		{
			objects[ i ] connectpaths();
		}
		objects[ i ] delete();
		i++;
	}
	if ( isdefined( level._classic_setup_func ) )
	{
		[[ level._classic_setup_func ]]();
	}
}

createtimer()
{
	flag_waitopen( "pregame" );
	elem = newhudelem();
	elem.hidewheninmenu = 1;
	elem.horzalign = "center";
	elem.vertalign = "top";
	elem.alignx = "center";
	elem.aligny = "middle";
	elem.x = 0;
	elem.y = 0;
	elem.foreground = 1;
	elem.font = "default";
	elem.fontscale = 1.5;
	elem.color = ( 1, 1, 1 );
	elem.alpha = 2;
	elem thread maps/mp/gametypes_zm/_hud::fontpulseinit();
	if ( is_true( level.timercountdown ) )
	{
		elem settenthstimer( level.timelimit * 60 );
	}
	else
	{
		elem settenthstimerup( 0.1 );
	}
	level.game_module_timer = elem;
	level waittill( "game_module_ended" );
	elem destroy();
}

setup_classic_gametype()
{
	ents = getentarray();
	i = 0;
	while ( i < ents.size )
	{
		if ( isDefined( ents[ i ].script_parameters ) )
		{
			parameters = strtok( ents[ i ].script_parameters, " " );
			should_remove = 0;
			foreach ( parm in parameters )
			{
				if ( parm == "survival_remove" )
				{
					should_remove = 1;
				}
			}
			if ( should_remove )
			{
				ents[ i ] delete();
			}
		}
		i++;
	}
	structs = getstructarray( "game_mode_object" );
	i = 0;
	while ( i < structs.size )
	{
		if ( !isdefined( structs[ i ].script_string ) )
		{
			i++;
			continue;
		}
		tokens = strtok( structs[ i ].script_string, " " );
		spawn_object = 0;
		foreach ( parm in tokens )
		{
			if ( parm == "survival" )
			{
				spawn_object = 1;
			}
		}
		if ( !spawn_object )
		{
			i++;
			continue;
		}
		barricade = spawn( "script_model", structs[ i ].origin );
		barricade.angles = structs[ i ].angles;
		barricade setmodel( structs[ i ].script_parameters );
		i++;
	}
	unlink_meat_traversal_nodes();
}