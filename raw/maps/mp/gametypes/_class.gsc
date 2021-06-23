// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

#include common_scripts\utility;
#include maps\mp\_utility;

init()
{
	level.classMap["class0"] = 0;
	level.classMap["class1"] = 1;
	level.classMap["class2"] = 2;
	level.classMap["class3"] = 3;
	level.classMap["class4"] = 4;
	level.classMap["class5"] = 5;
	level.classMap["class6"] = 6;
	level.classMap["class7"] = 7;
	level.classMap["class8"] = 8;
	level.classMap["class9"] = 9;
	level.classMap["class10"] = 10;
	level.classMap["class11"] = 11;
	level.classMap["class12"] = 12;
	level.classMap["class13"] = 13;
	level.classMap["class14"] = 14;

	level.classMap["custom1"] = 0;
	level.classMap["custom2"] = 1;
	level.classMap["custom3"] = 2;
	level.classMap["custom4"] = 3;
	level.classMap["custom5"] = 4;
	level.classMap["custom6"] = 5;
	level.classMap["custom7"] = 6;
	level.classMap["custom8"] = 7;
	level.classMap["custom9"] = 8;
	level.classMap["custom10"] = 9;
	level.classMap["custom11"] = 10;
	level.classMap["custom12"] = 11;
	level.classMap["custom13"] = 12;
	level.classMap["custom14"] = 13;
	level.classMap["custom15"] = 14;

	level.classMap["axis_recipe1"] = 0;
	level.classMap["axis_recipe2"] = 1;
	level.classMap["axis_recipe3"] = 2;
	level.classMap["axis_recipe4"] = 3;
	level.classMap["axis_recipe5"] = 4;

	level.classMap["allies_recipe1"] = 0;
	level.classMap["allies_recipe2"] = 1;
	level.classMap["allies_recipe3"] = 2;
	level.classMap["allies_recipe4"] = 3;
	level.classMap["allies_recipe5"] = 4;

	level.classMap["copycat"] = -1;

	level.defaultClass = "CLASS_ASSAULT";

	level.classTableName = "mp/classTable.csv";

	level thread onPlayerConnecting();
}

getClassChoice( response )
{
	return response;
}

getWeaponChoice( response )
{
	tokens = strtok( response, "," );

	if ( tokens.size > 1 )
		return int( tokens[1] );
	else
		return 0;
}

logClassChoice( class, primaryWeapon, specialType, perks )
{
	if ( class == self.lastClass )
		return;

	self logstring( "choseclass: " + class + " weapon: " + primaryWeapon + " special: " + specialType );

	for ( i = 0; i < perks.size; i++ )
		self logstring( "perk" + i + ": " + perks[i] );

	self.lastClass = class;
}

cac_getCustomClassLoc()
{
	if ( getdvarint( "xblive_privatematch" ) || getdvarint( "xblive_competitionmatch" ) && getdvarint( "systemlink" ) )
		return "privateMatchCustomClasses";
	else if ( getdvarint( "xblive_competitionmatch" ) && ( !level.console && ( getdvar( "dedicated" ) == "dedicated LAN server" || getdvar( "dedicated" ) == "dedicated internet server" ) ) )
		return "privateMatchCustomClasses";
	else
		return "customClasses";
}

cac_getWeapon( classIndex, weaponIndex )
{
	customClassLoc = cac_getCustomClassLoc();
	return self getPlayerData( customClassLoc, classIndex, "weaponSetups", weaponIndex, "weapon" );
}

cac_getWeaponAttachment( classIndex, weaponIndex )
{
	customClassLoc = cac_getCustomClassLoc();
	return self getPlayerData( customClassLoc, classIndex, "weaponSetups", weaponIndex, "attachment", 0 );
}

cac_getWeaponAttachmentTwo( classIndex, weaponIndex )
{
	customClassLoc = cac_getCustomClassLoc();
	return self getPlayerData( customClassLoc, classIndex, "weaponSetups", weaponIndex, "attachment", 1 );
}

cac_getWeaponBuff( classIndex, weaponIndex )
{
	customClassLoc = cac_getCustomClassLoc();
	return self getPlayerData( customClassLoc, classIndex, "weaponSetups", weaponIndex, "buff" );
}

cac_getWeaponCamo( classIndex, weaponIndex )
{
	customClassLoc = cac_getCustomClassLoc();
	return self getPlayerData( customClassLoc, classIndex, "weaponSetups", weaponIndex, "camo" );
}

cac_getWeaponReticle( classIndex, weaponIndex )
{
	customClassLoc = cac_getCustomClassLoc();
	return self getPlayerData( customClassLoc, classIndex, "weaponSetups", weaponIndex, "reticle" );
}

cac_getPerk( classIndex, perkIndex )
{
	customClassLoc = cac_getCustomClassLoc();
	return self getPlayerData( customClassLoc, classIndex, "perks", perkIndex );
}

cac_getKillstreak( class_num, streakType, streakIndex )
{
	playerData = undefined;
	switch( streakType )
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
	customClassLoc = cac_getCustomClassLoc();
	return self getPlayerData( customClassLoc, class_num, playerData, streakIndex );
}

cac_getDeathstreak( classIndex )
{
	customClassLoc = cac_getCustomClassLoc();
	return self getPlayerData( customClassLoc, classIndex, "deathstreak" );
}

cac_getOffhand( classIndex )
{
	customClassLoc = cac_getCustomClassLoc();
	return self getPlayerData( customClassLoc, classIndex, "perks", 6 );
}

recipe_getKillstreak( teamName, classIndex, streakType, streakIndex )
{
	playerData = undefined;
	switch( streakType )
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
	return getMatchRulesData( "defaultClasses", teamName, classIndex, "class", playerData, streakIndex );
}


table_getWeapon( tableName, classIndex, weaponIndex )
{
	if ( weaponIndex == 0 )
		return tableLookup( tableName, 0, "loadoutPrimary", classIndex + 1 );
	else
		return tableLookup( tableName, 0, "loadoutSecondary", classIndex + 1 );
}

table_getWeaponAttachment( tableName, classIndex, weaponIndex, attachmentIndex )
{
	tempName = "none";
	
	if ( weaponIndex == 0 )
	{
		if ( !isDefined( attachmentIndex ) || attachmentIndex == 0 )
			tempName = tableLookup( tableName, 0, "loadoutPrimaryAttachment", classIndex + 1 );
		else
			tempName = tableLookup( tableName, 0, "loadoutPrimaryAttachment2", classIndex + 1 );
	}
	else
	{
		if ( !isDefined( attachmentIndex ) || attachmentIndex == 0 )
			tempName = tableLookup( tableName, 0, "loadoutSecondaryAttachment", classIndex + 1 );
		else
			tempName = tableLookup( tableName, 0, "loadoutSecondaryAttachment2", classIndex + 1 );
	}
	
	if ( tempName == "" || tempName == "none" )
		return "none";
	else
		return tempName;
	
	
}

table_getWeaponBuff( tableName, classIndex, weaponIndex )
{
	if ( weaponIndex == 0 )
		return tableLookup( tableName, 0, "loadoutPrimaryBuff", classIndex + 1 );
	else
		return tableLookup( tableName, 0, "loadoutSecondaryBuff", classIndex + 1 );
}

table_getWeaponCamo( tableName, classIndex, weaponIndex )
{
	if ( weaponIndex == 0 )
		return tableLookup( tableName, 0, "loadoutPrimaryCamo", classIndex + 1 );
	else
		return tableLookup( tableName, 0, "loadoutSecondaryCamo", classIndex + 1 );
}

table_getWeaponReticle( tableName, classIndex, weaponIndex )
{
	return "none";
}

table_getEquipment( tableName, classIndex, perkIndex )
{
	return tableLookup( tableName, 0, "loadoutEquipment", classIndex + 1 );
}

table_getPerk( tableName, classIndex, perkIndex )
{
	return tablelookup( tableName, 0, "loadoutPerk" + perkIndex, classIndex + 1 );
}

table_getTeamPerk( tableName, classIndex )
{
	return tableLookup( tableName, 0, "loadoutTeamPerk", classIndex + 1 );
}

table_getOffhand( tableName, classIndex )
{
	return tableLookup( tableName, 0, "loadoutOffhand", classIndex + 1 );
}

table_getKillstreak( tableName, classIndex, streakIndex )
{
	return tableLookup( tableName, 0, "loadoutStreak" + streakIndex, classIndex + 1 );
}

table_getDeathstreak( tableName, classIndex )
{
	return tableLookup( tableName, 0, "loadoutDeathstreak", classIndex + 1 );
}

getClassIndex( className )
{
	return level.classMap[className];
}

