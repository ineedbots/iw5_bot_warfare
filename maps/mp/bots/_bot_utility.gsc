/*
	_bot_utility
	Author: INeedGames
	Date: 05/07/2021
	The shared functions for bots
*/

#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

/*
	Waits for the built-ins to be defined
*/
wait_for_builtins()
{
	for ( i = 0; i < 20; i++ )
	{
		if ( isdefined( level.bot_builtins ) )
		{
			return true;
		}
		
		if ( i < 18 )
		{
			waittillframeend;
		}
		else
		{
			wait 0.05;
		}
	}
	
	return false;
}

/*
	Prints to console without dev script on
*/
BotBuiltinPrintConsole( s )
{
	if ( isdefined( level.bot_builtins ) && isdefined( level.bot_builtins[ "printconsole" ] ) )
	{
		[[ level.bot_builtins[ "printconsole" ] ]]( s );
	}
}

/*
	Writes to the file, mode can be "append" or "write"
*/
BotBuiltinFileWrite( file, contents, mode )
{
	if ( isdefined( level.bot_builtins ) && isdefined( level.bot_builtins[ "filewrite" ] ) )
	{
		[[ level.bot_builtins[ "filewrite" ] ]]( file, contents, mode );
	}
}

/*
	Returns the whole file as a string
*/
BotBuiltinFileRead( file )
{
	if ( isdefined( level.bot_builtins ) && isdefined( level.bot_builtins[ "fileread" ] ) )
	{
		return [[ level.bot_builtins[ "fileread" ] ]]( file );
	}
	
	return undefined;
}

/*
	Test if a file exists
*/
BotBuiltinFileExists( file )
{
	if ( isdefined( level.bot_builtins ) && isdefined( level.bot_builtins[ "fileexists" ] ) )
	{
		return [[ level.bot_builtins[ "fileexists" ] ]]( file );
	}
	
	return false;
}

/*
	Bot action, does a bot action
	<client> botaction(<action string (+ or - then action like frag or smoke)>)
*/
BotBuiltinBotAction( action )
{
	if ( isdefined( level.bot_builtins ) && isdefined( level.bot_builtins[ "botaction" ] ) )
	{
		self [[ level.bot_builtins[ "botaction" ] ]]( action );
	}
}

/*
	Clears the bot from movement and actions
	<client> botstop()
*/
BotBuiltinBotStop()
{
	if ( isdefined( level.bot_builtins ) && isdefined( level.bot_builtins[ "botstop" ] ) )
	{
		self [[ level.bot_builtins[ "botstop" ] ]]();
	}
}

/*
	Sets the bot's movement
	<client> botmovement(<int forward>, <int right>)
*/
BotBuiltinBotMovement( forward, right )
{
	if ( isdefined( level.bot_builtins ) && isdefined( level.bot_builtins[ "botmovement" ] ) )
	{
		self [[ level.bot_builtins[ "botmovement" ] ]]( forward, right );
	}
}

/*
	Sets melee params
*/
BotBuiltinBotMeleeParams( entNum, dist )
{
	if ( isdefined( level.bot_builtins ) && isdefined( level.bot_builtins[ "botmeleeparams" ] ) )
	{
		self [[ level.bot_builtins[ "botmeleeparams" ] ]]( entNum, dist );
	}
}

/*
	Returns if player is the host
*/
is_host()
{
	return ( isdefined( self.pers[ "bot_host" ] ) && self.pers[ "bot_host" ] );
}

/*
	Setups the host variable on the player
*/
doHostCheck()
{
	self.pers[ "bot_host" ] = false;
	
	if ( self is_bot() )
	{
		return;
	}
	
	result = false;
	
	if ( getdvar( "bots_main_firstIsHost" ) != "0" )
	{
		BotBuiltinPrintConsole( "WARNING: bots_main_firstIsHost is enabled" );
		
		if ( getdvar( "bots_main_firstIsHost" ) == "1" )
		{
			setdvar( "bots_main_firstIsHost", self getguid() );
		}
		
		if ( getdvar( "bots_main_firstIsHost" ) == self getguid() + "" )
		{
			result = true;
		}
	}
	
	DvarGUID = getdvar( "bots_main_GUIDs" );
	
	if ( DvarGUID != "" )
	{
		guids = strtok( DvarGUID, "," );
		
		for ( i = 0; i < guids.size; i++ )
		{
			if ( self getguid() + "" == guids[ i ] )
			{
				result = true;
			}
		}
	}
	
	if ( !self ishost() && !result )
	{
		return;
	}
	
	self.pers[ "bot_host" ] = true;
}

/*
	Returns if the player is a bot.
*/
is_bot()
{
	assert( isdefined( self ) );
	assert( isplayer( self ) );
	
	return ( ( isdefined( self.pers[ "isBot" ] ) && self.pers[ "isBot" ] ) || ( isdefined( self.pers[ "isBotWarfare" ] ) && self.pers[ "isBotWarfare" ] ) || issubstr( self getguid() + "", "bot" ) );
}

/*
	Set the bot's stance
*/
BotSetStance( stance )
{
	switch ( stance )
	{
		case "stand":
			self maps\mp\bots\_bot_internal::stand();
			break;
			
		case "crouch":
			self maps\mp\bots\_bot_internal::crouch();
			break;
			
		case "prone":
			self maps\mp\bots\_bot_internal::prone();
			break;
	}
}

/*
	Bot presses the frag button for time.
*/
BotPressFrag( time )
{
	self maps\mp\bots\_bot_internal::frag( time );
}

/*
	Bot presses the smoke button for time.
*/
BotPressSmoke( time )
{
	self maps\mp\bots\_bot_internal::smoke( time );
}

/*
	Bot presses the use button for time.
*/
BotPressUse( time )
{
	self maps\mp\bots\_bot_internal::use( time );
}

/*
	Bot will press the ads button for the time
*/
BotpressADS( time )
{
	self maps\mp\bots\_bot_internal::pressADS( time );
}

/*
	Bots will press the attack button for a time
*/
BotPressAttack( time )
{
	self maps\mp\bots\_bot_internal::pressFire( time );
}

/*
	Returns a random number thats different everytime it changes target
*/
BotGetTargetRandom()
{
	if ( !isdefined( self.bot.target ) )
	{
		return undefined;
	}
	
	return self.bot.target.rand;
}

/*
	Returns the bot's random assigned number.
*/
BotGetRandom()
{
	return self.bot.rand;
}

/*
	Returns if the bot is pressing frag button.
*/
IsBotFragging()
{
	return self.bot.isfraggingafter;
}

/*
	Returns if the bot is pressing smoke button.
*/
IsBotSmoking()
{
	return self.bot.issmokingafter;
}

/*
	Returns if the bot is sprinting.
*/
IsBotSprinting()
{
	return self.bot.issprinting;
}

/*
	Returns if the bot is reloading.
*/
IsBotReloading()
{
	return self.bot.isreloading;
}

/*
	Is bot knifing
*/
IsBotKnifing()
{
	return self.bot.isknifingafter;
}

/*
	Freezes the bot's controls.
*/
BotFreezeControls( what )
{
	self.bot.isfrozen = what;
	
	if ( what )
	{
		self notify( "kill_goal" );
	}
}

/*
	Returns if the bot is script frozen.
*/
BotIsFrozen()
{
	return self.bot.isfrozen;
}

/*
	Bot will stop moving
*/
BotStopMoving( what )
{
	self.bot.stop_move = what;
	
	if ( what )
	{
		self notify( "kill_goal" );
	}
}

/*
	Notify the bot chat message
*/
BotNotifyBotEvent( msg, a, b, c, d, e, f, g )
{
	self notify( "bot_event", msg, a, b, c, d, e, f, g );
}

/*
	Returns if the bot has a script goal.
	(like t5 gsc bot)
*/
HasScriptGoal()
{
	return ( isdefined( self GetScriptGoal() ) );
}

/*
	Sets the bot's goal, will acheive it when dist away from it.
*/
SetScriptGoal( goal, dist )
{
	if ( !isdefined( dist ) )
	{
		dist = 16;
	}
	
	self.bot.script_goal = goal;
	self.bot.script_goal_dist = dist;
	waittillframeend;
	self notify( "new_goal_internal" );
	self notify( "new_goal" );
}

/*
	Returns the pos of the bot's goal
*/
GetScriptGoal()
{
	return self.bot.script_goal;
}

/*
	Clears the bot's goal.
*/
ClearScriptGoal()
{
	self SetScriptGoal( undefined, 0 );
}

/*
	Returns the location of the bot's javelin target
*/
HasBotJavelinLocation()
{
	return isdefined( self.bot.jav_loc );
}

/*
	Returns whether the bot has a priority objective
*/
HasPriorityObjective()
{
	return self.bot.prio_objective;
}

/*
	Sets the bot to prioritize the objective over targeting enemies
*/
SetPriorityObjective()
{
	self.bot.prio_objective = true;
	self notify( "kill_goal" );
}

/*
	Clears the bot's priority objective to allow the bot to target enemies automatically again
*/
ClearPriorityObjective()
{
	self.bot.prio_objective = false;
	self notify( "kill_goal" );
}

/*
	Sets the aim position of the bot
*/
SetScriptAimPos( pos )
{
	self.bot.script_aimpos = pos;
}

/*
	Clears the aim position of the bot
*/
ClearScriptAimPos()
{
	self SetScriptAimPos( undefined );
}

/*
	Returns the aim position of the bot
*/
GetScriptAimPos()
{
	return self.bot.script_aimpos;
}

/*
	Returns if the bot has a aim pos
*/
HasScriptAimPos()
{
	return isdefined( self GetScriptAimPos() );
}

/*
	Sets the bot's javelin target location
*/
SetBotJavelinLocation( loc )
{
	self.bot.jav_loc = loc;
	self notify( "new_enemy" );
}

/*
	Clears the bot's javelin location
*/
ClearBotJavelinLocation()
{
	self SetBotJavelinLocation( undefined );
}

/*
	Sets the bot's target to be this ent.
*/
setAttacker( att )
{
	self.bot.target_this_frame = att;
}

/*
	Sets the script enemy for a bot.
*/
SetScriptEnemy( enemy, offset )
{
	self.bot.script_target = enemy;
	self.bot.script_target_offset = offset;
}

/*
	Removes the script enemy of the bot.
*/
ClearScriptEnemy()
{
	self SetScriptEnemy( undefined, undefined );
}

/*
	Returns the entity of the bot's target.
*/
getThreat()
{
	if ( !isdefined( self.bot.target ) )
	{
		return undefined;
	}
	
	return self.bot.target.entity;
}

/*
	Returns if the bot has a script enemy.
*/
HasScriptEnemy()
{
	return ( isdefined( self.bot.script_target ) );
}

/*
	Returns if the bot has a threat.
*/
hasThreat()
{
	return ( isdefined( self getThreat() ) );
}

/*
	If the player is defusing
*/
isDefusing()
{
	return ( isdefined( self.isdefusing ) && self.isdefusing );
}

/*
	If the play is planting
*/
isPlanting()
{
	return ( isdefined( self.isplanting ) && self.isplanting );
}

/*
	If the player is carrying a bomb
*/
isBombCarrier()
{
	return ( isdefined( self.isbombcarrier ) && self.isbombcarrier );
}

/*
	If the site is in use
*/
isInUse()
{
	return ( isdefined( self.inuse ) && self.inuse );
}

/*
	If the player is in laststand
*/
inLastStand()
{
	return ( isdefined( self.laststand ) && self.laststand );
}

/*
	Is being revived
*/
isBeingRevived()
{
	return ( isdefined( self.beingrevived ) && self.beingrevived );
}

/*
	If the player is in final stand
*/
inFinalStand()
{
	return ( isdefined( self.infinalstand ) && self.infinalstand );
}

/*
	If the player is the flag carrier
*/
isFlagCarrier()
{
	return ( isdefined( self.carryflag ) && self.carryflag );
}

/*
	Returns if we are stunned.
*/
isStunned()
{
	return ( isdefined( self.concussionendtime ) && self.concussionendtime > gettime() );
}

/*
	Returns if we are beingArtilleryShellshocked
*/
isArtShocked()
{
	return ( isdefined( self.beingartilleryshellshocked ) && self.beingartilleryshellshocked );
}

/*
	Returns a valid grenade launcher weapon
*/
getValidTube()
{
	weaps = self getweaponslistall();
	
	for ( i = 0; i < weaps.size; i++ )
	{
		weap = weaps[ i ];
		
		if ( !self getammocount( weap ) )
		{
			continue;
		}
		
		if ( ( issubstr( weap, "alt_" ) && ( issubstr( weap, "_m320" ) || issubstr( weap, "_gl" ) || issubstr( weap, "_gp25" ) ) ) || weap == "m320_mp" )
		{
			return weap;
		}
	}
	
	return undefined;
}

/*
	helper
*/
waittill_either_return_( str1, str2 )
{
	self endon( str1 );
	self waittill( str2 );
	return true;
}

/*
	Returns which string gets notified first
*/
waittill_either_return( str1, str2 )
{
	if ( !isdefined( self waittill_either_return_( str1, str2 ) ) )
	{
		return str1;
	}
	
	return str2;
}

/*
	Returns a random grenade in the bot's inventory.
*/
getValidGrenade()
{
	grenadeTypes = [];
	grenadeTypes[ grenadeTypes.size ] = "frag_grenade_mp";
	grenadeTypes[ grenadeTypes.size ] = "smoke_grenade_mp";
	grenadeTypes[ grenadeTypes.size ] = "flash_grenade_mp";
	grenadeTypes[ grenadeTypes.size ] = "concussion_grenade_mp";
	grenadeTypes[ grenadeTypes.size ] = "semtex_mp";
	grenadeTypes[ grenadeTypes.size ] = "throwingknife_mp";
	grenadeTypes[ grenadeTypes.size ] = "emp_grenade_mp";
	
	possibles = [];
	
	for ( i = 0; i < grenadeTypes.size; i++ )
	{
		if ( !self hasweapon( grenadeTypes[ i ] ) )
		{
			continue;
		}
		
		if ( !self getammocount( grenadeTypes[ i ] ) )
		{
			continue;
		}
		
		possibles[ possibles.size ] = grenadeTypes[ i ];
	}
	
	return random( possibles );
}

