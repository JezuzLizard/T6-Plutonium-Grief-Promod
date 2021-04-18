//checked includes changed to match cerberus output
#include maps/mp/gametypes_zm/_spawnlogic;
#include maps/mp/animscripts/traverse/shared;
#include maps/mp/animscripts/utility;
#include maps/mp/zombies/_load;
#include maps/mp/_demo;
#include maps/mp/_global_fx;
#include maps/mp/_createfx;
#include maps/mp/_art;
#include maps/mp/_serverfaceanim_mp;
#include maps/mp/_fxanim;
#include maps/mp/_music;
#include maps/mp/_busing;
#include maps/mp/_audio;
#include maps/mp/_interactive_objects;
#include maps/mp/_script_gen;
#include maps/mp/_utility;
#include common_scripts/utility;

main( bscriptgened, bcsvgened, bsgenabled ) //checked partially changed to match cerberus output
{
	if ( !isDefined( level.script_gen_dump_reasons ) )
	{
		level.script_gen_dump_reasons = [];
	}
	if ( !isDefined( bsgenabled ) )
	{
		level.script_gen_dump_reasons[ level.script_gen_dump_reasons.size ] = "First run";
	}
	if ( !isDefined( bcsvgened ) )
	{
		bcsvgened = 0;
	}
	level.bcsvgened = bcsvgened;
	if ( !isDefined( bscriptgened ) )
	{
		bscriptgened = 0;
	}
	else
	{
		bscriptgened = 1;
	}
	level.bscriptgened = bscriptgened;
	level._loadstarted = 1;
	struct_class_init();
	if ( getDvar( "cg_usingClientScripts" ) != "" ) //changed at own discretion
	{
		level.clientscripts = getDvar( "cg_usingClientScripts" );
	}
	
	level._client_exploders = [];
	level._client_exploder_ids = [];
	if ( !isDefined( level.flag ) )
	{
		level.flag = [];
		level.flags_lock = [];
	}
	if ( !isDefined( level.timeofday ) )
	{
		level.timeofday = "day";
	}
	flag_init( "scriptgen_done" );
	level.script_gen_dump_reasons = [];
	if ( !isDefined( level.script_gen_dump ) )
	{
		level.script_gen_dump = [];
		level.script_gen_dump_reasons[ 0 ] = "First run";
	}
	if ( !isDefined( level.script_gen_dump2 ) )
	{
		level.script_gen_dump2 = [];
	}
	if ( isDefined( level.createfxent ) && isDefined( level.script ) )
	{
		script_gen_dump_addline( "maps\\mp\\createfx\\" + level.script + "_fx::main();", level.script + "_fx" );
	}
	if ( isDefined( level.script_gen_dump_preload ) )
	{
		for ( i = 0; i < level.script_gen_dump_preload.size; i++ )
		{
			script_gen_dump_addline( level.script_gen_dump_preload[ i ].string, level.script_gen_dump_preload[ i ].signature );
		}
	}
	if ( getDvar( "scr_RequiredMapAspectratio" ) == "" )
	{
		setdvar( "scr_RequiredMapAspectratio", "1" );
	}
	setdvar( "r_waterFogTest", 0 );
	precacherumble( "reload_small" );
	precacherumble( "reload_medium" );
	precacherumble( "reload_large" );
	precacherumble( "reload_clipin" );
	precacherumble( "reload_clipout" );
	precacherumble( "reload_rechamber" );
	precacherumble( "pullout_small" );
	precacherumble( "buzz_high" );
	precacherumble( "riotshield_impact" );
	registerclientsys( "levelNotify" );
	level.aitriggerspawnflags = getaitriggerflags();
	level.vehicletriggerspawnflags = getvehicletriggerflags();
	level.physicstracemaskphysics = 1;
	level.physicstracemaskvehicle = 2;
	level.physicstracemaskwater = 4;
	level.physicstracemaskclip = 8;
	level.physicstracecontentsvehicleclip = 16;
	if ( getDvar( "createfx" ) != "" )
	{
		level.createfx_enabled = getDvar( "createfx" );
	}
	level thread start_intro_screen_zm();
	thread maps/mp/_interactive_objects::init();
	maps/mp/_audio::init();
	thread maps/mp/_busing::businit();
	thread maps/mp/_music::music_init();
	thread maps/mp/_fxanim::init();
	thread maps/mp/_serverfaceanim_mp::init();
	if ( level.createfx_enabled )
	{
		setinitialplayersconnected();
	}
	visionsetnight( "default_night" );
	setup_traversals();
	maps/mp/_art::main();
	setupexploders();
	parse_structs();
	thread footsteps();
	/*
/#
	level thread level_notify_listener();
	level thread client_notify_listener();
#/
	*/
	thread maps/mp/_createfx::fx_init();
	if ( level.createfx_enabled )
	{
		calculate_map_center();
		maps/mp/_createfx::createfx();
	}
	if ( getDvar( "r_reflectionProbeGenerate" ) == "1" )
	{
		maps/mp/_global_fx::main();
		level waittill( "eternity" );
	}
	thread maps/mp/_global_fx::main();
	maps/mp/_demo::init();
	for ( p = 0; p < 6; p++ )
	{
		switch( p )
		{
			case 0:
				triggertype = "trigger_multiple";
				break;
			case 1:
				triggertype = "trigger_once";
				break;
			case 2:
				triggertype = "trigger_use";
				break;
			case 3:
				triggertype = "trigger_radius";
				break;
			case 4:
				triggertype = "trigger_lookat";
				break;
			default:
			/*
/#
				assert( p == 5 );
#/
			*/
				triggertype = "trigger_damage";
				break;
		}
		triggers = getentarray( triggertype, "classname" );
		for ( i = 0; i < triggers.size; i++ )
		{
			if ( isDefined( triggers[ i ].script_prefab_exploder ) )
			{
				triggers[ i ].script_exploder = triggers[ i ].script_prefab_exploder;
			}
			if ( isDefined( triggers[ i ].script_exploder ) )
			{
				level thread maps/mp/zombies/_load::exploder_load( triggers[ i ] );
			}
		}
	}
	//Initialize cut locations
	/////////////////////////////
	map = getDvar( "mapname" );
	location = getDvar( "ui_zm_mapstartlocation" ); 
	register_spawnpoint_structs();
	register_perk_structs();
	if ( map == "zm_transit" )
	{
		if ( location == "diner" || location == "cornfield" || location == "power" || location == "tunnel" )
		{
			level.trash_spawns = getDvarIntDefault( "grief_use_trash_spawns_power", 0 );
		}
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
				}
				else 
				{
					if ( perk_keys[ i ] == "perk" )
					{
						perks_moved[ perks_index ] = spawnStruct();
						perks_moved[ perks_index ].perk = perk_keys[ i + 1 ];
						logprint( "perks_moved array: index " + perks_index + " perks_moved array: perk " + perks_moved[ perks_index ].perk + "\n" );
					}
					else if ( perk_keys[ i ] == "origin" )
					{
						perks_moved[ perks_index ].origin = cast_to_vector( perk_keys[ i + 1 ] );
						logprint( "perks_moved array: index " + perks_index + " perks_moved array: origin " + perks_moved[ perks_index ].origin + "\n" );
					}
					else if ( perk_keys[ i ] == "angles" )
					{
						perks_moved[ perks_index ].angles = cast_to_vector( perk_keys[ i + 1 ] );
						logprint( "perks_moved array: index " + perks_index + " perks_moved array: angles " + perks_moved[ perks_index ].angles + "\n" );
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

							logprint( "perks_moved array: index " + j + " perks_moved array: perk " + perks_moved[ j ].perk + "\n" );
							logprint( "perks_moved array: index " + j + " perks_moved array: origin " + perks_moved[ j ].origin + "\n" );
							logprint( "perks_moved array: index " + j + " perks_moved array: angles " + perks_moved[ j ].angles + "\n" );
						}
					}
				}
			}
		}
	}
	/////////////////////////////
}

