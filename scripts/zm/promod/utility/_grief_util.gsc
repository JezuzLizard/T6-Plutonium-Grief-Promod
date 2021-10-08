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
			if ( !flag( "game_start" ) )
			{
				player freezeControls( 1 );
			}
			player [[ level.spawnplayer ]]();
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

is_str_int( str )
{
	number_chars = "0123456789";
	int_checks_passed = 0;
	for ( i = 0; i < str.size; i++ )
	{
		if ( int_checks_passed != i )
		{
			break;
		}
		for ( j = 0; j < number_chars; j++ )
		{
			if ( str[ i ] == number_chars[ j ] )
			{
				int_checks_passed++;
				break;
			}
		}
	}
	return int_checks_passed == str.size;
}

is_str_bool( str )
{
	if ( str == "0" || str == "1" || str == "false" || str == "true" )
	{
		return true;
	}
	return false;
}

is_str_float( str )
{
	number_chars = "0123456789";
	decimals_found = 0;
	float_checks_passed = 0;
	for ( i = 0; i < str.size; i++ )
	{
		if ( float_checks_passed != i )
		{
			break;
		}
		for ( j = 0; j < number_chars; j++ )
		{
			if ( str[ i ] == number_chars[ j ] )
			{
				float_checks_passed++;
				break;
			}
			else if ( str[ i ] == "." )
			{
				decimals_found++;
				float_checks_passed++;
				break;
			}
		}
	}
	if ( str.size <= 10 && decimals_found == 0 )
	{
		return false;
	}
	else if ( decimals_found > 1 )
	{
		return false;
	}
	return float_checks_passed == str.size;
}

is_str_vec( str )
{
	if ( !isSubStr( str, "," ) )
	{
		return false;
	}
	if ( str[ 0 ] == "(" && str[ str.size - 1 ] == ")" )
	{
		str[ str.size - 1 ] = "";
		str[ 0 ] = "";
	}
	else 
	{
		return false;
	}
	keys = strTok( str, "," );
	if ( keys.size != 3 )
	{
		return false;
	}
	vec_checks_passed = 0;
	for ( i = 0; i < keys.size; i++ )
	{
		if ( is_str_float( keys[ i ] ) || is_str_int( keys[ i ] ) )
		{
			vec_checks_passed++;
		}
	}
	return vec_checks_passed == keys.size;
}

cast_str_to_vec( str )
{
	str[ str.size - 1 ] = "";
	str[ 0 ] = "";
	keys = strTok( str, "," );
	return ( float( keys[ 0 ] ), float( keys[ 1 ] ), float( keys[ 2 ] ) );
}

cast_str_to_bool( str )
{
	if ( str == "0" || str == "false" )
	{
		return false;
	}
	if ( str == "1" || str == "true" )
	{
		return true;
	}
	return false;
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
	key_list = "allies:B:false:0|axis:A:false:0"; //|team3:C:false:0|team4:D:false:0|team5:E:false:0|team6:F:false:0|team7:G:false:0|team8:H:false:0
	key_names = "team|e_team|alive|score";
	generate_map( "encounters_teams", key_list, key_names );
	key_list = "admins:player_names:player_guids:cmds:|moderators:player_names:player_guids:cmds|trusted:player_names:player_guids:cmds";
	key_names = "tier|names|guids|cmds|privileges";
	generate_map( "server_ranks", key_list, key_names );
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
		key_value_pairs = strTok( arg_list, "|" );
		for ( i = 0; i < key_value_pairs.size; i++ )
		{
			pairs = strTok( key_value_pairs[ i ], ":" );
			for ( j = 0; j < name_list_keys.size; j++ )
			{
				size = level.data_maps[ map_name ][ name_list_keys[ j ] ].size;
				if ( is_str_bool( pairs[ j ] ) )
				{
					pairs[ j ] = cast_str_to_bool( pairs[ j ] );
				}
				else if ( is_str_int( pairs[ j ] ) )
				{
					pairs[ j ] = int( pairs[ j ] );
				}
				else if ( is_str_float( pairs[ j ] ) )
				{
					pairs[ j ] = float( pairs[ j ] );
				}
				else if ( is_str_vec( pairs[ j ] ) )
				{
					pairs[ j ] = cast_str_to_vec( pairs[ j ] );
				}
				level.data_maps[ map_name ][ name_list_keys[ j ] ][ size ] = pairs[ j ];
			}
		}
	}
}