/*
	If the weapon is not a script weapon (bomb, killstreak, etc, grenades)
*/
isWeaponPrimary( weap )
{
	return ( maps\mp\gametypes\_weapons::isprimaryweapon( weap ) || maps\mp\gametypes\_weapons::isaltmodeweapon( weap ) );
}

/*
	If the ent is a vehicle
*/
entIsVehicle( ent )
{
	return ( !isplayer( ent ) && ( ent.classname == "script_vehicle" || ent.model == "vehicle_uav_static_mp" || ent.model == "vehicle_ac130_coop" || ent.model == "vehicle_predator_b" || ent.model == "vehicle_phantom_ray" ) );
}

/*
	Returns if the given weapon is full auto.
*/
WeaponIsFullAuto( weap )
{
	weaptoks = strtok( weap, "_" );
	
	if ( weaptoks.size < 2 )
	{
		return false;
	}
	
	return isdefined( level.bots_fullautoguns[ weaptoks[ 1 ] ] );
}

/*
	If weap is a secondary gnade
*/
isSecondaryGrenade( gnade )
{
	return ( gnade == "concussion_grenade_mp" || gnade == "flash_grenade_mp" || gnade == "smoke_grenade_mp" || gnade == "trophy_mp" || gnade == "emp_grenade_mp" || gnade == "flare_mp" || gnade == "scrambler_mp" || gnade == "portable_radar_mp" );
}

/*
	If the weapon  is allowed to be dropped
*/
isWeaponDroppable( weap )
{
	return ( maps\mp\gametypes\_weapons::maydropweapon( weap ) );
}

/*
	Does a notify after a delay
*/
notifyAfterDelay( delay, not )
{
	wait delay;
	self notify( not );
}

/*
	Returns a bot to be kicked
*/
getBotToKick()
{
	bots = getBotArray();
	
	if ( !isdefined( bots ) || !isdefined( bots.size ) || bots.size <= 0 || !isdefined( bots[ 0 ] ) )
	{
		return undefined;
	}
	
	tokick = undefined;
	axis = 0;
	allies = 0;
	team = getdvar( "bots_team" );
	
	// count teams
	for ( i = 0; i < bots.size; i++ )
	{
		bot = bots[ i ];
		
		if ( !isdefined( bot ) || !isdefined( bot.team ) )
		{
			continue;
		}
		
		if ( bot.team == "allies" )
		{
			allies++;
		}
		else if ( bot.team == "axis" )
		{
			axis++;
		}
		else // choose bots that are not on a team first
		{
			return bot;
		}
	}
	
	// search for a bot on the other team
	if ( team == "custom" || team == "axis" )
	{
		team = "allies";
	}
	else if ( team == "autoassign" )
	{
		// get the team with the most bots
		team = "allies";
		
		if ( axis > allies )
		{
			team = "axis";
		}
	}
	else
	{
		team = "axis";
	}
	
	// get the bot on this team with lowest skill
	for ( i = 0; i < bots.size; i++ )
	{
		bot = bots[ i ];
		
		if ( !isdefined( bot ) || !isdefined( bot.team ) )
		{
			continue;
		}
		
		if ( bot.team != team )
		{
			continue;
		}
		
		if ( !isdefined( bot.pers ) || !isdefined( bot.pers[ "bots" ] ) || !isdefined( bot.pers[ "bots" ][ "skill" ] ) || !isdefined( bot.pers[ "bots" ][ "skill" ][ "base" ] ) )
		{
			continue;
		}
		
		if ( isdefined( tokick ) && bot.pers[ "bots" ][ "skill" ][ "base" ] > tokick.pers[ "bots" ][ "skill" ][ "base" ] )
		{
			continue;
		}
		
		tokick = bot;
	}
	
	if ( isdefined( tokick ) )
	{
		return tokick;
	}
	
	// just kick lowest skill
	for ( i = 0; i < bots.size; i++ )
	{
		bot = bots[ i ];
		
		if ( !isdefined( bot ) || !isdefined( bot.team ) )
		{
			continue;
		}
		
		if ( !isdefined( bot.pers ) || !isdefined( bot.pers[ "bots" ] ) || !isdefined( bot.pers[ "bots" ][ "skill" ] ) || !isdefined( bot.pers[ "bots" ][ "skill" ][ "base" ] ) )
		{
			continue;
		}
		
		if ( isdefined( tokick ) && bot.pers[ "bots" ][ "skill" ][ "base" ] > tokick.pers[ "bots" ][ "skill" ][ "base" ] )
		{
			continue;
		}
		
		tokick = bot;
	}
	
	return tokick;
}

/*
	Gets a player who is host
*/
GetHostPlayer()
{
	for ( i = 0; i < level.players.size; i++ )
	{
		player = level.players[ i ];
		
		if ( !player is_host() )
		{
			continue;
		}
		
		return player;
	}
	
	return undefined;
}

/*
    Waits for a host player
*/
bot_wait_for_host()
{
	host = undefined;
	
	while ( !isdefined( level ) || !isdefined( level.players ) )
	{
		wait 0.05;
	}
	
	for ( i = getdvarfloat( "bots_main_waitForHostTime" ); i > 0; i -= 0.05 )
	{
		host = GetHostPlayer();
		
		if ( isdefined( host ) )
		{
			break;
		}
		
		wait 0.05;
	}
	
	if ( !isdefined( host ) )
	{
		return;
	}
	
	for ( i = getdvarfloat( "bots_main_waitForHostTime" ); i > 0; i -= 0.05 )
	{
		if ( isdefined( host.pers[ "team" ] ) )
		{
			break;
		}
		
		wait 0.05;
	}
	
	if ( !isdefined( host.pers[ "team" ] ) )
	{
		return;
	}
	
	for ( i = getdvarfloat( "bots_main_waitForHostTime" ); i > 0; i -= 0.05 )
	{
		if ( host.pers[ "team" ] == "allies" || host.pers[ "team" ] == "axis" )
		{
			break;
		}
		
		wait 0.05;
	}
}

/*
	Pezbot's line sphere intersection.
	http://paulbourke.net/geometry/circlesphere/raysphere.c
*/
RaySphereIntersect( start, end, spherePos, radius )
{
	// check if the start or end points are in the sphere
	r2 = radius * radius;
	
	if ( distancesquared( start, spherePos ) < r2 )
	{
		return true;
	}
	
	if ( distancesquared( end, spherePos ) < r2 )
	{
		return true;
	}
	
	// check if the line made by start and end intersect the sphere
	dp = end - start;
	a = dp[ 0 ] * dp[ 0 ] + dp[ 1 ] * dp[ 1 ] + dp[ 2 ] * dp[ 2 ];
	b = 2 * ( dp[ 0 ] * ( start[ 0 ] - spherePos[ 0 ] ) + dp[ 1 ] * ( start[ 1 ] - spherePos[ 1 ] ) + dp[ 2 ] * ( start[ 2 ] - spherePos[ 2 ] ) );
	c = spherePos[ 0 ] * spherePos[ 0 ] + spherePos[ 1 ] * spherePos[ 1 ] + spherePos[ 2 ] * spherePos[ 2 ];
	c += start[ 0 ] * start[ 0 ] + start[ 1 ] * start[ 1 ] + start[ 2 ] * start[ 2 ];
	c -= 2.0 * ( spherePos[ 0 ] * start[ 0 ] + spherePos[ 1 ] * start[ 1 ] + spherePos[ 2 ] * start[ 2 ] );
	c -= radius * radius;
	bb4ac = b * b - 4.0 * a * c;
	
	if ( abs( a ) < 0.0001 || bb4ac < 0 )
	{
		return false;
	}
	
	mu1 = ( 0 - b + sqrt( bb4ac ) ) / ( 2 * a );
	// mu2 = (0-b - sqrt(bb4ac)) / (2 * a);
	
	// intersection points of the sphere
	ip1 = start + mu1 * dp;
	// ip2 = start + mu2 * dp;
	
	myDist = distancesquared( start, end );
	
	// check if both intersection points far
	if ( distancesquared( start, ip1 ) > myDist/* && distancesquared(start, ip2) > myDist*/ )
	{
		return false;
	}
	
	dpAngles = vectortoangles( dp );
	
	// check if the point is behind us
	if ( getConeDot( ip1, start, dpAngles ) < 0/* || getConeDot(ip2, start, dpAngles) < 0*/ )
	{
		return false;
	}
	
	return true;
}

/*
	Returns if a smoke grenade would intersect start to end line.
*/
SmokeTrace( start, end, rad )
{
	for ( i = level.bots_smokelist.count - 1; i >= 0; i-- )
	{
		nade = level.bots_smokelist.data[ i ];
		
		if ( nade.state != "smoking" )
		{
			continue;
		}
		
		if ( !RaySphereIntersect( start, end, nade.origin, rad ) )
		{
			continue;
		}
		
		return false;
	}
	
	return true;
}

/*
	Returns the cone dot (like fov, or distance from the center of our screen).
*/
getConeDot( to, from, dir )
{
	dirToTarget = vectornormalize( to - from );
	forward = anglestoforward( dir );
	return vectordot( dirToTarget, forward );
}

/*
	Returns the distance squared in a 2d space
*/
distancesquared2D( to, from )
{
	to = ( to[ 0 ], to[ 1 ], 0 );
	from = ( from[ 0 ], from[ 1 ], 0 );
	
	return distancesquared( to, from );
}

/*
	Rounds to the nearest whole number.
*/
Round( x )
{
	y = int( x );
	
	if ( abs( x ) - abs( y ) > 0.5 )
	{
		if ( x < 0 )
		{
			return y - 1;
		}
		else
		{
			return y + 1;
		}
	}
	else
	{
		return y;
	}
}

/*
	converts a string into a float
*/
float_old( num )
{
	setdvar( "temp_dvar_bot_util", num );
	
	return getdvarfloat( "temp_dvar_bot_util" );
}

/*
	If the string starts with
*/
isStrStart( string1, subStr )
{
	return ( getsubstr( string1, 0, subStr.size ) == subStr );
}

/*
	Parses tokens into a waypoint obj
*/
parseTokensIntoWaypoint( tokens )
{
	waypoint = spawnstruct();
	
	orgStr = tokens[ 0 ];
	orgToks = strtok( orgStr, " " );
	waypoint.origin = ( float_old( orgToks[ 0 ] ), float_old( orgToks[ 1 ] ), float_old( orgToks[ 2 ] ) );
	
	childStr = tokens[ 1 ];
	childToks = strtok( childStr, " " );
	waypoint.children = [];
	
	for ( j = 0; j < childToks.size; j++ )
	{
		waypoint.children[ j ] = int( childToks[ j ] );
	}
	
	type = tokens[ 2 ];
	waypoint.type = type;
	
	anglesStr = tokens[ 3 ];
	
	if ( isdefined( anglesStr ) && anglesStr != "" )
	{
		anglesToks = strtok( anglesStr, " " );
		
		if ( anglesToks.size >= 3 )
		{
			waypoint.angles = ( float_old( anglesToks[ 0 ] ), float_old( anglesToks[ 1 ] ), float_old( anglesToks[ 2 ] ) );
		}
	}
	
	javStr = tokens[ 4 ];
	
	if ( isdefined( javStr ) && javStr != "" )
	{
		javToks = strtok( javStr, " " );
		
		if ( javToks.size >= 3 )
		{
			waypoint.jav_point = ( float_old( javToks[ 0 ] ), float_old( javToks[ 1 ] ), float_old( javToks[ 2 ] ) );
		}
	}
	
	return waypoint;
}

/*
	Function to extract lines from a file specified by 'filename' and store them in a result structure.
*/
getWaypointLinesFromFile( filename )
{
	// Create a structure to store the result, including an array to hold individual lines.
	result = spawnstruct();
	result.lines = [];
	
	// Read the entire content of the file into the 'waypointStr' variable.
	// Note: max string length in GSC is 65535.
	waypointStr = BotBuiltinFileRead( filename );
	
	// If the file is empty or not defined, return the empty result structure.
	if ( !isdefined( waypointStr ) )
	{
		return result;
	}
	
	// Variables to track the current line's character count and starting position.
	linecount = 0;
	linestart = 0;
	
	// Iterate through each character in the 'waypointStr'.
	for ( i = 0; i < waypointStr.size; i++ )
	{
		// Check for newline characters '\n' or '\r'.
		if ( waypointStr[ i ] == "\n" || waypointStr[ i ] == "\r" )
		{
			// Extract the current line using 'getsubstr' and store it in the result array.
			result.lines[ result.lines.size ] = getsubstr( waypointStr, linestart, linestart + linecount );
			
			// If the newline is '\r\n', skip the next character.
			if ( waypointStr[ i ] == "\r" && i < waypointStr.size - 1 && waypointStr[ i + 1 ] == "\n" )
			{
				i++;
			}
			
			// Reset linecount and update linestart for the next line.
			linecount = 0;
			linestart = i + 1;
			continue;
		}
		
		// Increment linecount for the current line.
		linecount++;
	}
	
	// Store the last line (or the only line if there are no newline characters) in the result array.
	result.lines[ result.lines.size ] = getsubstr( waypointStr, linestart, linestart + linecount );
	
	// Return the result structure containing the array of extracted lines.
	return result;
}

