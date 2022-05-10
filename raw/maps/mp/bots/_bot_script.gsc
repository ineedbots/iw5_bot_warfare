/*
	_bot_script
	Author: INeedGames
	Date: 05/11/2021
	Tells the bots what to do.
	Similar to t5's _bot
*/

#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\bots\_bot_utility;

/*
	When the bot gets added into the game.
*/
added()
{
	self endon( "disconnect" );

	self setPlayerData( "experience", self bot_get_rank() );
	self setPlayerData( "prestige", self bot_get_prestige() );

	self setPlayerData( "cardTitle", random( getCardTitles() ) );
	self setPlayerData( "cardIcon", random( getCardIcons() ) );

	self setClasses();

	self set_diff();
}

/*
	When the bot connects to the game.
*/
connected()
{
	self endon( "disconnect" );

	self.killerLocation = undefined;
	self.lastKiller = undefined;
	self.bot_change_class = true;

	self thread difficulty();
	self thread teamWatch();
	self thread classWatch();

	self thread onBotSpawned();
	self thread onSpawned();

	self thread onDeath();
	self thread onGiveLoadout();

	self thread onKillcam();

	wait 4;
	self.challengeData = []; // iw5 is bad lmao
}

/*
	Gets the prestige
*/
bot_get_prestige()
{
	p_dvar = getDvarInt( "bots_loadout_prestige" );
	p = 0;

	if ( p_dvar == -1 )
	{
		for ( i = 0; i < level.players.size; i++ )
		{
			player = level.players[i];

			if ( !isDefined( player.team ) )
				continue;

			if ( player is_bot() )
				continue;

			p = player getPlayerData( "prestige" );
			break;
		}
	}
	else if ( p_dvar == -2 )
	{
		p = randomInt( 12 );
	}
	else
	{
		p = p_dvar;
	}

	return p;
}

/*
	Gets an exp amount for the bot that is nearish the host's xp.
*/
bot_get_rank()
{
	rank = 1;
	rank_dvar = getDvarInt( "bots_loadout_rank" );

	if ( rank_dvar == -1 )
	{
		ranks = [];
		bot_ranks = [];
		human_ranks = [];

		for ( i = level.players.size - 1; i >= 0; i-- )
		{
			player = level.players[i];

			if ( player == self )
				continue;

			if ( !IsDefined( player.pers[ "rank" ] ) )
				continue;

			if ( player is_bot() )
			{
				bot_ranks[ bot_ranks.size ] = player.pers[ "rank" ];
			}
			else
			{
				human_ranks[ human_ranks.size ] = player.pers[ "rank" ];
			}
		}

		if ( !human_ranks.size )
			human_ranks[ human_ranks.size ] = Round( random_normal_distribution( 45, 20, 0, level.maxRank ) );

		human_avg = array_average( human_ranks );

		while ( bot_ranks.size + human_ranks.size < 5 )
		{
			// add some random ranks for better random number distribution
			rank = human_avg + RandomIntRange( -10, 10 );
			human_ranks[ human_ranks.size ] = rank;
		}

		ranks = array_combine( human_ranks, bot_ranks );

		avg = array_average( ranks );
		s = array_std_deviation( ranks, avg );

		rank = Round( random_normal_distribution( avg, s, 0, level.maxRank ) );
	}
	else if ( rank_dvar == 0 )
	{
		rank = Round( random_normal_distribution( 45, 20, 0, level.maxRank ) );
	}
	else
	{
		rank = Round( random_normal_distribution( rank_dvar, 5, 0, level.maxRank ) );
	}

	return maps\mp\gametypes\_rank::getRankInfoMinXP( rank );
}

/*
	returns an array of all card titles
*/
getCardTitles()
{
	cards = [];

	for ( i = 0; i < 600; i++ )
	{
		card_name = tableLookupByRow( "mp/cardTitleTable.csv", i, 0 );

		if ( card_name == "" )
			continue;

		if ( !isSubStr( card_name, "cardtitle_" ) )
			continue;

		cards[cards.size] = i;
	}

	return cards;
}

/*
	returns an array of all card icons
*/
getCardIcons()
{
	cards = [];

	for ( i = 0; i < 400; i++ )
	{
		card_name = tableLookupByRow( "mp/cardIconTable.csv", i, 0 );

		if ( card_name == "" )
			continue;

		if ( !isSubStr( card_name, "cardicon_" ) )
			continue;

		cards[cards.size] = i;
	}

	return cards;
}

/*
	returns if attachment is valid with attachment 2
*/
isValidAttachmentCombo( att1, att2 )
{
	colIndex = tableLookupRowNum( "mp/attachmentCombos.csv", 0, att1 );

	if ( tableLookup( "mp/attachmentCombos.csv", 0, att2, colIndex ) == "no" )
		return false;

	return true;
}

/*
	returns all attachments for the given gun
*/
getAttachmentsForGun( gun )
{
	row = tableLookupRowNum( "mp/statStable.csv", 4, gun );

	attachments = [];

	for ( h = 0; h < 10; h++ )
	{
		attachmentName = tableLookupByRow( "mp/statStable.csv", row, h + 11 );

		if ( attachmentName == "" )
		{
			attachments[attachments.size] = "none";
			break;
		}

		attachments[attachments.size] = attachmentName;
	}

	return attachments;
}

/*
	returns all primaries
*/
getPrimaries()
{
	primaries = [];

	for ( i = 0; i < 160; i++ )
	{
		weapon_type = tableLookupByRow( "mp/statstable.csv", i, 2 );

		if ( weapon_type != "weapon_assault" && weapon_type != "weapon_riot" && weapon_type != "weapon_smg" && weapon_type != "weapon_sniper" && weapon_type != "weapon_lmg" && weapon_type != "weapon_shotgun" )
			continue;

		weapon_name = tableLookupByRow( "mp/statstable.csv", i, 4 );

		if ( isSubStr( weapon_name, "jugg" ) )
			continue;

		primaries[primaries.size] = weapon_name;
	}

	return primaries;
}

/*
	returns all secondaries
*/
getSecondaries()
{
	secondaries = [];

	for ( i = 0; i < 160; i++ )
	{
		weapon_type = tableLookupByRow( "mp/statstable.csv", i, 2 );

		if ( weapon_type != "weapon_pistol" && weapon_type != "weapon_machine_pistol" && weapon_type != "weapon_projectile" )
			continue;

		weapon_name = tableLookupByRow( "mp/statstable.csv", i, 4 );

		if ( weapon_name == "gl" || isSubStr( weapon_name, "jugg" ) )
			continue;

		secondaries[secondaries.size] = weapon_name;
	}

	return secondaries;
}

/*
	returns all camos
*/
getCamos()
{
	camos = [];

	for ( i = 0; i < 15; i++ )
	{
		camo_name = tableLookupByRow( "mp/camoTable.csv", i, 1 );

		if ( camo_name == "" )
			continue;

		camos[camos.size] = camo_name;
	}

	return camos;
}

/*
	returns all reticles
*/
getReticles()
{
	reticles = [];

	for ( i = 0; i < 10; i++ )
	{
		reticle_name = tableLookupByRow( "mp/reticletable.csv", i, 1 );

		if ( reticle_name == "" )
			continue;

		reticles[reticles.size] = reticle_name;
	}

	return reticles;
}

/*
	returns all perks for the given type
*/
getPerks( perktype )
{
	perks = [];

	for ( i = 0; i < 100; i++ )
	{
		perk_type = tableLookupByRow( "mp/perktable.csv", i, 5 );

		if ( perk_type != perktype )
			continue;

		perk_name = tableLookupByRow( "mp/perktable.csv", i, 1 );

		if ( perk_name == "specialty_uav" )
			continue;

		perks[perks.size] = perk_name;
	}

	return perks;
}

/*
	returns kill cost for a streak
*/
getKillsNeededForStreak( streak )
{
	return int( tableLookup( "mp/killstreakTable.csv", 1, streak, 4 ) );
}

/*
	returns all killstreaks
*/
getKillstreaks()
{
	killstreaks = [];

	for ( i = 0; i < 65; i++ )
	{
		streak_name = tableLookupByRow( "mp/killstreakTable.csv", i, 1 );

		if ( streak_name == "" || streak_name == "none" )
			continue;

		if ( streak_name == "b1" )
			continue;

		if ( streak_name == "sentry" || streak_name == "remote_tank" || streak_name == "nuke" || streak_name == "all_perks_bonus" ) // theres an airdrop version
			continue;

		if ( isSubstr( streak_name, "specialty_" ) && isSubstr( streak_name, "_pro" ) )
			continue;

		killstreaks[killstreaks.size] = streak_name;
	}

	return killstreaks;
}

/*
	Returns the weapon buffs for a given weapon type
*/
getWeaponProfs( weapClass )
{
	answer = [];

	if ( weapClass == "weapon_assault" )
	{
		answer[answer.size] = "specialty_bling";
		answer[answer.size] = "specialty_bulletpenetration";
		answer[answer.size] = "specialty_marksman";
		answer[answer.size] = "specialty_sharp_focus";
		answer[answer.size] = "specialty_holdbreathwhileads";
		answer[answer.size] = "specialty_reducedsway";
	}
	else if ( weapClass == "weapon_smg" )
	{
		answer[answer.size] = "specialty_bling";
		answer[answer.size] = "specialty_marksman";
		answer[answer.size] = "specialty_sharp_focus";
		answer[answer.size] = "specialty_reducedsway";
		answer[answer.size] = "specialty_longerrange";
		answer[answer.size] = "specialty_fastermelee";
	}
	else if ( weapClass == "weapon_lmg" )
	{
		answer[answer.size] = "specialty_bling";
		answer[answer.size] = "specialty_bulletpenetration";
		answer[answer.size] = "specialty_marksman";
		answer[answer.size] = "specialty_sharp_focus";
		answer[answer.size] = "specialty_reducedsway";
		answer[answer.size] = "specialty_lightweight";
	}
	else if ( weapClass == "weapon_sniper" )
	{
		answer[answer.size] = "specialty_bling";
		answer[answer.size] = "specialty_bulletpenetration";
		answer[answer.size] = "specialty_marksman";
		answer[answer.size] = "specialty_sharp_focus";
		answer[answer.size] = "specialty_reducedsway";
		answer[answer.size] = "specialty_lightweight";
	}
	else if ( weapClass == "weapon_shotgun" )
	{
		answer[answer.size] = "specialty_bling";
		answer[answer.size] = "specialty_marksman";
		answer[answer.size] = "specialty_sharp_focus";
		answer[answer.size] = "specialty_longerrange";
		answer[answer.size] = "specialty_fastermelee";
		answer[answer.size] = "specialty_moredamage";
	}
	else if ( weapClass == "weapon_riot" )
	{
		answer[answer.size] = "specialty_fastermelee";
		answer[answer.size] = "specialty_lightweight";
	}

	return answer;
}

/*
	Returns the level for unlocking the item
*/
getUnlockLevel( forWhat )
{
	return int( tableLookup( "mp/unlocktable.csv", 0, forWhat, 2 ) );
}

/*
	bots chooses a random perk
*/
chooseRandomPerk( perkkind )
{
	perks = getPerks( perkkind );
	rank = self maps\mp\gametypes\_rank::getRankForXp( self getPlayerData( "experience" ) );
	allowOp = ( getDvarInt( "bots_loadout_allow_op" ) >= 1 );
	reasonable = getDvarInt( "bots_loadout_reasonable" );

	while ( true )
	{
		perk = random( perks );

		if ( !allowOp )
		{
			if ( perkkind == "perk4" )
				return "specialty_null";

			if ( perk == "specialty_coldblooded" || perk == "specialty_blindeye" || perk == "specialty_quieter" )
				continue;

			if ( perk == "streaktype_specialist" || perk == "streaktype_support" )
				continue;
		}

		if ( reasonable )
		{
		}

		if ( perk == "specialty_null" )
			continue;

		if ( !self isItemUnlocked( perk ) )
			continue;

		if ( rank < getUnlockLevel( perk ) )
			continue;

		if ( RandomFloatRange( 0, 1 ) < ( ( rank / level.maxRank ) + 0.1 ) )
			self.pers["bots"]["unlocks"]["upgraded_" + perk] = true;

		return perk;
	}
}

/*
	choose a random camo
*/
chooseRandomCamo()
{
	camos = getCamos();

	while ( true )
	{
		camo = random( camos );

		return camo;
	}
}

/*
	choose a random camo
*/
chooseRandomReticle()
{
	reticles = getReticles();

	while ( true )
	{
		reticle = random( reticles );

		return reticle;
	}
}

/*
	choose a random primary
*/
chooseRandomPrimary()
{
	primaries = getPrimaries();
	allowOp = ( getDvarInt( "bots_loadout_allow_op" ) >= 1 );
	reasonable = getDvarInt( "bots_loadout_reasonable" );
	rank = self maps\mp\gametypes\_rank::getRankForXp( self getPlayerData( "experience" ) );

	while ( true )
	{
		primary = random( primaries );

		if ( !allowOp )
		{
			if ( primary == "riotshield" )
				continue;
		}

		if ( reasonable )
		{
			if ( primary == "riotshield" )
				continue;
		}

		if ( !self isItemUnlocked( primary ) )
			continue;

		if ( rank < getUnlockLevel( primary ) )
			continue;

		return primary;
	}
}

/*
	choose a random secondary
*/
chooseRandomSecondary()
{
	secondaries = getSecondaries();
	allowOp = ( getDvarInt( "bots_loadout_allow_op" ) >= 1 );
	reasonable = getDvarInt( "bots_loadout_reasonable" );
	rank = self maps\mp\gametypes\_rank::getRankForXp( self getPlayerData( "experience" ) );

	while ( true )
	{
		secondary = random( secondaries );

		if ( !allowOp )
		{
			if ( secondary == "iw5_smaw" || secondary == "rpg" || secondary == "m320" || secondary == "xm25" )
				continue;
		}

		if ( reasonable )
		{
		}

		if ( !self isItemUnlocked( secondary ) )
			continue;

		if ( rank < getUnlockLevel( secondary ) )
			continue;

		return secondary;
	}
}

/*
	Returns a random buff for a weapon
*/
chooseRandomBuff( weap )
{
	buffs = getWeaponProfs( getWeaponClass( weap ) );
	rank = self maps\mp\gametypes\_rank::getRankForXp( self getPlayerData( "experience" ) );
	allowOp = ( getDvarInt( "bots_loadout_allow_op" ) >= 1 );
	reasonable = getDvarInt( "bots_loadout_reasonable" );

	buffs[buffs.size] = "specialty_null";

	if ( RandomFloatRange( 0, 1 ) >= ( ( rank / level.maxRank ) + 0.1 ) )
	{
		return "specialty_null";
	}

	while ( true )
	{
		buff = random( buffs );

		return buff;
	}
}

/*
	chooses random attachements for a gun
*/
chooseRandomAttachmentComboForGun( gun )
{
	atts = getAttachmentsForGun( gun );
	rank = self maps\mp\gametypes\_rank::getRankForXp( self getPlayerData( "experience" ) );
	allowOp = ( getDvarInt( "bots_loadout_allow_op" ) >= 1 );
	reasonable = getDvarInt( "bots_loadout_reasonable" );

	if ( RandomFloatRange( 0, 1 ) >= ( ( rank / level.maxRank ) + 0.1 ) )
	{
		retAtts = [];
		retAtts[0] = "none";
		retAtts[1] = "none";

		return retAtts;
	}

	while ( true )
	{
		att1 = random( atts );
		att2 = random( atts );

		if ( !isValidAttachmentCombo( att1, att2 ) )
			continue;

		if ( !allowOp )
		{
			if ( att1 == "gl" || att2 == "gl" || att1 == "gp25" || att2 == "gp25" || att1 == "m320" || att2 == "m320" )
				continue;
		}

		if ( reasonable )
		{
		}

		retAtts = [];
		retAtts[0] = att1;
		retAtts[1] = att2;

		return retAtts;
	}
}

/*
	choose a random tacticle grenade
*/
chooseRandomTactical()
{
	perks = getPerks( "equipment" );
	allowOp = ( getDvarInt( "bots_loadout_allow_op" ) >= 1 );
	reasonable = getDvarInt( "bots_loadout_reasonable" );
	rank = self maps\mp\gametypes\_rank::getRankForXp( self getPlayerData( "experience" ) );

	while ( true )
	{
		perk = random( perks );

		if ( !allowOp )
		{
		}

		if ( reasonable )
		{
		}

		if ( perk == "specialty_null" )
			continue;

		if ( !maps\mp\gametypes\_class::isValidOffhand( perk ) )
			continue;

		if ( !self isItemUnlocked( perk ) )
			continue;

		if ( rank < getUnlockLevel( perk ) )
			continue;

		return perk;
	}
}

/*
	Choose a random grenade
*/
chooseRandomGrenade()
{
	perks = getPerks( "equipment" );
	allowOp = ( getDvarInt( "bots_loadout_allow_op" ) >= 1 );
	rank = self maps\mp\gametypes\_rank::getRankForXp( self getPlayerData( "experience" ) );
	reasonable = getDvarInt( "bots_loadout_reasonable" );

	while ( true )
	{
		perk = random( perks );

		if ( !allowOp )
		{
		}

		if ( reasonable )
		{
		}

		if ( perk == "specialty_null" )
			continue;

		if ( !maps\mp\gametypes\_class::isValidEquipment( perk ) )
			continue;

		if ( perk == "specialty_portable_radar" )
			continue;

		if ( !self isItemUnlocked( perk ) )
			continue;

		if ( rank < getUnlockLevel( perk ) )
			continue;

		return perk;
	}
}

/*
	Choose a random killstreak set
*/
chooseRandomKillstreaks( type, perks )
{
	answers = [];
	allStreaks = getKillstreaks();
	rank = self maps\mp\gametypes\_rank::getRankForXp( self getPlayerData( "experience" ) ) + 1;
	allowOp = ( getDvarInt( "bots_loadout_allow_op" ) >= 1 );
	reasonable = getDvarInt( "bots_loadout_reasonable" );
	chooseStreaks = [];

	availUnlocks = 0;

	if ( rank >= 7 )
		availUnlocks++;

	if ( rank >= 10 )
		availUnlocks++;

	if ( rank >= 13 )
		availUnlocks++;

	for ( ;; )
	{
		streak = random( allStreaks );

		if ( isDefined( chooseStreaks[streak] ) )
			continue;

		if ( type == "streaktype_specialist" )
		{
			if ( !isSubStr( streak, "specialty_" ) )
				continue;

			perk = strTok( streak, "_ks" )[0];

			if ( !self isItemUnlocked( perk ) )
				continue;

			if ( isDefined( perks[perk] ) )
				continue;
		}
		else
		{
			if ( availUnlocks <= 0 )
			{
				for ( i = ( 3 - answers.size - 1 ); i >= 0; i-- )
				{
					if ( type == "streaktype_support" )
					{
						if ( i == 2 )
							answers[answers.size] = "uav_support";
						else if ( i == 1 )
							answers[answers.size] = "sam_turret";
						else
							answers[answers.size] = "triple_uav";
					}
					else
					{
						if ( i == 2 )
							answers[answers.size] = "uav";
						else if ( i == 1 )
							answers[answers.size] = "predator_missile";
						else
							answers[answers.size] = "helicopter";
					}
				}

				break;
			}

			if ( isSubStr( streak, "specialty_" ) )
				continue;

			if ( isColidingKillstreak( answers, streak ) )
				continue;

			if ( type == "streaktype_support" )
			{
				if ( !maps\mp\killstreaks\_killstreaks::isSupportKillstreak( streak ) )
					continue;
			}
			else
			{
				if ( !maps\mp\killstreaks\_killstreaks::isAssaultKillstreak( streak ) )
					continue;
			}
		}

		answers[answers.size] = streak;
		chooseStreaks[streak] = true;
		availUnlocks--;

		if ( answers.size > 2 )
			break;
	}

	return answers;
}

/*
	returns if killstreak is going to have the same kill cost
*/
isColidingKillstreak( killstreaks, killstreak )
{
	ksVal = getKillsNeededForStreak( killstreak );

	for ( i = 0; i < killstreaks.size; i++ )
	{
		ks = killstreaks[i];

		if ( ks == "" )
			continue;

		if ( ks == "none" )
			continue;

		ksV = getKillsNeededForStreak( ks );

		if ( ksV <= 0 )
			continue;

		if ( ksV != ksVal )
			continue;

		return true;
	}

	return false;
}

/*
	sets up all classes for a bot
*/
setClasses()
{
	n = 5;

	if ( !self is_bot() )
		n = 15;

	rank = self maps\mp\gametypes\_rank::getRankForXp( self getPlayerData( "experience" ) );

	if ( RandomFloatRange( 0, 1 ) < ( ( rank / level.maxRank ) + 0.1 ) )
	{
		self.pers["bots"]["unlocks"]["ghillie"] = true;
		self.pers["bots"]["behavior"]["quickscope"] = true;
	}

	whereToSave = "customClasses";

	if ( getDvarInt( "xblive_privatematch" ) )
		whereToSave = "privateMatchCustomClasses";

	for ( i = 0; i < n; i++ )
	{
		primary = chooseRandomPrimary();
		primaryBuff = chooseRandomBuff( primary );
		primaryAtts = chooseRandomAttachmentComboForGun( primary );
		primaryReticle = chooseRandomReticle();
		primaryCamo = chooseRandomCamo();

		perk2 = chooseRandomPerk( "perk2" );

		secondary = chooseRandomSecondary();

		if ( perk2 == "specialty_twoprimaries" )
		{
			secondary = chooseRandomPrimary();

			while ( secondary == primary )
				secondary = chooseRandomPrimary();
		}

		secondaryBuff = chooseRandomBuff( secondary );
		secondaryAtts = chooseRandomAttachmentComboForGun( secondary );
		secondaryReticle = chooseRandomReticle();
		secondaryCamo = chooseRandomCamo();

		if ( perk2 != "specialty_twoprimaries" )
		{
			secondaryReticle = "none";
			secondaryCamo = "none";
			secondaryAtts[1] = "none";
		}
		else if ( !isDefined( self.pers["bots"]["unlocks"]["upgraded_specialty_twoprimaries"] ) )
		{
			secondaryAtts[0] = "none";
			secondaryAtts[1] = "none";
		}

		perk1 = chooseRandomPerk( "perk1" );
		perk3 = chooseRandomPerk( "perk3" );
		deathstreak = chooseRandomPerk( "perk4" );
		equipment = chooseRandomGrenade();
		tactical = chooseRandomTactical();

		perks = [];
		perks[perk1] = true;
		perks[perk2] = true;
		perks[perk3] = true;

		ksType = chooseRandomPerk( "perk5" );
		killstreaks = chooseRandomKillstreaks( ksType, perks );

		self setPlayerData( whereToSave, i, "weaponSetups", 0, "weapon", primary );
		self setPlayerData( whereToSave, i, "weaponSetups", 0, "attachment", 0, primaryAtts[0] );
		self setPlayerData( whereToSave, i, "weaponSetups", 0, "attachment", 1, primaryAtts[1] );
		self setPlayerData( whereToSave, i, "weaponSetups", 0, "camo", primaryCamo );
		self setPlayerData( whereToSave, i, "weaponSetups", 0, "reticle", primaryReticle );
		self setPlayerData( whereToSave, i, "weaponSetups", 0, "buff", primaryBuff );

		self setPlayerData( whereToSave, i, "weaponSetups", 1, "weapon", secondary );
		self setPlayerData( whereToSave, i, "weaponSetups", 1, "attachment", 0, secondaryAtts[0] );
		self setPlayerData( whereToSave, i, "weaponSetups", 1, "attachment", 1, secondaryAtts[1] );
		self setPlayerData( whereToSave, i, "weaponSetups", 1, "camo", secondaryCamo );
		self setPlayerData( whereToSave, i, "weaponSetups", 1, "reticle", secondaryReticle );
		self setPlayerData( whereToSave, i, "weaponSetups", 1, "buff", secondaryBuff );

		self setPlayerData( whereToSave, i, "perks", 0, equipment );
		self setPlayerData( whereToSave, i, "perks", 1, perk1 );
		self setPlayerData( whereToSave, i, "perks", 2, perk2 );
		self setPlayerData( whereToSave, i, "perks", 3, perk3 );
		self setPlayerData( whereToSave, i, "deathstreak", deathstreak );
		self setPlayerData( whereToSave, i, "perks", 6, tactical );

		self setPlayerData( whereToSave, i, "perks", 5, ksType );

		playerData = undefined;

		switch ( ksType )
		{
			case "streaktype_support":
				playerData = "defenseStreaks";
				break;

			case "streaktype_specialist":
				playerData = "specialistStreaks";
				break;

			default:
				playerData = "assaultStreaks";
				break;
		}

		self setPlayerData( whereToSave, i, playerData, 0, killstreaks[0] );
		self setPlayerData( whereToSave, i, playerData, 1, killstreaks[1] );
		self setPlayerData( whereToSave, i, playerData, 2, killstreaks[2] );
	}
}

/*
	The callback for when the bot gets killed.
*/
onKilled( eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration )
{
	self.killerLocation = undefined;
	self.lastKiller = undefined;

	if ( !IsDefined( self ) || !isDefined( self.team ) )
		return;

	if ( sMeansOfDeath == "MOD_FALLING" || sMeansOfDeath == "MOD_SUICIDE" )
		return;

	if ( iDamage <= 0 )
		return;

	if ( !IsDefined( eAttacker ) || !isDefined( eAttacker.team ) )
		return;

	if ( eAttacker == self )
		return;

	if ( level.teamBased && eAttacker.team == self.team )
		return;

	if ( !IsDefined( eInflictor ) || eInflictor.classname != "player" )
		return;

	if ( !isAlive( eAttacker ) )
		return;

	self.killerLocation = eAttacker.origin;
	self.lastKiller = eAttacker;
}

/*
	The callback for when the bot gets damaged.
*/
onDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset )
{
	if ( !IsDefined( self ) || !isDefined( self.team ) )
		return;

	if ( !isAlive( self ) )
		return;

	if ( sMeansOfDeath == "MOD_FALLING" || sMeansOfDeath == "MOD_SUICIDE" )
		return;

	if ( iDamage <= 0 )
		return;

	if ( !IsDefined( eAttacker ) || !isDefined( eAttacker.team ) )
		return;

	if ( eAttacker == self )
		return;

	if ( level.teamBased && eAttacker.team == self.team )
		return;

	if ( !IsDefined( eInflictor ) || eInflictor.classname != "player" )
		return;

	if ( !isAlive( eAttacker ) )
		return;

	if ( !isSubStr( sWeapon, "_silencer" ) )
		self bot_cry_for_help( eAttacker );

	self SetAttacker( eAttacker );
}

