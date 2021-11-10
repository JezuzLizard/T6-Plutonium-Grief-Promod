
#include scripts/zm/zm_nuked/grief/gamemodes;

main()
{
	replaceFunc( maps/mp/zm_nuked_gamemodes::init, scripts/zm/zm_nuked/grief/gamemodes::init_override );
}