/*public*/ get_tokens_with_key_value( string, key )
{
	string_keys = strTok( string, ";" );
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

/*public*/ get_first_token_with_key_value( string, key )
{
	string_keys = strTok( string, ";" );
	token = "";
	for ( i = 0; i < string_keys.size; i++ )
	{
		if ( isSubStr( string_keys[ i ], key ) )
		{
			token = string_keys[ i ];
			break;
		}
	}
	return token;
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
		key_names = "tier|names|guids|cmds|privileges";
		level.players_in_session[ self.name ].team_change_timer = 0;
		level.players_in_session[ self.name ].team_changed_times = 0;
		level.players_in_session[ self.name ].team_change_ban = false;
		level.players_in_session[ self.name ].server_rank_system = [];
		level.players_in_session[ self.name ].server_rank_system[ "rank" ] = self get_server_privileges_rank();
		level.players_in_session[ self.name ].server_rank_system[ "cmds" ] = self get_server_privileges_cmds();
		level.players_in_session[ self.name ].server_rank_system[ "privileges" ] = get_server_privileges_special();
	}
}

//(owner,all,all);
//(admin,...,...);
//(moderator,...,...);
//(trusted,...,...);
//(default,...,...);

/*public*/ get_server_privileges_rank()
{

}

/*public*/ get_server_privileges_cmds()
{
	//"all", "allex", "none", "noneex", "inheritall", "inheritex"
}

/*private*/ FS_init()
{
	level.FS_basepath = getDvar( "fs_basepath" ) + "/" + getDvar( "fs_basegame" ) + "/" + "scriptdata" + "/";
	level.FS_open_files = [];
}

/*public*/ FS_read( filename )
{
	reason = FS_file_open_failure( filename );
	if ( reason != "" )
	{
		print( "FS_read Error: Failed to open " + filename + " reason " + reason );
		return "";
	}
	level.FS_open_files[ level.FS_open_files.size ] = filename;
	file = fopen( level.basepath + filename, "r+" );
	if ( file == -1 )
	{
		arrayRemoveValue( level.FS_open_files, filename );
		print( "FS_read Error: Failed to open " + filename );
		return "";
	}
	buffer = fread( file );
	fclose( file );
	arrayRemoveValue( level.FS_open_files, filename );
	return buffer;
}

/*public*/ FS_write( filename, buffer )
{
	reason = FS_file_open_failure( filename );
	if ( reason != "" )
	{
		print( "FS_write Error: Failed to open " + filename + " reason " + reason );
		return;
	}
	level.FS_open_files[ level.FS_open_files.size ] = filename;
	file = fopen( level.basepath + filename, "w+" );
	if ( file == -1 )
	{
		arrayRemoveValue( level.FS_open_files, filename );
		print( "FS_write Error: Failed to open " + filename );
		return;
	}
	data = "";
	data_printed = 0;
	for ( buffer_index = 0; isDefined( buffer[ buffer_index ] ); buffer_index++ )
	{
		data += buffer[ buffer_index ];
		if ( buffer[ buffer_index ] == ";" )
		{
			fprintf( data + "\n", file );
			data_printed += data.size;
			data = "";
		}
	}
	fclose( file );
	arrayRemoveValue( level.FS_open_files, filename );
	if ( buffer.size != data_printed )
	{
		print( "FS_write Error: Failed to write entire buffer " + filename );
	}
}

