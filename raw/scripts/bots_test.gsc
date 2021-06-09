#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;
#include maps\mp\bots\_bot_utility;

init()
{
	setDvarIfUninitialized( "bots_test", true );

	if (!getDvarInt("bots_test"))
		return;

	level thread onConnected();
	level thread onframe();
}

onframe()
{
	for(;;)
	{
		wait 0.05;

		if(getDvarInt("developer")) print("time:" + getTime() + "  child0:" + getVarUsage(0) + "  child1:" + getVarUsage(1) + "  notifycount:" + getVarUsage(2) + "  sound:" + getVarUsage(3, 2140) + "  fx:" + getVarUsage(3, 2780) + "  vol:" + getVarUsage(3, 3036) + "  anim:" + getVarUsage(3, 3681) + "  veh:" + getVarUsage(3, 2108) + "  localstr:" + getVarUsage(3, 469) + "  mat:" + getVarUsage(3, 3084) + "  3340:" + getVarUsage(3, 3340) + "  2524:" + getVarUsage(3, 2524));
	}
}

onConnected()
{
	for (;;)
	{
		level waittill("connected", player);

		player thread test();
		player thread onSpawn();
	}
}

onSpawn()
{
	self endon("disconnect");

	for (;;)
	{
		self waittill("spawned_player");

		self thread spawned();
	}
}

giveAllKillstreaks()
{
	killstreaks = maps\mp\bots\_bot_script::getKillstreaks();

	for ( i = 0; i < killstreaks.size; i++ )
	{
		j = randomInt(killstreaks.size);
		ks = killstreaks[i];
		killstreaks[i] = killstreaks[j];
		killstreaks[j] = ks;
	}

	for (i = 0; i < killstreaks.size; i++)
	{
		ks = killstreaks[i];

		if (isSubstr(ks, "specialty_"))
			continue;

		self maps\mp\killstreaks\_killstreaks::giveKillstreak(ks);
	}
}

spawned()
{
	self endon("disconnect");
	self endon("death");

	wait 0.5;

	//self giveAllKillstreaks();
}

test()
{
	self endon("disconnect");

	for (;;)
	{
		wait 0.05;

		if (self is_bot())
		{
		}
		else
		{
		}
	}
}
