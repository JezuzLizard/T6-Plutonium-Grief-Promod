#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/zombies/_zm_pers_upgrades_functions;
#include maps/mp/zombies/_zm_power;
#include maps/mp/zombies/_zm_perks;

perk_set_max_health_if_jugg_override( perk, set_premaxhealth, clamp_health_to_max_health ) //checked matches cerberus output
{
	max_total_health = undefined;
	if ( perk == "specialty_armorvest" )
	{
		if ( set_premaxhealth )
		{
			self.premaxhealth = self.maxhealth;
		}
		max_total_health = level.zombie_vars[ "zombie_perk_juggernaut_health" ];
	}
	else if ( perk == "specialty_armorvest_upgrade" )
	{
		if ( set_premaxhealth )
		{
			self.premaxhealth = self.maxhealth;
		}
		max_total_health = level.zombie_vars[ "zombie_perk_juggernaut_health_upgrade" ];
	}
	else if ( perk == "jugg_upgrade" )
	{
		if ( set_premaxhealth )
		{
			self.premaxhealth = self.maxhealth;
		}
		if ( self hasperk( "specialty_armorvest" ) )
		{
			max_total_health = level.zombie_vars[ "zombie_perk_juggernaut_health" ];
		}
		else
		{
			max_total_health = 100;
		}
	}
	else
	{
		if ( perk == "health_reboot" )
		{
			max_total_health = getDvarIntDefault( "health_player_maxhealth", 100 );
		}
	}
	if ( isDefined( max_total_health ) )
	{
		if ( self maps/mp/zombies/_zm_pers_upgrades_functions::pers_jugg_active() )
		{
			max_total_health += level.pers_jugg_upgrade_health_bonus;
		}
		self setmaxhealth( max_total_health );
		if ( isDefined( clamp_health_to_max_health ) && clamp_health_to_max_health == 1 )
		{
			if ( self.health > self.maxhealth )
			{
				self.health = self.maxhealth;
			}
		}
	}
}

turn_jugger_on_override() //checked changed to match cerberus output
{
	while ( 1 )
	{
		machine = getentarray( "vending_jugg", "targetname" );
		machine_triggers = getentarray( "vending_jugg", "target" );
		if ( !array_validate ( machine ) || !array_validate( machine_triggers ) )
		{
			return;
		}
		for ( i = 0; i < machine.size; i++ )
		{
			machine[ i ] setmodel( level.machine_assets[ "juggernog" ].off_model );
		}
		level thread do_initial_power_off_callback( machine, "juggernog" );
		array_thread( machine_triggers, ::set_power_on, 0 );
		level waittill( "juggernog_on" );
		for ( i = 0; i < machine.size; i++ )
		{
			machine[ i ] setmodel( level.machine_assets[ "juggernog" ].on_model );
			machine[ i ] vibrate( vectorScale( ( 0, -1, 0 ), 100 ), 0.3, 0.4, 3 );
			machine[ i ] playsound( "zmb_perks_power_on" );
			machine[ i ] thread perk_fx( "jugger_light" );
			machine[ i ] thread play_loop_on_machine();
		}
		level notify( "specialty_armorvest_power_on" );
		array_thread( machine_triggers, ::set_power_on, 1 );
		if ( isDefined( level.machine_assets[ "juggernog" ].power_on_callback ) )
		{
			array_thread( machine, level.machine_assets[ "juggernog" ].power_on_callback );
		}
		level waittill( "juggernog_off" );
		if ( isDefined( level.machine_assets[ "juggernog" ].power_off_callback ) )
		{
			array_thread( machine, level.machine_assets[ "juggernog" ].power_off_callback );
		}
		array_thread( machine, ::turn_perk_off );
	}
}