/*public*/ FS_append( filename, buffer )
{
	reason = FS_file_open_failure( filename );
	if ( reason != "" )
	{
		print( "FS_append Error: Failed to open " + filename + " reason " + reason );
		return;
	}
	level.FS_open_files[ level.FS_open_files.size ] = filename;
	file = fopen( level.basepath + filename, "a+" );
	if ( file == -1 )
	{
		arrayRemoveValue( level.FS_open_files, filename );
		print( "FS_append Error: Failed to open " + filename );
		return;
	}
	data = "";
	data_printed = 0;
	for ( buffer_index = 0; isDefined( buffer[ buffer_index ] ); buffer_index++ )
	{
		data += buffer[ buffer_index ];
		if ( buffer[ buffer_index ] == ";" )
		{
			fprintf( data + "\n", file );
			data_printed += data.size;
			data = "";
		}
	}
	fclose( file );
	arrayRemoveValue( level.FS_open_files, filename );
	if ( buffer.size != data_printed )
	{
		print( "FS_append Error: Failed to write entire buffer " + filename );
	}
}

/*private*/ FS_file_open_failure( filename )
{
	if ( level.FS_open_files.size > 10 )
	{
		return "more than 10 open files";
	}
	if ( isInArray( level.FS_open_files, filename ) )
	{
		return "file already open";
	}
	return "";
}

/*private*/ SERVER_MSG_INIT()
{
	level.msg_types = [];
	level.msg_types[ "info" ] = getDvarIntDefault( "sv_msg_info_display", 1 );
	level.msg_types[ "warning" ] = getDvarIntDefault( "sv_msg_warning_display", 1 );
	level.msg_types[ "error" ] = getDvarIntDefault( "sv_msg_error_display", 1 );
	level.msg_types[ "cmdinfo" ] = getDvarIntDefault( "sv_msg_cmdinfo_display", 1 );
	level.msg_types[ "cmdwarning" ] = getDvarIntDefault( "sv_msg_cmdwarning_display", 1 );
	level.msg_types[ "cmderror" ] = getDvarIntDefault( "sv_msg_cmderror_display", 1 );
	level.msg_types[ "debug" ] = getDvarIntDefault( "sv_msg_debug_display", 0 );
	level.msg_types[ "obituary" ] = getDvarIntDefault( "sv_msg_obituary_display", 1 );
	level.msg_types[ "notitle" ] = getDvarIntDefault( "sv_msg_notitle_display", 1 );

	level.msg_funcs[ "con" ] = ::COM_PRINT;
	level.msg_funcs[ "g_log" ] = ::COM_LOGPRINT;
	level.msg_funcs[ "con_log" ] = ::COM_CONSOLELOGPRINT;
	level.msg_funcs[ "iprint" ] = ::COM_IPRINTLN;
	level.msg_funcs[ "iprintbold" ] = ::COM_IPRINTLNBOLD;
	level.msg_funcs[ "say" ] = ::COM_SAY;
	level.msg_funcs[ "tell" ] = ::COM_TELL;
	level.msg_funcs[ "obituary" ] = ::COM_OBITUARY;
}

COM_PRINT( channel, filter, message, players )
{
	if ( is_true( level.msg_types[ filter ] ) )
	{
		message = COM_TO_CAPS_MSG_TITLE( filter ) + message;
		print( message );
	}
}

COM_LOGPRINT( channel, filter, message, players )
{
	if ( is_true( level.msg_types[ filter ] ) )
	{
		message = COM_TO_CAPS_MSG_TITLE( filter ) + message;
		logPrint( message + "/n" );
	}
}

COM_CONSOLELOGPRINT( channel, filter, message, players )
{
	if ( is_true( level.msg_types[ filter ] ) )
	{
		message = COM_TO_CAPS_MSG_TITLE( filter ) + message;
		//consoleLogPrint( message );
	}
}

COM_IPRINTLN( channel, filter, message, players )
{
	if ( is_true( level.msg_types[ filter ] ) )
	{
		message = COM_TO_CAPS_MSG_TITLE( filter ) + message;
		if ( array_validate( players ) )
		{
			for ( i = 0; i < players.size; i++ )
			{
				if ( isPlayer( players[ i ] ) && !players[ i ].is_server )
				{
					players[ i ] iPrintLn( message );
				}
			}
		}
		else 
		{
			COM_PRINTF( "con con_log", "error", va( "COM_PRINTF() msg %s sent for channel %s has bad players arg", message, channel ) );
		}
	}
}

