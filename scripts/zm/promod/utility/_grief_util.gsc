#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/zombies/_zm_laststand;
#include scripts/zm/promod/plugin/commands;
#include maps/mp/zombies/_zm;
#include scripts/zm/promod/_teams;
#include maps/mp/zombies/_zm_perks;

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
			say( clean_player_name_of_clantag( self.name ) + " has been kicked for inactivity!" );
			kick( self getEntityNumber() );
		}

		wait 0.05;
		time++;
	}
}

/*public*/ get_mapname()
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

/*public*/ get_loser( winner )
{
	if ( winner == "A" )
	{
		return "B";
	}
	return "A";
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
		}
		else if ( !is_true( level.initial_spawn_players ) )
		{
			player [[ level.spawnplayer ]]();
			player freeze_player_controls( 1 );
		}
	}
}

/*public*/ zombie_goto_round( target_round )
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

/*private*/ add_new_dvar_command( dvar_name )
{
	if ( !isDefined( level.dvar_commands ) ) 
	{
		level.dvar_commands = [];
	}
	if ( !isDefined( level.dvar_commands[ dvar_name ] ) )
	{
		level.dvar_commands[ dvar_name ] = true;
		setDvar( dvar_name, "" );
	}
}

/*public*/ add_dvar_commands()
{
	add_new_dvar_command( "dcmd" );
	level thread dvar_command_watcher();
}

/*private*/ dvar_command_watcher()
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
				setDvar( dvar, "" );
			}
		}
		wait 0.05;
	}
}

/*public*/ remove_tokens_from_array( array, token )
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

/*public*/ clean_str( str, tokens )
{
	new_str = "";
	for ( i = 0; i < str.size; i++ )
	{
		match = false;
		for ( j = 0; j < tokens.size; j++ )
		{
			if ( str[ i ] == tokens[ j ] )
			{
				match = true;
				break;
			}
		}
		if ( !match )
		{
			new_str += str[ i ];
		}
	}
	return new_str;
}

//set grief_preset_teams "(player_name,team_name,is_perm,is_banned);(player_name,team_name,is_perm,is_banned) etc"

/*public*/ get_value_from_indexes( string, index, sub_index )
{
	string_keys = strTok( string, ";" );
	if ( index >= string_keys.size )
	{
		print( "Parsing Error: get_value_from_indexes() index is out of bounds." );
		return "";
	}
	sub_keys = strTok( clean_str( string_keys[ index ], "()" ), "," );
	if ( sub_index >= sub_keys.size )
	{
		print( "Parsing Error: get_value_from_indexes() sub_index is out of bounds." );
		return "";
	}
	return sub_keys[ sub_index ];
}

/*public*/ set_value_from_indexes( string_name, string_contents, index, sub_index, new_value )
{
	string_keys = strTok( string_contents, ";" );
	if ( index >= string_keys.size )
	{
		print( "Parsing Error: set_value_from_indexes() index is out of bounds." );
		return;
	}
	sub_keys = strTok( clean_str( string_keys[ index ], "()" ), "," );
	if ( sub_index >= sub_keys.size )
	{
		print( "Parsing Error: set_value_from_indexes() sub_index is out of bounds." );
		return;
	}
	sub_keys[ sub_index ] = new_value;
	new_str = repackage_string( sub_keys, "," );
	new_str = "(" + new_str + ");";
	string_keys[ index ] = new_str;
	modified_str = repackage_string( string_keys, "" );
	setDvar( string_name, modified_str );
	//save_to_file( "teams.txt", new_str );
}

/*public*/ repackage_string( array, delimiter )
{
	new_str = "";
	for ( i = 0; i < array.size; i++ )
	{
		new_str += concatenate_array( array[ i ], delimiter );
	}
	return new_str;
}