cloneLoadout()
{
	teamName = "none";
	
	clonedLoadout = [];
	
	class = self.curClass;
	
	if ( class == "copycat" )
		return ( undefined );

	if( isSubstr( class, "axis" ) )
	{
		teamName = "axis";
	}
	else if( isSubstr( class, "allies" ) )
	{
		teamName = "allies";
	}
	
	if (teamName != "none")
	{
		classIndex = getClassIndex( class );

		loadoutPrimaryAttachment2 = "none";
		loadoutSecondaryAttachment2 = "none";

		loadoutPrimary = getMatchRulesData( "defaultClasses", teamName, classIndex, "class", "weaponSetups", 0, "weapon" );
		loadoutPrimaryAttachment = getMatchRulesData( "defaultClasses", teamName, classIndex, "class", "weaponSetups", 0, "attachment", 0 );
		loadoutPrimaryAttachment2 = getMatchRulesData( "defaultClasses", teamName, classIndex, "class", "weaponSetups", 0, "attachment", 1 );
		loadoutPrimaryBuff = getMatchRulesData( "defaultClasses", teamName, classIndex, "class", "weaponSetups", 0, "buff" );
		loadoutPrimaryCamo = getMatchRulesData( "defaultClasses", teamName, classIndex, "class", "weaponSetups", 0, "camo" );
		loadoutPrimaryReticle = getMatchRulesData( "defaultClasses", teamName, classIndex, "class", "weaponSetups", 0, "reticle" );

		loadoutSecondary = getMatchRulesData( "defaultClasses", teamName, classIndex, "class", "weaponSetups", 1, "weapon" );
		loadoutSecondaryAttachment = getMatchRulesData( "defaultClasses", teamName, classIndex, "class", "weaponSetups", 1, "attachment", 0 );
		loadoutSecondaryAttachment2 = getMatchRulesData( "defaultClasses", teamName, classIndex, "class", "weaponSetups", 1, "attachment", 1 );
		loadoutSecondaryBuff = getMatchRulesData( "defaultClasses", teamName, classIndex, "class", "weaponSetups", 1, "buff" );
		loadoutSecondaryCamo = getMatchRulesData( "defaultClasses", teamName, classIndex, "class", "weaponSetups", 1, "camo" );
		loadoutSecondaryReticle = getMatchRulesData( "defaultClasses", teamName, classIndex, "class", "weaponSetups", 1, "reticle" );

		loadoutEquipment = getMatchRulesData( "defaultClasses", teamName, classIndex, "class", "perks", 0 );
		loadoutPerk1 = getMatchRulesData( "defaultClasses", teamName, classIndex, "class", "perks", 1 );
		loadoutPerk2 = getMatchRulesData( "defaultClasses", teamName, classIndex, "class", "perks", 2 );
		loadoutPerk3 = getMatchRulesData( "defaultClasses", teamName, classIndex, "class", "perks", 3 );
		loadoutStreakType = getMatchRulesData( "defaultClasses", teamName, classIndex, "class", "perks", 5 );
		loadoutKillstreak1 = recipe_getKillstreak( teamName, classIndex, loadoutStreakType, 0 );
		loadoutKillstreak2 = recipe_getKillstreak( teamName, classIndex, loadoutStreakType, 1 );
		loadoutKillstreak3 = recipe_getKillstreak( teamName, classIndex, loadoutStreakType, 2 );
		loadoutOffhand = getMatchRulesData( "defaultClasses", teamName, classIndex, "class", "perks", 6 );
		loadoutDeathStreak = getMatchRulesData( "defaultClasses", teamName, classIndex, "class", "deathstreak" );
	}
	else if( isSubstr( class, "custom" ) )
	{
		class_num = getClassIndex( class );

		loadoutPrimaryAttachment2 = "none";
		loadoutSecondaryAttachment2 = "none";

		loadoutPrimary = cac_getWeapon( class_num, 0 );
		loadoutPrimaryAttachment = cac_getWeaponAttachment( class_num, 0 );
		loadoutPrimaryAttachment2 = cac_getWeaponAttachmentTwo( class_num, 0 );
		loadoutPrimaryBuff = cac_getWeaponBuff( class_num, 0 );
		loadoutPrimaryCamo = cac_getWeaponCamo( class_num, 0 );
		loadoutPrimaryReticle = cac_getWeaponReticle( class_num, 0 );
		loadoutSecondary = cac_getWeapon( class_num, 1 );
		loadoutSecondaryAttachment = cac_getWeaponAttachment( class_num, 1 );
		loadoutSecondaryAttachment2 = cac_getWeaponAttachmentTwo( class_num, 1 );
		loadoutSecondaryBuff = cac_getWeaponBuff( class_num, 1 );
		loadoutSecondaryCamo = cac_getWeaponCamo( class_num, 1 );
		loadoutSecondaryReticle = cac_getWeaponReticle( class_num, 1 );
		loadoutEquipment = cac_getPerk( class_num, 0 );
		loadoutPerk1 = cac_getPerk( class_num, 1 );
		loadoutPerk2 = cac_getPerk( class_num, 2 );
		loadoutPerk3 = cac_getPerk( class_num, 3 );
		loadoutStreakType = cac_getPerk( class_num, 5 );
		loadoutKillstreak1 = cac_getKillstreak( class_num, loadoutStreakType, 0 );
		loadoutKillstreak2 = cac_getKillstreak( class_num, loadoutStreakType, 1 );
		loadoutKillstreak3 = cac_getKillstreak( class_num, loadoutStreakType, 2 );
		loadoutOffhand = cac_getOffhand( class_num );
		loadoutDeathStreak = cac_getDeathstreak( class_num );
	}
	else
	{
		class_num = getClassIndex( class );
		
		loadoutPrimary = table_getWeapon( level.classTableName, class_num, 0 );
		loadoutPrimaryAttachment = table_getWeaponAttachment( level.classTableName, class_num, 0 , 0);
		loadoutPrimaryAttachment2 = table_getWeaponAttachment( level.classTableName, class_num, 0, 1 );
		loadoutPrimaryBuff = table_getWeaponBuff( level.classTableName, class_num, 0 );
		loadoutPrimaryCamo = table_getWeaponCamo( level.classTableName, class_num, 0 );
		loadoutPrimaryReticle = table_getWeaponReticle( level.classTableName, class_num, 0 );
		loadoutSecondary = table_getWeapon( level.classTableName, class_num, 1 );
		loadoutSecondaryAttachment = table_getWeaponAttachment( level.classTableName, class_num, 1, 0);
		loadoutSecondaryAttachment2 = table_getWeaponAttachment( level.classTableName, class_num, 1, 1 );
		loadoutSecondaryBuff = table_getWeaponBuff( level.classTableName, class_num, 1 );
		loadoutSecondaryCamo = table_getWeaponCamo( level.classTableName, class_num, 1 );
		loadoutSecondaryReticle = table_getWeaponReticle( level.classTableName, class_num, 1 );
		loadoutEquipment = table_getEquipment( level.classTableName, class_num, 0 );
		loadoutPerk1 = table_getPerk( level.classTableName, class_num, 1 );
		loadoutPerk2 = table_getPerk( level.classTableName, class_num, 2 );
		loadoutPerk3 = table_getPerk( level.classTableName, class_num, 3 );
		loadoutStreakType = table_getPerk( level.classTableName, class_num, 5 );
		loadoutOffhand = table_getOffhand( level.classTableName, class_num );
		loadoutDeathStreak = table_getDeathstreak( level.classTableName, class_num );
		
		switch( loadoutStreakType )
		{
		case "streaktype_support":
			defaultKillstreak1 = table_getKillstreak( level.classTableName, 3, 1 );
			defaultKillstreak2 = table_getKillstreak( level.classTableName, 3, 2 );
			defaultKillstreak3 = table_getKillstreak( level.classTableName, 3, 3 );
			break;
		case "streaktype_specialist":
			defaultKillstreak1 = table_getKillstreak( level.classTableName, 1, 1 );
			defaultKillstreak2 = table_getKillstreak( level.classTableName, 1, 2 );
			defaultKillstreak3 = table_getKillstreak( level.classTableName, 1, 3 );
			break;
		default:
			defaultKillstreak1 = table_getKillstreak( level.classTableName, 0, 1 );
			defaultKillstreak2 = table_getKillstreak( level.classTableName, 0, 2 );
			defaultKillstreak3 = table_getKillstreak( level.classTableName, 0, 3 );
			break;
		}

		loadoutKillstreak1 = defaultKillstreak1;
		loadoutKillstreak2 = defaultKillstreak2;
		loadoutKillstreak3 = defaultKillstreak3;
	}
	
	clonedLoadout["inUse"] = false;
	clonedLoadout["loadoutPrimary"] = loadoutPrimary;
	clonedLoadout["loadoutPrimaryAttachment"] = loadoutPrimaryAttachment;
	clonedLoadout["loadoutPrimaryAttachment2"] = loadoutPrimaryAttachment2;
	clonedLoadout["loadoutPrimaryBuff"] = loadoutPrimaryBuff;
	clonedLoadout["loadoutPrimaryCamo"] = loadoutPrimaryCamo;
	clonedLoadout["loadoutPrimaryReticle"] = loadoutPrimaryReticle;
	clonedLoadout["loadoutSecondary"] = loadoutSecondary;
	clonedLoadout["loadoutSecondaryAttachment"] = loadoutSecondaryAttachment;
	clonedLoadout["loadoutSecondaryAttachment2"] = loadoutSecondaryAttachment2;
	clonedLoadout["loadoutSecondaryBuff"] = loadoutSecondaryBuff;
	clonedLoadout["loadoutSecondaryCamo"] = loadoutSecondaryCamo;
	clonedLoadout["loadoutSecondaryReticle"] = loadoutSecondaryReticle;
	clonedLoadout["loadoutEquipment"] = loadoutEquipment;
	clonedLoadout["loadoutPerk1"] = loadoutPerk1;
	clonedLoadout["loadoutPerk2"] = loadoutPerk2;
	clonedLoadout["loadoutPerk3"] = loadoutPerk3;
	clonedLoadout["loadoutStreakType"] = loadoutStreakType;
	clonedLoadout["loadoutKillstreak1"] = loadoutKillstreak1;
	clonedLoadout["loadoutKillstreak2"] = loadoutKillstreak2;
	clonedLoadout["loadoutKillstreak3"] = loadoutKillstreak3;
	clonedLoadout["loadoutDeathstreak"] = loadoutDeathstreak;
	clonedLoadout["loadoutOffhand"] = loadoutOffhand;
	
	return ( clonedLoadout );
}

loadoutFakePerks( loadoutStreakType )
{
	switch ( loadoutStreakType )
	{
		case "streaktype_support":
			self.streakType = "support";
			break;
		case "streaktype_specialist":
			self.streakType = "specialist";
			break;
		default:
			self.streakType = "assault";
	}
}

getLoadoutStreakTypeFromStreakType( streakType )
{
	if ( !isdefined( streakType ) )
		return "streaktype_assault";

	switch ( streakType )
	{
		case "support":
			return "streaktype_support";
		case "specialist":
			return "streaktype_specialist";
		case "assault":
			return "streaktype_assault";
		default:
			return "streaktype_assault";
	}
}

