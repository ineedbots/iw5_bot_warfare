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
	Returns if player is the host
*/
is_host()
{
	return (isDefined(self.pers["bot_host"]) && self.pers["bot_host"]);
}

/*
	Setups the host variable on the player
*/
doHostCheck()
{
	self.pers["bot_host"] = false;

	if (self is_bot())
		return;

	result = false;
	if (getDvar("bots_main_firstIsHost") != "0")
	{
		printLn("WARNING: bots_main_firstIsHost is enabled");

		if (getDvar("bots_main_firstIsHost") == "1")
		{
			setDvar("bots_main_firstIsHost", self getguid());
		}

		if (getDvar("bots_main_firstIsHost") == self getguid()+"")
			result = true;
	}

	DvarGUID = getDvar("bots_main_GUIDs");
	if (DvarGUID != "")
	{
		guids = strtok(DvarGUID, ",");

		for (i = 0; i < guids.size; i++)
		{
			if(self getguid()+"" == guids[i])
				result = true;
		}
	}
	
	if (!self isHost() && !result)
		return;

	self.pers["bot_host"] = true;
}

/*
	Returns if the player is a bot.
*/
is_bot()
{
	assert(isDefined(self));
	assert(isPlayer(self));

	return ((isDefined(self.pers["isBot"]) && self.pers["isBot"]) || (isDefined(self.pers["isBotWarfare"]) && self.pers["isBotWarfare"]) || isSubStr( self getguid()+"", "bot" ));
}

/*
	Bot changes to the weap
*/
BotChangeToWeapon(weap)
{
	self maps\mp\bots\_bot_internal::changeToWeap(weap);
}

/*
	Bot presses the frag button for time.
*/
BotPressFrag(time)
{
	self maps\mp\bots\_bot_internal::frag(time);
}

/*
	Bot presses the smoke button for time.
*/
BotPressSmoke(time)
{
	self maps\mp\bots\_bot_internal::smoke(time);
}

/*
	Bot presses the use button for time.
*/
BotPressUse(time)
{
	self maps\mp\bots\_bot_internal::use(time);
}

/*
	Bot will press the ads button for the time
*/
BotPressADS(time)
{
	self maps\mp\bots\_bot_internal::pressAds(time);
}

/*
	Bots will press the attack button for a time
*/
BotPressAttack(time)
{
	self maps\mp\bots\_bot_internal::pressFire(time);
}

