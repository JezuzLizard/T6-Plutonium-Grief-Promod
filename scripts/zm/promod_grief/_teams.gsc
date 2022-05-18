#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\gametypes_zm\_globallogic_ui;

//By overriding this function we intercept the very first time the game attempts to set a players team. 
//Now the default team won't be allies and we don't need to call level.givecustomercharacters unnecessarily.
menuautoassign_override( comingfrommenu )
{
	teamkeys = getarraykeys( level.teams );
	self closemenus();
	if ( level.grief_ffa )
	{
		assignment = level.grief_ffa_team;
	}
	else 
	{
		//Allow forcing a specific player's team to axis or allies in teambased Grief.
		//assignment = self get_assigned_team();
		if ( isDefined( assignment ) )
		{
			switch ( assignment )
			{
				case "allies":
					self._encounters_team = "B";
					break;
				case "axis":
					self._encounters_team = "A";
				default:
					print( "menuautoassign_override() assignment " + assignment + " for player " + self.name + " is invalid\n Valid teams are allies and axis only" );
					break;
			}
		}
		else 
		{
			//Normal team balancing code.
			teamplayersallies = countplayers( "allies" );
			teamplayersaxis = countplayers( "axis" );
			if ( teamplayersallies == teamplayersaxis )
			{
				assignment = "allies";
				self._encounters_team = "B";
			}
			else
			{
				if ( teamplayersallies > teamplayersaxis )
				{
					assignment = "axis";
					self._encounters_team = "A";
				}
				else
				{
					assignment = "allies";
					self._encounters_team = "B";
				}
			}
		}
	}
	self.pers["team"] = assignment;
	self.team = assignment;
	self.pers["class"] = undefined;
	self.class = undefined;
	self.pers["weapon"] = undefined;
	self.pers["savedmodel"] = undefined;
	self updateobjectivetext();

	self.sessionteam = assignment;

	if ( !isalive( self ) )
		self.statusicon = "hud_status_dead";

	//This is for the spawnpoint.script_int code for the spawnpoints we create as well as vanilla spawnpoints.
	//We can use this script_int to make it so where players on one team spawn facing the other team for example.
	if ( !isdefined( level.side_selection ) )
	{
		if ( cointoss() )
			level.side_selection = 1;
		else
			level.side_selection = 2;
	}
	if ( level.side_selection == 1 )
	{
		side_selection = 1;
		if ( assignment == "axis" )
		{
			side_selection = 2;
		}
	}
	else
	{
		side_selection = 2;
		if ( assignment == "axis" )
		{
			side_selection = 1;
		}
	}
	self.spawnpoint_desired_script_int = side_selection;

	self notify( "joined_team" );
	level notify( "joined_team" );
	self notify( "end_respawn" );
	self beginclasschoice();
	self setclientscriptmainmenu( game["menu_class"] );
}

auto_balance_teams()
{
	allies_players = getPlayers( "allies" );
	axis_players = getPlayers( "axis" );
	if ( allies_players.size == axis_players.size )
	{
		return;
	}
	while ( allies_players.size != axis_players.size && ( allies_players.size - 1 ) > axis_players.size )
	{
		random_allies_player = random( allies_players );
		random_allies_player auto_balance_set_team( "axis" );
		allies_players = getPlayers( "allies" );
		axis_players = getPlayers( "axis" );
	}
	while ( allies_players.size != axis_players.size && ( axis_players.size - 1 ) > allies_players.size )
	{
		random_axis_player = random( axis_players );
		random_axis_player auto_balance_set_team( "allies" );
		allies_players = getPlayers( "allies" );
		axis_players = getPlayers( "axis" );
	}
}

auto_balance_set_team( team )
{
	if ( team == "allies" )
	{
		self._encounters_team = "B";
	}
	else 
	{
		self._encounters_team = "A";
	}
	self.pers[ "team" ] = team;
	self.team = team;
	self.sessionteam = team;
	self.characterindex = undefined;
	self [[ level.givecustomcharacters ]]();
}