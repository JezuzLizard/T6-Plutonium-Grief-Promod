#include scripts/zm/promod/_utility;
#include scripts/zm/zm_transit/grief/gamemodes;
#include scripts/zm/zm_transit/locs/location_common;
#include scripts/zm/grief/gametype_modules/_gametype_setup;

main()
{
	replaceFunc( maps/mp/zm_transit_gamemodes::init, scripts/zm/zm_transit/grief/gamemodes::init_override );
}