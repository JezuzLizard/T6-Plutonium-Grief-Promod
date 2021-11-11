
#include scripts/zm/zm_tomb/gamemodes;
#include scripts/zm/grief/gametype_modules/_gametype_setup;

main()
{
	replaceFunc( maps/mp/zm_tomb_gamemodes::init, scripts/zm/zm_tomb/grief/gamemodes::init_override );
}