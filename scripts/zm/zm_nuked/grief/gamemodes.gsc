#include maps/mp/zm_nuked_standard;
#include maps/mp/zm_nuked;
#include maps/mp/gametypes_zm/_zm_gametype;
#include maps/mp/zombies/_zm_game_module;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/zm_nuked;

#include scripts/zm/zm_nuked/locs/location_common;

init_override()
{
	add_map_gamemode( "zstandard", ::zstandard_preinit_override, undefined, undefined );
	add_map_location_gamemode( "zstandard", "nuked", scripts/zm/zm_nuked/locs/location_common::precache, scripts/zm/zm_nuked/locs/location_common::main );
}

zstandard_preinit_override() //checked matches cerberus output
{
	survival_init();
}

survival_init() //checked matches cerberus output
{
// 	level.should_use_cia = 0;
// 	if ( randomint( 100 ) > 50 )
// 	{
// 		level.should_use_cia = 1;
// 	}
	level.precachecustomcharacters = ::precache_team_characters;
	level.givecustomcharacters = ::give_team_characters_override;
	flag_wait( "start_zombie_round_logic" );
}

give_team_characters_override() //checked matches cerberus output
{
	self detachall();
	self set_player_is_female( 0 );
	if ( !isDefined( self.characterindex ) )
	{
		self.characterindex = 1;
		if ( self.team == "axis" )
		{
			self.characterindex = 0;
		}
	}
	switch( self.characterindex )
	{
		case 0:
		case 2:
			self setmodel( "c_zom_player_cia_fb" );
			self.voice = "american";
			self.skeleton = "base";
			self setviewmodel( "c_zom_suit_viewhands" );
			self.characterindex = 0;
			break;
		case 1:
		case 3:
			self setmodel( "c_zom_player_cdc_fb" );
			self.voice = "american";
			self.skeleton = "base";
			self setviewmodel( "c_zom_hazmat_viewhands_light" );
			self.characterindex = 1;
			break;
	}
	self setmovespeedscale( 1 );
	self setsprintduration( 4 );
	self setsprintcooldown( 0 );
	self set_player_tombstone_index();
}