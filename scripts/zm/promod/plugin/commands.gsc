
commands()
{
	level endon( "end_commands" );
	level thread end_commands_on_end_game();
	while ( true )
    {
        level waittill( "say", player, message );
        if ( !isSubStr( message, "!" ) )
        {
            continue;
        }
		args = strTok( message, ":" );
        keys = strTok( args[ 0 ], "!" );
        command = toLower( keys[ 0 ] );
        if ( player has_permissions_for_command( command, args ) )
        {
            switch ( command )
            {
				case "fr":
				case "restart":
				case "maprestart":
				case "map_restart":
					logline1 = "CMD:" + player.name + ";FR" + "\n";
					logprint( logline1 );
					level thread change_level();
					level notify( "end_commands", 0 );
					break;
				case "nm":
				case "nextmap":
                case "setnextmap":
					logline1 = "CMD:" + player.name + ";NM:" + args[ 1 ] + "\n";
					logprint( logline1 );
                    find_alias_and_set_map( toLower( args[ 1 ] ), player, 0, 0 );
                    break;
				case "km":
				case "keepmap":
					logline1 = "CMD:" + player.name + ";KM:" + args[ 1 ] + "\n";
					logprint( logline1 );
                    find_alias_and_set_map( toLower( args[ 1 ] ), player, 0, 1 );
                    break;
				case "mr":
                case "maprotate":
					logline1 = "CMD:" + player.name + ";MR" + "\n";
					logprint( logline1 );
					level thread change_level();
					level notify( "end_commands", 1 );
                    break;
				case "m":
				case "map":
					logline1 = "CMD:" + player.name + ";MAP:" + args[ 1 ] + "\n";
					logprint( logline1 );
					find_alias_and_set_map( toLower( args[ 1 ] ), player, 1 );
					break;
				case "rr":
				case "resetrotation":
					logline1 = "CMD:" + player.name + ";RR" + "\n";
					logprint( logline1 );
					player tell( "Map rotation reset to the default" );
					setDvar( "sv_maprotation", getDvar( "grief_original_rotation" ) );
					setDvar( "sv_maprotationCurrent", getDvar( "grief_original_rotation" ) );
					break;
				case "k":
				case "kick":
					foreach ( player in level.players )
					{
						if ( clean_player_name_of_clantag( player.name ) == clean_player_name_of_clantag( args[ 1 ] ) )
						{
							logline1 = "CMD:" + player.name + ";K:" + args[ 1 ] + "\n";
							logprint( logline1 );
							say( clean_player_name_of_clantag( player.name ) + " has been kicked!" );
							kick( player getEntityNumber() );
							break;
						}
					}
					break;
				case "mv":
				case "mapvote":
					if ( !is_true( level.mapvote_in_progress ) )
					{
						logline1 = "CMD:" + player.name + ";MVS:" + args[ 1 ] + "\n";
						logprint( logline1 );
						level thread mapvote_started();
						level thread mapvote_count_votes();
						level thread mapvote_end();
						level.mapvote_in_progress = 1;
						say( "Mapvote started!" );
					}
					level notify( "grief_mapvote", args[ 1 ], player );
					break;
				case "vk":
				case "votekick":
					if ( level.players.size < 3 )
					{
						player tell( "Not enough players to initiate a votekick" );
						break;
					}
					if ( !is_true( level.votekick_in_progress ) )
					{
						logline1 = "CMD:" + player.name + ";VKS:" + args[ 1 ] + "\n";
						logprint( logline1 );
						level thread vote_kick_started();
						level thread votekick_count_votes();
						level.votekick_in_progress = 1;
						say( "Votekick started!" );
					}
					level notify( "grief_votekick", args[ 1 ], player );
					break;
				case "mag":
				case "magic":
				case "nomagic":
					if ( !isDefined( args[ 1 ] ) )
					{
						say( "Magic is disabled for this round only" );
						no_magic();
						break;
					}
					if ( args[ 1 ] == "0" )
					{	
						logline1 = "CMD:" + player.name + ";TOGMAG" + "\n";
						logprint( logline1 );
						say( "Magic is disabled on the server" );
						setDvar( "grief_gamerule_magic", 0 );
						no_magic();
					}
					if ( args[ 1 ] == "1" )
					{
						say( "Magic will be enabled on the server starting next match" );
						setDvar( "grief_gamerule_magic", 1 );
					}
					break;
				case "np":
				case "drops":
				case "powerups":
					if ( !isDefined( args[ 1 ] ) )
					{
						say( "Powerups are disabled for this match only" );
						no_drops();
						break;
					}
					logline1 = "CMD:" + player.name + ";TOGDROPS:" + args[ 1 ] + "\n";
					logprint( logline1 );
					if ( args[ 1 ] == "0" )
					{
						say( "Powerups are disabled on the server" );
						no_drops();
						setDvar( "grief_gamerule_powerup_restrictions", "all" );
					}
					else if ( args[ 1 ] == "1" )
					{
						say( "Powerups will be enabled on the server starting next match" );
						setDvar( "grief_gamerule_powerup_restrictions", "" );
					}
					break;
				case "rn":
				case "roundnumber":
					if ( !isDefined( args[ 1 ] ) )
					{
						player tell( "You need to specify a round number" );
						break;
					}
					logline1 = "CMD:" + player.name + ";ROUND:" + args[ 1 ] + "\n";
					logprint( logline1 );
					say( "The round is set to " + args[ 1 ] );
					set_round( int( args[ 1 ] ) );
					break;
				case "kl":
				case "knifelunge":
					logline1 = "CMD:" + player.name + ";KNIFE:" + args[ 1 ] + "\n";
					logprint( logline1 );
					set_knife_lunge( int( args[ 1 ] ) );
					break;
				case "d":
				case "dvar":
					if ( !isDefined( args[ 1 ] ) || !isDefined( args[ 2 ] ) )
					{
						player tell( "You need to specify a dvar and its value" );
						break;
					}
					player tell( "Dvar set " + args[ 1 ] + " to " + args[ 2 ] );
					logline1 = "CMD:" + player.name + ";DVAR:" + args[ 1 ] + ";VAL:" + args[ 2 ] + "\n";
					logprint( logline1 );
					setDvar( args[ 1 ], args[ 2 ] );
					break;
				case "cv":
				case "cvar":
					if ( !isDefined( args[ 1 ] ) || !isDefined( args[ 2 ] ) )
					{
						player tell( "You need to specify a dvar and its value" );
						break;
					}
					player tell( "Cvar set " + args[ 1 ] + " to " + args[ 2 ] );
					logline1 = "CMD:" + player.name + ";CVAR:" + args[ 1 ] + ";VAL:" + args[ 2 ] + "\n";
					logprint( logline1 );
					player setClientDvar( args[ 1 ], args[ 2 ] );
					break;
				case "cva":
				case "cvarall":
					if ( !isDefined( args[ 1 ] ) || !isDefined( args[ 2 ] ) )
					{
						player tell( "You need to specify a dvar and its value" );
						break;
					}
					foreach ( player in level.players )
					{
						player tell( "Cvar set " + args[ 1 ] + " to " + args[ 2 ] );
						logline1 = "CMD:" + player.name + ";CVARA:" + args[ 1 ] + ";VAL:" + args[ 2 ] + "\n";
						logprint( logline1 );
						player setClientDvar( args[ 1 ], args[ 2 ] );
					} 
					break;
				case "l":
				case "lock":
				case "lockserver":
					if ( !isDefined( args[ 1 ] ) )
					{
						player tell( "You need to specify a password to lock the server" );
						break;
					}
					player tell( "Server is now password protected" );
					logline1 = "CMD:" + player.name + ";LOCK:" + args[ 1 ] + "\n";
					logprint( logline1 );
					setDvar( "g_password", args[ 1 ] );
					break;
				case "ul":
				case "unlock":
				case "unlockserver":
					player tell( "Server is now open" );
					logline1 = "CMD:" + player.name + ";UNLOCK:" + "\n";
					logprint( logline1 );
					setDvar( "g_password", "" );
					break;
				// case "im":
				// case "intermission":
				// 	level.grief_gamerules[ "intermission_time" ] = args[ 1 ];
				// 	say( "Intermission will take place after next round and last " + args[ 1 ] );
				// 	logline1 = "CMD:" + player.name + ";IM" + ";TIME:" + args[ 1 ] + "\n";
				// 	logprint( logline1 );
				// 	break;
				case "mobjug":
				case "celljug":
				case "cellblockjug":
					if ( !isDefined( args[ 1 ] ) )
					{
						player tell( "You need to specify 1 or 0" );
						break;
					}
					if ( args[ 1 ] == "1" )
					{	
						say( "Jug is enabled on Cellblock" );
						setDvar( "grief_gamerule_cellblock_jug", 1 );
					}
					else if ( args[ 1 ] == "0" )
					{	
						say( "Jug is disabled on Cellblock" );
						setDvar( "grief_gamerule_cellblock_jug", 0 );
					}
					logline1 = "CMD:" + player.name + ";MOBJUG:" + args[ 1 ] + "\n";
					logprint( logline1 );
					break;
				case "depotjug":
					if ( !isDefined( args[ 1 ] ) )
					{
						player tell( "You need to specify 1 or 0" );
						break;
					}
					if ( args[ 1 ] == "1" )
					{	
						say( "Jug is enabled on Bus Depot" );
						setDvar("grief_gamerule_depot_jug", 1 );
					}
					else if ( args[ 1 ] == "0" )
					{	
						say( "Jug is disabled on Bus Depot" );
						setDvar("grief_gamerule_depot_jug", 0 );
					}
					logline1 = "CMD:" + player.name + ";DEPOTJUG:" + args[ 1 ] + "\n";
					logprint( logline1 );
					break;
				case "rsa":
				case "reducedammo":
					logline1 = "CMD:" + player.name + ";AMMO:" + args[ 1 ] + "\n";
					logprint( logline1 );
					if ( !isDefined( args[ 1 ] ) )
					{
						player tell( "You need to specify 1 or 0" );
						break;
					}
					if( int( args[ 1 ] ) == 1 )
					{
						level.grief_gamerules[ "reduced_pistol_ammo" ] = 1;
						say( "Reduced pistol starting ammo is enabled" );
					}
					else if( int( args[ 1 ] ) == 0 )
					{
						level.grief_gamerules[ "reduced_pistol_ammo" ] = 0;
						say( "Reduced pistol starting ammo is disabled" );
					}
					break;
				case "build":
				case "buildables":
					logline1 = "CMD:" + player.name + ";BUILD:" + args[ 1 ] + "\n";
					logprint( logline1 );
					if ( !isDefined( args[ 1 ] ) )
					{
						player tell( "You need to specify 1 or 0" );
						break;
					}
					if( int( args[ 1 ] ) == 1 )
					{
						level.grief_gamerules[ "buildables" ] = 1;
						say( "Buildables are enabled" );
					}
					else if( int( args[ 1 ] ) == 0 )
					{
						level.grief_gamerules[ "buildables" ] = 0;
						say( "Buildables are disabled" );
					}
					break;
				case "zombies":
				case "maxzombies":
					logline1 = "CMD:" + player.name + ";MAXZM:" + args[ 1 ] + "\n";
					logprint( logline1 );
					if ( !isDefined( args[ 1 ] ) )
					{
						player tell( "You need to specify a number" );
						break;
					}
					int_args = int( args[ 1 ] );
					if( int_args <= 32 )
					{
						level.zombie_ai_limit = int_args;
						level.zombie_actor_limit = int_args;
						say( "The max amount of zombies on the map is set to " + int_args );
					}
					else 
					{
						player tell( "The max amount of zombies you can set is 32" );
					}
					break;
				case "bot":
				case "spawnbot":
					bot = addtestClient();
					bot.pers[ "IsBot" ] = 1;
					if ( isDefined( args[ 1 ] ) )
					{
						say( "Bot spawned on team " + args[ 1 ] );
						logline1 = "CMD:" + player.name + ";BOT" + ";TEAM:" + args[ 1 ] + "\n";
						logprint( logline1 );
						bot.custom_team = args[ 1 ];
					}
					else 
					{
						say( "Bot spawned in" );
						logline1 = "CMD:" + player.name + ";BOT:" + "\n";
						logprint( logline1 );
					}
					break;
				case "cmd":
				case "commandlist":
				case "list":
				case "commands":
					if ( !player.printing_commands )
					{
						player thread print_command_list();
					}
					break;
				default:
					player tell( "No such command exists" );
					break;
            }
        }
    }
}

