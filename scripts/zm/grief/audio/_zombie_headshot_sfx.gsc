
init()
{
	
}

// play_head_gib_sound()
// {
// 	random = randomInt( 2 );
// 	if ( random == 0 )
// 	{
// 		playsoundatposition( "chr_zombie_head_gib", self.origin ); //works
// 	}
// 	else if ( random == 1 )
// 	{
// 		playsoundatposition( "zmb_zombie_head_gib", self.origin ); //works
// 	}
// 	if ( random == 0 )
// 	{
// 		playSoundAtPosition( "prj_bullet_impact_headshot", self.origin );
// 		playSoundAtPosition( "prj_bullet_impact_headshot_2d", self.origin ); //works
// 	}
// 	else 
// 	{
// 		playsoundatposition( "prj_bullet_impact_headshot_helmet_nodie", self.origin ); //prj_bullet_impact_headshot_2d
// 		playSoundAtPosition( "prj_bullet_impact_headshot_helmet_nodie_2d", self.origin ); //works
// 	}
// }

// zombie_head_gib_o( attacker, means_of_death ) //checked changed to match cerberus output
// {
// 	self endon( "death" );
// 	if ( !is_mature() )
// 	{
// 		return 0;
// 	}
// 	if ( is_true( self.head_gibbed ) )
// 	{
// 		return;
// 	}
// 	play_head_gib_sound();
// 	self.head_gibbed = 1;
// 	self zombie_eye_glow_stop();
// 	size = self getattachsize();
// 	for ( i = 0; i < size; i++ )
// 	{
// 		model = self getattachmodelname( i );
// 		if ( issubstr( model, "head" ) )
// 		{
// 			if ( isDefined( self.hatmodel ) )
// 			{
// 				self detach( self.hatmodel, "" );
// 			}
// 			self detach( model, "" );
// 			if ( isDefined( self.torsodmg5 ) )
// 			{
// 				self attach( self.torsodmg5, "", 1 );
// 			}
// 			break;
// 		}
// 	}
// 	temp_array = [];
// 	temp_array[ 0 ] = level._zombie_gib_piece_index_head;
// 	if ( !is_true( self.hat_gibbed ) && isDefined( self.gibspawn5 ) && isDefined( self.gibspawntag5 ) )
// 	{
// 		temp_array[ 1 ] = level._zombie_gib_piece_index_hat;
// 	}
// 	self.hat_gibbed = 1;
// 	self gib( "normal", temp_array );
// 	if ( isDefined( level.track_gibs ) )
// 	{
// 		level [[ level.track_gibs ]]( self, temp_array );
// 	}
// 	self thread damage_over_time( ceil( self.health * 0.2 ), 1, attacker, means_of_death );
// }