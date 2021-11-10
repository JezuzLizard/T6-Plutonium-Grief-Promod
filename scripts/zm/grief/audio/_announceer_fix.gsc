
playleaderdialogonplayer_o( dialog, team, waittime )
{
	self endon( "disconnect" );

	if ( level.allowzmbannouncer )
	{
		if ( !isDefined( game[ "zmbdialog" ][ dialog ] ) )
		{
			return;
		}
	}
	self.zmbdialogactive = 1;
	if ( isDefined( self.zmbdialoggroups[ dialog ] ) )
	{
		group = dialog;
		dialog = self.zmbdialoggroups[ group ];
		self.zmbdialoggroups[ group ] = undefined;
		self.zmbdialoggroup = group;
	}
	if ( level.allowzmbannouncer )
	{
		alias = game[ "zmbdialog" ][ "prefix" ] + "_" + game[ "zmbdialog" ][ dialog ];
		variant = self getleaderdialogvariant( alias );
		if ( !isDefined( variant ) )
		{
			full_alias = alias + "_" + "0";
			if ( level.script == "zm_prison" )
			{
				dialogType = strtok( game[ "zmbdialog" ][ dialog ], "_" );
				switch ( dialogType[ 0 ] )
				{
					case "powerup":
						full_alias = alias;
						break;
					case "grief":
						full_alias = alias + "_" + "0";
						break;
					default:
						full_alias = alias;
				}
			}
		}
		else
		{
			full_alias =  alias + "_" + variant;
		}
		self playlocalsound( full_alias );
	}
	if ( isDefined( waittime ) )
	{
		wait waittime;
	}
	else
	{
		wait 4;
	}
	self.zmbdialogactive = 0;
	self.zmbdialoggroup = "";
	if ( self.zmbdialogqueue.size > 0 && level.allowzmbannouncer )
	{
		nextdialog = self.zmbdialogqueue[0];
		for( i = 1; i < self.zmbdialogqueue.size; i++ )
		{
			self.zmbdialogqueue[ i - 1 ] = self.zmbdialogqueue[ i ];
		}
		self.zmbdialogqueue[ i - 1 ] = undefined;
		self thread playleaderdialogonplayer( nextdialog, team );
	}
}