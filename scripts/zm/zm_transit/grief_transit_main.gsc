#include scripts/zm/promod/_utility;
#include scripts/zm/zm_transit/grief/gamemodes;

main()
{
	replaceFunc( maps/mp/zm_transit_gamemodes::init, scripts/zm/zm_transit/grief/gamemodes::init_override );
}