/*
	Returns a random number thats different everytime it changes target
*/
BotGetTargetRandom()
{
	if (!isDefined(self.bot.target))
		return undefined;

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
BotFreezeControls(what)
{
	self.bot.isfrozen = what;
	if(what)
		self notify("kill_goal");
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
BotStopMoving(what)
{
	self.bot.stop_move = what;

	if(what)
		self notify("kill_goal");
}

/*
	Returns if the bot has a script goal.
	(like t5 gsc bot)
*/
HasScriptGoal()
{
	return (isDefined(self GetScriptGoal()));
}

/*
	Sets the bot's goal, will acheive it when dist away from it.
*/
SetScriptGoal(goal, dist)
{
	if (!isDefined(dist))
		dist = 16;
	self.bot.script_goal = goal;
	self.bot.script_goal_dist = dist;
	waittillframeend;
	self notify("new_goal_internal");
	self notify("new_goal");
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
	self SetScriptGoal(undefined, 0);
}

/*
	Returns the location of the bot's javelin target
*/
HasBotJavelinLocation()
{
	return isDefined(self.bot.jav_loc);
}

/*
	Sets the aim position of the bot
*/
SetScriptAimPos(pos)
{
	self.bot.script_aimpos = pos;
}

/*
	Clears the aim position of the bot
*/
ClearScriptAimPos()
{
	self SetScriptAimPos(undefined);
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
	return isDefined(self GetScriptAimPos());
}

/*
	Sets the bot's javelin target location
*/
SetBotJavelinLocation(loc)
{
	self.bot.jav_loc = loc;
	self notify("new_enemy");
}

/*
	Clears the bot's javelin location
*/
ClearBotJavelinLocation()
{
	self SetBotJavelinLocation(undefined);
}

/*
	Sets the bot's target to be this ent.
*/
SetAttacker(att)
{
	self.bot.target_this_frame = att;
}

/*
	Sets the script enemy for a bot.
*/
SetScriptEnemy(enemy, offset)
{
	self.bot.script_target = enemy;
	self.bot.script_target_offset = offset;
}

/*
	Removes the script enemy of the bot.
*/
ClearScriptEnemy()
{
	self SetScriptEnemy(undefined, undefined);
}

/*
	Returns the entity of the bot's target.
*/
GetThreat()
{
	if(!isdefined(self.bot.target))
		return undefined;
		
	return self.bot.target.entity;
}

/*
	Returns if the bot has a script enemy.
*/
HasScriptEnemy()
{
	return (isDefined(self.bot.script_target));
}

/*
	Returns if the bot has a threat.
*/
HasThreat()
{
	return (isDefined(self GetThreat()));
}

/*
	If the player is defusing
*/
IsDefusing()
{
	return (isDefined(self.isDefusing) && self.isDefusing);
}

/*
	If the play is planting
*/
isPlanting()
{
	return (isDefined(self.isPlanting) && self.isPlanting);
}

/*
	If the player is carrying a bomb
*/
isBombCarrier()
{
	return (isDefined(self.isBombCarrier) && self.isBombCarrier);
}

/*
	If the site is in use
*/
isInUse()
{
	return (isDefined(self.inUse) && self.inUse);
}

/*
	If the player is in laststand
*/
inLastStand()
{
	return (isDefined(self.lastStand) && self.lastStand);
}

/*
	If the player is in final stand
*/
inFinalStand()
{
	return (isDefined(self.inFinalStand) && self.inFinalStand);
}

/*
	If the player is the flag carrier
*/
isFlagCarrier()
{
	return (isDefined(self.carryFlag) && self.carryFlag);
}

/*
	Returns if we are stunned.
*/
IsStunned()
{
	return (isdefined(self.concussionEndTime) && self.concussionEndTime > gettime());
}

/*
	Returns if we are beingArtilleryShellshocked 
*/
isArtShocked()
{
	return (isDefined(self.beingArtilleryShellshocked) && self.beingArtilleryShellshocked);
}

/*
	Returns a valid grenade launcher weapon
*/
getValidTube()
{
	weaps = self getweaponslistall();

	for (i = 0; i < weaps.size; i++)
	{
		weap = weaps[i];

		if(!self getAmmoCount(weap))
			continue;

		if ((isSubStr(weap, "alt_") && (isSubStr(weap, "_m320") || isSubStr(weap, "_gl") || isSubStr(weap, "_gp25"))) || weap == "m320_mp")
			return weap;
	}

	return undefined;
}

/*
	helper
*/
waittill_either_return_(str1, str2)
{
	self endon(str1);
	self waittill(str2);
	return true;
}

/*
	Returns which string gets notified first
*/
waittill_either_return(str1, str2)
{
	if (!isDefined(self waittill_either_return_(str1, str2)))
		return str1;

	return str2;
}

/*
	Returns a random grenade in the bot's inventory.
*/
getValidGrenade()
{
	grenadeTypes = [];
	grenadeTypes[grenadeTypes.size] = "frag_grenade_mp";
	grenadeTypes[grenadeTypes.size] = "smoke_grenade_mp";
	grenadeTypes[grenadeTypes.size] = "flash_grenade_mp";
	grenadeTypes[grenadeTypes.size] = "concussion_grenade_mp";
	grenadeTypes[grenadeTypes.size] = "semtex_mp";
	grenadeTypes[grenadeTypes.size] = "throwingknife_mp";
	grenadeTypes[grenadeTypes.size] = "emp_grenade_mp";
	
	possibles = [];
	
	for(i = 0; i < grenadeTypes.size; i++)
	{
		if ( !self hasWeapon( grenadeTypes[i] ) )
			continue;
			
		if ( !self getAmmoCount( grenadeTypes[i] ) )
			continue;
			
		possibles[possibles.size] = grenadeTypes[i];
	}
	
	return random(possibles);
}

/*
	If the weapon is not a script weapon (bomb, killstreak, etc, grenades)
*/
isWeaponPrimary(weap)
{
	return (maps\mp\gametypes\_weapons::isPrimaryWeapon(weap) || maps\mp\gametypes\_weapons::isAltModeWeapon(weap));
}

/*
	If the ent is a vehicle
*/
entIsVehicle(ent)
{
	return (!isPlayer(ent) && (ent.classname == "script_vehicle" || ent.model == "vehicle_uav_static_mp" || ent.model == "vehicle_ac130_coop" || ent.model == "vehicle_predator_b" || ent.model == "vehicle_phantom_ray"));
}

/*
	Returns if the given weapon is full auto.
*/
WeaponIsFullAuto(weap)
{
	weaptoks = strtok(weap, "_");

	if (weaptoks.size < 2)
		return false;
	
	return isDefined(level.bots_fullautoguns[weaptoks[1]]);
}

/*
	If weap is a secondary gnade
*/
isSecondaryGrenade(gnade)
{
	return (gnade == "concussion_grenade_mp" || gnade == "flash_grenade_mp" || gnade == "smoke_grenade_mp" || gnade == "trophy_mp" || gnade == "emp_grenade_mp" || gnade == "flare_mp" || gnade == "scrambler_mp" || gnade == "portable_radar_mp");
}

/*
	If the weapon  is allowed to be dropped
*/
isWeaponDroppable(weap)
{
	return (maps\mp\gametypes\_weapons::mayDropWeapon(weap));
}

/*
	Returns the height the viewpos is above the origin
*/
getEyeHeight()
{
	myEye = self getEye();

	return myEye[2] - self.origin[2];
}

/*
	Does a notify after a delay
*/
notifyAfterDelay(delay, not)
{
	wait delay;
	self notify(not);
}

/*
	Gets a player who is host
*/
GetHostPlayer()
{
	for (i = 0; i < level.players.size; i++)
	{
		player = level.players[i];

		if (!player is_host())
			continue;

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

	while (!isDefined(level) || !isDefined(level.players))
		wait 0.05;
	
	for(i = getDvarFloat("bots_main_waitForHostTime"); i > 0; i -= 0.05)
	{
		host = GetHostPlayer();
		
		if(isDefined(host))
			break;
		
		wait 0.05;
	}
	
	if(!isDefined(host))
		return;
	
	for(i = getDvarFloat("bots_main_waitForHostTime"); i > 0; i -= 0.05)
	{
		if(IsDefined( host.pers[ "team" ] ))
			break;
		
		wait 0.05;
	}

	if(!IsDefined( host.pers[ "team" ] ))
		return;
	
	for(i = getDvarFloat("bots_main_waitForHostTime"); i > 0; i -= 0.05)
	{
		if(host.pers[ "team" ] == "allies" || host.pers[ "team" ] == "axis")
			break;
		
		wait 0.05;
	}
}

/*
	Pezbot's line sphere intersection.
	http://paulbourke.net/geometry/circlesphere/raysphere.c
*/
RaySphereIntersect(start, end, spherePos, radius)
{
	// check if the start or end points are in the sphere
	r2 = radius * radius;
	if (DistanceSquared(start, spherePos) < r2)
		return true;

	if (DistanceSquared(end, spherePos) < r2)
		return true;

	// check if the line made by start and end intersect the sphere
	dp = end - start;
	a = dp[0] * dp[0] + dp[1] * dp[1] + dp[2] * dp[2];
	b = 2 * (dp[0] * (start[0] - spherePos[0]) + dp[1] * (start[1] - spherePos[1]) + dp[2] * (start[2] - spherePos[2]));
	c = spherePos[0] * spherePos[0] + spherePos[1] * spherePos[1] + spherePos[2] * spherePos[2];
	c += start[0] * start[0] + start[1] * start[1] + start[2] * start[2];
	c -= 2.0 * (spherePos[0] * start[0] + spherePos[1] * start[1] + spherePos[2] * start[2]);
	c -= radius * radius;
	bb4ac = b * b - 4.0 * a * c;

	if (abs(a) < 0.0001 || bb4ac < 0)
		return false;

	mu1 = (0-b + sqrt(bb4ac)) / (2 * a);
	//mu2 = (0-b - sqrt(bb4ac)) / (2 * a);

	// intersection points of the sphere
	ip1 = start + mu1 * dp;
	//ip2 = start + mu2 * dp;

	myDist = DistanceSquared(start, end);

	// check if both intersection points far
	if (DistanceSquared(start, ip1) > myDist/* && DistanceSquared(start, ip2) > myDist*/)
		return false;

	dpAngles = VectorToAngles(dp);

	// check if the point is behind us
	if (getConeDot(ip1, start, dpAngles) < 0/* || getConeDot(ip2, start, dpAngles) < 0*/)
		return false;

	return true;
}

/*
	Returns if a smoke grenade would intersect start to end line.
*/
SmokeTrace(start, end, rad)
{
	for(i = level.bots_smokeList.count - 1; i >= 0; i--)
	{
		nade = level.bots_smokeList.data[i];
		
		if(nade.state != "smoking")
			continue;
			
		if(!RaySphereIntersect(start, end, nade.origin, rad))
			continue;
		
		return false;
	}
	
	return true;
}

/*
	Returns the cone dot (like fov, or distance from the center of our screen).
*/
getConeDot(to, from, dir)
{
	dirToTarget = VectorNormalize(to-from);
	forward = AnglesToForward(dir);
	return vectordot(dirToTarget, forward);
}

/*
	Returns the distance squared in a 2d space
*/
DistanceSquared2D(to, from)
{
	to = (to[0], to[1], 0);
	from = (from[0], from[1], 0);
	
	return DistanceSquared(to, from);
}

/*
	Rounds to the nearest whole number.
*/
Round(x)
{
	y = int(x);
	
	if(abs(x) - abs(y) > 0.5)
	{
		if(x < 0)
			return y - 1;
		else
			return y + 1;
	}
	else
		return y;
}

/*
	Rounds up the given value.
*/
RoundUp( floatVal )
{
	i = int( floatVal );
	if ( i != floatVal )
		return i + 1;
	else
		return i;
}

/*
	converts a string into a float
*/
float(num)
{
	setdvar("temp_dvar_bot_util", num);

	return GetDvarFloat("temp_dvar_bot_util");
}

/*
	Tokenizes a string (strtok has limits...) (only one char tok)
*/
tokenizeLine(line, tok)
{
	tokens = [];

	token = "";
	for (i = 0; i < line.size; i++)
	{
		c = line[i];

		if (c == tok)
		{
			tokens[tokens.size] = token;
			token = "";
			continue;
		}

		token += c;
	}
	tokens[tokens.size] = token;

	return tokens;
}

/*
	If the string starts with
*/
isStrStart( string1, subStr )
{
	return ( getSubStr( string1, 0, subStr.size ) == subStr );
}

/*
	Parses tokens into a waypoint obj
*/
parseTokensIntoWaypoint(tokens)
{
	waypoint = spawnStruct();

	orgStr = tokens[0];
	orgToks = strtok(orgStr, " ");
	waypoint.origin = (float(orgToks[0]), float(orgToks[1]), float(orgToks[2]));

	childStr = tokens[1];
	childToks = strtok(childStr, " ");
	waypoint.children = [];
	for( j=0; j<childToks.size; j++ )
		waypoint.children[j] = int(childToks[j]);

	type = tokens[2];
	waypoint.type = type;

	anglesStr = tokens[3];
	if (isDefined(anglesStr) && anglesStr != "")
	{
		anglesToks = strtok(anglesStr, " ");
		waypoint.angles = (float(anglesToks[0]), float(anglesToks[1]), float(anglesToks[2]));
	}

	javStr = tokens[4];
	if (isDefined(javStr) && javStr != "")
	{
		javToks = strtok(javStr, " ");
		waypoint.jav_point = (float(javToks[0]), float(javToks[1]), float(javToks[2]));
	}

	return waypoint;
}

/*
	Returns an array of each line
*/
getWaypointLinesFromFile(filename)
{
	/*result = spawnStruct();
	result.lines = [];

	waypointStr = fileRead(filename);

	if (!isDefined(waypointStr))
		return result;

	line = "";
	for (i=0;i<waypointStr.size;i++)
	{
		c = waypointStr[i];
		
		if (c == "\n")
		{
			result.lines[result.lines.size] = line;

			line = "";
			continue;
		}

		line += c;
	}
	result.lines[result.lines.size] = line;

	return result;*/
}

/*
	Loads waypoints from file
*/
readWpsFromFile(mapname)
{
	/*waypoints = [];
	filename = "waypoints/" + mapname + "_wp.csv";

	if (!fileExists(filename))
		return waypoints;

	res = getWaypointLinesFromFile(filename);

	if (!res.lines.size)
		return waypoints;

	printLn("Attempting to read waypoints from " + filename);

	waypointCount = int(res.lines[0]);

	for (i = 1; i <= waypointCount; i++)
	{
		tokens = tokenizeLine(res.lines[i], ",");
	
		waypoint = parseTokensIntoWaypoint(tokens);

		waypoints[i-1] = waypoint;
	}

	return waypoints;*/

	return [];
}

/*
	Loads the waypoints. Populating everything needed for the waypoints.
*/
load_waypoints()
{
	level.waypointCount = 0;
	level.waypoints = [];
	level.waypointUsage = [];
	level.waypointUsage["allies"] = [];
	level.waypointUsage["axis"] = [];

	mapname = getDvar("mapname");

	wps = readWpsFromFile(mapname);
	
	if (wps.size)
	{
		level.waypoints = wps;
		printLn("Loaded " + wps.size + " waypoints from csv.");
	}
	else
	{
		switch(mapname)
		{
			case "mp_dome":
				level.waypoints = maps\mp\bots\waypoints\dome::Dome();
			break;
			case "mp_seatown":
				level.waypoints = maps\mp\bots\waypoints\seatown::Seatown();
			break;
			case "mp_plaza2":
				level.waypoints = maps\mp\bots\waypoints\arkaden::Arkaden();
			break;
			case "mp_mogadishu":
				level.waypoints = maps\mp\bots\waypoints\bakaara::Bakaara();
			break;
			case "mp_highrise":
				level.waypoints = maps\mp\bots\waypoints\highrise::Highrise();
			break;
			case "mp_paris":
				level.waypoints = maps\mp\bots\waypoints\resistance::Resistance();
			break;
			case "mp_hardhat":
				level.waypoints = maps\mp\bots\waypoints\hardhat::Hardhat();
			break;
			case "mp_bootleg":
				level.waypoints = maps\mp\bots\waypoints\bootleg::Bootleg();
			break;
			case "mp_exchange":
				level.waypoints = maps\mp\bots\waypoints\downturn::Downturn();
			break;
			case "mp_carbon":
				level.waypoints = maps\mp\bots\waypoints\carbon::Carbon();
			break;
			case "mp_rust":
				level.waypoints = maps\mp\bots\waypoints\rust::Rust();
			break;
			case "mp_test":
				level.waypoints = maps\mp\bots\waypoints\testmap::TestMap();
			break;
			default:
				maps\mp\bots\waypoints\_custom_map::main(mapname);
			break;
		}

		if (level.waypoints.size)
			printLn("Loaded " + level.waypoints.size + " waypoints from script.");
	}

	if (!level.waypoints.size)
	{
		//maps\mp\bots\_bot_http::getRemoteWaypoints(mapname);
	}

	level.waypointCount = level.waypoints.size;
	
	for(i = 0; i < level.waypointCount; i++)
	{
		if (!isDefined(level.waypoints[i].children) || !isDefined(level.waypoints[i].children.size))
			level.waypoints[i].children = [];

		if (!isDefined(level.waypoints[i].origin))
			level.waypoints[i].origin = (0, 0, 0);

		if (!isDefined(level.waypoints[i].type))
			level.waypoints[i].type = "crouch";
	}
}

/*
	Is bot near any of the given waypoints
*/
nearAnyOfWaypoints(dist, waypoints)
{
	dist *= dist;
	for (i = 0; i < waypoints.size; i++)
	{
		waypoint = level.waypoints[waypoints[i]];

		if (DistanceSquared(waypoint.origin, self.origin) > dist)
			continue;

		return true;
	}

	return false;
}

/*
	Returns the waypoints that are near
*/
waypointsNear(waypoints, dist)
{
	dist *= dist;

	answer = [];

	for (i = 0; i < waypoints.size; i++)
	{
		wp = level.waypoints[waypoints[i]];

		if (DistanceSquared(wp.origin, self.origin) > dist)
			continue;

		answer[answer.size] = waypoints[i];
	}

	return answer;
}

/*
	Returns nearest waypoint of waypoints
*/
getNearestWaypointOfWaypoints(waypoints)
{
	answer = undefined;
	closestDist = 2147483647;
	for (i = 0; i < waypoints.size; i++)
	{
		waypoint = level.waypoints[waypoints[i]];
		thisDist = DistanceSquared(self.origin, waypoint.origin);

		if (isDefined(answer) && thisDist > closestDist)
			continue;

		answer = waypoints[i];
		closestDist = thisDist;
	}

	return answer;
}

/*
	Returns all waypoints of type
*/
getWaypointsOfType(type)
{
	answer = [];
	for(i = 0; i < level.waypointCount; i++)
	{
		wp = level.waypoints[i];
		
		if (type == "camp")
		{
			if (wp.type != "crouch")
				continue;

			if (wp.children.size != 1)
				continue;
		}
		else if (type != wp.type)
			continue;

		answer[answer.size] = i;
	}
	return answer;
}

/*
	Returns the waypoint for index
*/
getWaypointForIndex(i)
{
	if (!isDefined(i))
		return undefined;

	return level.waypoints[i];
}

/*
	Returns the friendly user name for a given map's codename
*/
getMapName(mapname)
{
  switch(mapname)
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
	switch(getdvar("mapname"))
	{
		case "mp_dome":
			if (level.teambased)
				return 8;
			else
				return 5;
		default:
			return 2;
	}
}

/*
	Matches a num to a char
*/
keyCodeToString(a)
{
	b="";
	switch(a)
	{
		case 0: b= "a"; break;
		case 1: b= "b"; break;
		case 2: b= "c"; break;
		case 3: b= "d"; break;
		case 4: b= "e"; break;
		case 5: b= "f"; break;
		case 6: b= "g"; break;
		case 7: b= "h"; break;
		case 8: b= "i"; break;
		case 9: b= "j"; break;
		case 10: b= "k"; break;
		case 11: b= "l"; break;
		case 12: b= "m"; break;
		case 13: b= "n"; break;
		case 14: b= "o"; break;
		case 15: b= "p"; break;
		case 16: b= "q"; break;
		case 17: b= "r"; break;
		case 18: b= "s"; break;
		case 19: b= "t"; break;
		case 20: b= "u"; break;
		case 21: b= "v"; break;
		case 22: b= "w"; break;
		case 23: b= "x"; break;
		case 24: b= "y"; break;
		case 25: b= "z"; break;
		case 26: b= "."; break;
		case 27: b= " "; break;
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
	for(i = 0; i < playercount; i++)
	{
		player = level.players[i];
		
		if(!player is_bot())
			continue;
			
		result[result.size] = player;
	}
	
	return result;
}

/*
	We return a balanced KDTree from the waypoints.
*/
WaypointsToKDTree()
{
	kdTree = KDTree();
	
	kdTree _WaypointsToKDTree(level.waypoints, 0);
	
	return kdTree;
}

/*
	Recurive function. We construct a balanced KD tree by sorting the waypoints using heap sort.
*/
_WaypointsToKDTree(waypoints, dem)
{
	if(!waypoints.size)
		return;

	callbacksort = undefined;

	switch(dem)
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
	
	heap = NewHeap(callbacksort);
	
	for(i = 0; i < waypoints.size; i++)
	{
		heap HeapInsert(waypoints[i]);
	}
	
	sorted = [];
	while(heap.data.size)
	{
		sorted[sorted.size] = heap.data[0];
		heap HeapRemove();
	}
	
	median = int(sorted.size/2);//use divide and conq
	
	left = [];
	right = [];
	for(i = 0; i < sorted.size; i++)
		if(i < median)
			right[right.size] = sorted[i];
		else if(i > median)
			left[left.size] = sorted[i];
	
	self KDTreeInsert(sorted[median]);
	
	_WaypointsToKDTree(left, (dem+1)%3);
	
	_WaypointsToKDTree(right, (dem+1)%3);
}

/*
	Returns a new list.
*/
List()
{
	list = spawnStruct();
	list.count = 0;
	list.data = [];
	
	return list;
}

/*
	Adds a new thing to the list.
*/
ListAdd(thing)
{
	self.data[self.count] = thing;
	
	self.count++;
}

/*
	Adds to the start of the list.
*/
ListAddFirst(thing)
{
	for (i = self.count - 1; i >= 0; i--)
	{
		self.data[i + 1] = self.data[i];
	}

	self.data[0] = thing;
	self.count++;
}

/*
	Removes the thing from the list.
*/
ListRemove(thing)
{
	for ( i = 0; i < self.count; i++ )
	{
		if ( self.data[i] == thing )
		{
			while ( i < self.count-1 )
			{
				self.data[i] = self.data[i+1];
				i++;
			}
			
			self.data[i] = undefined;
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
	kdTree = spawnStruct();
	kdTree.root = undefined;
	kdTree.count = 0;
	
	return kdTree;
}

/*
	Called on a KDTree. Will insert the object into the KDTree.
*/
KDTreeInsert(data)//as long as what you insert has a .origin attru, it will work.
{
	self.root = self _KDTreeInsert(self.root, data, 0, -2147483647, -2147483647, -2147483647, 2147483647, 2147483647, 2147483647);
}

/*
	Recurive function that insert the object into the KDTree.
*/
_KDTreeInsert(node, data, dem, x0, y0, z0, x1, y1, z1)
{
	if(!isDefined(node))
	{
		r = spawnStruct();
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
	
	switch(dem)
	{
		case 0:
			if(data.origin[0] < node.data.origin[0])
				node.left = self _KDTreeInsert(node.left, data, 1, x0, y0, z0, node.data.origin[0], y1, z1);
			else
				node.right = self _KDTreeInsert(node.right, data, 1, node.data.origin[0], y0, z0, x1, y1, z1);
		break;
		case 1:
			if(data.origin[1] < node.data.origin[1])
				node.left = self _KDTreeInsert(node.left, data, 2, x0, y0, z0, x1, node.data.origin[1], z1);
			else
				node.right = self _KDTreeInsert(node.right, data, 2, x0, node.data.origin[1], z0, x1, y1, z1);
		break;
		case 2:
			if(data.origin[2] < node.data.origin[2])
				node.left = self _KDTreeInsert(node.left, data, 0, x0, y0, z0, x1, y1, node.data.origin[2]);
			else
				node.right = self _KDTreeInsert(node.right, data, 0, x0, y0, node.data.origin[2], x1, y1, z1);
		break;
	}
	
	return node;
}

/*
	Called on a KDTree, will return the nearest object to the given origin.
*/
KDTreeNearest(origin)
{
	if(!isDefined(self.root))
		return undefined;
	
	return self _KDTreeNearest(self.root, origin, self.root.data, DistanceSquared(self.root.data.origin, origin), 0);
}

/*
	Recurive function that will retrieve the closest object to the query.
*/
_KDTreeNearest(node, point, closest, closestdist, dem)
{
	if(!isDefined(node))
	{
		return closest;
	}
	
	thisDis = DistanceSquared(node.data.origin, point);
	
	if(thisDis < closestdist)
	{
		closestdist = thisDis;
		closest = node.data;
	}
	
	if(node RectDistanceSquared(point) < closestdist)
	{
		near = node.left;
		far = node.right;
		if(point[dem] > node.data.origin[dem])
		{
			near = node.right;
			far = node.left;
		}
		
		closest = self _KDTreeNearest(near, point, closest, closestdist, (dem+1)%3);
		
		closest = self _KDTreeNearest(far, point, closest, DistanceSquared(closest.origin, point), (dem+1)%3);
	}
	
	return closest;
}

/*
	Called on a rectangle, returns the distance from origin to the rectangle.
*/
RectDistanceSquared(origin)
{
	dx = 0;
	dy = 0;
	dz = 0;
	
	if(origin[0] < self.x0)
		dx = origin[0] - self.x0;
	else if(origin[0] > self.x1)
		dx = origin[0] - self.x1;
		
	if(origin[1] < self.y0)
		dy = origin[1] - self.y0;
	else if(origin[1] > self.y1)
		dy = origin[1] - self.y1;

		
	if(origin[2] < self.z0)
		dz = origin[2] - self.z0;
	else if(origin[2] > self.z1)
		dz = origin[2] - self.z1;
		
	return dx*dx + dy*dy + dz*dz;
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
HeapSortCoordX(item, item2)
{
	return item.origin[0] > item2.origin[0];
}

/*
	A heap invarient comparitor, used for objects, objects with a higher Y coord will be first in the heap.
*/
HeapSortCoordY(item, item2)
{
	return item.origin[1] > item2.origin[1];
}

/*
	A heap invarient comparitor, used for objects, objects with a higher Z coord will be first in the heap.
*/
HeapSortCoordZ(item, item2)
{
	return item.origin[2] > item2.origin[2];
}

/*
	A heap invarient comparitor, used for numbers, numbers with the highest number will be first in the heap.
*/
Heap(item, item2)
{
	return item > item2;
}

/*
	A heap invarient comparitor, used for numbers, numbers with the lowest number will be first in the heap.
*/
ReverseHeap(item, item2)
{
	return item < item2;
}

/*
	A heap invarient comparitor, used for traces. Wanting the trace with the largest length first in the heap.
*/
HeapTraceFraction(item, item2)
{
	return item["fraction"] > item2["fraction"];
}

/*
	Returns a new heap.
*/
NewHeap(compare)
{
	heap_node = spawnStruct();
	heap_node.data = [];
	heap_node.compare = compare;
	
	return heap_node;
}

/*
	Inserts the item into the heap. Called on a heap.
*/
HeapInsert(item)
{
	insert = self.data.size;
	self.data[insert] = item;
	
	current = insert+1;
	
	while(current > 1)
	{
		last = current;
		current = int(current/2);
		
		if(![[self.compare]](item, self.data[current-1]))
			break;
			
		self.data[last-1] = self.data[current-1];
		self.data[current-1] = item;
	}
}

/*
	Helper function to determine what is the next child of the bst.
*/
_HeapNextChild(node, hsize)
{
	left = node * 2;
	right = left + 1;
	
	if(left > hsize)
		return -1;
		
	if(right > hsize)
		return left;
		
	if([[self.compare]](self.data[left-1], self.data[right-1]))
		return left;
	else
		return right;
}

/*
	Removes an item from the heap. Called on a heap.
*/
HeapRemove()
{
	remove = self.data.size;
	
	if(!remove)
		return remove;
	
	move = self.data[remove-1];
	self.data[0] = move;
	self.data[remove-1] = undefined;
	remove--;
	
	if(!remove)
		return remove;
	
	last = 1;
	next = self _HeapNextChild(1, remove);
	
	while(next != -1)
	{
		if([[self.compare]](move, self.data[next-1]))
			break;
			
		self.data[last-1] = self.data[next-1];
		self.data[next-1] = move;
		
		last = next;
		next = self _HeapNextChild(next, remove);
	}
	
	return remove;
}

/*
	A heap invarient comparitor, used for the astar's nodes, wanting the node with the lowest f to be first in the heap.
*/
ReverseHeapAStar(item, item2)
{
	return item.f < item2.f;
}

/*
	Removes the waypoint usage
*/
RemoveWaypointUsage(wp, team)
{
	if (!isDefined(level.waypointUsage))
		return;
	
	if (!isDefined(level.waypointUsage[team][wp+""]))
		return;

	level.waypointUsage[team][wp+""]--;

	if (level.waypointUsage[team][wp+""] <= 0)
		level.waypointUsage[team][wp+""] = undefined;
}

/*
	Will linearly search for the nearest waypoint to pos that has a direct line of sight.
*/
GetNearestWaypointWithSight(pos)
{
	candidate = undefined;
	dist = 2147483647;
	
	for(i = 0; i < level.waypointCount; i++)
	{
		if(!bulletTracePassed(pos + (0, 0, 15), level.waypoints[i].origin + (0, 0, 15), false, undefined))
			continue;
		
		curdis = DistanceSquared(level.waypoints[i].origin, pos);
		if(curdis > dist)
			continue;
			
		dist = curdis;
		candidate = i;
	}
	
	return candidate;
}

/*
	Will linearly search for the nearest waypoint
*/
GetNearestWaypoint(pos)
{
	candidate = undefined;
	dist = 2147483647;
	
	for(i = 0; i < level.waypointCount; i++)
	{
		curdis = DistanceSquared(level.waypoints[i].origin, pos);
		if(curdis > dist)
			continue;
			
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
AStarSearch(start, goal, team, greedy_path)
{
	open = NewHeap(::ReverseHeapAStar);//heap
	openset = [];//set for quick lookup
	closed = [];//set for quick lookup
	

	startWp = getNearestWaypoint(start);
	if(!isDefined(startWp))
		return [];
	
	_startwp = undefined;
	if(!bulletTracePassed(start + (0, 0, 15), level.waypoints[startWp].origin + (0, 0, 15), false, undefined))
		_startwp = GetNearestWaypointWithSight(start);

	if(isDefined(_startwp))
		startWp = _startwp;

	
	goalWp = getNearestWaypoint(goal);
	if(!isDefined(goalWp))
		return [];

	_goalWp = undefined;
	if(!bulletTracePassed(goal + (0, 0, 15), level.waypoints[goalWp].origin + (0, 0, 15), false, undefined))
		_goalwp = GetNearestWaypointWithSight(goal);
		
	if(isDefined(_goalwp))
		goalWp = _goalwp;

	
	node = spawnStruct();
	node.g = 0; //path dist so far
	node.h = DistanceSquared(level.waypoints[startWp].origin, level.waypoints[goalWp].origin); //herustic, distance to goal for path finding
	node.f = node.h + node.g; // combine path dist and heru, use reverse heap to sort the priority queue by this attru
	node.index = startWp;
	node.parent = undefined; //we are start, so we have no parent
	
	//push node onto queue
	openset[node.index+""] = node;
	open HeapInsert(node);
	
	//while the queue is not empty
	while(open.data.size)
	{
		//pop bestnode from queue
		bestNode = open.data[0];
		open HeapRemove();
		openset[bestNode.index+""] = undefined;
		wp = level.waypoints[bestNode.index];
		
		//check if we made it to the goal
		if(bestNode.index == goalWp)
		{
			path = [];
		
			while(isDefined(bestNode))
			{
				if(isdefined(team) && isDefined(level.waypointUsage))
				{
					if (!isDefined(level.waypointUsage[team][bestNode.index+""]))
						level.waypointUsage[team][bestNode.index+""] = 0;

					level.waypointUsage[team][bestNode.index+""]++;
				}
					
				//construct path
				path[path.size] = bestNode.index;
				
				bestNode = bestNode.parent;
			}

			return path;
		}

		//for each child of bestnode
		for(i = wp.children.size - 1; i >= 0; i--)
		{
			child = wp.children[i];
			childWp = level.waypoints[child];
			
			penalty = 1;
			if(!greedy_path && isdefined(team) && isDefined(level.waypointUsage))
			{
				temppen = 1;
				if (isDefined(level.waypointUsage[team][child+""]))
					temppen = level.waypointUsage[team][child+""];//consider how many bots are taking this path
				
				if(temppen > 1)
					penalty = temppen;
			}

			// have certain types of nodes more expensive
			if (childWp.type == "climb" || childWp.type == "prone")
				penalty += 4;
			
			//calc the total path we have took
			newg = bestNode.g + DistanceSquared(wp.origin, childWp.origin)*penalty;//bots on same team's path are more expensive
			
			//check if this child is in open or close with a g value less than newg
			inopen = isDefined(openset[child+""]);
			if(inopen && openset[child+""].g <= newg)
				continue;
			
			inclosed = isDefined(closed[child+""]);
			if(inclosed && closed[child+""].g <= newg)
				continue;
			
			node = undefined;
			if(inopen)
				node = openset[child+""];
			else if(inclosed)
				node = closed[child+""];
			else
				node = spawnStruct();
				
			node.parent = bestNode;
			node.g = newg;
			node.h = DistanceSquared(childWp.origin, level.waypoints[goalWp].origin);
			node.f = node.g + node.h;
			node.index = child;
			
			//check if in closed, remove it
			if(inclosed)
				closed[child+""] = undefined;
			
			//check if not in open, add it
			if(!inopen)
			{
				open HeapInsert(node);
				openset[child+""] = node;
			}
		}
		
		//done with children, push onto closed
		closed[bestNode.index+""] = bestNode;
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
		total += array[i];
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
		tmp[i] = ( array[i] - mean ) * ( array[i] - mean );
	}
	total = 0;
	for ( i = 0; i < tmp.size; i++ )
	{
		total = total + tmp[i];
	}
	return Sqrt( total / array.size );
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
		x1 = 2 * RandomFloatRange( 0, 1 ) - 1;
		x2 = 2 * RandomFloatRange( 0, 1 ) - 1;
		w = x1 * x1 + x2 * x2;
	}
	w = Sqrt( ( -2.0 * Log( w ) ) / w );
	y1 = x1 * w;
	number = mean + y1 * std_deviation;
	if ( IsDefined( lower_bound ) && number < lower_bound )
	{
		number = lower_bound;
	}
	if ( IsDefined( upper_bound ) && number > upper_bound )
	{
		number = upper_bound;
	}
	
	return( number );
}

/*
	Patches the plant sites so it exposes the defuseObject
*/
onUsePlantObjectFix( player )
{
	if ( !maps\mp\gametypes\_gameobjects::isFriendlyTeam( player.pers["team"] ) )
	{
		level thread bombPlantedFix( self, player );

		for ( i = 0; i < level.bombZones.size; i++ )
		{
			if ( level.bombZones[i] == self )
				continue;

			level.bombZones[i] maps\mp\gametypes\_gameobjects::disableObject();
		}

		player playsound( "mp_bomb_plant" );
		player notify( "bomb_planted" );
		player notify( "objective",  "plant"  );
		player maps\mp\_utility::incPersStat( "plants", 1 );
		player maps\mp\gametypes\_persistence::statSetChild( "round", "plants", player.pers["plants"] );

		if ( isdefined( level.sd_loadout ) && isdefined( level.sd_loadout[player.team] ) )
			player thread maps\mp\gametypes\sd::removeBombCarrierClass();

		maps\mp\_utility::leaderDialog( "bomb_planted" );
		level thread maps\mp\_utility::teamPlayerCardSplash( "callout_bombplanted", player );
		level.bombOwner = player;
		player thread maps\mp\gametypes\_hud_message::splashNotify( "plant", maps\mp\gametypes\_rank::getScoreInfoValue( "plant" ) );
		player thread maps\mp\gametypes\_rank::giveRankXP( "plant" );
		player.bombPlantedTime = gettime();
		maps\mp\gametypes\_gamescore::givePlayerScore( "plant", player );
		player thread maps\mp\_matchdata::logGameEvent( "plant", player.origin );
	}
}

/*
	Patches the plant sites so it exposes the defuseObject
*/
bombPlantedFix( var_0, var_1 )
{
	maps\mp\gametypes\_gamelogic::pauseTimer();
	level.bombPlanted = 1;
	var_0.visuals[0] thread maps\mp\gametypes\_gamelogic::playTickingSound();
	level.tickingObject = var_0.visuals[0];
	level.timeLimitOverride = 1;
	setgameendtime( int( gettime() + level.bombTimer * 1000 ) );
	setdvar( "ui_bomb_timer", 1 );

	if ( !level.multiBomb )
	{
		level.sdBomb maps\mp\gametypes\_gameobjects::allowCarry( "none" );
		level.sdBomb maps\mp\gametypes\_gameobjects::setVisibleTeam( "none" );
		level.sdBomb maps\mp\gametypes\_gameobjects::setDropped();
		level.sdBombModel = level.sdBomb.visuals[0];
	}
	else
	{
		for ( var_2 = 0; var_2 < level.players.size; var_2++ )
		{
			if ( isdefined( level.players[var_2].carryIcon ) )
				level.players[var_2].carryIcon maps\mp\gametypes\_hud_util::destroyElem();
		}

		var_3 = bullettrace( var_1.origin + ( 0, 0, 20 ), var_1.origin - ( 0, 0, 2000 ), 0, var_1 );
		var_4 = randomfloat( 360 );
		var_5 = ( cos( var_4 ), sin( var_4 ), 0 );
		var_5 = vectornormalize( var_5 - var_3["normal"] * vectordot( var_5, var_3["normal"] ) );
		var_6 = vectortoangles( var_5 );
		level.sdBombModel = spawn( "script_model", var_3["position"] );
		level.sdBombModel.angles = var_6;
		level.sdBombModel setmodel( "prop_suitcase_bomb" );
	}

	var_0 maps\mp\gametypes\_gameobjects::allowUse( "none" );
	var_0 maps\mp\gametypes\_gameobjects::setVisibleTeam( "none" );
	var_7 = var_0 maps\mp\gametypes\_gameobjects::getLabel();
	var_8 = var_0.bombDefuseTrig;
	var_8.origin = level.sdBombModel.origin;
	var_9 = [];
	defuseObject = maps\mp\gametypes\_gameobjects::createUseObject( game["defenders"], var_8, var_9, ( 0, 0, 32 ) );
	defuseObject maps\mp\gametypes\_gameobjects::allowUse( "friendly" );
	defuseObject maps\mp\gametypes\_gameobjects::setUseTime( level.defuseTime );
	defuseObject maps\mp\gametypes\_gameobjects::setUseText( &"MP_DEFUSING_EXPLOSIVE" );
	defuseObject maps\mp\gametypes\_gameobjects::setUseHintText( &"PLATFORM_HOLD_TO_DEFUSE_EXPLOSIVES" );
	defuseObject maps\mp\gametypes\_gameobjects::setVisibleTeam( "any" );
	defuseObject maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", "waypoint_defuse" + var_7 );
	defuseObject maps\mp\gametypes\_gameobjects::set2DIcon( "enemy", "waypoint_defend" + var_7 );
	defuseObject maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", "waypoint_defuse" + var_7 );
	defuseObject maps\mp\gametypes\_gameobjects::set3DIcon( "enemy", "waypoint_defend" + var_7 );
	defuseObject.label = var_7;
	defuseObject.onBeginUse = maps\mp\gametypes\sd::onBeginUse;
	defuseObject.onEndUse = maps\mp\gametypes\sd::onEndUse;
	defuseObject.onUse = maps\mp\gametypes\sd::onUseDefuseObject;
	defuseObject.useWeapon = "briefcase_bomb_defuse_mp";

	level.defuseObject = defuseObject;

	maps\mp\gametypes\sd::BombTimerWait();
	setdvar( "ui_bomb_timer", 0 );
	var_0.visuals[0] maps\mp\gametypes\_gamelogic::stopTickingSound();

	if ( level.gameEnded || level.bombDefused )
		return;

	level.bombexploded = 1;
	var_11 = level.sdBombModel.origin;
	level.sdBombModel hide();

	if ( isdefined( var_1 ) )
	{
		var_0.visuals[0] radiusdamage( var_11, 512, 200, 20, var_1, "MOD_EXPLOSIVE", "bomb_site_mp" );
		var_1 maps\mp\_utility::incPersStat( "destructions", 1 );
		var_1 maps\mp\gametypes\_persistence::statSetChild( "round", "destructions", var_1.pers["destructions"] );
	}
	else
		var_0.visuals[0] radiusdamage( var_11, 512, 200, 20, undefined, "MOD_EXPLOSIVE", "bomb_site_mp" );

	var_12 = randomfloat( 360 );
	var_13 = spawnfx( level._effect["bombexplosion"], var_11 + ( 0, 0, 50 ), ( 0, 0, 1 ), ( cos( var_12 ), sin( var_12 ), 0 ) );
	triggerfx( var_13 );
	playrumbleonposition( "grenade_rumble", var_11 );
	earthquake( 0.75, 2.0, var_11, 2000 );
	thread maps\mp\_utility::playSoundinSpace( "exp_suitcase_bomb_main", var_11 );

	if ( isdefined( var_0.exploderIndex ) )
		common_scripts\utility::exploder( var_0.exploderIndex );

	for ( var_2 = 0; var_2 < level.bombZones.size; var_2++ )
		level.bombZones[var_2] maps\mp\gametypes\_gameobjects::disableObject();

	defuseObject maps\mp\gametypes\_gameobjects::disableObject();
	setgameendtime( 0 );
	wait 3;
	maps\mp\gametypes\sd::sd_endGame( game["attackers"], game["strings"]["target_destroyed"] );
}

/*
	Patches giveLoadout so that it doesn't use IsItemUnlocked
*/
botGiveLoadout( team, class, allowCopycat, setPrimarySpawnWeapon ) // setPrimarySpawnWeapon only when called during spawn
{
	self endon("death");

	self takeallweapons();
	self.changingWeapon = undefined;
	teamName = "none";

	if ( !isdefined( setPrimarySpawnWeapon ) )
		setPrimarySpawnWeapon = true;

	primaryIndex = 0;

	// initialize specialty array
	self.specialty = [];

	if ( !isdefined( allowCopycat ) )
		allowCopycat = true;

	primaryWeapon = undefined;
	var_7 = 0;

	//	set in game mode custom class
	loadoutKillstreak1 = undefined;
	loadoutKillstreak2 = undefined;
	loadoutKillstreak3 = undefined;

	if ( issubstr( class, "axis" ) )
		teamName = "axis";
	else if ( issubstr( class, "allies" ) )
		teamName = "allies";

	clonedLoadout = [];

	if ( isdefined( self.pers["copyCatLoadout"] ) && self.pers["copyCatLoadout"]["inUse"] && allowCopycat )
	{
		self maps\mp\gametypes\_class::setClass( "copycat" );
		self.class_num = maps\mp\gametypes\_class::getClassIndex( "copycat" );
		clonedLoadout = self.pers["copyCatLoadout"];
		loadoutPrimary = clonedLoadout["loadoutPrimary"];
		loadoutPrimaryAttachment = clonedLoadout["loadoutPrimaryAttachment"];
		loadoutPrimaryAttachment2 = clonedLoadout["loadoutPrimaryAttachment2"];
		loadoutPrimaryBuff = clonedLoadout["loadoutPrimaryBuff"];
		loadoutPrimaryCamo = clonedLoadout["loadoutPrimaryCamo"];
		loadoutPrimaryReticle = clonedLoadout["loadoutPrimaryReticle"];
		loadoutSecondary = clonedLoadout["loadoutSecondary"];
		loadoutSecondaryAttachment = clonedLoadout["loadoutSecondaryAttachment"];
		loadoutSecondaryAttachment2 = clonedLoadout["loadoutSecondaryAttachment2"];
		loadoutSecondaryBuff = clonedLoadout["loadoutSecondaryBuff"];
		loadoutSecondaryCamo = clonedLoadout["loadoutSecondaryCamo"];
		loadoutSecondaryReticle = clonedLoadout["loadoutSecondaryReticle"];
		loadoutEquipment = clonedLoadout["loadoutEquipment"];
		loadoutPerk1 = clonedLoadout["loadoutPerk1"];
		loadoutPerk2 = clonedLoadout["loadoutPerk2"];
		loadoutPerk3 = clonedLoadout["loadoutPerk3"];
		loadoutStreakType = clonedLoadout["loadoutStreakType"];
		loadoutOffhand = clonedLoadout["loadoutOffhand"];
		loadoutDeathStreak = clonedLoadout["loadoutDeathstreak"];
		loadoutAmmoType = clonedLoadout["loadoutAmmoType"];
	}
	else if ( teamName != "none" )
	{
		classIndex = maps\mp\gametypes\_class::getClassIndex( class );
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

		if ( (loadoutPrimary == "throwingknife" || loadoutPrimary == "none") && loadoutSecondary != "none" )
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
		else if ( (loadoutPrimary == "throwingknife" || loadoutPrimary == "none") && loadoutSecondary == "none" )
		{
			var_7 = 1;
			loadoutPrimary = "iw5_usp45";
			loadoutPrimaryAttachment = "tactical";
		}

		loadoutEquipment = getmatchrulesdata( "defaultClasses", teamName, classIndex, "class", "perks", 0 );
		loadoutPerk1 = getmatchrulesdata( "defaultClasses", teamName, classIndex, "class", "perks", 1 );
		loadoutPerk2 = getmatchrulesdata( "defaultClasses", teamName, classIndex, "class", "perks", 2 );
		loadoutPerk3 = getmatchrulesdata( "defaultClasses", teamName, classIndex, "class", "perks", 3 );

		if ( loadoutSecondary != "none" && !maps\mp\gametypes\_class::isValidSecondary( loadoutSecondary, loadoutPerk2, 0 ) )
		{
			loadoutSecondary = maps\mp\gametypes\_class::table_getWeapon( level.classTableName, 10, 1 );
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
			loadoutKillstreak1 = maps\mp\gametypes\_class::recipe_getKillstreak( teamName, classIndex, loadoutStreakType, 0 );
			loadoutKillstreak2 = maps\mp\gametypes\_class::recipe_getKillstreak( teamName, classIndex, loadoutStreakType, 1 );
			loadoutKillstreak3 = maps\mp\gametypes\_class::recipe_getKillstreak( teamName, classIndex, loadoutStreakType, 2 );
		}

		loadoutOffhand = getmatchrulesdata( "defaultClasses", teamName, classIndex, "class", "perks", 6 );

		if ( loadoutOffhand == "specialty_null" )
			loadoutOffhand = "none";

		loadoutDeathStreak = getmatchrulesdata( "defaultClasses", teamName, classIndex, "class", "deathstreak" );

		if ( getmatchrulesdata( "defaultClasses", teamName, classIndex, "juggernaut" ) )
		{
			self thread recipeClassApplyJuggernaut( isJuggernaut() );
			self.isJuggernaut = true;
			self.juggmovespeedscaler = 0.7;
		}
		else if ( isJuggernaut() )
		{
			self notify( "lost_juggernaut" );
			self.isJuggernaut = false;
			self.moveSpeedScaler = 1;
		}
	}
	else if ( issubstr( class, "custom" ) )
	{
		class_num = maps\mp\gametypes\_class::getClassIndex( class );
		self.class_num = class_num;
		loadoutPrimary = maps\mp\gametypes\_class::cac_getWeapon( class_num, 0 );
		loadoutPrimaryAttachment = maps\mp\gametypes\_class::cac_getWeaponAttachment( class_num, 0 );
		loadoutPrimaryAttachment2 = maps\mp\gametypes\_class::cac_getWeaponAttachmentTwo( class_num, 0 );
		loadoutPrimaryBuff = maps\mp\gametypes\_class::cac_getWeaponBuff( class_num, 0 );
		loadoutPrimaryCamo = maps\mp\gametypes\_class::cac_getWeaponCamo( class_num, 0 );
		loadoutPrimaryReticle = maps\mp\gametypes\_class::cac_getWeaponReticle( class_num, 0 );
		loadoutSecondary = maps\mp\gametypes\_class::cac_getWeapon( class_num, 1 );
		loadoutSecondaryAttachment = maps\mp\gametypes\_class::cac_getWeaponAttachment( class_num, 1 );
		loadoutSecondaryAttachment2 = maps\mp\gametypes\_class::cac_getWeaponAttachmentTwo( class_num, 1 );
		loadoutSecondaryBuff = maps\mp\gametypes\_class::cac_getWeaponBuff( class_num, 1 );
		loadoutSecondaryCamo = maps\mp\gametypes\_class::cac_getWeaponCamo( class_num, 1 );
		loadoutSecondaryReticle = maps\mp\gametypes\_class::cac_getWeaponReticle( class_num, 1 );
		loadoutEquipment = maps\mp\gametypes\_class::cac_getPerk( class_num, 0 );
		loadoutPerk1 = maps\mp\gametypes\_class::cac_getPerk( class_num, 1 );
		loadoutPerk2 = maps\mp\gametypes\_class::cac_getPerk( class_num, 2 );
		loadoutPerk3 = maps\mp\gametypes\_class::cac_getPerk( class_num, 3 );
		loadoutStreakType = maps\mp\gametypes\_class::cac_getPerk( class_num, 5 );
		loadoutOffhand = maps\mp\gametypes\_class::cac_getOffhand( class_num );
		loadoutDeathStreak = maps\mp\gametypes\_class::cac_getDeathstreak( class_num );
	}
	else if ( class == "gamemode" )
	{
		gamemodeLoadout = self.pers["gamemodeLoadout"];
		loadoutPrimary = gamemodeLoadout["loadoutPrimary"];
		loadoutPrimaryAttachment = gamemodeLoadout["loadoutPrimaryAttachment"];
		loadoutPrimaryAttachment2 = gamemodeLoadout["loadoutPrimaryAttachment2"];
		loadoutPrimaryBuff = gamemodeLoadout["loadoutPrimaryBuff"];
		loadoutPrimaryCamo = gamemodeLoadout["loadoutPrimaryCamo"];
		loadoutPrimaryReticle = gamemodeLoadout["loadoutPrimaryReticle"];
		loadoutSecondary = gamemodeLoadout["loadoutSecondary"];
		loadoutSecondaryAttachment = gamemodeLoadout["loadoutSecondaryAttachment"];
		loadoutSecondaryAttachment2 = gamemodeLoadout["loadoutSecondaryAttachment2"];
		loadoutSecondaryBuff = gamemodeLoadout["loadoutSecondaryBuff"];
		loadoutSecondaryCamo = gamemodeLoadout["loadoutSecondaryCamo"];
		loadoutSecondaryReticle = gamemodeLoadout["loadoutSecondaryReticle"];

		if ( (loadoutPrimary == "throwingknife" || loadoutPrimary == "none") && loadoutSecondary != "none" )
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
		else if ( (loadoutPrimary == "throwingknife" || loadoutPrimary == "none") && loadoutSecondary == "none" )
		{
			var_7 = 1;
			loadoutPrimary = "iw5_usp45";
			loadoutPrimaryAttachment = "tactical";
		}

		loadoutEquipment = gamemodeLoadout["loadoutEquipment"];
		loadoutOffhand = gamemodeLoadout["loadoutOffhand"];

		if ( loadoutOffhand == "specialty_null" )
			loadoutOffhand = "none";

		loadoutPerk1 = gamemodeLoadout["loadoutPerk1"];
		loadoutPerk2 = gamemodeLoadout["loadoutPerk2"];
		loadoutPerk3 = gamemodeLoadout["loadoutPerk3"];

		if ( loadoutSecondary != "none" && !maps\mp\gametypes\_class::isValidSecondary( loadoutSecondary, loadoutPerk2, 0 ) )
		{
			loadoutSecondary = maps\mp\gametypes\_class::table_getWeapon( level.classTableName, 10, 1 );
			loadoutSecondaryAttachment = "none";
			loadoutSecondaryAttachment2 = "none";
			loadoutSecondaryBuff = "specialty_null";
			loadoutSecondaryCamo = "none";
			loadoutSecondaryReticle = "none";
		}

		if ( level.killstreakRewards && isdefined( gamemodeLoadout["loadoutStreakType"] ) && gamemodeLoadout["loadoutStreakType"] != "specialty_null" )
		{
			loadoutStreakType = gamemodeLoadout["loadoutStreakType"];
			loadoutKillstreak1 = gamemodeLoadout["loadoutKillstreak1"];
			loadoutKillstreak2 = gamemodeLoadout["loadoutKillstreak2"];
			loadoutKillstreak3 = gamemodeLoadout["loadoutKillstreak3"];
		}
		else if ( level.killstreakRewards && isdefined( self.streakType ) )
			loadoutStreakType = maps\mp\gametypes\_class::getLoadoutStreakTypeFromStreakType( self.streakType );
		else
		{
			loadoutStreakType = "streaktype_assault";
			loadoutKillstreak1 = "none";
			loadoutKillstreak2 = "none";
			loadoutKillstreak3 = "none";
		}

		loadoutDeathStreak = gamemodeLoadout["loadoutDeathstreak"];

		if ( gamemodeLoadout["loadoutJuggernaut"] )
		{
			self.health = self.maxHealth;
			self thread recipeClassApplyJuggernaut( isJuggernaut() );
			self.isJuggernaut = true;
			self.juggmovespeedscaler = 0.7;
		}
		else if ( isJuggernaut() )
		{
			self notify( "lost_juggernaut" );
			self.isJuggernaut = false;
			self.moveSpeedScaler = 1;
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
		loadoutStreakType = maps\mp\gametypes\_class::getLoadoutStreakTypeFromStreakType( self.streakType );
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
		loadoutStreakType = maps\mp\gametypes\_class::getLoadoutStreakTypeFromStreakType( self.streakType );
		loadoutOffhand = "smoke_grenade_mp";
		loadoutDeathStreak = "specialty_null";
	}
	else
	{
		class_num = maps\mp\gametypes\_class::getClassIndex( class );
		self.class_num = class_num;
		loadoutPrimary = maps\mp\gametypes\_class::table_getWeapon( level.classTableName, class_num, 0 );
		loadoutPrimaryAttachment = maps\mp\gametypes\_class::table_getWeaponAttachment( level.classTableName, class_num, 0, 0 );
		loadoutPrimaryAttachment2 = maps\mp\gametypes\_class::table_getWeaponAttachment( level.classTableName, class_num, 0, 1 );
		loadoutPrimaryBuff = maps\mp\gametypes\_class::table_getWeaponBuff( level.classTableName, class_num, 0 );
		loadoutPrimaryCamo = maps\mp\gametypes\_class::table_getWeaponCamo( level.classTableName, class_num, 0 );
		loadoutPrimaryReticle = maps\mp\gametypes\_class::table_getWeaponReticle( level.classTableName, class_num, 0 );
		loadoutSecondary = maps\mp\gametypes\_class::table_getWeapon( level.classTableName, class_num, 1 );
		loadoutSecondaryAttachment = maps\mp\gametypes\_class::table_getWeaponAttachment( level.classTableName, class_num, 1, 0 );
		loadoutSecondaryAttachment2 = maps\mp\gametypes\_class::table_getWeaponAttachment( level.classTableName, class_num, 1, 1 );
		loadoutSecondaryBuff = maps\mp\gametypes\_class::table_getWeaponBuff( level.classTableName, class_num, 1 );
		loadoutSecondaryCamo = maps\mp\gametypes\_class::table_getWeaponCamo( level.classTableName, class_num, 1 );
		loadoutSecondaryReticle = maps\mp\gametypes\_class::table_getWeaponReticle( level.classTableName, class_num, 1 );
		loadoutEquipment = maps\mp\gametypes\_class::table_getEquipment( level.classTableName, class_num, 0 );
		loadoutPerk1 = maps\mp\gametypes\_class::table_getPerk( level.classTableName, class_num, 1 );
		loadoutPerk2 = maps\mp\gametypes\_class::table_getPerk( level.classTableName, class_num, 2 );
		loadoutPerk3 = maps\mp\gametypes\_class::table_getPerk( level.classTableName, class_num, 3 );
		loadoutStreakType = maps\mp\gametypes\_class::table_getPerk( level.classTableName, class_num, 5 );
		loadoutOffhand = maps\mp\gametypes\_class::table_getOffhand( level.classTableName, class_num );
		loadoutDeathStreak = maps\mp\gametypes\_class::table_getDeathstreak( level.classTableName, class_num );
	}

	self maps\mp\gametypes\_class::loadoutFakePerks( loadoutStreakType );
	isCustomClass = issubstr( class, "custom" );
	isRecipeClass = issubstr( class, "recipe" );
	isGameModeClass = (class == "gamemode");

	if ( !isGameModeClass && !isRecipeClass && !(isdefined( self.pers["copyCatLoadout"] ) && self.pers["copyCatLoadout"]["inUse"] && allowCopycat) )
	{
		if ( !maps\mp\gametypes\_class::isValidPrimary( loadoutPrimary ) )
			loadoutPrimary = maps\mp\gametypes\_class::table_getWeapon( level.classTableName, 10, 0 );

		if ( !maps\mp\gametypes\_class::isValidAttachment( loadoutPrimaryAttachment ) )
			loadoutPrimaryAttachment = maps\mp\gametypes\_class::table_getWeaponAttachment( level.classTableName, 10, 0, 0 );

		if ( !maps\mp\gametypes\_class::isValidAttachment( loadoutPrimaryAttachment2 ) )
			loadoutPrimaryAttachment2 = maps\mp\gametypes\_class::table_getWeaponAttachment( level.classTableName, 10, 0, 1 );

		if ( !maps\mp\gametypes\_class::isValidWeaponBuff( loadoutPrimaryBuff, loadoutPrimary ) )
			loadoutPrimaryBuff = maps\mp\gametypes\_class::table_getWeaponBuff( level.classTableName, 10, 0 );

		if ( !maps\mp\gametypes\_class::isValidCamo( loadoutPrimaryCamo ) )
			loadoutPrimaryCamo = maps\mp\gametypes\_class::table_getWeaponCamo( level.classTableName, 10, 0 );

		if ( !maps\mp\gametypes\_class::isValidReticle( loadoutPrimaryReticle ) )
			loadoutPrimaryReticle = maps\mp\gametypes\_class::table_getWeaponReticle( level.classTableNum, 10, 0 );

		if ( !maps\mp\gametypes\_class::isValidSecondary( loadoutSecondary, loadoutPerk2 ) )
		{
			loadoutSecondary = maps\mp\gametypes\_class::table_getWeapon( level.classTableName, 10, 1 );
			loadoutSecondaryAttachment = "none";
			loadoutSecondaryAttachment2 = "none";
			loadoutSecondaryBuff = "specialty_null";
			loadoutSecondaryCamo = "none";
			loadoutSecondaryReticle = "none";
		}

		if ( !maps\mp\gametypes\_class::isValidAttachment( loadoutSecondaryAttachment ) )
			loadoutSecondaryAttachment = maps\mp\gametypes\_class::table_getWeaponAttachment( level.classTableName, 10, 1, 0 );

		if ( !maps\mp\gametypes\_class::isValidAttachment( loadoutSecondaryAttachment2 ) )
			loadoutSecondaryAttachment2 = maps\mp\gametypes\_class::table_getWeaponAttachment( level.classTableName, 10, 1, 1 );

		if ( loadoutPerk2 == "specialty_twoprimaries" && !maps\mp\gametypes\_class::isValidWeaponBuff( loadoutSecondaryBuff, loadoutSecondary ) )
			loadoutSecondaryBuff = maps\mp\gametypes\_class::table_getWeaponBuff( level.classTableName, 10, 1 );

		if ( !maps\mp\gametypes\_class::isValidCamo( loadoutSecondaryCamo ) )
			loadoutSecondaryCamo = maps\mp\gametypes\_class::table_getWeaponCamo( level.classTableName, 10, 1 );

		if ( !maps\mp\gametypes\_class::isValidReticle( loadoutSecondaryReticle ) )
			loadoutSecondaryReticle = maps\mp\gametypes\_class::table_getWeaponReticle( level.classTableName, 10, 1 );

		if ( !maps\mp\gametypes\_class::isValidEquipment( loadoutEquipment ) )
			loadoutEquipment = maps\mp\gametypes\_class::table_getEquipment( level.classTableName, 10, 0 );

		if ( !maps\mp\gametypes\_class::isValidPerk1( loadoutPerk1 ) )
			loadoutPerk1 = maps\mp\gametypes\_class::table_getPerk( level.classTableName, 10, 1 );

		if ( !maps\mp\gametypes\_class::isValidPerk2( loadoutPerk2 ) )
			loadoutPerk2 = maps\mp\gametypes\_class::table_getPerk( level.classTableName, 10, 2 );

		if ( !maps\mp\gametypes\_class::isValidPerk3( loadoutPerk3 ) )
			loadoutPerk3 = maps\mp\gametypes\_class::table_getPerk( level.classTableName, 10, 3 );

		if ( !maps\mp\gametypes\_class::isValidDeathStreak( loadoutDeathStreak ) )
			loadoutDeathStreak = maps\mp\gametypes\_class::table_getDeathstreak( level.classTableName, 10 );

		if ( !maps\mp\gametypes\_class::isValidOffhand( loadoutOffhand ) )
			loadoutOffhand = maps\mp\gametypes\_class::table_getOffhand( level.classTableName, 10 );

		if ( loadoutPrimaryAttachment2 != "none" && loadoutPrimaryBuff != "specialty_bling" )
			loadoutPrimaryAttachment2 = "none";

		if ( loadoutSecondaryBuff != "specialty_null" && loadoutPerk2 != "specialty_twoprimaries" )
			loadoutSecondaryBuff = "specialty_null";

		if ( loadoutSecondaryAttachment2 != "none" && (loadoutSecondaryBuff != "specialty_bling" || loadoutPerk2 != "specialty_twoprimaries") )
			loadoutSecondaryAttachment2 = "none";
	}

	self.loadoutPrimary = loadoutPrimary;
	self.loadoutPrimaryCamo = int( tablelookup( "mp/camoTable.csv", 1, loadoutPrimaryCamo, 0 ) );
	self.loadoutSecondary = loadoutSecondary;
	self.loadoutSecondaryCamo = int( tablelookup( "mp/camoTable.csv", 1, loadoutSecondaryCamo, 0 ) );

	if ( !issubstr( loadoutPrimary, "iw5" ) )
		self.loadoutPrimaryCamo = 0;

	if ( !issubstr( loadoutSecondary, "iw5" ) )
		self.loadoutSecondaryCamo = 0;

	self.loadoutPrimaryReticle = int( tablelookup( "mp/reticleTable.csv", 1, loadoutPrimaryReticle, 0 ) );
	self.loadoutSecondaryReticle = int( tablelookup( "mp/reticleTable.csv", 1, loadoutSecondaryReticle, 0 ) );

	if ( !issubstr( loadoutPrimary, "iw5" ) )
		self.loadoutPrimaryReticle = 0;

	if ( !issubstr( loadoutSecondary, "iw5" ) )
		self.loadoutSecondaryReticle = 0;

	if ( loadoutSecondary == "none" )
		secondaryName = "none";
	else
	{
		secondaryName = maps\mp\gametypes\_class::buildWeaponName( loadoutSecondary, loadoutSecondaryAttachment, loadoutSecondaryAttachment2, self.loadoutSecondaryCamo, self.loadoutSecondaryReticle );
		self _giveWeapon( secondaryName );
		weaponTokens = strtok( secondaryName, "_" );

		if ( weaponTokens[0] == "iw5" )
			weaponTokens[0] = weaponTokens[0] + "_" + weaponTokens[1];
		else if ( weaponTokens[0] == "alt" )
			weaponTokens[0] = weaponTokens[1] + "_" + weaponTokens[2];

		weaponName = weaponTokens[0];
		curWeaponRank = self maps\mp\gametypes\_rank::getWeaponRank( weaponName );
		curWeaponStatRank = self getplayerdata( "weaponRank", weaponName );

		if ( curWeaponRank != curWeaponStatRank )
			self setplayerdata( "weaponRank", weaponName, curWeaponRank );
	}

	self setoffhandprimaryclass( "other" );
	self _setActionSlot( 1, "" );
	self _setActionSlot( 3, "altMode" );
	self _setActionSlot( 4, "" );

	if ( !level.console )
	{
		self _setActionSlot( 5, "" );
		self _setActionSlot( 6, "" );
		self _setActionSlot( 7, "" );
	}

	self _clearPerks();
	self maps\mp\gametypes\_class::_detachAll();

	if ( level.dieHardMode )
		self givePerk( "specialty_pistoldeath", false );

	self loadoutAllPerks( loadoutEquipment, loadoutPerk1, loadoutPerk2, loadoutPerk3, loadoutPrimaryBuff, loadoutSecondaryBuff );

	if ( self _hasPerk( "specialty_extraammo" ) && secondaryName != "none" && getWeaponClass( secondaryName ) != "weapon_projectile" )
		self givemaxammo( secondaryName );

	self.spawnperk = false;

	if ( !self _hasPerk( "specialty_blindeye" ) && self.avoidKillstreakOnSpawnTimer > 0 )
		self thread maps\mp\perks\_perks::giveBlindEyeAfterSpawn();

	if ( self.pers["cur_death_streak"] > 0 )
	{
		deathStreaks = [];

		if ( loadoutDeathStreak != "specialty_null" )
			deathStreaks[loadoutDeathStreak] = int( tablelookup( "mp/perkTable.csv", 1, loadoutDeathStreak, 6 ) );

		if ( self getPerkUpgrade( loadoutPerk1 ) == "specialty_rollover" || self getPerkUpgrade( loadoutPerk2 ) == "specialty_rollover" || getPerkUpgrade( loadoutPerk3 ) == "specialty_rollover" )
		{
			foreach ( key, value in deathStreaks )
				deathStreaks[key] -= 1;
		}

		foreach ( key, value in deathStreaks )
		{
			if ( self.pers["cur_death_streak"] >= value )
			{
				if ( key == "specialty_carepackage" && self.pers["cur_death_streak"] > value )
					continue;

				if ( key == "specialty_uav" && self.pers["cur_death_streak"] > value )
					continue;

				self thread givePerk( key, true );
				self thread maps\mp\gametypes\_hud_message::splashNotify( key );
			}
		}
	}

	if ( level.killstreakRewards && !isdefined( loadoutKillstreak1 ) && !isdefined( loadoutKillstreak2 ) && !isdefined( loadoutKillstreak3 ) )
	{
		if ( isdefined( self.pers["copyCatLoadout"] ) && self.pers["copyCatLoadout"]["inUse"] && allowCopycat )
		{
			loadoutKillstreak1 = clonedLoadout["loadoutKillstreak1"];
			loadoutKillstreak2 = clonedLoadout["loadoutKillstreak2"];
			loadoutKillstreak3 = clonedLoadout["loadoutKillstreak3"];
		}
		else
		{
			defaultKillstreak1 = undefined;
			defaultKillstreak2 = undefined;
			defaultKillstreak3 = undefined;
			playerData = undefined;

			switch ( self.streakType )
			{
				case "support":
					defaultKillstreak1 = maps\mp\gametypes\_class::table_getKillstreak( level.classTableName, 2, 1 );
					defaultKillstreak2 = maps\mp\gametypes\_class::table_getKillstreak( level.classTableName, 2, 2 );
					defaultKillstreak3 = maps\mp\gametypes\_class::table_getKillstreak( level.classTableName, 2, 3 );
					playerData = "defenseStreaks";
					break;
				case "specialist":
					defaultKillstreak1 = maps\mp\gametypes\_class::table_getKillstreak( level.classTableName, 1, 1 );
					defaultKillstreak2 = maps\mp\gametypes\_class::table_getKillstreak( level.classTableName, 1, 2 );
					defaultKillstreak3 = maps\mp\gametypes\_class::table_getKillstreak( level.classTableName, 1, 3 );
					playerData = "specialistStreaks";
					break;
				default:
					defaultKillstreak1 = maps\mp\gametypes\_class::table_getKillstreak( level.classTableName, 0, 1 );
					defaultKillstreak2 = maps\mp\gametypes\_class::table_getKillstreak( level.classTableName, 0, 2 );
					defaultKillstreak3 = maps\mp\gametypes\_class::table_getKillstreak( level.classTableName, 0, 3 );
					playerData = "assaultStreaks";
					break;
			}

			loadoutKillstreak1 = undefined;
			loadoutKillstreak2 = undefined;
			loadoutKillstreak3 = undefined;

			if ( issubstr( class, "custom" ) )
			{
				customClassLoc = maps\mp\gametypes\_class::cac_getCustomClassLoc();
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
						loadoutKillstreak3 = killstreak;
				}

				if ( isGameModeClass && self.streakType == "specialist" )
				{
					self.pers["gamemodeLoadout"]["loadoutKillstreak1"] = loadoutKillstreak1;
					self.pers["gamemodeLoadout"]["loadoutKillstreak2"] = loadoutKillstreak2;
					self.pers["gamemodeLoadout"]["loadoutKillstreak3"] = loadoutKillstreak3;
				}
			}

			if ( !issubstr( class, "custom" ) && !issubstr( class, "juggernaut" ) && !isGameModeClass )
			{
				loadoutKillstreak1 = defaultKillstreak1;
				loadoutKillstreak2 = defaultKillstreak2;
				loadoutKillstreak3 = defaultKillstreak3;
			}

			if ( !isdefined( loadoutKillstreak1 ) )
				loadoutKillstreak1 = "none";

			if ( !isdefined( loadoutKillstreak2 ) )
				loadoutKillstreak2 = "none";

			if ( !isdefined( loadoutKillstreak3 ) )
				loadoutKillstreak3 = "none";

			var_56 = 0;

			if ( !maps\mp\gametypes\_class::isValidKillstreak( loadoutKillstreak1 ) )
				var_56 = 1;

			if ( !maps\mp\gametypes\_class::isValidKillstreak( loadoutKillstreak2 ) )
				var_56 = 1;

			if ( !maps\mp\gametypes\_class::isValidKillstreak( loadoutKillstreak3 ) )
				var_56 = 1;

			if ( var_56 )
			{
				self.streakType = "assault";
				loadoutKillstreak1 = maps\mp\gametypes\_class::table_getKillstreak( level.classTableName, 0, 1 );
				loadoutKillstreak2 = maps\mp\gametypes\_class::table_getKillstreak( level.classTableName, 0, 2 );
				loadoutKillstreak3 = maps\mp\gametypes\_class::table_getKillstreak( level.classTableName, 0, 3 );
			}
		}
	}
	else if ( !level.killstreakRewards )
	{
		loadoutKillstreak1 = "none";
		loadoutKillstreak2 = "none";
		loadoutKillstreak3 = "none";
	}

	self maps\mp\gametypes\_class::setKillstreaks( loadoutKillstreak1, loadoutKillstreak2, loadoutKillstreak3 );

	if ( isdefined( self.lastClass ) && self.lastClass != self.class && !issubstr( self.class, "juggernaut" ) && !issubstr( self.lastClass, "juggernaut" ) && !issubstr( class, "juggernaut" ) )
	{
		if ( wasOnlyRound() || self.lastClass != "" )
		{
			streakNames = [];
			inc = 0;

			if ( self.pers["killstreaks"].size > 5 )
			{
				for ( i = 5; i < self.pers["killstreaks"].size; i++ )
				{
					streakNames[inc] = self.pers["killstreaks"][i].streakName;
					inc++;
				}
			}

			if ( self.pers["killstreaks"].size )
			{
				for ( i = 1; i < 4; i++ )
				{
					if ( isdefined( self.pers["killstreaks"][i] ) && isdefined( self.pers["killstreaks"][i].streakName ) && self.pers["killstreaks"][i].available && !self.pers["killstreaks"][i].isSpecialist )
					{
						streakNames[inc] = self.pers["killstreaks"][i].streakName;
						inc++;
					}
				}
			}

			self notify( "givingLoadout" );
			self maps\mp\killstreaks\_killstreaks::clearKillstreaks();

			for ( i = 0; i < streakNames.size; i++ )
				self maps\mp\killstreaks\_killstreaks::giveKillstreak( streakNames[i] );
		}
	}

	if ( !issubstr( class, "juggernaut" ) )
	{
		if ( isdefined( self.lastClass ) && self.lastClass != "" && self.lastClass != self.class )
			self incPlayerStat( "mostclasseschanged", 1 );

		self.pers["lastClass"] = self.class;
		self.lastClass = self.class;
	}

	if ( isdefined( self.gamemode_chosenclass ) )
	{
		self.pers["class"] = self.gamemode_chosenclass;
		self.pers["lastClass"] = self.gamemode_chosenclass;
		self.class = self.gamemode_chosenclass;
		self.lastClass = self.gamemode_chosenclass;
		self.gamemode_chosenclass = undefined;
	}

	primaryName = maps\mp\gametypes\_class::buildWeaponName( loadoutPrimary, loadoutPrimaryAttachment, loadoutPrimaryAttachment2, self.loadoutPrimaryCamo, self.loadoutPrimaryReticle );
	self _giveWeapon( primaryName );
	self switchtoweapon( primaryName );
	weaponTokens = strtok( primaryName, "_" );

	if ( weaponTokens[0] == "iw5" )
		weaponName = weaponTokens[0] + "_" + weaponTokens[1];
	else if ( weaponTokens[0] == "alt" )
		weaponName = weaponTokens[1] + "_" + weaponTokens[2];
	else
		weaponName = weaponTokens[0];

	curWeaponRank = self maps\mp\gametypes\_rank::getWeaponRank( weaponName );
	curWeaponStatRank = self getplayerdata( "weaponRank", weaponName );

	if ( curWeaponRank != curWeaponStatRank )
		self setplayerdata( "weaponRank", weaponName, curWeaponRank );

	if ( primaryName == "riotshield_mp" && level.inGracePeriod )
		self notify( "weapon_change",  "riotshield_mp"  );

	if ( self _hasPerk( "specialty_extraammo" ) )
		self givemaxammo( primaryName );

	if ( setPrimarySpawnWeapon )
		self setspawnweapon( primaryName );

	self.pers["primaryWeapon"] = weaponName;
	primaryTokens = strtok( primaryName, "_" );
	offhandSecondaryWeapon = loadoutOffhand;

	if ( loadoutOffhand == "none" )
		self setoffhandsecondaryclass( "none" );
	else if ( loadoutOffhand == "flash_grenade_mp" )
		self setoffhandsecondaryclass( "flash" );
	else if ( loadoutOffhand == "smoke_grenade_mp" || loadoutOffhand == "concussion_grenade_mp" )
		self setoffhandsecondaryclass( "smoke" );
	else
		self setoffhandsecondaryclass( "flash" );

	switch ( offhandSecondaryWeapon )
	{
		case "none":
			break;
		case "trophy_mp":
		case "specialty_portable_radar":
		case "specialty_scrambler":
		case "specialty_tacticalinsertion":
			self givePerk( offhandSecondaryWeapon, 0 );
			break;
		default:
			self giveweapon( offhandSecondaryWeapon );

			if ( loadoutOffhand == "flash_grenade_mp" )
				self setweaponammoclip( offhandSecondaryWeapon, 2 );
			else if ( loadoutOffhand == "concussion_grenade_mp" )
				self setweaponammoclip( offhandSecondaryWeapon, 2 );
			else
				self setweaponammoclip( offhandSecondaryWeapon, 1 );

			break;
	}

	primaryWeapon = primaryName;
	self.primaryWeapon = primaryWeapon;
	self.secondaryWeapon = secondaryName;

	if ( var_7 )
	{
		self setweaponammoclip( self.primaryWeapon, 0 );
		self setweaponammostock( self.primaryWeapon, 0 );
	}

	self playerModelForWeapon( self.pers["primaryWeapon"], getBaseWeaponName( secondaryName ) );
	self.isSniper = (weaponclass( self.primaryWeapon ) == "sniper");
	self maps\mp\gametypes\_weapons::updateMoveSpeedScale();
	self maps\mp\perks\_perks::cac_selector();
	self notify( "changed_kit" );
	self notify( "bot_giveLoadout" );
}

/*
	Patches giveLoadout so that it doesn't use IsItemUnlocked
*/
getPerkUpgrade( perkName )
{
	perkUpgrade = tablelookup( "mp/perktable.csv", 1, perkName, 8 );
	
	if ( perkUpgrade == "" || perkUpgrade == "specialty_null" )
		return "specialty_null";
		
	if ( !isDefined(self.pers["bots"]["unlocks"]["upgraded_"+perkName]) || !self.pers["bots"]["unlocks"]["upgraded_"+perkName] )
		return "specialty_null";
		
	return ( perkUpgrade );
}

/*
	Patches giveLoadout so that it doesn't use IsItemUnlocked
*/
loadoutAllPerks( loadoutEquipment, loadoutPerk1, loadoutPerk2, loadoutPerk3, loadoutPrimaryBuff, loadoutSecondaryBuff )
{
	loadoutEquipment = maps\mp\perks\_perks::validatePerk( 1, loadoutEquipment );
	loadoutPerk1 = maps\mp\perks\_perks::validatePerk( 1, loadoutPerk1 );
	loadoutPerk2 = maps\mp\perks\_perks::validatePerk( 2, loadoutPerk2 );
	loadoutPerk3 = maps\mp\perks\_perks::validatePerk( 3, loadoutPerk3 );

	loadoutPrimaryBuff = maps\mp\perks\_perks::validatePerk( undefined, loadoutPrimaryBuff );
	if( loadoutPerk2 == "specialty_twoprimaries" )
		loadoutSecondaryBuff = maps\mp\perks\_perks::validatePerk( undefined, loadoutSecondaryBuff );

	self.loadoutPerk1 = loadoutPerk1;
	self.loadoutPerk2 = loadoutPerk2;
	self.loadoutPerk3 = loadoutPerk3;
	self.loadoutPerkEquipment = loadoutEquipment;
	self.loadoutPrimaryBuff = loadoutPrimaryBuff;
	if( loadoutPerk2 == "specialty_twoprimaries" )
		self.loadoutSecondaryBuff = loadoutSecondaryBuff;

	if( loadoutEquipment != "specialty_null" )
		self givePerk( loadoutEquipment, true );
	if( loadoutPerk1 != "specialty_null" )
		self givePerk( loadoutPerk1, true );
	if( loadoutPerk2 != "specialty_null" )
		self givePerk( loadoutPerk2, true );
	if( loadoutPerk3 != "specialty_null" )
		self givePerk( loadoutPerk3, true );
	
	if( loadoutPrimaryBuff != "specialty_null" )
		self givePerk( loadoutPrimaryBuff, true );

	perkUpgrd[0] = tablelookup( "mp/perktable.csv", 1, loadoutPerk1, 8 );
	perkUpgrd[1] = tablelookup( "mp/perktable.csv", 1, loadoutPerk2, 8 );
	perkUpgrd[2] = tablelookup( "mp/perktable.csv", 1, loadoutPerk3, 8 );

	perks[0] = loadoutPerk1;
	perks[1] = loadoutPerk2;
	perks[2] = loadoutPerk3;
	
	for (i = 0; i < perkUpgrd.size; i++)
	{
		upgrade = perkUpgrd[i];
		perk = perks[i];

		if ( upgrade == "" || upgrade == "specialty_null" )
			continue;
			
		if ( isDefined(self.pers["bots"]["unlocks"]["upgraded_"+perk]) && self.pers["bots"]["unlocks"]["upgraded_"+perk] )
		{
			self givePerk( upgrade, true );
		}
	}

	if( !self _hasPerk( "specialty_assists" ) )
		self.pers["assistsToKill"] = 0;
}

/*
	Patches giveLoadout so that it doesn't use IsItemUnlocked
*/
playerModelForWeapon( weapon, secondary )
{
	team = self.team;

	if ( isdefined( game[team + "_model"][weapon] ) )
	{
		[[ game[team + "_model"][weapon] ]]();
		return;
	}

	weaponClass = tablelookup( "mp/statstable.csv", 4, weapon, 2 );

	switch ( weaponClass )
	{
		case "weapon_smg":
			[[ game[team + "_model"]["SMG"] ]]();
			break;
		case "weapon_assault":
			[[ game[team + "_model"]["ASSAULT"] ]]();
			break;
		case "weapon_sniper":
			if ( level.environment != "" && game[team] != "opforce_africa" && isDefined(self.pers["bots"]["unlocks"]["ghillie"]) && self.pers["bots"]["unlocks"]["ghillie"] )
				[[ game[team + "_model"]["GHILLIE"] ]]();
			else
				[[ game[team + "_model"]["SNIPER"] ]]();

			break;
		case "weapon_lmg":
			[[ game[team + "_model"]["LMG"] ]]();
			break;
		case "weapon_riot":
			[[ game[team + "_model"]["RIOT"] ]]();
			break;
		case "weapon_shotgun":
			[[ game[team + "_model"]["SHOTGUN"] ]]();
			break;
		default:
			[[ game[team + "_model"]["ASSAULT"] ]]();
			break;
	}

	if ( isJuggernaut() )
		[[ game[team + "_model"]["JUGGERNAUT"] ]]();
}
