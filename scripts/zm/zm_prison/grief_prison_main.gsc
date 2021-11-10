#include scripts/zm/promod/_utility;
#include scripts/zm/zm_prison/grief/gamemodes;

main()
{
	replaceFunc( maps/mp/zm_prison_gamemodes::init, scripts/zm/zm_prison/grief/gamemodes::init_override );
}