#include maps\mp\zombies\_zm_utility;
#include common_scripts\utility;
#include maps\mp\_utility;

debug()
{
    if( !getDvarIntDefault( "debug", 0 ) )
		return;

    // level thread spawn_bots(1);
	level waittill( "connected", player );
	// player thread print_origin();
	// player thread print_doors();
}

spawn_bots( num )
{
	bot_amount = getDvarIntDefault("scr_bot_count_zm", 0);

	if(isDefined(num))
		bot_amount = num;

	level waittill( "connected", player );

	level.bots = [];
	for(i = 0; i < bot_amount; i++)
	{
		if(get_players().size == 8)
		{
			break;
		}

		// fixes bot occasionally not spawning
		while(!isDefined(level.bots[i]))
		{
			level.bots[i] = addtestclient();
		}

		level.bots[i].pers["isBot"] = 1;
	}
}

timescale( num )
{
	setDvar("timescale", num);
}

teleport_player( origin )
{
	flag_wait( "initial_blackscreen_passed" );
	level.player[0] setorigin( origin );
}

print_origin()
{
	while ( 1 )
	{
		wait 2;
		print( "origin " + self.origin );
	}
}

print_angles()
{
	while ( 1 )
	{
		wait 2;
		print( "angles " + self.angles );
	}
}

print_doors()
{
    zombie_doors = getEntArray( "zombie_door", "targetname" );
    while ( 1 )
    {
		wait 2;
		foreach ( door in zombie_doors )
		{
			if ( DistanceSquared( self.origin, door.origin ) < 128*128 )
			{
				print( door.target );
			}
		}
    }
}

print_debris()
{
    zombie_debris = getentarray( "zombie_debris", "targetname" );
    while ( 1 )
    {
		wait 2;
		foreach ( debris in zombie_debris )
		{
			if ( DistanceSquared( self.origin, debris.origin ) < 128*128 )
			{
				print( debris.target );
			}
		}
    }
}