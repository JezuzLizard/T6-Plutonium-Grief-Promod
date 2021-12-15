#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/zombies/_zm;
#include maps/mp/gametypes_zm/_spectating;
#include maps/mp/zombies/_zm_perks;

onspawnplayerunified()
{
	onspawnplayer( 0 );
}

onspawnplayer( predictedspawn )
{
	if ( !isDefined( predictedspawn ) )
	{
		predictedspawn = 0;
	}
	pixbeginevent( "ZSURVIVAL:onSpawnPlayer" );
	self.usingobj = undefined;
	self.is_zombie = 0;
	if ( is_true( self.player_initialized ) )
	{
		self grief_spectator_respawn();
		return;
	}
	match_string = "";
	location = level.scr_zm_map_start_location;
	if ( ( location == "default" || location == "" ) && isDefined( level.default_start_location ) )
	{
		location = level.default_start_location;
	}
	match_string = level.scr_zm_ui_gametype + "_" + location;
	spawnpoints = [];
	structs = getstructarray( "initial_spawn", "script_noteworthy" );
	if ( isdefined( structs ) )
	{
		for ( i = 0; i < structs.size; i++ )
		{
			if ( isdefined( structs[ i ].script_string ) )
			{
				tokens = strtok( structs[ i ].script_string, " " );
				foreach ( token in tokens )
				{
					if ( token == match_string )
					{
						spawnpoints[ spawnpoints.size ] = structs[ i ];
					}
				}
			}
		}
	}
	if ( !isDefined( spawnpoints ) || spawnpoints.size == 0 )
	{
		spawnpoints = getstructarray( "initial_spawn_points", "targetname" );
	}	
	level.initial_spawnpoints = spawnpoints;
	spawnpoint = getfreespawnpoint( spawnpoints, self );
	if ( predictedspawn )
	{
		self predictspawnpoint( spawnpoint.origin, spawnpoint.angles );
		return;
	}
	else
	{
		self spawn( spawnpoint.origin, spawnpoint.angles, "zsurvival" );
	}
	self.entity_num = self getentitynumber();
	self thread onplayerspawned();
	self thread maps/mp/zombies/_zm::player_revive_monitor();
	self freezecontrols( 1 );
	self.spectator_respawn = spawnpoint;
	self.score = self maps/mp/gametypes_zm/_globallogic_score::getpersstat( "score" );
	self.pers[ "participation" ] = 0;
	self.score_total = self.score;
	self.old_score = self.score;
	self.player_initialized = 0;
	self.zombification_time = 0;
	self.enabletext = 1;
	self thread maps/mp/zombies/_zm_blockers::rebuild_barrier_reward_reset();
	if ( should_spawn_as_spectator() )
	{
		self delay_thread( 0.05, maps/mp/zombies/_zm::spawnspectator );
	}
	else if ( is_true( level.in_grief_pre_round ) )
	{
		self freezecontrols( 0 );
	}
	else 
	{
		self enableweapons();
	}
	pixendevent();
}


get_player_spawns_for_gametype_override()
{
	match_string = "";
	location = level.scr_zm_map_start_location;
	if ( ( location == "default" || location == "" ) && isDefined( level.default_start_location ) )
	{
		location = level.default_start_location;
	}
	match_string = level.scr_zm_ui_gametype + "_" + location;
	player_spawns = [];
	structs = getstructarray("player_respawn_point", "targetname");
	i = 0;
	while ( i < structs.size )
	{
		if ( isdefined( structs[ i ].script_string ) )
		{
			tokens = strtok( structs[ i ].script_string, " " );
			foreach ( token in tokens )
			{
				if ( token == match_string )
				{
					player_spawns[ player_spawns.size ] = structs[ i ];
				}
			}
			i++;
			continue;
		}
		player_spawns[ player_spawns.size ] = structs[ i ];
		i++;
	}
	return player_spawns;
}

grief_spectator_respawn()
{
	origin = self.spectator_respawn.origin;
	angles = self.spectator_respawn.angles;
	self setspectatepermissions( 0 );
	self spawn( origin, angles );
	if ( isDefined( self get_player_placeable_mine() ) )
	{
		self takeweapon( self get_player_placeable_mine() );
		self set_player_placeable_mine( undefined );
	}
	self maps/mp/zombies/_zm_equipment::equipment_take();
	self.is_burning = undefined;
	self.abilities = [];
	self.is_zombie = 0;
	self.ignoreme = 0;
	setclientsysstate( "lsm", "0", self );
	self reviveplayer();
	self notify( "spawned_player" );
	if ( isDefined( level._zombiemode_post_respawn_callback ) )
	{
		self thread [[ level._zombiemode_post_respawn_callback ]]();
	}
	self maps/mp/zombies/_zm_score::player_reduce_points( "died" );
	self maps/mp/zombies/_zm_melee_weapon::spectator_respawn_all();
	claymore_triggers = getentarray( "claymore_purchase", "targetname" );
	i = 0;
	while ( i < claymore_triggers.size )
	{
		claymore_triggers[ i ] setvisibletoplayer( self );
		claymore_triggers[ i ].claymores_triggered = 0;
		i++;
	}
	self thread player_zombie_breadcrumb();
	self thread return_retained_perks();
	return 1;
}

getfreespawnpoint( spawnpoints, player )
{
	assign_spawnpoints_player_data( spawnpoints, player );
	for ( j = 0; j < spawnpoints.size; j++ )
	{
		if ( spawnpoints[ j ].player_property == player.name )
		{
			return spawnpoints[ j ];
		}
	}
}