zombie_spawn_delay_fix()
{
	i = 1;
	while ( i <= level.round_number )
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

zombie_speed_fix()
{
	if ( level.gamedifficulty == 0 )
	{
		level.zombie_move_speed = level.round_number * level.zombie_vars[ "zombie_move_speed_multiplier_easy" ];
	}
	else
	{
		level.zombie_move_speed = level.round_number * level.zombie_vars[ "zombie_move_speed_multiplier" ];
	}
}

set_round( round_number )
{
	if ( isDefined( level._grief_reset_message ) )
	{
		level thread [[ level._grief_reset_message ]]();
	}
	level.isresetting_grief = 1;
	level notify( "end_round_think" );
	level.zombie_vars[ "spectators_respawn" ] = 1;
	level notify( "keep_griefing" );
	level.checking_for_round_end = 0;
	level.round_number = round_number;
	zombie_goto_round( round_number );
	zombie_spawn_delay_fix();
	zombie_speed_fix();
	level thread reset_grief();
	level thread maps/mp/zombies/_zm::round_think( 1 );
	level notify( "grief_give_points" );
}

has_permissions_for_command( command, args )
{
	for ( i = 0; i < level.grief_no_permissions_required_commands.size; i++ )
	{
		if ( command == level.grief_no_permissions_required_commands[ i ] )
		{
			return 1;
		}
	}
    for ( i = 0; i < level.server_users[ "Admins" ].guids.size; i++ )
    {
        if ( self getGUID() == level.server_users[ "Admins" ].guids[ i ] )
        {
            return 1;
        }
    }
    return 0;
}

initialize_no_permissions_required_commands()
{
	level.grief_no_permissions_required_commands = [];
	level.grief_no_permissions_required_commands[ 0 ] = "mv";
	level.grief_no_permissions_required_commands[ 1 ] = "mapvote";
	level.grief_no_permissions_required_commands[ 2 ] = "vk";
	level.grief_no_permissions_required_commands[ 3 ] = "votekick";

	level.mapvote_array = [];
	level.mapvote_array[ 0 ] = spawnStruct();
	level.mapvote_array[ 0 ].mapname = "cellblock";
	level.mapvote_array[ 0 ].aliases = array( "c", "cell", "block", "cellblock", "mob" );
	level.mapvote_array[ 0 ].votes = 0;
	level.mapvote_array[ 1 ] = spawnStruct();
	level.mapvote_array[ 1 ].mapname = "borough";
	level.mapvote_array[ 1 ].aliases = array( "s", "street", "borough", "buried" );
	level.mapvote_array[ 1 ].votes = 0;
	level.mapvote_array[ 2 ] = spawnStruct();
	level.mapvote_array[ 2 ].mapname = "farm";
	level.mapvote_array[ 2 ].aliases = array( "f", "farm" );
	level.mapvote_array[ 2 ].votes = 0;
	level.mapvote_array[ 3 ] = spawnStruct();
	level.mapvote_array[ 3 ].mapname = "town";
	level.mapvote_array[ 3 ].aliases = array( "t", "town" );
	level.mapvote_array[ 3 ].votes = 0;
	level.mapvote_array[ 4 ] = spawnStruct();
	level.mapvote_array[ 4 ].mapname = "depot";
	level.mapvote_array[ 4 ].aliases = array( "b", "bus", "depot" );
	level.mapvote_array[ 4 ].votes = 0;
	level.mapvote_array[ 5 ] = spawnStruct();
	level.mapvote_array[ 5 ].mapname = "diner";
	level.mapvote_array[ 5 ].aliases = array( "d", "din", "diner" );
	level.mapvote_array[ 5 ].votes = 0;
	level.mapvote_array[ 6 ] = spawnStruct();
	level.mapvote_array[ 6 ].mapname = "tunnel";
	level.mapvote_array[ 6 ].aliases = array( "t", "tunnel" );
	level.mapvote_array[ 6 ].votes = 0;
	level.mapvote_array[ 7 ] = spawnStruct();
	level.mapvote_array[ 7 ].mapname = "power";
	level.mapvote_array[ 7 ].aliases = array( "p", "pow", "power" );
	level.mapvote_array[ 7 ].votes = 0;
}

mapvote_started()
{
	level endon( "end_game" );
	level endon( "grief_mapvote_ended" );
	while ( true )
	{
		level waittill( "grief_mapvote", vote, player );
		if ( !isDefined( vote ) )
		{
			continue;
		}
		if ( !isDefined( player.previous_votes ) )
		{
			player.previous_votes = [];
		}
		mapname = "NULL";
		for ( i = 0; i < level.mapvote_array.size; i++ )
		{
			if ( mapname != "NULL" )
			{
				player.has_mapvoted_previously = 1;
				break;
			}
			for ( j = 0; j < level.mapvote_array[ i ].aliases.size; j++ )
			{
				if ( level.mapvote_array[ i ].aliases[ j ] == vote )
				{
					mapname = level.mapvote_array[ i ].mapname;
					player.previous_votes[ player.previous_votes.size ] = mapname;
					if ( is_true( player.has_mapvoted_previously ) )
					{
						for ( k = 0; k < player.previous_votes.size; k++ )
						{
							if ( player.previous_votes[ k ] != mapname )
							{
								level.mapvote_array[ i ].votes++;
								player tell( "You voted for " + mapname + " which has " + level.mapvote_array[ i ].votes + "/" + get_vote_threshold() + " votes" );
								logline1 = "MV:" + player.name + ";V:" + mapname + "\n";
								logprint( logline1 );
								break;
							}
						}
					}
					else 
					{
						level.mapvote_array[ i ].votes++;
						player tell( "You voted for " + mapname + " which has " + level.mapvote_array[ i ].votes + "/" + get_vote_threshold() + " votes" );
						logline1 = "MV:" + player.name + ";V:" + mapname + "\n";
						logprint( logline1 );
						break;
					}
				}
			}
		}
		if ( mapname == "NULL" )
		{
			player tell( "Invalid map" );
		}
	}
}

mapvote_count_votes()
{
	level endon( "end_game" );
	level endon( "grief_mapvote_ended" );
	start_time = getTime() / 1000;
	current_time = start_time;
	while ( true )
	{
		for ( i = 0; i < level.mapvote_array.size; i++ )
		{
			if ( level.mapvote_array[ i ].votes >= get_vote_threshold() )
			{
				map = level.mapvote_array[ i ].mapname;
				break;
			}
		}
		if ( isDefined( map ) )
		{
			break;
		}
		if ( ( getTime() / 1000 ) > ( start_time + 600 ) )
		{	
			level notify( "grief_mapvote_ended" );
		}
		wait 0.05;
	}
	level notify( "grief_mapvote_ended", map );
}

mapvote_end()
{
	level waittill( "grief_mapvote_ended", result );
	if ( isDefined( result ) )
	{
		logline1 = "MV;" + "MAP:" + result + "\n";
		logprint( logline1 );
		find_alias_and_set_map( toLower( result ), undefined, 0 );
	}
	else 
	{
		logline1 = "MV:TIMEOUT;" + "\n";
		logprint( logline1 );
		say( "Mapvote timed out!" );
	}
	level.mapvote_in_progress = 0;
	foreach ( player in level.players )
	{
		player.previous_votes = [];
	}
	for ( i = 0; i < level.mapvote_array.size; i++ )
	{
		level.mapvote_array[ i ].votes = 0;
	}
}

clean_player_name_of_clantag( name )
{
	if ( isSubStr( name, "]" ) )
	{
		keys = strTok( name, "]" );
		return keys[ 1 ];
	}
	return name;
}

print_command_list()
{	
	self endon( "command_print_end" );
	self.printing_commands = 1;

	self tell( "!restart" );
	self tell( "!maprotate" );
	self tell( "!resetrotation" );
	self tell( "!map:<mapname>" );
	self tell( "!nextmap:<mapname>" );
	self tell( "!keepmap:<mapname>" );
	self tell( "!kick:<playername>" );
	wait 12;
	self tell( "!magic:<bool>" );
	self tell( "!powerups:<bool>" );
	self tell( "!knifelunge:<bool>" );
	self tell( "!roundnumber:<int>" );
	self tell( "!dvar:<name>:<int>" );
	self tell( "!cvar:<name>:<int>" );
	self tell( "!cvarall:<name>:<int>" );
	wait 12;
	self tell( "!lockserver:<password>" );
	self tell( "!unlockserver" );
	self tell( "!buildables:<bool>" );
	self tell( "!reduceammo:<bool>" );
	self tell( "!maxzombies:<int>" );
	self tell( "!depotjug:<bool>" );
	self tell( "!cellblockjug:<bool>" );

	self.printing_commands = 0;
	self notify( "command_print_end" );
}

end_commands_on_end_game()
{
	level waittill( "end_game" );
	wait 15;
	level notify( "end_commands" );
}

change_level()
{
	level waittill( "end_commands", result );
	wait 0.5;
	switch ( result )
	{
		case 0:
			cmdExecute( "map_restart" );
			break;
		case 1:
			cmdExecute( "map_rotate" );
			break;
		default:
			break;
	}
}

vote_kick_started()
{
	level endon( "end_game" );
	level endon( "grief_votekick_ended" );

	for ( i = 0; i < level.players.size; i++ )
	{
		level.players[ i ].kick_votes = 0;
	}
	while ( true )
	{
		level waittill( "grief_votekick", player_name, player );
		if ( !isDefined( player_name ) )
		{
			continue;
		}
		if ( is_true( player.vk_voted ) )
		{
			continue;
		}
		for( i = 0; i < level.players.size; i++ )
		{
			if ( clean_player_name_of_clantag( player_name ) == clean_player_name_of_clantag( level.players[ i ].name ) )
			{	
				level.players[ i ].kick_votes++;
				player tell( level.players[ i ].name + " has " + level.players[ i ].kick_votes + "/" + get_vote_threshold() + " votes needed to be kicked" );
				player.vk_voted = 1;
			}
		}
	}
}

votekick_count_votes()
{
	level endon( "end_game" );
	level endon( "grief_votekick_ended" );
	start_time = getTime() / 1000;
	while ( true )
	{
		for ( i = 0; i < level.players.size; i++ )
		{
			if ( level.players[ i ].kick_votes >= get_vote_threshold() )
			{
				kick( level.players[ i ] getEntityNumber() );
				say( level.players[ i ].name + " was kicked!" );
				level.votekick_in_progress = 0;
				logline1 = "VK;" + level.players[ i ].name + ":K" + "\n";
				logprint( logline1 );
				for ( i = 0; i < level.players.size; i++ )
				{
					level.players[ i ].vk_voted = 0;
				}
				level notify( "grief_votekick_ended" );
			}
		}
		if ( ( getTime() / 1000 ) > ( start_time + 600 ) )
		{	
			say( "Vote kick timed out!" );
			level.votekick_in_progress = 0;
			logline1 = "VK;TIMEOUT" + "\n";
			logprint( logline1 );
			for ( i = 0; i < level.players.size; i++ )
			{
				level.players[ i ].vk_voted = 0;
			}
			level notify( "grief_votekick_ended" );
		}
		wait 0.05;
	}
}

get_vote_threshold()
{
	switch ( level.players.size )
	{
		case 3:
			return 2;
		case 4:
			return 3;
		case 5:
			return 4;
		case 6:
			return 4;
		case 7:
			return 5;
		case 8:
			return 5;
		default:
			return 99;
	}
}

setup_permissions()
{
    level.server_users = [];
    level.server_users[ "Admins" ] = spawnStruct();
    level.server_users[ "Admins" ].names = [];
    level.server_users[ "Admins" ].guids = [];
    path = level.basepath + "command_permissions.txt";
    file = fopen( path, "r+" );
	buffer = fread( file );
    fclose( file );
	rank_type = strTok( buffer, ":" );
	names_and_guids = strTok( rank_type[ 1 ], "," );
	rank = rank_type[ 0 ];
	for ( j = 0; j < names_and_guids.size; j++ )
	{
		names_keys = strTok( names_and_guids[ j ], "<" );
		level.server_users[ rank ].names[ j ] = names_keys[ 0 ];
	}
	for ( j = 0; j < names_and_guids.size; j++ )
	{
		guids_keys = strTok( names_and_guids[ j ], "<" );
		level.server_users[ rank ].guids[ j ] = int( guids_keys[ 1 ] );
	}
}

find_alias_and_set_map( mapname, player, map_rotate, set_map )
{
    switch ( mapname )
    {
		case "c":
		case "cell":
		case "block":
        case "cellblock":
		case "mob":
            gamemode = "grief";
            location = "cellblock";
            mapname = "zm_prison";
            break;
		case "s":
        case "street":
		case "borough":
		case "buried":
            gamemode = "grief";
            location = "street";
            mapname = "zm_buried";
            break;
		case "f":
        case "farm":
            gamemode = "grief";
            location = "farm";
            mapname = "zm_transit";
            break;
		case "t":
        case "town":
            gamemode = "grief";
            location = "town";
            mapname = "zm_transit";
            break;
		case "b":
		case "bus":
        case "depot":
            gamemode = "grief";
            location = "transit";
            mapname = "zm_transit";
            break;
		case "d":
		case "din":
		case "diner":
            gamemode = "grief";
            location = "diner";
            mapname = "zm_transit";
            break;
		case "tu":
        case "tunnel":
            gamemode = "grief";
            location = "tunnel";
            mapname = "zm_transit";
            break;
		case "p":
		case "pow":
        case "power":
            gamemode = "grief";
            location = "power";
            mapname = "zm_transit";
            break;
        default:
			if ( isDefined( player ) )
			{
				player tell( "Invalid map" );
			}
            return;
    }
    setDvar( "sv_maprotation", "exec zm_" + gamemode + "_" + location + ".cfg" + " map " + mapname );
	setDvar( "sv_maprotationCurrent", "exec zm_" + gamemode + "_" + location + ".cfg" + " map " + mapname );
	if ( map_rotate && !set_map )
	{
		setDvar( "grief_new_map_kept", 1 );
		level thread change_level();
		level notify( "end_commands", 1 );
	}
	else if ( is_true( set_map ) )
	{	
		setDvar( "grief_new_map_kept", 0 );
		level thread change_level();
		level notify( "end_commands", 1 );
	}
	else
	{
		say( "Next map set to " + mapname + " " + location );
		setDvar( "grief_new_map_kept", 1 );
	}
}

set_knife_lunge( arg )
{
	if ( arg == 1 )
	{	
		setDvar( "grief_gamerule_knife_lunge", arg );
		say( "Knife lunge is set to default" );
		foreach ( player in level.players )
		{	
			player setClientDvar( "aim_automelee_range", 120 );
		}
	}
	else if ( arg == 0 )
	{	
		setDvar( "grief_gamerule_knife_lunge", arg );
		say( "Knife lunge is disabled" );
		foreach ( player in level.players )
		{	
			player setClientDvar( "aim_automelee_range", 0 );
		}
	}
}

no_magic()
{	
	no_drops();
	machines = getentarray( "zombie_vending", "targetname" );
	for( i = 0; i < machines.size; i++ )
	{
		level thread perk_machine_removal( machines[ i ].script_noteworthy );
	}
}

no_drops()
{
	flag_clear( "zombie_drop_powerups" );
	level.zombie_include_powerups = [];
	level.zombie_powerup_array= [];
	level.zombie_include_powerups = [];
}