giveLoadout( team, class, allowCopycat, setPrimarySpawnWeapon )
{
	self takeAllWeapons();
	
	self.changingWeapon = undefined;

	teamName = "none";
	if ( !isDefined( setPrimarySpawnWeapon ) )
		setPrimarySpawnWeapon = true;

	primaryIndex = 0;
	
	self.specialty = [];

	if ( !isDefined( allowCopycat ) )
		allowCopycat = true;

	primaryWeapon = undefined;
	var_7 = 0;
	
	loadoutKillstreak1 = undefined;
	loadoutKillstreak2 = undefined;
	loadoutKillstreak3 = undefined;	

	if( isSubstr( class, "axis" ) )
	{
		teamName = "axis";
	}
	else if( isSubstr( class, "allies" ) )
	{
		teamName = "allies";
	}

	clonedLoadout = [];
	if ( isDefined( self.pers["copyCatLoadout"] ) && self.pers["copyCatLoadout"]["inUse"] && allowCopycat )
	{
		self setClass( "copycat" );
		self.class_num = getClassIndex( "copycat" );

		clonedLoadout = self.pers["copyCatLoadout"];

		loadoutPrimary = clonedLoadout["loadoutPrimary"];
		loadoutPrimaryAttachment = clonedLoadout["loadoutPrimaryAttachment"];
		loadoutPrimaryAttachment2 = clonedLoadout["loadoutPrimaryAttachment2"] ;
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
		loadoutAmmoType	 = clonedLoadout["loadoutAmmoType"];
	}
	else if ( teamName != "none" )
	{
		classIndex = getClassIndex( class );

		loadoutPrimaryAttachment2 = "none";
		loadoutSecondaryAttachment2 = "none";

		loadoutPrimary = getMatchRulesData( "defaultClasses", teamName, classIndex, "class", "weaponSetups", 0, "weapon" );
		loadoutPrimaryAttachment = getMatchRulesData( "defaultClasses", teamName, classIndex, "class", "weaponSetups", 0, "attachment", 0 );
		loadoutPrimaryAttachment2 = getMatchRulesData( "defaultClasses", teamName, classIndex, "class", "weaponSetups", 0, "attachment", 1 );
		loadoutPrimaryBuff = getMatchRulesData( "defaultClasses", teamName, classIndex, "class", "weaponSetups", 0, "buff" );
		loadoutPrimaryCamo = getMatchRulesData( "defaultClasses", teamName, classIndex, "class", "weaponSetups", 0, "camo" );
		loadoutPrimaryReticle = getMatchRulesData( "defaultClasses", teamName, classIndex, "class", "weaponSetups", 0, "reticle" );

		loadoutSecondary = getMatchRulesData( "defaultClasses", teamName, classIndex, "class", "weaponSetups", 1, "weapon" );
		loadoutSecondaryAttachment = getMatchRulesData( "defaultClasses", teamName, classIndex, "class", "weaponSetups", 1, "attachment", 0 );
		loadoutSecondaryAttachment2 = getMatchRulesData( "defaultClasses", teamName, classIndex, "class", "weaponSetups", 1, "attachment", 1 );
		loadoutSecondaryBuff = getMatchRulesData( "defaultClasses", teamName, classIndex, "class", "weaponSetups", 1, "buff" );
		loadoutSecondaryCamo = getMatchRulesData( "defaultClasses", teamName, classIndex, "class", "weaponSetups", 1, "camo" );
		loadoutSecondaryReticle = getMatchRulesData( "defaultClasses", teamName, classIndex, "class", "weaponSetups", 1, "reticle" );
		
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

		loadoutEquipment = getMatchRulesData( "defaultClasses", teamName, classIndex, "class", "perks", 0 );
		loadoutPerk1 = getMatchRulesData( "defaultClasses", teamName, classIndex, "class", "perks", 1 );
		loadoutPerk2 = getMatchRulesData( "defaultClasses", teamName, classIndex, "class", "perks", 2 );
		loadoutPerk3 = getMatchRulesData( "defaultClasses", teamName, classIndex, "class", "perks", 3 );
		
		if ( loadoutSecondary != "none" && !isValidSecondary( loadoutSecondary, loadoutPerk2, loadoutPerk3, false ) )
		{
			loadoutSecondary = table_getWeapon( level.classTableName, 10, 1 );
			loadoutSecondaryAttachment = "none";
			loadoutSecondaryAttachment2 = "none";
			loadoutSecondaryBuff = "specialty_null";
			loadoutSecondaryCamo = "none";
			loadoutSecondaryReticle = "none";	
		}
		
		loadoutStreakType = getMatchRulesData( "defaultClasses", teamName, classIndex, "class", "perks", 5 );

		if ( loadoutStreakType == "specialty_null" )
		{
		  loadoutKillstreak1 = "none";
		  loadoutKillstreak2 = "none";
		  loadoutKillstreak3 = "none";
		}
		else
		{
		  loadoutKillstreak1 = recipe_getKillstreak( teamName, classIndex, loadoutStreakType, 0 );
		  loadoutKillstreak2 = recipe_getKillstreak( teamName, classIndex, loadoutStreakType, 1 );
		  loadoutKillstreak3 = recipe_getKillstreak( teamName, classIndex, loadoutStreakType, 2 );
		}

		loadoutOffhand = getMatchRulesData( "defaultClasses", teamName, classIndex, "class", "perks", 6 );	

		if ( loadoutOffhand == "specialty_null" )
			loadoutOffhand = "none";	
	
		loadoutDeathStreak = getMatchRulesData( "defaultClasses", teamName, classIndex, "class", "deathstreak" );

		if ( getmatchrulesdata( "defaultClasses", teamName, classIndex, "juggernaut" ) )
		{
			thread recipeClassApplyJuggernaut( isJuggernaut() );
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
	else if ( isSubstr( class, "custom" ) )
	{
		class_num = getClassIndex( class );
		self.class_num = class_num;

		loadoutPrimary = cac_getWeapon( class_num, 0 );
		loadoutPrimaryAttachment = cac_getWeaponAttachment( class_num, 0 );
		loadoutPrimaryAttachment2 = cac_getWeaponAttachmentTwo( class_num, 0 );
		loadoutPrimaryBuff = cac_getWeaponBuff( class_num, 0 );
		loadoutPrimaryCamo = cac_getWeaponCamo( class_num, 0 );
		loadoutPrimaryReticle = cac_getWeaponReticle( class_num, 0 );
		loadoutSecondary = cac_getWeapon( class_num, 1 );
		loadoutSecondaryAttachment = cac_getWeaponAttachment( class_num, 1 );
		loadoutSecondaryAttachment2 = cac_getWeaponAttachmentTwo( class_num, 1 );
		loadoutSecondaryBuff = cac_getWeaponBuff( class_num, 1 );
		loadoutSecondaryCamo = cac_getWeaponCamo( class_num, 1 );
		loadoutSecondaryReticle = cac_getWeaponReticle( class_num, 1 );
		loadoutEquipment = cac_getPerk( class_num, 0 );
		loadoutPerk1 = cac_getPerk( class_num, 1 );
		loadoutPerk2 = cac_getPerk( class_num, 2 );
		loadoutPerk3 = cac_getPerk( class_num, 3 );
		loadoutStreakType = cac_getPerk( class_num, 5 );
		loadoutOffhand = cac_getOffhand( class_num );
		loadoutDeathStreak = cac_getDeathstreak( class_num );
	}
	else if ( class == "gamemode" )
	{
		gamemodeLoadout = self.pers["gamemodeLoadout"];

		loadoutPrimary = gamemodeLoadout["loadoutPrimary"];
		loadoutPrimaryAttachment = gamemodeLoadout["loadoutPrimaryAttachment"];
		loadoutPrimaryAttachment2 = gamemodeLoadout["loadoutPrimaryAttachment2"] ;
		loadoutPrimaryBuff = gamemodeLoadout["loadoutPrimaryBuff"];
		loadoutPrimaryCamo = gamemodeLoadout["loadoutPrimaryCamo"];
		loadoutPrimaryReticle = gamemodeLoadout["loadoutPrimaryReticle"];
		loadoutSecondary = gamemodeLoadout["loadoutSecondary"];		
		loadoutSecondaryAttachment = gamemodeLoadout["loadoutSecondaryAttachment"];
		loadoutSecondaryAttachment2 = gamemodeLoadout["loadoutSecondaryAttachment2"];
		loadoutSecondaryBuff = gamemodeLoadout["loadoutSecondaryBuff"];
		loadoutSecondaryCamo = gamemodeLoadout["loadoutSecondaryCamo"];
		loadoutSecondaryReticle = gamemodeLoadout["loadoutSecondaryReticle"];
		
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
		
		loadoutEquipment = gamemodeLoadout["loadoutEquipment"];
		loadoutOffhand = gamemodeLoadout["loadoutOffhand"];

		if ( loadoutOffhand == "specialty_null" )
			loadoutOffhand = "none";	
	
		loadoutPerk1 = gamemodeLoadout["loadoutPerk1"];
		loadoutPerk2 = gamemodeLoadout["loadoutPerk2"];
		loadoutPerk3 = gamemodeLoadout["loadoutPerk3"];

		if ( loadoutSecondary != "none" && !isValidSecondary( loadoutSecondary, loadoutPerk2, loadoutPerk3, false ) )
		{
			loadoutSecondary = table_getWeapon( level.classTableName, 10, 1 );
			loadoutSecondaryAttachment = "none";
			loadoutSecondaryAttachment2 = "none";
			loadoutSecondaryBuff = "specialty_null";
			loadoutSecondaryCamo = "none";
			loadoutSecondaryReticle = "none";	
		}

		if ( level.killstreakRewards && isDefined( gamemodeLoadout["loadoutStreakType"] ) && gamemodeLoadout["loadoutStreakType"] != "specialty_null" )
		{
			loadoutStreakType = gamemodeLoadout["loadoutStreakType"];
			loadoutKillstreak1 = gamemodeLoadout["loadoutKillstreak1"];
			loadoutKillstreak2 = gamemodeLoadout["loadoutKillstreak2"];
			loadoutKillstreak3 = gamemodeLoadout["loadoutKillstreak3"];			
		}
		else if ( level.killstreakRewards && isDefined( self.streakType ) )
			loadoutStreakType = getLoadoutStreakTypeFromStreakType( self.streakType );
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
			thread recipeClassApplyJuggernaut( isJuggernaut() );
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
		loadoutStreakType = getLoadoutStreakTypeFromStreakType( self.streakType );
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
		loadoutStreakType = getLoadoutStreakTypeFromStreakType( self.streakType );
		loadoutOffhand = "smoke_grenade_mp";
		loadoutDeathStreak = "specialty_null";
	}
	else
	{
		class_num = getClassIndex( class );
		self.class_num = class_num;
		
		loadoutPrimary = table_getWeapon( level.classTableName, class_num, 0 );
		loadoutPrimaryAttachment = table_getWeaponAttachment( level.classTableName, class_num, 0 , 0);
		loadoutPrimaryAttachment2 = table_getWeaponAttachment( level.classTableName, class_num, 0, 1 );
		loadoutPrimaryBuff = table_getWeaponBuff( level.classTableName, class_num, 0 );
		loadoutPrimaryCamo = table_getWeaponCamo( level.classTableName, class_num, 0 );
		loadoutPrimaryReticle = table_getWeaponReticle( level.classTableName, class_num, 0 );
		loadoutSecondary = table_getWeapon( level.classTableName, class_num, 1 );
		loadoutSecondaryAttachment = table_getWeaponAttachment( level.classTableName, class_num, 1 , 0);
		loadoutSecondaryAttachment2 = table_getWeaponAttachment( level.classTableName, class_num, 1, 1 );
		loadoutSecondaryBuff = table_getWeaponBuff( level.classTableName, class_num, 1 );
		loadoutSecondaryCamo = table_getWeaponCamo( level.classTableName, class_num, 1 );
		loadoutSecondaryReticle = table_getWeaponReticle( level.classTableName, class_num, 1 );
		loadoutEquipment = table_getEquipment( level.classTableName, class_num, 0 );
		loadoutPerk1 = table_getPerk( level.classTableName, class_num, 1 );
		loadoutPerk2 = table_getPerk( level.classTableName, class_num, 2 );
		loadoutPerk3 = table_getPerk( level.classTableName, class_num, 3 );
		loadoutStreakType = table_getPerk( level.classTableName, class_num, 5 );
		loadoutOffhand = table_getOffhand( level.classTableName, class_num );
		loadoutDeathstreak = table_getDeathstreak( level.classTableName, class_num );
	}

	self loadoutFakePerks( loadoutStreakType );

	isCustomClass = isSubstr( class, "custom" );
	isRecipeClass = isSubstr( class, "recipe" );
	isGameModeClass = ( class == "gamemode" );
	
	if ( !isGameModeClass && !isRecipeClass && !( isDefined( self.pers["copyCatLoadout"] ) && self.pers["copyCatLoadout"]["inUse"] && allowCopycat ) )
	{
		if ( !isValidPrimary( loadoutPrimary ) || ( level.rankedMatch && isCustomClass && !self isItemUnlocked( loadoutPrimary )) )
			loadoutPrimary = table_getWeapon( level.classTableName, 10, 0 );
		
		if ( isValidCombination( loadoutPrimary, loadoutPrimaryAttachment ) )
		{
			if ( !isValidAttachment( loadoutPrimaryAttachment ) || (  level.rankedMatch && isCustomClass && !self isAttachmentUnlocked( loadoutPrimary, loadoutPrimaryAttachment ) ) )
				loadoutPrimaryAttachment = table_getWeaponAttachment( level.classTableName, 10, 0 , 0);
		}
		else
		{
			loadoutPrimaryAttachment = "none";
		}	
		
		if ( isValidCombination( loadoutPrimary, loadoutPrimaryAttachment2 ) )
		{
			if ( !isValidAttachment( loadoutPrimaryAttachment2 ) || (  level.rankedMatch && isCustomClass && !self isAttachmentUnlocked( loadoutPrimary, loadoutPrimaryAttachment2 ) ) )
				loadoutPrimaryAttachment2 = table_getWeaponAttachment( level.classTableName, 10, 0, 1 );
		}
		else
		{
			loadoutPrimaryAttachment2 = "none";
		}	
		
		if ( !isValidWeaponBuff( loadoutPrimaryBuff, loadoutPrimary ) || ( level.rankedMatch && isCustomClass && !self isWeaponBuffUnlocked( loadoutPrimary, loadoutPrimaryBuff )) )
			loadoutPrimaryBuff = table_getWeaponBuff( level.classTableName, 10, 0 );

		if ( !isValidCamo( loadoutPrimaryCamo ) || (  level.rankedMatch && isCustomClass && !self isCamoUnlocked( loadoutPrimary, loadoutPrimaryCamo )) )
			loadoutPrimaryCamo = table_getWeaponCamo( level.classTableName, 10, 0 );

		if ( !isValidReticle( loadoutPrimaryReticle ) )
			loadoutPrimaryReticle = table_getWeaponReticle( level.classTableNum, 10, 0 );
		
		if ( !isValidSecondary( loadoutSecondary, loadoutPerk2, loadoutPerk3 ) || ( level.rankedMatch && isCustomClass && !self isItemUnlocked( loadoutSecondary )) )
		{
			loadoutSecondary = table_getWeapon( level.classTableName, 10, 1 );
			loadoutSecondaryAttachment = "none";
			loadoutSecondaryAttachment2 = "none";
			loadoutSecondaryBuff = "specialty_null";
			loadoutSecondaryCamo = "none";
			loadoutSecondaryReticle = "none";
		}
		
		if ( isValidCombination( loadoutSecondary, loadoutSecondaryAttachment ) )
		{
			if ( !isValidAttachment( loadoutSecondaryAttachment ) || (  level.rankedMatch && isCustomClass && !self isAttachmentUnlocked( loadoutSecondary, loadoutSecondaryAttachment )) )
				loadoutSecondaryAttachment = table_getWeaponAttachment( level.classTableName, 10, 1 , 0);
		}
		else
		{
			loadoutSecondaryAttachment = "none";
		}
		
		if ( isValidCombination( loadoutSecondary, loadoutSecondaryAttachment2 ) )
		{
			if ( !isValidAttachment( loadoutSecondaryAttachment2 ) || (  level.rankedMatch && isCustomClass && !self isAttachmentUnlocked( loadoutSecondary, loadoutSecondaryAttachment2 )) )
				loadoutSecondaryAttachment2 = table_getWeaponAttachment( level.classTableName, 10, 1, 1 );
		}
		else
		{
			loadoutSecondaryAttachment2 = "none";
		}
		
		if ( loadoutPerk2 == "specialty_twoprimaries" && !isValidWeaponBuff( loadoutSecondaryBuff, loadoutSecondary ) || ( level.rankedMatch && isCustomClass && !self isItemUnlocked( loadoutSecondary + " " + loadoutSecondaryBuff ) ) )
			loadoutSecondaryBuff = table_getWeaponBuff( level.classTableName, 10, 1 );

		if ( !isValidCamo( loadoutSecondaryCamo ) || ( level.rankedMatch && isCustomClass && !self isCamoUnlocked( loadoutSecondary, loadoutSecondaryCamo )) )
			loadoutSecondaryCamo = table_getWeaponCamo( level.classTableName, 10, 1 );

		if ( !isValidReticle( loadoutSecondaryReticle ) )
			loadoutSecondaryReticle = table_getWeaponReticle( level.classTableName, 10, 1 );
		
		if ( !isValidEquipment( loadoutEquipment ) || ( level.rankedMatch && isCustomClass && !self isItemUnlocked( loadoutEquipment )) )
			loadoutEquipment = table_getEquipment( level.classTableName, 10, 0 );
		
		if ( !isValidPerk1( loadoutPerk1 ) || ( level.rankedMatch && isCustomClass && !self isItemUnlocked( loadoutPerk1 )) )
			loadoutPerk1 = table_getPerk( level.classTableName, 10, 1 );
		
		if ( !isValidPerk2( loadoutPerk2 ) || ( level.rankedMatch && isCustomClass && !self isItemUnlocked( loadoutPerk2 )) )
			loadoutPerk2 = table_getPerk( level.classTableName, 10, 2 );
		
		if ( !isValidPerk3( loadoutPerk3 ) || ( level.rankedMatch && isCustomClass && !self isItemUnlocked( loadoutPerk3 )) )
			loadoutPerk3 = table_getPerk( level.classTableName, 10, 3 );
		
		if ( !isValidDeathStreak( loadoutDeathStreak ) || ( level.rankedMatch && isCustomClass && !self isItemUnlocked( loadoutDeathStreak ) ) )
			loadoutDeathStreak = table_getDeathstreak( level.classTableName, 10 );

		if ( !isValidOffhand( loadoutOffhand ) )
			loadoutOffhand = table_getOffhand( level.classTableName, 10 );

		if ( loadoutPrimaryAttachment2 != "none" && loadoutPrimaryBuff != "specialty_bling" )
			loadoutPrimaryAttachment2 = "none";

		if ( loadoutSecondaryBuff != "specialty_null" && loadoutPerk2 != "specialty_twoprimaries" )
			loadoutSecondaryBuff = "specialty_null";

		if ( loadoutSecondaryAttachment2 != "none" && ( loadoutSecondaryBuff != "specialty_bling" || loadoutPerk2 != "specialty_twoprimaries" ) )
			loadoutSecondaryAttachment2 = "none";
	}

	self.loadoutPrimary = loadoutPrimary;
	self.loadoutPrimaryCamo = int(tableLookup( "mp/camoTable.csv", 1, loadoutPrimaryCamo, 0 ));
	self.loadoutSecondary = loadoutSecondary;
	self.loadoutSecondaryCamo = int(tableLookup( "mp/camoTable.csv", 1, loadoutSecondaryCamo, 0 ));
	
	if ( !IsSubstr( loadoutPrimary, "iw5" ) )
		self.loadoutPrimaryCamo = 0;
	if ( !IsSubstr( loadoutSecondary, "iw5" ) )
		self.loadoutSecondaryCamo = 0;

	self.loadoutPrimaryReticle = int(tableLookup( "mp/reticleTable.csv", 1, loadoutPrimaryReticle, 0 ));
	self.loadoutSecondaryReticle = int(tableLookup( "mp/reticleTable.csv", 1, loadoutSecondaryReticle, 0));
	
	if ( !IsSubstr( loadoutPrimary, "iw5" ) )
		self.loadoutPrimaryReticle = 0;
	if ( !IsSubstr( loadoutSecondary, "iw5" ) )
		self.loadoutSecondaryReticle = 0;

	if ( loadoutSecondary == "none" )
		secondaryName = "none";
	else
	{
		secondaryName = buildWeaponName( loadoutSecondary, loadoutSecondaryAttachment, loadoutSecondaryAttachment2, self.loadoutSecondaryCamo, self.loadoutSecondaryReticle );
		self _giveWeapon( secondaryName );

		weaponTokens = StrTok( secondaryName, "_" );
		
		if ( weaponTokens[0] == "iw5" )
			weaponTokens[0] = weaponTokens[0] + "_" + weaponTokens[1];
		else if ( weaponTokens[0] == "alt" )
			weaponTokens[0] = weaponTokens[1] + "_" + weaponTokens[2];
		
		weaponName = weaponTokens[0];
		
		curWeaponRank = self maps\mp\gametypes\_rank::getWeaponRank( weaponName );
		curWeaponStatRank = self GetPlayerData( "weaponRank", weaponName );
		if( curWeaponRank != curWeaponStatRank )
			self SetPlayerData( "weaponRank", weaponName, curWeaponRank );
	}
		
	self SetOffhandPrimaryClass( "other" );

	self _SetActionSlot( 1, "" );
	self _SetActionSlot( 3, "altMode" );
	self _SetActionSlot( 4, "" );

	if ( !level.console )
	{
		_setActionSlot( 5, "" );
		_setActionSlot( 6, "" );
		_setActionSlot( 7, "" );
	}

	self _clearPerks();
	self _detachAll();
	
	if ( level.dieHardMode )
		self givePerk( "specialty_pistoldeath", false );
	
	self loadoutAllPerks( loadoutEquipment, loadoutPerk1, loadoutPerk2, loadoutPerk3, loadoutPrimaryBuff, loadoutSecondaryBuff );
		
	if ( self _hasPerk( "specialty_extraammo" ) && secondaryName != "none" && getWeaponClass( secondaryName ) != "weapon_projectile" )
		self giveMaxAmmo( secondaryName );

	self.spawnPerk = false;
	if( !self _hasPerk( "specialty_blindeye" ) && self.avoidKillstreakOnSpawnTimer > 0 )
		self thread maps\mp\perks\_perks::giveBlindEyeAfterSpawn();

	if( self.pers["cur_death_streak"] > 0 )
	{
		deathStreaks = [];
		if( loadoutDeathStreak != "specialty_null" )
			deathStreaks[ loadoutDeathStreak ] = int( tableLookup( "mp/perkTable.csv", 1, loadoutDeathStreak, 6 ) );

		if ( self getPerkUpgrade( loadoutPerk1 ) == "specialty_rollover" || self getPerkUpgrade( loadoutPerk2 ) == "specialty_rollover" || self getPerkUpgrade( loadoutPerk3 ) == "specialty_rollover" )
		{
			foreach( key, value in deathStreaks )
				deathStreaks[ key ] -= 1;
		}

		foreach( key, value in deathStreaks )
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

	if ( level.killstreakRewards && !isDefined( loadoutKillstreak1 ) && !isDefined( loadoutKillstreak2 ) && !isDefined( loadoutKillstreak3 ) )
	{
		if ( isDefined( self.pers["copyCatLoadout"] ) && self.pers["copyCatLoadout"]["inUse"] && allowCopycat )
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

			switch( self.streakType )
			{
			case "support":
				defaultKillstreak1 = table_getKillstreak( level.classTableName, 2, 1 );
				defaultKillstreak2 = table_getKillstreak( level.classTableName, 2, 2 );
				defaultKillstreak3 = table_getKillstreak( level.classTableName, 2, 3 );
				playerData = "defenseStreaks";
				break;
			case "specialist":
				defaultKillstreak1 = table_getKillstreak( level.classTableName, 1, 1 );
				defaultKillstreak2 = table_getKillstreak( level.classTableName, 1, 2 );
				defaultKillstreak3 = table_getKillstreak( level.classTableName, 1, 3 );
				playerData = "specialistStreaks";
				break;
			default:
				defaultKillstreak1 = table_getKillstreak( level.classTableName, 0, 1 );
				defaultKillstreak2 = table_getKillstreak( level.classTableName, 0, 2 );
				defaultKillstreak3 = table_getKillstreak( level.classTableName, 0, 3 );
				playerData = "assaultStreaks";
				break;
			}

			loadoutKillstreak1 = undefined;
			loadoutKillstreak2 = undefined;
			loadoutKillstreak3 = undefined;

			if( IsSubStr( class, "custom" ) )
			{
				customClassLoc = cac_getCustomClassLoc();
				loadoutKillstreak1 = self getPlayerData( customClassLoc, self.class_num, playerData, 0 );
				loadoutKillstreak2 = self getPlayerData( customClassLoc, self.class_num, playerData, 1 );
				loadoutKillstreak3 = self getPlayerData( customClassLoc, self.class_num, playerData, 2 );
			}

			if( IsSubStr( class, "juggernaut" ) || isGameModeClass )
			{
				foreach( killstreak in self.killstreaks )
				{
					if( !IsDefined( loadoutKillstreak1 ) )
						loadoutKillstreak1 = killstreak;
					else if( !IsDefined( loadoutKillstreak2 ) )
						loadoutKillstreak2 = killstreak;
					else if( !IsDefined( loadoutKillstreak3 ) )
						loadoutKillstreak3 = killstreak;
				}

				if ( isGameModeClass && self.streakType == "specialist" )
				{
					self.pers["gamemodeLoadout"]["loadoutKillstreak1"] = loadoutKillstreak1;
					self.pers["gamemodeLoadout"]["loadoutKillstreak2"] = loadoutKillstreak2;
					self.pers["gamemodeLoadout"]["loadoutKillstreak3"] = loadoutKillstreak3;
				}
			}

			if( !isSubstr( class, "custom" ) && !isSubstr( class, "juggernaut" ) && !isGameModeClass )
			{
				loadoutKillstreak1 = defaultKillstreak1;
				loadoutKillstreak2 = defaultKillstreak2;
				loadoutKillstreak3 = defaultKillstreak3;
			}

			if( !IsDefined( loadoutKillstreak1 ) )
				loadoutKillstreak1 = "none";
			if( !IsDefined( loadoutKillstreak2 ) )
				loadoutKillstreak2 = "none";
			if( !IsDefined( loadoutKillstreak3 ) )
				loadoutKillstreak3 = "none";


			var_56 = 0;

			if ( !isValidKillstreak( loadoutKillstreak1 ) || isCustomClass && !self isitemunlocked( loadoutKillstreak1 ) )
				var_56 = 1;

			if ( !isValidKillstreak( loadoutKillstreak2 ) || isCustomClass && !self isitemunlocked( loadoutKillstreak2 ) )
				var_56 = 1;

			if ( !isValidKillstreak( loadoutKillstreak3 ) || isCustomClass && !self isitemunlocked( loadoutKillstreak3 ) )
				var_56 = 1;

			if ( var_56 )
			{
				self.streakType = "assault";
				loadoutKillstreak1 = table_getKillstreak( level.classTableName, 0, 1 );
				loadoutKillstreak2 = table_getKillstreak( level.classTableName, 0, 2 );
				loadoutKillstreak3 = table_getKillstreak( level.classTableName, 0, 3 );
			}
		}
	}
	else if ( !level.killstreakRewards )
	{
		loadoutKillstreak1 = "none";
		loadoutKillstreak2 = "none";
		loadoutKillstreak3 = "none";
	}

	self setKillstreaks( loadoutKillstreak1, loadoutKillstreak2, loadoutKillstreak3 );

	if ( IsDefined( self.lastClass ) && self.lastClass != self.class && !IsSubStr( self.class, "juggernaut" ) && !IsSubStr( self.lastClass, "juggernaut" ) && !IsSubStr( class, "juggernaut" ) )
	{
		if ( wasOnlyRound() || self.lastClass != "" )
		{
			streakNames = [];
			inc = 0;

			if( self.pers["killstreaks"].size > 5 )
			{
				for ( i = 5; i < self.pers["killstreaks"].size; i++ )
				{
					streakNames[inc] = self.pers["killstreaks"][i].streakName;
					inc++;
				}
			}

			if( self.pers["killstreaks"].size )
			{
				for ( i = 1; i < 4; i++ )
				{
					if( IsDefined( self.pers["killstreaks"][i] ) && 
						IsDefined( self.pers["killstreaks"][i].streakName ) &&
						self.pers["killstreaks"][i].available && 
						!self.pers["killstreaks"][i].isSpecialist )
					{
						streakNames[inc] = self.pers["killstreaks"][i].streakName;
						inc++;
					}
				}
			}

			self notify( "givingLoadout" );
			maps\mp\killstreaks\_killstreaks::clearKillstreaks();

			for ( i = 0; i < streakNames.size; i++ )
			{
				self maps\mp\killstreaks\_killstreaks::giveKillstreak( streakNames[i] );
			}
		}
	}

	if( !IsSubStr( class, "juggernaut" ) )
	{
		if( isDefined( self.lastClass ) && self.lastClass != "" && self.lastClass != self.class )
		{
			self incPlayerStat( "mostclasseschanged", 1 );
		}

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

	primaryName = buildWeaponName( loadoutPrimary, loadoutPrimaryAttachment, loadoutPrimaryAttachment2, self.loadoutPrimaryCamo, self.loadoutPrimaryReticle );
	self _giveWeapon( primaryName );

	self SwitchToWeapon( primaryName );
	weaponTokens = StrTok( primaryName, "_" );
	
	if ( weaponTokens[0] == "iw5" )
		weaponName = weaponTokens[0] + "_" + weaponTokens[1];
	else if ( weaponTokens[0] == "alt" )
		weaponName = weaponTokens[1] + "_" + weaponTokens[2];
	else
		weaponName = weaponTokens[0];
	
	curWeaponRank = self maps\mp\gametypes\_rank::getWeaponRank( weaponName );
	curWeaponStatRank = self GetPlayerData( "weaponRank", weaponName );
	if( curWeaponRank != curWeaponStatRank )
		self SetPlayerData( "weaponRank", weaponName, curWeaponRank );

	if ( primaryName == "riotshield_mp" && level.inGracePeriod )
		self notify ( "weapon_change", "riotshield_mp" );

	if ( self _hasPerk( "specialty_extraammo" ) )
		self giveMaxAmmo( primaryName );

	if ( setPrimarySpawnWeapon )
		self setSpawnWeapon( primaryName );
	
	self.pers["primaryWeapon"] = weaponName;
	
	primaryTokens = strtok( primaryName, "_" );
	
	offhandSecondaryWeapon = loadoutOffhand;
	
	if ( loadoutOffhand == "none" )
		self SetOffhandSecondaryClass( "none" );
	else if ( loadoutOffhand == "flash_grenade_mp" )
		self SetOffhandSecondaryClass( "flash" );
	else if ( loadoutOffhand == "smoke_grenade_mp" || loadoutOffhand == "concussion_grenade_mp" )
		self SetOffhandSecondaryClass( "smoke" );	
	else 
		self SetOffhandSecondaryClass( "flash" );
	
	switch( offhandSecondaryWeapon )
	{
		case "none":
			break;
		case "specialty_portable_radar":
		case "specialty_scrambler":
		case "specialty_tacticalinsertion":
		case "trophy_mp":
			self givePerk( offhandSecondaryWeapon, false );
			break;
	
		default:
			self giveWeapon( offhandSecondaryWeapon );
	
			if( loadOutOffhand == "flash_grenade_mp" )
				self setWeaponAmmoClip( offhandSecondaryWeapon, 2 );
			else if( loadOutOffhand == "concussion_grenade_mp" )
				self setWeaponAmmoClip( offhandSecondaryWeapon, 2 );
			else
				self setWeaponAmmoClip( offhandSecondaryWeapon, 1 );
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

	self maps\mp\gametypes\_teams::playerModelForWeapon( self.pers["primaryWeapon"], getBaseWeaponName( secondaryName ) );
		
	self.isSniper = (weaponClass( self.primaryWeapon ) == "sniper");
	
	self maps\mp\gametypes\_weapons::updateMoveSpeedScale();

	self maps\mp\perks\_perks::cac_selector();
	
	self notify( "changed_kit" );
	self notify( "giveLoadout", team, class, allowCopycat, setPrimarySpawnWeapon );
}

_detachAll()
{
	if ( isdefined( self.hasRiotShield ) && self.hasRiotShield )
	{
		if ( self.hasRiotShieldEquipped && ( !isdefined( self.hasriotshieldhidden ) || self.hasriotshieldhidden == 0 ) )
		{
			self detachshieldmodel( "weapon_riot_shield_mp", "tag_weapon_left" );
			self.hasRiotShieldEquipped = 0;
		}
		else
			self detachshieldmodel( "weapon_riot_shield_mp", "tag_shield_back" );

		self.hasRiotShield = 0;
	}

	self detachall();
}

isPerkUpgraded( perkName )
{
	perkUpgrade = tablelookup( "mp/perktable.csv", 1, perkName, 8 );
	
	if ( perkUpgrade == "" || perkUpgrade == "specialty_null" )
		return false;
		
	if ( !self isItemUnlocked( perkUpgrade ) )
		return false;
		
	return true;
}

getPerkUpgrade( perkName )
{
	perkUpgrade = tablelookup( "mp/perktable.csv", 1, perkName, 8 );
	
	if ( perkUpgrade == "" || perkUpgrade == "specialty_null" )
		return "specialty_null";
		
	if ( !self isItemUnlocked( perkUpgrade ) )
		return "specialty_null";
		
	return ( perkUpgrade );
}

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
	else
		self.loadoutSecondaryBuff = "specialty_null";

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
	
	foreach( upgrade in perkUpgrd )
	{
		if ( upgrade == "" || upgrade == "specialty_null" )
			continue;
			
		if ( self isItemUnlocked( upgrade ) || !self rankingEnabled() )
		{
			self givePerk( upgrade, true );
		}
	}

	if( !self _hasPerk( "specialty_assists" ) )
		self.pers["assistsToKill"] = 0;
}

watchoffhanduse()
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "faux_spawn" );

	for (;;)
	{
		self waittill( "grenade_pullback",  var_0  );

		if ( self.hasRiotShieldEquipped )
		{
			self detachshieldmodel( "weapon_riot_shield_mp", "tag_weapon_left" );
			self.hasriotshieldhidden = 1;
		}
		else
			continue;

		self waittill( "offhand_end",  var_0  );

		if ( self.hasRiotShieldEquipped )
		{
			self attachshieldmodel( "weapon_riot_shield_mp", "tag_weapon_left" );
			self.hasriotshieldhidden = 0;
		}
	}
}

trackRiotShield()
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "faux_spawn" );
	self.hasRiotShield = self hasweapon( "riotshield_mp" );
	self.hasRiotShieldEquipped = self.currentWeaponAtSpawn == "riotshield_mp";
	thread watchoffhanduse();

	if ( self.hasRiotShield )
	{
		if ( self.primaryWeapon == "riotshield_mp" && self.secondaryWeapon == "riotshield_mp" )
		{
			self attachshieldmodel( "weapon_riot_shield_mp", "tag_weapon_left" );
			self attachshieldmodel( "weapon_riot_shield_mp", "tag_shield_back" );
		}
		else if ( self.hasRiotShieldEquipped )
			self attachshieldmodel( "weapon_riot_shield_mp", "tag_weapon_left" );
		else
			self attachshieldmodel( "weapon_riot_shield_mp", "tag_shield_back" );
	}

	for (;;)
	{
		self waittill( "weapon_change",  var_0  );

		if ( var_0 == "riotshield_mp" || var_0 == "iw5_riotshieldjugg_mp" )
		{
			if ( self.hasRiotShieldEquipped )
				continue;

			if ( self.primaryWeapon == var_0 && self.secondaryWeapon == var_0 )
				continue;
			else if ( self.hasRiotShield )
				self moveshieldmodel( "weapon_riot_shield_mp", "tag_shield_back", "tag_weapon_left" );
			else
				self attachshieldmodel( "weapon_riot_shield_mp", "tag_weapon_left" );

			self.hasRiotShield = 1;
			self.hasRiotShieldEquipped = 1;
			continue;
		}

		if ( self ismantling() && var_0 == "none" )
			continue;

		if ( self.hasRiotShieldEquipped )
		{
			self.hasRiotShield = self hasweapon( "riotshield_mp" ) || self hasweapon( "iw5_riotshieldjugg_mp" );

			if ( self.hasRiotShield )
				self moveshieldmodel( "weapon_riot_shield_mp", "tag_weapon_left", "tag_shield_back" );
			else
				self detachshieldmodel( "weapon_riot_shield_mp", "tag_weapon_left" );

			self.hasRiotShieldEquipped = 0;
			continue;
		}

		if ( self.hasRiotShield )
		{
			if ( !self hasweapon( "riotshield_mp" ) && !self hasweapon( "iw5_riotshieldjugg_mp" ) )
			{
				self detachshieldmodel( "weapon_riot_shield_mp", "tag_shield_back" );
				self.hasRiotShield = 0;
			}
		}
	}
}