/*
	When the bot gets attacked, have the bot ask for help from teammates.
*/
bot_cry_for_help( attacker )
{
	if ( !level.teamBased )
	{
		return;
	}

	theTime = GetTime();

	if ( IsDefined( self.help_time ) && theTime - self.help_time < 1000 )
	{
		return;
	}

	self.help_time = theTime;

	for ( i = level.players.size - 1; i >= 0; i-- )
	{
		player = level.players[i];

		if ( !player is_bot() )
		{
			continue;
		}

		if ( !isDefined( player.team ) )
			continue;

		if ( !IsAlive( player ) )
		{
			continue;
		}

		if ( player == self )
		{
			continue;
		}

		if ( player.team != self.team )
		{
			continue;
		}

		dist = player.pers["bots"]["skill"]["help_dist"];
		dist *= dist;

		if ( DistanceSquared( self.origin, player.origin ) > dist )
		{
			continue;
		}

		if ( RandomInt( 100 ) < 50 )
		{
			self SetAttacker( attacker );

			if ( RandomInt( 100 ) > 70 )
			{
				break;
			}
		}
	}
}

/*
	watches when the bot enters a killcam
*/
onKillcam()
{
	level endon( "game_ended" );
	self endon( "disconnect" );

	for ( ;; )
	{
		self waittill( "begin_killcam" );

		self thread doKillcamStuff();
	}
}

/*
	bots use copy cat and skip killcams
*/
doKillcamStuff()
{
	self endon( "disconnect" );
	self endon( "killcam_ended" );

	self BotNotifyBotEvent( "killcam", "start" );

	wait 0.5 + randomInt( 3 );

	wait 0.1;

	self notify( "abort_killcam" );

	self BotNotifyBotEvent( "killcam", "stop" );
}

/*
	Selects a class for the bot.
*/
classWatch()
{
	self endon( "disconnect" );

	for ( ;; )
	{
		while ( !isdefined( self.pers["team"] ) || !allowClassChoice() )
			wait .05;

		wait 0.5;

		if ( !isValidClass( self.class ) || !isDefined( self.bot_change_class ) )
			self notify( "menuresponse", game["menu_changeclass"], self chooseRandomClass() );

		self.bot_change_class = true;

		while ( isdefined( self.pers["team"] ) && isValidClass( self.class ) && isDefined( self.bot_change_class ) )
			wait .05;
	}
}

/*
	Any recipe classes
*/
anyMatchRuleDefaultClass( team )
{
	if ( !isUsingMatchRulesData() )
		return false;

	for ( i = 0; i < 5; i++ )
	{
		if ( GetMatchRulesData( "defaultClasses", team, i, "class", "inUse" ) )
			return true;
	}

	return false;
}

/*
	Chooses a random class
*/
chooseRandomClass( )
{
	if ( self.team != "axis" && self.team != "allies" )
		return "";

	reasonable = getDvarInt( "bots_loadout_reasonable" );
	class = "";
	rank = self maps\mp\gametypes\_rank::getRankForXp( self getPlayerData( "experience" ) ) + 1;

	if ( rank < 4 || ( randomInt( 100 ) < 2 && !reasonable ) || ( isUsingMatchRulesData() && !level.matchRules_allowCustomClasses ) )
	{
		while ( class == "" )
		{
			switch ( randomInt( 5 ) )
			{
				case 0:
					if ( isUsingMatchRulesData() && GetMatchRulesData( "defaultClasses", self.team, 0, "class", "inUse" ) )
						class = self.team + "_recipe1";
					else if ( !anyMatchRuleDefaultClass( self.team ) )
						class = "class0";

					break;

				case 1:
					if ( isUsingMatchRulesData() && GetMatchRulesData( "defaultClasses", self.team, 1, "class", "inUse" ) )
						class = self.team + "_recipe2";
					else if ( !anyMatchRuleDefaultClass( self.team ) )
						class = "class1";

					break;

				case 2:
					if ( isUsingMatchRulesData() && GetMatchRulesData( "defaultClasses", self.team, 2, "class", "inUse" ) )
						class = self.team + "_recipe3";
					else if ( !anyMatchRuleDefaultClass( self.team ) )
						class = "class2";

					break;

				case 3:
					if ( isUsingMatchRulesData() && GetMatchRulesData( "defaultClasses", self.team, 3, "class", "inUse" ) )
						class = self.team + "_recipe4";
					else if ( rank >= 2 && !anyMatchRuleDefaultClass( self.team ) )
						class = "class3";

					break;

				case 4:
					if ( isUsingMatchRulesData() && GetMatchRulesData( "defaultClasses", self.team, 4, "class", "inUse" ) )
						class = self.team + "_recipe5";
					else if ( rank >= 3 && !anyMatchRuleDefaultClass( self.team ) )
						class = "class4";

					break;
			}
		}
	}
	else
	{
		class = "custom" + ( randomInt( 5 ) + 1 );
	}

	return class;
}

/*
	Makes sure the bot is on a team.
*/
teamWatch()
{
	self endon( "disconnect" );

	for ( ;; )
	{
		while ( !isdefined( self.pers["team"] ) || !allowTeamChoice() )
			wait .05;

		wait 0.1;

		if ( self.team != "axis" || self.team != "allies" )
			self notify( "menuresponse", game["menu_team"], getDvar( "bots_team" ) );

		while ( isdefined( self.pers["team"] ) )
			wait .05;
	}
}

/*
	Updates the bot's difficulty variables.
*/
difficulty()
{
	self endon( "disconnect" );

	for ( ;; )
	{
		if ( GetDvarInt( "bots_skill" ) != 9 )
		{
			switch ( self.pers["bots"]["skill"]["base"] )
			{
				case 1:
					self.pers["bots"]["skill"]["aim_time"] = 0.6;
					self.pers["bots"]["skill"]["init_react_time"] = 1500;
					self.pers["bots"]["skill"]["reaction_time"] = 1000;
					self.pers["bots"]["skill"]["no_trace_ads_time"] = 500;
					self.pers["bots"]["skill"]["no_trace_look_time"] = 600;
					self.pers["bots"]["skill"]["remember_time"] = 750;
					self.pers["bots"]["skill"]["fov"] = 0.7;
					self.pers["bots"]["skill"]["dist_max"] = 2500;
					self.pers["bots"]["skill"]["dist_start"] = 1000;
					self.pers["bots"]["skill"]["spawn_time"] = 0.75;
					self.pers["bots"]["skill"]["help_dist"] = 0;
					self.pers["bots"]["skill"]["semi_time"] = 0.9;
					self.pers["bots"]["skill"]["shoot_after_time"] = 1;
					self.pers["bots"]["skill"]["aim_offset_time"] = 1.5;
					self.pers["bots"]["skill"]["aim_offset_amount"] = 4;
					self.pers["bots"]["skill"]["bone_update_interval"] = 2;
					self.pers["bots"]["skill"]["bones"] = "j_spineupper,j_ankle_le,j_ankle_ri";
					self.pers["bots"]["skill"]["ads_fov_multi"] = 0.5;
					self.pers["bots"]["skill"]["ads_aimspeed_multi"] = 0.5;

					self.pers["bots"]["behavior"]["strafe"] = 0;
					self.pers["bots"]["behavior"]["nade"] = 10;
					self.pers["bots"]["behavior"]["sprint"] = 30;
					self.pers["bots"]["behavior"]["camp"] = 5;
					self.pers["bots"]["behavior"]["follow"] = 5;
					self.pers["bots"]["behavior"]["crouch"] = 20;
					self.pers["bots"]["behavior"]["switch"] = 2;
					self.pers["bots"]["behavior"]["class"] = 2;
					self.pers["bots"]["behavior"]["jump"] = 0;
					break;

				case 2:
					self.pers["bots"]["skill"]["aim_time"] = 0.55;
					self.pers["bots"]["skill"]["init_react_time"] = 1000;
					self.pers["bots"]["skill"]["reaction_time"] = 800;
					self.pers["bots"]["skill"]["no_trace_ads_time"] = 1000;
					self.pers["bots"]["skill"]["no_trace_look_time"] = 1250;
					self.pers["bots"]["skill"]["remember_time"] = 1500;
					self.pers["bots"]["skill"]["fov"] = 0.65;
					self.pers["bots"]["skill"]["dist_max"] = 3000;
					self.pers["bots"]["skill"]["dist_start"] = 1500;
					self.pers["bots"]["skill"]["spawn_time"] = 0.65;
					self.pers["bots"]["skill"]["help_dist"] = 500;
					self.pers["bots"]["skill"]["semi_time"] = 0.75;
					self.pers["bots"]["skill"]["shoot_after_time"] = 0.75;
					self.pers["bots"]["skill"]["aim_offset_time"] = 1;
					self.pers["bots"]["skill"]["aim_offset_amount"] = 3;
					self.pers["bots"]["skill"]["bone_update_interval"] = 1.5;
					self.pers["bots"]["skill"]["bones"] = "j_spineupper,j_ankle_le,j_ankle_ri,j_head";
					self.pers["bots"]["skill"]["ads_fov_multi"] = 0.5;
					self.pers["bots"]["skill"]["ads_aimspeed_multi"] = 0.5;

					self.pers["bots"]["behavior"]["strafe"] = 10;
					self.pers["bots"]["behavior"]["nade"] = 15;
					self.pers["bots"]["behavior"]["sprint"] = 45;
					self.pers["bots"]["behavior"]["camp"] = 5;
					self.pers["bots"]["behavior"]["follow"] = 5;
					self.pers["bots"]["behavior"]["crouch"] = 15;
					self.pers["bots"]["behavior"]["switch"] = 2;
					self.pers["bots"]["behavior"]["class"] = 2;
					self.pers["bots"]["behavior"]["jump"] = 10;
					break;

				case 3:
					self.pers["bots"]["skill"]["aim_time"] = 0.4;
					self.pers["bots"]["skill"]["init_react_time"] = 750;
					self.pers["bots"]["skill"]["reaction_time"] = 500;
					self.pers["bots"]["skill"]["no_trace_ads_time"] = 1000;
					self.pers["bots"]["skill"]["no_trace_look_time"] = 1500;
					self.pers["bots"]["skill"]["remember_time"] = 2000;
					self.pers["bots"]["skill"]["fov"] = 0.6;
					self.pers["bots"]["skill"]["dist_max"] = 4000;
					self.pers["bots"]["skill"]["dist_start"] = 2250;
					self.pers["bots"]["skill"]["spawn_time"] = 0.5;
					self.pers["bots"]["skill"]["help_dist"] = 750;
					self.pers["bots"]["skill"]["semi_time"] = 0.65;
					self.pers["bots"]["skill"]["shoot_after_time"] = 0.65;
					self.pers["bots"]["skill"]["aim_offset_time"] = 0.75;
					self.pers["bots"]["skill"]["aim_offset_amount"] = 2.5;
					self.pers["bots"]["skill"]["bone_update_interval"] = 1;
					self.pers["bots"]["skill"]["bones"] = "j_spineupper,j_spineupper,j_ankle_le,j_ankle_ri,j_head";
					self.pers["bots"]["skill"]["ads_fov_multi"] = 0.5;
					self.pers["bots"]["skill"]["ads_aimspeed_multi"] = 0.5;

					self.pers["bots"]["behavior"]["strafe"] = 20;
					self.pers["bots"]["behavior"]["nade"] = 20;
					self.pers["bots"]["behavior"]["sprint"] = 50;
					self.pers["bots"]["behavior"]["camp"] = 5;
					self.pers["bots"]["behavior"]["follow"] = 5;
					self.pers["bots"]["behavior"]["crouch"] = 10;
					self.pers["bots"]["behavior"]["switch"] = 2;
					self.pers["bots"]["behavior"]["class"] = 2;
					self.pers["bots"]["behavior"]["jump"] = 25;
					break;

				case 4:
					self.pers["bots"]["skill"]["aim_time"] = 0.3;
					self.pers["bots"]["skill"]["init_react_time"] = 600;
					self.pers["bots"]["skill"]["reaction_time"] = 400;
					self.pers["bots"]["skill"]["no_trace_ads_time"] = 1500;
					self.pers["bots"]["skill"]["no_trace_look_time"] = 2000;
					self.pers["bots"]["skill"]["remember_time"] = 3000;
					self.pers["bots"]["skill"]["fov"] = 0.55;
					self.pers["bots"]["skill"]["dist_max"] = 5000;
					self.pers["bots"]["skill"]["dist_start"] = 3350;
					self.pers["bots"]["skill"]["spawn_time"] = 0.35;
					self.pers["bots"]["skill"]["help_dist"] = 1000;
					self.pers["bots"]["skill"]["semi_time"] = 0.5;
					self.pers["bots"]["skill"]["shoot_after_time"] = 0.5;
					self.pers["bots"]["skill"]["aim_offset_time"] = 0.5;
					self.pers["bots"]["skill"]["aim_offset_amount"] = 2;
					self.pers["bots"]["skill"]["bone_update_interval"] = 0.75;
					self.pers["bots"]["skill"]["bones"] = "j_spineupper,j_spineupper,j_ankle_le,j_ankle_ri,j_head,j_head";
					self.pers["bots"]["skill"]["ads_fov_multi"] = 0.5;
					self.pers["bots"]["skill"]["ads_aimspeed_multi"] = 0.5;

					self.pers["bots"]["behavior"]["strafe"] = 30;
					self.pers["bots"]["behavior"]["nade"] = 25;
					self.pers["bots"]["behavior"]["sprint"] = 55;
					self.pers["bots"]["behavior"]["camp"] = 5;
					self.pers["bots"]["behavior"]["follow"] = 5;
					self.pers["bots"]["behavior"]["crouch"] = 10;
					self.pers["bots"]["behavior"]["switch"] = 2;
					self.pers["bots"]["behavior"]["class"] = 2;
					self.pers["bots"]["behavior"]["jump"] = 35;
					break;

				case 5:
					self.pers["bots"]["skill"]["aim_time"] = 0.25;
					self.pers["bots"]["skill"]["init_react_time"] = 500;
					self.pers["bots"]["skill"]["reaction_time"] = 300;
					self.pers["bots"]["skill"]["no_trace_ads_time"] = 2500;
					self.pers["bots"]["skill"]["no_trace_look_time"] = 3000;
					self.pers["bots"]["skill"]["remember_time"] = 4000;
					self.pers["bots"]["skill"]["fov"] = 0.5;
					self.pers["bots"]["skill"]["dist_max"] = 7500;
					self.pers["bots"]["skill"]["dist_start"] = 5000;
					self.pers["bots"]["skill"]["spawn_time"] = 0.25;
					self.pers["bots"]["skill"]["help_dist"] = 1500;
					self.pers["bots"]["skill"]["semi_time"] = 0.4;
					self.pers["bots"]["skill"]["shoot_after_time"] = 0.35;
					self.pers["bots"]["skill"]["aim_offset_time"] = 0.35;
					self.pers["bots"]["skill"]["aim_offset_amount"] = 1.5;
					self.pers["bots"]["skill"]["bone_update_interval"] = 0.5;
					self.pers["bots"]["skill"]["bones"] = "j_spineupper,j_head";
					self.pers["bots"]["skill"]["ads_fov_multi"] = 0.5;
					self.pers["bots"]["skill"]["ads_aimspeed_multi"] = 0.5;

					self.pers["bots"]["behavior"]["strafe"] = 40;
					self.pers["bots"]["behavior"]["nade"] = 35;
					self.pers["bots"]["behavior"]["sprint"] = 60;
					self.pers["bots"]["behavior"]["camp"] = 5;
					self.pers["bots"]["behavior"]["follow"] = 5;
					self.pers["bots"]["behavior"]["crouch"] = 10;
					self.pers["bots"]["behavior"]["switch"] = 2;
					self.pers["bots"]["behavior"]["class"] = 2;
					self.pers["bots"]["behavior"]["jump"] = 50;
					break;

				case 6:
					self.pers["bots"]["skill"]["aim_time"] = 0.2;
					self.pers["bots"]["skill"]["init_react_time"] = 250;
					self.pers["bots"]["skill"]["reaction_time"] = 150;
					self.pers["bots"]["skill"]["no_trace_ads_time"] = 2500;
					self.pers["bots"]["skill"]["no_trace_look_time"] = 4000;
					self.pers["bots"]["skill"]["remember_time"] = 5000;
					self.pers["bots"]["skill"]["fov"] = 0.45;
					self.pers["bots"]["skill"]["dist_max"] = 10000;
					self.pers["bots"]["skill"]["dist_start"] = 7500;
					self.pers["bots"]["skill"]["spawn_time"] = 0.2;
					self.pers["bots"]["skill"]["help_dist"] = 2000;
					self.pers["bots"]["skill"]["semi_time"] = 0.25;
					self.pers["bots"]["skill"]["shoot_after_time"] = 0.25;
					self.pers["bots"]["skill"]["aim_offset_time"] = 0.25;
					self.pers["bots"]["skill"]["aim_offset_amount"] = 1;
					self.pers["bots"]["skill"]["bone_update_interval"] = 0.25;
					self.pers["bots"]["skill"]["bones"] = "j_spineupper,j_head,j_head";
					self.pers["bots"]["skill"]["ads_fov_multi"] = 0.5;
					self.pers["bots"]["skill"]["ads_aimspeed_multi"] = 0.5;

					self.pers["bots"]["behavior"]["strafe"] = 50;
					self.pers["bots"]["behavior"]["nade"] = 45;
					self.pers["bots"]["behavior"]["sprint"] = 65;
					self.pers["bots"]["behavior"]["camp"] = 5;
					self.pers["bots"]["behavior"]["follow"] = 5;
					self.pers["bots"]["behavior"]["crouch"] = 10;
					self.pers["bots"]["behavior"]["switch"] = 2;
					self.pers["bots"]["behavior"]["class"] = 2;
					self.pers["bots"]["behavior"]["jump"] = 75;
					break;

				case 7:
					self.pers["bots"]["skill"]["aim_time"] = 0.1;
					self.pers["bots"]["skill"]["init_react_time"] = 100;
					self.pers["bots"]["skill"]["reaction_time"] = 50;
					self.pers["bots"]["skill"]["no_trace_ads_time"] = 2500;
					self.pers["bots"]["skill"]["no_trace_look_time"] = 4000;
					self.pers["bots"]["skill"]["remember_time"] = 7500;
					self.pers["bots"]["skill"]["fov"] = 0.4;
					self.pers["bots"]["skill"]["dist_max"] = 15000;
					self.pers["bots"]["skill"]["dist_start"] = 10000;
					self.pers["bots"]["skill"]["spawn_time"] = 0.05;
					self.pers["bots"]["skill"]["help_dist"] = 3000;
					self.pers["bots"]["skill"]["semi_time"] = 0.1;
					self.pers["bots"]["skill"]["shoot_after_time"] = 0;
					self.pers["bots"]["skill"]["aim_offset_time"] = 0;
					self.pers["bots"]["skill"]["aim_offset_amount"] = 0;
					self.pers["bots"]["skill"]["bone_update_interval"] = 0.05;
					self.pers["bots"]["skill"]["bones"] = "j_head";
					self.pers["bots"]["skill"]["ads_fov_multi"] = 0.5;
					self.pers["bots"]["skill"]["ads_aimspeed_multi"] = 0.5;

					self.pers["bots"]["behavior"]["strafe"] = 65;
					self.pers["bots"]["behavior"]["nade"] = 65;
					self.pers["bots"]["behavior"]["sprint"] = 70;
					self.pers["bots"]["behavior"]["camp"] = 5;
					self.pers["bots"]["behavior"]["follow"] = 5;
					self.pers["bots"]["behavior"]["crouch"] = 5;
					self.pers["bots"]["behavior"]["switch"] = 2;
					self.pers["bots"]["behavior"]["class"] = 2;
					self.pers["bots"]["behavior"]["jump"] = 90;
					break;
			}
		}

		wait 5;
	}
}

/*
	Sets the bot difficulty.
*/
set_diff()
{
	rankVar = GetDvarInt( "bots_skill" );

	switch ( rankVar )
	{
		case 0:
			self.pers["bots"]["skill"]["base"] = Round( random_normal_distribution( 3.5, 1.75, 1, 7 ) );
			break;

		case 8:
			break;

		case 9:
			self.pers["bots"]["skill"]["base"] = randomIntRange( 1, 7 );
			self.pers["bots"]["skill"]["aim_time"] = 0.05 * randomIntRange( 1, 20 );
			self.pers["bots"]["skill"]["init_react_time"] = 50 * randomInt( 100 );
			self.pers["bots"]["skill"]["reaction_time"] = 50 * randomInt( 100 );
			self.pers["bots"]["skill"]["remember_time"] = 50 * randomInt( 100 );
			self.pers["bots"]["skill"]["no_trace_ads_time"] = 50 * randomInt( 100 );
			self.pers["bots"]["skill"]["no_trace_look_time"] = 50 * randomInt( 100 );
			self.pers["bots"]["skill"]["fov"] = randomFloatRange( -1, 1 );

			randomNum = randomIntRange( 500, 25000 );
			self.pers["bots"]["skill"]["dist_start"] = randomNum;
			self.pers["bots"]["skill"]["dist_max"] = randomNum * 2;

			self.pers["bots"]["skill"]["spawn_time"] = 0.05 * randomInt( 20 );
			self.pers["bots"]["skill"]["help_dist"] = randomIntRange( 500, 25000 );
			self.pers["bots"]["skill"]["semi_time"] = randomFloatRange( 0.05, 1 );
			self.pers["bots"]["skill"]["shoot_after_time"] = randomFloatRange( 0.05, 1 );
			self.pers["bots"]["skill"]["aim_offset_time"] = randomFloatRange( 0.05, 1 );
			self.pers["bots"]["skill"]["aim_offset_amount"] = randomFloatRange( 0.05, 1 );
			self.pers["bots"]["skill"]["bone_update_interval"] = randomFloatRange( 0.05, 1 );
			self.pers["bots"]["skill"]["bones"] = "j_head,j_spineupper,j_ankle_le,j_ankle_ri";

			self.pers["bots"]["behavior"]["strafe"] = randomInt( 100 );
			self.pers["bots"]["behavior"]["nade"] = randomInt( 100 );
			self.pers["bots"]["behavior"]["sprint"] = randomInt( 100 );
			self.pers["bots"]["behavior"]["camp"] = randomInt( 100 );
			self.pers["bots"]["behavior"]["follow"] = randomInt( 100 );
			self.pers["bots"]["behavior"]["crouch"] = randomInt( 100 );
			self.pers["bots"]["behavior"]["switch"] = randomInt( 100 );
			self.pers["bots"]["behavior"]["class"] = randomInt( 100 );
			self.pers["bots"]["behavior"]["jump"] = randomInt( 100 );
			break;

		default:
			self.pers["bots"]["skill"]["base"] = rankVar;
			break;
	}
}

/*
	Allows the bot to spawn when force respawn is disabled
	Watches when the bot dies
*/
onDeath()
{
	self endon( "disconnect" );

	for ( ;; )
	{
		self waittill( "death" );

		self.wantSafeSpawn = true;
		self ClearScriptGoal();
	}
}

/*
	Watches when the bot is given a loadout
*/
onGiveLoadout()
{
	self endon( "disconnect" );

	for ( ;; )
	{
		self waittill( "giveLoadout", team, class, allowCopycat, setPrimarySpawnWeapon );

		if ( !isDefined( team ) )
			team = self.team;

		if ( !isDefined( class ) )
			class = self.class;

		if ( !isDefined( allowCopycat ) )
			allowCopycat = false;

		if ( !isDefined( setPrimarySpawnWeapon ) )
			setPrimarySpawnWeapon = true;

		self botGiveLoadout( team, class, allowCopycat, setPrimarySpawnWeapon );
	}
}

/*
	When the bot spawns.
*/
onSpawned()
{
	self endon( "disconnect" );

	for ( ;; )
	{
		self waittill( "spawned_player" );

		if ( randomInt( 100 ) <= self.pers["bots"]["behavior"]["class"] )
			self.bot_change_class = undefined;

		self.bot_lock_goal = false;
		self.help_time = undefined;
		self.bot_was_follow_script_update = undefined;
		self.bot_stuck_on_carepackage = undefined;

		if ( getDvarInt( "bots_play_obj" ) )
			self thread bot_dom_cap_think();
	}
}

/*
	When the bot spawned, after the difficulty wait. Start the logic for the bot.
*/
onBotSpawned()
{
	self endon( "disconnect" );
	level endon( "game_ended" );

	for ( ;; )
	{
		self waittill( "bot_spawned" );

		self thread start_bot_threads();
	}
}

/*
	Starts all the bot thinking
*/
start_bot_threads()
{
	self endon( "disconnect" );
	level endon( "game_ended" );
	self endon( "death" );

	gameFlagWait( "prematch_done" );

	// inventory usage
	if ( getDvarInt( "bots_play_killstreak" ) )
	{
		self thread bot_killstreak_think();
		self thread bot_box_think();
		self thread bot_watch_use_remote_turret();
	}

	self thread bot_weapon_think();
	self thread doReloadCancel();

	// script targeting
	if ( getDvarInt( "bots_play_target_other" ) )
	{
		self thread bot_target_vehicle();
		self thread bot_equipment_kill_think();
		self thread bot_turret_think();
	}

	// airdrop
	if ( getDvarInt( "bots_play_take_carepackages" ) )
	{
		self thread bot_watch_stuck_on_crate();
		self thread bot_crate_think();
	}

	// awareness
	self thread bot_revenge_think();
	self thread bot_uav_think();
	self thread bot_listen_to_steps();
	self thread follow_target();

	// camp and follow
	if ( getDvarInt( "bots_play_camp" ) )
	{
		self thread bot_think_follow();
		self thread bot_think_camp();
	}

	// nades
	if ( getDvarInt( "bots_play_nade" ) )
	{
		self thread bot_jav_loc_think();
		self thread bot_use_tube_think();
		self thread bot_use_grenade_think();
		self thread bot_use_equipment_think();
		self thread bot_watch_riot_weapons();
		self thread bot_watch_think_mw2(); // bots play mw2
	}

	// obj
	if ( getDvarInt( "bots_play_obj" ) )
	{
		self thread bot_dom_def_think();
		self thread bot_dom_spawn_kill_think();

		self thread bot_hq();

		self thread bot_cap();

		self thread bot_sab();

		self thread bot_sd_defenders();
		self thread bot_sd_attackers();

		self thread bot_dem_attackers();
		self thread bot_dem_defenders();
		self thread bot_dem_overtime();

		self thread bot_gtnw();
		self thread bot_oneflag();
		self thread bot_arena();
		self thread bot_vip();

		self thread bot_conf();
		self thread bot_grnd();
		self thread bot_tdef();

		self thread bot_infect();
	}
}