/*
	Loads waypoints from file
*/
readWpsFromFile( mapname )
{
	waypoints = [];
	filename = "waypoints/" + mapname + "_wp.csv";
	
	if ( !BotBuiltinFileExists( filename ) )
	{
		return waypoints;
	}
	
	res = getWaypointLinesFromFile( filename );
	
	if ( !res.lines.size )
	{
		return waypoints;
	}
	
	BotBuiltinPrintConsole( "Attempting to read waypoints from " + filename );
	
	waypointCount = int( res.lines[ 0 ] );
	
	for ( i = 1; i <= waypointCount; i++ )
	{
		tokens = strtok( res.lines[ i ], "," );
		
		waypoint = parseTokensIntoWaypoint( tokens );
		
		waypoints[ i - 1 ] = waypoint;
	}
	
	return waypoints;
	
	return [];
}

/*
	Loads the waypoints. Populating everything needed for the waypoints.
*/
load_waypoints()
{
	level.waypointcount = 0;
	level.waypointusage = [];
	level.waypointusage[ "allies" ] = [];
	level.waypointusage[ "axis" ] = [];
	
	if ( !isdefined( level.waypoints ) )
	{
		level.waypoints = [];
	}
	
	mapname = getdvar( "mapname" );
	
	wps = readWpsFromFile( mapname );
	
	if ( wps.size )
	{
		level.waypoints = wps;
		BotBuiltinPrintConsole( "Loaded " + wps.size + " waypoints from csv." );
	}
	else
	{
		switch ( mapname )
		{
			default:
				maps\mp\bots\waypoints\_custom_map::main( mapname );
				break;
		}
		
		if ( level.waypoints.size )
		{
			BotBuiltinPrintConsole( "Loaded " + level.waypoints.size + " waypoints from script." );
		}
	}
	
	if ( !level.waypoints.size )
	{
		BotBuiltinPrintConsole( "No waypoints loaded!" );
	}
	
	level.waypointcount = level.waypoints.size;
	
	for ( i = 0; i < level.waypointcount; i++ )
	{
		if ( !isdefined( level.waypoints[ i ].children ) || !isdefined( level.waypoints[ i ].children.size ) )
		{
			level.waypoints[ i ].children = [];
		}
		
		if ( !isdefined( level.waypoints[ i ].origin ) )
		{
			level.waypoints[ i ].origin = ( 0, 0, 0 );
		}
		
		if ( !isdefined( level.waypoints[ i ].type ) )
		{
			level.waypoints[ i ].type = "crouch";
		}
	}
}

/*
	Is bot near any of the given waypoints
*/
nearAnyOfWaypoints( dist, waypoints )
{
	dist *= dist;
	
	for ( i = 0; i < waypoints.size; i++ )
	{
		waypoint = level.waypoints[ waypoints[ i ] ];
		
		if ( distancesquared( waypoint.origin, self.origin ) > dist )
		{
			continue;
		}
		
		return true;
	}
	
	return false;
}

/*
	Returns the waypoints that are near
*/
waypointsNear( waypoints, dist )
{
	dist *= dist;
	
	answer = [];
	
	for ( i = 0; i < waypoints.size; i++ )
	{
		wp = level.waypoints[ waypoints[ i ] ];
		
		if ( distancesquared( wp.origin, self.origin ) > dist )
		{
			continue;
		}
		
		answer[ answer.size ] = waypoints[ i ];
	}
	
	return answer;
}

/*
	Returns nearest waypoint of waypoints
*/
getNearestWaypointOfWaypoints( waypoints )
{
	answer = undefined;
	closestDist = 2147483647;
	
	for ( i = 0; i < waypoints.size; i++ )
	{
		waypoint = level.waypoints[ waypoints[ i ] ];
		thisDist = distancesquared( self.origin, waypoint.origin );
		
		if ( isdefined( answer ) && thisDist > closestDist )
		{
			continue;
		}
		
		answer = waypoints[ i ];
		closestDist = thisDist;
	}
	
	return answer;
}

/*
	Returns all waypoints of type
*/
getWaypointsOfType( type )
{
	answer = [];
	
	for ( i = 0; i < level.waypointcount; i++ )
	{
		wp = level.waypoints[ i ];
		
		if ( type == "camp" )
		{
			if ( wp.type != "crouch" )
			{
				continue;
			}
			
			if ( wp.children.size != 1 )
			{
				continue;
			}
		}
		else if ( type != wp.type )
		{
			continue;
		}
		
		answer[ answer.size ] = i;
	}
	
	return answer;
}

/*
	Returns the waypoint for index
*/
getWaypointForIndex( i )
{
	if ( !isdefined( i ) )
	{
		return undefined;
	}
	
	return level.waypoints[ i ];
}

/*
	Returns the friendly user name for a given map's codename
*/
getMapName( mapname )
{
	switch ( mapname )
	{
		case "mp_dome":
			return "Dome";
			
		default:
			return mapname;
	}
}

/*
	Returns a good amount of players.
*/
getGoodMapAmount()
{
	switch ( getdvar( "mapname" ) )
	{
		case "mp_dome":
			if ( level.teambased )
			{
				return 8;
			}
			else
			{
				return 5;
			}
			
		default:
			return 2;
	}
}

/*
	Matches a num to a char
*/
keyCodeToString( a )
{
	b = "";
	
	switch ( a )
	{
		case 0:
			b = "a";
			break;
			
		case 1:
			b = "b";
			break;
			
		case 2:
			b = "c";
			break;
			
		case 3:
			b = "d";
			break;
			
		case 4:
			b = "e";
			break;
			
		case 5:
			b = "f";
			break;
			
		case 6:
			b = "g";
			break;
			
		case 7:
			b = "h";
			break;
			
		case 8:
			b = "i";
			break;
			
		case 9:
			b = "j";
			break;
			
		case 10:
			b = "k";
			break;
			
		case 11:
			b = "l";
			break;
			
		case 12:
			b = "m";
			break;
			
		case 13:
			b = "n";
			break;
			
		case 14:
			b = "o";
			break;
			
		case 15:
			b = "p";
			break;
			
		case 16:
			b = "q";
			break;
			
		case 17:
			b = "r";
			break;
			
		case 18:
			b = "s";
			break;
			
		case 19:
			b = "t";
			break;
			
		case 20:
			b = "u";
			break;
			
		case 21:
			b = "v";
			break;
			
		case 22:
			b = "w";
			break;
			
		case 23:
			b = "x";
			break;
			
		case 24:
			b = "y";
			break;
			
		case 25:
			b = "z";
			break;
			
		case 26:
			b = ".";
			break;
			
		case 27:
			b = " ";
			break;
	}
	
	return b;
}

/*
	Returns an array of all the bots in the game.
*/
getBotArray()
{
	result = [];
	playercount = level.players.size;
	
	for ( i = 0; i < playercount; i++ )
	{
		player = level.players[ i ];
		
		if ( !player is_bot() )
		{
			continue;
		}
		
		result[ result.size ] = player;
	}
	
	return result;
}

/*
	We return a balanced KDTree from the waypoints.
*/
WaypointsToKDTree()
{
	kdTree = KDTree();
	
	kdTree _WaypointsToKDTree( level.waypoints, 0 );
	
	return kdTree;
}

/*
	Recurive function. We construct a balanced KD tree by sorting the waypoints using heap sort.
*/
_WaypointsToKDTree( waypoints, dem )
{
	if ( !waypoints.size )
	{
		return;
	}
	
	callbacksort = undefined;
	
	switch ( dem )
	{
		case 0:
			callbacksort = ::HeapSortCoordX;
			break;
			
		case 1:
			callbacksort = ::HeapSortCoordY;
			break;
			
		case 2:
			callbacksort = ::HeapSortCoordZ;
			break;
	}
	
	heap = NewHeap( callbacksort );
	
	for ( i = 0; i < waypoints.size; i++ )
	{
		heap HeapInsert( waypoints[ i ] );
	}
	
	sorted = [];
	
	while ( heap.data.size )
	{
		sorted[ sorted.size ] = heap.data[ 0 ];
		heap HeapRemove();
	}
	
	median = int( sorted.size / 2 ); // use divide and conq
	
	left = [];
	right = [];
	
	for ( i = 0; i < sorted.size; i++ )
	{
		if ( i < median )
		{
			right[ right.size ] = sorted[ i ];
		}
		else if ( i > median )
		{
			left[ left.size ] = sorted[ i ];
		}
	}
	
	self KDTreeInsert( sorted[ median ] );
	
	_WaypointsToKDTree( left, ( dem + 1 ) % 3 );
	
	_WaypointsToKDTree( right, ( dem + 1 ) % 3 );
}

/*
	Returns a new list.
*/
List()
{
	list = spawnstruct();
	list.count = 0;
	list.data = [];
	
	return list;
}

/*
	Adds a new thing to the list.
*/
ListAdd( thing )
{
	self.data[ self.count ] = thing;
	
	self.count++;
}

/*
	Adds to the start of the list.
*/
ListAddFirst( thing )
{
	for ( i = self.count - 1; i >= 0; i-- )
	{
		self.data[ i + 1 ] = self.data[ i ];
	}
	
	self.data[ 0 ] = thing;
	self.count++;
}

/*
	Removes the thing from the list.
*/
ListRemove( thing )
{
	for ( i = 0; i < self.count; i++ )
	{
		if ( self.data[ i ] == thing )
		{
			while ( i < self.count - 1 )
			{
				self.data[ i ] = self.data[ i + 1 ];
				i++;
			}
			
			self.data[ i ] = undefined;
			self.count--;
			break;
		}
	}
}

/*
	Returns a new KDTree.
*/
KDTree()
{
	kdTree = spawnstruct();
	kdTree.root = undefined;
	kdTree.count = 0;
	
	return kdTree;
}

/*
	Called on a KDTree. Will insert the object into the KDTree.
*/
KDTreeInsert( data ) // as long as what you insert has a .origin attru, it will work.
{
	self.root = self _KDTreeInsert( self.root, data, 0, -2147483647, -2147483647, -2147483647, 2147483647, 2147483647, 2147483647 );
}

/*
	Recurive function that insert the object into the KDTree.
*/
_KDTreeInsert( node, data, dem, x0, y0, z0, x1, y1, z1 )
{
	if ( !isdefined( node ) )
	{
		r = spawnstruct();
		r.data = data;
		r.left = undefined;
		r.right = undefined;
		r.x0 = x0;
		r.x1 = x1;
		r.y0 = y0;
		r.y1 = y1;
		r.z0 = z0;
		r.z1 = z1;
		
		self.count++;
		
		return r;
	}
	
	switch ( dem )
	{
		case 0:
			if ( data.origin[ 0 ] < node.data.origin[ 0 ] )
			{
				node.left = self _KDTreeInsert( node.left, data, 1, x0, y0, z0, node.data.origin[ 0 ], y1, z1 );
			}
			else
			{
				node.right = self _KDTreeInsert( node.right, data, 1, node.data.origin[ 0 ], y0, z0, x1, y1, z1 );
			}
			
			break;
			
		case 1:
			if ( data.origin[ 1 ] < node.data.origin[ 1 ] )
			{
				node.left = self _KDTreeInsert( node.left, data, 2, x0, y0, z0, x1, node.data.origin[ 1 ], z1 );
			}
			else
			{
				node.right = self _KDTreeInsert( node.right, data, 2, x0, node.data.origin[ 1 ], z0, x1, y1, z1 );
			}
			
			break;
			
		case 2:
			if ( data.origin[ 2 ] < node.data.origin[ 2 ] )
			{
				node.left = self _KDTreeInsert( node.left, data, 0, x0, y0, z0, x1, y1, node.data.origin[ 2 ] );
			}
			else
			{
				node.right = self _KDTreeInsert( node.right, data, 0, x0, y0, node.data.origin[ 2 ], x1, y1, z1 );
			}
			
			break;
	}
	
	return node;
}

/*
	Called on a KDTree, will return the nearest object to the given origin.
*/
KDTreeNearest( origin )
{
	if ( !isdefined( self.root ) )
	{
		return undefined;
	}
	
	return self _KDTreeNearest( self.root, origin, self.root.data, distancesquared( self.root.data.origin, origin ), 0 );
}

/*
	Recurive function that will retrieve the closest object to the query.
*/
_KDTreeNearest( node, point, closest, closestdist, dem )
{
	if ( !isdefined( node ) )
	{
		return closest;
	}
	
	thisDis = distancesquared( node.data.origin, point );
	
	if ( thisDis < closestdist )
	{
		closestdist = thisDis;
		closest = node.data;
	}
	
	if ( node Rectdistancesquared( point ) < closestdist )
	{
		near = node.left;
		far = node.right;
		
		if ( point[ dem ] > node.data.origin[ dem ] )
		{
			near = node.right;
			far = node.left;
		}
		
		closest = self _KDTreeNearest( near, point, closest, closestdist, ( dem + 1 ) % 3 );
		
		closest = self _KDTreeNearest( far, point, closest, distancesquared( closest.origin, point ), ( dem + 1 ) % 3 );
	}
	
	return closest;
}

/*
	Called on a rectangle, returns the distance from origin to the rectangle.
*/
Rectdistancesquared( origin )
{
	dx = 0;
	dy = 0;
	dz = 0;
	
	if ( origin[ 0 ] < self.x0 )
	{
		dx = origin[ 0 ] - self.x0;
	}
	else if ( origin[ 0 ] > self.x1 )
	{
		dx = origin[ 0 ] - self.x1;
	}
	
	if ( origin[ 1 ] < self.y0 )
	{
		dy = origin[ 1 ] - self.y0;
	}
	else if ( origin[ 1 ] > self.y1 )
	{
		dy = origin[ 1 ] - self.y1;
	}
	
	
	if ( origin[ 2 ] < self.z0 )
	{
		dz = origin[ 2 ] - self.z0;
	}
	else if ( origin[ 2 ] > self.z1 )
	{
		dz = origin[ 2 ] - self.z1;
	}
	
	return dx * dx + dy * dy + dz * dz;
}

/*
	Does the extra check when adding bots
*/
doExtraCheck()
{
	maps\mp\bots\_bot_internal::checkTheBots();
}

/*
	A heap invarient comparitor, used for objects, objects with a higher X coord will be first in the heap.
*/
HeapSortCoordX( item, item2 )
{
	return item.origin[ 0 ] > item2.origin[ 0 ];
}

