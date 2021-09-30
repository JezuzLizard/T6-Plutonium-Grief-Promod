
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


//cmd structure:
//set preset_teams_cmd "remove(player_name);remove(player_name2);" - Removes a player from the preset teams list.
//set preset_teams_cmd "add(player_name,team_name,is_perm);add(player_name2,team_name,is_perm);" - Adds a player to team. Optional is_perm arg to determine if dvar doesn't clear if the player isn't in the session.

//set grief_preset_teams "(player_name,team_name,is_perm);(player_name,team_name,is_perm) etc"

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

execute_dvar_cmd( namespace, cmd, arg_list )
{
	switch ( namespace )
	{
		case "t":
		case "team":
		case "teamcmd":
			switch ( cmd )
			{
				case "r":
				case "remove":
					new_tokens = remove_tokens_from_array( strTok( getDvar( "grief_preset_teams" ), ";" ), arg_list[ 0 ] );
					setDvar( "grief_preset_teams", concatenate_array( new_tokens, ";" ) );
					break; 
				case "a":
				case "add":
					cur_tokens = strTok( getDvar( "grief_preset_teams" ), ";" );
					new_tokens = [];
					player_name = arg_list[ 0 ];
					team_name = arg_list[ 1 ];
					is_perm = arg_list[ 2 ];
					if ( !isDefined( player_name ) || !isDefined( team_name ) )
					{
						print( "Parsing Error: team:add() missing player or team name arg." );
						return;
					}
					new_tokens = concatenate_array( remove_tokens_from_array( cur_tokens, player_name ), ";" );
					if ( !isDefined( is_perm )
					{
						is_perm = "0";
					}
					if ( is_perm == "true" )
					{
						is_perm = "1";
					}
					else if ( is_perm == "false" )
					{
						is_perm = "0";
					}
					else if ( int( is_perm ) != 0 || int( is_perm ) != 1 )
					{
						print( "Parsing Error: Bad token detected for is_perm for player: " + player_name );
						print( "cont: Defaulting to false." );
						is_perm = "0";
					}
					add_new_preset_team_token( new_tokens, player_name, team_name, is_perm );
					break;
				default: 
					print( "Parsing Error: Unhandled cmd " + cmd + " sent to execute_team_cmd()." );
					break;
			}
			break;
		default:
			print( "Parsing Error: Unhandled namespace " + namespace + " sent to execute_dvar_cmd()." );
			break;
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