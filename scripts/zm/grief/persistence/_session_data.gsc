
init_player_session_data()
{
	if ( !isDefined( level.players_in_session ) )
	{
		level.players_in_session = [];
	}
	if ( !isDefined( level.players_in_session[ self.name ] ) )
	{
		level.players_in_session[ self.name ] = spawnStruct();
		if ( level.grief_gamerules[ "use_preset_teams" ] && self scripts/zm/grief/team/_teams::check_for_predefined_team() )
		{
			level.players_in_session[ self.name ].sessionteam = self.team;
		}
		else 
		{
			level.players_in_session[ self.name ].sessionteam = undefined;
		}
		level.players_in_session[ self.name ].team_change_timer = 0;
		level.players_in_session[ self.name ].team_changed_times = 0;
		level.players_in_session[ self.name ].team_change_ban = false;
		level.players_in_session[ self.name ].time = getTime();
	}
}