tryAttach( placement )
{
	if ( !isDefined( placement ) || placement != "back" )
		tag = "tag_weapon_left";
	else
		tag = "tag_shield_back";
	
	attachSize = self getAttachSize();
	
	for ( i = 0; i < attachSize; i++ )
	{
		attachedTag = self getAttachTagName( i );
		if ( attachedTag == tag &&  self getAttachModelName( i ) == "weapon_riot_shield_mp" )
		{
			return;
		}
	}
	
	self AttachShieldModel( "weapon_riot_shield_mp", tag );
}

tryDetach( placement )
{
	if ( !isDefined( placement ) || placement != "back" )
		tag = "tag_weapon_left";
	else
		tag = "tag_shield_back";
	
	
	attachSize = self getAttachSize();
	
	for ( i = 0; i < attachSize; i++ )
	{
		attachedModel = self getAttachModelName( i );
		if ( attachedModel == "weapon_riot_shield_mp" )
		{
			self DetachShieldModel( attachedModel, tag);
			return;
		}
	}
	return;
}

buildWeaponName( baseName, attachment1, attachment2, camo, reticle )
{
	if ( !isDefined( level.letterToNumber ) )
		level.letterToNumber = makeLettersToNumbers();
	
	if ( getDvarInt ( "scr_game_perks" ) == 0 )
	{
		attachment2 = "none";
	}
	
	if ( isDefined( reticle ) && reticle != 0 && getAttachmentType( attachment1 ) != "rail" && getAttachmentType( attachment2 ) != "rail" )
	{
		reticle = undefined;
	}
		
	if( getAttachmentType( attachment1 ) == "rail" )
	{
		attachment1 = attachmentMap( attachment1, baseName );
	}
	else if ( getAttachmentType( attachment2 ) == "rail" )
	{
		attachment2 = attachmentMap( attachment2, baseName );
	}
	
	bareWeaponName = "";
	
	if ( isSubstr(baseName, "iw5_") )
	{
		weaponName = baseName + "_mp";
		endIndex = baseName.size;
		bareWeaponName = GetSubStr( baseName, 4, endIndex );
	}
	else
	{
		weaponName = baseName;
	}
	
	attachments = [];

	if ( attachment1 != "none" && attachment2 != "none" )
	{
		if ( level.letterToNumber[attachment1[0]] < level.letterToNumber[attachment2[0]] )
		{
			
			attachments[0] = attachment1;
			attachments[1] = attachment2;
			
		}
		else if ( level.letterToNumber[attachment1[0]] == level.letterToNumber[attachment2[0]] )
		{
			if ( level.letterToNumber[attachment1[1]] < level.letterToNumber[attachment2[1]] )
			{
				attachments[0] = attachment1;
				attachments[1] = attachment2;
			}
			else
			{
				attachments[0] = attachment2;
				attachments[1] = attachment1;
			}	
		}
		else
		{
			attachments[0] = attachment2;
			attachments[1] = attachment1;
		}
		
		if ( getWeaponClass( baseName ) == "weapon_sniper" && getAttachmentType( attachment1 ) != "rail" && getAttachmentType( attachment2 ) != "rail" ) 	
		{
			if ( attachment1 != "zoomscope" && attachment2 != "zoomscope" )
				attachments[2] = bareWeaponName + "scope";
		}
	}
	else if ( attachment1 != "none" )
	{
		attachments[0] = attachment1;
		
		if ( getWeaponClass( baseName ) == "weapon_sniper" && getAttachmentType( attachment1 ) != "rail" && attachment1 != "zoomscope" )
			attachments[1] = bareWeaponName + "scope";
		
	}
	else if ( attachment2 != "none" )
	{
		attachments[0] = attachment2;	
		
		if ( getWeaponClass( baseName ) == "weapon_sniper" && getAttachmentType( attachment2 ) != "rail" && attachment2 != "zoomscope" )
			attachments[1] = bareWeaponName + "scope";
	}
	else if ( getWeaponClass( baseName ) == "weapon_sniper" )
	{
		attachments[0] = bareWeaponName + "scope";
	}
	
	if( isDefined( attachments[0] ) && attachments[0] == "vzscope" )
		attachments[0] = bareWeaponName + "scopevz";
	else if( isDefined( attachments[1] ) && attachments[1] == "vzscope" )
		attachments[1] = bareWeaponName + "scopevz";
	else if( isDefined( attachments[2] ) && attachments[2] == "vzscope" )
		attachments[2] = bareWeaponName + "scopevz";
	
	if ( isDefined( attachments.size ) && attachments.size )
	{
		i = 0;
		while( i < attachments.size )
		{
			if ( isDefined( attachments[i+1] ) && is_later_in_alphabet( attachments[i], attachments[i+1] ) )
			{
				tmpAtch = attachments[i];
				attachments[i] = attachments[i+1];
				attachments[i+1] = tmpAtch;
				i = 0;
				continue;
			}
			i++;
		}
	}
	
	foreach ( attachment in attachments )
	{
		weaponName += "_" + attachment;
	}

	if ( isSubstr(weaponName, "iw5_") )
	{
		weaponName = buildWeaponNameCamo( weaponName, camo );
		weaponName = buildWeaponNameReticle( weaponName, reticle );
		return ( weaponName );
	}
	else if ( !isValidWeapon( weaponName + "_mp" ) )
	{
		return ( baseName + "_mp" );
	}
	else
	{
		weaponName = buildWeaponNameCamo( weaponName, camo );
		weaponName = buildWeaponNameReticle( weaponName, reticle );
		return ( weaponName + "_mp" );
	}
}

