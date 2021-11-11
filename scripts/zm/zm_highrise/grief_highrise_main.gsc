
#include scripts/zm/zm_highrise/grief/gamemodes;
#include scripts/zm/grief/gametype_modules/_gametype_setup;

main()
{
	replaceFunc( maps/mp/zm_highrise_gamemodes::init, scripts/zm/zm_highrise/grief/gamemodes::init_override );
}