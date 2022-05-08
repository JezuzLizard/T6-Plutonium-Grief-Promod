#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_magicbox;
#include maps\mp\zombies\_zm_unitrigger;
#include maps\mp\zombies\_zm_weapons;

set_default_pistol()
{
	if ( level.script == "zm_tomb" )
	{
		level.default_solo_laststandpistol = "c96_zm";
	}
	else 
	{
		level.default_solo_laststandpistol = "m1911_zm";
	}
}

treasure_chest_init_override( start_chest_name ) //checked changed to match cerberus output
{
	flag_init( "moving_chest_enabled" );
	flag_init( "moving_chest_now" );
	flag_init( "chest_has_been_used" );
	level.chest_moves = 0;
	level.chest_level = 0;
	if ( level.chests.size == 0 )
	{
		return;
	}
	for ( i = 0; i < level.chests.size; i++ )
	{
		level.chests[ i ].box_hacks = [];
		level.chests[ i ].orig_origin = level.chests[ i ].origin;
		level.chests[ i ] get_chest_pieces();
		if ( isDefined( level.chests[ i ].zombie_cost ) )
		{
			level.chests[ i ].old_cost = level.chests[ i ].zombie_cost;
		}
		else 
		{
			level.chests[ i ].old_cost = 950;
		}
	}
	if ( !level.enable_magic || !level.grief_gamerules[ "mystery_box_enabled" ].current )
	{
		foreach( chest in level.chests )
		{
			chest hide_chest();
		}
		return;
	}
	level.chest_accessed = 0;
	if ( level.chests.size > 1 )
	{
		flag_set( "moving_chest_enabled" );
		level.chests = array_randomize( level.chests );
	}
	else
	{
		level.chest_index = 0;
		level.chests[ 0 ].no_fly_away = 1;
	}
	init_starting_chest_location( start_chest_name );
	array_thread( level.chests, ::treasure_chest_think );
}

show_all_weapon_buys_override( player, cost, ammo_cost, is_grenade )
{
	model = getent( self.target, "targetname" );

	if ( isdefined( model ) )
		model thread weapon_show( player );
	else if ( isdefined( self.clientfieldname ) )
		level setclientfield( self.clientfieldname, 1 );

	self.first_time_triggered = 1;

	if ( isdefined( self.stub ) )
		self.stub.first_time_triggered = 1;

	if ( !is_grenade )
		self weapon_set_first_time_hint( cost, ammo_cost );

	if ( !( isdefined( level.dont_link_common_wallbuys ) && level.dont_link_common_wallbuys ) && isdefined( level._spawned_wallbuys ) )
	{
		for ( i = 0; i < level._spawned_wallbuys.size; i++ )
		{
			wallbuy = level._spawned_wallbuys[i];

			if ( isdefined( self.stub ) && isdefined( wallbuy.trigger_stub ) && isDefined( self.stub.clientfieldname ) && self.stub.clientfieldname == wallbuy.trigger_stub.clientfieldname )
			{

			}
			else if ( self.zombie_weapon_upgrade == wallbuy.zombie_weapon_upgrade )
			{
				if ( isdefined( wallbuy.trigger_stub ) && isdefined( wallbuy.trigger_stub.clientfieldname ) )
					level setclientfield( wallbuy.trigger_stub.clientfieldname, 1 );
				else if ( isdefined( wallbuy.target ) )
				{
					model = getent( wallbuy.target, "targetname" );

					if ( isdefined( model ) )
						model thread weapon_show( player );
				}

				if ( isdefined( wallbuy.trigger_stub ) )
				{
					wallbuy.trigger_stub.first_time_triggered = 1;

					if ( isdefined( wallbuy.trigger_stub.trigger ) )
					{
						wallbuy.trigger_stub.trigger.first_time_triggered = 1;

						if ( !is_grenade )
							wallbuy.trigger_stub.trigger weapon_set_first_time_hint( cost, ammo_cost );
					}
				}
				else if ( !is_grenade )
					wallbuy weapon_set_first_time_hint( cost, ammo_cost );
			}
		}
	}
}