
#include scripts/zm/zm_tomb/gamemodes;

main()
{
	replaceFunc( maps/mp/zm_tomb_gamemodes::init, scripts/zm/zm_tomb/grief/gamemodes::init_override );
}