buildWeaponNameCamo( weaponName, camo )
{
	if ( !IsDefined( camo ) || camo <= 0 )
		return weaponName;

	return weaponName + "_camo" + ter_op( camo < 10, "0", "" ) + camo;
}

buildWeaponNameReticle( weaponName, reticle )
{
	if ( !IsDefined( reticle ) || reticle == 0 )
	{
		return weaponName;
	}
	
	weaponName += "_scope" + reticle;

	return weaponName;
}

makeLettersToNumbers()
{
	array = [];

	array["a"] = 0;
	array["b"] = 1;
	array["c"] = 2;
	array["d"] = 3;
	array["e"] = 4;
	array["f"] = 5;
	array["g"] = 6;
	array["h"] = 7;
	array["i"] = 8;
	array["j"] = 9;
	array["k"] = 10;
	array["l"] = 11;
	array["m"] = 12;
	array["n"] = 13;
	array["o"] = 14;
	array["p"] = 15;
	array["q"] = 16;
	array["r"] = 17;
	array["s"] = 18;
	array["t"] = 19;
	array["u"] = 20;
	array["v"] = 21;
	array["w"] = 22;
	array["x"] = 23;
	array["y"] = 24;
	array["z"] = 25;

	return array;
}

setKillstreaks( streak1, streak2, streak3 )
{
	self.killStreaks = [];

	killStreaks = [];

	if ( IsDefined( streak1 ) && streak1 != "none" )
	{
		streakVal = self maps\mp\killstreaks\_killstreaks::getStreakCost( streak1 );
		killStreaks[streakVal] = streak1;
	}
	if ( IsDefined( streak2 ) && streak2 != "none" )
	{
		streakVal = self maps\mp\killstreaks\_killstreaks::getStreakCost( streak2 );
		killStreaks[streakVal] = streak2;
	}
	if ( IsDefined( streak3 ) && streak3 != "none" )
	{
		streakVal = self maps\mp\killstreaks\_killstreaks::getStreakCost( streak3 );
		killStreaks[streakVal] = streak3;
	}

	maxVal = 0;
	foreach ( streakVal, streakName in killStreaks )
	{
		if ( streakVal > maxVal )
			maxVal = streakVal;
	}

	for ( streakIndex = 0; streakIndex <= maxVal; streakIndex++ )
	{
		if ( !IsDefined( killStreaks[ streakIndex ] ) )
			continue;
			
		streakName = killStreaks[streakIndex];
			
		self.killStreaks[ streakIndex ] = killStreaks[ streakIndex ];
	}
}