/*
	Increments the number of bots approching the obj, decrements when needed
	Used for preventing too many bots going to one obj, or unreachable objs
*/
bot_inc_bots( obj, unreach )
{
	level endon( "game_ended" );
	self endon( "bot_inc_bots" );

	if ( !isDefined( obj ) )
		return;

	if ( !isDefined( obj.bots ) )
		obj.bots = 0;

	obj.bots++;

	ret = self waittill_any_return( "death", "disconnect", "bad_path", "goal", "new_goal" );

	if ( isDefined( obj ) && ( ret != "bad_path" || !isDefined( unreach ) ) )
		obj.bots--;
}

/*
	Watches when the bot is touching the obj and calls 'goal'
*/
bots_watch_touch_obj( obj )
{
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon ( "bad_path" );
	self endon ( "goal" );
	self endon ( "new_goal" );

	for ( ;; )
	{
		wait 0.5;

		if ( !isDefined( obj ) )
		{
			self notify( "bad_path" );
			return;
		}

		if ( self IsTouching( obj ) )
		{
			self notify( "goal" );
			return;
		}
	}
}

/*
	Watches while the obj is being carried, calls 'goal' when complete
*/
bot_escort_obj( obj, carrier )
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "goal" );
	self endon( "bad_path" );
	self endon( "new_goal" );

	for ( ;; )
	{
		wait 0.5;

		if ( !isDefined( obj ) )
			break;

		if ( !isDefined( obj.carrier ) || carrier == obj.carrier )
			break;
	}

	self notify( "goal" );
}

/*
	Watches while the obj is not being carried, calls 'goal' when complete
*/
bot_get_obj( obj )
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "goal" );
	self endon( "bad_path" );
	self endon( "new_goal" );

	for ( ;; )
	{
		wait 0.5;

		if ( !isDefined( obj ) )
			break;

		if ( isDefined( obj.carrier ) )
			break;
	}

	self notify( "goal" );
}

/*
	bots will defend their site from a planter/defuser
*/
bot_defend_site( site )
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon( "game_ended" );
	self endon( "goal" );
	self endon( "bad_path" );
	self endon( "new_goal" );

	for ( ;; )
	{
		wait 0.5;

		if ( !site isInUse() )
			break;
	}

	self notify( "bad_path" );
}

/*
	Bots will go plant the bomb
*/
bot_go_plant( plant )
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon( "game_ended" );
	self endon( "goal" );
	self endon( "bad_path" );
	self endon( "new_goal" );

	for ( ;; )
	{
		wait 1;

		if ( level.bombPlanted )
			break;

		if ( self isTouching( plant.trigger ) )
			break;
	}

	if ( level.bombPlanted )
		self notify( "bad_path" );
	else
		self notify( "goal" );
}

/*
	Bots will go defuse the bomb
*/
bot_go_defuse( plant )
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon( "game_ended" );
	self endon( "goal" );
	self endon( "bad_path" );
	self endon( "new_goal" );

	for ( ;; )
	{
		wait 1;

		if ( !level.bombPlanted )
			break;

		if ( self isTouching( plant.trigger ) )
			break;
	}

	if ( !level.bombPlanted )
		self notify( "bad_path" );
	else
		self notify( "goal" );
}

/*
	Fires the bots weapon until told to stop
*/
fire_current_weapon()
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "weapon_change" );
	self endon( "stop_firing_weapon" );

	for ( ;; )
	{
		self thread BotPressAttack( 0.05 );
		wait 0.1;
	}
}

/*
	Changes to the weap
*/
changeToWeapon( weap )
{
	self endon( "disconnect" );
	self endon( "death" );
	level endon( "game_ended" );

	if ( !self HasWeapon( weap ) )
		return false;

	self BotChangeToWeapon( weap );

	if ( self GetCurrentWeapon() == weap )
		return true;

	self waittill_any_timeout( 5, "weapon_change" );

	return ( self GetCurrentWeapon() == weap );
}

/*
	Bots throw the grenade
*/
botThrowGrenade( nade, time )
{
	self endon( "disconnect" );
	self endon( "death" );
	level endon( "game_ended" );

	if ( !self GetAmmoCount( nade ) )
		return false;

	if ( isSecondaryGrenade( nade ) )
		self thread BotPressSmoke( time );
	else
		self thread BotPressFrag( time );

	ret = self waittill_any_timeout( 5, "grenade_fire" );

	return ( ret == "grenade_fire" );
}

/*
	Gets the object thats the closest in the array
*/
bot_array_nearest_curorigin( array )
{
	result = undefined;

	for ( i = 0; i < array.size; i++ )
		if ( !isDefined( result ) || DistanceSquared( self.origin, array[i].curorigin ) < DistanceSquared( self.origin, result.curorigin ) )
			result = array[i];

	return result;
}

/*
	Returns an weapon thats a rocket with ammo
*/
getRocketAmmo()
{
	answer = self getLockonAmmo();

	if ( isDefined( answer ) )
		return answer;

	if ( self getAmmoCount( "rpg_mp" ) )
		answer = "rpg_mp";

	return answer;
}

/*
	Returns a weapon thats lockon with ammo
*/
getLockonAmmo()
{
	answer = undefined;

	if ( self getAmmoCount( "iw5_smaw_mp" ) )
		answer = "iw5_smaw_mp";

	if ( self getAmmoCount( "stinger_mp" ) )
		answer = "stinger_mp";

	if ( self getAmmoCount( "javelin_mp" ) )
		answer = "javelin_mp";

	return answer;
}

/*
	Clears goal when events death
*/
stop_go_target_on_death( tar )
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "new_goal" );
	self endon( "bad_path" );
	self endon( "goal" );

	tar waittill_either( "death", "disconnect" );

	self ClearScriptGoal();
}

/*
	Goes to the target's location if it had one
*/
follow_target()
{
	self endon( "death" );
	self endon( "disconnect" );

	for ( ;; )
	{
		wait 1;

		if ( self HasScriptGoal() || self.bot_lock_goal )
			continue;

		if ( !self HasThreat() )
			continue;

		threat = self GetThreat();

		if ( !isPlayer( threat ) )
			continue;

		if ( randomInt( 100 ) > self.pers["bots"]["behavior"]["follow"] * 5 )
			continue;

		self BotNotifyBotEvent( "follow_threat", "start", threat );

		self SetScriptGoal( threat.origin, 64 );
		self thread stop_go_target_on_death( threat );

		if ( self waittill_any_return( "new_goal", "goal", "bad_path" ) != "new_goal" )
			self ClearScriptGoal();

		self BotNotifyBotEvent( "follow_threat", "stop", threat );
	}
}

/*
	Used so that variables are free'd (in gsc, loops retain their variables they create, eats up child0 vars)
*/
bot_think_camp_loop()
{
	campSpot = getWaypointForIndex( random( self waypointsNear( getWaypointsOfType( "camp" ), 1024 ) ) );

	if ( !isDefined( campSpot ) )
		return;

	self SetScriptGoal( campSpot.origin, 16 );

	time = randomIntRange( 10, 20 );

	self BotNotifyBotEvent( "camp", "go", campSpot, time );

	ret = self waittill_any_return( "new_goal", "goal", "bad_path" );

	if ( ret != "new_goal" )
		self ClearScriptGoal();

	if ( ret != "goal" )
		return;

	self BotNotifyBotEvent( "camp", "start", campSpot, time );

	self thread killCampAfterTime( time );
	self CampAtSpot( campSpot.origin, campSpot.origin + AnglesToForward( campSpot.angles ) * 2048 );

	self BotNotifyBotEvent( "camp", "stop", campSpot, time );
}

/*
	Bot logic for bot determining to camp.
*/
bot_think_camp()
{
	self endon( "death" );
	self endon( "disconnect" );

	for ( ;; )
	{
		wait randomintrange( 4, 7 );

		if ( self HasScriptGoal() || self.bot_lock_goal || self HasScriptAimPos() )
			continue;

		if ( randomInt( 100 ) > self.pers["bots"]["behavior"]["camp"] )
			continue;

		self bot_think_camp_loop();
	}
}

/*
	Kills the camping thread when time
*/
killCampAfterTime( time )
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "kill_camp_bot" );

	wait time + 0.05;
	self ClearScriptGoal();
	self ClearScriptAimPos();

	self notify( "kill_camp_bot" );
}

/*
	Kills the camping thread when ent gone
*/
killCampAfterEntGone( ent )
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "kill_camp_bot" );

	for ( ;; )
	{
		wait 0.05;

		if ( !isDefined( ent ) )
			break;
	}

	self ClearScriptGoal();
	self ClearScriptAimPos();

	self notify( "kill_camp_bot" );
}

/*
	Camps at the spot
*/
CampAtSpot( origin, anglePos )
{
	self endon( "kill_camp_bot" );

	self SetScriptGoal( origin, 64 );

	if ( isDefined( anglePos ) )
	{
		self SetScriptAimPos( anglePos );
	}

	self waittill( "new_goal" );
	self ClearScriptAimPos();

	self notify( "kill_camp_bot" );
}

/*
	Waits for the bot to stop moving
*/
bot_wait_stop_move()
{
	while ( !self isOnGround() || lengthSquared( self getVelocity() ) > 1 )
		wait 0.25;
}

/*
	Loop
*/
bot_think_follow_loop()
{
	follows = [];
	distSq = self.pers["bots"]["skill"]["help_dist"] * self.pers["bots"]["skill"]["help_dist"];

	for ( i = level.players.size - 1; i >= 0; i-- )
	{
		player = level.players[i];

		if ( player == self )
			continue;

		if ( !isReallyAlive( player ) )
			continue;

		if ( player.team != self.team )
			continue;

		if ( DistanceSquared( player.origin, self.origin ) > distSq )
			continue;

		follows[follows.size] = player;
	}

	toFollow = random( follows );
	follows = undefined;

	if ( !isDefined( toFollow ) )
		return;

	time = randomIntRange( 10, 20 );

	self BotNotifyBotEvent( "follow", "start", toFollow, time );

	self thread killFollowAfterTime( time );
	self followPlayer( toFollow );

	self BotNotifyBotEvent( "follow", "stop", toFollow, time );
}

/*
	Bot logic for bot determining to follow another player.
*/
bot_think_follow()
{
	self endon( "death" );
	self endon( "disconnect" );

	for ( ;; )
	{
		wait randomIntRange( 3, 5 );

		if ( self HasScriptGoal() || self.bot_lock_goal || self HasScriptAimPos() )
			continue;

		if ( randomInt( 100 ) > self.pers["bots"]["behavior"]["follow"] )
			continue;

		if ( !level.teamBased )
			continue;

		self bot_think_follow_loop();
	}
}

/*
	Kills follow when new goal
*/
watchForFollowNewGoal()
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "kill_follow_bot" );

	for ( ;; )
	{
		self waittill( "new_goal" );

		if ( !isDefined( self.bot_was_follow_script_update ) )
			break;
	}

	self ClearScriptAimPos();
	self notify( "kill_follow_bot" );
}

/*
	Kills follow when time
*/
killFollowAfterTime( time )
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "kill_follow_bot" );

	wait time;

	self ClearScriptGoal();
	self ClearScriptAimPos();
	self notify( "kill_follow_bot" );
}

/*
	Determine bot to follow a player
*/
followPlayer( who )
{
	self endon( "kill_follow_bot" );

	self thread watchForFollowNewGoal();

	for ( ;; )
	{
		wait 0.05;

		if ( !isDefined( who ) || !isReallyAlive( who ) )
			break;

		self SetScriptAimPos( who.origin + ( 0, 0, 42 ) );
		myGoal = self GetScriptGoal();

		if ( isDefined( myGoal ) && DistanceSquared( myGoal, who.origin ) < 64 * 64 )
			continue;

		self.bot_was_follow_script_update = true;
		self SetScriptGoal( who.origin, 32 );
		waittillframeend;
		self.bot_was_follow_script_update = undefined;

		self waittill_either( "goal", "bad_path" );
	}

	self ClearScriptGoal();
	self ClearScriptAimPos();

	self notify( "kill_follow_bot" );
}

/*
	Loop
*/
bot_use_tube_think_loop( data )
{
	if ( data.doFastContinue )
		data.doFastContinue = false;
	else
	{
		wait randomintRange( 3, 7 );

		chance = self.pers["bots"]["behavior"]["nade"] / 2;

		if ( chance > 20 )
			chance = 20;

		if ( randomInt( 100 ) > chance )
			return;
	}

	tube = self getValidTube();

	if ( !isDefined( tube ) )
		return;

	if ( self HasThreat() || self HasBotJavelinLocation() || self HasScriptAimPos() )
		return;

	if ( self BotIsFrozen() )
		return;

	if ( self IsBotFragging() || self IsBotSmoking() )
		return;

	if ( self isDefusing() || self isPlanting() )
		return;

	if ( self IsUsingRemote() )
		return;

	if ( self InLastStand() && !self InFinalStand() )
		return;

	loc = undefined;

	if ( !self nearAnyOfWaypoints( 128, getWaypointsOfType( "tube" ) ) )
	{
		tubeWp = getWaypointForIndex( random( self waypointsNear( getWaypointsOfType( "tube" ), 1024 ) ) );

		myEye = self GetEye();

		if ( !isDefined( tubeWp ) || self HasScriptGoal() || self.bot_lock_goal )
		{
			traceForward = BulletTrace( myEye, myEye + AnglesToForward( self GetPlayerAngles() ) * 900 * 5, false, self );

			loc = traceForward["position"];
			dist = DistanceSquared( self.origin, loc );

			if ( dist < level.bots_minGrenadeDistance || dist > level.bots_maxGrenadeDistance * 5 )
				return;

			if ( !bulletTracePassed( self.origin + ( 0, 0, 5 ), self.origin + ( 0, 0, 2048 ), false, self ) )
				return;

			if ( !bulletTracePassed( loc + ( 0, 0, 5 ), loc + ( 0, 0, 2048 ), false, self ) )
				return;

			loc += ( 0, 0, dist / 16000 );
		}
		else
		{
			self BotNotifyBotEvent( "tube", "go", tubeWp, tube );

			self SetScriptGoal( tubeWp.origin, 16 );

			ret = self waittill_any_return( "new_goal", "goal", "bad_path" );

			if ( ret != "new_goal" )
				self ClearScriptGoal();

			if ( ret != "goal" )
				return;

			data.doFastContinue = true;
			return;
		}
	}
	else
	{
		tubeWp = getWaypointForIndex( self getNearestWaypointOfWaypoints( getWaypointsOfType( "tube" ) ) );
		loc = tubeWp.origin + AnglesToForward( tubeWp.angles ) * 2048;
	}

	if ( !isDefined( loc ) )
		return;

	self BotNotifyBotEvent( "tube", "start", loc, tube );

	self SetScriptAimPos( loc );
	self BotStopMoving( true );
	wait 1;

	if ( self changeToWeapon( tube ) )
	{
		self thread fire_current_weapon();
		self waittill_any_timeout( 5, "missile_fire", "weapon_change" );
		self notify( "stop_firing_weapon" );
	}

	self ClearScriptAimPos();
	self BotStopMoving( false );
}

/*
	Bots thinking of using a noobtube
*/
bot_use_tube_think()
{
	self endon( "disconnect" );
	self endon( "death" );
	level endon( "game_ended" );

	data = spawnStruct();
	data.doFastContinue = false;

	for ( ;; )
	{
		self bot_use_tube_think_loop( data );
	}
}

/*
	Loop
*/
bot_use_equipment_think_loop( data )
{
	if ( data.doFastContinue )
		data.doFastContinue = false;
	else
	{
		wait randomintRange( 2, 4 );

		chance = self.pers["bots"]["behavior"]["nade"] / 2;

		if ( chance > 20 )
			chance = 20;

		if ( randomInt( 100 ) > chance )
			return;
	}

	nade = undefined;

	if ( self GetAmmoCount( "claymore_mp" ) )
		nade = "claymore_mp";

	if ( self GetAmmoCount( "flare_mp" ) )
		nade = "flare_mp";

	if ( self GetAmmoCount( "c4_mp" ) )
		nade = "c4_mp";

	if ( self GetAmmoCount( "bouncingbetty_mp" ) )
		nade = "bouncingbetty_mp";

	if ( self GetAmmoCount( "portable_radar_mp" ) )
		nade = "portable_radar_mp";

	if ( self GetAmmoCount( "scrambler_mp" ) )
		nade = "scrambler_mp";

	if ( self GetAmmoCount( "trophy_mp" ) )
		nade = "trophy_mp";

	if ( !isDefined( nade ) )
		return;

	if ( self HasThreat() || self HasBotJavelinLocation() || self HasScriptAimPos() )
		return;

	if ( self BotIsFrozen() )
		return;

	if ( self IsBotFragging() || self IsBotSmoking() )
		return;

	if ( self isDefusing() || self isPlanting() )
		return;

	if ( self IsUsingRemote() )
		return;

	if ( self inLastStand() && !self _hasPerk( "specialty_laststandoffhand" ) && !self inFinalStand() )
		return;

	loc = undefined;

	if ( !self nearAnyOfWaypoints( 128, getWaypointsOfType( "claymore" ) ) )
	{
		clayWp = getWaypointForIndex( random( self waypointsNear( getWaypointsOfType( "claymore" ), 1024 ) ) );

		if ( !isDefined( clayWp ) || self HasScriptGoal() || self.bot_lock_goal )
		{
			myEye = self GetEye();
			loc = myEye + AnglesToForward( self GetPlayerAngles() ) * 256;

			if ( !bulletTracePassed( myEye, loc, false, self ) )
				return;
		}
		else
		{
			self BotNotifyBotEvent( "equ", "go", clayWp, nade );

			self SetScriptGoal( clayWp.origin, 16 );

			ret = self waittill_any_return( "new_goal", "goal", "bad_path" );

			if ( ret != "new_goal" )
				self ClearScriptGoal();

			if ( ret != "goal" )
				return;

			data.doFastContinue = true;
			return;
		}
	}
	else
	{
		clayWp = getWaypointForIndex( self getNearestWaypointOfWaypoints( getWaypointsOfType( "claymore" ) ) );
		loc = clayWp.origin + AnglesToForward( clayWp.angles ) * 2048;
	}

	if ( !isDefined( loc ) )
		return;

	self BotNotifyBotEvent( "equ", "start", loc, nade );

	self SetScriptAimPos( loc );
	self BotStopMoving( true );
	wait 1;

	self botThrowGrenade( nade, 0.05 );

	self ClearScriptAimPos();
	self BotStopMoving( false );
}

/*
	Bots thinking of using claymores and TIs
*/
bot_use_equipment_think()
{
	self endon( "disconnect" );
	self endon( "death" );
	level endon( "game_ended" );

	data = spawnStruct();
	data.doFastContinue = false;

	for ( ;; )
	{
		self bot_use_equipment_think_loop( data );
	}
}

/*
	Loop
*/
bot_use_grenade_think_loop( data )
{
	if ( data.doFastContinue )
		data.doFastContinue = false;
	else
	{
		wait randomintRange( 4, 7 );

		chance = self.pers["bots"]["behavior"]["nade"] / 2;

		if ( chance > 20 )
			chance = 20;

		if ( randomInt( 100 ) > chance )
			return;
	}

	nade = self getValidGrenade();

	if ( !isDefined( nade ) )
		return;

	if ( self HasThreat() || self HasBotJavelinLocation() || self HasScriptAimPos() )
		return;

	if ( self BotIsFrozen() )
		return;

	if ( self IsBotFragging() || self IsBotSmoking() )
		return;

	if ( self isDefusing() || self isPlanting() )
		return;

	if ( self IsUsingRemote() )
		return;

	if ( self inLastStand() && !self _hasPerk( "specialty_laststandoffhand" ) && !self inFinalStand() )
		return;

	loc = undefined;

	if ( !self nearAnyOfWaypoints( 128, getWaypointsOfType( "grenade" ) ) )
	{
		nadeWp = getWaypointForIndex( random( self waypointsNear( getWaypointsOfType( "grenade" ), 1024 ) ) );

		myEye = self GetEye();

		if ( !isDefined( nadeWp ) || self HasScriptGoal() || self.bot_lock_goal )
		{
			traceForward = BulletTrace( myEye, myEye + AnglesToForward( self GetPlayerAngles() ) * 900, false, self );

			loc = traceForward["position"];
			dist = DistanceSquared( self.origin, loc );

			if ( dist < level.bots_minGrenadeDistance || dist > level.bots_maxGrenadeDistance )
				return;

			if ( !bulletTracePassed( self.origin + ( 0, 0, 5 ), self.origin + ( 0, 0, 2048 ), false, self ) )
				return;

			if ( !bulletTracePassed( loc + ( 0, 0, 5 ), loc + ( 0, 0, 2048 ), false, self ) )
				return;

			loc += ( 0, 0, dist / 3000 );
		}
		else
		{
			self BotNotifyBotEvent( "nade", "go", nadeWp, nade );

			self SetScriptGoal( nadeWp.origin, 16 );

			ret = self waittill_any_return( "new_goal", "goal", "bad_path" );

			if ( ret != "new_goal" )
				self ClearScriptGoal();

			if ( ret != "goal" )
				return;

			data.doFastContinue = true;
			return;
		}
	}
	else
	{
		nadeWp = getWaypointForIndex( self getNearestWaypointOfWaypoints( getWaypointsOfType( "grenade" ) ) );
		loc = nadeWp.origin + AnglesToForward( nadeWp.angles ) * 2048;
	}

	if ( !isDefined( loc ) )
		return;

	self BotNotifyBotEvent( "nade", "start", loc, nade );

	self SetScriptAimPos( loc );
	self BotStopMoving( true );
	wait 1;

	time = 0.5;

	if ( nade == "frag_grenade_mp" )
		time = 2;

	self botThrowGrenade( nade, time );

	self ClearScriptAimPos();
	self BotStopMoving( false );
}

/*
	Bots thinking of using grenades
*/
bot_use_grenade_think()
{
	self endon( "disconnect" );
	self endon( "death" );
	level endon( "game_ended" );

	data = spawnStruct();
	data.doFastContinue = false;

	for ( ;; )
	{
		self bot_use_grenade_think_loop( data );
	}
}

/*
	Bots play mw2
*/
bot_watch_think_mw2_loop()
{
	tube = self getValidTube();

	if ( !isDefined( tube ) )
	{
		if ( self GetAmmoCount( "iw5_smaw_mp" ) )
			tube = "iw5_smaw_mp";
		else if ( self GetAmmoCount( "rpg_mp" ) )
			tube = "rpg_mp";
		else if ( self GetAmmoCount( "xm25_mp" ) )
			tube = "xm25_mp";
		else
			return;
	}

	if ( self GetCurrentWeapon() == tube )
		return;

	if ( randomInt( 100 ) > self.pers["bots"]["behavior"]["nade"] )
		return;

	self thread ChangeToWeapon( tube );
}

/*
	Bots play mw2
*/
bot_watch_think_mw2()
{
	self endon( "disconnect" );
	self endon( "death" );
	level endon( "game_ended" );

	for ( ;; )
	{
		wait randomIntRange( 1, 4 );

		if ( self BotIsFrozen() )
			continue;

		if ( self isDefusing() || self isPlanting() )
			continue;

		if ( self IsUsingRemote() )
			continue;

		if ( self InLastStand() && !self InFinalStand() )
			continue;

		if ( self HasThreat() )
			continue;

		self bot_watch_think_mw2_loop();
	}
}

/*
	Loop
*/
bot_watch_riot_weapons_loop()
{
	threat = self GetThreat();
	dist = DistanceSquared( threat.origin, self.origin );
	curWeap = self GetCurrentWeapon();

	if ( randomInt( 2 ) )
	{
		nade = self getValidGrenade();

		if ( !isDefined( nade ) )
			return;

		if ( dist <= level.bots_minGrenadeDistance || dist >= level.bots_maxGrenadeDistance )
			return;

		if ( randomInt( 100 ) > self.pers["bots"]["behavior"]["nade"] )
			return;

		self botThrowGrenade( nade );
	}
	else
	{
		if ( randomInt( 100 ) > self.pers["bots"]["behavior"]["switch"] * 10 )
			return;

		weaponslist = self getweaponslistall();
		weap = "";

		while ( weaponslist.size )
		{
			weapon = weaponslist[randomInt( weaponslist.size )];
			weaponslist = array_remove( weaponslist, weapon );

			if ( !self getAmmoCount( weapon ) )
				continue;

			if ( !isWeaponPrimary( weapon ) )
				continue;

			if ( curWeap == weapon || weapon == "none" || weapon == "" || weapon == "javelin_mp" || weapon == "stinger_mp" )
				continue;

			weap = weapon;
			break;
		}

		if ( weap == "" )
			return;

		self thread ChangeToWeapon( weap );
	}
}

/*
	Bots will use gremades/wweapons while having a target while using a shield
*/
bot_watch_riot_weapons()
{
	self endon( "disconnect" );
	self endon( "death" );
	level endon( "game_ended" );

	for ( ;; )
	{
		wait randomIntRange( 2, 4 );

		if ( self BotIsFrozen() )
			continue;

		if ( self isDefusing() || self isPlanting() )
			continue;

		if ( self IsUsingRemote() )
			continue;

		if ( self InLastStand() && !self InFinalStand() )
			continue;

		if ( !self HasThreat() )
			continue;

		if ( !self.hasRiotShieldEquipped )
			continue;

		self bot_watch_riot_weapons_loop();
	}
}

/*
	Loop
*/
bot_jav_loc_think_loop( data )
{
	if ( data.doFastContinue )
		data.doFastContinue = false;
	else
	{
		wait randomintRange( 2, 4 );

		chance = self.pers["bots"]["behavior"]["nade"] / 2;

		if ( chance > 20 )
			chance = 20;

		if ( randomInt( 100 ) > chance && self getCurrentWeapon() != "javelin_mp" )
			return;
	}

	if ( !self GetAmmoCount( "javelin_mp" ) )
		return;

	if ( self HasThreat() || self HasBotJavelinLocation() || self HasScriptAimPos() )
		return;

	if ( self BotIsFrozen() )
		return;

	if ( self isDefusing() || self isPlanting() )
		return;

	if ( self IsUsingRemote() )
		return;

	if ( self InLastStand() && !self InFinalStand() )
		return;

	if ( self isEMPed() )
		return;

	loc = undefined;

	if ( !self nearAnyOfWaypoints( 128, getWaypointsOfType( "javelin" ) ) )
	{
		javWp = getWaypointForIndex( random( self waypointsNear( getWaypointsOfType( "javelin" ), 1024 ) ) );

		if ( !isDefined( javWp ) || self HasScriptGoal() || self.bot_lock_goal )
		{
			traceForward = self maps\mp\_javelin::EyeTraceForward();

			if ( !isDefined( traceForward ) )
				return;

			loc = traceForward[0];

			if ( self maps\mp\_javelin::TargetPointTooClose( loc ) )
				return;

			if ( !bulletTracePassed( self.origin + ( 0, 0, 5 ), self.origin + ( 0, 0, 2048 ), false, self ) )
				return;

			if ( !bulletTracePassed( loc + ( 0, 0, 5 ), loc + ( 0, 0, 2048 ), false, self ) )
				return;
		}
		else
		{
			self BotNotifyBotEvent( "jav", "go", javWp );

			self SetScriptGoal( javWp.origin, 16 );

			ret = self waittill_any_return( "new_goal", "goal", "bad_path" );

			if ( ret != "new_goal" )
				self ClearScriptGoal();

			if ( ret != "goal" )
				return;

			data.doFastContinue = true;
			return;
		}
	}
	else
	{
		javWp = getWaypointForIndex( self getNearestWaypointOfWaypoints( getWaypointsOfType( "javelin" ) ) );
		loc = javWp.jav_point;
	}

	if ( !isDefined( loc ) )
		return;

	self BotNotifyBotEvent( "jav", "start", loc );

	self SetBotJavelinLocation( loc );

	if ( self changeToWeapon( "javelin_mp" ) )
	{
		self waittill_any_timeout( 10, "missile_fire", "weapon_change" );
	}

	self ClearBotJavelinLocation();
}

