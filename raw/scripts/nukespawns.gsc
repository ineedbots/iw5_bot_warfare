init()
{
  level thread watchNuke();

	level thread onPlayerConnect();

	level thread hook_callbacks();

	level.killstreakPrint = 2;
}

doPrintDamage(dmg, hitloc)
{
	huddamage = newclienthudelem(self);
  huddamage.alignx = "center";
  huddamage.horzalign = "center";
  huddamage.x = 10;
  huddamage.y = 235;
  huddamage.fontscale = 1.6;
  huddamage.font = "objective";
  huddamage setvalue(dmg);

  if (hitloc == "head")
    huddamage.color = (1, 1, 0.25);

  huddamage moveovertime(1);
  huddamage fadeovertime(1);
  huddamage.alpha = 0;
  huddamage.x = randomIntRange(25, 70);

	val = 1;
	if (randomInt(2))
		val = -1;
	
  huddamage.y = 235 + randomIntRange(25, 70) * val;

  wait 1;

	huddamage destroy();
}

onPlayerDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset )
{
	self [[level.prevCallbackPlayerDamage2]]( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset );

	if ( isDefined( eAttacker ) && isPlayer( eAttacker ) )
		eAttacker thread doPrintDamage(iDamage, sHitLoc);
	else if( isDefined( eAttacker.owner ) && isPlayer( eAttacker.owner ) )
		eAttacker.owner thread doPrintDamage(iDamage, sHitLoc);
}

hook_callbacks()
{
	level waittill( "prematch_over" );
	wait 0.1;

	level.prevCallbackPlayerDamage2 = level.callbackPlayerDamage;
	level.callbackPlayerDamage = ::onPlayerDamage;
}

onPlayerConnect()
{
	for (;;)
	{
		level waittill("connected", player);

		player thread onChangeKit();
	}
}

watchNuke()
{
	setDvar("scr_spawnpointfavorweight", "");
	level waittill( "nuke_death" );
	setDvar("scr_spawnpointfavorweight", "499999");
}

onChangeKit()
{
	self endon("disconnect");

	for (;;)
	{
		self waittill("changed_kit");

		self thread watchNotifyKSMessage();
	}
}

watchNotifyKSMessage()
{
	self endon("disconnect");
	self endon("changed_kit");

	for (lastKs = self.pers["cur_kill_streak_for_nuke"];;)
	{
		self waittill( "killed_enemy" );

		for (curStreak = lastKs + 1; curStreak <= self.pers["cur_kill_streak_for_nuke"]; curStreak++)
		{
			//if (curStreak == 5)
			//	continue;

			if (curStreak % 5 != 0)
				continue;

			self thread streakNotify(curStreak);
		}

		lastKs = self.pers["cur_kill_streak_for_nuke"];
	}
}

streakNotify( streakVal )
{
	self endon( "disconnect" );

	notifyData = spawnStruct();

	if (level.killstreakPrint > 1)
	{
		xpReward = streakVal * 100;

		self thread maps\mp\gametypes\_rank::giveRankXP( "killstreak_bonus", xpReward );

		notifyData.notifyText = "+" + xpReward;
	}

	wait .05;

	notifyData.titleLabel = &"MP_KILLSTREAK_N";
	notifyData.titleText = streakVal;
	
	self maps\mp\gametypes\_hud_message::notifyMessage( notifyData );
	
	iprintln( &"RANK_KILL_STREAK_N", self, streakVal );
}