/*public*/ get_key_value_from_value( string_name, string_contents, value, key )
{
	key_value = "";
	if ( !isSubStr( string_contents, value ) )
	{
		return "";
	}
	string_keys = strTok( string_contents, ";" );
	for ( i = 0; i < string_keys.size; i++ )
	{
		if ( isSubStr( string_keys[ i ], value ) )
		{
			is_valid_key = false;
			key_index = 0;
			if ( isDefined( level.data_maps[ string_name ][ "keys" ] ) )
			{
				for ( j = 0; j < level.data_maps[ string_name ][ "keys" ].size; j++ )
				{
					if ( key == level.data_maps[ string_name ][ "keys" ][ j ] )
					{
						is_valid_key = true;
						key_index = j;
						break;
					}
				}
				if ( !is_valid_key )
				{
					print( "Parsing Error: get_key_value_from_value() invalid key." );
					return "";
				}
			}
			else 
			{
				print( "Parsing Error: get_key_value_from_value() no map found for " + string_name + "." );
				return "";
			}
			sub_keys = strTok( string_keys[ i ], "," );
			if ( key_index >= sub_keys.size )
			{
				print( "Parsing Error: get_key_value_from_value() key_index is out of bounds." );
				return "";
			}
			key_value = sub_keys[ key_index ];
		}
	}
	return clean_str( key_value, "()" );
}

/*public*/ set_key_value_from_value( string_name, string_contents, value, key, new_value )
{
	set_value = false;
	if ( !isSubStr( string_contents, value ) )
	{
		return "";
	}
	string_keys = strTok( string_contents, ";" );
	for ( i = 0; i < string_keys.size; i++ )
	{
		if ( isSubStr( string_keys[ i ], value ) )
		{
			is_valid_key = false;
			is_valid_new_value = false;
			key_index = 0;
			if ( isDefined( level.data_maps[ string_name ][ "keys" ] ) )
			{
				for ( j = 0; j < level.data_maps[ string_name ][ "keys" ].size; j++ )
				{
					if ( key == level.data_maps[ string_name ][ "keys" ][ j ] )
					{
						is_valid_key = true;
						if ( get_type( new_value ) == level.data_maps[ string_name ][ "value_types" ][ j ] )
						{
							is_valid_new_value = true;
							key_index = j;
							break;
						}
					}
				}
				if ( !is_valid_key || !is_valid_new_value )
				{
					print( "Parsing Error: set_key_value_from_value() invalid key/new_value pair." );
					return;
				}
			}
			else 
			{
				print( "Parsing Error: set_key_value_from_value() no map found for " + string_name + "." );
				return;
			}
			sub_keys = strTok( clean_str( string_keys[ i ], "()" ), "," );
			if ( key_index >= sub_keys.size )
			{
				print( "Parsing Error: set_key_value_from_value() key_index is out of bounds." );
				return;
			}
			sub_keys[ key_index ] = new_value + "";
			set_value = true;
			break;
		}
	}
	if ( set_value )
	{
		new_str = repackage_string( sub_keys, "," );
		new_str = "(" + new_str + ");";
		string_keys[ index ] = new_str;
		modified_str = repackage_string( string_keys, "" );
		setDvar( string_name, modified_str );
		//save_to_file( "teams.txt", new_str );
	}
	else 
	{
		print( "Parsing Error: set_key_value_from_value() couldn't find key/value pair to set." );
	}
}

/*public*/ get_type( var )
{
	is_int = isInt( var );
	is_float = isFloat( var );
	is_vec = isVec( var );
	if ( is_vec )
	{
		return "vec";
	}
	if ( ( var == 0 || var == 1 ) && is_int )
	{
		return "bool";
	}
	if ( is_int )
	{
		return "int";
	}
	if ( isString( var ) )
	{
		return "str";
	}
	if ( is_float )
	{
		return "float";
	}
}

/*public*/ generate_storage_maps()
{
	key_list = "str:player_name|str:team_name|bool:is_perm|bool:is_banned";
	key_names = "value_types|keys";
	generate_map( "grief_preset_teams", key_list, key_names );
	key_list = "axis:A|allies:B|team3:C|team4:D|team5:E|team6:F|team7:G|team8:H";
	key_names = "team|e_team";
	generate_map( "encounters_teams", key_list, key_names );
}

/*private*/ generate_map( map_name, arg_list, name_list )
{
	if ( !isDefined( level.data_maps ) )
	{
		level.data_maps = [];
	}
	if ( !isDefined( level.data_maps[ map_name ] ) )
	{
		name_list_keys = strTok( name_list, "|" );
		foreach ( key in name_list_keys )
		{
			if ( !isDefined( level.data_maps[ map_name ][ key ] ) )
			{
				level.data_maps[ map_name ][ key ] = [];
			}
		}
		key_value_types_pairs = strTok( arg_list, "|" );
		for ( i = 0; i < key_value_pairs.size; i++ )
		{
			pairs = strTok( key_value_pairs[ i ], ":" );
			for ( j = 0; j < name_list_keys.size; j++ )
			{
				size = level.data_maps[ map_name ][ name_list_keys[ j ] ].size;
				level.data_maps[ map_name ][ name_list_keys[ j ] ][ size ] = pairs[ j ];
			}
		}
	}
}