level_notify_listener() //checked matches cerberus output
{
	while ( 1 )
	{
		val = getDvar( "level_notify" );
		if ( val != "" )
		{
			level notify( val );
			setdvar( "level_notify", "" );
		}
		wait 0.2;
	}
}

client_notify_listener() //checked matches cerberus output
{
	while ( 1 )
	{
		val = getDvar( "client_notify" );
		if ( val != "" )
		{
			clientnotify( val );
			setdvar( "client_notify", "" );
		}
		wait 0.2;
	}
}

footsteps() //checked matches cerberus output
{
	if ( is_true( level.fx_exclude_footsteps ) )
	{
		return;
	}
	maps/mp/animscripts/utility::setfootstepeffect( "asphalt", loadfx( "bio/player/fx_footstep_dust" ) );
	maps/mp/animscripts/utility::setfootstepeffect( "brick", loadfx( "bio/player/fx_footstep_dust" ) );
	maps/mp/animscripts/utility::setfootstepeffect( "carpet", loadfx( "bio/player/fx_footstep_dust" ) );
	maps/mp/animscripts/utility::setfootstepeffect( "cloth", loadfx( "bio/player/fx_footstep_dust" ) );
	maps/mp/animscripts/utility::setfootstepeffect( "concrete", loadfx( "bio/player/fx_footstep_dust" ) );
	maps/mp/animscripts/utility::setfootstepeffect( "dirt", loadfx( "bio/player/fx_footstep_sand" ) );
	maps/mp/animscripts/utility::setfootstepeffect( "foliage", loadfx( "bio/player/fx_footstep_sand" ) );
	maps/mp/animscripts/utility::setfootstepeffect( "gravel", loadfx( "bio/player/fx_footstep_dust" ) );
	maps/mp/animscripts/utility::setfootstepeffect( "grass", loadfx( "bio/player/fx_footstep_dust" ) );
	maps/mp/animscripts/utility::setfootstepeffect( "metal", loadfx( "bio/player/fx_footstep_dust" ) );
	maps/mp/animscripts/utility::setfootstepeffect( "mud", loadfx( "bio/player/fx_footstep_mud" ) );
	maps/mp/animscripts/utility::setfootstepeffect( "paper", loadfx( "bio/player/fx_footstep_dust" ) );
	maps/mp/animscripts/utility::setfootstepeffect( "plaster", loadfx( "bio/player/fx_footstep_dust" ) );
	maps/mp/animscripts/utility::setfootstepeffect( "rock", loadfx( "bio/player/fx_footstep_dust" ) );
	maps/mp/animscripts/utility::setfootstepeffect( "sand", loadfx( "bio/player/fx_footstep_sand" ) );
	maps/mp/animscripts/utility::setfootstepeffect( "water", loadfx( "bio/player/fx_footstep_water" ) );
	maps/mp/animscripts/utility::setfootstepeffect( "wood", loadfx( "bio/player/fx_footstep_dust" ) );
}