/*
	A heap invarient comparitor, used for objects, objects with a higher Y coord will be first in the heap.
*/
HeapSortCoordY( item, item2 )
{
	return item.origin[ 1 ] > item2.origin[ 1 ];
}

/*
	A heap invarient comparitor, used for objects, objects with a higher Z coord will be first in the heap.
*/
HeapSortCoordZ( item, item2 )
{
	return item.origin[ 2 ] > item2.origin[ 2 ];
}

/*
	A heap invarient comparitor, used for numbers, numbers with the highest number will be first in the heap.
*/
Heap( item, item2 )
{
	return item > item2;
}

/*
	A heap invarient comparitor, used for numbers, numbers with the lowest number will be first in the heap.
*/
ReverseHeap( item, item2 )
{
	return item < item2;
}

/*
	A heap invarient comparitor, used for traces. Wanting the trace with the largest length first in the heap.
*/
HeapTraceFraction( item, item2 )
{
	return item[ "fraction" ] > item2[ "fraction" ];
}

/*
	Returns a new heap.
*/
NewHeap( compare )
{
	heap_node = spawnstruct();
	heap_node.data = [];
	heap_node.compare = compare;
	
	return heap_node;
}

/*
	Inserts the item into the heap. Called on a heap.
*/
HeapInsert( item )
{
	insert = self.data.size;
	self.data[ insert ] = item;
	
	current = insert + 1;
	
	while ( current > 1 )
	{
		last = current;
		current = int( current / 2 );
		
		if ( ![[ self.compare ]]( item, self.data[ current - 1 ] ) )
		{
			break;
		}
		
		self.data[ last - 1 ] = self.data[ current - 1 ];
		self.data[ current - 1 ] = item;
	}
}

/*
	Helper function to determine what is the next child of the bst.
*/
_HeapNextChild( node, hsize )
{
	left = node * 2;
	right = left + 1;
	
	if ( left > hsize )
	{
		return -1;
	}
	
	if ( right > hsize )
	{
		return left;
	}
	
	if ( [[ self.compare ]]( self.data[ left - 1 ], self.data[ right - 1 ] ) )
	{
		return left;
	}
	else
	{
		return right;
	}
}

/*
	Removes an item from the heap. Called on a heap.
*/
HeapRemove()
{
	remove = self.data.size;
	
	if ( !remove )
	{
		return remove;
	}
	
	move = self.data[ remove - 1 ];
	self.data[ 0 ] = move;
	self.data[ remove - 1 ] = undefined;
	remove--;
	
	if ( !remove )
	{
		return remove;
	}
	
	last = 1;
	next = self _HeapNextChild( 1, remove );
	
	while ( next != -1 )
	{
		if ( [[ self.compare ]]( move, self.data[ next - 1 ] ) )
		{
			break;
		}
		
		self.data[ last - 1 ] = self.data[ next - 1 ];
		self.data[ next - 1 ] = move;
		
		last = next;
		next = self _HeapNextChild( next, remove );
	}
	
	return remove;
}

/*
	A heap invarient comparitor, used for the astar's nodes, wanting the node with the lowest f to be first in the heap.
*/
ReverseHeapAStar( item, item2 )
{
	return item.f < item2.f;
}

/*
	Removes the waypoint usage
*/
RemoveWaypointUsage( wp, team )
{
	if ( !isdefined( level.waypointusage ) )
	{
		return;
	}
	
	if ( !isdefined( level.waypointusage[ team ][ wp + "" ] ) )
	{
		return;
	}
	
	level.waypointusage[ team ][ wp + "" ]--;
	
	if ( level.waypointusage[ team ][ wp + "" ] <= 0 )
	{
		level.waypointusage[ team ][ wp + "" ] = undefined;
	}
}

/*
	Will linearly search for the nearest waypoint to pos that has a direct line of sight.
*/
GetNearestWaypointWithSight( pos )
{
	candidate = undefined;
	dist = 2147483647;
	
	for ( i = 0; i < level.waypointcount; i++ )
	{
		if ( !bullettracepassed( pos + ( 0, 0, 15 ), level.waypoints[ i ].origin + ( 0, 0, 15 ), false, undefined ) )
		{
			continue;
		}
		
		curdis = distancesquared( level.waypoints[ i ].origin, pos );
		
		if ( curdis > dist )
		{
			continue;
		}
		
		dist = curdis;
		candidate = i;
	}
	
	return candidate;
}

/*
	Will linearly search for the nearest waypoint
*/
getNearestWaypoint( pos )
{
	candidate = undefined;
	dist = 2147483647;
	
	for ( i = 0; i < level.waypointcount; i++ )
	{
		curdis = distancesquared( level.waypoints[ i ].origin, pos );
		
		if ( curdis > dist )
		{
			continue;
		}
		
		dist = curdis;
		candidate = i;
	}
	
	return candidate;
}

/*
	Modified Pezbot astar search.
	This makes use of sets for quick look up and a heap for a priority queue instead of simple lists which require to linearly search for elements everytime.
	It is also modified to make paths with bots already on more expensive and will try a less congested path first. Thus spliting up the bots onto more paths instead of just one (the smallest).
*/
AStarSearch( start, goal, team, greedy_path )
{
	open = NewHeap( ::ReverseHeapAStar ); // heap
	openset = []; // set for quick lookup
	closed = []; // set for quick lookup
	
	
	startWp = getNearestWaypoint( start );
	
	if ( !isdefined( startWp ) )
	{
		return [];
	}
	
	_startwp = undefined;
	
	if ( !bullettracepassed( start + ( 0, 0, 15 ), level.waypoints[ startWp ].origin + ( 0, 0, 15 ), false, undefined ) )
	{
		_startwp = GetNearestWaypointWithSight( start );
	}
	
	if ( isdefined( _startwp ) )
	{
		startWp = _startwp;
	}
	
	
	goalWp = getNearestWaypoint( goal );
	
	if ( !isdefined( goalWp ) )
	{
		return [];
	}
	
	_goalwp = undefined;
	
	if ( !bullettracepassed( goal + ( 0, 0, 15 ), level.waypoints[ goalWp ].origin + ( 0, 0, 15 ), false, undefined ) )
	{
		_goalwp = GetNearestWaypointWithSight( goal );
	}
	
	if ( isdefined( _goalwp ) )
	{
		goalWp = _goalwp;
	}
	
	
	node = spawnstruct();
	node.g = 0; // path dist so far
	node.h = distancesquared( level.waypoints[ startWp ].origin, level.waypoints[ goalWp ].origin ); // herustic, distance to goal for path finding
	node.f = node.h + node.g; // combine path dist and heru, use reverse heap to sort the priority queue by this attru
	node.index = startWp;
	node.parent = undefined; // we are start, so we have no parent
	
	// push node onto queue
	openset[ node.index + "" ] = node;
	open HeapInsert( node );
	
	// while the queue is not empty
	while ( open.data.size )
	{
		// pop bestnode from queue
		bestNode = open.data[ 0 ];
		open HeapRemove();
		openset[ bestNode.index + "" ] = undefined;
		wp = level.waypoints[ bestNode.index ];
		
		// check if we made it to the goal
		if ( bestNode.index == goalWp )
		{
			path = [];
			
			while ( isdefined( bestNode ) )
			{
				if ( isdefined( team ) && isdefined( level.waypointusage ) )
				{
					if ( !isdefined( level.waypointusage[ team ][ bestNode.index + "" ] ) )
					{
						level.waypointusage[ team ][ bestNode.index + "" ] = 0;
					}
					
					level.waypointusage[ team ][ bestNode.index + "" ]++;
				}
				
				// construct path
				path[ path.size ] = bestNode.index;
				
				bestNode = bestNode.parent;
			}
			
			return path;
		}
		
		// for each child of bestnode
		for ( i = wp.children.size - 1; i >= 0; i-- )
		{
			child = wp.children[ i ];
			childWp = level.waypoints[ child ];
			
			penalty = 1;
			
			if ( !greedy_path && isdefined( team ) && isdefined( level.waypointusage ) )
			{
				temppen = 1;
				
				if ( isdefined( level.waypointusage[ team ][ child + "" ] ) )
				{
					temppen = level.waypointusage[ team ][ child + "" ]; // consider how many bots are taking this path
				}
				
				if ( temppen > 1 )
				{
					penalty = temppen;
				}
			}
			
			// have certain types of nodes more expensive
			if ( childWp.type == "climb" || childWp.type == "prone" )
			{
				penalty += 4;
			}
			
			// calc the total path we have took
			newg = bestNode.g + distancesquared( wp.origin, childWp.origin ) * penalty; // bots on same team's path are more expensive
			
			// check if this child is in open or close with a g value less than newg
			inopen = isdefined( openset[ child + "" ] );
			
			if ( inopen && openset[ child + "" ].g <= newg )
			{
				continue;
			}
			
			inclosed = isdefined( closed[ child + "" ] );
			
			if ( inclosed && closed[ child + "" ].g <= newg )
			{
				continue;
			}
			
			node = undefined;
			
			if ( inopen )
			{
				node = openset[ child + "" ];
			}
			else if ( inclosed )
			{
				node = closed[ child + "" ];
			}
			else
			{
				node = spawnstruct();
			}
			
			node.parent = bestNode;
			node.g = newg;
			node.h = distancesquared( childWp.origin, level.waypoints[ goalWp ].origin );
			node.f = node.g + node.h;
			node.index = child;
			
			// check if in closed, remove it
			if ( inclosed )
			{
				closed[ child + "" ] = undefined;
			}
			
			// check if not in open, add it
			if ( !inopen )
			{
				open HeapInsert( node );
				openset[ child + "" ] = node;
			}
		}
		
		// done with children, push onto closed
		closed[ bestNode.index + "" ] = bestNode;
	}
	
	return [];
}

/*
	Taken from t5 gsc.
	Returns an array of number's average.
*/
array_average( array )
{
	assert( array.size > 0 );
	total = 0;
	
	for ( i = 0; i < array.size; i++ )
	{
		total += array[ i ];
	}
	
	return ( total / array.size );
}

/*
	Taken from t5 gsc.
	Returns an array of number's standard deviation.
*/
array_std_deviation( array, mean )
{
	assert( array.size > 0 );
	tmp = [];
	
	for ( i = 0; i < array.size; i++ )
	{
		tmp[ i ] = ( array[ i ] - mean ) * ( array[ i ] - mean );
	}
	
	total = 0;
	
	for ( i = 0; i < tmp.size; i++ )
	{
		total = total + tmp[ i ];
	}
	
	return sqrt( total / array.size );
}

/*
	Taken from t5 gsc.
	Will produce a random number between lower_bound and upper_bound but with a bell curve distribution (more likely to be close to the mean).
*/
random_normal_distribution( mean, std_deviation, lower_bound, upper_bound )
{
	x1 = 0;
	x2 = 0;
	w = 1;
	y1 = 0;
	
	while ( w >= 1 )
	{
		x1 = 2 * randomfloatrange( 0, 1 ) - 1;
		x2 = 2 * randomfloatrange( 0, 1 ) - 1;
		w = x1 * x1 + x2 * x2;
	}
	
	w = sqrt( ( -2.0 * log( w ) ) / w );
	y1 = x1 * w;
	number = mean + y1 * std_deviation;
	
	if ( isdefined( lower_bound ) && number < lower_bound )
	{
		number = lower_bound;
	}
	
	if ( isdefined( upper_bound ) && number > upper_bound )
	{
		number = upper_bound;
	}
	
	return ( number );
}

/*
	Patches the plant sites so it exposes the defuseObject
*/
onUsePlantObjectFix( player )
{
	if ( !maps\mp\gametypes\_gameobjects::isfriendlyteam( player.pers[ "team" ] ) )
	{
		level thread bombPlantedFix( self, player );
		
		for ( i = 0; i < level.bombzones.size; i++ )
		{
			if ( level.bombzones[ i ] == self )
			{
				continue;
			}
			
			level.bombzones[ i ] maps\mp\gametypes\_gameobjects::disableobject();
		}
		
		player playsound( "mp_bomb_plant" );
		player notify( "bomb_planted" );
		player notify( "objective", "plant" );
		player maps\mp\_utility::incpersstat( "plants", 1 );
		player maps\mp\gametypes\_persistence::statsetchild( "round", "plants", player.pers[ "plants" ] );
		
		if ( isdefined( level.sd_loadout ) && isdefined( level.sd_loadout[ player.team ] ) )
		{
			player thread maps\mp\gametypes\sd::removebombcarrierclass();
		}
		
		maps\mp\_utility::leaderdialog( "bomb_planted" );
		level thread maps\mp\_utility::teamplayercardsplash( "callout_bombplanted", player );
		level.bombowner = player;
		player thread maps\mp\gametypes\_hud_message::splashnotify( "plant", maps\mp\gametypes\_rank::getscoreinfovalue( "plant" ) );
		player thread maps\mp\gametypes\_rank::giverankxp( "plant" );
		player.bombplantedtime = gettime();
		maps\mp\gametypes\_gamescore::giveplayerscore( "plant", player );
		player thread maps\mp\_matchdata::loggameevent( "plant", player.origin );
	}
}

