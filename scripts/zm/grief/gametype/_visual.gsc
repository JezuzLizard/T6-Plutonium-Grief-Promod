#include maps/mp/gametypes_zm/_hud_util;
#include common_scripts/utility;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;

main()
{
    level thread onConnect();
}

onConnect()
{
	for(;;)
	{
		level waittill("connected", player);
		player thread visual_tweaks();
	}
}

visual_tweaks()
{
    flag_wait( "start_zombie_round_logic" );
   	wait 0.05;
	self setclientdvar( "r_dof_enable", 0 );
	self setclientdvar( "r_enablePlayerShadow", 1 );
	self setclientdvar( "r_lodBiasRigid", -500 );
	self setclientdvar( "r_lodBiasSkinned", -500 );
	self setClientDvar( "r_lodScaleRigid", 1) ;
	self setClientDvar( "r_lodScaleSkinned", 1 );
	self setclientdvar( "r_enablePlayerShadow", 1 );
	self setclientdvar( "sm_sunquality", 2 );
	self setclientdvar( "vc_fbm", "0 0 0 0" );
	self setclientdvar( "vc_fsm", "1 1 1 1" );
	self setclientdvar( "vc_fgm", "1 1 1 1" );
}