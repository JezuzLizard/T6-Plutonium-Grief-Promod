FS_INIT()
{
	level.FS_basepath = va( "%s/scriptdata/", getDvar( "fs_homepath" ) );
	level.max_open_files = 10;
	level.FS_open_files = [];
}

JSON_WRITE( filename, buffer )
{
	writeFile( level.FS_basepath + filename, buffer );
}

FS_read( filename )
{
	reason = FS_file_open_failure( filename );
	if ( reason != "" )
	{
		print( "FS_read Error: Failed to open " + filename + " reason " + reason );
		return "";
	}
	level.FS_open_files[ level.FS_open_files.size ] = filename;
	file = fopen( level.FS_basepath + filename, "r" );
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

FS_write( filename, buffer )
{
	reason = FS_file_open_failure( filename );
	if ( reason != 0 )
	{
		print( "FS_write Error: Failed to open " + filename + " reason " + reason );
		return;
	}
	level.FS_open_files[ level.FS_open_files.size ] = filename;
	file = fopen( va( "%s\\%s", level.FS_basepath, filename ), "w" );
	if ( file == -1 )
	{
		arrayRemoveValue( level.FS_open_files, filename );
		print( "FS_write Error: Failed to open " + filename );
		return;
	}
	//fwrite( file, buffer );
	fwrite( file, buffer );
	fclose( file );
	arrayRemoveValue( level.FS_open_files, filename );
	// if ( buffer.size != data_printed )
	// {
	// 	print( "FS_write Error: Failed to write entire buffer " + filename );
	// }
}

FS_append( filename, buffer )
{
	reason = FS_file_open_failure( filename );
	if ( reason != 0 )
	{
		print( "FS_append Error: Failed to open " + filename + " reason " + reason );
		return;
	}
	level.FS_open_files[ level.FS_open_files.size ] = filename;
	file = fopen( level.FS_basepath + filename, "a" );
	if ( file == -1 )
	{
		arrayRemoveValue( level.FS_open_files, filename );
		print( "FS_append Error: Failed to open " + filename );
		return;
	}
	fclose( file );
	arrayRemoveValue( level.FS_open_files, filename );
}

FS_file_open_failure( filename )
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