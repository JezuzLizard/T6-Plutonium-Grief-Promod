
array_validate( array )
{
	return isDefined( array ) && isArray( array ) && array.size > 0;
}

add_struct( s_struct )
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

emptyLobbyRestart()
{
	level endon( "end_game" );
	while ( 1 )
	{
		players = get_players();
		if ( players.size > 0 )
		{
			while ( 1 )
			{
				players = get_players();
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

afk_kick()
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
			say( clean_player_name_of_clantag( self.name ) + " has been kicked for inactivity!" );
			kick( self getEntityNumber() );
		}

		wait 0.05;
		time++;
	}
}

get_mapname()
{
	switch ( getDvar( "ui_zm_mapstartlocation" ) )
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

get_loser( winner )
{
	if ( winner == "A" )
	{
		return "B";
	}
	return "A";
} 

all_surviving_players_invulnerable()
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

all_surviving_players_vulnerable()
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

respawn_players()
{
	players = get_players();
	foreach ( player in players )
	{
		if ( player.sessionstate == "spectator" || player player_is_in_laststand() )
		{
			player [[ level.spawnplayer ]]();
		}
		else if ( !is_true( level.initial_spawn_players ) )
		{
			player [[ level.spawnplayer ]]();
			player freeze_player_controls( 1 );
		}
	}
}

zombie_goto_round( target_round )
{
	level notify( "restart_round" );
	if ( target_round < 1 )
	{
		target_round = 1;
	}
	level.zombie_total = 0;
	maps/mp/zombies/_zm::ai_calculate_health( target_round );
	zombies = get_round_enemy_array();
	if ( isDefined( zombies ) )
	{
		for ( i = 0; i < zombies.size; i++ )
		{
			zombies[ i ] dodamage( zombies[ i ].health + 666, zombies[ i ].origin );
		}
	}
	respawn_players();
	wait 1;
}

respawn_spectators_and_freeze_players()
{
	players = get_players();
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

make_super_sprinter( special_movespeed )
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

add_new_dvar_command( dvar_name, args_string )
{
	if ( !isDefined( level.dvar_commands ) ) 
	{
		level.dvar_commands = [];
	}
	if ( !isDefined( level.dvar_commands[ dvar_name ] ) )
	{
		level.dvar_commands[ dvar_name ] = true;
		setDvar( dvar_name, args_string );
	}
}

add_dvar_commands()
{
	add_new_dvar_command( "dcmd", "" );
}

dvar_command_watcher()
{
	level endon( "end_commands" );
	while ( true )
	{
		dvar_keys = getArrayKeys( level.dvar_commands );
		foreach ( dvar in dvar_keys )
		{
			dvar_value = getDvar( dvar );
			if ( dvar_value != "" )
			{
				level notify( "say", undefined, dvar_value );
				process_dvar_command( dvar, dvar_value );
				setDvar( dvar, "" );
			}
		}
		wait 0.05;
	}
}

process_dvar_command( dvar, value )
{
	command_args = parse_message( value );
	execute_dvar_cmd( command_args[ "namespace" ], command_args[ "cmdname" ], command_args[ "args" ] );
}

remove_tokens_from_array( array, token )
{
	new_tokens = [];
	foreach ( string in array )
	{
		if ( isSubStr( string, token ) )
		{
		}
		else 
		{
			new_tokens[ new_tokens.size ] = string;
		}
	}
	return new_tokens;
}

clean_str( str, tokens )
{
	for ( i = 0; i < tokens.size; i++ )
	{
		new_str = "";
		for ( j = 0; j < str.size; j++ )
		{
			if ( str[ i ] != tokens[ i ] )
			{
				new_str += str[ i ];
			}
		}
	}
	return new_str;
}

//set grief_preset_teams "(player_name,team_name,is_perm,is_banned);(player_name,team_name,is_perm,is_banned) etc"

find_data_from_index( string, index, sub_index )
{
	string_keys = strTok( string, ";" );
	if ( index >= string_keys.size )
	{
		print( "Parsing Error: find_data_from_index() index is out of bounds." );
		return;
	}
	key = string_keys[ index ];
	sub_keys = strTok( key, "," );
	if ( sub_index >= sub_keys.size )
	{
		print( "Parsing Error: find_data_from_index() sub_index is out of bounds." );
		return;
	}
	return clean_str( sub_keys[ sub_index ], "()" );
}

find_data_from_key( string, key, sub_index )
{
	string_keys = strTok( string, ";" );
	if ( index >= string_keys.size )
	{
		print( "Parsing Error: find_data_from_index() index is out of bounds." );
		return;
	}
	for ( i = 0; i < string_keys.size; i++ )
	{
		if ()
	}
}

get_tokens_with_key_value( string, key )
{
	string_keys = strTok( string, ";" );
	if ( index >= string_keys.size )
	{
		print( "Parsing Error: find_data_from_index() index is out of bounds." );
		return;
	}
	tokens = [];
	for ( i = 0; i < string_keys.size; i++ )
	{
		if ( isSubStr( string_keys[ i ], key ) )
		{
			tokens[ tokens.size ] = string_keys[ i ];
		}
	}
}

add_new_preset_team_token( new_tokens, player_name, team_name_arg, is_perm_arg )
{
	new_preset_team_token = ";" + player_name + "(" + team_name_arg + "," + is_perm_arg + ")";
	add_to_array( new_tokens, new_preset_team_token );
	string = concatenate_array( new_tokens, ";" );
	setDvar( "grief_preset_teams", string );
	//save_to_file( "teams.txt", string );
}

concatenate_array( array, delimiter )
{
	new_string = "";
	foreach ( token in array )
	{
		new_string = new_string + delimiter + token;
	}
	return new_string;
}