/*
	BOts thinking of using javelins
*/
bot_jav_loc_think()
{
	self endon( "disconnect" );
	self endon( "death" );
	level endon( "game_ended" );

	data = spawnStruct();
	data.doFastContinue = false;

	for ( ;; )
	{
		self bot_jav_loc_think_loop( data );
	}
}

/*
	Loop
*/
bot_equipment_kill_think_loop()
{
	myteam = self.pers[ "team" ];
	hasSitrep = self _HasPerk( "specialty_detectexplosive" );
	grenades = getEntArray( "grenade", "classname" );
	myEye = self getEye();
	myAngles = self getPlayerAngles();
	dist = 512 * 512;
	target = undefined;

	// check legacy nades, c4 and claymores
	for ( i = 0; i < grenades.size; i++ )
	{
		item = grenades[i];

		if ( !isDefined( item ) )
			continue;

		if ( !IsDefined( item.name ) )
			continue;

		if ( item.name != "c4_mp" && item.name != "claymore_mp" )
			continue;

		if ( IsDefined( item.owner ) && ( ( level.teamBased && item.owner.team == self.team ) || item.owner == self ) )
			continue;

		if ( !hasSitrep && !bulletTracePassed( myEye, item.origin, false, item ) )
			continue;

		if ( getConeDot( item.origin, self.origin, myAngles ) < 0.6 )
			continue;

		if ( DistanceSquared( item.origin, self.origin ) < dist )
		{
			target = item;
			break;
		}
	}

	grenades = undefined; // clean up, reduces child1 vars

	// check for player stuff, tis and throphys and radars
	if ( !IsDefined( target ) )
	{
		for ( i = 0; i < level.players.size; i++ )
		{
			player = level.players[i];

			if ( player == self )
				continue;

			if ( !isDefined( player.team ) )
				continue;

			if ( level.teamBased && player.team == myteam )
				continue;

			// check for thorphys
			if ( isDefined( player.trophyArray ) )
			{
				for ( h = 0; h < player.trophyArray.size; h++ )
				{
					item = player.trophyArray[h];

					if ( !isDefined( item ) )
						continue;

					if ( isDefined( item.damageTaken ) && isDefined( item.maxHealth ) )
					{
						if ( item.damageTaken >= item.maxHealth )
							continue;
					}

					if ( !isDefined( item.bots ) )
						item.bots = 0;

					if ( item.bots >= 2 )
						continue;

					if ( !hasSitrep && !bulletTracePassed( myEye, item.origin, false, item ) )
						continue;

					if ( getConeDot( item.origin, self.origin, myAngles ) < 0.6 )
						continue;

					if ( DistanceSquared( item.origin, self.origin ) < dist )
					{
						target = item;
						break;
					}
				}
			}

			// check for ti
			if ( !isDefined( target ) )
			{
				for ( h = 0; h < 1; h++ )
				{
					item = player.setSpawnPoint;

					if ( !isDefined( item ) )
						continue;

					if ( isDefined( item.damageTaken ) && isDefined( item.maxHealth ) )
					{
						if ( item.damageTaken >= item.maxHealth )
							continue;
					}

					if ( !isDefined( item.bots ) )
						item.bots = 0;

					if ( item.bots >= 2 )
						continue;

					if ( !hasSitrep && !bulletTracePassed( myEye, item.origin, false, item ) )
						continue;

					if ( getConeDot( item.origin, self.origin, myAngles ) < 0.6 )
						continue;

					if ( DistanceSquared( item.origin, self.origin ) < dist )
					{
						target = item;
						break;
					}
				}
			}

			// check for radar
			if ( !isDefined( target ) )
			{
				for ( h = 0; h < 1; h++ )
				{
					item = player.deployedPortableRadar;

					if ( !isDefined( item ) )
						continue;

					if ( isDefined( item.damageTaken ) && isDefined( item.maxHealth ) )
					{
						if ( item.damageTaken >= item.maxHealth )
							continue;
					}

					if ( !isDefined( item.bots ) )
						item.bots = 0;

					if ( item.bots >= 2 )
						continue;

					if ( !hasSitrep && !bulletTracePassed( myEye, item.origin, false, item ) )
						continue;

					if ( getConeDot( item.origin, self.origin, myAngles ) < 0.6 )
						continue;

					if ( DistanceSquared( item.origin, self.origin ) < dist )
					{
						target = item;
						break;
					}
				}
			}

			if ( isDefined( target ) )
				break;
		}
	}

	// check for ims
	if ( !IsDefined( target ) )
	{
		imsKeys = getArrayKeys( level.ims );

		for ( i = 0; i < imsKeys.size; i++ )
		{
			item = level.ims[imsKeys[i]];

			if ( !isDefined( item ) )
				continue;

			if ( isDefined( item.damageTaken ) && isDefined( item.maxHealth ) )
			{
				if ( item.damageTaken >= item.maxHealth )
					continue;
			}

			if ( IsDefined( item.owner ) && ( ( level.teamBased && item.owner.team == self.team ) || item.owner == self ) )
				continue;

			if ( !hasSitrep && !bulletTracePassed( myEye, item.origin, false, item ) )
				continue;

			if ( getConeDot( item.origin, self.origin, myAngles ) < 0.6 )
				continue;

			if ( DistanceSquared( item.origin, self.origin ) < dist )
			{
				target = item;
				break;
			}
		}

		imsKeys = undefined;
	}

	// check for vest
	if ( !IsDefined( target ) )
	{
		for ( i = 0; i < level.vest_boxes.size; i++ )
		{
			item = level.vest_boxes[i];

			if ( !isDefined( item ) )
				continue;

			if ( isDefined( item.damageTaken ) && isDefined( item.maxHealth ) )
			{
				if ( item.damageTaken >= item.maxHealth )
					continue;
			}

			if ( IsDefined( item.owner ) && ( ( level.teamBased && item.owner.team == self.team ) || item.owner == self ) )
				continue;

			if ( !hasSitrep && !bulletTracePassed( myEye, item.origin, false, item ) )
				continue;

			if ( getConeDot( item.origin, self.origin, myAngles ) < 0.6 )
				continue;

			if ( DistanceSquared( item.origin, self.origin ) < dist )
			{
				target = item;
				break;
			}
		}
	}

	// check for jammers
	if ( !IsDefined( target ) )
	{
		for ( i = 0; i < level.scramblers.size; i++ )
		{
			item = level.scramblers[i];

			if ( !isDefined( item ) )
				continue;

			if ( isDefined( item.damageTaken ) && isDefined( item.maxHealth ) )
			{
				if ( item.damageTaken >= item.maxHealth )
					continue;
			}

			if ( IsDefined( item.owner ) && ( ( level.teamBased && item.owner.team == self.team ) || item.owner == self ) )
				continue;

			if ( !hasSitrep && !bulletTracePassed( myEye, item.origin, false, item ) )
				continue;

			if ( getConeDot( item.origin, self.origin, myAngles ) < 0.6 )
				continue;

			if ( DistanceSquared( item.origin, self.origin ) < dist )
			{
				target = item;
				break;
			}
		}
	}

	// check for mines
	if ( !IsDefined( target ) )
	{
		for ( i = 0; i < level.mines.size; i++ )
		{
			item = level.mines[i];

			if ( !isDefined( item ) )
				continue;

			if ( isDefined( item.damageTaken ) && isDefined( item.maxHealth ) )
			{
				if ( item.damageTaken >= item.maxHealth )
					continue;
			}

			if ( IsDefined( item.owner ) && ( ( level.teamBased && item.owner.team == self.team ) || item.owner == self ) )
				continue;

			if ( !hasSitrep && !bulletTracePassed( myEye, item.origin, false, item ) )
				continue;

			if ( getConeDot( item.origin, self.origin, myAngles ) < 0.6 )
				continue;

			if ( DistanceSquared( item.origin, self.origin ) < dist )
			{
				target = item;
				break;
			}
		}
	}

	if ( !IsDefined( target ) )
		return;

	// must be ti
	if ( isDefined( target.enemyTrigger ) && !self HasScriptGoal() && !self.bot_lock_goal )
	{
		self BotNotifyBotEvent( "attack_equ", "go_ti", target );

		self SetScriptGoal( target.origin, 64 );
		self thread bot_inc_bots( target, true );
		self thread bots_watch_touch_obj( target );

		path = self waittill_any_return( "bad_path", "goal", "new_goal" );

		if ( path != "new_goal" )
			self ClearScriptGoal();

		if ( path != "goal" || !isDefined( target ) )
			return;

		if ( randomInt( 100 ) < self.pers["bots"]["behavior"]["camp"] * 8 )
		{
			self BotNotifyBotEvent( "attack_equ", "camp_ti", target );

			self thread killCampAfterTime( randomIntRange( 10, 20 ) );
			self thread killCampAfterEntGone( target );
			self CampAtSpot( target.origin, target.origin + ( 0, 0, 42 ) );
		}

		if ( isDefined( target ) )
		{
			self BotNotifyBotEvent( "attack_equ", "trigger_ti", target );
			self thread BotPressUse();
		}

		return;
	}

	self BotNotifyBotEvent( "attack_equ", "start", target );

	self SetScriptEnemy( target );
	self bot_equipment_attack( target );
	self ClearScriptEnemy();

	self BotNotifyBotEvent( "attack_equ", "stop", target );
}

/*
	Bots thinking of targeting equipment, c4, claymores and TIs
*/
bot_equipment_kill_think()
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon ( "game_ended" );

	for ( ;; )
	{
		wait( RandomIntRange( 1, 3 ) );

		if ( self HasScriptEnemy() )
			continue;

		if ( self.pers["bots"]["skill"]["base"] <= 1 )
			continue;

		self bot_equipment_kill_think_loop();
	}
}

/*
	Bots target the equipment for a time then stop
*/
bot_equipment_attack( equ )
{
	wait_time = RandomIntRange( 7, 10 );

	for ( i = 0; i < wait_time; i++ )
	{
		wait( 1 );

		if ( !IsDefined( equ ) )
		{
			return;
		}

		if ( isDefined( equ.damageTaken ) && isDefined( equ.maxHealth ) )
		{
			if ( equ.damageTaken >= equ.maxHealth )
				return;
		}
	}
}

/*
	Loop
*/
bot_listen_to_steps_loop()
{
	dist = level.bots_listenDist;

	if ( self _hasPerk( "specialty_selectivehearing" ) )
		dist *= 1.4;

	dist *= dist;

	heard = undefined;

	for ( i = level.players.size - 1 ; i >= 0; i-- )
	{
		player = level.players[i];

		if ( player == self )
			continue;

		if ( level.teamBased && self.team == player.team )
			continue;

		if ( player.sessionstate != "playing" )
			continue;

		if ( !isReallyAlive( player ) )
			continue;

		if ( lengthsquared( player getVelocity() ) < 20000 )
			continue;

		if ( distanceSquared( player.origin, self.origin ) > dist )
			continue;

		if ( player _hasPerk( "specialty_quieter" ) )
			continue;

		heard = player;
		break;
	}

	hasHeartbeat = ( isSubStr( self GetCurrentWeapon(), "_heartbeat" ) && ( ( !self IsEMPed() && !self isNuked() ) || self _hasPerk( "specialty_spygame" ) ) );
	heartbeatDist = 350 * 350;

	if ( !IsDefined( heard ) && hasHeartbeat )
	{
		for ( i = level.players.size - 1 ; i >= 0; i-- )
		{
			player = level.players[i];

			if ( player == self )
				continue;

			if ( level.teamBased && self.team == player.team )
				continue;

			if ( player.sessionstate != "playing" )
				continue;

			if ( !isReallyAlive( player ) )
				continue;

			if ( player _hasPerk( "specialty_heartbreaker" ) )
				continue;

			if ( distanceSquared( player.origin, self.origin ) > heartbeatDist )
				continue;

			if ( GetConeDot( player.origin, self.origin, self GetPlayerAngles() ) < 0.6 )
				continue;

			heard = player;
			break;
		}
	}

	if ( !isDefined( heard ) )
	{
		if ( self _hasPerk( "specialty_revenge" ) && isDefined( self.lastKilledBy ) )
			heard = self.lastKilledBy;
	}

	if ( !IsDefined( heard ) )
		return;

	self BotNotifyBotEvent( "heard_target", "start", heard );

	if ( bulletTracePassed( self getEye(), heard getTagOrigin( "j_spineupper" ), false, heard ) )
	{
		self setAttacker( heard );
		return;
	}

	if ( self HasScriptGoal() || self.bot_lock_goal )
		return;

	self SetScriptGoal( heard.origin, 64 );

	if ( self waittill_any_return( "goal", "bad_path", "new_goal" ) != "new_goal" )
		self ClearScriptGoal();

	self BotNotifyBotEvent( "heard_target", "stop", heard );
}

/*
	Bots will listen to foot steps and target nearby targets
*/
bot_listen_to_steps()
{
	self endon( "disconnect" );
	self endon( "death" );

	for ( ;; )
	{
		wait 1;

		if ( self.pers["bots"]["skill"]["base"] < 3 )
			continue;

		self bot_listen_to_steps_loop();
	}
}

/*
	Loop
*/
bot_uav_think_loop()
{
	hasAssPro = self _hasPerk( "specialty_spygame" );

	if ( !hasAssPro )
	{
		if ( self isEMPed() || self.bot_isScrambled || self isNuked() )
			return;

		if ( ( level.teamBased && level.activeCounterUAVs[level.otherTeam[self.team]] ) || ( !level.teamBased && self.isRadarBlocked ) )
			return;
	}

	hasRadar = ( ( level.teamBased && level.activeUAVs[self.team] ) || ( !level.teamBased && level.activeUAVs[self.guid] ) );

	if ( level.hardcoreMode && !hasRadar )
		return;

	dist = self.pers["bots"]["skill"]["help_dist"];
	dist *= dist * 8;

	for ( i = level.players.size - 1; i >= 0; i-- )
	{
		player = level.players[i];

		if ( player == self )
			continue;

		if ( !isDefined( player.team ) )
			continue;

		if ( player.sessionstate != "playing" )
			continue;

		if ( level.teambased && player.team == self.team )
			continue;

		if ( !isReallyAlive( player ) )
			continue;

		distFromPlayer = DistanceSquared( self.origin, player.origin );

		if ( distFromPlayer > dist )
			continue;

		if ( ( !isSubStr( player getCurrentWeapon(), "_silencer" ) && player.bots_firing ) || ( hasRadar && !player _hasPerk( "specialty_coldblooded" ) ) || player maps\mp\perks\_perkfunctions::isPainted() || player.bot_isInRadar || player isJuggernaut() || isDefined( player.UAVRemoteMarkedBy ) )
		{
			self BotNotifyBotEvent( "uav_target", "start", player );

			distSq = self.pers["bots"]["skill"]["help_dist"] * self.pers["bots"]["skill"]["help_dist"];

			if ( distFromPlayer < distSq && bulletTracePassed( self getEye(), player getTagOrigin( "j_spineupper" ), false, player ) )
			{
				self SetAttacker( player );
			}

			if ( !self HasScriptGoal() && !self.bot_lock_goal )
			{
				self SetScriptGoal( player.origin, 128 );
				self thread stop_go_target_on_death( player );

				if ( self waittill_any_return( "goal", "bad_path", "new_goal" ) != "new_goal" )
					self ClearScriptGoal();

				self BotNotifyBotEvent( "uav_target", "stop", player );
			}

			break;
		}
	}
}

/*
	Bots will look at the uav and target targets
*/
bot_uav_think()
{
	self endon( "death" );
	self endon( "disconnect" );

	for ( ;; )
	{
		wait 0.75;

		if ( self.pers["bots"]["skill"]["base"] <= 1 )
			continue;

		self bot_uav_think_loop();
	}
}

/*
	bots will go to their target's kill location
*/
bot_revenge_think()
{
	self endon( "death" );
	self endon( "disconnect" );

	if ( self.pers["bots"]["skill"]["base"] <= 1 )
		return;

	if ( isDefined( self.lastKiller ) && isReallyAlive( self.lastKiller ) )
	{
		if ( bulletTracePassed( self getEye(), self.lastKiller getTagOrigin( "j_spineupper" ), false, self.lastKiller ) )
		{
			self setAttacker( self.lastKiller );
		}
	}

	if ( !isDefined( self.killerLocation ) )
		return;

	loc = self.killerLocation;

	for ( ;; )
	{
		wait( RandomIntRange( 1, 5 ) );

		if ( self HasScriptGoal() || self.bot_lock_goal )
			return;

		if ( randomint( 100 ) < 75 )
			return;

		self BotNotifyBotEvent( "revenge", "start", loc, self.lastKiller );

		self SetScriptGoal( loc, 64 );

		if ( self waittill_any_return( "goal", "bad_path", "new_goal" ) != "new_goal" )
			self ClearScriptGoal();

		self BotNotifyBotEvent( "revenge", "stop", loc, self.lastKiller );
	}
}

/*
	Watches the target's health, calls 'bad_path'
*/
turret_death_monitor( turret )
{
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon ( "bad_path" );
	self endon ( "goal" );
	self endon ( "new_goal" );

	for ( ;; )
	{
		wait 0.5;

		if ( !isDefined( turret ) )
			break;

		if ( turret.damageTaken >= turret.maxHealth )
			break;

		if ( isDefined( turret.carriedBy ) )
			break;
	}

	self notify( "bad_path" );
}

/*
	Bots will target the turret for a time
*/
bot_turret_attack( enemy )
{
	wait_time = RandomIntRange( 7, 10 );

	for ( i = 0; i < wait_time; i++ )
	{
		wait( 1 );

		if ( !IsDefined( enemy ) )
			return;

		if ( enemy.damageTaken >= enemy.maxHealth )
			return;

		if ( isDefined( enemy.carriedBy ) )
			return;

		//if ( !BulletTracePassed( self getEye(), enemy.origin + ( 0, 0, 15 ), false, enemy ) )
		//	return;
	}
}

/*
	Loops
*/
bot_turret_think_loop()
{
	myteam = self.pers[ "team" ];
	turretsKeys = getArrayKeys( level.turrets );

	if ( turretsKeys.size == 0 )
	{
		wait( randomintrange( 3, 5 ) );
		return;
	}

	if ( self.pers["bots"]["skill"]["base"] <= 1 )
		return;

	if ( self HasScriptEnemy() || self IsUsingRemote() )
		return;

	myEye = self GetEye();
	turret = undefined;

	for ( i = turretsKeys.size - 1; i >= 0; i-- )
	{
		tempTurret = level.turrets[turretsKeys[i]];

		if ( !isDefined( tempTurret ) )
			continue;

		if ( tempTurret.damageTaken >= tempTurret.maxHealth )
			continue;

		if ( isDefined( tempTurret.carriedBy ) )
			continue;

		if ( isDefined( tempTurret.owner ) && tempTurret.owner == self )
			continue;

		if ( level.teamBased && tempTurret.team == myteam )
			continue;

		if ( !bulletTracePassed( myEye, tempTurret.origin + ( 0, 0, 15 ), false, tempTurret ) )
			continue;

		turret = tempTurret;
	}

	turretsKeys = undefined;

	if ( !isDefined( turret ) )
		return;

	forward = AnglesToForward( turret.angles );
	forward = VectorNormalize( forward );

	delta = self.origin - turret.origin;
	delta = VectorNormalize( delta );

	dot = VectorDot( forward, delta );

	facing = true;

	if ( dot < 0.342 ) // cos 70 degrees
		facing = false;

	if ( turret isStunned() )
		facing = false;

	if ( self _hasPerk( "specialty_blindeye" ) )
		facing = false;

	if ( !isDefined( turret.sentryType ) || turret.sentryType == "sam_turret" )
		facing = false;

	if ( facing && !BulletTracePassed( myEye, turret.origin + ( 0, 0, 15 ), false, turret ) )
		return;

	if ( !IsDefined( turret.bots ) )
		turret.bots = 0;

	if ( turret.bots >= 2 )
		return;

	if ( !facing && !self HasScriptGoal() && !self.bot_lock_goal )
	{
		self BotNotifyBotEvent( "turret_attack", "go", turret );

		self SetScriptGoal( turret.origin, 32 );
		self thread bot_inc_bots( turret, true );
		self thread turret_death_monitor( turret );
		self thread bots_watch_touch_obj( turret );

		if ( self waittill_any_return( "bad_path", "goal", "new_goal" ) != "new_goal" )
			self ClearScriptGoal();
	}

	if ( !isDefined( turret ) )
		return;

	self BotNotifyBotEvent( "turret_attack", "start", turret );

	self SetScriptEnemy( turret, ( 0, 0, 25 ) );
	self bot_turret_attack( turret );
	self ClearScriptEnemy();

	self BotNotifyBotEvent( "turret_attack", "stop", turret );
}

/*
	Bots will think when to target a turret
*/
bot_turret_think()
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon ( "game_ended" );

	for ( ;; )
	{
		wait( 1 );

		self bot_turret_think_loop();
	}
}

/*
	Loops
*/
bot_box_think_loop( data )
{
	ret = "bot_check_box_think";

	if ( data.first )
		data.first = false;
	else
		ret = self waittill_any_timeout( randomintrange( 3, 5 ), "bot_check_box_think" );

	if ( RandomInt( 100 ) < 20 && ret != "bot_check_box_think" )
		return;

	if ( self HasScriptGoal() || self.bot_lock_goal )
		return;

	if ( self HasThreat() )
		return;

	if ( self isDefusing() || self isPlanting() )
		return;

	if ( self IsUsingRemote() || self BotIsFrozen() )
		return;

	if ( self inLastStand() )
		return;

	if ( isDefined( self.hasLightArmor ) && self.hasLightArmor )
		return;

	if ( self isJuggernaut() )
		return;

	box = undefined;
	myteam = self.pers[ "team" ];

	dist = 2048 * 2048;

	for ( i = 0; i < level.vest_boxes.size; i++ )
	{
		item = level.vest_boxes[i];

		if ( !isDefined( item ) )
			continue;

		if ( isDefined( item.damageTaken ) && isDefined( item.maxHealth ) )
		{
			if ( item.damageTaken >= item.maxHealth )
				continue;
		}

		if ( !IsDefined( item.owner ) || ( level.teamBased && item.owner.team != myteam ) || ( !level.teamBased && item.owner != self ) )
			continue;

		if ( DistanceSquared( item.origin, self.origin ) < dist )
		{
			box = item;
			break;
		}
	}

	if ( !isDefined( box ) )
		return;

	self BotNotifyBotEvent( "box_cap", "go", box );

	self.bot_lock_goal = true;

	radius = GetDvarFloat( "player_useRadius" ) / 2;
	self SetScriptGoal( box.origin, radius );
	self thread bot_inc_bots( box, true );
	self thread bots_watch_touch_obj( box );

	path = self waittill_any_return( "bad_path", "goal", "new_goal" );

	self.bot_lock_goal = false;

	if ( path != "new_goal" )
		self ClearScriptGoal();

	if ( path != "goal" || !isDefined( box ) || DistanceSquared( self.origin, box.origin ) > radius * radius )
		return;

	self BotNotifyBotEvent( "box_cap", "start", box );

	self BotFreezeControls( true );
	self bot_wait_stop_move();

	waitTime = 2.25;
	self thread BotPressUse( waitTime );
	wait waitTime;

	self BotFreezeControls( false );

	self BotNotifyBotEvent( "box_cap", "stop", box );
}

/*
	Bots think to use boxes
*/
bot_box_think()
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon( "game_ended" );

	data = spawnStruct();
	data.first = true;

	for ( ;; )
	{
		self bot_box_think_loop( data );
	}
}

/*
	Loops
*/
bot_watch_stuck_on_crate_loop()
{
	crates = getEntArray( "care_package", "targetname" );

	if ( crates.size == 0 )
		return;

	crate = undefined;

	for ( i = crates.size - 1; i >= 0; i-- )
	{
		tempCrate = crates[i];

		if ( !isDefined( tempCrate ) )
			continue;

		if ( isDefined( tempCrate.owner ) && isDefined( tempCrate.bomb ) )
		{
			if ( tempCrate.owner == self )
				continue;

			if ( level.teamBased && tempCrate.owner.team == self.team )
				continue;

			if ( self _hasPerk( "specialty_detectexplosive" ) )
				continue;
		}

		if ( !isDefined( tempCrate.doingPhysics ) || tempCrate.doingPhysics )
			continue;

		if ( isDefined( crate ) && DistanceSquared( crate.origin, self.origin ) < DistanceSquared( tempCrate.origin, self.origin ) )
			continue;

		crate = tempCrate;
	}

	if ( !isDefined( crate ) )
		return;

	radius = GetDvarFloat( "player_useRadius" );

	if ( DistanceSquared( crate.origin, self.origin ) > radius * radius )
		return;

	self.bot_stuck_on_carepackage = crate;
	self notify( "crate_physics_done" );
}

/*
	Checks if the bot is stuck on a carepackage
*/
bot_watch_stuck_on_crate()
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon( "game_ended" );

	for ( ;; )
	{
		wait 3;

		if ( self HasThreat() )
			continue;

		self bot_watch_stuck_on_crate_loop();
	}
}