assign_spawnpoints_player_data( spawnpoints, player )
{
	remove_disconnected_players_spawnpoint_property( spawnpoints );
	for ( i = 0; i < spawnpoints.size; i++ )
	{
		if ( spawnpoints[ i ].player_property == "" )
		{
			spawnpoints[ i ].player_property = player.name;
			break;
		}
	}
}

remove_disconnected_players_spawnpoint_property( spawnpoints )
{
	for ( i = 0; i < spawnpoints.size; i++ )
	{
		spawnpoints[ i ].do_not_discard_player_property = false;
	}
	players = getPlayers();
	for ( i = 0; i < spawnpoints.size; i++ )
	{
		if ( isDefined( spawnpoints[ i ].player_property ) )
		{
			for ( j = 0; j < players.size; j++ )
			{
				if ( spawnpoints[ i ].player_property == players[ j ].name )
				{
					spawnpoints[ i ].do_not_discard_player_property = true;
					break;
				}
			}
		}
	}
	for ( i = 0; i < spawnpoints.size; i++ )
	{
		if ( !spawnpoints[ i ].do_not_discard_player_property )
		{
			spawnpoints[ i ].player_property = "";
		}
	}
}

should_spawn_as_spectator()
{
	if ( !flag( "spawn_players" ) )
	{
		return true;
	}
	return false;
}

onplayerspawned() //checked matches cerberus output
{
	self endon( "disconnect" );
	self notify( "stop_onPlayerSpawned" );
	self endon( "stop_onPlayerSpawned" );
	for ( ;; )
	{
		self waittill( "spawned_player" );
		if ( is_true( level.in_grief_pre_round ) )
		{
			self freezecontrols( 0 );
		}
		else 
		{
			self freezecontrols( 1 );
		}
		self.hits = 0;
		self init_player_offhand_weapons();
		lethal_grenade = self get_player_lethal_grenade();
		if ( !self hasweapon( lethal_grenade ) )
		{
			self giveweapon( lethal_grenade );
			self setweaponammoclip( lethal_grenade, 0 );
		}
		self recordplayerrevivezombies( self );
		self setactionslot( 3, "altMode" );
		self playerknockback( 0 );
		self setclientthirdperson( 0 );
		self resetfov();
		self setclientthirdpersonangle( 0 );
		self setdepthoffield( 0, 0, 512, 4000, 4, 0 );
		self cameraactivate( 0 );
		self.num_perks = 0;
		self.on_lander_last_stand = undefined;
		self setblur( 0, 0.1 );
		self.zmbdialogqueue = [];
		self.zmbdialogactive = 0;
		self.zmbdialoggroups = [];
		self.zmbdialoggroup = "";
		if ( is_true( level.player_out_of_playable_area_monitor ) )
		{
			self thread player_out_of_playable_area_monitor();
		}
		if ( is_true( level.player_too_many_weapons_monitor ) )
		{
			self thread [[ level.player_too_many_weapons_monitor_func ]]();
		}
		self.disabled_perks = [];
		if ( isDefined( self.player_initialized ) )
		{
			if ( self.player_initialized == 0 )
			{
				self.player_initialized = 1;
				self giveweapon( self get_player_lethal_grenade() );
				self setweaponammoclip( self get_player_lethal_grenade(), 0 );
				self setclientammocounterhide( 0 );
				self setclientminiscoreboardhide( 0 );
				self.is_drinking = 0;
				self thread player_zombie_breadcrumb();
				self thread player_monitor_travel_dist();
				self thread player_monitor_time_played();
				if ( isDefined( level.custom_player_track_ammo_count ) )
				{
					self thread [[ level.custom_player_track_ammo_count ]]();
				}
				else
				{
					self thread player_track_ammo_count();
				}
				self thread shock_onpain();
				self thread player_grenade_watcher();
				self maps/mp/zombies/_zm_laststand::revive_hud_create();
				if ( isDefined( level.zm_gamemodule_spawn_func ) )
				{
					self thread [[ level.zm_gamemodule_spawn_func ]]();
				}
				self thread player_spawn_protection();
				if ( !isDefined( self.lives ) )
				{
					self.lives = 0;
				}
				self.score_lost_when_downed = 0;
				self thread give_player_melee_weapon();
			}
		}
	}
}

give_player_melee_weapon()
{
	if ( !level.grief_gamerules[ "melee_weapon_on_spawn" ] )
	{
		return;
	}
	self waittill( "controls_unfrozen");
	trigger = getentarray( "tazer_upgrade", "targetname" )[0];
	mapname = getDvar( "mapname" );
	if( mapname != "zm_prison" || mapname != "zm_tomb" )
	{
		self thread maps\mp\zombies\_zm_melee_weapon::give_melee_weapon( "tazerknuckles", "zombie_tazer_flourish", "tazer_knuckles_zm", "knife_ballistic_no_melee_zm", "knife_ballistic_no_melee_upgraded_zm", ::tazer_flourish_fx, trigger );
	}
}

tazer_flourish_fx()
{
	self waittill( "weapon_change", newweapon );
	if ( newweapon == "zombie_tazer_flourish" )
	{
		self endon( "weapon_change" );
		wait level.tazer_flourish_delay;
		self thread maps/mp/zombies/_zm_audio::playerexert( "hitmed" );
		self setclientfieldtoplayer( "tazer_flourish", 1 );
		wait_network_frame();
		self setclientfieldtoplayer( "tazer_flourish", 0 );
	}
}