/*
	Patches the plant sites so it exposes the defuseObject
*/
bombPlantedFix( var_0, var_1 )
{
	maps\mp\gametypes\_gamelogic::pausetimer();
	level.bombplanted = 1;
	var_0.visuals[ 0 ] thread maps\mp\gametypes\_gamelogic::playtickingsound();
	level.tickingobject = var_0.visuals[ 0 ];
	level.timelimitoverride = 1;
	setgameendtime( int( gettime() + level.bombtimer * 1000 ) );
	setdvar( "ui_bomb_timer", 1 );
	
	if ( !level.multibomb )
	{
		level.sdbomb maps\mp\gametypes\_gameobjects::allowcarry( "none" );
		level.sdbomb maps\mp\gametypes\_gameobjects::setvisibleteam( "none" );
		level.sdbomb maps\mp\gametypes\_gameobjects::setdropped();
		level.sdbombmodel = level.sdbomb.visuals[ 0 ];
	}
	else
	{
		for ( var_2 = 0; var_2 < level.players.size; var_2++ )
		{
			if ( isdefined( level.players[ var_2 ].carryicon ) )
			{
				level.players[ var_2 ].carryicon maps\mp\gametypes\_hud_util::destroyelem();
			}
		}
		
		var_3 = bullettrace( var_1.origin + ( 0, 0, 20 ), var_1.origin - ( 0, 0, 2000 ), 0, var_1 );
		var_4 = randomfloat( 360 );
		var_5 = ( cos( var_4 ), sin( var_4 ), 0 );
		var_5 = vectornormalize( var_5 - var_3[ "normal" ] * vectordot( var_5, var_3[ "normal" ] ) );
		var_6 = vectortoangles( var_5 );
		level.sdbombmodel = spawn( "script_model", var_3[ "position" ] );
		level.sdbombmodel.angles = var_6;
		level.sdbombmodel setmodel( "prop_suitcase_bomb" );
	}
	
	var_0 maps\mp\gametypes\_gameobjects::allowuse( "none" );
	var_0 maps\mp\gametypes\_gameobjects::setvisibleteam( "none" );
	var_7 = var_0 maps\mp\gametypes\_gameobjects::getlabel();
	var_8 = var_0.bombdefusetrig;
	var_8.origin = level.sdbombmodel.origin;
	var_9 = [];
	defuseObject = maps\mp\gametypes\_gameobjects::createuseobject( game[ "defenders" ], var_8, var_9, ( 0, 0, 32 ) );
	defuseObject maps\mp\gametypes\_gameobjects::allowuse( "friendly" );
	defuseObject maps\mp\gametypes\_gameobjects::setusetime( level.defusetime );
	defuseObject maps\mp\gametypes\_gameobjects::setusetext( &"MP_DEFUSING_EXPLOSIVE" );
	defuseObject maps\mp\gametypes\_gameobjects::setusehinttext( &"PLATFORM_HOLD_TO_DEFUSE_EXPLOSIVES" );
	defuseObject maps\mp\gametypes\_gameobjects::setvisibleteam( "any" );
	defuseObject maps\mp\gametypes\_gameobjects::set2dicon( "friendly", "waypoint_defuse" + var_7 );
	defuseObject maps\mp\gametypes\_gameobjects::set2dicon( "enemy", "waypoint_defend" + var_7 );
	defuseObject maps\mp\gametypes\_gameobjects::set3dicon( "friendly", "waypoint_defuse" + var_7 );
	defuseObject maps\mp\gametypes\_gameobjects::set3dicon( "enemy", "waypoint_defend" + var_7 );
	defuseObject.label = var_7;
	defuseObject.onbeginuse = maps\mp\gametypes\sd::onbeginuse;
	defuseObject.onenduse = maps\mp\gametypes\sd::onenduse;
	defuseObject.onuse = maps\mp\gametypes\sd::onusedefuseobject;
	defuseObject.useweapon = "briefcase_bomb_defuse_mp";
	
	level.defuseobject = defuseObject;
	
	maps\mp\gametypes\sd::bombtimerwait();
	setdvar( "ui_bomb_timer", 0 );
	var_0.visuals[ 0 ] maps\mp\gametypes\_gamelogic::stoptickingsound();
	
	if ( level.gameended || level.bombdefused )
	{
		return;
	}
	
	level.bombexploded = 1;
	var_11 = level.sdbombmodel.origin;
	level.sdbombmodel hide();
	
	if ( isdefined( var_1 ) )
	{
		var_0.visuals[ 0 ] radiusdamage( var_11, 512, 200, 20, var_1, "MOD_EXPLOSIVE", "bomb_site_mp" );
		var_1 maps\mp\_utility::incpersstat( "destructions", 1 );
		var_1 maps\mp\gametypes\_persistence::statsetchild( "round", "destructions", var_1.pers[ "destructions" ] );
	}
	else
	{
		var_0.visuals[ 0 ] radiusdamage( var_11, 512, 200, 20, undefined, "MOD_EXPLOSIVE", "bomb_site_mp" );
	}
	
	var_12 = randomfloat( 360 );
	var_13 = spawnfx( level._effect[ "bombexplosion" ], var_11 + ( 0, 0, 50 ), ( 0, 0, 1 ), ( cos( var_12 ), sin( var_12 ), 0 ) );
	triggerfx( var_13 );
	playrumbleonposition( "grenade_rumble", var_11 );
	earthquake( 0.75, 2.0, var_11, 2000 );
	thread maps\mp\_utility::playsoundinspace( "exp_suitcase_bomb_main", var_11 );
	
	if ( isdefined( var_0.exploderindex ) )
	{
		common_scripts\utility::exploder( var_0.exploderindex );
	}
	
	for ( var_2 = 0; var_2 < level.bombzones.size; var_2++ )
	{
		level.bombzones[ var_2 ] maps\mp\gametypes\_gameobjects::disableobject();
	}
	
	defuseObject maps\mp\gametypes\_gameobjects::disableobject();
	setgameendtime( 0 );
	wait 3;
	maps\mp\gametypes\sd::sd_endgame( game[ "attackers" ], game[ "strings" ][ "target_destroyed" ] );
}

