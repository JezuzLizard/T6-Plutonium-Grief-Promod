
#include maps/mp/zombies/_zm_blockers;

init_replacements()
{
	replaceFunc( maps/mp/zombies/_zm_blockers::waittill_door_can_close, ::waittill_door_can_close_override );
}

waittill_door_can_close_override() //checked changed to match cerberus output
{
	switch ( self.script_noteworthy )
	{
		case "local_electric_door":
			self waittill( "local_power_off" );
			return;
		case "electric_door":
			self waittill( "power_off" );
			return;
	}
}