/*
	Loops
*/
bot_crate_think_loop( data )
{
	myteam = self.pers[ "team" ];
	ret = "crate_physics_done";

	if ( data.first )
		data.first = false;
	else
		ret = self waittill_any_timeout( randomintrange( 3, 5 ), "crate_physics_done" );

	crate = self.bot_stuck_on_carepackage;
	self.bot_stuck_on_carepackage = undefined;

	if ( !isDefined( crate ) )
	{
		if ( RandomInt( 100 ) < 20 && ret != "crate_physics_done" )
			return;

		if ( self HasScriptGoal() || self.bot_lock_goal )
			return;

		if ( self isDefusing() || self isPlanting() )
			return;

		if ( self IsUsingRemote() || self BotIsFrozen() )
			return;

		if ( self inLastStand() )
			return;

		crates = getEntArray( "care_package", "targetname" );

		if ( crates.size == 0 )
			return;

		wantsClosest = randomint( 2 );

		crate = undefined;

		for ( i = crates.size - 1; i >= 0; i-- )
		{
			tempCrate = crates[i];

			if ( !isDefined( tempCrate ) )
				continue;

			if ( isDefined( tempCrate.owner ) && isDefined( tempCrate.bomb ) )
			{
				if ( tempCrate.owner == self )
					continue;

				if ( level.teamBased && tempCrate.owner.team == self.team )
					continue;

				if ( self _hasPerk( "specialty_detectexplosive" ) )
					continue;
			}

			if ( !isDefined( tempCrate.doingPhysics ) || tempCrate.doingPhysics )
				continue;

			if ( !IsDefined( tempCrate.bots ) )
				tempCrate.bots = 0;

			if ( tempCrate.bots >= 3 )
				continue;

			if ( isDefined( crate ) )
			{
				if ( wantsClosest )
				{
					if ( DistanceSquared( crate.origin, self.origin ) < DistanceSquared( tempCrate.origin, self.origin ) )
						continue;
				}
				else
				{
					if ( maps\mp\killstreaks\_killstreaks::getStreakCost( crate.crateType ) > maps\mp\killstreaks\_killstreaks::getStreakCost( tempCrate.crateType ) )
						continue;
				}
			}

			crate = tempCrate;
		}

		crates = undefined;

		if ( !isDefined( crate ) )
			return;

		self BotNotifyBotEvent( "crate_cap", "go", crate );

		self.bot_lock_goal = true;

		radius = GetDvarFloat( "player_useRadius" ) - 16;
		self SetScriptGoal( crate.origin, radius );
		self thread bot_inc_bots( crate, true );
		self thread bots_watch_touch_obj( crate );

		path = self waittill_any_return( "bad_path", "goal", "new_goal" );

		self.bot_lock_goal = false;

		if ( path != "new_goal" )
			self ClearScriptGoal();

		if ( path != "goal" || !isDefined( crate ) || DistanceSquared( self.origin, crate.origin ) > radius * radius )
		{
			if ( isDefined( crate ) && path == "bad_path" )
				self BotNotifyBotEvent( "crate_cap", "unreachable", crate );

			return;
		}
	}

	self BotNotifyBotEvent( "crate_cap", "start", crate );

	self BotRandomStance();

	self BotFreezeControls( true );
	self bot_wait_stop_move();

	waitTime = 3.25;

	if ( !isDefined( crate.owner ) || crate.owner == self )
		waitTime = 0.75;

	self thread BotPressUse( waitTime );
	wait waitTime;

	self BotFreezeControls( false );

	// check if actually captured it?
	self BotNotifyBotEvent( "crate_cap", "stop", crate );
}

/*
	Bots will capture carepackages
*/
bot_crate_think()
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon( "game_ended" );

	data = spawnStruct();
	data.first = true;

	for ( ;; )
	{
		self bot_crate_think_loop( data );
	}
}

/*
	Reload cancels
*/
doReloadCancel_loop()
{
	curWeap = self GetCurrentWeapon();
	ret = self waittill_either_return( "reload", "weapon_change" );

	if ( self BotIsFrozen() )
		return;

	if ( self isDefusing() || self isPlanting() )
		return;

	if ( self IsUsingRemote() )
		return;

	if ( self InLastStand() && !self InFinalStand() )
		return;

	if ( !getDvarInt( "sv_enableDoubleTaps" ) )
		return;

	// wait for an actual change
	if ( ret == "weapon_change" )
	{
		for ( i = 0; i < 10 && curWeap == self GetCurrentWeapon(); i++ )
			wait 0.05;
	}

	curWeap = self GetCurrentWeapon();

	if ( !maps\mp\gametypes\_weapons::isPrimaryWeapon( curWeap ) )
		return;

	if ( ret == "reload" )
	{
		// check single reloads
		if ( self GetWeaponAmmoClip( curWeap ) < WeaponClipSize( curWeap ) )
			return;
	}

	// check difficulty
	if ( self.pers["bots"]["skill"]["base"] <= 3 )
		return;

	// check if got another weapon
	weaponslist = self GetWeaponsListPrimaries();
	weap = "";

	while ( weaponslist.size )
	{
		weapon = weaponslist[randomInt( weaponslist.size )];
		weaponslist = array_remove( weaponslist, weapon );

		if ( !maps\mp\gametypes\_weapons::isPrimaryWeapon( weapon ) )
			continue;

		if ( curWeap == weapon || weapon == "none" || weapon == "" )
			continue;

		weap = weapon;
		break;
	}

	if ( weap == "" )
		return;

	// do the cancel
	wait 0.1;
	self thread ChangeToWeapon( weap );
	wait 0.25;
	self thread ChangeToWeapon( curWeap );
	wait 2;
}

/*
	Reload cancels
*/
doReloadCancel()
{
	self endon( "disconnect" );
	self endon( "death" );

	for ( ;; )
	{
		self doReloadCancel_loop();
	}
}

/*
	Loops
*/
bot_weapon_think_loop( data )
{
	self waittill_any_timeout( randomIntRange( 2, 4 ), "bot_force_check_switch" );

	if ( self BotIsFrozen() )
		return;

	if ( self isDefusing() || self isPlanting() )
		return;

	if ( self IsUsingRemote() )
		return;

	if ( self InLastStand() && !self InFinalStand() )
		return;

	curWeap = self GetCurrentWeapon();
	hasTarget = self hasThreat();

	if ( hasTarget )
	{
		threat = self getThreat();
		rocketAmmo = self getRocketAmmo();

		if ( entIsVehicle( threat ) && isDefined( rocketAmmo ) )
		{
			if ( curWeap != rocketAmmo )
				self thread ChangeToWeapon( rocketAmmo );

			return;
		}
	}

	if ( self HasBotJavelinLocation() && self GetAmmoCount( "javelin_mp" ) )
	{
		if ( curWeap != "javelin_mp" )
			self thread ChangeToWeapon( "javelin_mp" );

		return;
	}

	if ( data.first )
	{
		data.first = false;

		if ( randomInt( 100 ) > self.pers["bots"]["behavior"]["initswitch"] )
			return;
	}
	else
	{
		if ( curWeap != "none" && self getAmmoCount( curWeap ) && curWeap != "stinger_mp" && curWeap != "javelin_mp" )
		{
			if ( randomInt( 100 ) > self.pers["bots"]["behavior"]["switch"] )
				return;

			if ( hasTarget )
				return;
		}
	}

	weaponslist = self getweaponslistall();
	weap = "";

	while ( weaponslist.size )
	{
		weapon = weaponslist[randomInt( weaponslist.size )];
		weaponslist = array_remove( weaponslist, weapon );

		if ( !self getAmmoCount( weapon ) )
			continue;

		if ( !isWeaponPrimary( weapon ) )
			continue;

		if ( curWeap == weapon || weapon == "none" || weapon == "" || weapon == "javelin_mp" || weapon == "stinger_mp" )
			continue;

		weap = weapon;
		break;
	}

	if ( weap == "" )
		return;

	self thread ChangeToWeapon( weap );
}

/*
	Bots will think to switch weapons
*/
bot_weapon_think()
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon( "game_ended" );

	data = spawnStruct();
	data.first = true;

	for ( ;; )
	{
		self bot_weapon_think_loop( data );
	}
}

/*
	Bots think when to target vehicles
*/
bot_target_vehicle_loop()
{
	rocketAmmo = self getRocketAmmo();

	if ( isDefined( rocketAmmo ) && rocketAmmo == "javelin_mp" && self isEMPed() )
		return;

	targets = maps\mp\_stinger::GetTargetList();

	if ( !targets.size )
		return;

	lockOnAmmo = self getLockonAmmo();
	myEye = self GetEye();
	target = undefined;

	for ( i = targets.size - 1; i >= 0; i-- )
	{
		tempTarget = targets[i];

		if ( isPlayer( tempTarget ) )
			continue;

		if ( isDefined( tempTarget.owner ) && tempTarget.owner == self )
			continue;

		if ( !bulletTracePassed( myEye, tempTarget.origin, false, tempTarget ) )
			continue;

		if ( tempTarget.health <= 0 )
			continue;

		if ( isDefined( tempTarget.damageTaken ) && isDefined( tempTarget.maxHealth ) )
		{
			if ( tempTarget.damageTaken >= tempTarget.maxHealth )
				continue;
		}

		if ( tempTarget.classname != "script_vehicle" && !isDefined( lockOnAmmo ) )
			continue;

		target = tempTarget;
	}

	targets = undefined;

	if ( !isDefined( target ) )
		return;

	if ( target.model != "vehicle_ugv_talon_mp" && target.model != "vehicle_remote_uav" )
	{
		if ( isDefined( self.remoteTank ) )
			return;

		if ( !isDefined( rocketAmmo ) && self BotGetRandom() < 90 )
			return;
	}

	self BotNotifyBotEvent( "attack_vehicle", "start", target, rocketAmmo );

	self SetScriptEnemy( target, ( 0, 0, 0 ) );
	self bot_attack_vehicle( target );
	self ClearScriptEnemy();
	self notify( "bot_force_check_switch" );

	self BotNotifyBotEvent( "attack_vehicle", "stop", target, rocketAmmo );
}

/*
	Bots think when to target vehicles
*/
bot_target_vehicle()
{
	self endon( "disconnect" );
	self endon( "death" );

	for ( ;; )
	{
		wait randomIntRange( 2, 4 );

		if ( self.pers["bots"]["skill"]["base"] <= 1 )
			continue;

		if ( self HasScriptEnemy() )
			continue;

		if ( self IsUsingRemote() && !isDefined( self.remoteTank ) )
			continue;

		self bot_target_vehicle_loop();
	}
}

/*
	Bots target the killstreak for a time and stops
*/
bot_attack_vehicle( target )
{
	target endon( "death" );

	wait_time = RandomIntRange( 7, 10 );

	for ( i = 0; i < wait_time; i++ )
	{
		self notify( "bot_force_check_switch" );
		wait( 1 );

		if ( !IsDefined( target ) )
		{
			return;
		}
	}
}

/*
	Bot watch to use remote turret
*/
bot_watch_use_remote_turret()
{
	self endon( "death" );
	self endon( "disconnect" );

	for ( ;; )
	{
		wait 5;

		if ( self BotIsFrozen() )
			continue;

		if ( self HasThreat() || self HasBotJavelinLocation() )
			continue;

		if ( self isDefusing() || self isPlanting() )
			continue;

		if ( self IsUsingRemote() )
			continue;

		if ( self InLastStand() && !self InFinalStand() )
			continue;

		if ( !isDefined( self.remoteTurretList ) || !isDefined( self.remoteTurretList[0] ) )
			continue;

		self thread BotPressUse( 3 );
		wait 3;
	}
}

/*
	Returns an origin thats good to use for a kill streak
*/
getKillstreakTargetLocation()
{
	location = undefined;
	players = [];

	for ( i = level.players.size - 1; i >= 0; i-- )
	{
		player = level.players[i];

		if ( player == self )
			continue;

		if ( !isDefined( player.team ) )
			continue;

		if ( level.teamBased && self.team == player.team )
			continue;

		if ( player.sessionstate != "playing" )
			continue;

		if ( !isReallyAlive( player ) )
			continue;

		if ( player _hasPerk( "specialty_blindeye" ) )
			continue;

		if ( !bulletTracePassed( player.origin, player.origin + ( 0, 0, 2048 ), false, player ) && self.pers["bots"]["skill"]["base"] > 3 )
			continue;

		players[players.size] = player;
	}

	target = random( players );

	if ( isDefined( target ) )
		location = target.origin + ( randomIntRange( ( 8 - self.pers["bots"]["skill"]["base"] ) * -75, ( 8 - self.pers["bots"]["skill"]["base"] ) * 75 ), randomIntRange( ( 8 - self.pers["bots"]["skill"]["base"] ) * -75, ( 8 - self.pers["bots"]["skill"]["base"] ) * 75 ), 0 );
	else if ( self.pers["bots"]["skill"]["base"] <= 3 )
		location = self.origin + ( randomIntRange( -512, 512 ), randomIntRange( -512, 512 ), 0 );

	return location;
}

/*
	Clears remote usage when bot dies
*/
clear_remote_on_death( isac130 )
{
	self endon( "bot_clear_remote_on_death" );
	level endon( "game_ended" );

	self waittill_either( "death", "disconnect" );

	if ( isDefined( isac130 ) && isac130 )
		level.ac130InUse = false;

	if ( isDefined( self ) )
		self ClearUsingRemote();
}

/*
	Bots think to use killstreaks
*/
bot_killstreak_think_loop( data )
{
	if ( !isDefined( data.doFastContinue ) )
	{
		wait randomIntRange( 1, 3 );
	}

	if ( self BotIsFrozen() )
		return;

	if ( self HasThreat() || self HasBotJavelinLocation() )
		return;

	if ( self isDefusing() || self isPlanting() )
		return;

	if ( self isEMPed() || self isNuked() )
		return;

	if ( self IsUsingRemote() )
		return;

	if ( self InLastStand() && !self InFinalStand() )
		return;


	if ( isDefined( self.isCarrying ) && self.isCarrying )
	{
		self notify( "place_sentry" );
		self notify( "place_turret" );
		self notify( "place_ims" );
		self notify( "place_carryRemoteUAV" );
		self notify( "place_tank" );
	}

	curWeap = self GetCurrentWeapon();

	if ( isSubStr( curWeap, "airdrop_" ) || isSubStr( curWeap, "deployable_" ) )
		self thread BotPressAttack( 0.05 );


	useableStreaks = [];

	if ( !isDefined( data.doFastContinue ) )
	{
		if ( self.pers["killstreaks"][0].available )
			useableStreaks[useableStreaks.size] = 0;

		if ( self.pers["killstreaks"][1].available && self.streakType != "specialist" )
			useableStreaks[useableStreaks.size] = 1;

		if ( self.pers["killstreaks"][2].available && self.streakType != "specialist" )
			useableStreaks[useableStreaks.size] = 2;

		if ( self.pers["killstreaks"][3].available && self.streakType != "specialist" )
			useableStreaks[useableStreaks.size] = 3;
	}
	else
	{
		useableStreaks[0] = data.doFastContinue;
		data.doFastContinue = undefined;
	}

	if ( !useableStreaks.size )
		return;

	self.killstreakIndexWeapon = random( useableStreaks );
	streakName = self.pers["killstreaks"][self.killstreakIndexWeapon].streakName;

	if ( level.inGracePeriod && maps\mp\killstreaks\_killstreaks::deadlyKillstreak( streakName ) )
		return;

	ksWeap = maps\mp\killstreaks\_killstreaks::getKillstreakWeapon( streakName );

	if ( curWeap == "none" || !isWeaponPrimary( curWeap ) )
		curWeap = self GetLastWeapon();

	lifeId = self.pers["killstreaks"][0].lifeId;

	if ( !isDefined( lifeId ) )
		lifeId = -1;

	if ( maps\mp\killstreaks\_killstreaks::isRideKillstreak( streakName ) || maps\mp\killstreaks\_killstreaks::isCarryKillstreak( streakName ) || streakName == "sam_turret" || streakName == "remote_mg_turret" )
	{
		if ( self inLastStand() )
			return;

		if ( lifeId == self.deaths && !self HasScriptGoal() && !self.bot_lock_goal && maps\mp\killstreaks\_killstreaks::isRideKillstreak( streakName ) && !self nearAnyOfWaypoints( 128, getWaypointsOfType( "camp" ) ) )
		{
			campSpot = getWaypointForIndex( random( self waypointsNear( getWaypointsOfType( "camp" ), 1024 ) ) );

			if ( isDefined( campSpot ) )
			{
				self BotNotifyBotEvent( "killstreak", "camp", streakName, campSpot );

				self SetScriptGoal( campSpot.origin, 16 );

				if ( self waittill_any_return( "new_goal", "goal", "bad_path" ) != "new_goal" )
					self ClearScriptGoal();

				data.doFastContinue = self.killstreakIndexWeapon;
				return;
			}
		}

		if ( streakName == "sentry" || streakName == "sam_turret" || streakName == "remote_mg_turret" || streakName == "ims" || streakName == "remote_uav" || streakName == "remote_tank" )
		{
			if ( self HasScriptAimPos() )
				return;

			if ( streakName == "remote_uav" || streakName == "remote_tank" )
			{
				if ( ( isDefined( level.remote_uav[self.team] ) || level.littleBirds.size >= 4 ) && streakName == "remote_uav" )
					return;

				if ( currentActiveVehicleCount() >= maxVehiclesAllowed() || level.fauxVehicleCount + 1 >= maxVehiclesAllowed() )
					return;
			}

			myEye = self GetEye();
			angles = self GetPlayerAngles();

			forwardTrace = bulletTrace( myEye, myEye + AnglesToForward( angles ) * 1024, false, self );
			placeNot = "place_sentry";
			cancelNot = "cancel_sentry";
			distCheck = 1000 * 1000;
			doRandomStance = false;

			switch ( streakName )
			{
				case "sam_turret":
					forwardTrace = bulletTrace( myEye, myEye + ( 0, 0, 1024 ), false, self );
					break;

				case "remote_mg_turret":
					placeNot = "place_turret";
					cancelNot = "cancel_turret";
					break;

				case "ims":
					forwardTrace = bulletTrace( myEye, myEye + AnglesToForward( angles ) * 128, false, self );
					placeNot = "place_ims";
					cancelNot = "cancel_ims";
					distCheck = 100 * 100;
					break;

				case "remote_uav":
					forwardTrace = bulletTrace( myEye, myEye + AnglesToForward( angles ) * 128, false, self );
					placeNot = "place_carryRemoteUAV";
					cancelNot = "cancel_carryRemoteUAV";
					distCheck = 100 * 100;
					doRandomStance = true;
					break;

				case "remote_tank":
					forwardTrace = bulletTrace( myEye, myEye + AnglesToForward( angles ) * 128, false, self );
					placeNot = "place_tank";
					cancelNot = "cancel_tank";
					distCheck = 100 * 100;
					doRandomStance = true;
					break;
			}

			if ( DistanceSquared( self.origin, forwardTrace["position"] ) < distCheck && self.pers["bots"]["skill"]["base"] > 3 )
				return;

			self BotNotifyBotEvent( "killstreak", "call", streakName );

			if ( doRandomStance )
				self BotRandomStance();

			self BotStopMoving( true );
			self SetScriptAimPos( forwardTrace["position"] );

			if ( !self changeToWeapon( ksWeap ) )
			{
				self BotStopMoving( false );
				self ClearScriptAimPos();
				return;
			}

			wait 1;
			self notify( placeNot );
			wait 0.05;
			self notify( cancelNot );
			wait 0.5;

			self BotStopMoving( false );
			self ClearScriptAimPos();
		}
		else if ( streakName == "predator_missile" )
		{
			location = self getKillstreakTargetLocation();

			if ( !isDefined( location ) )
				return;

			self BotNotifyBotEvent( "killstreak", "call", streakName, location );

			self BotRandomStance();
			self setUsingRemote( "remotemissile" );
			self thread clear_remote_on_death();
			self BotStopMoving( true );

			if ( !self changeToWeapon( ksWeap ) )
			{
				self ClearUsingRemote();
				self notify( "bot_clear_remote_on_death" );
				self BotStopMoving( false );
				return;
			}

			wait 0.05;
			self thread ChangeToWeapon( ksWeap ); // prevent script from changing back

			wait 1;
			self notify( "bot_clear_remote_on_death" );
			self BotStopMoving( false );

			if ( self isEMPed() || self isNuked() )
			{
				self ClearUsingRemote();
				self thread changeToWeapon( curWeap );
				return;
			}

			self BotFreezeControls( true );

			self thread maps\mp\killstreaks\_killstreaks::updateKillstreaks();
			self maps\mp\killstreaks\_killstreaks::usedKillstreak( streakName, true );

			rocket = MagicBullet( "remotemissile_projectile_mp", self.origin + ( 0.0, 0.0, 7000.0 - ( self.pers["bots"]["skill"]["base"] * 400 ) ), location, self );
			rocket.lifeId = lifeId;
			rocket.type = "remote";

			rocket thread maps\mp\gametypes\_weapons::AddMissileToSightTraces( self.pers["team"] );
			rocket thread maps\mp\killstreaks\_remotemissile::handleDamage();
			thread maps\mp\killstreaks\_remotemissile::MissileEyes( self, rocket );

			self waittill( "stopped_using_remote" );

			wait 1;
			self BotFreezeControls( false );
		}
		else if ( streakName == "ac130" || streakName == "remote_mortar" || streakName == "osprey_gunner" )
		{
			if ( streakName == "ac130" )
			{
				if ( isDefined( level.ac130player ) || level.ac130InUse )
					return;
			}

			if ( streakName == "remote_mortar" )
			{
				if ( isDefined( level.remote_mortar ) )
					return;
			}

			location = undefined;
			directionYaw = undefined;

			if ( streakName == "osprey_gunner" )
			{
				if ( isDefined( level.chopper ) )
					return;

				if ( currentActiveVehicleCount() >= maxVehiclesAllowed() || level.fauxVehicleCount + 1 >= maxVehiclesAllowed() )
					return;

				location = self getKillstreakTargetLocation();
				directionYaw = randomInt( 360 );

				if ( !isDefined( location ) )
					return;
			}

			self BotNotifyBotEvent( "killstreak", "call", streakName, location, directionYaw );

			self BotRandomStance();
			self BotStopMoving( true );

			if ( self changeToWeapon( ksWeap ) )
			{
				wait 1;

				if ( isDefined( location ) )
				{
					self notify( "confirm_location", location, directionYaw );
				}
			}

			wait 2;
			self BotStopMoving( false );
		}
		else if ( streakName == "deployable_vest" )
		{
			myEye = self GetEye();
			angles = self GetPlayerAngles();

			forwardTrace = bulletTrace( myEye, myEye + AnglesToForward( angles ) * 128, false, self );

			if ( DistanceSquared( self.origin, forwardTrace["position"] ) < 96 * 96 && self.pers["bots"]["skill"]["base"] > 3 )
				return;

			self BotNotifyBotEvent( "killstreak", "call", streakName );

			self BotStopMoving( true );
			self SetScriptAimPos( forwardTrace["position"] );

			if ( !self changeToWeapon( ksWeap ) )
			{
				self BotStopMoving( false );
				self ClearScriptAimPos();
				return;
			}

			self thread fire_current_weapon();

			self waittill_any_timeout( 5, "grenade_fire" );

			self notify( "stop_firing_weapon" );

			self BotStopMoving( false );
			self ClearScriptAimPos();

			wait 2.5;
			self notify( "bot_check_box_think" );
		}
	}
	else
	{
		if ( streakName == "escort_airdrop" || streakName == "airdrop_juggernaut_recon" || streakName == "airdrop_trap" || streakName == "airdrop_juggernaut" || streakName == "airdrop_remote_tank" || streakName == "airdrop_sentry_minigun" || streakName == "airdrop_assault" )
		{
			if ( self HasScriptAimPos() )
				return;

			if ( ( level.littleBirds.size >= 4 || level.fauxVehicleCount >= 4 ) && !isSubStr( toLower( streakName ), "juggernaut" ) )
				return;

			if ( currentActiveVehicleCount() >= maxVehiclesAllowed() || level.fauxVehicleCount + 1 >= maxVehiclesAllowed() )
				return;

			if ( IsSubStr( toLower( streakName ), "escort_airdrop" ) && isDefined( level.chopper ) )
				return;

			if ( !bulletTracePassed( self.origin, self.origin + ( 0, 0, 2048 ), false, self ) && self.pers["bots"]["skill"]["base"] > 3 )
				return;

			myEye = self GetEye();
			angles = self GetPlayerAngles();

			forwardTrace = bulletTrace( myEye, myEye + AnglesToForward( angles ) * 256, false, self );

			if ( DistanceSquared( self.origin, forwardTrace["position"] ) < 96 * 96 && self.pers["bots"]["skill"]["base"] > 3 )
				return;

			if ( !bulletTracePassed( forwardTrace["position"], forwardTrace["position"] + ( 0, 0, 2048 ), false, self ) && self.pers["bots"]["skill"]["base"] > 3 )
				return;

			self BotNotifyBotEvent( "killstreak", "call", streakName );

			self BotStopMoving( true );
			self SetScriptAimPos( forwardTrace["position"] );

			if ( !self changeToWeapon( ksWeap ) )
			{
				self BotStopMoving( false );
				self ClearScriptAimPos();
				return;
			}

			self thread fire_current_weapon();

			ret = self waittill_any_timeout( 5, "grenade_fire" );

			self notify( "stop_firing_weapon" );

			if ( ret == "timeout" )
			{
				self BotStopMoving( false );
				self ClearScriptAimPos();
				return;
			}

			if ( randomInt( 100 ) < 80 && !self HasScriptGoal() && !self.bot_lock_goal )
				self waittill_any_timeout( 15, "crate_physics_done", "new_goal" );

			self BotStopMoving( false );
			self ClearScriptAimPos();
		}
		else
		{
			if ( streakName == "nuke" && isDefined( level.nukeIncoming ) )
				return;

			if ( streakName == "counter_uav" && self.pers["bots"]["skill"]["base"] > 3 && ( ( level.teamBased && level.activeCounterUAVs[self.team] ) || ( !level.teamBased && level.activeCounterUAVs[self.guid] ) ) )
				return;

			if ( ( streakName == "uav" || streakName == "uav_support" || streakName == "triple_uav" ) && self.pers["bots"]["skill"]["base"] > 3 && ( ( level.teamBased && ( level.activeUAVs[self.team] || level.activeCounterUAVs[level.otherTeam[self.team]] ) ) || ( !level.teamBased && ( level.activeUAVs[self.guid] || self.isRadarBlocked ) ) ) )
				return;

			if ( streakName == "emp" && self.pers["bots"]["skill"]["base"] > 3 && ( ( level.teamBased && level.teamEMPed[level.otherTeam[self.team]] ) || ( !level.teamBased && isDefined( level.empPlayer ) ) ) )
				return;

			if ( streakName == "littlebird_flock" || streakName == "helicopter" || streakName == "helicopter_flares" || streakName == "littlebird_support" )
			{
				numIncomingVehicles = 1;

				if ( streakName == "littlebird_flock" )
					numIncomingVehicles = 5;

				if ( currentActiveVehicleCount() >= maxVehiclesAllowed() || level.fauxVehicleCount + numIncomingVehicles >= maxVehiclesAllowed() )
					return;

				if ( streakName == "helicopter" && isDefined( level.chopper ) )
					return;

				if ( streakName == "littlebird_support" && ( isDefined( level.littlebirdGuard ) || maps\mp\killstreaks\_helicopter::exceededMaxLittlebirds( "littlebird_support" ) ) )
					return;
			}

			location = undefined;
			directionYaw = undefined;

			switch ( streakName )
			{
				case "littlebird_flock":
				case "stealth_airstrike":
				case "precision_airstrike":
					location = self getKillstreakTargetLocation();
					directionYaw = randomInt( 360 );

					if ( !isDefined( location ) )
						return;

				case "helicopter":
				case "helicopter_flares":
				case "littlebird_support":
				case "uav":
				case "uav_support":
				case "counter_uav":
				case "triple_uav":
				case "nuke":
				case "emp":
					self BotStopMoving( true );

					self BotNotifyBotEvent( "killstreak", "call", streakName, location, directionYaw );

					if ( self changeToWeapon( ksWeap ) )
					{
						wait 1;

						if ( isDefined( location ) )
						{
							self BotFreezeControls( true );

							self notify( "confirm_location", location, directionYaw );
							wait 1;

							self BotFreezeControls( false );
						}
					}

					self BotStopMoving( false );
					break;
			}
		}
	}
}

