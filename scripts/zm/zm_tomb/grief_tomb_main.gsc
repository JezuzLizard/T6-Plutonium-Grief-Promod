#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;
#include maps\mp\zombies\_zm_perks;
#include maps\mp\zm_tomb;

#include scripts\zm\zm_tomb\grief\gamemodes;
#include scripts\zm\_gametype_setup;

main()
{
	replaceFunc( maps\mp\zm_tomb_gamemodes::init, scripts\zm\zm_tomb\grief\gamemodes::init_override );
	replacefunc( maps\mp\zm_tomb_dig::dig_spots_init, ::dig_spots_init );
	replacefunc( maps\mp\zm_tomb_dig::generate_shovel_unitrigger, ::generate_shovel_unitrigger );
	replacefunc( maps\mp\zm_tomb_vo::first_magic_box_seen_vo, ::first_magic_box_seen_vo );
	
	thread turn_on_power();

	fake_location = getDvar( "scr_zm_location" );
	switch ( fake_location )
	{
		case "crazyplace":
			level.custom_location_zones = [];
			level.custom_location_zones[ 0 ] = "zone_chamber_0";
			level.custom_location_zones[ 1 ] = "zone_chamber_1";
			level.custom_location_zones[ 2 ] = "zone_chamber_2";
			level.custom_location_zones[ 3 ] = "zone_chamber_3";
			level.custom_location_zones[ 4 ] = "zone_chamber_4";
			level.custom_location_zones[ 5 ] = "zone_chamber_5";
			level.custom_location_zones[ 6 ] = "zone_chamber_6";
			level.custom_location_zones[ 7 ] = "zone_chamber_7";
			level.custom_location_zones[ 8 ] = "zone_chamber_8";
			break;
		case "trenches":
			// not needed
			break;
	}
}

init()
{
	// if ( level.grief_ffa )
	// {
	// 	level.grief_ffa_team_character_index = randomint( 4 );
	// }
	// else 
	// {
	// 	level.grief_character_index_teams = [];
	// 	character_index_array = array( 0, 1, 2, 3 );
	// 	random_index = character_index_array[ randomint( character_index_array.size ) ];
	// 	arrayRemoveIndex( character_index_array, random_index );
	// 	level.grief_character_index_teams[ "allies" ] = random_index;
	// 	level.grief_character_index_teams[ "axis" ] = character_index_array[ randomint( character_index_array.size ) ];
	// }
	// level.givecustomcharacters = ::give_personality_characters_tomb_override;

	// survival_init();
}

survival_init()
{
    level.force_team_characters = 1;
    level.should_use_cia = 0;

    if ( randomint( 100 ) > 50 )
        level.should_use_cia = 1;

    level.precachecustomcharacters = ::precache_team_characters;
    level.givecustomcharacters = ::give_team_characters;
}

give_personality_characters_tomb_override()
{
	if ( isdefined( level.hotjoin_player_setup ) && [[ level.hotjoin_player_setup ]]( "c_zom_arlington_coat_viewhands" ) )
        return;

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
        case "0":
            self character\c_usa_dempsey_dlc4::main();
            self setviewmodel( "c_zom_dempsey_viewhands" );
            level.vox maps\mp\zombies\_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
            self set_player_is_female( 0 );
            self.character_name = "Dempsey";
            break;
        case "1":
            self character\c_rus_nikolai_dlc4::main();
            self setviewmodel( "c_zom_nikolai_viewhands" );
            level.vox maps\mp\zombies\_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
            self set_player_is_female( 0 );
            self.character_name = "Nikolai";
            break;
        case "2":
            self character\c_ger_richtofen_dlc4::main();
            self setviewmodel( "c_zom_richtofen_viewhands" );
            level.vox maps\mp\zombies\_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
            self set_player_is_female( 0 );
            self.character_name = "Richtofen";
            break;
        case "3":
            self character\c_jap_takeo_dlc4::main();
            self setviewmodel( "c_zom_takeo_viewhands" );
            level.vox maps\mp\zombies\_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
            self set_player_is_female( 0 );
            self.character_name = "Takeo";
            break;
    }

    self setmovespeedscale( 1 );
    self setsprintduration( 4 );
    self setsprintcooldown( 0 );
    self thread set_exert_id();
}

turn_on_power()
{
	flag_wait("capture_zones_init_done" );
	foreach(zone in level.zone_capture.zones)
	{
		zone.n_current_progress = 100;
		zone maps/mp/zm_tomb_capture_zones::handle_generator_capture();
		level setclientfield( zone.script_noteworthy, 100 / 100 );
		level setclientfield( "state_" + zone.script_noteworthy, 2 );
	}
	wait 1;
	flag_set("zone_capture_in_progress");

	level.custom_perk_validation = undefined;
}

generate_shovel_unitrigger( e_shovel ) //checked changed to match cerberus output
{
	return;
}

dig_spots_init()
{
	return;
}

first_magic_box_seen_vo()
{
	return;
}