
#include scripts/zm/zm_buried/grief/gamemodes;
#include scripts/zm/_gametype_setup;

main()
{
	replaceFunc( maps/mp/zm_buried_gamemodes::init, scripts/zm/zm_buried/grief/gamemodes::init_override );
}