replenishLoadout()
{
	team = self.pers["team"];
	class = self.pers["class"];

	weaponsList = self GetWeaponsListAll();
	for( idx = 0; idx < weaponsList.size; idx++ )
	{
		weapon = weaponsList[idx];

		self giveMaxAmmo( weapon );
		self SetWeaponAmmoClip( weapon, 9999 );

		if ( weapon == "claymore_mp" || weapon == "claymore_detonator_mp" )
			self setWeaponAmmoStock( weapon, 2 );
	}
	
	if ( self getAmmoCount( level.classGrenades[class]["primary"]["type"] ) < level.classGrenades[class]["primary"]["count"] )
		self SetWeaponAmmoClip( level.classGrenades[class]["primary"]["type"], level.classGrenades[class]["primary"]["count"] );

	if ( self getAmmoCount( level.classGrenades[class]["secondary"]["type"] ) < level.classGrenades[class]["secondary"]["count"] )
		self SetWeaponAmmoClip( level.classGrenades[class]["secondary"]["type"], level.classGrenades[class]["secondary"]["count"] );	
}

onPlayerConnecting()
{
	for(;;)
	{
		level waittill( "connected", player );

		if ( !isDefined( player.pers["class"] ) )
		{
			player.pers["class"] = "";
		}
		if ( !isDefined( player.pers["lastClass"] ) )
		{
			player.pers["lastClass"] = "";
		}
		player.class = player.pers["class"];
		player.lastClass = player.pers["lastClass"];
		player.detectExplosives = false;
		player.bombSquadIcons = [];
		player.bombSquadIds = [];
	}
}