COM_IPRINTLNBOLD( channel, filter, message, players )
{
	if ( is_true( level.msg_types[ filter ] ) )
	{
		message = COM_TO_CAPS_MSG_TITLE( filter ) + message;
		if ( array_validate( players ) )
		{
			for ( i = 0; i < players.size; i++ )
			{
				if ( isPlayer( players[ i ] ) && !players[ i ].is_server )
				{
					players[ i ] iPrintLnBold( message );
				}
			}
		}
		else 
		{
			COM_PRINTF( "con con_log", "error", va( "COM_PRINTF() msg %s sent for channel %s has bad players arg", message, channel ) );
		}
	}
}

COM_SAY( channel, filter, message, players )
{
	if ( is_true( level.msg_types[ filter ] ) )
	{
		message = COM_TO_CAPS_MSG_TITLE( filter ) + message;
		say( message );
	}
}

COM_TELL( channel, filter, message, players )
{
	if ( is_true( level.msg_types[ filter ] ) )
	{
		message = COM_TO_CAPS_MSG_TITLE( filter ) + message;
		if ( array_validate( players ) )
		{
			for ( i = 0; i < players.size; i++ )
			{
				if ( isPlayer( players[ i ] ) && !players[ i ].is_server )
				{
					players[ i ] tell( message );
				}
			}
		}
		else 
		{
			COM_PRINTF( "con con_log", "error", va( "COM_PRINTF() msg %s sent for channel %s has bad players arg", message, channel ) );
		}
	}
}

COM_OBITUARY( filter, message, players )
{
	if ( is_true( level.msg_types[ filter ] ) )
	{
		obituary( players[ 0 ], players[ 1 ], players[ 0 ].last_griefed_by.weapon, players[ 0 ].last_griefed_by.meansofdeath );
	}
}

COM_TO_CAPS_MSG_TITLE( filter )
{
	return filter != "notitle" ? toUpper( filter ) + ":" : "";
}

/*public*/ COM_PRINTF( channels, filter, message, players )
{
	channel_keys = strTok( channels, " " );
	fmt_msg = message;
	foreach ( channel in channel_keys )
	{
		if ( isDefined( level.msg_funcs[ channel ] ) )
		{
			[[ level.msg_funcs[ channel ] ]]( channel, filter, message, players );
		}
		else 
		{
			COM_PRINTF( "con", "error", va( "COM_PRINTF() channel %s is invalid", channel ) );
		}
	}
}

/*public*/ parse_cmd_message( message )
{
	if ( message == "" )
	{
		return [];
	}
	multi_cmds = [];
	command_keys = [];
	multiple_cmds_keys = strTok( message, ";" );
	for ( i = 0; i < multiple_cmds_keys.size; i++ )
	{
		message = multiple_cmds_keys[ i ];
		command_keys[ "cmdname" ] = "";
		command_keys[ "args" ] = [];
		command_keys[ "namespace" ] = get_cmd_namespace( message );
		buffer_index = 0;
		for ( ; command_keys[ "namespace" ] != "" && buffer_index < command_keys[ "namespace" ].size + 2; buffer_index++ )
		{
		}
		for ( ; message[ buffer_index ] != "("; buffer_index++ )
		{
			command_keys[ "cmdname" ] = command_keys[ "cmdname" ] + message[ buffer_index ];
		}
		for ( ; isDefined( message[ buffer_index ] ); buffer_index++ )
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
				if ( isSubStr( command_keys[ "args" ][ command_keys[ "args" ].size - 1 ], "(" ) );
				{
					result = execute_nested_command( command_keys[ "args" ][ command_keys[ "args" ].size - 1 ] );
					if ( is_true( result[ "success" ] ) )
					{
						command_keys[ "args" ][ command_keys[ "args" ].size - 1 ] = result[ "args" ];
					}
					else 
					{
						command_keys[ "args" ][ command_keys[ "args" ].size - 1 ] = "";
					}
				}
			}
		}
		multi_cmds[ multi_cmds.size ] = command_keys;
	}
	return multi_cmds;
}

/*private*/ get_cmd_namespace( message )
{
	if ( !isSubStr( message, ":" ) )
	{
		return "";
	}
	message_tokens = strTok( message, ":" );
	return message_tokens[ 0 ];
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