turn_doubletap_on_override() //checked changed to match cerberus output
{
	while ( 1 )
	{
		machine = getentarray( "vending_doubletap", "targetname" );
		machine_triggers = getentarray( "vending_doubletap", "target" );
		if ( !array_validate ( machine ) || !array_validate( machine_triggers ) )
		{
			return;
		}
		for ( i = 0; i < machine.size; i++ )
		{
			machine[ i ] setmodel( level.machine_assets[ "doubletap" ].off_model );
		}
		level thread do_initial_power_off_callback( machine, "doubletap" );
		array_thread( machine_triggers, ::set_power_on, 0 );
		level waittill( "doubletap_on" );
		for ( i = 0; i < machine.size; i++ )
		{
			machine[ i ] setmodel( level.machine_assets[ "doubletap" ].on_model );
			machine[ i ] vibrate( vectorScale( ( 0, -1, 0 ), 100 ), 0.3, 0.4, 3 );
			machine[ i ] playsound( "zmb_perks_power_on" );
			machine[ i ] thread perk_fx( "doubletap_light" );
			machine[ i ] thread play_loop_on_machine();
		}
		level notify( "specialty_rof_power_on" );
		array_thread( machine_triggers, ::set_power_on, 1 );
		if ( isDefined( level.machine_assets[ "doubletap" ].power_on_callback ) )
		{
			array_thread( machine, level.machine_assets[ "doubletap" ].power_on_callback );
		}
		level waittill( "doubletap_off" );
		if ( isDefined( level.machine_assets[ "doubletap" ].power_off_callback ) )
		{
			array_thread( machine, level.machine_assets[ "doubletap" ].power_off_callback );
		}
		array_thread( machine, ::turn_perk_off );
	}
}

turn_sleight_on_override() //checked changed to match cerberus output
{
	while ( 1 )
	{
		machine = getentarray( "vending_sleight", "targetname" );
		machine_triggers = getentarray( "vending_sleight", "target" );
		if ( !array_validate ( machine ) || !array_validate( machine_triggers ) )
		{
			return;
		}
		for ( i = 0; i < machine.size; i++ )
		{
			machine[ i ] setmodel( level.machine_assets[ "speedcola" ].off_model );
		}
		level thread do_initial_power_off_callback( machine, "speedcola" );
		array_thread( machine_triggers, ::set_power_on, 0 );
		level waittill( "sleight_on" );
		for ( i = 0; i < machine.size; i++ )
		{
			machine[ i ] setmodel( level.machine_assets[ "speedcola" ].on_model );
			machine[ i ] vibrate( vectorScale( ( 0, -1, 0 ), 100 ), 0.3, 0.4, 3 );
			machine[ i ] playsound( "zmb_perks_power_on" );
			machine[ i ] thread perk_fx( "sleight_light" );
			machine[ i ] thread play_loop_on_machine();
		}
		array_thread( machine_triggers, ::set_power_on, 1 );
		if ( isDefined( level.machine_assets[ "speedcola" ].power_on_callback ) )
		{
			array_thread( machine, level.machine_assets[ "speedcola" ].power_on_callback );
		}
		level notify( "specialty_fastreload_power_on" );
		level waittill( "sleight_off" );
		array_thread( machine, ::turn_perk_off );
		if ( isDefined( level.machine_assets[ "speedcola" ].power_off_callback ) )
		{
			array_thread( machine, level.machine_assets[ "speedcola" ].power_off_callback );
		}
	}
}

turn_marathon_on_override() //checked changed to match cerberus output
{
	while ( 1 )
	{
		machine = getentarray( "vending_marathon", "targetname" );
		machine_triggers = getentarray( "vending_marathon", "target" );
		if ( !array_validate ( machine ) || !array_validate( machine_triggers ) )
		{
			return;
		}
		for ( i = 0; i < machine.size; i++ )
		{
			machine[ i ] setmodel( level.machine_assets[ "marathon" ].off_model );
		}
		array_thread( machine_triggers, ::set_power_on, 0 );
		level thread do_initial_power_off_callback( machine, "marathon" );
		level waittill( "marathon_on" );
		for ( i = 0; i < machine.size; i++ )
		{
			machine[ i ] setmodel( level.machine_assets[ "marathon" ].on_model );
			machine[ i ] vibrate( vectorScale( ( 0, -1, 0 ), 100 ), 0.3, 0.4, 3 );
			machine[ i ] playsound( "zmb_perks_power_on" );
			machine[ i ] thread perk_fx( "marathon_light" );
			machine[ i ] thread play_loop_on_machine();
			i++;
		}
		level notify( "specialty_longersprint_power_on" );
		array_thread( machine_triggers, ::set_power_on, 1 );
		if ( isDefined( level.machine_assets[ "marathon" ].power_on_callback ) )
		{
			array_thread( machine, level.machine_assets[ "marathon" ].power_on_callback );
		}
		level waittill( "marathon_off" );
		if ( isDefined( level.machine_assets[ "marathon" ].power_off_callback ) )
		{
			array_thread( machine, level.machine_assets[ "marathon" ].power_off_callback );
		}
		array_thread( machine, ::turn_perk_off );
	}
}

