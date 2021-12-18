#include maps/mp/zombies/_zm_game_module;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zombies/_zm;
#include scripts/zm/promod/_gametype_setup;

struct_init()
{
	scripts/zm/grief/gametype_modules/_gametype_setup::register_perk_struct( "specialty_armorvest", "zombie_vending_jugg", ( 0, -132, 0 ), ( 10746, 7282, -557 ) );
	scripts/zm/grief/gametype_modules/_gametype_setup::register_perk_struct( "specialty_rof", "zombie_vending_doubletap2", ( 0, 180, 0 ), ( 11402, 8159, -487 ) );
	scripts/zm/grief/gametype_modules/_gametype_setup::register_perk_struct( "specialty_longersprint", "zombie_vending_marathon", ( 0, -35, 0 ), ( 10856, 7879, -576 ) );
	scripts/zm/grief/gametype_modules/_gametype_setup::register_perk_struct( "specialty_quickrevive", "zombie_vending_quickrevive", ( 0, 270, 0 ), ( 10946, 8308.77, -408 ) );
	scripts/zm/grief/gametype_modules/_gametype_setup::register_perk_struct( "specialty_weapupgrade", "p6_anim_zm_buildable_pap_on", ( 0, 162, 0 ), ( 12625, 7434, -755 ) );
	scripts/zm/grief/gametype_modules/_gametype_setup::register_perk_struct( "specialty_scavenger", "zombie_vending_tombstone", ( 0, -4, 0 ), ( 11156, 8120, -575 ) );
	scripts/zm/grief/gametype_modules/_gametype_setup::register_perk_struct( "specialty_fastreload", "zombie_vending_sleight", ( 0, -1, 0 ), ( 11568, 7723, -755 ) );
	level.trash_spawns = getDvarIntDefault( "grief_use_trash_spawns_power", 0 );
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
	for ( i = 0; i < coordinates.size; i++ )
	{
		scripts/zm/grief/gametype_modules/_gametype_setup::register_map_initial_spawnpoint( coordinates[ i ], angles[ i ] );
	}
	door_ents = getEntArray( "zombie_door", "targetname" );
	foreach ( door in door_ents )
	{
		if ( door.script_noteworthy == "electric_door" )
		{
			door.script_noteworthy = "electric_buyable_door";
		}
	}
	level.location_zones = [];
	level.location_zones[ 0 ] = "zone_pow";
	level.location_zones[ 1 ] = "zone_pow_warehouse";
}

precache()
{
	normalChests = getstructarray( "treasure_chest_use", "targetname" );
	start_chest_zbarrier = getEnt( "depot_chest_zbarrier", "script_noteworthy" );
	start_chest_zbarrier.origin = ( 10806, 8518, -407 );
	start_chest_zbarrier.angles = ( 0, 180, 0 );
	start_chest = spawnStruct();
	start_chest.origin = ( 10806, 8518, -407 );
	start_chest.angles = ( 0, 180, 0 );
	start_chest.script_noteworthy = "depot_chest";
	start_chest.zombie_cost = 950;
	collision = spawn( "script_model", start_chest_zbarrier.origin );
	collision.angles = start_chest_zbarrier.angles;
	collision setmodel( "collision_clip_32x32x128" );
	collision = spawn( "script_model", start_chest_zbarrier.origin - ( 32, 0, 0 ) );
	collision.angles = start_chest_zbarrier.angles;
	collision setmodel( "collision_clip_32x32x128" );
	collision = spawn( "script_model", start_chest_zbarrier.origin + ( 32, 0, 0 ) );
	collision.angles = start_chest_zbarrier.angles;
	collision setmodel( "collision_clip_32x32x128" );
	level.chests = [];
	level.chests[ 0 ] = normalChests[ 2 ];
	level.chests[ 1 ] = start_chest;
}

power_main()
{
	level thread falling_death_init();
	init_wallbuys();
	init_barriers();
	maps/mp/zombies/_zm_magicbox::treasure_chest_init( "pow_chest" );
	scripts/zm/zm_transit/locs/location_common::common_init();
}

init_wallbuys()
{
	//wallbuy( ( 0, 90, 0), ( 10559, 8226, -504 ), "m14_zm_fx", "m14_zm", "t6_wpn_ar_m14_world", "m14", "weapon_upgrade" );
	scripts/zm/grief/gametype_modules/_gametype_setup::wallbuy( ( 0, -180, 0 ), ( 10620, 8135, -490 ), "mp5k_zm_fx", "mp5k_zm", "t6_wpn_smg_mp5_world", "mp5", "weapon_upgrade" );
	//wallbuy( ( 0, 170, 0 ), ( 11769, 7662, -701 ), "rottweil72_zm_fx", "rottweil72_zm", "t6_wpn_shotty_olympia_world", "olympia", "weapon_upgrade" );
	scripts/zm/grief/gametype_modules/_gametype_setup::wallbuy( ( 0, 0, 0 ), ( 10859, 8146, -353 ), "m16_zm_fx", "m16_zm", "t6_wpn_ar_m16a2_world", "m16", "weapon_upgrade" );
	scripts/zm/grief/gametype_modules/_gametype_setup::wallbuy( ( 0, 90, 0 ), ( 11452, 8692, -521 ), "mp5k_zm_fx", "mp5k_zm", "t6_wpn_smg_mp5_world", "mp5", "weapon_upgrade" );
	//wallbuy( ( 0, 180, 0 ), ( -4280, -7486, -5 ), "bowie_knife_zm_fx", "bowie_knife_zm", "world_knife_bowie", "bowie_knife", "bowie_upgrade" );
}

