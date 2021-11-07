#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/zombies/_zm_laststand;
#include maps/mp/zombies/_zm;
#include scripts/zm/promod/_teams;
#include maps/mp/zombies/_zm_perks;
#include scripts/zm/promod/utility/_text_parser;

/*public*/ array_validate( array )
{
	return isDefined( array ) && isArray( array ) && array.size > 0;
}

/*public*/ add_struct( s_struct )
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
	if ( isDefined( s_struct.script_noteworthy ) )
	{
		if ( !isDefined( level.struct_class_names[ "script_noteworthy" ][ s_struct.script_noteworthy ] ) )
		{
			level.struct_class_names[ "script_noteworthy" ][ s_struct.script_noteworthy ] = [];
		}
		size = level.struct_class_names[ "script_noteworthy" ][ s_struct.script_noteworthy ].size;
		level.struct_class_names[ "script_noteworthy" ][ s_struct.script_noteworthy ][ size ] = s_struct;
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

/*public*/ emptyLobbyRestart()
{
	level endon( "end_game" );
	while ( 1 )
	{
		players = getPlayers();
		if ( players.size > 0 )
		{
			while ( 1 )
			{
				players = getPlayers();
				if ( players.size < 1  )
				{
					map_restart( false );
				}
				wait 1;
			}
		}
		wait 1;
	}
}

/*public*/ kill_all_zombies()
{
	zombies = getaispeciesarray( level.zombie_team, "all" );
	for ( i = 0; i < zombies.size; i++ )
	{
		if ( isDefined( zombies[ i ] ) && isAlive( zombies[ i ] ) )
		{
			zombies[ i ] scripts/zm/promod/zgriefp_overrides::zombie_head_gib_o();
			zombies[ i ] dodamage( zombies[ i ].health + 666, zombies[ i ].origin );
			wait randomfloatrange( 0.10, 0.30 );
		}
	}
}

/*public*/ afk_kick()
{   
	level endon( "game_ended" );
	self endon("disconnect");
	if ( self.grief_is_admin )
	{
		return;
	}
	time = 0;
	while( 1 )
	{   
		if ( self.sessionstate == "spectator" || level.players.size <= 2 )
		{	
			wait 1;
			continue;
		}
		if( self usebuttonpressed() || self jumpbuttonpressed() || self meleebuttonpressed() || self attackbuttonpressed() || self adsbuttonpressed() || self sprintbuttonpressed() )
		{
			time = 0;
		}
		if( time == 3600 ) //3mins
		{
			//say( clean_player_name_of_clantag( self.name ) + " has been kicked for inactivity!" );
			kick( self getEntityNumber() );
		}

		wait 0.05;
		time++;
	}
}

/*public*/ get_map_display_name_from_location( location )
{
	switch ( location )
	{
		case "transit":
			return "Bus Depot";
		case "town":
			return "Town";
		case "farm":
			return "Farm";
		case "diner":
			return "Diner";
		case "Power":
			return "Power";
		case "cornfield":
			return "Cornfield";
		case "Tunnel":
			return "Tunnel";
		case "cellblock":
			return "Cellblock";
		case "street":
			return "Buried";
	}
	return "NULL";
}

/*public*/ get_loser( winner )
{
	if ( winner == "axis" )
	{
		return "allies";
	}
	return "axis";
} 

/*public*/ all_surviving_players_invulnerable()
{
	players = getPlayers();
	foreach ( player in players )
	{
		if ( is_player_valid( player ) )
		{
			player enableInvulnerability();
		}
	}
}

/*public*/ all_surviving_players_vulnerable()
{
	players = getPlayers();
	foreach ( player in players )
	{
		if ( is_player_valid( player ) )
		{
			player disableInvulnerability();
		}
	}
}

/*public*/ respawn_players()
{
	players = getPlayers();
	foreach ( player in players )
	{
		if ( player.sessionstate == "spectator" || player player_is_in_laststand() )
		{
			player [[ level.spawnplayer ]]();
			if ( !flag( "game_start" ) )
			{
				player freezeControls( 1 );
			}
		}
	}
}

get_other_team( team )
{
	if ( team == "allies" )
	{
		return "axis";
	}
	else if ( team == "axis" )
	{
		return "allies";
	}
	else
	{
		return "allies";
	}
}

unfreeze_all_players_controls()
{
	players = getPlayers();
	foreach ( player in players )
	{
		player freezeControls( 0 );
	}
}

/*public*/ respawn_spectators_and_freeze_players()
{
	players = getPlayers();
	foreach ( player in players )
	{
		if ( player.sessionstate == "spectator" )
		{
			if ( isDefined( player.spectate_hud ) )
			{
				player.spectate_hud destroy();
			}
			player [[ level.spawnplayer ]]();
		}
		player freeze_player_controls( 1 );
	}
}

/*public*/ make_super_sprinter( special_movespeed )
{
	self.zombie_move_speed = "sprint";
	while ( 1 )
	{
		if ( self in_enabled_playable_area() )
		{
			self.zombie_move_speed = special_movespeed;
			self notify( "zombie_movespeed_set" );
			break;
		}
		wait 0.05;
	}
}

/*public*/ cast_to_vector( vector_string )
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

/*public*/ init_player_session_data()
{
	if ( !isDefined( level.players_in_session ) )
	{
		level.players_in_session = [];
	}
	if ( !isDefined( level.players_in_session[ self.name ] ) )
	{
		level.players_in_session[ self.name ] = spawnStruct();
		if ( level.grief_gamerules[ "use_preset_teams" ] )
		{
			level.players_in_session[ self.name ].sessionteam = self check_for_predefined_team();
		}
		else 
		{
			level.players_in_session[ self.name ].sessionteam = undefined;
		}
		key_names = "tier|names|guids|cmds|privileges";
		level.players_in_session[ self.name ].team_change_timer = 0;
		level.players_in_session[ self.name ].team_changed_times = 0;
		level.players_in_session[ self.name ].team_change_ban = false;
		//level.players_in_session[ self.name ].server_rank_system = [];
		// level.players_in_session[ self.name ].server_rank_system[ "rank" ] = self get_server_privileges_rank();
		//level.players_in_session[ self.name ].server_rank_system[ "cmds" ] = self get_server_privileges_cmds();
		// level.players_in_session[ self.name ].server_rank_system[ "privileges" ] = [];
		// level.players_in_session[ self.name ].server_rank_system[ "privileges" ][ "cmd_cooldown" ] = 0;
		level.players_in_session[ self.name ].command_cooldown = 0;
		// level.players_in_session[ self.name ].entity_num = self getEntityNumber();
		// level.players_in_session[ self.name ].GUID = self getGUID();
	}
}

//(owner,all,all);
//(admin,...,...);
//(moderator,...,...);
//(trusted,...,...);
//(default,...,...);

/*public*/ add_random_sound( group, sound, percent_chance )
{
	if ( !isDefined( level.random_sounds ) )
	{
		level.random_sounds = [];
	}
	if ( !isDefined( level.random_sounds[ group ] ) )
	{
		level.random_sounds[ group ] = [];
	}
	level.random_sounds[ group ][ sound ] = percent_chance;
}

/*public*/ play_random_sound_from_group( group, origin )
{
	if ( !isDefined( level.random_sounds[ group ] ) )
	{
		return;
	}
	sounds = getArrayKeys( level.random_sounds[ group ] );
	random_int = randomInt( 100 );
	sounds_can_play = [];
	foreach ( sound in sounds )
	{
		if ( level.random_sounds[ group ][ sound ] >= random_int )
		{
			sounds_can_play[ sounds_can_play.size ] = sound;
		}
	}
	if ( sounds_can_play.size > 0 )
	{
		sound_to_play = random( sounds_can_play );
	}
	else 
	{
		return;
	}
	if ( isDefined( origin ) )
	{
		playSoundAtPosition( sound_to_play, origin );
	}
	else if ( isDefined( self ) && isPlayer( self ) )
	{
		self playLocalSound( sound_to_play );
	}
}

/*public*/ zombie_spawn_delay_fix()
{
	i = 1;
	while ( i <= level.grief_gamerules[ "zombie_round" ] )
	{
		timer = level.zombie_vars[ "zombie_spawn_delay" ];
		if ( timer > 0.08 )
		{
			level.zombie_vars[ "zombie_spawn_delay" ] = timer * 0.95;
			i++;
			continue;
		}
		if ( timer < 0.08 )
		{
			level.zombie_vars[ "zombie_spawn_delay" ] = 0.08;
			break;
		}
		i++;
	}
}

/*public*/ zombie_speed_fix()
{
	if ( level.gamedifficulty == 0 )
	{
		level.zombie_move_speed = level.grief_gamerules[ "zombie_round" ] * level.zombie_vars[ "zombie_move_speed_multiplier_easy" ];
	}
	else
	{
		level.zombie_move_speed = level.grief_gamerules[ "zombie_round" ] * level.zombie_vars[ "zombie_move_speed_multiplier" ];
	}
}

/*public*/ toggle_perk_power( new_power_state )
{
	if ( new_power_state )
	{
		for ( i = 0; i < level.data_maps[ "perks" ][ "power_notifies" ].size; i++ )
		{
			level notify( level.data_maps[ "perks" ][ "power_notifies" ][ i ] + "_on" );
		}
	}
	else 
	{
		for ( i = 0; i < level.data_maps[ "perks" ][ "power_notifies" ].size; i++ )
		{
			level notify( level.data_maps[ "perks" ][ "power_notifies" ][ i ] + "_off" );
		}
	}
}

server_safe_notify_thread( notify_name, index )
{
	wait( level.SERVER_FRAME * index );
	level notify( notify_name );
}