turn_deadshot_on_override() //checked changed to match cerberus output
{
	while ( 1 )
	{
		machine = getentarray( "vending_deadshot_model", "targetname" );
		machine_triggers = getentarray( "vending_deadshot", "target" );
		if ( !array_validate ( machine ) || !array_validate( machine_triggers ) )
		{
			return;
		}
		for ( i = 0; i < machine.size; i++ )
		{
			machine[ i ] setmodel( level.machine_assets[ "deadshot" ].off_model );
		}
		level thread do_initial_power_off_callback( machine, "deadshot" );
		array_thread( machine_triggers, ::set_power_on, 0 );
		level waittill( "deadshot_on" );
		for ( i = 0; i < machine.size; i++ )
		{
			machine[ i ] setmodel( level.machine_assets[ "deadshot" ].on_model );
			machine[ i ] vibrate( vectorScale( ( 0, -1, 0 ), 100 ), 0.3, 0.4, 3 );
			machine[ i ] playsound( "zmb_perks_power_on" );
			machine[ i ] thread perk_fx( "deadshot_light" );
			machine[ i ] thread play_loop_on_machine();
		}
		level notify( "specialty_deadshot_power_on" );
		array_thread( machine_triggers, ::set_power_on, 1 );
		if ( isDefined( level.machine_assets[ "deadshot" ].power_on_callback ) )
		{
			array_thread( machine, level.machine_assets[ "deadshot" ].power_on_callback );
		}
		level waittill( "deadshot_off" );
		if ( isDefined( level.machine_assets[ "deadshot" ].power_off_callback ) )
		{
			array_thread( machine, level.machine_assets[ "deadshot" ].power_off_callback );
		}
		array_thread( machine, ::turn_perk_off );
	}
}

turn_tombstone_on_override() //checked changed to match cerberus output
{
	level endon( "tombstone_removed" );
	while ( 1 )
	{
		machine = getentarray( "vending_tombstone", "targetname" );
		machine_triggers = getentarray( "vending_tombstone", "target" );
		if ( !array_validate ( machine ) || !array_validate( machine_triggers ) )
		{
			return;
		}
		for ( i = 0; i < machine.size; i++ )
		{
			machine[ i ] setmodel( level.machine_assets[ "tombstone" ].off_model );
		}
		level thread do_initial_power_off_callback( machine, "tombstone" );
		array_thread( machine_triggers, ::set_power_on, 0 );
		level waittill( "tombstone_on" );
		for ( i = 0; i < machine.size; i++ )
		{
			machine[ i ] setmodel( level.machine_assets[ "tombstone" ].on_model );
			machine[ i ] vibrate( vectorScale( ( 0, -1, 0 ), 100 ), 0.3, 0.4, 3 );
			machine[ i ] playsound( "zmb_perks_power_on" );
			machine[ i ] thread perk_fx( "tombstone_light" );
			machine[ i ] thread play_loop_on_machine();
		}
		level notify( "specialty_scavenger_power_on" );
		array_thread( machine_triggers, ::set_power_on, 1 );
		if ( isDefined( level.machine_assets[ "tombstone" ].power_on_callback ) )
		{
			array_thread( machine, level.machine_assets[ "tombstone" ].power_on_callback );
		}
		level waittill( "tombstone_off" );
		if ( isDefined( level.machine_assets[ "tombstone" ].power_off_callback ) )
		{
			array_thread( machine, level.machine_assets[ "tombstone" ].power_off_callback );
		}
		array_thread( machine, ::turn_perk_off );
		players = get_players();
		foreach ( player in players )
		{
			player.hasperkspecialtytombstone = undefined;
		}
	}
}

