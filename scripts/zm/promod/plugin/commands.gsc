#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include scripts/zm/promod/utility/_grief_util;
#include maps/mp/zombies/_zm_perks;
#include scripts/zm/promod/zgriefp;
#include scripts/zm/promod/zgriefp_overrides;

/*private*/ init_cmd_namespaces()
{
	key_list = "teamcmd,team,t:add,a|teamcmd,team,t:remove,r|teamcmd,team,t:ban,b|teamcmd,team,t:unban,u|teamcmd,team,t:remove,r|teamcmd,team,t:set,s|teamcmd,team,t:perm,p|teamcmd,team,t:unperm,up";
	key_names = "namespace_aliases|command_aliases";
	generate_map( "cmd_namespaces", key_list, key_names );
	level.server = spawnStruct();
	level.server.name = getDvar( "sv_hostname" );
	level.server.is_server = true;
}

//Command struture - namespace:cmd(...);
/*public*/ command_watcher()
{
	level endon( "end_commands" );
	level thread end_commands_on_end_game();
	init_cmd_namespaces();
	while ( true )
	{
		level waittill( "say", player, message );
		if ( isDefined( player ) && !isSubStr( message, "/" ) )
		{
			continue;
		}
		if ( !isDefined( player ) )
		{
			player = level.server;
		}
		multi_cmds = parse_cmd_message( message );
		for ( cmd_index = 0; cmd_index < multi_cmds.size; i++ )
		{
			args = multi_cmds[ cmd_index ][ "args" ];
			namespace = toLower( multi_cmds[ cmd_index ][ "namespace" ] );
			cmdname = toLower( multi_cmds[ cmd_index ][ "cmdname" ] );
			success = true;
			cmd_outcome_log = "";
			chat_say_message = "";
			pm_say_message = "";
			if ( player has_permissions_for_command( cmdname, args ) )
			{
				switch ( namespace )
				{
					case "t":
					case "team":
					case "teamcmd":
						success = execute_team_cmd( cmd, args );
						break;
					case "r":
					case "rank":
						success = execute_rank_cmd( cmd, args );
						break;
					default:
						switch ( cmdname )
						{
							case "fr":
							case "restart":
							case "maprestart":
							case "map_restart":
								cmd_outcome_log = "CMD:" + player.name + ";FR" + "\n";
								level thread change_level();
								level notify( "end_commands", 0 );
								break;
							case "nm":
							case "nextmap":
							case "setnextmap":
								cmd_outcome_log = "CMD:" + player.name + ";NM:" + args[ 0 ] + "\n";
								find_alias_and_set_map( toLower( args[ 0 ] ), player, 0, 0 );
								break;
							case "km":
							case "keepmap":
								cmd_outcome_log = "CMD:" + player.name + ";KM:" + args[ 0 ] + "\n";
								find_alias_and_set_map( toLower( args[ 0 ] ), player, 0, 1 );
								break;
							case "mr":
							case "maprotate":
								cmd_outcome_log = "CMD:" + player.name + ";MR" + "\n";
								level thread change_level();
								level notify( "end_commands", 1 );
								break;
							case "m":
							case "map":
								cmd_outcome_log = "CMD:" + player.name + ";MAP:" + args[ 0 ] + "\n";
								find_alias_and_set_map( toLower( args[ 0 ] ), player, 1 );
								break;
							case "rr":
							case "resetrotation":
								cmd_outcome_log = "CMD:" + player.name + ";RR" + "\n";
								player tell( "Map rotation reset to the default" );
								setDvar( "sv_maprotation", getDvar( "grief_original_rotation" ) );
								setDvar( "sv_maprotationCurrent", getDvar( "grief_original_rotation" ) );
								break;
							case "k":
							case "kick":
								foreach ( player in level.players )
								{
									if ( clean_player_name_of_clantag( player.name ) == clean_player_name_of_clantag( args[ 0 ] ) )
									{
										cmd_outcome_log = "CMD:" + player.name + ";K:" + args[ 0 ] + "\n";
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
									cmd_outcome_log = "CMD:" + player.name + ";MVS:" + args[ 0 ] + "\n";
									level thread mapvote_started();
									level thread mapvote_count_votes();
									level thread mapvote_end();
									level.mapvote_in_progress = 1;
									say( "Mapvote started!" );
								}
								level notify( "grief_mapvote", args[ 0 ], player );
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
									cmd_outcome_log = "CMD:" + player.name + ";VKS:" + args[ 0 ] + "\n";
									level thread vote_kick_started();
									level thread votekick_count_votes();
									level.votekick_in_progress = 1;
									say( "Votekick started!" );
								}
								level notify( "grief_votekick", args[ 0 ], player );
								break;
							case "mag":
							case "magic":
							case "nomagic":
								if ( !isDefined( args[ 0 ] ) )
								{
									say( "Magic is disabled for this round only" );
									no_magic();
									break;
								}
								if ( args[ 0 ] == "0" )
								{	
									cmd_outcome_log = "CMD:" + player.name + ";TOGMAG" + "\n";
									say( "Magic is disabled on the server" );
									setDvar( "grief_gamerule_magic", 0 );
									no_magic();
								}
								if ( args[ 0 ] == "1" )
								{
									say( "Magic will be enabled on the server starting next match" );
									setDvar( "grief_gamerule_magic", 1 );
								}
								break;
							case "np":
							case "drops":
							case "powerups":
								if ( !isDefined( args[ 0 ] ) )
								{
									say( "Powerups are disabled for this match only" );
									no_drops();
									break;
								}
								cmd_outcome_log = "CMD:" + player.name + ";TOGDROPS:" + args[ 0 ] + "\n";
								if ( args[ 0 ] == "0" )
								{
									say( "Powerups are disabled on the server" );
									no_drops();
									setDvar( "grief_gamerule_powerup_restrictions", "all" );
								}
								else if ( args[ 0 ] == "1" )
								{
									say( "Powerups will be enabled on the server starting next match" );
									setDvar( "grief_gamerule_powerup_restrictions", "" );
								}
								break;
							case "rn":
							case "roundnumber":
								if ( !isDefined( args[ 0 ] ) )
								{
									player tell( "You need to specify a round number" );
									break;
								}
								cmd_outcome_log = "CMD:" + player.name + ";ROUND:" + args[ 0 ] + "\n";
								say( "The round is set to " + args[ 0 ] );
								set_round( int( args[ 0 ] ) );
								break;
							case "kl":
							case "knifelunge":
								cmd_outcome_log = "CMD:" + player.name + ";KNIFE:" + args[ 0 ] + "\n";
								set_knife_lunge( int( args[ 0 ] ) );
								break;
							case "d":
							case "dvar":
								if ( !isDefined( args[ 0 ] ) || !isDefined( args[ 1 ] ) )
								{
									player tell( "You need to specify a dvar and its value" );
									break;
								}
								player tell( "Dvar set " + args[ 0 ] + " to " + args[ 1 ] );
								cmd_outcome_log = "CMD:" + player.name + ";DVAR:" + args[ 0 ] + ";VAL:" + args[ 1 ] + "\n";
								setDvar( args[ 0 ], args[ 1 ] );
								break;
							case "cv":
							case "cvar":
								if ( !isDefined( args[ 0 ] ) || !isDefined( args[ 1 ] ) )
								{
									player tell( "You need to specify a dvar and its value" );
									break;
								}
								player tell( "Cvar set " + args[ 0 ] + " to " + args[ 1 ] );
								cmd_outcome_log = "CMD:" + player.name + ";CVAR:" + args[ 0 ] + ";VAL:" + args[ 1 ] + "\n";
								player setClientDvar( args[ 0 ], args[ 1 ] );
								break;
							case "cva":
							case "cvarall":
								if ( !isDefined( args[ 0 ] ) || !isDefined( args[ 1 ] ) )
								{
									player tell( "You need to specify a dvar and its value" );
									break;
								}
								foreach ( player in level.players )
								{
									player tell( "Cvar set " + args[ 0 ] + " to " + args[ 1 ] );
									cmd_outcome_log = "CMD:" + player.name + ";CVARA:" + args[ 0 ] + ";VAL:" + args[ 1 ] + "\n";
									player setClientDvar( args[ 0 ], args[ 1 ] );
								} 
								break;
							case "l":
							case "lock":
							case "lockserver":
								if ( !isDefined( args[ 0 ] ) )
								{
									player tell( "You need to specify a password to lock the server" );
									break;
								}
								player tell( "Server is now password protected" );
								cmd_outcome_log = "CMD:" + player.name + ";LOCK:" + args[ 0 ] + "\n";
								setDvar( "g_password", args[ 0 ] );
								break;
							case "ul":
							case "unlock":
							case "unlockserver":
								player tell( "Server is now open" );
								cmd_outcome_log = "CMD:" + player.name + ";UNLOCK:" + "\n";
								setDvar( "g_password", "" );
								break;
							// case "im":
							// case "intermission":
							// 	level.grief_gamerules[ "intermission_time" ] = args[ 0 ];
							// 	say( "Intermission will take place after next round and last " + args[ 0 ] );
							// 	cmd_outcome_log = "CMD:" + player.name + ";IM" + ";TIME:" + args[ 0 ] + "\n";
							// 	break;
							case "mobjug":
							case "celljug":
							case "cellblockjug":
								if ( !isDefined( args[ 0 ] ) )
								{
									player tell( "You need to specify 1 or 0" );
									break;
								}
								if ( args[ 0 ] == "1" )
								{	
									say( "Jug is enabled on Cellblock" );
									setDvar( "grief_gamerule_cellblock_jug", 1 );
								}
								else if ( args[ 0 ] == "0" )
								{	
									say( "Jug is disabled on Cellblock" );
									setDvar( "grief_gamerule_cellblock_jug", 0 );
								}
								cmd_outcome_log = "CMD:" + player.name + ";MOBJUG:" + args[ 0 ] + "\n";
								break;
							case "depotjug":
								if ( !isDefined( args[ 0 ] ) )
								{
									player tell( "You need to specify 1 or 0" );
									break;
								}
								if ( args[ 0 ] == "1" )
								{	
									say( "Jug is enabled on Bus Depot" );
									setDvar("grief_gamerule_depot_jug", 1 );
								}
								else if ( args[ 0 ] == "0" )
								{	
									say( "Jug is disabled on Bus Depot" );
									setDvar("grief_gamerule_depot_jug", 0 );
								}
								cmd_outcome_log = "CMD:" + player.name + ";DEPOTJUG:" + args[ 0 ] + "\n";
								break;
							case "rsa":
							case "reducedammo":
								cmd_outcome_log = "CMD:" + player.name + ";AMMO:" + args[ 0 ] + "\n";
								if ( !isDefined( args[ 0 ] ) )
								{
									player tell( "You need to specify 1 or 0" );
									break;
								}
								if( int( args[ 0 ] ) == 1 )
								{
									level.grief_gamerules[ "reduced_pistol_ammo" ] = 1;
									say( "Reduced pistol starting ammo is enabled" );
								}
								else if( int( args[ 0 ] ) == 0 )
								{
									level.grief_gamerules[ "reduced_pistol_ammo" ] = 0;
									say( "Reduced pistol starting ammo is disabled" );
								}
								break;
							case "build":
							case "buildables":
								cmd_outcome_log = "CMD:" + player.name + ";BUILD:" + args[ 0 ] + "\n";
								if ( !isDefined( args[ 0 ] ) )
								{
									player tell( "You need to specify 1 or 0" );
									break;
								}
								if( int( args[ 0 ] ) == 1 )
								{
									level.grief_gamerules[ "buildables" ] = 1;
									say( "Buildables are enabled" );
								}
								else if( int( args[ 0 ] ) == 0 )
								{
									level.grief_gamerules[ "buildables" ] = 0;
									say( "Buildables are disabled" );
								}
								break;
							case "zombies":
							case "maxzombies":
								cmd_outcome_log = "CMD:" + player.name + ";MAXZM:" + args[ 0 ] + "\n";
								if ( !isDefined( args[ 0 ] ) )
								{
									player tell( "You need to specify a number" );
									break;
								}
								int_args = int( args[ 0 ] );
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
								bot = addTestClient();
								bot.pers[ "IsBot" ] = 1;
								if ( isDefined( args[ 0 ] ) )
								{
									say( "Bot spawned on team " + args[ 0 ] );
									cmd_outcome_log = "CMD:" + player.name + ";BOT" + ";TEAM:" + args[ 0 ] + "\n";
									bot default_menu_autoassign( args[ 0 ] );
								}
								else 
								{
									say( "Bot spawned in" );
									cmd_outcome_log = "CMD:" + player.name + ";BOT:" + "\n";
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
								success = false;
								break;
						}
				}
				player_array = array( player );
				if ( cmd_outcome_log != "" )
				{
					COM_PRINTF( "g_log", "cmd", cmd_outcome_log );
					if ( is_true( player.is_server ) )
					{
						COM_PRINTF( "con", "cmd", cmd_outcome_log );
					}
				}
				if ( chat_say_message != "" )
				{
					COM_PRINTF( "con say", "cmdinfo", chat_say_message );
				}
				if ( pm_say_message != "" )
				{
					COM_PRINTF( "con tell", "cmdinfo", pm_say_message, player_array );
				}
				if ( !success )
				{
					if ( cmdname != "" )
					{
						expected_cmd_usage = get_first_token_with_key_value( level.command_references, cmdname + "(" );
						bad_cmd_message = strTok( message, ";" );
						if ( is_true( player.is_server ) )
						{
							if ( expected_cmd_usage != "" )
							{
								COM_PRINTF( "con", "cmderror", "Bad command usage" );
								COM_PRINTF( "con", "cmdinfo", "Expected:" + expected_cmd_usage );
								COM_PRINTF( "con", "cmdinfo", "Got:" + bad_cmd_message[ cmd_index ] );
							}
							else 
							{
								if ( namespace != "" )
								{
									is_valid_namespace = false;
									keys = getArrayKeys( level.data_maps[ cmd_namespaces ] );
									foreach ( key in keys )
									{
										if ( isSubStr( key, namespace ) )
										{
											is_valid_namespace = true;
											break;
										}
									}
									if ( !is_valid_namespace )
									{
										COM_PRINTF( "con", "cmderror", "Command bad namespace" );
										COM_PRINTF( "con", "cmdinfo", "Got:" + namespace );
									}
									else 
									{
										COM_PRINTF( "con", "cmderror", "Command not found in namespace" );
										COM_PRINTF( "con", "cmdinfo", "Got:" + namespace + ":" + cmdname );
									}
								}
								else 
								{
									COM_PRINTF( "con", "cmderror", "Invalid command" );
									COM_PRINTF( "con", "cmdinfo", "Got:" + cmdname );
								}
							}
						}
						else 
						{
							if ( expected_cmd_usage != "" )
							{
								COM_PRINTF( "tell", "cmderror", "Bad command usage", player_array );
								COM_PRINTF( "tell", "cmdinfo", "Expected:" + expected_cmd_usage, player_array );
								COM_PRINTF( "tell", "cmdinfo", "Got:" + bad_cmd_message[ cmd_index ], player_array );
							}
							else 
							{
								if ( namespace != "" )
								{
									is_valid_namespace = false;
									keys = getArrayKeys( level.data_maps[ cmd_namespaces ] );
									foreach ( key in keys )
									{
										if ( isSubStr( key, namespace ) )
										{
											is_valid_namespace = true;
											break;
										}
									}
									if ( !is_valid_namespace )
									{
										COM_PRINTF( "tell", "cmderror", "Command bad namespace", player_array );
										COM_PRINTF( "tell", "cmdinfo", "Got:" + namespace, player_array );
									}
									else 
									{
										COM_PRINTF( "tell", "cmderror", "Invalid command", player_array );
										COM_PRINTF( "tell", "cmdinfo", "Got:" + cmdname, player_array );
									}
								}
								else 
								{
									COM_PRINTF( "tell", "cmderror", "Invalid command", player_array );
									COM_PRINTF( "tell", "cmdinfo", "Got:" + cmdname, player_array );
								}
							}
						}
					}
				}
			}
		}
	}
}

/*private*/ set_round( round_number )
{
	start_new_round( true, round_number );
}

/*private*/ has_permissions_for_command( command, args )
{
	for ( i = 0; i < level.grief_no_permissions_required_commands.size; i++ )
	{
		if ( command == level.grief_no_permissions_required_commands[ i ] )
		{
			return true;
		}
	}
	for ( i = 0; i < level.server_users[ "admins" ].guids.size; i++ )
	{
		if ( self getGUID() == level.server_users[ "admins" ].guids[ i ] )
		{
			return true;
		}
	}
	return false;
}

/*private*/ mapvote_started()
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
								cmd_outcome_log = "MV:" + player.name + ";V:" + mapname + "\n";
								logprint( cmd_outcome_log );
								break;
							}
						}
					}
					else 
					{
						level.mapvote_array[ i ].votes++;
						player tell( "You voted for " + mapname + " which has " + level.mapvote_array[ i ].votes + "/" + get_vote_threshold() + " votes" );
						cmd_outcome_log = "MV:" + player.name + ";V:" + mapname + "\n";
						logprint( cmd_outcome_log );
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

/*private*/ mapvote_count_votes()
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

/*private*/ mapvote_end()
{
	level waittill( "grief_mapvote_ended", result );
	if ( isDefined( result ) )
	{
		mapvote_outcome_log = "MV;" + "MAP:" + result + "\n";
		find_alias_and_set_map( toLower( result ), undefined, 0 );
	}
	else 
	{
		cmd_outcome_log = "MV:TIMEOUT;" + "\n";
		say( "Mapvote timed out!" );
	}
	logprint( mapvote_outcome_log );
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

/*private*/ print_command_list()
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

/*private*/ end_commands_on_end_game()
{
	level waittill( "end_game" );
	wait 15;
	clear_non_perm_dvar_entries();
	level notify( "end_commands" );
}

/*private*/ change_level()
{
	level waittill( "end_commands", result );
	wait 0.5;
	switch ( result )
	{
		case 0:
			map_restart( false ); 
			break;
		case 1:
			exitLevel( false );
			break;
		default:
			break;
	}
}

/*private*/ vote_kick_started()
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

/*private*/ votekick_count_votes()
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
				cmd_outcome_log = "VK;" + level.players[ i ].name + ":K" + "\n";
				logprint( cmd_outcome_log );
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
			cmd_outcome_log = "VK;TIMEOUT" + "\n";
			logprint( cmd_outcome_log );
			for ( i = 0; i < level.players.size; i++ )
			{
				level.players[ i ].vk_voted = 0;
			}
			level notify( "grief_votekick_ended" );
		}
		wait 0.05;
	}
}