parse_structs() //checked matches cerberus output
{
	for ( i = 0; i < level.struct.size; i++ )
	{
		if ( isDefined( level.struct[ i ].targetname ) )
		{
			if ( level.struct[ i ].targetname == "flak_fire_fx" )
			{
				level._effect[ "flak20_fire_fx" ] = loadfx( "weapon/tracer/fx_tracer_flak_single_noExp" );
				level._effect[ "flak38_fire_fx" ] = loadfx( "weapon/tracer/fx_tracer_quad_20mm_Flak38_noExp" );
				level._effect[ "flak_cloudflash_night" ] = loadfx( "weapon/flak/fx_flak_cloudflash_night" );
				level._effect[ "flak_burst_single" ] = loadfx( "weapon/flak/fx_flak_single_day_dist" );
			}
			if ( level.struct[ i ].targetname == "fake_fire_fx" )
			{
				level._effect[ "distant_muzzleflash" ] = loadfx( "weapon/muzzleflashes/heavy" );
			}
			if ( level.struct[ i ].targetname == "spotlight_fx" )
			{
				level._effect[ "spotlight_beam" ] = loadfx( "env/light/fx_ray_spotlight_md" );
			}
		}
	}
}

exploder_load( trigger ) //checked matches cerberus output
{
	level endon( "killexplodertridgers" + trigger.script_exploder );
	trigger waittill( "trigger" );
	if ( isDefined( trigger.script_chance ) && randomfloat( 1 ) > trigger.script_chance )
	{
		if ( isDefined( trigger.script_delay ) )
		{
			wait trigger.script_delay;
		}
		else
		{
			wait 4;
		}
		level thread exploder_load( trigger );
		return;
	}
	maps/mp/_utility::exploder( trigger.script_exploder );
	level notify( "killexplodertridgers" + trigger.script_exploder );
}