turn_additionalprimaryweapon_on_override() //checked changed to match cerberus output
{
	while ( 1 )
	{
		machine = getentarray( "vending_additionalprimaryweapon", "targetname" );
		machine_triggers = getentarray( "vending_additionalprimaryweapon", "target" );
		if ( !array_validate ( machine ) || !array_validate( machine_triggers ) )
		{
			return;
		}
		for ( i = 0; i < machine.size; i++ )
		{
			machine[ i ] setmodel( level.machine_assets[ "additionalprimaryweapon" ].off_model );
		}
		level thread do_initial_power_off_callback( machine, "additionalprimaryweapon" );
		array_thread( machine_triggers, ::set_power_on, 0 );
		level waittill( "additionalprimaryweapon_on" );
		for ( i = 0; i < machine.size; i++ )
		{
			machine[ i ] setmodel( level.machine_assets[ "additionalprimaryweapon" ].on_model );
			machine[ i ] vibrate( vectorScale( ( 0, -1, 0 ), 100 ), 0.3, 0.4, 3 );
			machine[ i ] playsound( "zmb_perks_power_on" );
			machine[ i ] thread perk_fx( "additionalprimaryweapon_light" );
			machine[ i ] thread play_loop_on_machine();
		}
		level notify( "specialty_additionalprimaryweapon_power_on" );
		array_thread( machine_triggers, ::set_power_on, 1 );
		if ( isDefined( level.machine_assets[ "additionalprimaryweapon" ].power_on_callback ) )
		{
			array_thread( machine, level.machine_assets[ "additionalprimaryweapon" ].power_on_callback );
		}
		level waittill( "additionalprimaryweapon_off" );
		if ( isDefined( level.machine_assets[ "additionalprimaryweapon" ].power_off_callback ) )
		{
			array_thread( machine, level.machine_assets[ "additionalprimaryweapon" ].power_off_callback );
		}
		array_thread( machine, ::turn_perk_off );
	}
}

turn_chugabud_on_override() //checked changed to match cerberus output
{
	maps/mp/zombies/_zm_chugabud::init();
	if ( isDefined( level.vsmgr_prio_visionset_zm_whos_who ) )
	{
		maps/mp/_visionset_mgr::vsmgr_register_info( "visionset", "zm_whos_who", 5000, level.vsmgr_prio_visionset_zm_whos_who, 1, 1 );
	}
	while ( 1 )
	{
		machine = getentarray( "vending_chugabud", "targetname" );
		machine_triggers = getentarray( "vending_chugabud", "target" );
		if ( !array_validate ( machine ) || !array_validate( machine_triggers ) )
		{
			return;
		}
		for ( i = 0; i < machine.size; i++ )
		{
			machine[ i ] setmodel( level.machine_assets[ "whoswho" ].off_model );
		}
		level thread do_initial_power_off_callback( machine, "whoswho" );
		array_thread( machine_triggers, ::set_power_on, 0 );
		level waittill( "chugabud_on" );
		for ( i = 0; i < machine.size; i++ )
		{
			machine[ i ] setmodel( level.machine_assets[ "whoswho" ].on_model );
			machine[ i ] vibrate( vectorScale( ( 0, -1, 0 ), 100 ), 0.3, 0.4, 3 );
			machine[ i ] playsound( "zmb_perks_power_on" );
			machine[ i ] thread perk_fx( "tombstone_light" );
			machine[ i ] thread play_loop_on_machine();
		}
		level notify( "specialty_finalstand_power_on" );
		array_thread( machine_triggers, ::set_power_on, 1 );
		if ( isDefined( level.machine_assets[ "whoswho" ].power_on_callback ) )
		{
			array_thread( machine, level.machine_assets[ "whoswho" ].power_on_callback );
		}
		level waittill( "chugabud_off" );
		if ( isDefined( level.machine_assets[ "whoswho" ].power_off_callback ) )
		{
			array_thread( machine, level.machine_assets[ "whoswho" ].power_off_callback );
		}
		array_thread( machine, ::turn_perk_off );
		players = get_players();
		foreach ( player in players )
		{
			player.hasperkspecialtychugabud = undefined;
		}
	}
}

