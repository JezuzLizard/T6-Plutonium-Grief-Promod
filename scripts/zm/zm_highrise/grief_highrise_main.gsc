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