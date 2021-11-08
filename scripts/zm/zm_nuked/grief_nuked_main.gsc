
#include scripts/zm/zm_nuked/gamemodes;

main()
{
	replaceFunc( maps/mp/zm_nuked_gamemodes::init, scripts/zm/zm_nuked/gamemodes::init_o );
}