setupexploders() //checked partially changed to match cerberus output
{
	ents = getentarray( "script_brushmodel", "classname" );
	smodels = getentarray( "script_model", "classname" );
	for ( i = 0; i < smodels.size; i++ )
	{
		ents[ ents.size ] = smodels[ i ];
	}
	i = 0;
	while ( i < ents.size )
	{
		if ( isDefined( ents[ i ].script_prefab_exploder ) )
		{
			ents[ i ].script_exploder = ents[ i ].script_prefab_exploder;
		}
		if ( isDefined( ents[ i ].script_exploder ) )
		{
			if ( ents[ i ].model == "fx" || !isDefined( ents[ i ].targetname ) && ents[ i ].targetname != "exploderchunk" )
			{
				ents[ i ] hide();
				i++;
				continue;
			}
			if ( isDefined( ents[ i ].targetname ) && ents[ i ].targetname == "exploder" )
			{
				ents[ i ] hide();
				ents[ i ] notsolid();
				i++;
				continue;
			}
			if ( isDefined( ents[ i ].targetname ) && ents[ i ].targetname == "exploderchunk" )
			{
				ents[ i ] hide();
				ents[ i ] notsolid();
			}
		}
		i++;
	}
	script_exploders = [];
	potentialexploders = getentarray( "script_brushmodel", "classname" );
	for ( i = 0; i < potentialexploders.size; i++ )
	{
		if ( isDefined( potentialexploders[ i ].script_prefab_exploder ) )
		{
			potentialexploders[ i ].script_exploder = potentialexploders[ i ].script_prefab_exploder;
		}
		if ( isDefined( potentialexploders[ i ].script_exploder ) )
		{
			script_exploders[ script_exploders.size ] = potentialexploders[ i ];
		}
	}
	potentialexploders = getentarray( "script_model", "classname" );
	for ( i = 0; i < potentialexploders.size; i++ )
	{
		if ( isDefined( potentialexploders[ i ].script_prefab_exploder ) )
		{
			potentialexploders[ i ].script_exploder = potentialexploders[ i ].script_prefab_exploder;
		}
		if ( isDefined( potentialexploders[ i ].script_exploder ) )
		{
			script_exploders[ script_exploders.size ] = potentialexploders[ i ];
		}
	}
	potentialexploders = getentarray( "item_health", "classname" );
	for ( i = 0; i < potentialexploders.size; i++ )
	{
		if ( isDefined( potentialexploders[ i ].script_prefab_exploder ) )
		{
			potentialexploders[ i ].script_exploder = potentialexploders[ i ].script_prefab_exploder;
		}
		if ( isDefined( potentialexploders[ i ].script_exploder ) )
		{
			script_exploders[ script_exploders.size ] = potentialexploders[ i ];
		}
	}
	if ( !isDefined( level.createfxent ) )
	{
		level.createfxent = [];
	}
	acceptabletargetnames = [];
	acceptabletargetnames[ "exploderchunk visible" ] = 1;
	acceptabletargetnames[ "exploderchunk" ] = 1;
	acceptabletargetnames[ "exploder" ] = 1;
	for ( i = 0; i < script_exploders.size; i++ )
	{
		exploder = script_exploders[ i ];
		ent = createexploder( exploder.script_fxid );
		ent.v = [];
		ent.v[ "origin" ] = exploder.origin;
		ent.v[ "angles" ] = exploder.angles;
		ent.v[ "delay" ] = exploder.script_delay;
		ent.v[ "firefx" ] = exploder.script_firefx;
		ent.v[ "firefxdelay" ] = exploder.script_firefxdelay;
		ent.v[ "firefxsound" ] = exploder.script_firefxsound;
		ent.v[ "firefxtimeout" ] = exploder.script_firefxtimeout;
		ent.v[ "earthquake" ] = exploder.script_earthquake;
		ent.v[ "damage" ] = exploder.script_damage;
		ent.v[ "damage_radius" ] = exploder.script_radius;
		ent.v[ "soundalias" ] = exploder.script_soundalias;
		ent.v[ "repeat" ] = exploder.script_repeat;
		ent.v[ "delay_min" ] = exploder.script_delay_min;
		ent.v[ "delay_max" ] = exploder.script_delay_max;
		ent.v[ "target" ] = exploder.target;
		ent.v[ "ender" ] = exploder.script_ender;
		ent.v[ "type" ] = "exploder";
		if ( !isDefined( exploder.script_fxid ) )
		{
			ent.v[ "fxid" ] = "No FX";
		}
		else
		{
			ent.v[ "fxid" ] = exploder.script_fxid;
		}
		ent.v[ "exploder" ] = exploder.script_exploder;
		/*
/#
		assert( isDefined( exploder.script_exploder ), "Exploder at origin " + exploder.origin + " has no script_exploder" );
#/
		*/
		if ( !isDefined( ent.v[ "delay" ] ) )
		{
			ent.v[ "delay" ] = 0;
		}
		if ( isDefined( exploder.target ) )
		{
			org = getent( ent.v[ "target" ], "targetname" ).origin;
			ent.v[ "angles" ] = vectorToAngles( org - ent.v[ "origin" ] );
		}
		if ( exploder.classname == "script_brushmodel" || isDefined( exploder.model ) )
		{
			ent.model = exploder;
			ent.model.disconnect_paths = exploder.script_disconnectpaths;
		}
		if ( isDefined( exploder.targetname ) && isDefined( acceptabletargetnames[ exploder.targetname ] ) )
		{
			ent.v[ "exploder_type" ] = exploder.targetname;
		}
		else
		{
			ent.v[ "exploder_type" ] = "normal";
		}
		ent maps/mp/_createfx::post_entity_creation_function();
	}
	level.createfxexploders = [];
	i = 0;
	while ( i < level.createfxent.size )
	{
		ent = level.createfxent[ i ];
		if ( ent.v[ "type" ] != "exploder" )
		{
			i++;
			continue;
		}
		ent.v[ "exploder_id" ] = getexploderid( ent );
		if ( !isDefined( level.createfxexploders[ ent.v[ "exploder" ] ] ) )
		{
			level.createfxexploders[ ent.v[ "exploder" ] ] = [];
		}
		level.createfxexploders[ ent.v[ "exploder" ] ][ level.createfxexploders[ ent.v[ "exploder" ] ].size ] = ent;
		i++;
	}
}

