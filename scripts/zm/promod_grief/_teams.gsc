#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\gametypes_zm\_globallogic_ui;
#include scripts\zm\promod_tcs_integration;

//By overriding this function we intercept the very first time the game attempts to set a players team. 
//Now the default team won't be allies and we don't need to call level.givecustomercharacters unnecessarily.
menuautoassign_override( comingfrommenu )
{
	self closemenus();
	if ( level.grief_ffa )
	{
		assignment = level.grief_ffa_team;
	}
	else 
	{
		//Allow forcing a specific player's team to axis or allies in teambased Grief.
		assignment = self get_assigned_team();
		if ( isDefined( assignment ) && assignment != "none" )
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
					assignment = "allies";
					self._encounters_team = "B";
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
	level.grief_team_members[ assignment ]++;
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
		random_allies_player = allies_players[ randomInt( allies_players.size ) ];
		random_allies_player auto_balance_set_team( "axis", true );
		allies_players = getPlayers( "allies" );
		axis_players = getPlayers( "axis" );
	}
	while ( allies_players.size != axis_players.size && ( axis_players.size - 1 ) > allies_players.size )
	{
		random_axis_player = axis_players[ randomInt( axis_players.size ) ];
		random_axis_player auto_balance_set_team( "allies", true );
		allies_players = getPlayers( "allies" );
		axis_players = getPlayers( "axis" );
	}
}

auto_balance_set_team( team, count_grief_team_members )
{
	if ( team == "allies" )
	{
		self._encounters_team = "B";
	}
	else 
	{
		self._encounters_team = "A";
	}
	if ( level.side_selection == 1 )
	{
		side_selection = 1;
		if ( team == "axis" )
		{
			side_selection = 2;
		}
	}
	else
	{
		side_selection = 2;
		if ( team == "axis" )
		{
			side_selection = 1;
		}
	}
	self.spawnpoint_desired_script_int = side_selection;
	self.pers[ "team" ] = team;
	self.team = team;
	self.sessionteam = team;
	self.characterindex = undefined;
	if ( is_true( count_grief_team_members ) )
	{
		level.grief_team_members[ team ]++;
		level.grief_team_members[ getotherteam( team ) ]--;
	}
	self [[ level.givecustomcharacters ]]();
}

menu_onmenuresponse_override()
{
	self endon( "disconnect" );
	for (;;)
	{
		self waittill( "menuresponse", menu, response );
		if ( response == "back" )
		{
			self closemenu();
			self closeingamemenu();

			continue;
		}

		if ( menu == game[ "menu_team" ] && level.allow_teamchange == "1" )
		{
			self closemenu();
			self closeingamemenu();
			can_switch_teams = false;
			if ( level.grief_team_members[ self.team ] <= 1 )
			{
				self iPrintLn( "You cannot switch teams as the last player on your team" );
			}
			else if ( level.grief_team_members[ getotherteam( self.team ) ] >= 4 )
			{
				self iPrintLn( "You cannot switch teams because it would result in more than four players on a team" );
			}
			else if ( self.team_changes > level.grief_team_changes_max )
			{
				self iPrintLn( "You have swapped teams the maximum amount allowed already" );
			}
			else if ( !is_true( self.switching_teams_next_round ) )
			{
				can_switch_teams = true;
			}
			else 
			{
				self iPrintLn( "You are already switching teams next round" );
			}
			if ( can_switch_teams )
			{
				switch ( response )
				{
					case "allies":
						self thread grief_team_change_logic( "allies" );
						break;
					case "axis":
						self thread grief_team_change_logic( "axis" );
						break;
					case "autoassign":
						self thread grief_team_change_logic( "autoassign" );
						break;
				}
			}
		}
	}
}

grief_team_change_logic( assignment )
{
	level endon( "end_game" );
	self endon( "disconnect" );
	self closemenus();
	if ( self.team == assignment )
	{
		self iPrintLn( "You cannot switch to a team you are already on" );
		return; 
	}
	if ( assignment == "autoassign" )
	{
		assignment = getotherteam( self.team );
	}
	level.grief_team_members[ assignment ]++;
	level.grief_team_members[ self.team ]--;
	self.switching_teams_next_round = true;
	self thread on_disconnect( assignment );
	level waittill( "end_round_think" );
	auto_balance_set_team( assignment );
	self.team_changes++;
	self.switching_teams_next_round = false;
}

getotherencountersteam( encounters_team )
{
	if ( encounters_team == "A" )
	{
		return "B";
	}
	else if ( encounters_team == "B" )
	{
		return "A";
	}
	else 
	{
		return "B";
	}
}

on_disconnect( assignment )
{
	level endon( "end_game" );
	self notify( "restart_disconnect" );
	self endon( "restart_disconnect" );
	team = assignment;
	self waittill( "disconnect" );
	level.grief_team_members[ team ]--;
}
