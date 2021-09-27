#include scripts/zm/promod/_utility;
#include scripts/zm/zm_transit/gamemodes;

/*
	This script handles map specific code relating to Tranzit locations. 
	Map specific overrides and includes only.
*/

main()
{
	replaceFunc( maps/mp/zm_transit_gamemodes::init, scripts/zm/zm_transit/gamemodes::init_o );
}