setup_traversals() //checked changed to match cerberus output
{
	potential_traverse_nodes = getallnodes();
	for ( i = 0; i < potential_traverse_nodes.size; i++ )
	{
		node = potential_traverse_nodes[ i ];
		if ( node.type == "Begin" )
		{
			node maps/mp/animscripts/traverse/shared::init_traverse();
		}
	}
}

calculate_map_center() //checked matches cerberus output
{
	if ( !isDefined( level.mapcenter ) )
	{
		level.nodesmins = ( 0, 0, 0 );
		level.nodesmaxs = ( 0, 0, 0 );
		level.mapcenter = maps/mp/gametypes_zm/_spawnlogic::findboxcenter( level.nodesmins, level.nodesmaxs );
		/*
/#
		println( "map center: ", level.mapcenter );
#/
		*/
		setmapcenter( level.mapcenter );
	}
}

start_intro_screen_zm() //checked changed to match cerberus output
{
	if ( level.createfx_enabled )
	{
		return;
	}
	if ( !isDefined( level.introscreen ) )
	{
		level.introscreen = newhudelem();
		level.introscreen.x = 0;
		level.introscreen.y = 0;
		level.introscreen.horzalign = "fullscreen";
		level.introscreen.vertalign = "fullscreen";
		level.introscreen.foreground = 0;
		level.introscreen setshader( "black", 640, 480 );
		level.introscreen.immunetodemogamehudsettings = 1;
		level.introscreen.immunetodemofreecamera = 1;
		wait 0.05;
	}
	level.introscreen.alpha = 1;
	players = get_players();
	for ( i = 0; i < players.size; i++ )
	{
		players[ i ] freezecontrols( 1 );
	}
	wait 1;
}

