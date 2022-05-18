#include scripts/zm/promod/_utility;
#include scripts/zm/zm_prison/grief/gamemodes;
#include scripts/zm/_gametype_setup;

main()
{
	replaceFunc( maps/mp/zm_alcatraz_gamemodes::init, scripts/zm/zm_prison/grief/gamemodes::init_override );
	replaceFunc( maps/mp/zm_alcatraz_traps::acid_trap_fx, scripts/zm/zm_prison/locs/location_common::acid_trap_fx_override );
}