/*
	Patches giveLoadout so that it doesn't use IsItemUnlocked
*/
botGiveLoadout( team, class, allowCopycat, setPrimarySpawnWeapon ) // setPrimarySpawnWeapon only when called during spawn
{
	self endon( "death" );
	
	self takeallweapons();
	self.changingweapon = undefined;
	teamName = "none";
	
	if ( !isdefined( setPrimarySpawnWeapon ) )
	{
		setPrimarySpawnWeapon = true;
	}
	
	primaryIndex = 0;
	
	// initialize specialty array
	self.specialty = [];
	
	if ( !isdefined( allowCopycat ) )
	{
		allowCopycat = true;
	}
	
	primaryWeapon = undefined;
	var_7 = 0;
	
	//	set in game mode custom class
	loadoutKillstreak1 = undefined;
	loadoutKillstreak2 = undefined;
	loadoutKillstreak3 = undefined;
	
	if ( issubstr( class, "axis" ) )
	{
		teamName = "axis";
	}
	else if ( issubstr( class, "allies" ) )
	{
		teamName = "allies";
	}
	
	clonedLoadout = [];
	
	if ( isdefined( self.pers[ "copyCatLoadout" ] ) && self.pers[ "copyCatLoadout" ][ "inUse" ] && allowCopycat )
	{
		self maps\mp\gametypes\_class::setclass( "copycat" );
		self.class_num = maps\mp\gametypes\_class::getclassindex( "copycat" );
		clonedLoadout = self.pers[ "copyCatLoadout" ];
		loadoutPrimary = clonedLoadout[ "loadoutPrimary" ];
		loadoutPrimaryAttachment = clonedLoadout[ "loadoutPrimaryAttachment" ];
		loadoutPrimaryAttachment2 = clonedLoadout[ "loadoutPrimaryAttachment2" ];
		loadoutPrimaryBuff = clonedLoadout[ "loadoutPrimaryBuff" ];
		loadoutPrimaryCamo = clonedLoadout[ "loadoutPrimaryCamo" ];
		loadoutPrimaryReticle = clonedLoadout[ "loadoutPrimaryReticle" ];
		loadoutSecondary = clonedLoadout[ "loadoutSecondary" ];
		loadoutSecondaryAttachment = clonedLoadout[ "loadoutSecondaryAttachment" ];
		loadoutSecondaryAttachment2 = clonedLoadout[ "loadoutSecondaryAttachment2" ];
		loadoutSecondaryBuff = clonedLoadout[ "loadoutSecondaryBuff" ];
		loadoutSecondaryCamo = clonedLoadout[ "loadoutSecondaryCamo" ];
		loadoutSecondaryReticle = clonedLoadout[ "loadoutSecondaryReticle" ];
		loadoutEquipment = clonedLoadout[ "loadoutEquipment" ];
		loadoutPerk1 = clonedLoadout[ "loadoutPerk1" ];
		loadoutPerk2 = clonedLoadout[ "loadoutPerk2" ];
		loadoutPerk3 = clonedLoadout[ "loadoutPerk3" ];
		loadoutStreakType = clonedLoadout[ "loadoutStreakType" ];
		loadoutOffhand = clonedLoadout[ "loadoutOffhand" ];
		loadoutDeathStreak = clonedLoadout[ "loadoutDeathstreak" ];
		loadoutAmmoType = clonedLoadout[ "loadoutAmmoType" ];
	}
	else if ( teamName != "none" )
	{
		classIndex = maps\mp\gametypes\_class::getclassindex( class );
		loadoutPrimaryAttachment2 = "none";
		loadoutSecondaryAttachment2 = "none";
		loadoutPrimary = getmatchrulesdata( "defaultClasses", teamName, classIndex, "class", "weaponSetups", 0, "weapon" );
		loadoutPrimaryAttachment = getmatchrulesdata( "defaultClasses", teamName, classIndex, "class", "weaponSetups", 0, "attachment", 0 );
		loadoutPrimaryAttachment2 = getmatchrulesdata( "defaultClasses", teamName, classIndex, "class", "weaponSetups", 0, "attachment", 1 );
		loadoutPrimaryBuff = getmatchrulesdata( "defaultClasses", teamName, classIndex, "class", "weaponSetups", 0, "buff" );
		loadoutPrimaryCamo = getmatchrulesdata( "defaultClasses", teamName, classIndex, "class", "weaponSetups", 0, "camo" );
		loadoutPrimaryReticle = getmatchrulesdata( "defaultClasses", teamName, classIndex, "class", "weaponSetups", 0, "reticle" );
		loadoutSecondary = getmatchrulesdata( "defaultClasses", teamName, classIndex, "class", "weaponSetups", 1, "weapon" );
		loadoutSecondaryAttachment = getmatchrulesdata( "defaultClasses", teamName, classIndex, "class", "weaponSetups", 1, "attachment", 0 );
		loadoutSecondaryAttachment2 = getmatchrulesdata( "defaultClasses", teamName, classIndex, "class", "weaponSetups", 1, "attachment", 1 );
		loadoutSecondaryBuff = getmatchrulesdata( "defaultClasses", teamName, classIndex, "class", "weaponSetups", 1, "buff" );
		loadoutSecondaryCamo = getmatchrulesdata( "defaultClasses", teamName, classIndex, "class", "weaponSetups", 1, "camo" );
		loadoutSecondaryReticle = getmatchrulesdata( "defaultClasses", teamName, classIndex, "class", "weaponSetups", 1, "reticle" );
		
		if ( ( loadoutPrimary == "throwingknife" || loadoutPrimary == "none" ) && loadoutSecondary != "none" )
		{
			loadoutPrimary = loadoutSecondary;
			loadoutPrimaryAttachment = loadoutSecondaryAttachment;
			loadoutPrimaryAttachment2 = loadoutSecondaryAttachment2;
			loadoutPrimaryBuff = loadoutSecondaryBuff;
			loadoutPrimaryCamo = loadoutSecondaryCamo;
			loadoutPrimaryReticle = loadoutSecondaryReticle;
			loadoutSecondary = "none";
			loadoutSecondaryAttachment = "none";
			loadoutSecondaryAttachment2 = "none";
			loadoutSecondaryBuff = "specialty_null";
			loadoutSecondaryCamo = "none";
			loadoutSecondaryReticle = "none";
		}
		else if ( ( loadoutPrimary == "throwingknife" || loadoutPrimary == "none" ) && loadoutSecondary == "none" )
		{
			var_7 = 1;
			loadoutPrimary = "iw5_usp45";
			loadoutPrimaryAttachment = "tactical";
		}
		
		loadoutEquipment = getmatchrulesdata( "defaultClasses", teamName, classIndex, "class", "perks", 0 );
		loadoutPerk1 = getmatchrulesdata( "defaultClasses", teamName, classIndex, "class", "perks", 1 );
		loadoutPerk2 = getmatchrulesdata( "defaultClasses", teamName, classIndex, "class", "perks", 2 );
		loadoutPerk3 = getmatchrulesdata( "defaultClasses", teamName, classIndex, "class", "perks", 3 );
		
		if ( loadoutSecondary != "none" && !maps\mp\gametypes\_class::isvalidsecondary( loadoutSecondary, loadoutPerk2, 0 ) )
		{
			loadoutSecondary = maps\mp\gametypes\_class::table_getweapon( level.classtablename, 10, 1 );
			loadoutSecondaryAttachment = "none";
			loadoutSecondaryAttachment2 = "none";
			loadoutSecondaryBuff = "specialty_null";
			loadoutSecondaryCamo = "none";
			loadoutSecondaryReticle = "none";
		}
		
		loadoutStreakType = getmatchrulesdata( "defaultClasses", teamName, classIndex, "class", "perks", 5 );
		
		if ( loadoutStreakType == "specialty_null" )
		{
			loadoutKillstreak1 = "none";
			loadoutKillstreak2 = "none";
			loadoutKillstreak3 = "none";
		}
		else
		{
			loadoutKillstreak1 = maps\mp\gametypes\_class::recipe_getkillstreak( teamName, classIndex, loadoutStreakType, 0 );
			loadoutKillstreak2 = maps\mp\gametypes\_class::recipe_getkillstreak( teamName, classIndex, loadoutStreakType, 1 );
			loadoutKillstreak3 = maps\mp\gametypes\_class::recipe_getkillstreak( teamName, classIndex, loadoutStreakType, 2 );
		}
		
		loadoutOffhand = getmatchrulesdata( "defaultClasses", teamName, classIndex, "class", "perks", 6 );
		
		if ( loadoutOffhand == "specialty_null" )
		{
			loadoutOffhand = "none";
		}
		
		loadoutDeathStreak = getmatchrulesdata( "defaultClasses", teamName, classIndex, "class", "deathstreak" );
		
		if ( getmatchrulesdata( "defaultClasses", teamName, classIndex, "juggernaut" ) )
		{
			self thread recipeclassapplyjuggernaut( isjuggernaut() );
			self.isjuggernaut = true;
			self.juggmovespeedscaler = 0.7;
		}
		else if ( isjuggernaut() )
		{
			self notify( "lost_juggernaut" );
			self.isjuggernaut = false;
			self.movespeedscaler = 1;
		}
	}
	else if ( issubstr( class, "custom" ) )
	{
		class_num = maps\mp\gametypes\_class::getclassindex( class );
		self.class_num = class_num;
		loadoutPrimary = maps\mp\gametypes\_class::cac_getweapon( class_num, 0 );
		loadoutPrimaryAttachment = maps\mp\gametypes\_class::cac_getweaponattachment( class_num, 0 );
		loadoutPrimaryAttachment2 = maps\mp\gametypes\_class::cac_getweaponattachmenttwo( class_num, 0 );
		loadoutPrimaryBuff = maps\mp\gametypes\_class::cac_getweaponbuff( class_num, 0 );
		loadoutPrimaryCamo = maps\mp\gametypes\_class::cac_getweaponcamo( class_num, 0 );
		loadoutPrimaryReticle = maps\mp\gametypes\_class::cac_getweaponreticle( class_num, 0 );
		loadoutSecondary = maps\mp\gametypes\_class::cac_getweapon( class_num, 1 );
		loadoutSecondaryAttachment = maps\mp\gametypes\_class::cac_getweaponattachment( class_num, 1 );
		loadoutSecondaryAttachment2 = maps\mp\gametypes\_class::cac_getweaponattachmenttwo( class_num, 1 );
		loadoutSecondaryBuff = maps\mp\gametypes\_class::cac_getweaponbuff( class_num, 1 );
		loadoutSecondaryCamo = maps\mp\gametypes\_class::cac_getweaponcamo( class_num, 1 );
		loadoutSecondaryReticle = maps\mp\gametypes\_class::cac_getweaponreticle( class_num, 1 );
		loadoutEquipment = maps\mp\gametypes\_class::cac_getperk( class_num, 0 );
		loadoutPerk1 = maps\mp\gametypes\_class::cac_getperk( class_num, 1 );
		loadoutPerk2 = maps\mp\gametypes\_class::cac_getperk( class_num, 2 );
		loadoutPerk3 = maps\mp\gametypes\_class::cac_getperk( class_num, 3 );
		loadoutStreakType = maps\mp\gametypes\_class::cac_getperk( class_num, 5 );
		loadoutOffhand = maps\mp\gametypes\_class::cac_getoffhand( class_num );
		loadoutDeathStreak = maps\mp\gametypes\_class::cac_getdeathstreak( class_num );
	}
	else if ( class == "gamemode" )
	{
		gamemodeLoadout = self.pers[ "gamemodeLoadout" ];
		loadoutPrimary = gamemodeLoadout[ "loadoutPrimary" ];
		loadoutPrimaryAttachment = gamemodeLoadout[ "loadoutPrimaryAttachment" ];
		loadoutPrimaryAttachment2 = gamemodeLoadout[ "loadoutPrimaryAttachment2" ];
		loadoutPrimaryBuff = gamemodeLoadout[ "loadoutPrimaryBuff" ];
		loadoutPrimaryCamo = gamemodeLoadout[ "loadoutPrimaryCamo" ];
		loadoutPrimaryReticle = gamemodeLoadout[ "loadoutPrimaryReticle" ];
		loadoutSecondary = gamemodeLoadout[ "loadoutSecondary" ];
		loadoutSecondaryAttachment = gamemodeLoadout[ "loadoutSecondaryAttachment" ];
		loadoutSecondaryAttachment2 = gamemodeLoadout[ "loadoutSecondaryAttachment2" ];
		loadoutSecondaryBuff = gamemodeLoadout[ "loadoutSecondaryBuff" ];
		loadoutSecondaryCamo = gamemodeLoadout[ "loadoutSecondaryCamo" ];
		loadoutSecondaryReticle = gamemodeLoadout[ "loadoutSecondaryReticle" ];
		
		if ( ( loadoutPrimary == "throwingknife" || loadoutPrimary == "none" ) && loadoutSecondary != "none" )
		{
			loadoutPrimary = loadoutSecondary;
			loadoutPrimaryAttachment = loadoutSecondaryAttachment;
			loadoutPrimaryAttachment2 = loadoutSecondaryAttachment2;
			loadoutPrimaryBuff = loadoutSecondaryBuff;
			loadoutPrimaryCamo = loadoutSecondaryCamo;
			loadoutPrimaryReticle = loadoutSecondaryReticle;
			loadoutSecondary = "none";
			loadoutSecondaryAttachment = "none";
			loadoutSecondaryAttachment2 = "none";
			loadoutSecondaryBuff = "specialty_null";
			loadoutSecondaryCamo = "none";
			loadoutSecondaryReticle = "none";
		}
		else if ( ( loadoutPrimary == "throwingknife" || loadoutPrimary == "none" ) && loadoutSecondary == "none" )
		{
			var_7 = 1;
			loadoutPrimary = "iw5_usp45";
			loadoutPrimaryAttachment = "tactical";
		}
		
		loadoutEquipment = gamemodeLoadout[ "loadoutEquipment" ];
		loadoutOffhand = gamemodeLoadout[ "loadoutOffhand" ];
		
		if ( loadoutOffhand == "specialty_null" )
		{
			loadoutOffhand = "none";
		}
		
		loadoutPerk1 = gamemodeLoadout[ "loadoutPerk1" ];
		loadoutPerk2 = gamemodeLoadout[ "loadoutPerk2" ];
		loadoutPerk3 = gamemodeLoadout[ "loadoutPerk3" ];
		
		if ( loadoutSecondary != "none" && !maps\mp\gametypes\_class::isvalidsecondary( loadoutSecondary, loadoutPerk2, 0 ) )
		{
			loadoutSecondary = maps\mp\gametypes\_class::table_getweapon( level.classtablename, 10, 1 );
			loadoutSecondaryAttachment = "none";
			loadoutSecondaryAttachment2 = "none";
			loadoutSecondaryBuff = "specialty_null";
			loadoutSecondaryCamo = "none";
			loadoutSecondaryReticle = "none";
		}
		
		if ( level.killstreakrewards && isdefined( gamemodeLoadout[ "loadoutStreakType" ] ) && gamemodeLoadout[ "loadoutStreakType" ] != "specialty_null" )
		{
			loadoutStreakType = gamemodeLoadout[ "loadoutStreakType" ];
			loadoutKillstreak1 = gamemodeLoadout[ "loadoutKillstreak1" ];
			loadoutKillstreak2 = gamemodeLoadout[ "loadoutKillstreak2" ];
			loadoutKillstreak3 = gamemodeLoadout[ "loadoutKillstreak3" ];
		}
		else if ( level.killstreakrewards && isdefined( self.streaktype ) )
		{
			loadoutStreakType = maps\mp\gametypes\_class::getloadoutstreaktypefromstreaktype( self.streaktype );
		}
		else
		{
			loadoutStreakType = "streaktype_assault";
			loadoutKillstreak1 = "none";
			loadoutKillstreak2 = "none";
			loadoutKillstreak3 = "none";
		}
		
		loadoutDeathStreak = gamemodeLoadout[ "loadoutDeathstreak" ];
		
		if ( gamemodeLoadout[ "loadoutJuggernaut" ] )
		{
			self.health = self.maxhealth;
			self thread recipeclassapplyjuggernaut( isjuggernaut() );
			self.isjuggernaut = true;
			self.juggmovespeedscaler = 0.7;
		}
		else if ( isjuggernaut() )
		{
			self notify( "lost_juggernaut" );
			self.isjuggernaut = false;
			self.movespeedscaler = 1;
		}
	}
	else if ( class == "juggernaut" )
	{
		loadoutPrimary = "iw5_m60jugg";
		loadoutPrimaryAttachment = "none";
		loadoutPrimaryAttachment2 = "none";
		loadoutPrimaryBuff = "specialty_null";
		loadoutPrimaryCamo = "none";
		loadoutPrimaryReticle = "none";
		loadoutSecondary = "iw5_mp412jugg";
		loadoutSecondaryAttachment = "none";
		loadoutSecondaryAttachment2 = "none";
		loadoutSecondaryBuff = "specialty_null";
		loadoutSecondaryCamo = "none";
		loadoutSecondaryReticle = "none";
		loadoutEquipment = "frag_grenade_mp";
		loadoutPerk1 = "specialty_scavenger";
		loadoutPerk2 = "specialty_quickdraw";
		loadoutPerk3 = "specialty_detectexplosive";
		loadoutStreakType = maps\mp\gametypes\_class::getloadoutstreaktypefromstreaktype( self.streaktype );
		loadoutOffhand = "smoke_grenade_mp";
		loadoutDeathStreak = "specialty_null";
	}
	else if ( class == "juggernaut_recon" )
	{
		loadoutPrimary = "iw5_riotshieldjugg";
		loadoutPrimaryAttachment = "none";
		loadoutPrimaryAttachment2 = "none";
		loadoutPrimaryBuff = "specialty_null";
		loadoutPrimaryCamo = "none";
		loadoutPrimaryReticle = "none";
		loadoutSecondary = "iw5_usp45jugg";
		loadoutSecondaryAttachment = "none";
		loadoutSecondaryAttachment2 = "none";
		loadoutSecondaryBuff = "specialty_null";
		loadoutSecondaryCamo = "none";
		loadoutSecondaryReticle = "none";
		loadoutEquipment = "specialty_portable_radar";
		loadoutPerk1 = "specialty_scavenger";
		loadoutPerk2 = "specialty_coldblooded";
		loadoutPerk3 = "specialty_detectexplosive";
		loadoutStreakType = maps\mp\gametypes\_class::getloadoutstreaktypefromstreaktype( self.streaktype );
		loadoutOffhand = "smoke_grenade_mp";
		loadoutDeathStreak = "specialty_null";
	}
	else
	{
		class_num = maps\mp\gametypes\_class::getclassindex( class );
		self.class_num = class_num;
		loadoutPrimary = maps\mp\gametypes\_class::table_getweapon( level.classtablename, class_num, 0 );
		loadoutPrimaryAttachment = maps\mp\gametypes\_class::table_getweaponattachment( level.classtablename, class_num, 0, 0 );
		loadoutPrimaryAttachment2 = maps\mp\gametypes\_class::table_getweaponattachment( level.classtablename, class_num, 0, 1 );
		loadoutPrimaryBuff = maps\mp\gametypes\_class::table_getweaponbuff( level.classtablename, class_num, 0 );
		loadoutPrimaryCamo = maps\mp\gametypes\_class::table_getweaponcamo( level.classtablename, class_num, 0 );
		loadoutPrimaryReticle = maps\mp\gametypes\_class::table_getweaponreticle( level.classtablename, class_num, 0 );
		loadoutSecondary = maps\mp\gametypes\_class::table_getweapon( level.classtablename, class_num, 1 );
		loadoutSecondaryAttachment = maps\mp\gametypes\_class::table_getweaponattachment( level.classtablename, class_num, 1, 0 );
		loadoutSecondaryAttachment2 = maps\mp\gametypes\_class::table_getweaponattachment( level.classtablename, class_num, 1, 1 );
		loadoutSecondaryBuff = maps\mp\gametypes\_class::table_getweaponbuff( level.classtablename, class_num, 1 );
		loadoutSecondaryCamo = maps\mp\gametypes\_class::table_getweaponcamo( level.classtablename, class_num, 1 );
		loadoutSecondaryReticle = maps\mp\gametypes\_class::table_getweaponreticle( level.classtablename, class_num, 1 );
		loadoutEquipment = maps\mp\gametypes\_class::table_getequipment( level.classtablename, class_num, 0 );
		loadoutPerk1 = maps\mp\gametypes\_class::table_getperk( level.classtablename, class_num, 1 );
		loadoutPerk2 = maps\mp\gametypes\_class::table_getperk( level.classtablename, class_num, 2 );
		loadoutPerk3 = maps\mp\gametypes\_class::table_getperk( level.classtablename, class_num, 3 );
		loadoutStreakType = maps\mp\gametypes\_class::table_getperk( level.classtablename, class_num, 5 );
		loadoutOffhand = maps\mp\gametypes\_class::table_getoffhand( level.classtablename, class_num );
		loadoutDeathStreak = maps\mp\gametypes\_class::table_getdeathstreak( level.classtablename, class_num );
	}
	
	// stop default class op'ness
	allowOp = ( getdvarint( "bots_loadout_allow_op" ) >= 1 );
	
	if ( !allowOp )
	{
		loadoutDeathstreak = "specialty_null";
		
		if ( loadoutSecondary == "iw5_smaw" )
		{
			loadoutSecondary = "iw5_usp";
		}
		
		if ( loadoutPrimaryAttachment == "m320" )
		{
			loadoutPrimaryAttachment = "none";
		}
		
		if ( loadoutPerk2 == "specialty_coldblooded" )
		{
			loadoutPerk2 = "specialty_null";
		}
		
		if ( loadoutPerk1 == "specialty_blindeye" )
		{
			loadoutPerk1 = "specialty_null";
		}
		
		if ( loadoutStreakType == "streaktype_support" )
		{
			loadoutStreakType = "streaktype_assault";
		}
		
		if ( loadoutPrimary == "riotshield" )
		{
			loadoutPrimary = "iw5_m4";
		}
		
		if ( loadoutSecondary == "riotshield" )
		{
			loadoutSecondary = "iw5_m4";
		}
	}
	
	self maps\mp\gametypes\_class::loadoutfakeperks( loadoutStreakType );
	isCustomClass = issubstr( class, "custom" );
	isRecipeClass = issubstr( class, "recipe" );
	isGameModeClass = ( class == "gamemode" );
	
	if ( !isGameModeClass && !isRecipeClass && !( isdefined( self.pers[ "copyCatLoadout" ] ) && self.pers[ "copyCatLoadout" ][ "inUse" ] && allowCopycat ) )
	{
		if ( !maps\mp\gametypes\_class::isvalidprimary( loadoutPrimary ) )
		{
			loadoutPrimary = maps\mp\gametypes\_class::table_getweapon( level.classtablename, 10, 0 );
		}
		
		if ( !maps\mp\gametypes\_class::isvalidattachment( loadoutPrimaryAttachment ) )
		{
			loadoutPrimaryAttachment = maps\mp\gametypes\_class::table_getweaponattachment( level.classtablename, 10, 0, 0 );
		}
		
		if ( !maps\mp\gametypes\_class::isvalidattachment( loadoutPrimaryAttachment2 ) )
		{
			loadoutPrimaryAttachment2 = maps\mp\gametypes\_class::table_getweaponattachment( level.classtablename, 10, 0, 1 );
		}
		
		if ( !maps\mp\gametypes\_class::isvalidweaponbuff( loadoutPrimaryBuff, loadoutPrimary ) )
		{
			loadoutPrimaryBuff = maps\mp\gametypes\_class::table_getweaponbuff( level.classtablename, 10, 0 );
		}
		
		if ( !maps\mp\gametypes\_class::isvalidcamo( loadoutPrimaryCamo ) )
		{
			loadoutPrimaryCamo = maps\mp\gametypes\_class::table_getweaponcamo( level.classtablename, 10, 0 );
		}
		
		if ( !maps\mp\gametypes\_class::isvalidreticle( loadoutPrimaryReticle ) )
		{
			loadoutPrimaryReticle = maps\mp\gametypes\_class::table_getweaponreticle( level.classtablenum, 10, 0 );
		}
		
		if ( !maps\mp\gametypes\_class::isvalidsecondary( loadoutSecondary, loadoutPerk2 ) )
		{
			loadoutSecondary = maps\mp\gametypes\_class::table_getweapon( level.classtablename, 10, 1 );
			loadoutSecondaryAttachment = "none";
			loadoutSecondaryAttachment2 = "none";
			loadoutSecondaryBuff = "specialty_null";
			loadoutSecondaryCamo = "none";
			loadoutSecondaryReticle = "none";
		}
		
		if ( !maps\mp\gametypes\_class::isvalidattachment( loadoutSecondaryAttachment ) )
		{
			loadoutSecondaryAttachment = maps\mp\gametypes\_class::table_getweaponattachment( level.classtablename, 10, 1, 0 );
		}
		
		if ( !maps\mp\gametypes\_class::isvalidattachment( loadoutSecondaryAttachment2 ) )
		{
			loadoutSecondaryAttachment2 = maps\mp\gametypes\_class::table_getweaponattachment( level.classtablename, 10, 1, 1 );
		}
		
		if ( loadoutPerk2 == "specialty_twoprimaries" && !maps\mp\gametypes\_class::isvalidweaponbuff( loadoutSecondaryBuff, loadoutSecondary ) )
		{
			loadoutSecondaryBuff = maps\mp\gametypes\_class::table_getweaponbuff( level.classtablename, 10, 1 );
		}
		
		if ( !maps\mp\gametypes\_class::isvalidcamo( loadoutSecondaryCamo ) )
		{
			loadoutSecondaryCamo = maps\mp\gametypes\_class::table_getweaponcamo( level.classtablename, 10, 1 );
		}
		
		if ( !maps\mp\gametypes\_class::isvalidreticle( loadoutSecondaryReticle ) )
		{
			loadoutSecondaryReticle = maps\mp\gametypes\_class::table_getweaponreticle( level.classtablename, 10, 1 );
		}
		
		if ( !maps\mp\gametypes\_class::isvalidequipment( loadoutEquipment ) )
		{
			loadoutEquipment = maps\mp\gametypes\_class::table_getequipment( level.classtablename, 10, 0 );
		}
		
		if ( !maps\mp\gametypes\_class::isvalidperk1( loadoutPerk1 ) )
		{
			loadoutPerk1 = maps\mp\gametypes\_class::table_getperk( level.classtablename, 10, 1 );
		}
		
		if ( !maps\mp\gametypes\_class::isvalidperk2( loadoutPerk2 ) )
		{
			loadoutPerk2 = maps\mp\gametypes\_class::table_getperk( level.classtablename, 10, 2 );
		}
		
		if ( !maps\mp\gametypes\_class::isvalidperk3( loadoutPerk3 ) )
		{
			loadoutPerk3 = maps\mp\gametypes\_class::table_getperk( level.classtablename, 10, 3 );
		}
		
		if ( !maps\mp\gametypes\_class::isvaliddeathstreak( loadoutDeathStreak ) )
		{
			loadoutDeathStreak = maps\mp\gametypes\_class::table_getdeathstreak( level.classtablename, 10 );
		}
		
		if ( !maps\mp\gametypes\_class::isvalidoffhand( loadoutOffhand ) )
		{
			loadoutOffhand = maps\mp\gametypes\_class::table_getoffhand( level.classtablename, 10 );
		}
		
		if ( loadoutPrimaryAttachment2 != "none" && loadoutPrimaryBuff != "specialty_bling" )
		{
			loadoutPrimaryAttachment2 = "none";
		}
		
		if ( loadoutSecondaryBuff != "specialty_null" && loadoutPerk2 != "specialty_twoprimaries" )
		{
			loadoutSecondaryBuff = "specialty_null";
		}
		
		if ( loadoutSecondaryAttachment2 != "none" && ( loadoutSecondaryBuff != "specialty_bling" || loadoutPerk2 != "specialty_twoprimaries" ) )
		{
			loadoutSecondaryAttachment2 = "none";
		}
	}
	
	self.loadoutprimary = loadoutPrimary;
	self.loadoutprimarycamo = int( tablelookup( "mp/camoTable.csv", 1, loadoutPrimaryCamo, 0 ) );
	self.loadoutsecondary = loadoutSecondary;
	self.loadoutsecondarycamo = int( tablelookup( "mp/camoTable.csv", 1, loadoutSecondaryCamo, 0 ) );
	
	if ( !issubstr( loadoutPrimary, "iw5" ) )
	{
		self.loadoutprimarycamo = 0;
	}
	
	if ( !issubstr( loadoutSecondary, "iw5" ) )
	{
		self.loadoutsecondarycamo = 0;
	}
	
	self.loadoutprimaryreticle = int( tablelookup( "mp/reticleTable.csv", 1, loadoutPrimaryReticle, 0 ) );
	self.loadoutsecondaryreticle = int( tablelookup( "mp/reticleTable.csv", 1, loadoutSecondaryReticle, 0 ) );
	
	if ( !issubstr( loadoutPrimary, "iw5" ) )
	{
		self.loadoutprimaryreticle = 0;
	}
	
	if ( !issubstr( loadoutSecondary, "iw5" ) )
	{
		self.loadoutsecondaryreticle = 0;
	}
	
	if ( loadoutSecondary == "none" )
	{
		secondaryName = "none";
	}
	else
	{
		secondaryName = maps\mp\gametypes\_class::buildweaponname( loadoutSecondary, loadoutSecondaryAttachment, loadoutSecondaryAttachment2, self.loadoutsecondarycamo, self.loadoutsecondaryreticle );
		self _giveweapon( secondaryName );
		weaponTokens = strtok( secondaryName, "_" );
		
		if ( weaponTokens[ 0 ] == "iw5" )
		{
			weaponTokens[ 0 ] = weaponTokens[ 0 ] + "_" + weaponTokens[ 1 ];
		}
		else if ( weaponTokens[ 0 ] == "alt" )
		{
			weaponTokens[ 0 ] = weaponTokens[ 1 ] + "_" + weaponTokens[ 2 ];
		}
		
		weaponName = weaponTokens[ 0 ];
		curWeaponRank = self maps\mp\gametypes\_rank::getweaponrank( weaponName );
		curWeaponStatRank = self getplayerdata( "weaponRank", weaponName );
		
		if ( curWeaponRank != curWeaponStatRank )
		{
			self setplayerdata( "weaponRank", weaponName, curWeaponRank );
		}
	}
	
	self setoffhandprimaryclass( "other" );
	self _setactionslot( 1, "" );
	self _setactionslot( 3, "altMode" );
	self _setactionslot( 4, "" );
	
	if ( !level.console )
	{
		self _setactionslot( 5, "" );
		self _setactionslot( 6, "" );
		self _setactionslot( 7, "" );
	}
	
	self _clearperks();
	self maps\mp\gametypes\_class::_detachall();
	
	if ( level.diehardmode )
	{
		self giveperk( "specialty_pistoldeath", false );
	}
	
	self loadoutallperks( loadoutEquipment, loadoutPerk1, loadoutPerk2, loadoutPerk3, loadoutPrimaryBuff, loadoutSecondaryBuff );
	
	if ( self _hasperk( "specialty_extraammo" ) && secondaryName != "none" && getweaponclass( secondaryName ) != "weapon_projectile" )
	{
		self givemaxammo( secondaryName );
	}
	
	self.spawnperk = false;
	
	if ( !self _hasperk( "specialty_blindeye" ) && self.avoidkillstreakonspawntimer > 0 )
	{
		self thread maps\mp\perks\_perks::giveblindeyeafterspawn();
	}
	
	if ( self.pers[ "cur_death_streak" ] > 0 )
	{
		deathStreaks = [];
		
		if ( loadoutDeathStreak != "specialty_null" )
		{
			deathStreaks[ loadoutDeathStreak ] = int( tablelookup( "mp/perkTable.csv", 1, loadoutDeathStreak, 6 ) );
		}
		
		if ( self getperkupgrade( loadoutPerk1 ) == "specialty_rollover" || self getperkupgrade( loadoutPerk2 ) == "specialty_rollover" || getperkupgrade( loadoutPerk3 ) == "specialty_rollover" )
		{
			foreach ( key, value in deathStreaks )
			{
				deathStreaks[ key ] -= 1;
			}
		}
		
		foreach ( key, value in deathStreaks )
		{
			if ( self.pers[ "cur_death_streak" ] >= value )
			{
				if ( key == "specialty_carepackage" && self.pers[ "cur_death_streak" ] > value )
				{
					continue;
				}
				
				if ( key == "specialty_uav" && self.pers[ "cur_death_streak" ] > value )
				{
					continue;
				}
				
				self thread giveperk( key, true );
				self thread maps\mp\gametypes\_hud_message::splashnotify( key );
			}
		}
	}
	
	if ( level.killstreakrewards && !isdefined( loadoutKillstreak1 ) && !isdefined( loadoutKillstreak2 ) && !isdefined( loadoutKillstreak3 ) )
	{
		if ( isdefined( self.pers[ "copyCatLoadout" ] ) && self.pers[ "copyCatLoadout" ][ "inUse" ] && allowCopycat )
		{
			loadoutKillstreak1 = clonedLoadout[ "loadoutKillstreak1" ];
			loadoutKillstreak2 = clonedLoadout[ "loadoutKillstreak2" ];
			loadoutKillstreak3 = clonedLoadout[ "loadoutKillstreak3" ];
		}
		else
		{
			defaultKillstreak1 = undefined;
			defaultKillstreak2 = undefined;
			defaultKillstreak3 = undefined;
			playerData = undefined;
			
			switch ( self.streaktype )
			{
				case "support":
					defaultKillstreak1 = maps\mp\gametypes\_class::table_getkillstreak( level.classtablename, 2, 1 );
					defaultKillstreak2 = maps\mp\gametypes\_class::table_getkillstreak( level.classtablename, 2, 2 );
					defaultKillstreak3 = maps\mp\gametypes\_class::table_getkillstreak( level.classtablename, 2, 3 );
					playerData = "defenseStreaks";
					break;
					
				case "specialist":
					defaultKillstreak1 = maps\mp\gametypes\_class::table_getkillstreak( level.classtablename, 1, 1 );
					defaultKillstreak2 = maps\mp\gametypes\_class::table_getkillstreak( level.classtablename, 1, 2 );
					defaultKillstreak3 = maps\mp\gametypes\_class::table_getkillstreak( level.classtablename, 1, 3 );
					playerData = "specialistStreaks";
					break;
					
				default:
					defaultKillstreak1 = maps\mp\gametypes\_class::table_getkillstreak( level.classtablename, 0, 1 );
					defaultKillstreak2 = maps\mp\gametypes\_class::table_getkillstreak( level.classtablename, 0, 2 );
					defaultKillstreak3 = maps\mp\gametypes\_class::table_getkillstreak( level.classtablename, 0, 3 );
					playerData = "assaultStreaks";
					break;
			}
			
			loadoutKillstreak1 = undefined;
			loadoutKillstreak2 = undefined;
			loadoutKillstreak3 = undefined;
			
			if ( issubstr( class, "custom" ) )
			{
				customClassLoc = maps\mp\gametypes\_class::cac_getcustomclassloc();
				loadoutKillstreak1 = self getplayerdata( customClassLoc, self.class_num, playerData, 0 );
				loadoutKillstreak2 = self getplayerdata( customClassLoc, self.class_num, playerData, 1 );
				loadoutKillstreak3 = self getplayerdata( customClassLoc, self.class_num, playerData, 2 );
			}
			
			if ( issubstr( class, "juggernaut" ) || isGameModeClass )
			{
				foreach ( killstreak in self.killstreaks )
				{
					if ( !isdefined( loadoutKillstreak1 ) )
					{
						loadoutKillstreak1 = killstreak;
						continue;
					}
					
					if ( !isdefined( loadoutKillstreak2 ) )
					{
						loadoutKillstreak2 = killstreak;
						continue;
					}
					
					if ( !isdefined( loadoutKillstreak3 ) )
					{
						loadoutKillstreak3 = killstreak;
					}
				}
				
				if ( isGameModeClass && self.streaktype == "specialist" )
				{
					self.pers[ "gamemodeLoadout" ][ "loadoutKillstreak1" ] = loadoutKillstreak1;
					self.pers[ "gamemodeLoadout" ][ "loadoutKillstreak2" ] = loadoutKillstreak2;
					self.pers[ "gamemodeLoadout" ][ "loadoutKillstreak3" ] = loadoutKillstreak3;
				}
			}
			
			if ( !issubstr( class, "custom" ) && !issubstr( class, "juggernaut" ) && !isGameModeClass )
			{
				loadoutKillstreak1 = defaultKillstreak1;
				loadoutKillstreak2 = defaultKillstreak2;
				loadoutKillstreak3 = defaultKillstreak3;
			}
			
			if ( !isdefined( loadoutKillstreak1 ) )
			{
				loadoutKillstreak1 = "none";
			}
			
			if ( !isdefined( loadoutKillstreak2 ) )
			{
				loadoutKillstreak2 = "none";
			}
			
			if ( !isdefined( loadoutKillstreak3 ) )
			{
				loadoutKillstreak3 = "none";
			}
			
			var_56 = 0;
			
			if ( !maps\mp\gametypes\_class::isvalidkillstreak( loadoutKillstreak1 ) )
			{
				var_56 = 1;
			}
			
			if ( !maps\mp\gametypes\_class::isvalidkillstreak( loadoutKillstreak2 ) )
			{
				var_56 = 1;
			}
			
			if ( !maps\mp\gametypes\_class::isvalidkillstreak( loadoutKillstreak3 ) )
			{
				var_56 = 1;
			}
			
			if ( var_56 )
			{
				self.streaktype = "assault";
				loadoutKillstreak1 = maps\mp\gametypes\_class::table_getkillstreak( level.classtablename, 0, 1 );
				loadoutKillstreak2 = maps\mp\gametypes\_class::table_getkillstreak( level.classtablename, 0, 2 );
				loadoutKillstreak3 = maps\mp\gametypes\_class::table_getkillstreak( level.classtablename, 0, 3 );
			}
		}
	}
	else if ( !level.killstreakrewards )
	{
		loadoutKillstreak1 = "none";
		loadoutKillstreak2 = "none";
		loadoutKillstreak3 = "none";
	}
	
	self maps\mp\gametypes\_class::setkillstreaks( loadoutKillstreak1, loadoutKillstreak2, loadoutKillstreak3 );
	
	if ( isdefined( self.lastclass ) && self.lastclass != self.class && !issubstr( self.class, "juggernaut" ) && !issubstr( self.lastclass, "juggernaut" ) && !issubstr( class, "juggernaut" ) )
	{
		if ( wasonlyround() || self.lastclass != "" )
		{
			streakNames = [];
			inc = 0;
			
			if ( self.pers[ "killstreaks" ].size > 5 )
			{
				for ( i = 5; i < self.pers[ "killstreaks" ].size; i++ )
				{
					streakNames[ inc ] = self.pers[ "killstreaks" ][ i ].streakname;
					inc++;
				}
			}
			
			if ( self.pers[ "killstreaks" ].size )
			{
				for ( i = 1; i < 4; i++ )
				{
					if ( isdefined( self.pers[ "killstreaks" ][ i ] ) && isdefined( self.pers[ "killstreaks" ][ i ].streakname ) && self.pers[ "killstreaks" ][ i ].available && !self.pers[ "killstreaks" ][ i ].isspecialist )
					{
						streakNames[ inc ] = self.pers[ "killstreaks" ][ i ].streakname;
						inc++;
					}
				}
			}
			
			self notify( "givingLoadout" );
			self maps\mp\killstreaks\_killstreaks::clearkillstreaks();
			
			for ( i = 0; i < streakNames.size; i++ )
			{
				self maps\mp\killstreaks\_killstreaks::givekillstreak( streakNames[ i ] );
			}
		}
	}
	
	if ( !issubstr( class, "juggernaut" ) )
	{
		if ( isdefined( self.lastclass ) && self.lastclass != "" && self.lastclass != self.class )
		{
			self incplayerstat( "mostclasseschanged", 1 );
		}
		
		self.pers[ "lastClass" ] = self.class;
		self.lastclass = self.class;
	}
	
	if ( isdefined( self.gamemode_chosenclass ) )
	{
		self.pers[ "class" ] = self.gamemode_chosenclass;
		self.pers[ "lastClass" ] = self.gamemode_chosenclass;
		self.class = self.gamemode_chosenclass;
		self.lastclass = self.gamemode_chosenclass;
		self.gamemode_chosenclass = undefined;
	}
	
	primaryName = maps\mp\gametypes\_class::buildweaponname( loadoutPrimary, loadoutPrimaryAttachment, loadoutPrimaryAttachment2, self.loadoutprimarycamo, self.loadoutprimaryreticle );
	self _giveweapon( primaryName );
	self switchtoweapon( primaryName );
	weaponTokens = strtok( primaryName, "_" );
	
	if ( weaponTokens[ 0 ] == "iw5" )
	{
		weaponName = weaponTokens[ 0 ] + "_" + weaponTokens[ 1 ];
	}
	else if ( weaponTokens[ 0 ] == "alt" )
	{
		weaponName = weaponTokens[ 1 ] + "_" + weaponTokens[ 2 ];
	}
	else
	{
		weaponName = weaponTokens[ 0 ];
	}
	
	curWeaponRank = self maps\mp\gametypes\_rank::getweaponrank( weaponName );
	curWeaponStatRank = self getplayerdata( "weaponRank", weaponName );
	
	if ( curWeaponRank != curWeaponStatRank )
	{
		self setplayerdata( "weaponRank", weaponName, curWeaponRank );
	}
	
	if ( primaryName == "riotshield_mp" && level.ingraceperiod )
	{
		self notify( "weapon_change", "riotshield_mp" );
	}
	
	if ( self _hasperk( "specialty_extraammo" ) )
	{
		self givemaxammo( primaryName );
	}
	
	if ( setPrimarySpawnWeapon )
	{
		self setspawnweapon( primaryName );
	}
	
	self.pers[ "primaryWeapon" ] = weaponName;
	primaryTokens = strtok( primaryName, "_" );
	offhandSecondaryWeapon = loadoutOffhand;
	
	if ( loadoutOffhand == "none" )
	{
		self setoffhandsecondaryclass( "none" );
	}
	else if ( loadoutOffhand == "flash_grenade_mp" )
	{
		self setoffhandsecondaryclass( "flash" );
	}
	else if ( loadoutOffhand == "smoke_grenade_mp" || loadoutOffhand == "concussion_grenade_mp" )
	{
		self setoffhandsecondaryclass( "smoke" );
	}
	else
	{
		self setoffhandsecondaryclass( "flash" );
	}
	
	switch ( offhandSecondaryWeapon )
	{
		case "none":
			break;
			
		case "trophy_mp":
		case "specialty_portable_radar":
		case "specialty_scrambler":
		case "specialty_tacticalinsertion":
			self giveperk( offhandSecondaryWeapon, 0 );
			break;
			
		default:
			self giveweapon( offhandSecondaryWeapon );
			
			if ( loadoutOffhand == "flash_grenade_mp" )
			{
				self setweaponammoclip( offhandSecondaryWeapon, 2 );
			}
			else if ( loadoutOffhand == "concussion_grenade_mp" )
			{
				self setweaponammoclip( offhandSecondaryWeapon, 2 );
			}
			else
			{
				self setweaponammoclip( offhandSecondaryWeapon, 1 );
			}
			
			break;
	}
	
	primaryWeapon = primaryName;
	self.primaryweapon = primaryWeapon;
	self.secondaryweapon = secondaryName;
	
	if ( var_7 )
	{
		self setweaponammoclip( self.primaryweapon, 0 );
		self setweaponammostock( self.primaryweapon, 0 );
	}
	
	self playerModelForWeapon( self.pers[ "primaryWeapon" ], getbaseweaponname( secondaryName ) );
	self.issniper = ( weaponclass( self.primaryweapon ) == "sniper" );
	self maps\mp\gametypes\_weapons::updatemovespeedscale();
	self maps\mp\perks\_perks::cac_selector();
	self notify( "changed_kit" );
	self notify( "bot_giveLoadout" );
}

