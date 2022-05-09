#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\gametypes_zm\zgrief;

main()
{
	replaceFunc( maps\mp\gametypes_zm\zgrief::zgrief_player_bled_out_msg, ::zgrief_player_bled_out_msg_override );
}

init()
{
	if ( level.grief_ffa )
	{
		if ( cointoss() )
		{
			level.grief_ffa_team = "allies";
		}
		else 
		{
			level.grief_ffa_team = "axis";
		}
		switch ( level.script )
		{
			case "zm_transit":
				level.givecustomcharacters = ::give_team_characters_transit_override;
				break;
			case "zm_prison":
				level.givecustomcharacters = ::give_team_characters_prison_override;
				break;
			case "zm_buried":
				level.givecustomcharacters = ::give_team_characters_buried_override;
				break;
		}
	}
}

zgrief_player_bled_out_msg_override()
{
    level endon( "end_game" );
    self endon( "disconnect" );
	if ( !level.grief_ffa )
	{
		while ( true )
		{
			self waittill( "bled_out" );

			level thread update_players_on_bleedout_or_disconnect( self);
		}
	}
}

give_team_characters_transit_override()
{
    self detachall();

	self.characterindex = 1;
	if ( level.grief_ffa_team == "axis" )
		self.characterindex = 0;

	switch ( self.characterindex )
	{
		case 2:
		case 0:
			self setmodel( "c_zom_player_cia_fb" );
			self.voice = "american";
			self.skeleton = "base";
			self setviewmodel( "c_zom_suit_viewhands" );
			self.characterindex = 0;
			break;
		case 3:
		case 1:
			self setmodel( "c_zom_player_cdc_fb" );
			self.voice = "american";
			self.skeleton = "base";
			self setviewmodel( "c_zom_hazmat_viewhands" );
			self.characterindex = 1;
			break;
	}

    self setmovespeedscale( 1 );
    self setsprintduration( 4 );
    self setsprintcooldown( 0 );
}

give_team_characters_prison_override()
{
    self detachall();
    self set_player_is_female( 0 );

	self.characterindex = 1;
	if ( level.grief_ffa_team == "axis" )
		self.characterindex = 0;

    switch ( self.characterindex )
    {
        case 2:
        case 0:
            self setmodel( "c_zom_player_grief_inmate_fb" );
            self.voice = "american";
            self.skeleton = "base";
            self setviewmodel( "c_zom_oleary_shortsleeve_viewhands" );
            self.characterindex = 0;
            break;
        case 3:
        case 1:
            self setmodel( "c_zom_player_grief_guard_fb" );
            self.voice = "american";
            self.skeleton = "base";
            self setviewmodel( "c_zom_grief_guard_viewhands" );
            self.characterindex = 1;
            break;
    }

    self setmovespeedscale( 1 );
    self setsprintduration( 4 );
    self setsprintcooldown( 0 );
}

give_team_characters_buried_override()
{
    self detachall();
    self set_player_is_female( 0 );

	self.characterindex = 1;
	if ( level.grief_ffa_team == "axis" )
		self.characterindex = 0;

    switch ( self.characterindex )
    {
        case 2:
        case 0:
            self setmodel( "c_zom_player_cia_dlc1_fb" );
            self.voice = "american";
            self.skeleton = "base";
            self setviewmodel( "c_zom_suit_viewhands" );
            self.characterindex = 0;
            break;
        case 3:
        case 1:
            self setmodel( "c_zom_player_cdc_dlc1_fb" );
            self.voice = "american";
            self.skeleton = "base";
            self setviewmodel( "c_zom_hazmat_viewhands" );
            self.characterindex = 1;
            break;
    }

    self setmovespeedscale( 1 );
    self setsprintduration( 4 );
    self setsprintcooldown( 0 );
}