//Begin cut locations functions
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
register_perk_structs()
{
	switch ( getDvar( "ui_zm_mapstartlocation" ) )
	{
		case "diner":
			_register_survival_perk( "specialty_armorvest", "zombie_vending_jugg", ( 0, 176, 0 ), ( -3634, -7464, -58 ) );
			_register_survival_perk( "specialty_rof", "zombie_vending_doubletap2", ( 0, -90, 0 ), ( -4170, -7610, -61 ) );
			_register_survival_perk( "specialty_longersprint", "zombie_vending_marathon", ( 0, 4, 0 ), ( -4576, -6704, -61 ) );
			_register_survival_perk( "specialty_scavenger", "zombie_vending_tombstone", ( 0, 90, 0 ), ( -6496, -7691, 0 ) );
			_register_survival_perk( "specialty_weapupgrade", "p6_anim_zm_buildable_pap_on", ( 0, 175, 0 ), ( -6351, -7778, 227 ) );
			_register_survival_perk( "specialty_quickrevive", "zombie_vending_quickrevive", ( 0, 137, 0 ), ( -5424, -7920, -64 ) );
			_register_survival_perk( "specialty_fastreload", "zombie_vending_sleight", ( 0, 270, 0 ), ( -5470, -7859.5, 0 ) );
			break;
		case "tunnel":
			_register_survival_perk( "specialty_armorvest", "zombie_vending_jugg", ( 0, -180, 0 ), ( -11541, -2630, 194 ) );
			_register_survival_perk( "specialty_rof", "zombie_vending_doubletap2", ( 0, -10, 0 ), ( -11170, -590, 196 ) );
			_register_survival_perk( "specialty_longersprint", "zombie_vending_marathon", ( 0, -19, 0 ), ( -11681, -734, 228 ) );
			_register_survival_perk( "specialty_scavenger", "zombie_vending_tombstone", ( 0, -98, 0 ), ( -10664, -757, 196 ) );
			_register_survival_perk( "specialty_weapupgrade", "p6_anim_zm_buildable_pap_on", ( 0, 115, 0 ), ( -11301, -2096, 184 ) );
			_register_survival_perk( "specialty_quickrevive", "zombie_vending_quickrevive", ( 0, 270, 0 ), ( -10780, -2565, 224 ) );
			_register_survival_perk( "specialty_fastreload", "zombie_vending_sleight", ( 0, -89, 0 ), ( -11373, -1674, 192 ) );
			break;
		case "power":
			_register_survival_perk( "specialty_armorvest", "zombie_vending_jugg", ( 0, -132, 0 ), ( 10746, 7282, -557 ) );
			_register_survival_perk( "specialty_rof", "zombie_vending_doubletap2", ( 0, 180, 0 ), ( 11402, 8159, -487 ) );
			_register_survival_perk( "specialty_longersprint", "zombie_vending_marathon", ( 0, -35, 0 ), ( 10856, 7879, -576 ) );
			_register_survival_perk( "specialty_quickrevive", "zombie_vending_quickrevive", ( 0, 270, 0 ), ( 10946, 8308.77, -408 ) );
			_register_survival_perk( "specialty_weapupgrade", "p6_anim_zm_buildable_pap_on", ( 0, 162, 0 ), ( 12625, 7434, -755 ) );
			_register_survival_perk( "specialty_scavenger", "zombie_vending_tombstone", ( 0, -4, 0 ), ( 11156, 8120, -575 ) );
			_register_survival_perk( "specialty_fastreload", "zombie_vending_sleight", ( 0, -1, 0 ), ( 11568, 7723, -755 ) );
			break;
		case "cornfield":
			_register_survival_perk( "specialty_armorvest", "zombie_vending_jugg", ( 0, 179, 0 ), ( 13936, -649, -189 ) );
			_register_survival_perk( "specialty_rof", "zombie_vending_doubletap2", ( 0, -137, 0 ), ( 12052, -1943, -160 ) );
			_register_survival_perk( "specialty_longersprint", "zombie_vending_marathon", ( 0, -35, 0 ), ( 9944, -725, -211 ) );
			_register_survival_perk( "specialty_scavenger", "zombie_vending_tombstone", ( 0, 133, 0 ), ( 13551, -1384, -188 ) );
			_register_survival_perk( "specialty_weapupgrade", "p6_anim_zm_buildable_pap_on", ( 0, 123, 0), ( 9960, -1288, -217 ) );
			_register_survival_perk( "specialty_quickrevive", "zombie_vending_quickrevive", ( 0, -90, 0 ), ( 7831, -464, -203 ) );
			_register_survival_perk( "specialty_fastreload", "zombie_vending_sleight", ( 0, -4, 0 ), ( 13255, 74, -195 ) );
			break;
		case "cellblock":
			_register_survival_perk( "specialty_armorvest", "zombie_vending_jugg", ( 0, 86, 0 ), ( 1403, 9662, 1336 ) );
			break;
		case "transit":
			_register_survival_perk( "specialty_armorvest", "zombie_vending_jugg", ( 0, -5, 0), ( -6136, 5590, -63.85 ) );
			break;
	}
}

