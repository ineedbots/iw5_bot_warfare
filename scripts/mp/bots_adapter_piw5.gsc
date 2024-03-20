init()
{
	level.bot_builtins["printconsole"] = ::do_printconsole;
	level.bot_builtins["filewrite"] = ::do_filewrite;
	level.bot_builtins["fileread"] = ::do_fileread;
	level.bot_builtins["fileexists"] = ::do_fileexists;
	level.bot_builtins["botaction"] = ::do_botaction;
	level.bot_builtins["botstop"] = ::do_botstop;
	level.bot_builtins["botmovement"] = ::do_botmovement;
	level.bot_builtins["botmeleeparams"] = ::do_botmeleeparams;
}

do_printconsole( s )
{
	println( s );
}

do_filewrite( file, contents, mode )
{
	file = "scriptdata/" + file;
}

do_fileread( file )
{
	file = "scriptdata/" + file;
	return undefined;
}

do_fileexists( file )
{
	file = "scriptdata/" + file;
	return false;
}

do_botaction( action )
{
	self botaction( action );
}

do_botstop()
{
	self botstop();
}

do_botmovement( forward, right )
{
	self botmovement( forward, right );
}

do_botmeleeparams( entNum, dist )
{
	self botmeleeparams( entNum, dist );
}
