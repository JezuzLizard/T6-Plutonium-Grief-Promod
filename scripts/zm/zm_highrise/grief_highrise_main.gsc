#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zm_highrise;

#include scripts\zm\zm_highrise\grief\gamemodes;
#include scripts\zm\_gametype_setup;

main()
{
	replaceFunc( maps\mp\zm_highrise_gamemodes::init, scripts\zm\zm_highrise\grief\gamemodes::init_override );
}

init()
{
	if ( level.grief_ffa )
	{
		level.grief_ffa_team_character_index = randomint( 4 );
	}
	else 
	{
		level.grief_character_index_teams = [];
		character_index_array = array( 0, 1, 2, 3 );
		random_index = character_index_array[ randomint( character_index_array.size ) ];
		arrayRemoveIndex( character_index_array, random_index );
		level.grief_character_index_teams[ "allies" ] = random_index;
		level.grief_character_index_teams[ "axis" ] = character_index_array[ randomint( character_index_array.size ) ];
	}
	level.givecustomcharacters = ::give_personality_characters_highrise_override;

	disable_elevator_perks();

	flag_wait( "initial_blackscreen_passed" );
	turn_on_power();
	close_elevators();
	disable_zones();
}

give_personality_characters_highrise_override()
{
	self detachall();

	if ( !isdefined( self.characterindex ) )
	{
		if ( level.grief_ffa )
		{
			self.character_index = level.grief_ffa_team_character_index;
		}
		else 
		{
			self.characterindex = level.grief_character_index_teams[ self.team ];
		}
	}

	self.favorite_wall_weapons_list = [];
	self.talks_in_danger = 0;
	switch ( self.characterindex )
	{
		case 2:
			self character\c_highrise_player_farmgirl::main();
			self setviewmodel( "c_zom_farmgirl_viewhands" );
			level.vox maps\mp\zombies\_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
			self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = "rottweil72_zm";
			self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = "870mcs_zm";
			self set_player_is_female( 1 );
			self.whos_who_shader = "c_zom_player_farmgirl_dlc1_fb";
			break;
		case 0:
			self character\c_highrise_player_oldman::main();
			self setviewmodel( "c_zom_oldman_viewhands" );
			level.vox maps\mp\zombies\_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
			self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = "frag_grenade_zm";
			self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = "claymore_zm";
			self set_player_is_female( 0 );
			self.whos_who_shader = "c_zom_player_oldman_dlc1_fb";
			break;
		case 3:
			self character\c_highrise_player_engineer::main();
			self setviewmodel( "c_zom_engineer_viewhands" );
			level.vox maps\mp\zombies\_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
			self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = "m14_zm";
			self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = "m16_zm";
			self set_player_is_female( 0 );
			self.whos_who_shader = "c_zom_player_engineer_dlc1_fb";
			break;
		case 1:
			self character\c_highrise_player_reporter::main();
			self setviewmodel( "c_zom_reporter_viewhands" );
			level.vox maps\mp\zombies\_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
			self.talks_in_danger = 1;
			level.rich_sq_player = self;
			self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = "beretta93r_zm";
			self set_player_is_female( 0 );
			self.whos_who_shader = "c_zom_player_reporter_dlc1_fb";
			break;
	}

	self setmovespeedscale( 1 );
	self setsprintduration( 4 );
	self setsprintcooldown( 0 );
	self thread set_exert_id();
}

disable_elevator_perks()
{
	perks = array( "vending_additionalprimaryweapon", "vending_revive", "vending_chugabud", "vending_jugg", "vending_doubletap", "vending_sleight" );
	foreach ( perk in perks )
	{
		trigger = getent( perk, "target" );
		if( isDefined(trigger) )
			trigger disable_trigger();
	}
}

turn_on_power()
{	
	trig = getEnt( "use_elec_switch", "targetname" );
	powerSwitch = getEnt( "elec_switch", "targetname" );
	powerSwitch notSolid();
	trig setHintString( &"ZOMBIE_ELECTRIC_SWITCH" );
	trig setVisibleToAll();
	trig notify( "trigger", self );
	trig setInvisibleToAll();
	powerSwitch rotateRoll( -90, 0, 3 );
	level thread maps\mp\zombies\_zm_perks::perk_unpause_all_perks();
	powerSwitch waittill( "rotatedone" );
	flag_set( "power_on" );
	level setClientField( "zombie_power_on", 1 ); 
}

close_elevators()
{
	foreach(elevator in level.elevators)
	{
		elevator.body.lock_doors = 1;
		elevator.body maps\mp\zm_highrise_elevators::perkelevatordoor(0);
	}
}

disable_zones()
{
	zones_to_disable = array( "zone_blue_level4c", "zone_blue_level4a", "zone_blue_level4b", "zone_blue_level5" );
	foreach ( zone in zones_to_disable )
	{
		level.zones[ zone ].is_enabled = false;
	}
}