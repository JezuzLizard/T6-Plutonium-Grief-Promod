#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

/*private*/ FS_init()
{
	level.FS_basepath = getDvar( "fs_basepath" ) + "/" + getDvar( "fs_basegame" ) + "/" + "scriptdata" + "/";
	level.max_open_files = 10;
	level.FS_open_files = [];
}

/*public*/ FS_read( filename )
{
	reason = FS_file_open_failure( filename );
	if ( reason != "" )
	{
		print( "FS_read Error: Failed to open " + filename + " reason " + reason );
		return "";
	}
	level.FS_open_files[ level.FS_open_files.size ] = filename;
	file = fopen( level.basepath + filename, "r+" );
	if ( file == -1 )
	{
		arrayRemoveValue( level.FS_open_files, filename );
		print( "FS_read Error: Failed to open " + filename );
		return "";
	}
	buffer = fread( file );
	fclose( file );
	arrayRemoveValue( level.FS_open_files, filename );
	return buffer;
}

/*public*/ FS_write( filename, buffer )
{
	reason = FS_file_open_failure( filename );
	if ( reason != 0 )
	{
		print( "FS_write Error: Failed to open " + filename + " reason " + reason );
		return;
	}
	level.FS_open_files[ level.FS_open_files.size ] = filename;
	file = fopen( level.basepath + filename, "w+" );
	if ( file == -1 )
	{
		arrayRemoveValue( level.FS_open_files, filename );
		print( "FS_write Error: Failed to open " + filename );
		return;
	}
	data = "";
	data_printed = 0;
	for ( buffer_index = 0; isDefined( buffer[ buffer_index ] ); buffer_index++ )
	{
		data += buffer[ buffer_index ];
		if ( buffer[ buffer_index ] == ";" )
		{
			fprintf( data + "\n", file );
			data_printed += data.size;
			data = "";
		}
	}
	fclose( file );
	arrayRemoveValue( level.FS_open_files, filename );
	if ( buffer.size != data_printed )
	{
		print( "FS_write Error: Failed to write entire buffer " + filename );
	}
}

/*public*/ FS_append( filename, buffer )
{
	reason = FS_file_open_failure( filename );
	if ( reason != 0 )
	{
		print( "FS_append Error: Failed to open " + filename + " reason " + reason );
		return;
	}
	level.FS_open_files[ level.FS_open_files.size ] = filename;
	file = fopen( level.basepath + filename, "a+" );
	if ( file == -1 )
	{
		arrayRemoveValue( level.FS_open_files, filename );
		print( "FS_append Error: Failed to open " + filename );
		return;
	}
	data = "";
	data_printed = 0;
	for ( buffer_index = 0; isDefined( buffer[ buffer_index ] ); buffer_index++ )
	{
		data += buffer[ buffer_index ];
		if ( buffer[ buffer_index ] == ";" )
		{
			fprintf( data + "\n", file );
			data_printed += data.size;
			data = "";
		}
	}
	fclose( file );
	arrayRemoveValue( level.FS_open_files, filename );
	if ( buffer.size != data_printed )
	{
		print( "FS_append Error: Failed to write entire buffer " + filename );
	}
}

/*private*/ FS_file_open_failure( filename )
{
	if ( level.FS_open_files.size > level.max_open_files )
	{
		return va( "%s files are open max is %s", level.FS_open_files.size, level.max_open_files );
	}
	if ( isInArray( level.FS_open_files, filename ) )
	{
		return va( "file %s already open", filename );
	}
	return 0;
}