#include common_scripts/utility;
#include maps/mp/zombies/_zm_powerups;
#include maps/mp/gametypes_zm/_gameobjects;
#include scripts/T6_objective_api_main;

get_powerups_allowed()
{
	powerups_allowed = [];
	for ( i = 0; i < level.data_maps[ "powerups" ][ "names" ].size; i++ )
	{
		if ( level.data_maps[ "powerups" ][ "allowed" ][ i ] == "1" )
		{
			powerups_allowed[ powerups_allowed.size ] = level.data_maps[ "powerups" ][ "names" ][ i ];
		}
	}
	return powerups_allowed;
}

powerup_drop_override( drop_point ) //checked partially changed to match cerberus output
{
	return; //Disables vanilla powerup system entirely.
	// if ( level.powerup_drop_count >= level.zombie_vars[ "zombie_powerup_drop_max_per_round" ] )
	// {
	// 	return;
	// }
	// if ( !isDefined( level.zombie_include_powerups ) || level.zombie_include_powerups.size == 0 )
	// {
	// 	return;
	// }
	// if ( !level.grief_gamerules[ "magic" ] )
	// {
	// 	return;
	// }
	// allowed_powerups = get_powerups_allowed();
	// if ( allowed_powerups.size == 0 )
	// {
	// 	return;
	// }
	// rand_drop = randomint( 100 );
	// if ( rand_drop > 2 )
	// {
	// 	if ( !level.zombie_vars[ "zombie_drop_item" ] )
	// 	{
	// 		return;
	// 	}
	// }
	// playable_area = getentarray( "player_volume", "script_noteworthy" );
	// level.powerup_drop_count++;
	// powerup = maps/mp/zombies/_zm_net::network_safe_spawn( "powerup", 1, "script_model", drop_point + ( 0, 0, 40 ) );
	// valid_drop = 0;
	// for ( i = 0; i < playable_area.size; i++ )
	// {
	// 	if ( powerup istouching( playable_area[ i ] ) )
	// 	{
	// 		valid_drop = 1;
	// 		break;
	// 	}
	// }
	// if ( valid_drop && level.rare_powerups_active )
	// {
	// 	pos = ( drop_point[ 0 ], drop_point[ 1 ], drop_point[ 2 ] + 42 );
	// 	if ( check_for_rare_drop_override( pos ) )
	// 	{
	// 		level.zombie_vars[ "zombie_drop_item" ] = 0;
	// 		valid_drop = 0;
	// 	}
	// }
	// if ( !valid_drop )
	// {
	// 	level.powerup_drop_count--;

	// 	powerup delete();
	// 	return;
	// }
	// powerup powerup_setup( random( allowed_powerups ) );
	// powerup thread powerup_timeout();
	// powerup thread powerup_wobble();
	// powerup thread powerup_grab();
	// powerup thread powerup_move();
	// powerup thread powerup_emp();
	// level.zombie_vars[ "zombie_drop_item" ] = 0;
	// level notify( "powerup_dropped", powerup );
}