/*private*/ get_vote_threshold()
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

/*public*/ setup_permissions()
{
	level.server_users = [];
	level.server_users[ "admins" ] = spawnStruct();
	level.server_users[ "admins" ].names = [];
	level.server_users[ "admins" ].guids = [];
	level.server_users[ "admins" ].cmd_rate_limit = -1;
	level.server_users[ "moderators" ] = spawnStruct();
	level.server_users[ "moderators" ].names = [];
	level.server_users[ "moderators" ].guids = [];
	level.server_users[ "moderators" ].cmd_rate_limit = -1;
	level.server_users[ "trusted" ] = spawnStruct();
	level.server_users[ "trusted" ].names = [];
	level.server_users[ "trusted" ].guids = [];
	level.server_users[ "trusted" ].cmd_rate_limit = 2;
	level.server_users[ "default" ] = spawnStruct();
	level.server_users[ "default" ].cmd_rate_limit = 5;
	path = level.basepath + "startup_commands.txt";
	file = fopen( path, "r+" );
	if ( file == -1 )
	{
		print( "Promod FS Error: Failed to open startup_commands.txt" );
		return;
	}
	buffer = fread( file );
	fclose( file );
	multi_cmds = parse_cmd_message( buffer );
	if ( multi_cmds.size == 0 )
	{
		print( "Promod FS Error: Found startup_commands but it was empty" );
		return;
	}
	for ( i = 0; i < multi_cmds.size; i++ )
	{
		args = multi_cmds[ i ][ "args" ];
		namespace = multi_cmds[ i ][ "namespace" ];
		cmdname = multi_cmds[ i ][ "cmdname" ];
	}
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

	level.command_references = "";
	path = level.basepath + "command_references.txt";
	file = fopen( path, "r+" );
	if ( file == -1 )
	{
		print( "Promod FS: Failed to open file " + "command_references.txt" );
		print( "Place the scriptdata folder in storage\\t6 and try again." )
		return;
	}
	level.command_references = fread( file );
	fclose( file );
}