fadeAway( waitDelay, fadeDelay )
{
	wait waitDelay;
	
	self fadeOverTime( fadeDelay );
	self.alpha = 0;
}

setClass( newClass )
{
	self.curClass = newClass;
}

getPerkForClass( perkSlot, className )
{
	class_num = getClassIndex( className );

	if( isSubstr( className, "custom" ) )
		return cac_getPerk( class_num, perkSlot );
	else
		return table_getPerk( level.classTableName, class_num, perkSlot );
}

classHasPerk( className, perkName )
{
	return( getPerkForClass( 0, className ) == perkName || getPerkForClass( 1, className ) == perkName || getPerkForClass( 2, className ) == perkName );
}

isValidCombination( weaponName, attachmentName )
{
	if ( weaponName == "none" || attachmentName == "none" )
		return true;

	switch ( weaponName )
	{
		case "iw5_m60":
		case "iw5_pecheneg":
			if ( attachmentName == "heartbeat" )
				return false;
			else
				return true;
		case "iw5_44magnum":
		case "iw5_deserteagle":
		case "iw5_mp412":
			if ( attachmentName == "silencer02" || attachmentName == "xmags" )
				return false;
			else
				return true;
		default:
			return true;
	}
}

isValidPrimary( refString, showAssert )
{
	if ( !isdefined( showAssert ) )
		showAssert = true;

	switch ( refString )
	{
		case "iw5_1887":
		case "iw5_aa12":
		case "iw5_acr":
		case "iw5_ak47":
		case "iw5_ak74u":
		case "iw5_as50":
		case "iw5_barrett":
		case "iw5_cheytac":
		case "iw5_cm901":
		case "iw5_dragunov":
		case "iw5_fad":
		case "iw5_g36c":
		case "iw5_ksg":
		case "iw5_l96a1":
		case "iw5_m16":
		case "iw5_m4":
		case "iw5_m60":
		case "iw5_m9":
		case "iw5_mg36":
		case "iw5_mk14":
		case "iw5_mk46":
		case "iw5_mp5":
		case "iw5_mp7":
		case "iw5_msr":
		case "iw5_p90":
		case "iw5_pecheneg":
		case "iw5_pp90m1":
		case "iw5_rsass":
		case "iw5_sa80":
		case "iw5_scar":
		case "iw5_spas12":
		case "iw5_striker":
		case "iw5_type95":
		case "iw5_ump45":
		case "iw5_usas12":
		case "riotshield":
		case "xm25":
			return true;
		case "iw5_m60jugg":
		case "iw5_riotshieldjugg":
			if ( isJuggernaut() )
				return true;
			else
				return false;
		default:
			return false;
	}
}

isValidSecondary( refString, loadoutPerk2, loadoutPerk3, showAssert )
{
	if ( !isdefined( showAssert ) )
		showAssert = 1;

	switch ( refString )
	{
		case "iw5_44magnum":
		case "iw5_deserteagle":
		case "iw5_fmg9":
		case "iw5_fnfiveseven":
		case "iw5_g18":
		case "iw5_mp412":
		case "iw5_mp9":
		case "iw5_p99":
		case "iw5_skorpion":
		case "iw5_smaw":
		case "iw5_usp45":
		case "javelin":
		case "m320":
		case "rpg":
		case "stinger":
		case "xm25":
			return true;
		case "iw5_mp412jugg":
		case "iw5_usp45jugg":
			if ( isJuggernaut() )
				return true;
			else
				return false;
		case "iw5_1887":
		case "iw5_aa12":
		case "iw5_acr":
		case "iw5_ak74u":
		case "iw5_ak47":
		case "iw5_as50":
		case "iw5_barrett":
		case "iw5_cheytac":
		case "iw5_cm901":
		case "iw5_dragunov":
		case "iw5_fad":
		case "iw5_g36c":
		case "iw5_ksg":
		case "iw5_l96a1":
		case "iw5_m16":
		case "iw5_m4":
		case "iw5_m60":
		case "iw5_m9":
		case "iw5_mg36":
		case "iw5_mk14":
		case "iw5_mk46":
		case "iw5_mp5":
		case "iw5_mp7":
		case "iw5_msr":
		case "iw5_p90":
		case "iw5_pecheneg":
		case "iw5_pp90m1":
		case "iw5_rsass":
		case "iw5_sa80":
		case "iw5_scar":
		case "iw5_spas12":
		case "iw5_striker":
		case "iw5_type95":
		case "iw5_ump45":
		case "iw5_usas12":
		case "riotshield":
			if ( getdvarint( "scr_game_perks" ) == 1 && loadoutPerk2 == "specialty_twoprimaries" )
				return true;
			else
				return false;
		default:
			return false;
	}
}

isValidAttachment( refString, shouldAssert )
{
	if ( !isdefined( shouldAssert ) )
		shouldAssert = 1;

	switch ( refString )
	{
		case "none":
		case "akimbo":
		case "shotgun":
		case "tactical":
		case "vzscope":
		case "reflex":
		case "reflexsmg":
		case "eotech":
		case "eotechsmg":
		case "acog":
		case "acogsmg":
		case "thermal":
		case "thermalsmg":
		case "reflexlmg":
		case "eotechlmg":
		case "silencer02":
		case "silencer03":
		case "silencer":
		case "gp25":
		case "m320":
		case "gl":
		case "zoomscope":
		case "grip":
		case "heartbeat":
		case "fmj":
		case "rof":
		case "xmags":
		case "hamrhybrid":
		case "hybrid":
			return true;
		default:
			return false;
	}
}