create_powerup_objective( powerup_name, drop_spot, powerup_team, powerup_location ) //checked partially changed to match cerberus output
{
	powerup = maps/mp/zombies/_zm_net::network_safe_spawn( "powerup", 1, "script_model", drop_spot + ( 0, 0, 40 );
	if ( isDefined( powerup ) )
	{
		level notify( "powerup_dropped", powerup );
		powerup powerup_setup( powerup_name, powerup_team, powerup_location );
		powerup thread powerup_timeout();
		powerup thread powerup_wobble();
		powerup powerup_objective_setup();
		//powerup thread powerup_grab( powerup_team );
		//powerup thread powerup_move();
		//powerup thread powerup_emp();
		return powerup;
	}
}

// powerup_setup( powerup_override, powerup_team, powerup_location ) //checked partially changed to match cerberus output
// {
// 	powerup = powerup_override;
// 	struct = level.zombie_powerups[ powerup ];
// 	self setmodel( struct.model_name );
// 	playsoundatposition( "zmb_spawn_powerup", self.origin );
// 	if ( isDefined( powerup_team ) )
// 	{
// 		self.powerup_team = powerup_team;
// 	}
// 	if ( isDefined( powerup_location ) )
// 	{
// 		self.powerup_location = powerup_location;
// 	}
// 	self.powerup_name = struct.powerup_name;
// 	self.hint = struct.hint;
// 	self.solo = struct.solo;
// 	self.caution = struct.caution;
// 	self.zombie_grabbable = struct.zombie_grabbable;
// 	self.func_should_drop_with_regular_powerups = struct.func_should_drop_with_regular_powerups;
// 	if ( isDefined( struct.fx ) )
// 	{
// 		self.fx = struct.fx;
// 	}
// 	if ( isDefined( struct.can_pick_up_in_last_stand ) )
// 	{
// 		self.can_pick_up_in_last_stand = struct.can_pick_up_in_last_stand;
// 	}
// 	self playloopsound( "zmb_spawn_powerup_loop" );
// 	level.active_powerups[ level.active_powerups.size ] = self;
// }

// powerup_timeout() //checked partially changed to match cerberus output
// {
// 	if ( isDefined( level._powerup_timeout_override ) && !isDefined( self.powerup_team ) )
// 	{
// 		self thread [[ level._powerup_timeout_override ]]();
// 		return;
// 	}
// 	self endon( "powerup_grabbed" );
// 	self endon( "death" );
// 	self endon( "powerup_reset" );
// 	self show();
// 	wait_time = 15;
// 	if ( isDefined( level._powerup_timeout_custom_time ) )
// 	{
// 		time = [[ level._powerup_timeout_custom_time ]]( self );
// 		if ( time == 0 )
// 		{
// 			return;
// 		}
// 		wait_time = time;
// 	}
// 	wait wait_time;
// 	i = 0;
// 	while ( i < 40 )
// 	{
// 		if ( i % 2 )
// 		{
// 			self ghost();
// 			if ( isDefined( self.worldgundw ) )
// 			{
// 				self.worldgundw ghost();
// 			}
// 		}
// 		else
// 		{
// 			self show();
// 			if ( isDefined( self.worldgundw ) )
// 			{
// 				self.worldgundw show();
// 			}
// 		}
// 		if ( i < 15 )
// 		{
// 			wait 0.5;
// 			i++;
// 			continue;
// 		}
// 		if ( i < 25 )
// 		{
// 			wait 0.25;
// 			i++;
// 			continue;
// 		}
// 		wait 0.1;
// 		i++;
// 	}
// 	self notify( "powerup_timedout" );
// 	self powerup_delete();
// }

// powerup_wobble_fx() //checked matches cerberus output
// {
// 	self endon( "death" );
// 	if ( !isDefined( self ) )
// 	{
// 		return;
// 	}
// 	if ( isDefined( level.powerup_fx_func ) )
// 	{
// 		self thread [[ level.powerup_fx_func ]]();
// 		return;
// 	}
// 	if ( self.solo )
// 	{
// 		self setclientfield( "powerup_fx", 2 );
// 	}
// 	else if ( self.caution )
// 	{
// 		self setclientfield( "powerup_fx", 4 );
// 	}
// 	else if ( self.zombie_grabbable )
// 	{
// 		self setclientfield( "powerup_fx", 3 );
// 	}
// 	else
// 	{
// 		self setclientfield( "powerup_fx", 1 );
// 	}
// }

// powerup_grab(powerup_team) //checked partially changed to match cerberus output
// {
// 	// self endon ( "powerup_timedout" );
// 	// self endon ( "powerup_grabbed" );

// 	range_squared = 4096;
// 	while ( isdefined( self ) )
// 	{
// 		players = get_players();
// 		i = 0;
// 		while ( i < players.size )
// 		{
// 			// Don't let them grab the minigun, tesla, or random weapon if they're downed or reviving
// 			//	due to weapon switching issues.
// 			if ( ( players[ i ] maps/mp/zombies/_zm_laststand::player_is_in_laststand() )
// 			{
// 				i++;
// 				continue;
// 			}
// 			ignore_range = 0;
// 			if ( DistanceSquared( players[ i ].origin, self.origin ) < range_squared || ignore_range )
// 			{
// 				switch ( self.powerup_name )
// 				{
// 					case "nuke":
// 						level thread nuke_powerup( self, players[ i ].team );
// 						players[ i ] thread powerup_vo( "nuke" );
// 						zombies = getaiarray( level.zombie_team );
// 						players[ i ].zombie_nuked = arraysort( zombies, self.origin );
// 						players[ i ] notify( "nuke_triggered" );
// 						break;
// 					case "full_ammo":
// 						level thread full_ammo_powerup( self ,players[ i ] );
// 						players[ i ] thread powerup_vo( "full_ammo" );
// 						break;
// 					case "double_points":
// 						level thread double_points_powerup( self, players[ i ] );
// 						players[ i ] thread powerup_vo( "double_points" );
// 						break;
// 					case "insta_kill":
// 						level thread insta_kill_powerup( self,players[ i ] );
// 						players[ i ] thread powerup_vo( "insta_kill" );
// 						break;
// 					case "fire_sale":
// 						level thread start_fire_sale( self );
// 						players[ i ] thread powerup_vo( "firesale" );
// 						break;
// 					case "bonfire_sale":
// 						level thread start_bonfire_sale( self );
// 						players[ i ] thread powerup_vo( "firesale" );
// 						break;	
// 					case "minigun":
// 						level thread minigun_weapon_powerup( players[ i ] );
// 						players[ i ] thread powerup_vo( "minigun" );
// 						break;
// 					case "free_perk":
// 						level thread free_perk_powerup( self );
// 						break;
// 					case "bonus_points_player":
// 						level thread bonus_points_player_powerup( self, players[ i ] );
// 						players[ i ] thread powerup_vo( "bonus_points_solo" ); 
// 						break;
// 					case "bonus_points_team":
// 						level thread bonus_points_team_powerup( self );
// 						players[ i ] thread powerup_vo( "bonus_points_team" ); 
// 						break;
// 				}
// 				if ( self.solo )
// 				{
// 					playfx( level._effect[ "powerup_grabbed_solo" ], self.origin );
// 					playfx( level._effect[ "powerup_grabbed_wave_solo" ], self.origin );
// 				}
// 				else if ( self.caution )
// 				{
// 					playfx( level._effect[ "powerup_grabbed_caution" ], self.origin );
// 					playfx( level._effect[ "powerup_grabbed_wave_caution" ], self.origin );
// 				}
// 				else
// 				{
// 					playfx( level._effect[ "powerup_grabbed" ], self.origin );
// 					playfx( level._effect[ "powerup_grabbed_wave" ], self.origin );
// 				}
// 				if ( isdefined( self.grabbed_level_notify ) )
// 				{
// 					level notify( self.grabbed_level_notify );
// 				}

// 				// RAVEN BEGIN bhackbarth: since there is a wait here, flag the powerup as being taken 
// 				self.claimed = true;
// 				self.power_up_grab_player = players[ i ]; //Player who grabbed the power up
// 				// RAVEN END

// 				wait 0.1 ;
				
// 				playsoundatposition("zmb_powerup_grabbed", self.origin);
// 				self stoploopsound();
// 				self hide();
				
// 				//Preventing the line from playing AGAIN if fire sale becomes active before it runs out
// 				if ( self.powerup_name != "fire_sale" )
// 				{
// 					if ( isdefined( self.power_up_grab_player ) )
// 					{
// 						if ( isdefined( level.powerup_intro_vox ) )
// 						{
// 							level thread [[ level.powerup_intro_vox ]]( self );
// 							return;
// 						}
// 						else if ( isdefined( level.powerup_vo_available ) )
// 						{
// 							can_say_vo = [[ level.powerup_vo_available ]]();
// 							if ( !can_say_vo )
// 							{
// 								self powerup_delete();
// 								self notify( "powerup_grabbed" );
// 								return;
// 							}
// 						}
// 					}
// 				}
// 				level thread maps/mp/zombies/_zm_audio_announcer::leaderdialog( self.powerup_name, self.power_up_grab_player.pers[ "team" ] );
// 				self powerup_delete();
// 				self notify( "powerup_grabbed" );
// 			}
// 			i++;
// 		}
// 		wait 0.1;
// 	}
// }

powerup_objective_setup()
{
	trigger = spawn( "trigger_radius_use", ( 0, 0, 0 ), 0, 32, 32 );
	trigger sethintstring( "" );
	trigger setcursorhint( "HINT_NOICON" );
	trigger.origin = self.origin;
	powerup_obj = createuseobject( trigger, ( 0, 0, 1 ) );
	powerup_obj maps/mp/gametypes_zm/_gameobjects::allowuse( "any" ); //Any player on any team can use this objective.
	powerup_obj maps/mp/gametypes_zm/_gameobjects::setusetime( 3 );
	powerup_obj maps/mp/gametypes_zm/_gameobjects::setusetext( "Press [{+usereload}] to start capturing" );
	powerup_obj maps/mp/gametypes_zm/_gameobjects::setusehinttext( "Hold to capture" );
	powerup_obj.onbeginuse = ::onbeginuse;
	powerup_obj.onuse = ::capture_powerup;
	level.cur_powerup_obj = powerup_obj;
	level.cur_powerup_obj_waypoint = OBJ_CREATE_SERVER_WAYPOINT();
	level.cur_powerup_obj_waypoint setShader( "specialty_instakill_zombies", 4, 4 );
	level.cur_powerup_obj_waypoint setWayPoint( 0 );
	level.cur_powerup_obj_waypoint setTargetEnt( self );
}

createuseobject( trigger, offset ) //checked changed to match cerberus output
{
	useobject = spawnstruct();
	useobject.type = "useObject";
	useobject.curorigin = trigger.origin;
	useobject.entnum = trigger getentitynumber();
	useobject.keyobject = undefined;
	if ( issubstr( trigger.classname, "use" ) )
	{
		useobject.triggertype = "use";
	}
	else
	{
		useobject.triggertype = "proximity";
	}
	useobject.trigger = trigger;
	if ( !isDefined( offset ) )
	{
		offset = ( 0, 0, 0 );
	}
	useobject.interactteam = "none";
	useobject.worldicons = [];
	useobject.visibleteam = "none";
	useobject.worldiswaypoint = [];
	useobject.onuse = undefined;
	useobject.usetext = "default";
	useobject.usetime = 10000;
	useobject clearprogress();
	useobject.decayprogress = 0;
	if ( useobject.triggertype == "proximity" )
	{
		useobject.numtouching[ "neutral" ] = 0;
		useobject.numtouching[ "none" ] = 0;
		useobject.touchlist[ "neutral" ] = [];
		useobject.touchlist[ "none" ] = [];
		foreach ( team in level.teams )
		{
			useobject.numtouching[ team ] = 0;
			useobject.touchlist[ team ] = [];
		}
		useobject.teamusetimes = [];
		useobject.teamusetexts = [];
		useobject.userate = 0;
		useobject.claimteam = "none";
		useobject.claimplayer = undefined;
		useobject.lastclaimteam = "none";
		useobject.lastclaimtime = 0;
		useobject.claimgraceperiod = 1;
		useobject.mustmaintainclaim = 0;
		useobject.cancontestclaim = 0;
		useobject thread useobjectproxthink();
	}
	else
	{
		useobject.userate = 1;
		useobject thread useobjectusethink();
	}
	return useobject;
}

useobjectusethink() //checked changed to match cerberus output
{
	level endon( "game_ended" );
	self.trigger endon( "destroyed" );
	while ( 1 )
	{
		self.trigger waittill( "trigger", player );
		if ( !is_player_valid( player ) )
		{
			continue;
		}
		if ( !self caninteractwith( player ) )
		{
			continue;
		}
		if ( !player isonground() )
		{
			continue;
		}
		result = 1;
		if ( self.usetime > 0 )
		{
			if ( isDefined( self.onbeginuse ) )
			{
				self [[ self.onbeginuse ]]( player );
			}
			team = player.pers[ "team" ];
			result = self useholdthink( player );
		}
		if ( !result )
		{
			continue;
		}
		if ( isDefined( self.onuse ) )
		{
			self [[ self.onuse ]]( player );
		}
	}
}

onbeginuse( player ) //checked changed to match cerberus output
{
}

capture_powerup( player ) //checked partially changed to match cerberus output did not change while loop to for loop see github for more info
{
	self.trigger delete();
	self = undefined;
}

useholdthink( player ) //checked changed to match cerberus output
{
	player notify( "use_hold" );
	if ( !is_true( self.dontlinkplayertotrigger ) )
	{
		player playerlinkto( self.trigger );
		player playerlinkedoffsetenable();
	}
	player clientclaimtrigger( self.trigger );
	player.claimtrigger = self.trigger;
	useweapon = self.useweapon;
	lastweapon = player getcurrentweapon();
	if ( isDefined( useweapon ) )
	{
		if ( lastweapon == useweapon )
		{
			lastweapon = player.lastnonuseweapon;
		}
		player.lastnonuseweapon = lastweapon;
		player giveweapon( useweapon );
		player setweaponammostock( useweapon, 0 );
		player setweaponammoclip( useweapon, 0 );
		player switchtoweapon( useweapon );
	}
	else
	{
		player _disableweapon();
	}
	self clearprogress();
	self.inuse = 1;
	self.userate = 0;
	player thread personalusebar( self );
	result = useholdthinkloop( player, lastweapon );
	if ( isDefined( player ) )
	{
		self clearprogress();
		if ( isDefined( player.attachedusemodel ) )
		{
			player detach( player.attachedusemodel, "tag_inhand" );
			player.attachedusemodel = undefined;
		}
		player notify( "done_using" );
	}
	if ( isDefined( useweapon ) && isDefined( player ) )
	{
		player thread takeuseweapon( useweapon );
	}
	if ( is_true( result ) )
	{
		return 1;
	}
	if ( isDefined( player ) )
	{
		player.claimtrigger = undefined;
		if ( isDefined( useweapon ) )
		{
			ammo = player getweaponammoclip( lastweapon );
			if ( lastweapon != "none" && !maps/mp/killstreaks/_killstreaks::iskillstreakweapon( lastweapon ) && isweaponequipment( lastweapon ) && player getweaponammoclip( lastweapon ) != 0 )
			{
				player switchtoweapon( lastweapon );
			}
			else
			{
				player takeweapon( useweapon );
				player switchtolastnonkillstreakweapon();
			}
		}
		else if ( isalive( player ) )
		{
			player _enableweapon();
		}
		if ( !is_true( self.dontlinkplayertotrigger ) )
		{
			player unlink();
		}
		if ( !isalive( player ) )
		{
			player.killedinuse = 1;
		}
	}
	self.inuse = 0;
	if ( self.trigger.classname == "trigger_radius_use" )
	{
		player clientreleasetrigger( self.trigger );
	}
	else
	{
		self.trigger releaseclaimedtrigger();
	}
	return 0;
}