
#include scripts/zm/zm_buried/grief/gamemodes;

main()
{
	replaceFunc( maps/mp/zm_buried_gamemodes::init, scripts/zm/zm_buried/grief/gamemodes::init_override );
}