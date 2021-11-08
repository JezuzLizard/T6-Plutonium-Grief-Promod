#include scripts/zm/promod/_utility;
#include scripts/zm/zm_transit/gamemodes;

main()
{
	replaceFunc( maps/mp/zm_prison_gamemodes::init, scripts/zm/zm_prison/gamemodes::init_o );
}