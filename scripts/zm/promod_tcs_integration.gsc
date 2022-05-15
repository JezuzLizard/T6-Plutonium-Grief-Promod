#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;

#include scripts\zm\promod_grief\_gamerules;

main()
{
	while ( !is_true( level.zm_command_init_done ) )
	{
		wait 0.05;
	}
	//Add/remove commands here.
	if ( isDefined( level.tcs_register_generic_player_field ) )
	{
		stats = [];
		stats[ "wins" ] = 0;
		stats[ "losses" ] = 0;
		stats[ "stabs" ] = 0;
		stats[ "revives" ] = 0;
		stats[ "confirms" ] = 0;
		level [[ level.tcs_register_generic_player_field ]]( "stats", stats );
		penalties_array = [];
		penalties_array[ "perm_banned" ] = false;
		penalties_array[ "ban_reason" ] = "none";
		penalties_array[ "perm_team_changing_ban" ] = false;
		penalties_array[ "temp_team_changing_ban" ] = false;
		penalties_array[ "temp_team_changing_ban_time" ] = 0;
		penalties_array[ "temp_team_changing_ban_length" ] = 0;
		penalties_array[ "temp_banned" ] = false;
		penalties_array[ "temp_ban_time" ] = 0;
		penalties_array[ "temp_ban_length" ] = 0;
		penalties_array[ "perm_chat_muted" ] = false;
		penalties_array[ "chat_muted" ] = false;
		penalties_array[ "chat_muted_time" ] = 0;
		penalties_array[ "chat_muted_length" ] = 0;
		level [[ level.tcs_register_generic_player_field ]]( "penalties", penalties_array );
		level [[ level.tcs_register_generic_player_field ]]( "assigned_team", "none" );
	}
	if ( isDefined( level.tcs_add_server_command_func ) )
	{
		// level [[ level.tcs_add_server_command_func ]]( "banfromteamchange", "banfromteamchange banftc", "banfromteamchange <name|guid|clientnum>", ::CMD_BANFROMTEAMCHANGE_f, level.CMD_POWER_MODERATOR );
		// level [[ level.tcs_add_server_command_func ]]( "tempbanfromteamchange", "tempbanfromteamchange tbanftc", "tempbanfromteamchange <name|guid|clientnum> <duration_in_minutes>", ::CMD_TEMPBANFROMTEAMCHANGE_f, level.CMD_POWER_MODERATOR );
		// level [[ level.tcs_add_server_command_func ]]( "setteam", "setteam stm", "setteam <name|guid|clientnum> <teamname>", ::CMD_SETTEAM_f, level.CMD_POWER_ADMIN );
		level [[ level.tcs_add_server_command_func ]]( "setgamerule", "setgamerule sgmrl", "setgamerule <gamerule> <value> [nummatches]", ::CMD_SETGAMERULE_f, level.CMD_POWER_ADMIN );
		level [[ level.tcs_add_server_command_func ]]( "resetgamerule", "resetgamerule rsgmrl", "resetgamerule <gamerule>", ::CMD_RESETGAMERULE_f, level.CMD_POWER_ADMIN );
		level [[ level.tcs_add_server_command_func ]]( "listgamerules", "listgamerules lgmrls", "listgamerules", ::CMD_LISTGAMERULES_f, level.CMD_POWER_ADMIN );
	}
	if ( isDefined( level.tcs_add_client_command_func ) )
	{
	}
}

CMD_RESETGAMERULE_f( arg_list )
{
	result = [];
	if ( array_validate( arg_list ) && arg_list.size > 1 )
	{
		rulename = arg_list[ 0 ];
		if ( isDefined( level.grief_gamerules[ rulename ] ) )
		{
			reset_gamerule( rulename );
			result[ "filter" ] = "cmdinfo";
			result[ "message" ] = va( "Reset %s rule to %s ", rulename, level.grief_gamerules[ rulename ].current );
			level [[ level.tcs_com_printf ]]( "say", "notitle", va( "Reset %s rule to %s", rulename, level.grief_gamerules[ rulename ].current ), self );
		}
		else 
		{
			result[ "filter" ] = "cmderror";
			result[ "message" ] = va( "%s rulename is invalid", rulename );
		}
	}
	else 
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "Usage gamerule <gamerule> <value> [nummatches]";
	}
	return result;
}

CMD_SETGAMERULE_f( arg_list )
{
	result = [];
	if ( array_validate( arg_list ) && arg_list.size > 1 )
	{
		rulename = arg_list[ 0 ];
		if ( isDefined( level.grief_gamerules[ rulename ] ) )
		{
			switch ( level.grief_gamerules[ rulename ].type )
			{
				case "int":
					rulevalue = int( arg_list[ 1 ] );
					break;
				case "float":
					rulevalue = float( arg_list[ 1 ] );
					break;
			}
			if ( isDefined( arg_list[ 2 ] ) )
			{
				number_of_matches = int( arg_list[ 2 ] );
			}
			else 
			{
				number_of_matches = -1;
			}
			if ( number_of_matches == 0 )
			{
				number_of_matches = -1;
			}
			set_gamerule_for_next_matches( rulename, rulevalue, number_of_matches );
			result[ "filter" ] = "cmdinfo";
			if ( number_of_matches <= -1 )
			{
				result[ "message" ] = va( "Set %s to %s forever", rulename, rulevalue ); 
				level [[ level.tcs_com_printf ]]( "say", "notitle", va( "Set %s rule to %s forever", rulename, level.grief_gamerules[ rulename ].current ), self );
			} 
			else 
			{	
				result[ "message" ] = va( "Set %s to %s for %s matches", rulename, rulevalue, number_of_matches );
				level [[ level.tcs_com_printf ]]( "say", "notitle", va( "Set %s rule to %s for %s matches", rulename, level.grief_gamerules[ rulename ].current, number_of_matches ), self );
			}
			
		}
		else 
		{
			result[ "filter" ] = "cmderror";
			result[ "message" ] = va( "%s rulename is invalid", rulename );
		}
	}
	else 
	{
		result[ "filter" ] = "cmderror";
		result[ "message" ] = "Usage gamerule <gamerule> <value> [nummatches]";
	}
	return result;
}

CMD_LISTGAMERULES_f( arg_list )
{
	channel = self [[ level.tcs_com_get_feedback_channel ]]();
	if ( channel != "con" )
	{
		channel = channel + "|iprint";
	}
	gamerules = getArrayKeys( level.grief_gamerules );
	for ( i = 0; i < gamerules.size; i++ )
	{
		level [[ level.tcs_com_printf ]]( channel, "notitle", gamerules[ i ], self );
	}
	if ( !is_true( self.is_server ) )
	{
		level [[ level.tcs_com_printf ]]( channel, "cmdinfo", "Use shift + ` and scroll to the bottom to view the full list", self );
	}
}

CMD_BANFROMTEAMCHANGE_f( arg_list )
{

}

CMD_TEMPBANFROMTEAMCHANGE_f( arg_list )
{

}

CMD_SETTEAM_f( arg_list )
{
	
}