/*public*/ get_tokens_with_key_value( string, key )
{
	string_keys = strTok( string, ";" );
	if ( index >= string_keys.size )
	{
		print( "Parsing Error: get_tokens_with_key_value() index is out of bounds." );
		return [];
	}
	tokens = [];
	for ( i = 0; i < string_keys.size; i++ )
	{
		if ( isSubStr( string_keys[ i ], key ) )
		{
			tokens[ tokens.size ] = string_keys[ i ];
		}
	}
	return tokens;
}

/*public*/ add_new_preset_team_token( new_tokens, player_name, team_name_arg, is_perm_arg, is_banned_arg )
{
	new_preset_team_token = "(" + player_name + "," + team_name_arg + "," + is_perm_arg + "," + is_banned_arg + ")";
	add_to_array( new_tokens, new_preset_team_token );
	string = concatenate_array( new_tokens, ";" );
	setDvar( "grief_preset_teams", string );
	//save_to_file( "teams.txt", string );
}

/*public*/ concatenate_array( array, delimiter )
{
	new_string = "";
	foreach ( token in array )
	{
		new_string += token + delimiter;
	}
	return new_string;
}

/*public*/ clean_player_name_of_clantag( name )
{
	if ( isSubStr( name, "]" ) )
	{
		keys = strTok( name, "]" );
		return keys[ 1 ];
	}
	return name;
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
		level.players_in_session[ self.name ].team_change_timer = 0;
		level.players_in_session[ self.name ].team_changed_times = 0;
		level.players_in_session[ self.name ].team_change_ban = false;
	}
}

/*public*/ parse_message( message )
{
	multi_cmds = [];
	command_keys = [];
	multiple_cmds_keys = strTok( message, ";" );
	for ( i = 0; i < multiple_cmds_keys.size; i++ )
	{
		message = multiple_cmds_keys[ i ];
		command_keys[ "cmdname" ] = "";
		command_keys[ "args" ] = [];
		command_keys[ "namespace" ] = get_cmd_namespace( message );
		for ( buffer_index = 0; command_keys[ "namespace" ] != "" && buffer_index < command_keys[ "namespace" ].size + 2; buffer_index++ )
		{
		}
		for ( ; message[ buffer_index ] != "("; buffer_index++ )
		{
			command_keys[ "cmdname" ] = command_keys[ "cmdname" ] + message[ buffer_index ];
		}
		for ( ; isDefined( message[ buffer_index ] ) && message[ buffer_index ] != ")"; buffer_index++ )
		{
			if ( message[ buffer_index ] == "," )
			{
				command_keys[ "args" ][ command_keys[ "args" ].size ] = "";
			}
			else 
			{
				for ( ; isDefined( message[ buffer_index ] ) && message[ buffer_index ] != ","; buffer_index++ )
				{
					command_keys[ "args" ][ command_keys[ "args" ].size - 1 ] += message[ buffer_index ];
				}
			}
		}
		multi_cmds[ multi_cmds.size ] = command_keys;
	}
	return multi_cmds;
}

/*private*/ get_cmd_namespace( message )
{
	cmd_namespace = "";
	if ( !isSubStr( message, ":" ) )
	{
		return ":";
	}
	for ( i = 0; isDefined( message[ i ] ) && message[ i ] != ":"; i++ )
	{
		cmd_namespace = cmd_namespace + message[ i ];
	}
	namespace_keys = getArrayKeys( level.cmd_namespaces );
	for ( i = 0; i < namespace_keys.size; i++ )
	{
		foreach ( alias in level.cmd_namespaces[ namespace_keys[ i ] ][ "namespace_aliases" ] )
		{
			if ( cmd_namespace == alias )
			{
				return namespace_keys[ i ];
			}
		}
	}
	return "";
}

/*public*/ no_magic()
{	
	no_drops();
	machines = getentarray( "zombie_vending", "targetname" );
	for( i = 0; i < machines.size; i++ )
	{
		level thread perk_machine_removal( machines[ i ].script_noteworthy );
	}
}

/*public*/ no_drops()
{
	flag_clear( "zombie_drop_powerups" );
	level.zombie_include_powerups = [];
	level.zombie_powerup_array= [];
	level.zombie_include_powerups = [];
}