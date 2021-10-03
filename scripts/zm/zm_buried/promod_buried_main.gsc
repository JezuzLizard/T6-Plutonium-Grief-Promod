
#include scripts/zm/promod/_grief_util;
#include scripts/zm/zm_buried/gamemodes;

main()
{
	replaceFunc( maps/mp/zm_buried_gamemodes::init, scripts/zm/zm_buried/gamemodes::init_o );
}