/*
	Bots think to use killstreaks
*/
bot_killstreak_think()
{
	self endon( "disconnect" );
	self endon( "death" );
	level endon( "game_ended" );

	data = spawnStruct();
	data.doFastContinue = undefined;

	for ( ;; )
	{
		self bot_killstreak_think_loop( data );
	}
}

/*
	Bots do random stance
*/
BotRandomStance()
{
	if ( randomInt( 100 ) < 80 )
		self BotSetStance( "prone" );
	else if ( randomInt( 100 ) < 60 )
		self BotSetStance( "crouch" );
	else
		self BotSetStance( "stand" );
}

/*
	Bots will use a random equipment
*/
BotUseRandomEquipment()
{
	self endon( "death" );
	self endon( "disconnect" );

	nade = undefined;

	if ( self GetAmmoCount( "claymore_mp" ) )
		nade = "claymore_mp";

	if ( self GetAmmoCount( "flare_mp" ) )
		nade = "flare_mp";

	if ( self GetAmmoCount( "c4_mp" ) )
		nade = "c4_mp";

	if ( self GetAmmoCount( "bouncingbetty_mp" ) )
		nade = "bouncingbetty_mp";

	if ( self GetAmmoCount( "portable_radar_mp" ) )
		nade = "portable_radar_mp";

	if ( self GetAmmoCount( "scrambler_mp" ) )
		nade = "scrambler_mp";

	if ( self GetAmmoCount( "trophy_mp" ) )
		nade = "trophy_mp";

	if ( !isDefined( nade ) )
		return;

	self botThrowGrenade( nade, 0.05 );
}

/*
	Bots will look at a random thing
*/
BotLookAtRandomThing( obj_target )
{
	self endon( "death" );
	self endon( "disconnect" );

	if ( self HasScriptAimPos() )
		return;

	rand = RandomInt( 100 );

	nearestEnemy = undefined;

	for ( i = 0; i < level.players.size; i++ )
	{
		player = level.players[i];

		if ( !isDefined( player ) || !isDefined( player.team ) )
			continue;

		if ( !isAlive( player ) )
			continue;

		if ( level.teamBased && self.team == player.team )
			continue;

		if ( !isDefined( nearestEnemy ) || DistanceSquared( self.origin, player.origin ) < DistanceSquared( self.origin, nearestEnemy.origin ) )
		{
			nearestEnemy = player;
		}
	}

	origin = ( 0, 0, self GetEyeHeight() );

	if ( isDefined( nearestEnemy ) && DistanceSquared( self.origin, nearestEnemy.origin ) < 1024 * 1024 && rand < 40 )
		origin += ( nearestEnemy.origin[0], nearestEnemy.origin[1], self.origin[2] );
	else if ( isDefined( obj_target ) && rand < 50 )
		origin += ( obj_target.origin[0], obj_target.origin[1], self.origin[2] );
	else if ( rand < 85 )
		origin += self.origin + AnglesToForward( ( 0, self.angles[1] - 180, 0 ) ) * 1024;
	else
		origin += self.origin + AnglesToForward( ( 0, RandomInt( 360 ), 0 ) ) * 1024;

	self SetScriptAimPos( origin );
	wait 2;
	self ClearScriptAimPos();
}

/*
	Bots will do stuff while waiting for objective
*/
bot_do_random_action_for_objective( obj_target )
{
	self endon( "death" );
	self endon( "disconnect" );
	self notify( "bot_do_random_action_for_objective" );
	self endon( "bot_do_random_action_for_objective" );

	if ( !isDefined( self.bot_random_obj_action ) )
	{
		self.bot_random_obj_action = true;

		if ( randomInt( 100 ) < 80 )
			self thread BotUseRandomEquipment();

		if ( randomInt( 100 ) < 75 )
			self thread BotLookAtRandomThing( obj_target );
	}
	else
	{
		if ( self GetStance() != "prone" && randomInt( 100 ) < 15 )
			self BotSetStance( "prone" );
		else if ( randomInt( 100 ) < 5 )
			self thread BotLookAtRandomThing( obj_target );
	}

	wait 2;
	self.bot_random_obj_action = undefined;
}

/*
	Bots hang around the enemy's flag to spawn kill em
*/
bot_dom_spawn_kill_think_loop()
{
	myTeam = self.pers[ "team" ];
	otherTeam = getOtherTeam( myTeam );
	myFlagCount = maps\mp\gametypes\dom::getTeamFlagCount( myTeam );

	if ( myFlagCount == level.flags.size )
		return;

	otherFlagCount = maps\mp\gametypes\dom::getTeamFlagCount( otherTeam );

	if ( myFlagCount <= otherFlagCount || otherFlagCount != 1 )
		return;

	flag = undefined;

	for ( i = 0; i < level.flags.size; i++ )
	{
		if ( level.flags[i] maps\mp\gametypes\dom::getFlagTeam() == myTeam )
			continue;

		flag = level.flags[i];
	}

	if ( !isDefined( flag ) )
		return;

	if ( DistanceSquared( self.origin, flag.origin ) < 2048 * 2048 )
		return;

	self BotNotifyBotEvent( "dom", "start", "spawnkill", flag );

	self SetScriptGoal( flag.origin, 1024 );

	self thread bot_dom_watch_flags( myFlagCount, myTeam );

	if ( self waittill_any_return( "goal", "bad_path", "new_goal" ) != "new_goal" )
		self ClearScriptGoal();

	self BotNotifyBotEvent( "dom", "stop", "spawnkill", flag );
}

/*
	Bots hang around the enemy's flag to spawn kill em
*/
bot_dom_spawn_kill_think()
{
	self endon( "death" );
	self endon( "disconnect" );

	if ( level.gametype != "dom" )
		return;

	for ( ;; )
	{
		wait( randomintrange( 10, 20 ) );

		if ( randomint( 100 ) < 20 )
			continue;

		if ( self HasScriptGoal() || self.bot_lock_goal )
			continue;

		self bot_dom_spawn_kill_think_loop();
	}
}

/*
	Calls 'bad_path' when the flag count changes
*/
bot_dom_watch_flags( count, myTeam )
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "goal" );
	self endon( "bad_path" );
	self endon( "new_goal" );

	for ( ;; )
	{
		wait 0.5;

		if ( maps\mp\gametypes\dom::getTeamFlagCount( myTeam ) != count )
			break;
	}

	self notify( "bad_path" );
}

/*
	Bots watches their own flags and protects them when they are under capture
*/
bot_dom_def_think_loop()
{
	myTeam = self.pers[ "team" ];
	flag = undefined;

	for ( i = 0; i < level.flags.size; i++ )
	{
		if ( level.flags[i] maps\mp\gametypes\dom::getFlagTeam() != myTeam )
			continue;

		if ( !level.flags[i].useObj.objPoints[myTeam].isFlashing )
			continue;

		if ( !isDefined( flag ) || DistanceSquared( self.origin, level.flags[i].origin ) < DistanceSquared( self.origin, flag.origin ) )
			flag = level.flags[i];
	}

	if ( !isDefined( flag ) )
		return;

	self BotNotifyBotEvent( "dom", "start", "defend", flag );

	self SetScriptGoal( flag.origin, 128 );

	self thread bot_dom_watch_for_flashing( flag, myTeam );
	self thread bots_watch_touch_obj( flag );

	if ( self waittill_any_return( "goal", "bad_path", "new_goal" ) != "new_goal" )
		self ClearScriptGoal();

	self BotNotifyBotEvent( "dom", "stop", "defend", flag );
}

/*
	Bots watches their own flags and protects them when they are under capture
*/
bot_dom_def_think()
{
	self endon( "death" );
	self endon( "disconnect" );

	if ( level.gametype != "dom" )
		return;

	for ( ;; )
	{
		wait( randomintrange( 1, 3 ) );

		if ( randomint( 100 ) < 35 )
			continue;

		if ( self HasScriptGoal() || self.bot_lock_goal )
			continue;

		self bot_dom_def_think_loop();
	}
}

/*
	Watches while the flag is under capture
*/
bot_dom_watch_for_flashing( flag, myTeam )
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "goal" );
	self endon( "bad_path" );
	self endon( "new_goal" );

	for ( ;; )
	{
		wait 0.5;

		if ( !isDefined( flag ) )
			break;

		if ( flag maps\mp\gametypes\dom::getFlagTeam() != myTeam || !flag.useObj.objPoints[myTeam].isFlashing )
			break;
	}

	self notify( "bad_path" );
}

/*
	Bots capture dom flags
*/
bot_dom_cap_think_loop()
{
	myTeam = self.pers[ "team" ];
	otherTeam = getOtherTeam( myTeam );

	myFlagCount = maps\mp\gametypes\dom::getTeamFlagCount( myTeam );

	if ( myFlagCount == level.flags.size )
		return;

	otherFlagCount = maps\mp\gametypes\dom::getTeamFlagCount( otherTeam );

	if ( game["teamScores"][myteam] >= game["teamScores"][otherTeam] )
	{
		if ( myFlagCount < otherFlagCount )
		{
			if ( randomint( 100 ) < 15 )
				return;
		}
		else if ( myFlagCount == otherFlagCount )
		{
			if ( randomint( 100 ) < 35 )
				return;
		}
		else if ( myFlagCount > otherFlagCount )
		{
			if ( randomint( 100 ) < 95 )
				return;
		}
	}

	flag = undefined;
	flags = [];

	for ( i = 0; i < level.flags.size; i++ )
	{
		if ( level.flags[i] maps\mp\gametypes\dom::getFlagTeam() == myTeam )
			continue;

		flags[flags.size] = level.flags[i];
	}

	if ( randomInt( 100 ) > 30 )
	{
		for ( i = 0; i < flags.size; i++ )
		{
			if ( !isDefined( flag ) || DistanceSquared( self.origin, level.flags[i].origin ) < DistanceSquared( self.origin, flag.origin ) )
				flag = level.flags[i];
		}
	}
	else if ( flags.size )
	{
		flag = random( flags );
	}

	if ( !isDefined( flag ) )
		return;

	self BotNotifyBotEvent( "dom", "go", "cap", flag );

	self.bot_lock_goal = true;
	self SetScriptGoal( flag.origin, 64 );

	self thread bot_dom_go_cap_flag( flag, myteam );

	event = self waittill_any_return( "goal", "bad_path", "new_goal" );

	if ( event != "new_goal" )
		self ClearScriptGoal();

	if ( event != "goal" )
	{
		self.bot_lock_goal = false;
		return;
	}

	self BotNotifyBotEvent( "dom", "start", "cap", flag );

	self SetScriptGoal( self.origin, 64 );

	while ( flag maps\mp\gametypes\dom::getFlagTeam() != myTeam && self isTouching( flag ) )
	{
		cur = flag.useObj.curProgress;
		wait 0.5;

		if ( flag.useObj.curProgress == cur )
			break;//some enemy is near us, kill him

		self thread bot_do_random_action_for_objective( flag );
	}

	self BotNotifyBotEvent( "dom", "stop", "cap", flag );

	self ClearScriptGoal();

	self.bot_lock_goal = false;
}

/*
	Bots capture dom flags
*/
bot_dom_cap_think()
{
	self endon( "death" );
	self endon( "disconnect" );

	if ( level.gametype != "dom" )
		return;

	for ( ;; )
	{
		wait( randomintrange( 3, 12 ) );

		if ( self.bot_lock_goal )
		{
			continue;
		}

		if ( !isDefined( level.flags ) || level.flags.size == 0 )
			continue;

		self bot_dom_cap_think_loop();
	}
}

/*
	Bot goes to the flag, watching while they don't have the flag
*/
bot_dom_go_cap_flag( flag, myteam )
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "goal" );
	self endon( "bad_path" );
	self endon( "new_goal" );

	for ( ;; )
	{
		wait randomintrange( 2, 4 );

		if ( !isDefined( flag ) )
			break;

		if ( flag maps\mp\gametypes\dom::getFlagTeam() == myTeam )
			break;

		if ( self isTouching( flag ) )
			break;
	}

	if ( flag maps\mp\gametypes\dom::getFlagTeam() == myTeam )
		self notify( "bad_path" );
	else
		self notify( "goal" );
}

/*
	Bots play headquarters
*/
bot_hq_loop()
{
	myTeam = self.pers[ "team" ];
	otherTeam = getOtherTeam( myTeam );

	radio = level.radio;
	gameobj = radio.gameobject;
	origin = ( radio.origin[0], radio.origin[1], radio.origin[2] + 5 );

	//if neut or enemy
	if ( gameobj.ownerTeam != myTeam )
	{
		if ( gameobj.interactTeam == "none" ) //wait for it to become active
		{
			if ( self HasScriptGoal() )
				return;

			if ( DistanceSquared( origin, self.origin ) <= 1024 * 1024 )
				return;

			self SetScriptGoal( origin, 256 );

			if ( self waittill_any_return( "goal", "bad_path", "new_goal" ) != "new_goal" )
				self ClearScriptGoal();

			return;
		}

		//capture it

		self BotNotifyBotEvent( "hq", "go", "cap" );

		self.bot_lock_goal = true;
		self SetScriptGoal( origin, 64 );
		self thread bot_hq_go_cap( gameobj, radio );

		event = self waittill_any_return( "goal", "bad_path", "new_goal" );

		if ( event != "new_goal" )
			self ClearScriptGoal();

		if ( event != "goal" )
		{
			self.bot_lock_goal = false;
			return;
		}

		if ( !self isTouching( gameobj.trigger ) || level.radio != radio )
		{
			self.bot_lock_goal = false;
			return;
		}

		self BotNotifyBotEvent( "hq", "start", "cap" );

		self SetScriptGoal( self.origin, 64 );

		while ( self isTouching( gameobj.trigger ) && gameobj.ownerTeam != myTeam && level.radio == radio )
		{
			cur = gameobj.curProgress;
			wait 0.5;

			if ( cur == gameobj.curProgress )
				break;//no prog made, enemy must be capping

			self thread bot_do_random_action_for_objective( gameobj.trigger );
		}

		self ClearScriptGoal();
		self.bot_lock_goal = false;

		self BotNotifyBotEvent( "hq", "stop", "cap" );
	}
	else//we own it
	{
		if ( gameobj.objPoints[myteam].isFlashing ) //underattack
		{
			self BotNotifyBotEvent( "hq", "start", "defend" );

			self.bot_lock_goal = true;
			self SetScriptGoal( origin, 64 );
			self thread bot_hq_watch_flashing( gameobj, radio );

			if ( self waittill_any_return( "goal", "bad_path", "new_goal" ) != "new_goal" )
				self ClearScriptGoal();

			self.bot_lock_goal = false;

			self BotNotifyBotEvent( "hq", "stop", "defend" );
			return;
		}

		if ( self HasScriptGoal() )
			return;

		if ( DistanceSquared( origin, self.origin ) <= 1024 * 1024 )
			return;

		self SetScriptGoal( origin, 256 );

		if ( self waittill_any_return( "goal", "bad_path", "new_goal" ) != "new_goal" )
			self ClearScriptGoal();
	}
}

/*
	Bots play headquarters
*/
bot_hq()
{
	self endon( "death" );
	self endon( "disconnect" );

	if ( level.gametype != "koth" )
		return;

	for ( ;; )
	{
		wait( randomintrange( 3, 5 ) );

		if ( self.bot_lock_goal )
		{
			continue;
		}

		if ( !isDefined( level.radio ) )
			continue;

		if ( !isDefined( level.radio.gameobject ) )
			continue;

		self bot_hq_loop();
	}
}

/*
	Waits until not touching the trigger and it is the current radio.
*/
bot_hq_go_cap( obj, radio )
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "goal" );
	self endon( "bad_path" );
	self endon( "new_goal" );

	for ( ;; )
	{
		wait randomintrange( 2, 4 );

		if ( !isDefined( obj ) )
			break;

		if ( self isTouching( obj.trigger ) )
			break;

		if ( level.radio != radio )
			break;
	}

	if ( level.radio != radio )
		self notify( "bad_path" );
	else
		self notify( "goal" );
}

/*
	Waits while the radio is under attack.
*/
bot_hq_watch_flashing( obj, radio )
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "goal" );
	self endon( "bad_path" );
	self endon( "new_goal" );

	myteam = self.team;

	for ( ;; )
	{
		wait 0.5;

		if ( !isDefined( obj ) )
			break;

		if ( !obj.objPoints[myteam].isFlashing )
			break;

		if ( level.radio != radio )
			break;
	}

	self notify( "bad_path" );
}

/*
	Bots play sab
*/
bot_sab_loop()
{
	myTeam = self.pers[ "team" ];
	otherTeam = getOtherTeam( myTeam );

	bomb = level.sabBomb;
	bombteam = bomb.ownerTeam;
	carrier = bomb.carrier;
	timeleft = maps\mp\gametypes\_gamelogic::getTimeRemaining() / 1000;

	// the bomb is ours, we are on the offence
	if ( bombteam == myTeam )
	{
		site = level.bombZones[otherTeam];
		origin = ( site.curorigin[0] + 50, site.curorigin[1] + 50, site.curorigin[2] + 5 );

		// protect our planted bomb
		if ( level.bombPlanted )
		{
			// kill defuser
			if ( site isInUse() ) //somebody is defusing our bomb we planted
			{
				self BotNotifyBotEvent( "sab", "start", "defuser" );

				self.bot_lock_goal = true;
				self SetScriptGoal( origin, 64 );

				self thread bot_defend_site( site );

				if ( self waittill_any_return( "goal", "bad_path", "new_goal" ) != "new_goal" )
					self ClearScriptGoal();

				self.bot_lock_goal = false;

				self BotNotifyBotEvent( "sab", "stop", "defuser" );
				return;
			}

			//else hang around the site
			if ( DistanceSquared( origin, self.origin ) <= 1024 * 1024 )
				return;

			self.bot_lock_goal = true;
			self SetScriptGoal( origin, 256 );

			if ( self waittill_any_return( "goal", "bad_path", "new_goal" ) != "new_goal" )
				self ClearScriptGoal();

			self.bot_lock_goal = false;
			return;
		}

		// we are not the carrier
		if ( !self isBombCarrier() )
		{
			// lets escort the bomb carrier
			if ( self HasScriptGoal() )
				return;

			origin = carrier.origin;

			if ( DistanceSquared( origin, self.origin ) <= 1024 * 1024 )
				return;

			self SetScriptGoal( origin, 256 );
			self thread bot_escort_obj( bomb, carrier );

			if ( self waittill_any_return( "goal", "bad_path", "new_goal" ) != "new_goal" )
				self ClearScriptGoal();

			return;
		}

		// we are the carrier of the bomb, lets check if we need to plant
		timepassed = getTimePassed() / 1000;

		if ( timepassed < 120 && timeleft >= 90 && randomInt( 100 ) < 98 )
			return;

		self BotNotifyBotEvent( "sab", "go", "plant" );

		self.bot_lock_goal = true;
		self SetScriptGoal( origin, 1 );

		self thread bot_go_plant( site );
		event = self waittill_any_return( "goal", "bad_path", "new_goal" );

		if ( event != "new_goal" )
			self ClearScriptGoal();

		if ( event != "goal" || level.bombPlanted || !self isTouching( site.trigger ) || site IsInUse() || self inLastStand() || self HasThreat() )
		{
			self.bot_lock_goal = false;
			return;
		}

		self BotNotifyBotEvent( "sab", "start", "plant" );

		self BotRandomStance();
		self SetScriptGoal( self.origin, 64 );
		self bot_wait_stop_move();

		waitTime = ( site.useTime / 1000 ) + 2.5;
		self thread BotPressUse( waitTime );
		wait waitTime;

		self ClearScriptGoal();
		self.bot_lock_goal = false;

		self BotNotifyBotEvent( "sab", "stop", "plant" );
	}
	else if ( bombteam == otherTeam ) // the bomb is theirs, we are on the defense
	{
		site = level.bombZones[myteam];

		if ( !isDefined( site.bots ) )
			site.bots = 0;

		// protect our site from planters
		if ( !level.bombPlanted )
		{
			//kill bomb carrier
			if ( site.bots > 2 || randomInt( 100 ) < 45 )
			{
				if ( self HasScriptGoal() )
					return;

				if ( carrier _hasPerk( "specialty_coldblooded" ) )
					return;

				origin = carrier.origin;

				self SetScriptGoal( origin, 64 );
				self thread bot_escort_obj( bomb, carrier );

				if ( self waittill_any_return( "goal", "bad_path", "new_goal" ) != "new_goal" )
					self ClearScriptGoal();

				return;
			}

			//protect bomb site
			origin = ( site.curorigin[0] + 50, site.curorigin[1] + 50, site.curorigin[2] + 5 );

			self thread bot_inc_bots( site );

			if ( site isInUse() ) //somebody is planting
			{
				self BotNotifyBotEvent( "sab", "start", "planter" );

				self.bot_lock_goal = true;
				self SetScriptGoal( origin, 64 );
				self thread bot_inc_bots( site );

				self thread bot_defend_site( site );

				if ( self waittill_any_return( "goal", "bad_path", "new_goal" ) != "new_goal" )
					self ClearScriptGoal();

				self.bot_lock_goal = false;

				self BotNotifyBotEvent( "sab", "stop", "planter" );
				return;
			}

			//else hang around the site
			if ( DistanceSquared( origin, self.origin ) <= 1024 * 1024 )
			{
				wait 4;
				self notify( "bot_inc_bots" );
				site.bots--;
				return;
			}

			self.bot_lock_goal = true;
			self SetScriptGoal( origin, 256 );
			self thread bot_inc_bots( site );

			if ( self waittill_any_return( "goal", "bad_path", "new_goal" ) != "new_goal" )
				self ClearScriptGoal();

			self.bot_lock_goal = false;
			return;
		}

		// bomb is planted we need to defuse
		origin = ( site.curorigin[0] + 50, site.curorigin[1] + 50, site.curorigin[2] + 5 );

		// someone else is defusing, lets just hang around
		if ( site.bots > 1 )
		{
			if ( self HasScriptGoal() )
				return;

			if ( DistanceSquared( origin, self.origin ) <= 1024 * 1024 )
				return;

			self SetScriptGoal( origin, 256 );
			self thread bot_go_defuse( site );

			if ( self waittill_any_return( "goal", "bad_path", "new_goal" ) != "new_goal" )
				self ClearScriptGoal();

			return;
		}

		// lets go defuse
		self BotNotifyBotEvent( "sab", "go", "defuse" );

		self.bot_lock_goal = true;

		self SetScriptGoal( origin, 1 );
		self thread bot_inc_bots( site );
		self thread bot_go_defuse( site );

		event = self waittill_any_return( "goal", "bad_path", "new_goal" );

		if ( event != "new_goal" )
			self ClearScriptGoal();

		if ( event != "goal" || !level.bombPlanted || site IsInUse() || !self isTouching( site.trigger ) || self InLastStand() || self HasThreat() )
		{
			self.bot_lock_goal = false;
			return;
		}

		self BotNotifyBotEvent( "sab", "start", "defuse" );

		self BotRandomStance();
		self SetScriptGoal( self.origin, 64 );
		self bot_wait_stop_move();

		waitTime = ( site.useTime / 1000 ) + 2.5;
		self thread BotPressUse( waitTime );
		wait waitTime;

		self.bot_lock_goal = false;

		self BotNotifyBotEvent( "sab", "stop", "defuse" );
	}
	else // we need to go get the bomb!
	{
		origin = ( bomb.curorigin[0], bomb.curorigin[1], bomb.curorigin[2] + 5 );

		self BotNotifyBotEvent( "sab", "start", "bomb" );

		self.bot_lock_goal = true;
		self SetScriptGoal( origin, 64 );

		self thread bot_get_obj( bomb );

		if ( self waittill_any_return( "goal", "bad_path", "new_goal" ) != "new_goal" )
			self ClearScriptGoal();

		self.bot_lock_goal = false;

		self BotNotifyBotEvent( "sab", "stop", "bomb" );
		return;
	}
}

/*
	Bots play sab
*/
bot_sab()
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon( "game_ended" );

	if ( level.gametype != "sab" )
		return;

	for ( ;; )
	{
		wait( randomintrange( 3, 5 ) );

		if ( self IsUsingRemote() || self.bot_lock_goal )
		{
			continue;
		}

		if ( !isDefined( level.sabBomb ) )
			continue;

		if ( !isDefined( level.bombZones ) || !level.bombZones.size )
			continue;

		if ( self IsPlanting() || self isDefusing() )
			continue;

		self bot_sab_loop();
	}
}

