
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
					// result = execute_nested_command( command_keys[ "args" ][ command_keys[ "args" ].size - 1 ] );
					// if ( is_true( result[ "success" ] ) )
					// {
					// 	command_keys[ "args" ][ command_keys[ "args" ].size - 1 ] = result[ "args" ];
					// }
					// else 
					// {
					// 	command_keys[ "args" ][ command_keys[ "args" ].size - 1 ] = "";
					// }
				}
			}
		}
		multi_cmds[ multi_cmds.size ] = command_keys;
	}
	return multi_cmds;
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
	result = [];
	result[ "error_msg" ] = 0;
	result[ "key_value" ] = "";
	string_keys = strTok( string, ";" );
	if ( index >= string_keys.size )
	{
		result[ "error_msg" ] = "index is out of bounds.";
		return result;
	}
	sub_keys = strTok( clean_str( string_keys[ index ], "()" ), "," );
	if ( sub_index >= sub_keys.size )
	{
		result[ "error_msg" ] = "sub_index is out of bounds.";
		return result;
	}
	result[ "key_value" ] = sub_keys[ sub_index ];
	return result;
}

/*public*/ set_value_from_indexes( string_name, string_contents, index, sub_index, new_value )
{
	result = [];
	result[ "error_msg" ] = 0;
	string_keys = strTok( string_contents, ";" );
	if ( index >= string_keys.size )
	{
		result[ "error_msg" ] = "index is out of bounds.";
		return result;
	}
	sub_keys = strTok( clean_str( string_keys[ index ], "()" ), "," );
	if ( sub_index >= sub_keys.size )
	{
		result[ "error_msg" ] = "sub_index is out of bounds.";
		return result;
	}
	sub_keys[ sub_index ] = new_value;
	new_str = repackage_string( sub_keys, "," );
	new_str = "(" + new_str + ");";
	string_keys[ index ] = new_str;
	modified_str = repackage_string( string_keys, "" );
	setDvar( string_name, modified_str );
	//save_to_file( "teams.txt", new_str );
	return result;
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
	result = [];
	result[ "error_msg" ] = 0;
	result[ "key_value" ] = "";
	if ( !isSubStr( string_contents, value ) )
	{
		result[ "error_msg" ] = va( "string %s does not contain %s value in its contents.", string_name, value );
		return result;
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
					result[ "error_msg" ] = "invalid %s key.", key );
					return result;
				}
			}
			else 
			{
				result[ "error_msg" ] = va( "no map found for %s.", string_name );
				return result;
			}
			sub_keys = strTok( string_keys[ i ], "," );
			if ( key_index >= sub_keys.size )
			{
				result[ "error_msg" ] = "key_index is out of bounds.";
				return result;
			}
			result[ "key_value" ] = sub_keys[ key_index ];
		}
	}
	result[ "key_value" ] = clean_str( result[ "key_value" ], "()" );
	return result;
}

/*public*/ set_key_value_from_value( string_name, string_contents, value, key, new_value )
{
	result = [];
	result[ "error_msg" ] = 0;
	set_value = false;
	if ( !isSubStr( string_contents, value ) )
	{
		result[ "error_msg" ] = va( "string %s does not contain %s value in its contents.", string_name, value );
		return result;
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
					result[ "error_msg" ] = va( "invalid %s key %s new_value pair.", key, new_value )''
					return result;
				}
			}
			else 
			{
				result[ "error_msg" ] = va( "no map found for %s.", string_name );
				return result;
			}
			sub_keys = strTok( clean_str( string_keys[ i ], "()" ), "," );
			if ( key_index >= sub_keys.size )
			{
				result[ "error_msg" ] = "key_index is out of bounds.";
				return result;
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
		result[ "error_message" ] = va( "couldn't find key/value pair in %s to set.", string_name );
		return result;
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