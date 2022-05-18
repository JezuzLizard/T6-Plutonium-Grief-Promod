
#include scripts\zm\zm_tomb\grief\gamemodes;
#include scripts\zm\_gametype_setup;

main()
{
	replaceFunc( maps\mp\zm_tomb_gamemodes::init, scripts\zm\zm_tomb\grief\gamemodes::init_override );
}