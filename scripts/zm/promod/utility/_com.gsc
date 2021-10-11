/*private*/ COM_INIT()
{
	COM_ADDFILTER( "info", 1 );
	COM_ADDFILTER( "warning", 1 );
	COM_ADDFILTER( "error", 1 );
	COM_ADDFILTER( "cmdinfo", 1 );
	COM_ADDFILTER( "cmdwarning", 1 );
	COM_ADDFILTER( "cmderror", 1 );
	COM_ADDFILTER( "debug", 0 );
	COM_ADDFILTER( "obituary", 1 );
	COM_ADDFILTER( "notitle", 1 );

	COM_ADDCHANNEL( "con", ::COM_PRINT );
	COM_ADDCHANNEL( "g_log", ::COM_LOGPRINT );
	COM_ADDCHANNEL( "con_log", ::COM_CONSOLELOGPRINT );
	COM_ADDCHANNEL( "iprint", ::COM_IPRINTLN );
	COM_ADDCHANNEL( "iprintbold", ::COM_IPRINTLNBOLD );
	COM_ADDCHANNEL( "say", ::COM_SAY );
	COM_ADDCHANNEL( "tell", ::COM_TELL );
	COM_ADDCHANNEL( "obituary", ::COM_OBITUARY );
}

/*private*/ COM_ADDFILTER( filter, default_value )
{
	if ( !isDefined( level.com_filters ) )
	{
		level.com_filters = [];
	}
	if ( !isDefined( level.com_filters[ filter ] ) )
	{
		level.com_filters[ filter ] = getDvarIntDefault( "com_script_channel_" + filter, default_value );
	}
}

/*private*/ COM_ADDCHANNEL( channel, func )
{
	if ( !isDefined( level.com_channels ) )
	{
		level.com_channels = [];
	}
	if ( !isDefined( level.com_channels[ channel ] ) )
	{
		level.com_channels[ channel ] = func;
	}
}

/*public*/ COM_IS_FILTER_ACTIVE( filter )
{
	return is_true( level.com_filters[ filter ] );
}

/*public*/ COM_IS_CHANNEL_ACTIVE( channel )
{
	return isDefined( level.com_channels[ channel ] );
}

/*private*/ COM_CAPS_MSG_TITLE( filter )
{
	return filter != "notitle" ? toUpper( filter ) + ":" : "";
}

/*private*/ COM_PRINT( channel, message, players )
{
	print( message );
}

/*private*/ COM_LOGPRINT( channel, message, players )
{
	logPrint( message + "/n" );
}

/*private*/ COM_CONSOLELOGPRINT( channel, message, players )
{
	//consoleLogPrint( message );
}

/*private*/ COM_IPRINTLN( channel, message, players )
{
	if ( array_validate( players ) )
	{
		for ( i = 0; i < players.size; i++ )
		{
			if ( isPlayer( players[ i ] ) && !is_true( players[ i ].is_server ) )
			{
				players[ i ] iPrintLn( message );
			}
		}
	}
	else if ( isDefined( players ) && !is_true( players.is_server ) )
	{
		players iPrintLn( message );
	}
	else 
	{
		COM_PRINTF( "con con_log", "error", va( "COM_PRINTF() msg %s sent for channel %s has bad players arg", message, channel ) );
	}
}

/*private*/ COM_IPRINTLNBOLD( channel, message, players )
{
	if ( array_validate( players ) )
	{
		for ( i = 0; i < players.size; i++ )
		{
			if ( isPlayer( players[ i ] ) && !is_true( players[ i ].is_server ) )
			{
				players[ i ] iPrintLnBold( message );
			}
		}
	}
	else if ( isDefined( players ) && !is_true( players.is_server ) )
	{
		players iPrintLnBold( message );
	}
	else 
	{
		COM_PRINTF( "con con_log", "error", va( "COM_PRINTF() msg %s sent for channel %s has bad players arg", message, channel ) );
	}
}

/*private*/ COM_SAY( channel, message, players )
{
	say( message );
}

/*private*/ COM_TELL( channel, message, players )
{
	if ( array_validate( players ) )
	{
		for ( i = 0; i < players.size; i++ )
		{
			if ( isPlayer( players[ i ] ) && !is_true( players[ i ].is_server ) )
			{
				players[ i ] tell( message );
			}
		}
	}
	else if ( isDefined( players ) && !is_true( players.is_server ) )
	{
		players tell( message );
	}
	else 
	{
		COM_PRINTF( "con con_log", "error", va( "COM_PRINTF() msg %s sent for channel %s has bad players arg", message, channel ) );
	}
}

/*private*/ COM_OBITUARY( channel, message, players )
{
	if ( array_validate( players ) )
	{
		victim = players[ 0 ];
		attacker = players[ 1 ];
		obituary( victim, attacker, victim.last_griefed_by.weapon, victim.last_griefed_by.meansofdeath );
	}
	else 
	{
		COM_PRINTF( "con con_log", "error", va( "COM_PRINTF() channel %s requires an array of two players", channel ) );
	}
}

/*public*/ COM_PRINTF( channels, filter, message, players )
{
	channel_keys = strTok( channels, " " );
	foreach ( channel in channel_keys )
	{
		if ( COM_IS_CHANNEL_ACTIVE( channel ) && COM_IS_FILTER_ACTIVE( filter ) )
		{
			message = COM_CAPS_MSG_TITLE( filter ) + message;
			[[ level.com_channels[ channel ] ]]( channel, message, players );
		}
		else 
		{
			if ( COM_IS_FILTER_ACTIVE( filter ) )
			{
				COM_PRINTF( "con con_log", "error", va( "COM_PRINTF() failed to send message %s to channel %s using filter %s", message, channel, filter ) );
			}
		}
	}
}