/*
	Patches giveLoadout so that it doesn't use IsItemUnlocked
*/
getperkupgrade( perkName )
{
	perkUpgrade = tablelookup( "mp/perktable.csv", 1, perkName, 8 );
	
	if ( perkUpgrade == "" || perkUpgrade == "specialty_null" )
	{
		return "specialty_null";
	}
	
	if ( !isdefined( self.pers[ "bots" ][ "unlocks" ][ "upgraded_" + perkName ] ) || !self.pers[ "bots" ][ "unlocks" ][ "upgraded_" + perkName ] )
	{
		return "specialty_null";
	}
	
	return ( perkUpgrade );
}

/*
	Patches giveLoadout so that it doesn't use IsItemUnlocked
*/
loadoutallperks( loadoutEquipment, loadoutPerk1, loadoutPerk2, loadoutPerk3, loadoutPrimaryBuff, loadoutSecondaryBuff )
{
	loadoutEquipment = maps\mp\perks\_perks::validateperk( 1, loadoutEquipment );
	loadoutPerk1 = maps\mp\perks\_perks::validateperk( 1, loadoutPerk1 );
	loadoutPerk2 = maps\mp\perks\_perks::validateperk( 2, loadoutPerk2 );
	loadoutPerk3 = maps\mp\perks\_perks::validateperk( 3, loadoutPerk3 );
	
	loadoutPrimaryBuff = maps\mp\perks\_perks::validateperk( undefined, loadoutPrimaryBuff );
	
	if ( loadoutPerk2 == "specialty_twoprimaries" )
	{
		loadoutSecondaryBuff = maps\mp\perks\_perks::validateperk( undefined, loadoutSecondaryBuff );
	}
	
	self.loadoutperk1 = loadoutPerk1;
	self.loadoutperk2 = loadoutPerk2;
	self.loadoutperk3 = loadoutPerk3;
	self.loadoutperkequipment = loadoutEquipment;
	self.loadoutprimarybuff = loadoutPrimaryBuff;
	
	if ( loadoutPerk2 == "specialty_twoprimaries" )
	{
		self.loadoutsecondarybuff = loadoutSecondaryBuff;
	}
	
	if ( loadoutEquipment != "specialty_null" )
	{
		self giveperk( loadoutEquipment, true );
	}
	
	if ( loadoutPerk1 != "specialty_null" )
	{
		self giveperk( loadoutPerk1, true );
	}
	
	if ( loadoutPerk2 != "specialty_null" )
	{
		self giveperk( loadoutPerk2, true );
	}
	
	if ( loadoutPerk3 != "specialty_null" )
	{
		self giveperk( loadoutPerk3, true );
	}
	
	if ( loadoutPrimaryBuff != "specialty_null" )
	{
		self giveperk( loadoutPrimaryBuff, true );
	}
	
	perkUpgrd[ 0 ] = tablelookup( "mp/perktable.csv", 1, loadoutPerk1, 8 );
	perkUpgrd[ 1 ] = tablelookup( "mp/perktable.csv", 1, loadoutPerk2, 8 );
	perkUpgrd[ 2 ] = tablelookup( "mp/perktable.csv", 1, loadoutPerk3, 8 );
	
	perks[ 0 ] = loadoutPerk1;
	perks[ 1 ] = loadoutPerk2;
	perks[ 2 ] = loadoutPerk3;
	
	for ( i = 0; i < perkUpgrd.size; i++ )
	{
		upgrade = perkUpgrd[ i ];
		perk = perks[ i ];
		
		if ( upgrade == "" || upgrade == "specialty_null" )
		{
			continue;
		}
		
		if ( isdefined( self.pers[ "bots" ][ "unlocks" ][ "upgraded_" + perk ] ) && self.pers[ "bots" ][ "unlocks" ][ "upgraded_" + perk ] )
		{
			self giveperk( upgrade, true );
		}
	}
	
	if ( !self _hasperk( "specialty_assists" ) )
	{
		self.pers[ "assistsToKill" ] = 0;
	}
}