_register_survival_perk( perk_name, perk_model, perk_angles, perk_coordinates )
{
	if ( getDvar( "g_gametype" ) == "zgrief" && perk_name == "specialty_scavenger" )
	{
		return;
	}
	perk_struct = spawnStruct();
	perk_struct.script_noteworthy = perk_name;
	perk_struct.model = perk_model;
	perk_struct.angles = perk_angles;
	perk_struct.origin = perk_coordinates;
	//perk_struct.script_string = _get_perk_script_string_for_location( getDvar( "ui_zm_mapstartlocation" ), getDvar( "g_gametype") );
	perk_struct.targetname = "zm_perk_machine";
	struct_size = level.struct_class_names[ "targetname" ][ "zm_perk_machine" ].size;
	level.struct_class_names[ "targetname" ][ "zm_perk_machine" ][ struct_size ] = perk_struct;
}

_get_perk_script_string_for_location( location, gametype )
{ 
	string = gametype + "_" + "perks" + "_" + location;
	return string;
}

register_spawnpoint_structs() //custom function
{
	switch ( getDvar( "ui_zm_mapstartlocation" ) )
	{
		case "tunnel":
			coordinates = array( ( -11196, -837, 192 ), ( -11386, -863, 192 ), ( -11405, -1000, 192 ), ( -11498, -1151, 192 ),
									( -11398, -1326, 191 ), ( -11222, -1345, 192 ), ( -10934, -1380, 192 ), ( -10999, -1072, 192 ) );
			angles = array( ( 0, -94, 0 ), ( 0, -44, 0 ), ( 0, -32, 0 ), ( 0, 4, 0 ), ( 0, 50, 0 ), ( 0, 157, 0 ), ( 0, -144, 0 ) );		
			break;
		case "diner":
			coordinates = array( ( -3991, -7317, -63 ), ( -4231, -7395, -60 ), ( -4127, -6757, -54 ), ( -4465, -7346, -58 ),
									( -5770, -6600, -55 ), ( -6135, -6671, -56 ), ( -6182, -7120, -60 ), ( -5882, -7174, -61 ) );
			angles = array( ( 0, 161, 0 ), ( 0, 120, 0 ), ( 0, 217, 0 ), ( 0, 173, 0 ), ( 0, -106, 0 ), ( 0, -46, 0 ), ( 0, 51, 0 ), ( 0, 99, 0 ) );
			break;
		case "cornfield":
			coordinates = array( ( 7521, -545, -198 ), ( 7751, -522, -202 ), ( 7691, -395, -201 ), ( 7536, -432, -199 ), 
									( 13745, -336, -188 ), ( 13758, -681, -188 ), ( 13816, -1088, -189 ), ( 13752, -1444, -182 ) );
			angles = array( ( 0, 40, 0 ), ( 0, 145, 0 ), ( 0, -131, 0 ), ( 0, -24, 0 ), ( 0, -178, 0 ), ( 0, -179, 0 ), ( 0, -177, 0 ), ( 0, -177, 0 ) );
			break;
		case "power":
			if ( !is_true( level.trash_spawns ) )
			{
				coordinates = array( ( 11288, 7988, -550 ), ( 11284, 7760, -549 ), ( 10784, 7623, -584 ), ( 10866, 7473, -580 ),
									( 10261, 8146, -580 ), ( 10595, 8055, -541 ), ( 10477, 7679, -567 ), ( 10165, 7879, -570 ) );
				angles = array( ( 0, -137, 0 ), ( 0, 177, 0 ), ( 0, -10, 0 ), ( 0, 21, 0 ), ( 0, -31, 0 ), ( 0, -43, 0 ), ( 0, -9, 0 ), ( 0, -15, 0 ) );
			}
			else 
			{
				coordinates = array( ( 11257, 8233, -487 ), ( 11403, 8245, -487 ), ( 11381, 8374, -487), ( 11269, 8360, -487 ),
									( 10871, 8433, -407 ), ( 10852, 8230, -407 ), ( 10641, 8228, -407 ), ( 10655, 8431, -407 ) );
				angles = array( ( 0, -137, 0 ), ( 0, 177, 0 ), ( 0, -10, 0 ), ( 0, 21, 0 ), ( 0, -31, 0 ), ( 0, -43, 0 ), ( 0, -9, 0 ), ( 0, -15, 0 ) );
			}
			break;
		case "cellblock":
			coordinates = array( ( 1422, 9597, 1336 ), ( 1432, 9745, 1336 ), ( 2154, 9062, 1336 ), ( 1969, 9950, 1336 ),
								  ( 2150, 9496, 1336 ), ( 2144, 9931, 1336 ), ( 1665, 9053, 1336 ), ( 1661, 9211, 1336 ) );
			angles = array( ( 0, 0, 0 ), ( 0, 0, 0 ), ( 0, 180, 0 ), ( 0, 0, 0 ),
							( 0, 180, 0 ), ( 0, 180, 0), ( 0, 0, 0 ), ( 0, 0, 0) );
			break;
	}
	if ( getDvar( "ui_zm_mapstartlocation" ) == "cellblock" )
	{
		level.struct_class_names[ "targetname" ][ "player_respawn_point" ] = [];
		level.struct_class_names[ "script_noteworthy" ][ "initial_spawn" ] = [];
	} 
	for ( i = 0; i < 8; i++ )
	{
		if ( isDefined( angles ) )
		{
			_register_map_initial_spawnpoint( coordinates[ i ], angles[ i ] );
		}
		else 
		{
			_register_map_initial_spawnpoint( coordinates[ i ], undefined );
		}

	}
}

