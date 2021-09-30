
#include scripts/zm/promod/_utility;
#include scripts/zm/zm_transit/gamemodes;

main()
{
	replaceFunc( maps/mp/zm_buried_gamemodes::init, scripts/zm/zm_buried/gamemodes::init_o );
}