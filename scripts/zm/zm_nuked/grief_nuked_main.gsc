
#include scripts/zm/zm_nuked/grief/gamemodes;
#include scripts/zm/grief/gametype_modules/_gametype_setup;

#include scripts/zm/zm_nuked/locs/location_common;

main()
{
	replaceFunc( maps/mp/zm_nuked_gamemodes::init, scripts/zm/zm_nuked/grief/gamemodes::init_override );
	replaceFunc( maps/mp/zm_nuked_perks::perks_from_the_sky, scripts/zm/zm_nuked/locs/location_common::perks_from_the_sky_override );
	replaceFunc( maps/mp/zm_nuked_perks::init_nuked_perks, scripts/zm/zm_nuked/locs/location_common::init_nuked_perks_override );
}

init()
{
	level.givecustomcharacters = scripts/zm/zm_nuked/grief/gamemodes::give_team_characters_override;
}