_register_map_initial_spawnpoint( spawnpoint_coordinates, spawnpoint_angles ) //custom function
{
	spawnpoint_struct = spawnStruct();
	spawnpoint_struct.origin = spawnpoint_coordinates;
	if ( isDefined( spawnpoint_angles ) )
	{
		spawnpoint_struct.angles = spawnpoint_angles;
	}
	else 
	{
		spawnpoint_struct.angles = ( 0, 0, 0 );
	}
	spawnpoint_struct.radius = 32;
	spawnpoint_struct.script_noteworthy = "initial_spawn";
	spawnpoint_struct.script_int = 2048;
	spawnpoint_struct.script_string = _get_spawnpoint_script_string_for_location( getDvar( "ui_zm_mapstartlocation" ), getDvar( "g_gametype" ) );
	spawnpoint_struct.locked = 0;
	player_respawn_point_size = level.struct_class_names[ "targetname" ][ "player_respawn_point" ].size;
	player_initial_spawnpoint_size = level.struct_class_names[ "script_noteworthy" ][ "initial_spawn" ].size;
	level.struct_class_names[ "targetname" ][ "player_respawn_point" ][ player_respawn_point_size ] = spawnpoint_struct;
	level.struct_class_names[ "script_noteworthy" ][ "initial_spawn" ][ player_initial_spawnpoint_size ] = spawnpoint_struct;
}

_get_spawnpoint_script_string_for_location( location, gametype )
{
	string = gametype + "_" + location;
	return string;
}

cast_to_vector( vector_string )
{
	logprint( vector_string + "\n" );
	keys = strTok( vector_string, "," );
	logprint( keys[ 0 ] + "\n" );
	vector_array = [];
	for ( i = 0; i < keys.size; i++ )
	{
		vector_array[ i ] = float( keys[ i ] ); 
		logprint( vector_array[ i ] + "\n" );
	}
	vector = ( vector_array[ 0 ], vector_array[ 1 ], vector_array[ 2 ] );
	return vector;
}