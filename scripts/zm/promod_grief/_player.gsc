#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;

afk_kick()
{   
	level endon( "game_ended" );
    self endon("disconnect");
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
        if( time == 4800 ) //4mins
        {
			logprint( "afk kick" );
			print("afk kick");
            kick( self getEntityNumber() );
        }

        wait 0.05;
        time++;
    }
}

monitor_players_connecting_status()
{
	level.num_players_connecting = 0;
	while ( true )
	{
		level waittill( "connecting", player );
		if ( !flag( "initial_players_connected" ) )
		{
			logline1 = "P: " + player.name + " is connecting during loadscreen" + "\n";
			logprint( logline1 );
			player thread kick_player_if_dont_spawn_in_time();
		}
	}
}

kick_player_if_dont_spawn_in_time()
{
	self endon( "spawned_player" );
	wait 20;
	logline1 = "Kicking player because they failed to notify begin in less than 20 seconds during the loadscreen" + "\n";
	logprint( logline1 );
	print("spawned slow");
	kick( self getEntityNumber() );
}

grief_loadout_save( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration )
{
	self.grief_savedweapon_weapons = self getweaponslist();
	self.grief_savedweapon_weaponsammo_stock = [];
	self.grief_savedweapon_weaponsammo_clip = [];
	self.grief_savedweapon_currentweapon = self getcurrentweapon();
	self.grief_savedweapon_grenades = self get_player_lethal_grenade();
	if ( isDefined( self.grief_savedweapon_grenades ) )
	{
		self.grief_savedweapon_grenades_clip = self getweaponammoclip( self.grief_savedweapon_grenades );
	}
	self.grief_savedweapon_tactical = self get_player_tactical_grenade();
	if ( isDefined( self.grief_savedweapon_tactical ) )
	{
		self.grief_savedweapon_tactical_clip = self getweaponammoclip( self.grief_savedweapon_tactical );
	}
	for ( i = 0; i < self.grief_savedweapon_weapons.size; i++ )
	{
		self.grief_savedweapon_weaponsammo_clip[ i ] = self getweaponammoclip( self.grief_savedweapon_weapons[ i ] );
		self.grief_savedweapon_weaponsammo_stock[ i ] = self getweaponammostock( self.grief_savedweapon_weapons[ i ] );
	}
	if ( isDefined( self.hasriotshield ) && self.hasriotshield )
	{
		self.grief_hasriotshield = 1;
	}
	if ( self hasweapon( "claymore_zm" ) )
	{
		self.grief_savedweapon_claymore = 1;
		self.grief_savedweapon_claymore_clip = self getweaponammoclip( "claymore_zm" );
	}
}

track_players_intersection_tracker_override()
{
	self endon( "disconnect" );
	self endon( "death" );
	level endon( "end_game" );
	wait 5;
	while ( 1 )
	{
		killed_players = 0;
		players = getPlayers();
		i = 0;
		while ( i < players.size )
		{
			if ( players[ i ] maps\mp\zombies\_zm_laststand::player_is_in_laststand() || players[ i ].sessionstate != "playing" )
			{
				i++;
				continue;
			}
			j = 0;
			while ( j < players.size )
			{
				if ( j == i || players[ j ] maps\mp\zombies\_zm_laststand::player_is_in_laststand() || players[ j ].sessionstate != "playing" )
				{
					j++;
					continue;
				}
				playeri_origin = players[ i ].origin;
				playerj_origin = players[ j ].origin;
				if ( abs( playeri_origin[ 2 ] - playerj_origin[ 2 ] ) > 60 )
				{
					j++;
					continue;
				}
				distance_apart = distance2d( playeri_origin, playerj_origin );
				if ( abs( distance_apart ) > 18 )
				{
					j++;
					continue;
				}
				if ( players[ i ] getStance() == "prone" )
				{
					players[ i ].is_grief_jumped_on = true;
				}
				else if ( players[ j ] getStance() == "prone" )
				{
					players[ j ].is_grief_jumped_on = true;
				}
				players[ i ] dodamage( 1000, ( 0, 0, 1 ) );
				players[ j ] dodamage( 1000, ( 0, 0, 1 ) );
				if ( !killed_players )
				{
					players[ i ] playlocalsound( level.zmb_laugh_alias );
				}
				if ( is_true( players[ j ].is_grief_jumped_on ) )
				{
					// obituary_message = create_griefed_obituary_msg( players[ i ], players[ j ], "none", "MOD_IMPACT" );
					// players = array( players[ i ], players[ j ] );
					//COM_PRINTF( "obituary g_log", "obituary", obituary_message, players );
					players[ i ].is_grief_jumped_on = undefined;
					obituary( players[ j ], players[ i ], "none", "MOD_IMPACT" );
				}
				else if ( is_true( players[ i ].is_grief_jumped_on ) )
				{
					// obituary_message = create_griefed_obituary_msg( players[ j ], players[ i ], "none", "MOD_IMPACT" );
					// players = array( players[ j ], players[ i ] );
					//COM_PRINTF( "obituary g_log", "obituary", obituary_message, players );
					players[ j ].is_grief_jumped_on = undefined;
					obituary( players[ i ], players[ j ], "none", "MOD_IMPACT" );
				}
				killed_players = 1;
				j++;
			}
			i++;
		}
		wait 0.5;
	}
}

instructions_on_all_players()
{
	level endon( "end_game" );
	wait 15;
	flag_wait( "initial_blackscreen_passed" );
	players = getPlayers();
	if ( isDefined( players ) && ( players.size > 0 ) )
	{
		foreach ( player in players )
		{
			player thread instructions();
		}
	}
}

instructions()
{
	if(!level.grief_gamerules[ "display_instructions" ].current)
		return;

	level endon( "end_game" );
	self endon( "disconnect" );

	level waittill( "initial_blackscreen_passed" );
	rounds = level.grief_gamerules[ "scorelimit" ].current;
	self iPrintLn( "Welcome to Grief!" );
	wait 3;
	self iPrintLn( "Your goal is to win " + rounds + " rounds" );
	wait 3;
	self iPrintLn( "Win a round by downing the entire other team" );
	wait 3;
	self iPrintLn( "Good luck!" );
	wait 3;
	self iPrintLn( "Made by JezuzLizard and 5and5" );
}

check_quickrevive_for_hotjoin() //checked changed to match cerberus output
{
	flag_clear( "solo_game" );
	level.using_solo_revive = false;
	level.revive_machine_is_solo = false;
	maps\mp\zombies\_zm::set_default_laststand_pistol( false );
	if ( isDefined( level.quick_revive_machine ) )
	{
		maps\mp\zombies\_zm::update_quick_revive( false );
	}
}