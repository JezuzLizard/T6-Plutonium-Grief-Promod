
#include scripts/zm/zm_highrise/grief/gamemodes;

main()
{
	replaceFunc( maps/mp/zm_highrise_gamemodes::init, scripts/zm/zm_highrise/grief/gamemodes::init_override );
}