/*
	Bots play sd defenders
*/
bot_sd_defenders_loop( data )
{
	myTeam = self.pers[ "team" ];
	otherTeam = getOtherTeam( myTeam );

	// bomb not planted, lets protect our sites
	if ( !level.bombPlanted )
	{
		timeleft = maps\mp\gametypes\_gamelogic::getTimeRemaining() / 1000;

		if ( timeleft >= 90 )
			return;

		// check for a bomb carrier, and camp the bomb
		if ( !level.multiBomb && isDefined( level.sdBomb ) )
		{
			bomb = level.sdBomb;
			carrier = level.sdBomb.carrier;

			if ( !isDefined( carrier ) )
			{
				origin = ( bomb.curorigin[0], bomb.curorigin[1], bomb.curorigin[2] + 5 );

				//hang around the bomb
				if ( self HasScriptGoal() )
					return;

				if ( DistanceSquared( origin, self.origin ) <= 1024 * 1024 )
					return;

				self SetScriptGoal( origin, 256 );

				self thread bot_get_obj( bomb );

				if ( self waittill_any_return( "goal", "bad_path", "new_goal" ) != "new_goal" )
					self ClearScriptGoal();

				return;
			}
		}

		// pick a site to protect
		if ( !isDefined( level.bombZones ) || !level.bombZones.size )
			return;

		sites = [];

		for ( i = 0; i < level.bombZones.size; i++ )
		{
			sites[sites.size] = level.bombZones[i];
		}

		if ( !sites.size )
			return;

		if ( data.rand > 50 )
			site = self bot_array_nearest_curorigin( sites );
		else
			site = random( sites );

		if ( !isDefined( site ) )
			return;

		origin = ( site.curorigin[0] + 50, site.curorigin[1] + 50, site.curorigin[2] + 5 );

		if ( site isInUse() ) //somebody is planting
		{
			self BotNotifyBotEvent( "sd", "start", "planter", site );

			self.bot_lock_goal = true;
			self SetScriptGoal( origin, 64 );

			self thread bot_defend_site( site );

			if ( self waittill_any_return( "goal", "bad_path", "new_goal" ) != "new_goal" )
				self ClearScriptGoal();

			self.bot_lock_goal = false;

			self BotNotifyBotEvent( "sd", "stop", "planter", site );
			return;
		}

		//else hang around the site
		if ( DistanceSquared( origin, self.origin ) <= 1024 * 1024 )
			return;

		self.bot_lock_goal = true;
		self SetScriptGoal( origin, 256 );

		if ( self waittill_any_return( "goal", "bad_path", "new_goal" ) != "new_goal" )
			self ClearScriptGoal();

		self.bot_lock_goal = false;
		return;
	}

	// bomb is planted, we need to defuse
	if ( !isDefined( level.defuseObject ) )
		return;

	defuse = level.defuseObject;

	if ( !isDefined( defuse.bots ) )
		defuse.bots = 0;

	origin = ( defuse.curorigin[0], defuse.curorigin[1], defuse.curorigin[2] + 5 );

	// someone is going to go defuse ,lets just hang around
	if ( defuse.bots > 1 )
	{
		if ( self HasScriptGoal() )
			return;

		if ( DistanceSquared( origin, self.origin ) <= 1024 * 1024 )
			return;

		self SetScriptGoal( origin, 256 );
		self thread bot_go_defuse( defuse );

		if ( self waittill_any_return( "goal", "bad_path", "new_goal" ) != "new_goal" )
			self ClearScriptGoal();

		return;
	}

	// lets defuse
	self BotNotifyBotEvent( "sd", "go", "defuse" );

	self.bot_lock_goal = true;
	self SetScriptGoal( origin, 1 );
	self thread bot_inc_bots( defuse );
	self thread bot_go_defuse( defuse );

	event = self waittill_any_return( "goal", "bad_path", "new_goal" );

	if ( event != "new_goal" )
		self ClearScriptGoal();

	if ( event != "goal" || !level.bombPlanted || defuse isInUse() || !self isTouching( defuse.trigger ) || self InLastStand() || self HasThreat() )
	{
		self.bot_lock_goal = false;
		return;
	}

	self BotNotifyBotEvent( "sd", "start", "defuse" );

	self BotRandomStance();
	self SetScriptGoal( self.origin, 64 );
	self bot_wait_stop_move();

	waitTime = ( defuse.useTime / 1000 ) + 2.5;
	self thread BotPressUse( waitTime );
	wait waitTime;

	self ClearScriptGoal();
	self.bot_lock_goal = false;

	self BotNotifyBotEvent( "sd", "stop", "defuse" );
}

/*
	Bots play sd defenders
*/
bot_sd_defenders()
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon( "game_ended" );

	if ( level.gametype != "sd" )
		return;

	if ( self.team == game["attackers"] )
		return;

	data = spawnStruct();
	data.rand = self BotGetRandom();

	for ( ;; )
	{
		wait( randomintrange( 3, 5 ) );

		if ( self IsUsingRemote() || self.bot_lock_goal )
		{
			continue;
		}

		if ( self IsPlanting() || self isDefusing() )
			continue;

		self bot_sd_defenders_loop( data );
	}
}

/*
	Bots play sd attackers
*/
bot_sd_attackers_loop( data )
{
	if ( data.first )
		data.first = false;
	else
		wait( randomintrange( 3, 5 ) );

	if ( self IsUsingRemote() || self.bot_lock_goal )
	{
		return;
	}

	myTeam = self.pers[ "team" ];
	otherTeam = getOtherTeam( myTeam );

	//bomb planted
	if ( level.bombPlanted )
	{
		if ( !isDefined( level.defuseObject ) )
			return;

		site = level.defuseObject;

		origin = ( site.curorigin[0], site.curorigin[1], site.curorigin[2] + 5 );

		if ( site IsInUse() ) //somebody is defusing
		{
			self BotNotifyBotEvent( "sd", "start", "defuser" );

			self.bot_lock_goal = true;

			self SetScriptGoal( origin, 64 );

			self thread bot_defend_site( site );

			if ( self waittill_any_return( "goal", "bad_path", "new_goal" ) != "new_goal" )
				self ClearScriptGoal();

			self.bot_lock_goal = false;

			self BotNotifyBotEvent( "sd", "stop", "defuser" );
			return;
		}

		//else hang around the site
		if ( DistanceSquared( origin, self.origin ) <= 1024 * 1024 )
			return;

		self.bot_lock_goal = true;
		self SetScriptGoal( origin, 256 );

		if ( self waittill_any_return( "goal", "bad_path", "new_goal" ) != "new_goal" )
			self ClearScriptGoal();

		self.bot_lock_goal = false;
		return;
	}

	timeleft = maps\mp\gametypes\_gamelogic::getTimeRemaining() / 1000;
	timepassed = getTimePassed() / 1000;

	//dont have a bomb
	if ( !self IsBombCarrier() && !level.multiBomb )
	{
		if ( !isDefined( level.sdBomb ) )
			return;

		bomb = level.sdBomb;
		carrier = level.sdBomb.carrier;

		//bomb is picked up
		if ( isDefined( carrier ) )
		{
			//escort the bomb carrier
			if ( self HasScriptGoal() )
				return;

			origin = carrier.origin;

			if ( DistanceSquared( origin, self.origin ) <= 1024 * 1024 )
				return;

			self SetScriptGoal( origin, 256 );
			self thread bot_escort_obj( bomb, carrier );

			if ( self waittill_any_return( "goal", "bad_path", "new_goal" ) != "new_goal" )
				self ClearScriptGoal();

			return;
		}

		if ( !isDefined( bomb.bots ) )
			bomb.bots = 0;

		origin = ( bomb.curorigin[0], bomb.curorigin[1], bomb.curorigin[2] + 5 );

		//hang around the bomb if other is going to go get it
		if ( bomb.bots > 1 )
		{
			if ( self HasScriptGoal() )
				return;

			if ( DistanceSquared( origin, self.origin ) <= 1024 * 1024 )
				return;

			self SetScriptGoal( origin, 256 );

			self thread bot_get_obj( bomb );

			if ( self waittill_any_return( "goal", "bad_path", "new_goal" ) != "new_goal" )
				self ClearScriptGoal();

			return;
		}

		// go get the bomb
		self BotNotifyBotEvent( "sd", "start", "bomb" );

		self.bot_lock_goal = true;
		self SetScriptGoal( origin, 64 );
		self thread bot_inc_bots( bomb );
		self thread bot_get_obj( bomb );

		if ( self waittill_any_return( "goal", "bad_path", "new_goal" ) != "new_goal" )
			self ClearScriptGoal();

		self.bot_lock_goal = false;

		self BotNotifyBotEvent( "sd", "stop", "bomb" );
		return;
	}

	// check if to plant
	if ( timepassed < 120 && timeleft >= 90 && randomInt( 100 ) < 98 )
		return;

	if ( !isDefined( level.bombZones ) || !level.bombZones.size )
		return;

	sites = [];

	for ( i = 0; i < level.bombZones.size; i++ )
	{
		sites[sites.size] = level.bombZones[i];
	}

	if ( !sites.size )
		return;

	if ( data.rand > 50 )
		plant = self bot_array_nearest_curorigin( sites );
	else
		plant = random( sites );

	if ( !isDefined( plant ) )
		return;

	origin = ( plant.curorigin[0] + 50, plant.curorigin[1] + 50, plant.curorigin[2] + 5 );

	self BotNotifyBotEvent( "sd", "go", "plant", plant );

	self.bot_lock_goal = true;
	self SetScriptGoal( origin, 1 );
	self thread bot_go_plant( plant );

	event = self waittill_any_return( "goal", "bad_path", "new_goal" );

	if ( event != "new_goal" )
		self ClearScriptGoal();

	if ( event != "goal" || level.bombPlanted || plant.visibleTeam == "none" || !self isTouching( plant.trigger ) || self InLastStand() || self HasThreat() || plant IsInUse() )
	{
		self.bot_lock_goal = false;
		return;
	}

	self BotNotifyBotEvent( "sd", "start", "plant", plant );

	self BotRandomStance();
	self SetScriptGoal( self.origin, 64 );
	self bot_wait_stop_move();

	waitTime = ( plant.useTime / 1000 ) + 2.5;
	self thread BotPressUse( waitTime );
	wait waitTime;

	self ClearScriptGoal();
	self.bot_lock_goal = false;

	self BotNotifyBotEvent( "sd", "stop", "plant", plant );
}

/*
	Bots play sd attackers
*/
bot_sd_attackers()
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon( "game_ended" );

	if ( level.gametype != "sd" )
		return;

	if ( self.team != game["attackers"] )
		return;

	data = spawnStruct();
	data.rand = self BotGetRandom();
	data.first = true;

	for ( ;; )
	{
		self bot_sd_attackers_loop( data );
	}
}

/*
	Bots play capture the flag
*/
bot_cap_loop()
{
	myTeam = self.pers[ "team" ];
	otherTeam = getOtherTeam( myTeam );

	myflag = level.teamFlags[myteam];
	myzone = level.capZones[myteam];

	theirflag = level.teamFlags[otherTeam];
	theirzone = level.capZones[otherTeam];

	if ( !myflag maps\mp\gametypes\_gameobjects::isHome() )
	{
		carrier = myflag.carrier;

		if ( !isDefined( carrier ) ) //someone doesnt has our flag
		{
			if ( !isDefined( theirflag.carrier ) && DistanceSquared( self.origin, theirflag.curorigin ) < DistanceSquared( self.origin, myflag.curorigin ) ) //no one has their flag and its closer
			{
				self BotNotifyBotEvent( "cap", "start", "their_flag", theirflag );

				self bot_cap_get_flag( theirflag );

				self BotNotifyBotEvent( "cap", "stop", "their_flag", theirflag );
			}
			else//go get it
			{
				self BotNotifyBotEvent( "cap", "start", "my_flag", myflag );

				self bot_cap_get_flag( myflag );

				self BotNotifyBotEvent( "cap", "stop", "my_flag", myflag );
			}

			return;
		}
		else
		{
			if ( theirflag maps\mp\gametypes\_gameobjects::isHome() && randomint( 100 ) < 50 )
			{
				//take their flag
				self BotNotifyBotEvent( "cap", "start", "their_flag", theirflag );

				self bot_cap_get_flag( theirflag );

				self BotNotifyBotEvent( "cap", "stop", "their_flag", theirflag );
			}
			else
			{
				if ( self HasScriptGoal() )
					return;

				if ( !isDefined( theirzone.bots ) )
					theirzone.bots = 0;

				origin = theirzone.curorigin;

				if ( theirzone.bots > 2 || randomInt( 100 ) < 45 )
				{
					//kill carrier
					if ( carrier _hasPerk( "specialty_coldblooded" ) )
						return;

					origin = carrier.origin;

					self SetScriptGoal( origin, 64 );
					self thread bot_escort_obj( myflag, carrier );

					if ( self waittill_any_return( "goal", "bad_path", "new_goal" ) != "new_goal" )
						self ClearScriptGoal();

					return;
				}

				self thread bot_inc_bots( theirzone );

				//camp their zone
				if ( DistanceSquared( origin, self.origin ) <= 1024 * 1024 )
				{
					wait 4;
					self notify( "bot_inc_bots" );
					theirzone.bots--;
					return;
				}

				self SetScriptGoal( origin, 256 );
				self thread bot_inc_bots( theirzone );
				self thread bot_escort_obj( myflag, carrier );

				if ( self waittill_any_return( "goal", "bad_path", "new_goal" ) != "new_goal" )
					self ClearScriptGoal();
			}
		}
	}
	else//our flag is ok
	{
		if ( self isFlagCarrier() ) //if have flag
		{
			//go cap
			origin = myzone.curorigin;

			self BotNotifyBotEvent( "cap", "start", "cap" );

			self.bot_lock_goal = true;
			self SetScriptGoal( origin, 32 );

			self thread bot_get_obj( myflag );
			evt = self waittill_any_return( "goal", "bad_path", "new_goal" );

			wait 1;

			if ( evt != "new_goal" )
				self ClearScriptGoal();

			self.bot_lock_goal = false;

			self BotNotifyBotEvent( "cap", "stop", "cap" );
			return;
		}

		carrier = theirflag.carrier;

		if ( !isDefined( carrier ) ) //if no one has enemy flag
		{
			self BotNotifyBotEvent( "cap", "start", "their_flag", theirflag );

			self bot_cap_get_flag( theirflag );

			self BotNotifyBotEvent( "cap", "stop", "their_flag", theirflag );
			return;
		}

		//escort them

		if ( self HasScriptGoal() )
			return;

		origin = carrier.origin;

		if ( DistanceSquared( origin, self.origin ) <= 1024 * 1024 )
			return;

		self SetScriptGoal( origin, 256 );
		self thread bot_escort_obj( theirflag, carrier );

		if ( self waittill_any_return( "goal", "bad_path", "new_goal" ) != "new_goal" )
			self ClearScriptGoal();
	}
}

/*
	Bots play capture the flag
*/
bot_cap()
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon( "game_ended" );

	if ( level.gametype != "ctf" )
		return;

	for ( ;; )
	{
		wait( randomintrange( 3, 5 ) );

		if ( self IsUsingRemote() || self.bot_lock_goal )
		{
			continue;
		}

		if ( !isDefined( level.capZones ) )
			continue;

		if ( !isDefined( level.teamFlags ) )
			continue;

		self bot_cap_loop();
	}
}

/*
	Gets the carriers ent num
*/
getCarrierEntNum()
{
	carrierNum = -1;

	if ( isDefined( self.carrier ) )
		carrierNum = self.carrier getEntityNumber();

	return carrierNum;
}

/*
	Bots go and get the flag
*/
bot_cap_get_flag( flag )
{
	origin = flag.curorigin;

	//go get it

	self.bot_lock_goal = true;
	self SetScriptGoal( origin, 32 );

	self thread bot_get_obj( flag );

	evt = self waittill_any_return( "goal", "bad_path", "new_goal" );

	if ( evt != "new_goal" )
		self ClearScriptGoal();

	if ( evt != "goal" )
	{
		self.bot_lock_goal = false;
		return;
	}

	self SetScriptGoal( self.origin, 64 );
	curCarrier = flag getCarrierEntNum();

	while ( curCarrier == flag getCarrierEntNum() && self isTouching( flag.trigger ) )
	{
		cur = flag.curProgress;
		wait 0.5;

		if ( flag.curProgress == cur )
			break;//some enemy is near us, kill him
	}

	self ClearScriptGoal();

	self.bot_lock_goal = false;
}

/*
	Bots go plant the demo bomb
*/
bot_dem_go_plant( plant )
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon( "game_ended" );
	self endon( "goal" );
	self endon( "bad_path" );
	self endon( "new_goal" );

	for ( ;; )
	{
		wait 0.5;

		if ( ( plant.label == "_b" && level.bombBPlanted ) || ( plant.label == "_a" && level.bombAPlanted ) )
			break;

		if ( self isTouching( plant.trigger ) )
			break;
	}

	if ( ( plant.label == "_b" && level.bombBPlanted ) || ( plant.label == "_a" && level.bombAPlanted ) )
		self notify( "bad_path" );
	else
		self notify( "goal" );
}

/*
	Bots spawn kill dom attackers
*/
bot_dem_attack_spawnkill()
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon( "game_ended" );
	self endon( "goal" );
	self endon( "bad_path" );
	self endon( "new_goal" );

	l1 = level.bombAPlanted;
	l2 = level.bombBPlanted;

	for ( ;; )
	{
		wait 0.5;

		if ( l1 != level.bombAPlanted || l2 != level.bombBPlanted )
			break;
	}

	self notify( "bad_path" );
}

/*
	Bots play demo attackers
*/
bot_dem_attackers_loop()
{
	myTeam = self.pers[ "team" ];
	otherTeam = getOtherTeam( myTeam );

	bombs = [];//sites with bombs
	sites = [];//sites to bomb at
	bombed = 0;//exploded sites

	for ( i = 0; i < level.bombZones.size; i++ )
	{
		bomb = level.bombZones[i];

		if ( isDefined( bomb.bombExploded ) && bomb.bombExploded )
		{
			bombed++;
			continue;
		}

		if ( bomb.label == "_a" )
		{
			if ( level.bombAPlanted )
				bombs[bombs.size] = bomb;
			else
				sites[sites.size] = bomb;

			continue;
		}

		if ( bomb.label == "_b" )
		{
			if ( level.bombBPlanted )
				bombs[bombs.size] = bomb;
			else
				sites[sites.size] = bomb;

			continue;
		}
	}

	timeleft = maps\mp\gametypes\_gamelogic::getTimeRemaining() / 1000;

	shouldLet = ( game["teamScores"][myteam] > game["teamScores"][otherTeam] && timeleft < 90 && bombed == 1 );

	//spawnkill conditions
	//if we have bombed one site or 1 bomb is planted with lots of time left, spawn kill
	//if we want the other team to win for overtime and they do not need to defuse, spawn kill
	if ( ( ( bombed + bombs.size == 1 && timeleft >= 90 ) || ( shouldLet && !bombs.size ) ) && randomInt( 100 ) < 95 )
	{
		if ( self HasScriptGoal() )
			return;

		spawnPoints = maps\mp\gametypes\_spawnlogic::getSpawnpointArray( "mp_dd_spawn_defender_start" );

		if ( !spawnPoints.size )
			return;

		spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random( spawnPoints );

		if ( DistanceSquared( spawnpoint.origin, self.origin ) <= 2048 * 2048 )
			return;

		self SetScriptGoal( spawnpoint.origin, 1024 );

		self thread bot_dem_attack_spawnkill();

		if ( self waittill_any_return( "goal", "bad_path", "new_goal" ) != "new_goal" )
			self ClearScriptGoal();

		return;
	}

	//let defuse conditions
	//if enemy is going to lose and lots of time left, let them defuse to play longer
	//or if want to go into overtime near end of the extended game
	if ( ( ( bombs.size + bombed == 2 && timeleft >= 90 ) || ( shouldLet && bombs.size ) ) && randomInt( 100 ) < 95 )
	{
		spawnPoints = maps\mp\gametypes\_spawnlogic::getSpawnpointArray( "mp_dd_spawn_attacker_start" );

		if ( !spawnPoints.size )
			return;

		spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random( spawnPoints );

		if ( DistanceSquared( spawnpoint.origin, self.origin ) <= 1024 * 1024 )
			return;

		self.bot_lock_goal = true;
		self SetScriptGoal( spawnpoint.origin, 512 );

		if ( self waittill_any_return( "goal", "bad_path", "new_goal" ) != "new_goal" )
			self ClearScriptGoal();

		self.bot_lock_goal = false;
		return;
	}

	//defend bomb conditions
	//if time is running out and we have a bomb planted
	if ( bombs.size && timeleft < 90 && ( !sites.size || randomInt( 100 ) < 95 ) )
	{
		site = self bot_array_nearest_curorigin( bombs );
		origin = ( site.curorigin[0] + 50, site.curorigin[1] + 50, site.curorigin[2] + 5 );

		if ( site IsInUse() ) //somebody is defusing
		{
			self BotNotifyBotEvent( "dem", "start", "defuser", site );

			self.bot_lock_goal = true;
			self SetScriptGoal( origin, 64 );

			self thread bot_defend_site( site );

			if ( self waittill_any_return( "goal", "bad_path", "new_goal" ) != "new_goal" )
				self ClearScriptGoal();

			self.bot_lock_goal = false;

			self BotNotifyBotEvent( "dem", "stop", "defuser", site );
			return;
		}

		//else hang around the site
		if ( DistanceSquared( origin, self.origin ) <= 1024 * 1024 )
			return;

		self.bot_lock_goal = true;
		self SetScriptGoal( origin, 256 );

		if ( self waittill_any_return( "goal", "bad_path", "new_goal" ) != "new_goal" )
			self ClearScriptGoal();

		self.bot_lock_goal = false;
		return;
	}

	//else go plant
	if ( !sites.size )
		return;

	plant = self bot_array_nearest_curorigin( sites );

	if ( !isDefined( plant ) )
		return;

	if ( !isDefined( plant.bots ) )
		plant.bots = 0;

	origin = ( plant.curorigin[0] + 50, plant.curorigin[1] + 50, plant.curorigin[2] + 5 );

	//hang around the site if lots of time left
	if ( plant.bots > 1 && timeleft >= 60 )
	{
		if ( self HasScriptGoal() )
			return;

		if ( DistanceSquared( origin, self.origin ) <= 1024 * 1024 )
			return;

		self SetScriptGoal( origin, 256 );
		self thread bot_dem_go_plant( plant );

		if ( self waittill_any_return( "goal", "bad_path", "new_goal" ) != "new_goal" )
			self ClearScriptGoal();

		return;
	}

	self BotNotifyBotEvent( "dem", "go", "plant", plant );

	self.bot_lock_goal = true;

	self SetScriptGoal( origin, 1 );
	self thread bot_inc_bots( plant );
	self thread bot_dem_go_plant( plant );

	event = self waittill_any_return( "goal", "bad_path", "new_goal" );

	if ( event != "new_goal" )
		self ClearScriptGoal();

	if ( event != "goal" || ( plant.label == "_b" && level.bombBPlanted ) || ( plant.label == "_a" && level.bombAPlanted ) || plant IsInUse() || !self isTouching( plant.trigger ) || self InLastStand() || self HasThreat() )
	{
		self.bot_lock_goal = false;
		return;
	}

	self BotNotifyBotEvent( "dem", "start", "plant", plant );

	self BotRandomStance();
	self SetScriptGoal( self.origin, 64 );
	self bot_wait_stop_move();

	waitTime = ( plant.useTime / 1000 ) + 2.5;
	self thread BotPressUse( waitTime );
	wait waitTime;

	self ClearScriptGoal();

	self.bot_lock_goal = false;

	self BotNotifyBotEvent( "dem", "stop", "plant", plant );
}

/*
	Bots play demo attackers
*/
bot_dem_attackers()
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon( "game_ended" );

	if ( level.gametype != "dd" )
		return;

	if ( self.team != game["attackers"] )
		return;

	if ( inOvertime() )
		return;

	for ( ;; )
	{
		wait( randomintrange( 3, 5 ) );

		if ( self IsUsingRemote() || self.bot_lock_goal )
		{
			continue;
		}

		if ( !isDefined( level.bombZones ) || !level.bombZones.size )
			continue;

		self bot_dem_attackers_loop();
	}
}

/*
	Bots play demo defenders
*/
bot_dem_defenders_loop()
{
	myTeam = self.pers[ "team" ];
	otherTeam = getOtherTeam( myTeam );

	bombs = [];//sites with bombs
	sites = [];//sites to bomb at
	bombed = 0;//exploded sites

	for ( i = 0; i < level.bombZones.size; i++ )
	{
		bomb = level.bombZones[i];

		if ( isDefined( bomb.bombExploded ) && bomb.bombExploded )
		{
			bombed++;
			continue;
		}

		if ( bomb.label == "_a" )
		{
			if ( level.bombAPlanted )
				bombs[bombs.size] = bomb;
			else
				sites[sites.size] = bomb;

			continue;
		}

		if ( bomb.label == "_b" )
		{
			if ( level.bombBPlanted )
				bombs[bombs.size] = bomb;
			else
				sites[sites.size] = bomb;

			continue;
		}
	}

	timeleft = maps\mp\gametypes\_gamelogic::getTimeRemaining() / 1000;

	shouldLet = ( timeleft < 60 && ( ( bombed == 0 && bombs.size != 2 ) || ( game["teamScores"][myteam] > game["teamScores"][otherTeam] && bombed == 1 ) ) && randomInt( 100 ) < 98 );

	//spawnkill conditions
	//if nothing to defuse with a lot of time left, spawn kill
	//or letting a bomb site to explode but a bomb is planted, so spawnkill
	if ( ( !bombs.size && timeleft >= 60 && randomInt( 100 ) < 95 ) || ( shouldLet && bombs.size == 1 ) )
	{
		if ( self HasScriptGoal() )
			return;

		spawnPoints = maps\mp\gametypes\_spawnlogic::getSpawnpointArray( "mp_dd_spawn_attacker_start" );

		if ( !spawnPoints.size )
			return;

		spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random( spawnPoints );

		if ( DistanceSquared( spawnpoint.origin, self.origin ) <= 2048 * 2048 )
			return;

		self SetScriptGoal( spawnpoint.origin, 1024 );

		self thread bot_dem_defend_spawnkill();

		if ( self waittill_any_return( "goal", "bad_path", "new_goal" ) != "new_goal" )
			self ClearScriptGoal();

		return;
	}

	//let blow up conditions
	//let enemy blow up at least one to extend play time
	//or if want to go into overtime after extended game
	if ( shouldLet )
	{
		spawnPoints = maps\mp\gametypes\_spawnlogic::getSpawnpointArray( "mp_dd_spawn_defender_start" );

		if ( !spawnPoints.size )
			return;

		spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random( spawnPoints );

		if ( DistanceSquared( spawnpoint.origin, self.origin ) <= 1024 * 1024 )
			return;

		self.bot_lock_goal = true;
		self SetScriptGoal( spawnpoint.origin, 512 );

		if ( self waittill_any_return( "goal", "bad_path", "new_goal" ) != "new_goal" )
			self ClearScriptGoal();

		self.bot_lock_goal = false;
		return;
	}

	//defend conditions
	//if no bombs planted with little time left
	if ( !bombs.size && timeleft < 60 && randomInt( 100 ) < 95 && sites.size )
	{
		site = self bot_array_nearest_curorigin( sites );
		origin = ( site.curorigin[0] + 50, site.curorigin[1] + 50, site.curorigin[2] + 5 );

		if ( site IsInUse() ) //somebody is planting
		{
			self BotNotifyBotEvent( "dem", "start", "planter", site );

			self.bot_lock_goal = true;
			self SetScriptGoal( origin, 64 );

			self thread bot_defend_site( site );

			if ( self waittill_any_return( "goal", "bad_path", "new_goal" ) != "new_goal" )
				self ClearScriptGoal();

			self.bot_lock_goal = false;

			self BotNotifyBotEvent( "dem", "stop", "planter", site );
			return;
		}

		//else hang around the site

		if ( DistanceSquared( origin, self.origin ) <= 1024 * 1024 )
			return;

		self.bot_lock_goal = true;
		self SetScriptGoal( origin, 256 );

		if ( self waittill_any_return( "goal", "bad_path", "new_goal" ) != "new_goal" )
			self ClearScriptGoal();

		self.bot_lock_goal = false;
		return;
	}

	//else go defuse

	if ( !bombs.size )
		return;

	defuse = self bot_array_nearest_curorigin( bombs );

	if ( !isDefined( defuse ) )
		return;

	if ( !isDefined( defuse.bots ) )
		defuse.bots = 0;

	origin = ( defuse.curorigin[0] + 50, defuse.curorigin[1] + 50, defuse.curorigin[2] + 5 );

	//hang around the site if not in danger of losing
	if ( defuse.bots > 1 && bombed + bombs.size != 2 )
	{
		if ( self HasScriptGoal() )
			return;

		if ( DistanceSquared( origin, self.origin ) <= 1024 * 1024 )
			return;

		self SetScriptGoal( origin, 256 );

		self thread bot_dem_go_defuse( defuse );

		if ( self waittill_any_return( "goal", "bad_path", "new_goal" ) != "new_goal" )
			self ClearScriptGoal();

		return;
	}

	self BotNotifyBotEvent( "dem", "go", "defuse", defuse );

	self.bot_lock_goal = true;

	self SetScriptGoal( origin, 1 );
	self thread bot_inc_bots( defuse );
	self thread bot_dem_go_defuse( defuse );

	event = self waittill_any_return( "goal", "bad_path", "new_goal" );

	if ( event != "new_goal" )
		self ClearScriptGoal();

	if ( event != "goal" || ( defuse.label == "_b" && !level.bombBPlanted ) || ( defuse.label == "_a" && !level.bombAPlanted ) || defuse IsInUse() || !self isTouching( defuse.trigger ) || self InLastStand() || self HasThreat() )
	{
		self.bot_lock_goal = false;
		return;
	}

	self BotNotifyBotEvent( "dem", "start", "defuse", defuse );

	self BotRandomStance();
	self SetScriptGoal( self.origin, 64 );
	self bot_wait_stop_move();

	waitTime = ( defuse.useTime / 1000 ) + 2.5;
	self thread BotPressUse( waitTime );
	wait waitTime;

	self ClearScriptGoal();

	self.bot_lock_goal = false;

	self BotNotifyBotEvent( "dem", "stop", "defuse", defuse );
}

