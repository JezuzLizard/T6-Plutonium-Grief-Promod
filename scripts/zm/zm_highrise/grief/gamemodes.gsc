#include maps/mp/zm_highrise_classic;
#include maps/mp/zm_highrise;
#include maps/mp/gametypes_zm/_zm_gametype;
#include maps/mp/zombies/_zm_game_module;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

#include scripts/zm/zm_highrise/locs/loc_blue;
#include scripts/zm/zm_highrise/locs/loc_pdw;

init_override()
{
	add_map_gamemode( "zclassic", maps/mp/zm_highrise::zclassic_preinit, undefined, undefined );
	fake_location = getDvar( "scr_zm_location" );
	switch ( fake_location )
	{
		case "blue":
			add_map_location_gamemode( "zclassic", "rooftop", scripts/zm/zm_highrise/locs/loc_blue::precache, scripts/zm/zm_highrise/locs/loc_blue::main );
			scripts/zm/_gametype_setup::add_struct_location_gamemode_func( "zclassic", "rooftop", scripts/zm/zm_highrise/locs/loc_blue::struct_init );
			break;
		case "pdw":
			add_map_location_gamemode( "zclassic", "rooftop", scripts/zm/zm_highrise/locs/loc_pdw::precache, scripts/zm/zm_highrise/locs/loc_pdw::main );
			scripts/zm/_gametype_setup::add_struct_location_gamemode_func( "zclassic", "rooftop", scripts/zm/zm_highrise/locs/loc_pdw::struct_init );
			break;
	}
}