/*
	Patches giveLoadout so that it doesn't use IsItemUnlocked
*/
playerModelForWeapon( weapon, secondary )
{
	team = self.team;
	
	if ( isdefined( game[ team + "_model" ][ weapon ] ) )
	{
		[[ game[ team + "_model" ][ weapon ] ]]();
		return;
	}
	
	weaponclass = tablelookup( "mp/statstable.csv", 4, weapon, 2 );
	
	switch ( weaponclass )
	{
		case "weapon_smg":
			[[ game[ team + "_model" ][ "SMG" ] ]]();
			break;
			
		case "weapon_assault":
			[[ game[ team + "_model" ][ "ASSAULT" ] ]]();
			break;
			
		case "weapon_sniper":
			if ( level.environment != "" && game[ team ] != "opforce_africa" && isdefined( self.pers[ "bots" ][ "unlocks" ][ "ghillie" ] ) && self.pers[ "bots" ][ "unlocks" ][ "ghillie" ] )
			{
				[[ game[ team + "_model" ][ "GHILLIE" ] ]]();
			}
			else
			{
				[[ game[ team + "_model" ][ "SNIPER" ] ]]();
			}
			
			break;
			
		case "weapon_lmg":
			[[ game[ team + "_model" ][ "LMG" ] ]]();
			break;
			
		case "weapon_riot":
			[[ game[ team + "_model" ][ "RIOT" ] ]]();
			break;
			
		case "weapon_shotgun":
			[[ game[ team + "_model" ][ "SHOTGUN" ] ]]();
			break;
			
		default:
			[[ game[ team + "_model" ][ "ASSAULT" ] ]]();
			break;
	}
	
	if ( isjuggernaut() )
	{
		[[ game[ team + "_model" ][ "JUGGERNAUT" ] ]]();
	}
}