/*
	Bots play demo defenders
*/
bot_dem_defenders()
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon( "game_ended" );

	if ( level.gametype != "dd" )
		return;

	if ( self.team == game["attackers"] )
		return;

	if ( inOvertime() )
		return;

	for ( ;; )
	{
		wait( randomintrange( 3, 5 ) );

		if ( self IsUsingRemote() || self.bot_lock_goal )
		{
			continue;
		}

		if ( !isDefined( level.bombZones ) || !level.bombZones.size )
			continue;

		self bot_dem_defenders_loop();
	}
}

/*
	Bots play demo overtime
*/
bot_dem_overtime()
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon( "game_ended" );

	if ( level.gametype != "dd" )
		return;

	if ( !inOvertime() )
		return;

	for ( ;; )
	{
		wait( randomintrange( 3, 5 ) );

		if ( self IsUsingRemote() || self.bot_lock_goal )
		{
			continue;
		}

		if ( !isDefined( level.bombZones ) || !level.bombZones.size )
			continue;

		if ( !level.bombZones[0].bombPlanted || !level.bombZones[0] maps\mp\gametypes\_gameobjects::isFriendlyTeam( self.team ) )
		{
			self bot_dem_attackers_loop();
			continue;
		}

		self bot_dem_defenders_loop();
	}
}

/*
	Bots go defuse
*/
bot_dem_go_defuse( defuse )
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon( "game_ended" );
	self endon( "goal" );
	self endon( "bad_path" );
	self endon( "new_goal" );

	for ( ;; )
	{
		wait 0.5;

		if ( self isTouching( defuse.trigger ) )
			break;

		if ( ( defuse.label == "_b" && !level.bombBPlanted ) || ( defuse.label == "_a" && !level.bombAPlanted ) )
			break;
	}

	if ( ( defuse.label == "_b" && !level.bombBPlanted ) || ( defuse.label == "_a" && !level.bombAPlanted ) )
		self notify( "bad_path" );
	else
		self notify( "goal" );
}

/*
	Bots go spawn kill
*/
bot_dem_defend_spawnkill()
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon( "game_ended" );
	self endon( "goal" );
	self endon( "bad_path" );
	self endon( "new_goal" );

	for ( ;; )
	{
		wait 0.5;

		if ( level.bombBPlanted || level.bombAPlanted )
			break;
	}

	self notify( "bad_path" );
}

/*
	Bots think to revive
*/
bot_think_revive_loop()
{
	needsRevives = [];

	for ( i = 0; i < level.players.size; i++ )
	{
		player = level.players[i];

		if ( player.team != self.team )
			continue;

		if ( distanceSquared( self.origin, player.origin ) >= 2048 * 2048 )
			continue;

		if ( player inLastStand() )
			needsRevives[needsRevives.size] = player;
	}

	if ( !needsRevives.size )
		return;

	revive = random( needsRevives );

	self BotNotifyBotEvent( "revive", "go", revive );
	self.bot_lock_goal = true;

	self SetScriptGoal( revive.origin, 64 );
	self thread stop_go_target_on_death( revive );

	ret = self waittill_any_return( "new_goal", "goal", "bad_path" );

	if ( ret != "new_goal" )
		self ClearScriptGoal();

	self.bot_lock_goal = false;

	if ( ret != "goal" || !isDefined( revive ) || distanceSquared( self.origin, revive.origin ) >= 100 * 100 || !revive inLastStand() || revive isBeingRevived() || !isAlive( revive ) )
		return;

	self BotNotifyBotEvent( "revive", "start", revive );

	self BotFreezeControls( true );
	self bot_wait_stop_move();

	waitTime = 3.25;
	self thread BotPressUse( waitTime );
	wait waitTime;

	self BotFreezeControls( false );

	self BotNotifyBotEvent( "revive", "stop", revive );
}

/*
	Bots think to revive
*/
bot_think_revive()
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon( "game_ended" );

	if ( !level.dieHardMode || !level.teamBased )
		return;

	for ( ;; )
	{
		wait( randomintrange( 1, 3 ) );

		if ( self HasScriptGoal() || self.bot_lock_goal )
			continue;

		if ( self isDefusing() || self isPlanting() )
			continue;

		if ( self IsUsingRemote() || self BotIsFrozen() )
			continue;

		if ( self inLastStand() )
			continue;

		self bot_think_revive_loop();
	}
}

/*
	Bots play the Global thermonuclear warfare
*/
bot_gtnw_loop()
{
	myteam = self.team;
	theirteam = getOtherTeam( myteam );
	origin = level.nukeSite.trigger.origin;
	trigger = level.nukeSite.trigger;

	ourCapCount = level.nukeSite.touchList[myteam];
	theirCapCount = level.nukeSite.touchList[theirteam];
	rand = self BotGetRandom();

	if ( ( !ourCapCount && !theirCapCount ) || rand <= 20 )
	{
		// go cap the obj
		self BotNotifyBotEvent( "gtnw", "go", "cap" );

		self.bot_lock_goal = true;
		self SetScriptGoal( origin, 64 );
		self thread bots_watch_touch_obj( trigger );

		ret = self waittill_any_return( "goal", "bad_path", "new_goal" );

		if ( ret != "new_goal" )
			self ClearScriptGoal();

		if ( ret != "goal" || !self isTouching( trigger ) )
		{
			self.bot_lock_goal = false;
			return;
		}

		self BotNotifyBotEvent( "gtnw", "start", "cap" );

		self SetScriptGoal( self.origin, 64 );

		while ( self isTouching( trigger ) )
		{
			cur = level.nukeSite.curProgress;
			wait 0.5;

			if ( cur == level.nukeSite.curProgress )
				break;//no prog made, enemy must be capping

			self thread bot_do_random_action_for_objective( trigger );
		}

		self ClearScriptGoal();
		self.bot_lock_goal = false;

		self BotNotifyBotEvent( "gtnw", "stop", "cap" );
		return;
	}

	if ( theirCapCount )
	{
		// kill capturtour
		self.bot_lock_goal = true;

		self SetScriptGoal( origin, 64 );
		self thread bots_watch_touch_obj( trigger );

		if ( self waittill_any_return( "goal", "bad_path", "new_goal" ) != "new_goal" )
			self ClearScriptGoal();

		self.bot_lock_goal = false;
		return;
	}

	//else hang around the site
	if ( DistanceSquared( origin, self.origin ) <= 1024 * 1024 )
		return;

	self.bot_lock_goal = true;
	self SetScriptGoal( origin, 256 );

	if ( self waittill_any_return( "goal", "bad_path", "new_goal" ) != "new_goal" )
		self ClearScriptGoal();

	self.bot_lock_goal = false;
}

/*
	Bots play the Global thermonuclear warfare
*/
bot_gtnw()
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon( "game_ended" );

	if ( level.gametype != "gtnw" )
		return;

	for ( ;; )
	{
		wait( randomintrange( 3, 5 ) );

		if ( self IsUsingRemote() || self.bot_lock_goal )
		{
			continue;
		}

		if ( !isDefined( level.nukeSite ) || !isDefined( level.nukeSite.trigger ) )
			continue;

		self bot_gtnw_loop();
	}
}

/*
	Bots play oneflag
*/
bot_oneflag_loop()
{
	myTeam = self.pers[ "team" ];
	otherTeam = getOtherTeam( myTeam );

	if ( myteam == game["attackers"] )
	{
		myzone = level.capZones[myteam];
		theirflag = level.teamFlags[otherTeam];

		if ( self isFlagCarrier() )
		{
			//go cap
			origin = myzone.curorigin;

			self BotNotifyBotEvent( "oneflag", "start", "cap" );

			self.bot_lock_goal = true;
			self SetScriptGoal( origin, 32 );

			evt = self waittill_any_return( "goal", "bad_path", "new_goal" );

			wait 1;

			if ( evt != "new_goal" )
				self ClearScriptGoal();

			self.bot_lock_goal = false;

			self BotNotifyBotEvent( "oneflag", "stop", "cap" );
			return;
		}

		carrier = theirflag.carrier;

		if ( !isDefined( carrier ) ) //if no one has enemy flag
		{
			self BotNotifyBotEvent( "oneflag", "start", "their_flag" );
			self bot_cap_get_flag( theirflag );
			self BotNotifyBotEvent( "oneflag", "stop", "their_flag" );
			return;
		}

		//escort them

		if ( self HasScriptGoal() )
			return;

		origin = carrier.origin;

		if ( DistanceSquared( origin, self.origin ) <= 1024 * 1024 )
			return;

		self SetScriptGoal( origin, 256 );
		self thread bot_escort_obj( theirflag, carrier );

		if ( self waittill_any_return( "goal", "bad_path", "new_goal" ) != "new_goal" )
			self ClearScriptGoal();
	}
	else
	{
		myflag = level.teamFlags[myteam];
		theirzone = level.capZones[otherTeam];

		if ( !myflag maps\mp\gametypes\_gameobjects::isHome() )
		{
			carrier = myflag.carrier;

			if ( !isDefined( carrier ) ) //someone doesnt has our flag
			{
				self BotNotifyBotEvent( "oneflag", "start", "my_flag" );
				self bot_cap_get_flag( myflag );
				self BotNotifyBotEvent( "oneflag", "stop", "my_flag" );
				return;
			}

			if ( self HasScriptGoal() )
				return;

			if ( !isDefined( theirzone.bots ) )
				theirzone.bots = 0;

			origin = theirzone.curorigin;

			if ( theirzone.bots > 2 || randomInt( 100 ) < 45 )
			{
				//kill carrier
				if ( carrier _hasPerk( "specialty_coldblooded" ) )
					return;

				origin = carrier.origin;

				self SetScriptGoal( origin, 64 );
				self thread bot_escort_obj( myflag, carrier );

				if ( self waittill_any_return( "goal", "bad_path", "new_goal" ) != "new_goal" )
					self ClearScriptGoal();

				return;
			}

			self thread bot_inc_bots( theirzone );

			//camp their zone
			if ( DistanceSquared( origin, self.origin ) <= 1024 * 1024 )
			{
				wait 4;
				self notify( "bot_inc_bots" );
				theirzone.bots--;
				return;
			}

			self SetScriptGoal( origin, 256 );
			self thread bot_inc_bots( theirzone );
			self thread bot_escort_obj( myflag, carrier );

			if ( self waittill_any_return( "goal", "bad_path", "new_goal" ) != "new_goal" )
				self ClearScriptGoal();
		}
		else
		{
			// is home, lets hang around and protect
			if ( self HasScriptGoal() )
				return;

			origin = myflag.curorigin;

			if ( DistanceSquared( origin, self.origin ) <= 1024 * 1024 )
				return;

			self SetScriptGoal( origin, 256 );
			self thread bot_get_obj( myflag );

			if ( self waittill_any_return( "goal", "bad_path", "new_goal" ) != "new_goal" )
				self ClearScriptGoal();
		}
	}
}

/*
	Bots play oneflag
*/
bot_oneflag()
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon( "game_ended" );

	if ( level.gametype != "oneflag" )
		return;

	for ( ;; )
	{
		wait( randomintrange( 3, 5 ) );

		if ( self IsUsingRemote() || self.bot_lock_goal )
		{
			continue;
		}

		if ( !isDefined( level.capZones ) || !isDefined( level.teamFlags ) )
			continue;

		self bot_oneflag_loop();
	}
}

/*
	Bots play arena
*/
bot_arena_loop()
{
	flag = level.arenaFlag;
	myTeam = self.team;

	self BotNotifyBotEvent( "arena", "go", "cap" );

	self.bot_lock_goal = true;
	self SetScriptGoal( flag.trigger.origin, 64 );

	event = self waittill_any_return( "goal", "bad_path", "new_goal" );

	if ( event != "new_goal" )
		self ClearScriptGoal();

	if ( event != "goal" || !self isTouching( flag.trigger ) )
	{
		self.bot_lock_goal = false;
		return;
	}

	self BotNotifyBotEvent( "arena", "start", "cap" );

	self SetScriptGoal( self.origin, 64 );

	while ( self isTouching( flag.trigger ) && flag.ownerTeam != myTeam )
	{
		cur = flag.curProgress;
		wait 0.5;

		if ( cur == flag.curProgress )
			break;//no prog made, enemy must be capping

		self thread bot_do_random_action_for_objective( flag.trigger );
	}

	self ClearScriptGoal();
	self.bot_lock_goal = false;

	self BotNotifyBotEvent( "arena", "stop", "cap" );
}

/*
	Bots play arena
*/
bot_arena()
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon( "game_ended" );

	if ( level.gametype != "arena" )
		return;

	for ( ;; )
	{
		wait( randomintrange( 3, 5 ) );

		if ( self IsUsingRemote() || self.bot_lock_goal )
		{
			continue;
		}

		if ( !isDefined( level.arenaFlag ) )
			continue;

		self bot_arena_loop();
	}
}

/*
	bot_vip_loop

	For those wondering why i call a function for these loops like this
	its because, the variables created in this function will be free'd once the function exits,
	if it was in the infinite loop, the function never exits, thus the variables are never free'd

	This isnt leaking variables, but freeing variables that will no longer be used, an optimization of sorts
*/
bot_vip_loop()
{
	vip = undefined;

	for ( i = 0; i < level.players.size; i++ )
	{
		player = level.players[i];

		if ( !isReallyAlive( player ) )
			continue;

		if ( isDefined( player.isVip ) && player.isVip )
			vip = player;
	}

	if ( self.team == game["defenders"] )
	{
		if ( isDefined( self.isVip ) && self.isVip )
		{
			if ( isDefined( level.extractionZone ) && !isDefined( level.extractionTime ) )
			{
				// go to extraction zone
				self BotNotifyBotEvent( "vip", "start", "cap" );

				self.bot_lock_goal = true;
				self SetScriptGoal( level.extractionZone.trigger.origin, 32 );

				evt = self waittill_any_return( "goal", "bad_path", "new_goal" );

				wait 1;

				if ( evt != "new_goal" )
					self ClearScriptGoal();

				self.bot_lock_goal = false;

				self BotNotifyBotEvent( "vip", "stop", "cap" );
			}
		}
		else if ( isDefined( vip ) )
		{
			// protect the vip
			if ( DistanceSquared( vip.origin, self.origin ) <= 1024 * 1024 )
				return;

			self SetScriptGoal( vip.origin, 256 );

			if ( self waittill_any_return( "goal", "bad_path", "new_goal" ) != "new_goal" )
				self ClearScriptGoal();
		}
	}
	else
	{
		if ( isDefined( level.extractionZone ) && !isDefined( level.extractionTime ) && self BotGetRandom() < 65 )
		{
			// camp the extraction zone
			if ( DistanceSquared( level.extractionZone.trigger.origin, self.origin ) <= 1024 * 1024 )
				return;

			self SetScriptGoal( level.extractionZone.trigger.origin, 256 );

			if ( self waittill_any_return( "goal", "bad_path", "new_goal" ) != "new_goal" )
				self ClearScriptGoal();
		}
		else if ( isDefined( vip ) )
		{
			// kill the vip
			self SetScriptGoal( vip.origin, 32 );

			if ( self waittill_any_return( "goal", "bad_path", "new_goal" ) != "new_goal" )
				self ClearScriptGoal();
		}
	}
}

/*
	Bots play arena
*/
bot_vip()
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon( "game_ended" );

	if ( level.gametype != "vip" )
		return;

	for ( ;; )
	{
		wait( randomintrange( 3, 5 ) );

		if ( self IsUsingRemote() || self.bot_lock_goal )
		{
			continue;
		}

		self bot_vip_loop();
	}
}

/*
	Loop
*/
bot_conf_loop()
{
	dog_tag_keys = getArrayKeys( level.dogtags );
	tags = [];
	tag = undefined;

	for ( i = 0; i < dog_tag_keys.size; i++ )
	{
		temp_tag = level.dogtags[dog_tag_keys[i]];

		if ( !isDefined( temp_tag ) )
			continue;

		if ( DistanceSquared( self.origin, temp_tag.trigger.origin ) > 1024 * 1024 )
			continue;

		if ( !isDefined( temp_tag.bots ) )
			temp_tag.bots = 0;

		if ( temp_tag.bots >= 2 )
			continue;

		tags[tags.size] = temp_tag;
	}

	if ( randomInt( 2 ) )
	{
		for ( i = 0; i < tags.size; i++ )
		{
			temp_tag = tags[i];

			if ( !isDefined( tag ) || DistanceSquared( self.origin, temp_tag.trigger.origin ) < DistanceSquared( self.origin, tag.trigger.origin ) )
			{
				tag = temp_tag;
			}
		}
	}
	else
	{
		tag = random( tags );
	}

	if ( !isdefined( tag ) )
		return;

	self BotNotifyBotEvent( "conf", "start", "cap", tag );

	self.bot_lock_goal = true;
	self SetScriptGoal( tag.trigger.origin, 16 );
	self thread bot_inc_bots( tag, true );
	self thread bots_watch_touch_obj( tag.trigger );

	if ( self waittill_any_return( "goal", "bad_path", "new_goal" ) != "new_goal" )
		self ClearScriptGoal();

	self.bot_lock_goal = false;

	self BotNotifyBotEvent( "conf", "stop", "cap", tag );
}

/*
	Bots play conf
*/
bot_conf()
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon( "game_ended" );

	if ( level.gametype != "conf" )
		return;

	for ( ;; )
	{
		wait( randomintrange( 1, 2 ) );

		if ( self IsUsingRemote() || self.bot_lock_goal )
		{
			continue;
		}

		if ( !isdefined( level.dogtags ) )
		{
			continue;
		}

		self bot_conf_loop();
	}
}

/*
	Watches for grnd zone
*/
bots_watch_grnd()
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "goal" );
	self endon( "bad_path" );
	self endon( "new_goal" );

	grnd_origin = level.grnd_zone.origin;

	for ( ;; )
	{
		wait 1 + randomInt( 5 ) * 0.5;

		if ( grnd_origin != level.grnd_zone.origin )
			break;

		if ( self maps\mp\gametypes\grnd::isingrindzone() )
			break;
	}

	if ( grnd_origin != level.grnd_zone.origin )
		self notify( "bad_path" );
	else
		self notify( "goal" );
}

/*
	Loop
*/
bot_grnd_loop()
{
	if ( isDefined( self.inGrindZone ) && self.inGrindZone && isReallyAlive( self ) && self.pers["team"] != "spectator" && self maps\mp\gametypes\grnd::isingrindzone() )
	{
		// in the grnd zone

		if ( level.grnd_numplayers[level.otherTeam[self.team]] )
		{
			// hunt enemy in drop zone
			target = undefined;

			for ( i = 0; i < level.players.size; i++ )
			{
				player = level.players[i];

				if ( isDefined( player.inGrindZone ) && player.inGrindZone && isReallyAlive( player ) && player.pers["team"] != "spectator" && player maps\mp\gametypes\grnd::isingrindzone() )
				{
					target = player;

					if ( cointoss() )
						break;
				}
			}

			if ( isDefined( target ) )
			{
				self BotNotifyBotEvent( "grnd", "start", "kill", target );

				self SetScriptGoal( target.origin, 32 );
				self thread stop_go_target_on_death( target );

				if ( self waittill_any_return( "goal", "bad_path", "new_goal" ) != "new_goal" )
					self ClearScriptGoal();

				self BotNotifyBotEvent( "grnd", "stop", "kill", target );
			}
		}
		else
		{
			// stay in the zone
			goal = self.origin;
			self SetScriptGoal( goal, 64 );

			self BotNotifyBotEvent( "grnd", "start", "cap" );

			while ( self HasScriptGoal() && self GetScriptGoal() == goal && self maps\mp\gametypes\grnd::isingrindzone() )
			{
				if ( level.grnd_numplayers[level.otherTeam[self.team]] )
					break;

				wait 0.5;

				self thread bot_do_random_action_for_objective( level.grnd_zone );
			}

			if ( self HasScriptGoal() && self GetScriptGoal() == goal )
				self ClearScriptGoal();

			self BotNotifyBotEvent( "grnd", "start", "stop" );
		}

		return;
	}

	if ( randomInt( 100 ) < 40 || level.grnd_numplayers[self.team] <= 0 )
	{
		self BotNotifyBotEvent( "grnd", "start", "go_cap" );

		// go to grnd zone
		self.bot_lock_goal = true;
		self SetScriptGoal( level.grnd_zone.origin, 32 );
		self thread bots_watch_grnd();

		if ( self waittill_any_return( "goal", "bad_path", "new_goal" ) != "new_goal" )
			self ClearScriptGoal();

		self.bot_lock_goal = false;

		self BotNotifyBotEvent( "grnd", "stop", "go_cap" );
	}
}

/*
	Bots play groundzone
*/
bot_grnd()
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon( "game_ended" );

	if ( level.gametype != "grnd" )
		return;

	for ( ;; )
	{
		wait( randomintrange( 1, 3 ) );

		if ( self IsUsingRemote() || self.bot_lock_goal )
		{
			continue;
		}

		if ( !isdefined( level.grnd_zone ) )
		{
			continue;
		}

		self bot_grnd_loop();
	}
}

/*
	Loop
*/
bot_tdef_loop()
{
	if ( isDefined( level.gameFlag.carrier ) )
	{
		if ( level.gameFlag maps\mp\gametypes\_gameobjects::getOwnerTeam() == level.otherTeam[self.team] )
		{
			// go kill
			self SetScriptGoal( level.gameFlag.carrier.origin, 64 );
			self thread bot_escort_obj( level.gameFlag, level.gameFlag.carrier );

			if ( self waittill_any_return( "goal", "bad_path", "new_goal" ) != "new_goal" )
				self ClearScriptGoal();
		}
		else if ( level.gameFlag.carrier != self )
		{
			// go protect
			if ( self HasScriptGoal() )
				return;

			if ( DistanceSquared( level.gameFlag.carrier.origin, self.origin ) <= 1024 * 1024 )
				return;

			self SetScriptGoal( level.gameFlag.carrier.origin, 256 );
			self thread bot_escort_obj( level.gameFlag, level.gameFlag.carrier );

			if ( self waittill_any_return( "goal", "bad_path", "new_goal" ) != "new_goal" )
				self ClearScriptGoal();
		}

		return;
	}

	//go get it
	self BotNotifyBotEvent( "tdef", "start", "cap" );

	self bot_cap_get_flag( level.gameFlag );

	self BotNotifyBotEvent( "tdef", "stop", "cap" );
}

/*
	Bots play groundzone
*/
bot_tdef()
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon( "game_ended" );

	if ( level.gametype != "tdef" )
		return;

	for ( ;; )
	{
		wait( randomintrange( 1, 3 ) );

		if ( self IsUsingRemote() || self.bot_lock_goal )
		{
			continue;
		}

		if ( !isdefined( level.gameFlag ) )
		{
			continue;
		}

		self bot_tdef_loop();
	}
}

/*
	Loop
*/
bot_infect_loop()
{
	if ( self HasScriptGoal() )
		return;

	if ( self.team == "axis" )
	{
		target = undefined;

		for ( i = 0; i < level.players.size; i++ )
		{
			player = level.players[i];

			if ( player == self )
				continue;

			if ( !isReallyAlive( player ) )
				continue;

			if ( level.teambased && self.team == player.team )
				continue;

			if ( !isdefined( target ) || DistanceSquared( self.origin, player.origin ) < DistanceSquared( self.origin, target.origin ) )
			{
				target = player;
			}
		}

		if ( isDefined( target ) )
		{
			self SetScriptGoal( target.origin, 32 );
			self thread stop_go_target_on_death( target );

			if ( self waittill_any_return( "goal", "bad_path", "new_goal" ) != "new_goal" )
				self ClearScriptGoal();
		}
	}
}

/*
	Bots play infect
*/
bot_infect()
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon( "game_ended" );

	if ( level.gametype != "infect" )
		return;

	for ( ;; )
	{
		wait( randomintrange( 1, 3 ) );

		if ( self IsUsingRemote() || self.bot_lock_goal )
		{
			continue;
		}

		self bot_infect_loop();
	}
}
