
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