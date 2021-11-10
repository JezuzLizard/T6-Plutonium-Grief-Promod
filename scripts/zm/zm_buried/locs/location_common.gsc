#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/zm_buried_gamemodes;

common_init()
{
	level.buildables_built[ "pap" ] = 1;
	level.equipment_team_pick_up = 1;
	level thread maps/mp/zombies/_zm_buildables::think_buildables();
	powerswitchstate( 1 );
	level.enemy_location_override_func = ::enemy_location_override;
	generatebuildabletarps();
	deletebuildabletarp( "courthouse" );
	deletebuildabletarp( "bar" );
	deletebuildabletarp( "generalstore" );
	deleteSlothBarricade( "juggernaut_alley" );
	deleteSlothBarricade( "jail" );
	deleteSlothBarricade( "candystore_alley" );
	//deleteSlothBarricade( "gun_store_door1" );
	deleteSlothBarricade( "darkwest_nook_door1" );
	//deleteslothbarricades();
	flag_wait( "initial_blackscreen_passed" );
	flag_wait( "start_zombie_round_logic" );
	scripts/zm/grief/gametype_modules/_gamerules::set_power_state( level.grief_gamerules[ "power_state" ] );
	scripts/zm/grief/gametype_modules/_gamerules::perk_restrictions();
	wait 1;
	builddynamicwallbuys();
	buildbuildables();
	turnperkon( "revive" );
	turnperkon( "doubletap" );
	turnperkon( "marathon" );
	turnperkon( "juggernog" );
	turnperkon( "sleight" );
	turnperkon( "additionalprimaryweapon" );
	turnperkon( "Pack_A_Punch" );
}

enemy_location_override( zombie, enemy ) //checked matches cerberus output
{
	location = enemy.origin;
	if ( isDefined( self.reroute ) && self.reroute )
	{
		if ( isDefined( self.reroute_origin ) )
		{
			location = self.reroute_origin;
		}
	}
	return location;
}

builddynamicwallbuys() //checked matches cerberus output
{
	builddynamicwallbuy( "bank", "beretta93r_zm" );
	builddynamicwallbuy( "bar", "pdw57_zm" );
	builddynamicwallbuy( "church", "ak74u_zm" );
	builddynamicwallbuy( "courthouse", "mp5k_zm" );
	builddynamicwallbuy( "generalstore", "m16_zm" );
	builddynamicwallbuy( "mansion", "an94_zm" );
	builddynamicwallbuy( "morgue", "svu_zm" );
	builddynamicwallbuy( "prison", "claymore_zm" );
	builddynamicwallbuy( "stables", "mp5k_zm" );
	builddynamicwallbuy( "stablesroof", "mp5k_zm" );
	builddynamicwallbuy( "toystore", "tazer_knuckles_zm" );
	builddynamicwallbuy( "candyshop", "870mcs_zm" );
}

buildbuildables() //checked matches cerberus output
{	
	if( level.grief_gamerules[ "buildables" ] )
	{
		buildbuildable( "springpad_zm" );
		buildbuildable( "subwoofer_zm" );
		buildbuildable( "turbine" );
	}
}