/*private*/ find_alias_and_set_map( mapname, player, map_rotate, set_map )
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

/*private*/ set_knife_lunge( arg )
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

//cmd structure:
//set preset_teams_cmd "remove(player_name,...);" - Removes a player from the preset teams list.
//set preset_teams_cmd "add(player_name,team_name,is_perm,is_banned_from_team_change);add(player_name2,team_name,is_perm);" - Adds a player to team. Optional is_perm arg to determine if dvar doesn't clear if the player isn't in the session.
//set dcmd "ban(player_name,...)"
//set dcmd "unban(player_name,...)"

//set grief_preset_teams "(player_name,team_name,is_perm,is_banned);(player_name,team_name,is_perm,is_banned) etc"

/*private*/ execute_team_cmd( cmd, arg_list )
{
	success = true;
	player_name = arg_list[ 0 ];
	team_name = arg_list[ 1 ];
	is_perm = arg_list[ 2 ];
	is_banned = arg_list[ 3 ];
	switch ( cmd )
	{
		case "r":
		case "remove":
			new_tokens = remove_tokens_from_array( strTok( getDvar( "grief_preset_teams" ), ";" ), player_name );
			setDvar( "grief_preset_teams", concatenate_array( new_tokens, ";" ) );
			break; 
		case "a":
		case "add":
			cur_tokens = strTok( getDvar( "grief_preset_teams" ), ";" );
			new_tokens = [];
			if ( !isDefined( player_name ) || !isDefined( team_name ) )
			{
				print( "Command Error: team:add() missing player or team name arg." );
				return;
			}
			new_tokens = concatenate_array( remove_tokens_from_array( cur_tokens, player_name ), ";" );
			if ( !isDefined( is_perm ) )
			{
				is_perm = "0";
			}
			if ( !isDefined( is_banned ) )
			{
				is_banned = "0";
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
				print( "Command Error: team:add() Bad token detected for is_perm for player: " + player_name );
				print( "cont: Defaulting to false." );
				is_perm = "0";
			}
			add_new_preset_team_token( new_tokens, player_name, team_name, is_perm, is_banned );
			break;
		case "b":
		case "ban":
			set_key_value_from_value( "grief_preset_teams", getDvar( "grief_preset_teams" ), player_name, "is_banned", true );
			set_key_value_from_value( "grief_preset_teams", getDvar( "grief_preset_teams" ), player_name, "is_perm", true );
			break;
		case "u":
		case "unban":
			set_key_value_from_value( "grief_preset_teams", getDvar( "grief_preset_teams" ), player_name, "is_banned", false );
			break;
		case "s":
		case "set":
			if ( isDefined( level.teams[ team_name ] ) )
			{
				set_key_value_from_value( "grief_preset_teams", getDvar( "grief_preset_teams" ), player_name, "team_name", team_name );
			}
			else 
			{
				print( "Command Error: team:set() Undefined or unregistered team." );
			}
			break;
		case "p":
		case "perm":
			set_key_value_from_value( "grief_preset_teams", getDvar( "grief_preset_teams" ), player_name, "is_perm", true );
			break;
		case "up":
		case "unperm":
			set_key_value_from_value( "grief_preset_teams", getDvar( "grief_preset_teams" ), player_name, "is_perm", false );
			break;
		default: 
			success = false;
			break;
	}
	return success;
}

/*private*/ execute_rank_cmd( cmd, arg_list )
{
	//rank::remove(rank), rank::add(rank,cmds,privilges), rank::setplayer(rank), rank::setcmds(cmds), rank::setprivileges(privileges)
}

/*private*/ clear_non_perm_dvar_entries()
{
	string = getDvar( "grief_preset_teams" );
	string_keys = strTok( string, ";" );
	new_entries = [];
	for ( i = 0; i < string_keys.size; i++ )
	{
		if ( get_value_from_indexes( string, i, 2 ) == "1" )
		{
			new_entries[ new_entries.size ] = string_keys[ i ];
		}
	}
	setDvar( "grief_preset_teams", concatenate_array( new_entries, ";" ) );
}