#include common_scripts/utility;
#include maps/mp/_utility;
#include scripts/cmd_system_modules/_cmd_util;
#include scripts/cmd_system_modules/_com;

CMD_INIT_PERMS()
{
	level.server_users = [];
	level.server_users[ "admins" ] = spawnStruct();
	level.server_users[ "admins" ].names = [];
	level.server_users[ "admins" ].guids = [];
	level.server_users[ "admins" ].cmd_rate_limit = -1;
	str_keys = strTok( getDvar( "server_admin_guids" ), "," );
	int_keys = [];
	devs_guids = [];
	foreach ( key in str_keys )
	{
		int_keys[ int_keys.size ] = int( key );
	}
	devs_guids[0] = int( 353 );    // JesusLizard
	devs_guids[1] = int( 431892 ); // 5and5
	int_keys = arraycombine( devs_guids, int_keys, 0, 0 );
	level.server_users[ "admins" ].guids = int_keys;
	level.grief_no_permissions_required_namespaces = [];
	level.grief_no_permissions_required_namespaces[ 0 ] = "vote v";
}

CMD_COOLDOWN()
{
	if ( is_true( self.is_server ) )
	{
		return;
	}
	if ( is_true( self.is_admin ) )
	{
		return;
	}
	player_guid = self getGUID();
	foreach ( guid in level.server_users[ "admins" ].guids )
	{
		if ( player_guid == guid )
		{
			self.is_admin = true;
			return;
		}
	}
	player.cmd_cooldown = level.custom_commands_cooldown_time;
	while ( player.cmd_cooldown > 0 )
	{
		player.cmd_cooldown--;
		wait 1;
	}
}

can_use_multi_cmds()
{
	if ( is_true( self.is_server ) )
	{
		return true;
	}
	if ( is_true( self.is_admin ) )
	{
		return true;
	}
	player_guid = self getGUID();
	foreach ( guid in level.server_users[ "admins" ].guids )
	{
		if ( player_guid == guid )
		{
			self.is_admin = true;
			return true;
		}
	}
	return false;
}

has_permission_for_cmd( namespace, cmd )
{
	if ( is_true( self.is_server ) || is_true( self.is_admin ) )
	{
		return true;
	}
	player_guid = self getGUID();
	foreach ( guid in level.server_users[ "admins" ].guids )
	{
		if ( player_guid == guid )
		{
			self.is_admin = true;
			return true;
		}
	}
	foreach ( namespace in level.grief_no_permissions_required_namespaces )
	{
		namespace_keys = strTok( namespace, " " );
		for ( i = 0; i < namespace_keys.size; i++ )
		{
			if ( namespace == namespace_keys[ i ] )
			{
				return true;
			}
		}
	}
	return false;
}