turn_revive_on_override() //checked partially changed to match cerberus output
{
	level endon( "stop_quickrevive_logic" );
	machine = getentarray( "vending_revive", "targetname" );
	machine_triggers = getentarray( "vending_revive", "target" );
	machine_model = undefined;
	machine_clip = undefined;
	if ( !is_true( level.zombiemode_using_revive_perk ) )
	{
		return;
	}
	flag_wait( "start_zombie_round_logic" );
	players = get_players();
	solo_mode = 0;
	if ( use_solo_revive() )
	{
		solo_mode = 1;
	}
	start_state = 0;
	start_state = solo_mode;
	while ( 1 )
	{
		machine = getentarray( "vending_revive", "targetname" );
		machine_triggers = getentarray( "vending_revive", "target" );
		if ( !array_validate ( machine ) || !array_validate( machine_triggers ) )
		{
			return;
		}
		for ( i = 0; i < machine.size; i++ )
		{
			if ( flag_exists( "solo_game" ) && flag_exists( "solo_revive" ) && flag( "solo_game" ) && flag( "solo_revive" ) )
			{
				machine[ i ] hide();
			}
			machine[ i ] setmodel( level.machine_assets[ "revive" ].off_model );
			if ( isDefined( level.quick_revive_final_pos ) )
			{
				level.quick_revive_default_origin = level.quick_revive_final_pos;
			}
			if ( !isDefined( level.quick_revive_default_origin ) )
			{
				level.quick_revive_default_origin = machine[ i ].origin;
				level.quick_revive_default_angles = machine[ i ].angles;
			}
			level.quick_revive_machine = machine[ i ];
		}
		array_thread( machine_triggers, ::set_power_on, 0 );
		if ( !is_true( start_state ) )
		{
			level waittill( "revive_on" );
		}
		start_state = 0;
		i = 0;
		while ( i < machine.size )
		{
			if ( isDefined( machine[ i ].classname ) && machine[ i ].classname == "script_model" )
			{
				if ( isDefined( machine[ i ].script_noteworthy ) && machine[ i ].script_noteworthy == "clip" )
				{
					machine_clip = machine[ i ];
					i++;
					continue;
				}
				machine[ i ] setmodel( level.machine_assets[ "revive" ].on_model );
				machine[ i ] playsound( "zmb_perks_power_on" );
				machine[ i ] vibrate( ( 0, -100, 0 ), 0.3, 0.4, 3 );
				machine_model = machine[ i ];
				machine[ i ] thread perk_fx( "revive_light" );
				machine[ i ] notify( "stop_loopsound" );
				machine[ i ] thread play_loop_on_machine();
				if ( isDefined( machine_triggers[ i ] ) )
				{
					machine_clip = machine_triggers[ i ].clip;
				}
				if ( isDefined( machine_triggers[ i ] ) )
				{
					blocker_model = machine_triggers[ i ].blocker_model;
				}
			}
			i++;
		}
		wait_network_frame();
		if ( solo_mode && isDefined( machine_model ) && !is_true( machine_model.ishidden ) )
		{
			machine_model thread revive_solo_fx( machine_clip, blocker_model );
		}
		array_thread( machine_triggers, ::set_power_on, 1 );
		if ( isDefined( level.machine_assets[ "revive" ].power_on_callback ) )
		{
			array_thread( machine, level.machine_assets[ "revive" ].power_on_callback );
		}
		level notify( "specialty_quickrevive_power_on" );
		if ( isDefined( machine_model ) )
		{
			machine_model.ishidden = 0;
		}
		notify_str = level waittill_any_return( "revive_off", "revive_hide" );
		should_hide = 0;
		if ( notify_str == "revive_hide" )
		{
			should_hide = 1;
		}
		if ( isDefined( level.machine_assets[ "revive" ].power_off_callback ) )
		{
			array_thread( machine, level.machine_assets[ "revive" ].power_off_callback );
		}
		for ( i = 0; i < machine.size; i++ )
		{
			if ( isDefined( machine[ i ].classname ) && machine[ i ].classname == "script_model" )
			{
				machine[ i ] turn_perk_off( should_hide );
			}
		}
	}
}