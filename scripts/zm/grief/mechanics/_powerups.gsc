#include common_scripts/utility;
#include maps/mp/zombies/_zm_powerups;

get_powerups_allowed()
{
	powerups_allowed = [];
	for ( i = 0; i < level.data_maps[ "powerups" ][ "names" ].size; i++ )
	{
		if ( level.data_maps[ "powerups" ][ "allowed" ][ i ] == "1" )
		{
			powerups_allowed[ powerups_allowed.size ] = level.data_maps[ "powerups" ][ "names" ][ i ];
		}
	}
	return powerups_allowed;
}

powerup_drop_override( drop_point ) //checked partially changed to match cerberus output
{
	return; //Disables vanilla powerup system entirely.
	// if ( level.powerup_drop_count >= level.zombie_vars[ "zombie_powerup_drop_max_per_round" ] )
	// {
	// 	return;
	// }
	// if ( !isDefined( level.zombie_include_powerups ) || level.zombie_include_powerups.size == 0 )
	// {
	// 	return;
	// }
	// if ( !level.grief_gamerules[ "magic" ] )
	// {
	// 	return;
	// }
	// allowed_powerups = get_powerups_allowed();
	// if ( allowed_powerups.size == 0 )
	// {
	// 	return;
	// }
	// rand_drop = randomint( 100 );
	// if ( rand_drop > 2 )
	// {
	// 	if ( !level.zombie_vars[ "zombie_drop_item" ] )
	// 	{
	// 		return;
	// 	}
	// }
	// playable_area = getentarray( "player_volume", "script_noteworthy" );
	// level.powerup_drop_count++;
	// powerup = maps/mp/zombies/_zm_net::network_safe_spawn( "powerup", 1, "script_model", drop_point + ( 0, 0, 40 ) );
	// valid_drop = 0;
	// for ( i = 0; i < playable_area.size; i++ )
	// {
	// 	if ( powerup istouching( playable_area[ i ] ) )
	// 	{
	// 		valid_drop = 1;
	// 		break;
	// 	}
	// }
	// if ( valid_drop && level.rare_powerups_active )
	// {
	// 	pos = ( drop_point[ 0 ], drop_point[ 1 ], drop_point[ 2 ] + 42 );
	// 	if ( check_for_rare_drop_override( pos ) )
	// 	{
	// 		level.zombie_vars[ "zombie_drop_item" ] = 0;
	// 		valid_drop = 0;
	// 	}
	// }
	// if ( !valid_drop )
	// {
	// 	level.powerup_drop_count--;

	// 	powerup delete();
	// 	return;
	// }
	// powerup powerup_setup( random( allowed_powerups ) );
	// powerup thread powerup_timeout();
	// powerup thread powerup_wobble();
	// powerup thread powerup_grab();
	// powerup thread powerup_move();
	// powerup thread powerup_emp();
	// level.zombie_vars[ "zombie_drop_item" ] = 0;
	// level notify( "powerup_dropped", powerup );
}

specific_powerup_drop( powerup_name, drop_spot, powerup_team, powerup_location ) //checked partially changed to match cerberus output
{
	powerup = maps/mp/zombies/_zm_net::network_safe_spawn( "powerup", 1, "script_model", drop_spot + vectorScale( ( 0, 0, 1 ), 40 ) );
	level notify( "powerup_dropped", powerup );
	if ( isDefined( powerup ) )
	{
		powerup powerup_setup( powerup_name, powerup_team, powerup_location );
		powerup thread powerup_timeout();
		powerup thread powerup_wobble();
		powerup thread powerup_grab( powerup_team );
		powerup thread powerup_move();
		powerup thread powerup_emp();
		return powerup;
	}
}