init_barriers()
{
	scripts/zm/grief/gametype_modules/_gametype_setup::barrier( ( 9965, 8133, -556 ), "veh_t6_civ_60s_coupe_dead", ( 15, 5, 0 ) );
	scripts/zm/grief/gametype_modules/_gametype_setup::barrier( ( 9955, 8105, -575 ), "collision_player_wall_256x256x10", ( 0, 0, 0 ) );
	scripts/zm/grief/gametype_modules/_gametype_setup::barrier( ( 10056, 8350, -584 ), "veh_t6_civ_bus_zombie", ( 0, 340, 0 ), 1 );
	scripts/zm/grief/gametype_modules/_gametype_setup::barrier( ( 10267, 8194, -556 ), "collision_player_wall_256x256x10", ( 0, 340, 0 ) );
	scripts/zm/grief/gametype_modules/_gametype_setup::barrier( ( 10409, 8220, -181 ), "collision_player_wall_512x512x10", ( 0, 250, 0 ) );
	scripts/zm/grief/gametype_modules/_gametype_setup::barrier( ( 10409, 8220, -556 ), "collision_player_wall_128x128x10", ( 0, 250, 0 ) );
	scripts/zm/grief/gametype_modules/_gametype_setup::barrier( ( 10281, 7257, -575 ), "veh_t6_civ_microbus_dead", ( 0, 13, 0 ) );
	scripts/zm/grief/gametype_modules/_gametype_setup::barrier( ( 10268, 7294, -569 ), "collision_player_wall_256x256x10", ( 0, 13, 0 ) );
	scripts/zm/grief/gametype_modules/_gametype_setup::barrier( ( 10100, 7238, -575 ), "veh_t6_civ_60s_coupe_dead", ( 0, 52, 0 ) );
	scripts/zm/grief/gametype_modules/_gametype_setup::barrier( ( 10170, 7292, -505 ), "collision_player_wall_128x128x10", ( 0, 140, 0 ) );
	scripts/zm/grief/gametype_modules/_gametype_setup::barrier( ( 10030, 7216, -569 ), "collision_player_wall_256x256x10", ( 0, 49, 0 ) );
	scripts/zm/grief/gametype_modules/_gametype_setup::barrier( ( 10563, 8630, -344 ), "collision_player_wall_256x256x10", ( 0, 270, 0 ) );
}

falling_death_init()
{
	trig = getent( "transit_falling_death", "targetname" );
	if ( isDefined( trig ) )
	{
		while ( true )
		{
			trig waittill( "trigger", who );
			if ( !is_true( who.insta_killed ) )
			{
				who thread insta_kill_player();
			}
		}
	}
}

insta_kill_player()
{
	self endon( "disconnect" );
	if ( is_true( self.insta_killed ) )
	{
		return;
	}
	self maps/mp/zombies/_zm_buildables::player_return_piece_to_original_spawn();
	if ( is_player_killable( self ) )
	{
		self playsoundtoplayer( "falling_death", self );
		self.insta_killed = 1;
		in_last_stand = 0;
		if ( self maps/mp/zombies/_zm_laststand::player_is_in_laststand() )
		{
			in_last_stand = 1;
		}
		if ( getnumconnectedplayers() == 1 )
		{
			if ( isDefined( self.lives ) && self.lives > 0 )
			{
				self.waiting_to_revive = 1;
				points = getstruct( "zone_pcr", "script_noteworthy" );
				spawn_points = getstructarray( points.target, "targetname" );
				point = spawn_points[ 0 ];
				self dodamage( self.health + 1000, ( 0, 0, 0 ) );
				maps/mp/_visionset_mgr::vsmgr_activate( "overlay", "zm_transit_burn", self, 1, level.zm_transit_burn_max_duration );
				wait 0.5;
				self freezecontrols( 1 );
				wait 0.25;
				self setorigin( point.origin + vectorScale( ( 0, 0, 1 ), 20 ) );
				self.angles = point.angles;
				if ( in_last_stand )
				{
					flag_set( "instant_revive" );
					wait_network_frame();
					flag_clear( "instant_revive" );
				}
				else
				{
					self thread maps/mp/zombies/_zm_laststand::auto_revive( self );
					self.waiting_to_revive = 0;
					self.solo_respawn = 0;
					self.lives = 0;
				}
				self freezecontrols( 0 );
				self.insta_killed = 0;
			}
			else
			{
				self dodamage( self.health + 1000, ( 0, 0, 0 ) );
				maps/mp/_visionset_mgr::vsmgr_activate( "overlay", "zm_transit_burn", self, 2, level.zm_transit_burn_max_duration );
			}
		}
		else
		{
			self dodamage( self.health + 1000, ( 0, 0, 0 ) );
			maps/mp/_visionset_mgr::vsmgr_activate( "overlay", "zm_transit_burn", self, 1, level.zm_transit_burn_max_duration );
			wait_network_frame();
			self.bleedout_time = 0;
		}
		self notify( "burned" );
		self.insta_killed = 0;
	}
}

is_player_killable( player, checkignoremeflag )
{
	if ( !isDefined( player ) )
	{
		return 0;
	}
	if ( !isalive( player ) )
	{
		return 0;
	}
	if ( !isplayer( player ) )
	{
		return 0;
	}
	if ( player.sessionstate == "spectator" )
	{
		return 0;
	}
	if ( player.sessionstate == "intermission" )
	{
		return 0;
	}
	if ( isDefined( checkignoremeflag ) && player.ignoreme )
	{
		return 0;
	}
	return 1;
}