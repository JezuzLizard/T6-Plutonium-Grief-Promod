#include maps\mp\zombies\_zm_utility;
#include common_scripts\utility;
#include maps\mp\_utility;

debug()
{
    if( !getDvarIntDefault( "debug", 0 ) )
		return;

    level thread spawn_bots(1);
	level thread print_origin();
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
		print( "origin " + level.players[0].origin );
		wait 2;
	}
}

print_angles()
{
	while ( 1 )
	{
		print( "angles " + level.players[0].angles );
		wait 2;
	}
}

print_doors()
{
    zombie_doors = getEntArray( "zombie_door", "targetname" );
    while ( 1 )
    {
		foreach ( door in zombie_doors )
		{
			if ( DistanceSquared( level.players[0].origin, door.origin ) < 128*128 )
			{
				print( door.target );
			}
		}
		wait 2;
    }
}

print_debris()
{
    zombie_debris = getentarray( "zombie_debris", "targetname" );
    while ( 1 )
    {
		foreach ( debris in zombie_debris )
		{
			if ( DistanceSquared( level.players[0].origin, debris.origin ) < 128*128 )
			{
				print( debris.target );
			}
		}
		wait 2;
    }
}