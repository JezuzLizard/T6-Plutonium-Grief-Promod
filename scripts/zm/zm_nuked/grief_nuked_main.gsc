
#include scripts/zm/zm_nuked/grief/gamemodes;
#include scripts/zm/grief/gametype_modules/_gametype_setup;

main()
{
	replaceFunc( maps/mp/zm_nuked_gamemodes::init, scripts/zm/zm_nuked/grief/gamemodes::init_override );
}