isAttachmentUnlocked( weaponRef, attachmentRef )
{
	if ( getdvarint( "xblive_competitionmatch" ) && ( getdvarint( "systemlink" ) || !level.console && ( getdvar( "dedicated" ) == "dedicated LAN server" || getdvar( "dedicated" ) == "dedicated internet server" ) ) )
		return true;

	tableWeaponClassCol = 0;
	tableWeaponClassAttachmentCol = 2;
	tableWeaponRankCol = 4;
	weaponRank = self getplayerdata( "weaponRank", weaponRef );
	colNum = int( tablelookup( "mp/weaponRankTable.csv", tableWeaponClassCol, getWeaponClass( weaponRef ), tableWeaponClassAttachmentCol ) );
	attachmentRank = int( tablelookup( "mp/weaponRankTable.csv", colNum, attachmentRef, tableWeaponRankCol ) );

	if ( weaponRank >= attachmentRank )
		return true;
	else
		return false;
}

isValidWeaponBuff( refString, weapon )
{
	weapClass = getWeaponClass( weapon );

	if ( weapClass == "weapon_assault" )
	{
		switch ( refString )
		{
			case "specialty_bling":
			case "specialty_bulletpenetration":
			case "specialty_marksman":
			case "specialty_sharp_focus":
			case "specialty_holdbreathwhileads":
			case "specialty_reducedsway":
				return true;
			default:
				self.detectedexploit = 250;
				return false;
		}
	}
	else if ( weapClass == "weapon_smg" )
	{
		switch ( refString )
		{
			case "specialty_bling":
			case "specialty_marksman":
			case "specialty_sharp_focus":
			case "specialty_reducedsway":
			case "specialty_longerrange":
			case "specialty_fastermelee":
				return true;
			default:
				self.detectedexploit = 250;
				return false;
		}
	}
	else if ( weapClass == "weapon_lmg" )
	{
		switch ( refString )
		{
			case "specialty_bling":
			case "specialty_bulletpenetration":
			case "specialty_marksman":
			case "specialty_sharp_focus":
			case "specialty_reducedsway":
			case "specialty_lightweight":
				return true;
			default:
				self.detectedexploit = 250;
				return false;
		}
	}
	else if ( weapClass == "weapon_sniper" )
	{
		switch ( refString )
		{
			case "specialty_bling":
			case "specialty_bulletpenetration":
			case "specialty_marksman":
			case "specialty_sharp_focus":
			case "specialty_reducedsway":
			case "specialty_lightweight":
				return true;
			default:
				self.detectedexploit = 250;
				return false;
		}
	}
	else if ( weapClass == "weapon_shotgun" )
	{
		switch ( refString )
		{
			case "specialty_bling":
			case "specialty_marksman":
			case "specialty_sharp_focus":
			case "specialty_longerrange":
			case "specialty_fastermelee":
			case "specialty_moredamage":
				return true;
			default:
				self.detectedexploit = 250;
				return false;
		}
	}
	else if ( weapClass == "weapon_riot" )
	{
		switch ( refString )
		{
			case "specialty_fastermelee":
			case "specialty_lightweight":
				return true;
			default:
				self.detectedexploit = 250;
				return false;
		}
	}
	else
	{
		self.detectedexploit = 250;
		return false;
	}
}

isWeaponBuffUnlocked( weaponRef, buffRef )
{
	if ( getdvarint( "xblive_competitionmatch" ) && ( getdvarint( "systemlink" ) || !level.console && ( getdvar( "dedicated" ) == "dedicated LAN server" || getdvar( "dedicated" ) == "dedicated internet server" ) ) )
		return true;

	tableWeaponClassCol = 0;
	tableWeaponClassBuffCol = 4;
	tableWeaponRankCol = 4;
	weaponRank = self getplayerdata( "weaponRank", weaponRef );
	colNum = int( tablelookup( "mp/weaponRankTable.csv", tableWeaponClassCol, getWeaponClass( weaponRef ), tableWeaponClassBuffCol ) );
	buffRank = int( tablelookup( "mp/weaponRankTable.csv", colNum, buffRef, tableWeaponRankCol ) );

	if ( weaponRank >= buffRank )
		return true;

	return false;
}

isValidCamo( refString )
{
	switch ( refString )
	{
		case "none":
		case "classic":
		case "snow":
		case "multi":
		case "d_urban":
		case "hex":
		case "choco":
		case "marine":
		case "snake":
		case "winter":
		case "blue":
		case "red":
		case "autumn":
		case "gold":
			return true;
		default:
			return false;
	}
}

isValidReticle( refString )
{
	switch ( refString )
	{
		case "none":
		case "ret1":
		case "ret2":
		case "ret3":
		case "ret4":
		case "ret5":
		case "ret6":
			return true;
		default:
			return false;
	}
}

isCamoUnlocked( weaponRef, camoRef )
{
	if ( getdvarint( "xblive_competitionmatch" ) && (getdvarint( "systemlink" ) || !level.console && ( getdvar( "dedicated" ) == "dedicated LAN server" || getdvar( "dedicated" ) == "dedicated internet server" ) ) )
		return true;

	tableWeaponClassCol = 0;
	tableWeaponClassCamoCol = 3;
	tableWeaponRankCol = 4;
	weaponRank = self getplayerdata( "weaponRank", weaponRef );
	colNum = int( tablelookup( "mp/weaponRankTable.csv", tableWeaponClassCol, getWeaponClass( weaponRef ), tableWeaponClassCamoCol ) );
	camoRank = int( tablelookup( "mp/weaponRankTable.csv", colNum, camoRef, tableWeaponRankCol ) );

	if ( weaponRank >= camoRank )
		return true;

	return false;
}

isValidEquipment( refString )
{
	switch ( refString )
	{
		case "frag_grenade_mp":
		case "throwingknife_mp":
		case "claymore_mp":
		case "semtex_mp":
		case "c4_mp":
		case "bouncingbetty_mp":
			return true;
		default:
			return false;
	}
}

isValidOffhand( refString )
{
	switch ( refString )
	{
		case "trophy_mp":
		case "smoke_grenade_mp":
		case "specialty_portable_radar":
		case "flash_grenade_mp":
		case "concussion_grenade_mp":
		case "specialty_scrambler":
		case "specialty_tacticalinsertion":
		case "emp_grenade_mp":
			return true;
		default:
			return false;
	}
}

isValidPerk1( refString )
{
	switch ( refString )
	{
		case "specialty_scavenger":
		case "specialty_blindeye":
		case "specialty_longersprint":
		case "specialty_fastreload":
		case "specialty_paint":
			return true;
		default:
			return false;
	}
}

isValidPerk2( refString, loadoutPerk1 )
{
	switch ( refString )
	{
		case "specialty_coldblooded":
		case "specialty_assists":
		case "specialty_quickdraw":
		case "specialty_twoprimaries":
		case "specialty_hardline":
		case "_specialty_blastshield":
			return true;
		default:
			return false;
	}
}

isValidPerk3( refString, loadoutPerk1 )
{
	switch ( refString )
	{
		case "specialty_bulletaccuracy":
		case "specialty_detectexplosive":
		case "specialty_autospot":
		case "specialty_quieter":
		case "specialty_stalker":
			return true;
		default:
			return false;
	}
}

isValidDeathStreak( refString )
{
	switch ( refString )
	{
		case "specialty_null":
		case "specialty_finalstand":
		case "specialty_juiced":
		case "specialty_grenadepulldeath":
		case "specialty_revenge":
		case "specialty_stopping_power":
		case "specialty_c4death":
			return true;
		default:
			return false;
	}
}

isValidWeapon( refString )
{
	if ( !isdefined( level.weaponRefs ) )
	{
		level.weaponRefs = [];

		foreach ( weaponRef in level.weaponList )
			level.weaponRefs[weaponRef] = true;
	}

	if ( isdefined( level.weaponRefs[refString] ) )
		return true;

	return false;
}

isValidKillstreak( refString )
{
	switch ( self.streakType )
	{
		case "assault":
			return isvalidassaultkillstreak( refString );
		case "support":
			return isvalidsupportkillstreak( refString );
		case "specialist":
			return isvalidspecialistkillstreak( refString );
		default:
			return false;
	}
}

isvalidassaultkillstreak( refString )
{
	switch ( refString )
	{
		case "none":
		case "uav":
		case "double_uav":
		case "ac130":
		case "precision_airstrike":
		case "predator_missile":
		case "sentry":
		case "airdrop_assault":
		case "airdrop_sentry_minigun":
		case "airdrop_juggernaut":
		case "helicopter_flares":
		case "littlebird_flock":
		case "minigun_turret":
		case "osprey_gunner":
		case "directional_uav":
		case "heli_sniper":
		case "ims":
		case "aastrike":
		case "remote_mortar":
		case "remote_tank":
		case "airdrop_remote_tank":
		case "helicopter":
		case "littlebird_support":
			return true;
		default:
			return false;
	}
}

isvalidsupportkillstreak( refString )
{
	switch ( refString )
	{
		case "none":
		case "emp":
		case "triple_uav":
		case "counter_uav":
		case "stealth_airstrike":
		case "airdrop_trap":
		case "escort_airdrop":
		case "deployable_vest":
		case "remote_mg_turret":
		case "airdrop_juggernaut_recon":
		case "uav_support":
		case "remote_uav":
		case "sam_turret":
			return true;
		default:
			return false;
	}
}

isvalidspecialistkillstreak( refString )
{
	switch ( refString )
	{
		case "none":
		case "specialty_longersprint_ks":
		case "specialty_fastreload_ks":
		case "specialty_scavenger_ks":
		case "specialty_blindeye_ks":
		case "specialty_paint_ks":
		case "specialty_hardline_ks":
		case "specialty_coldblooded_ks":
		case "specialty_quickdraw_ks":
		case "specialty_assists_ks":
		case "_specialty_blastshield_ks":
		case "specialty_detectexplosive_ks":
		case "specialty_autospot_ks":
		case "specialty_bulletaccuracy_ks":
		case "specialty_quieter_ks":
		case "specialty_stalker_ks":
			return true;
		default:
			return false;
	}
}
