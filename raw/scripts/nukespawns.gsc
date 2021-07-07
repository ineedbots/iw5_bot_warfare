init()
{
  level thread watchNuke();

	level thread onPlayerConnect();

	level.killstreakPrint = 2;
	level.allowPrintDamage = true;
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

	self.printDamage = true;

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
		wait 0.05;

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
