#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

init()
{
	level thread watchNuke();

	level thread onPlayerConnect();

	setDvarIfUninitialized( "scr_killstreak_print", 0 );
	setDvarIfUninitialized( "scr_printDamage", 0 );
	setDvarIfUninitialized( "scr_xpscale_", 1 );
	setDvarIfUninitialized( "scr_weaponxpscale_", 1 );

	level.killstreakPrint = getDvarInt( "scr_killstreak_print" );
	level.allowPrintDamage = getDvarInt( "scr_printDamage" );

	level thread hook_callbacks();
}

hook_callbacks()
{
	level waittill( "prematch_over" ); // iw4madmin waits this long for some reason...
	wait 0.1; // so we need to be one frame after it sets up its callbacks.
	level.prevCallbackPlayerDamage2 = level.callbackPlayerDamage;
	level.callbackPlayerDamage = ::onPlayerDamage;
}

onPlayerDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset )
{
	if ( isSubStr( sWeapon, "iw5_1887_mp" ) && sMeansOfDeath != "MOD_MELEE" )
		iDamage = 35;

	self [[level.prevCallbackPlayerDamage2]]( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset );
}

main()
{
	// fix G-GetPlayereye bug
	replaceFunc( maps\mp\killstreaks\_helicopter::heli_leave, ::heli_leave );
	replaceFunc( maps\mp\killstreaks\_helicopter::heli_explode, ::heli_explode );

	// allow scr_xpscale to be anything
	replaceFunc( maps\mp\gametypes\_rank::init, ::rank_init );
	replaceFunc( maps\mp\gametypes\_rank::syncXPStat, ::syncXPStat );

	// add scr_spawnpointfavorweight dvar
	replaceFunc( maps\mp\gametypes\_spawnlogic::getSpawnpoint_NearTeam, ::getSpawnpoint_NearTeam );

	// add damage numbers
	replaceFunc( maps\mp\gametypes\_damage::finishPlayerDamageWrapper, ::finishPlayerDamageWrapper );

	// more perks for specialist bonus
	replaceFunc( maps\mp\killstreaks\_killstreaks::giveAllPerks, ::giveAllPerks );

	// scavenge all types of ammo
	replaceFunc( maps\mp\gametypes\_weapons::handleScavengerBagPickup, ::handleScavengerBagPickup );

	// only nuke slow mo once
	replaceFunc( maps\mp\killstreaks\_nuke::nukeSlowMo, ::nukeSlowMo );

	// fix array index issue with remoteuav when gettime is high
	replaceFunc( maps\mp\killstreaks\_remoteuav::remoteUAV_trackEntities, ::remoteUAV_trackEntities );
	replaceFunc( maps\mp\killstreaks\_remoteuav::remoteUAV_unmarkRemovedPlayer, ::remoteUAV_unmarkRemovedPlayer );
}

heli_explode( var_0 )
{
	self notify( "death" );

	if ( isdefined( var_0 ) && isdefined( level.chopper_fx["explode"]["air_death"][self.heli_type] ) )
	{
		var_1 = self gettagangles( "tag_deathfx" );
		playfx( level.chopper_fx["explode"]["air_death"][self.heli_type], self gettagorigin( "tag_deathfx" ), anglestoforward( var_1 ), anglestoup( var_1 ) );
	}
	else
	{
		var_2 = self.origin;
		var_3 = self.origin + ( 0, 0, 1 ) - self.origin;
		playfx( level.chopper_fx["explode"]["death"][self.heli_type], var_2, var_3 );
	}

	self playsound( level.heli_sound[self.team]["crash"] );
	wait 0.05;

	if ( isdefined( self.killCamEnt ) )
		self.killCamEnt delete ();

	if ( self.heliType == "osprey_gunner" )
	{
		if ( isDefined( self ) )
			self hide();

		wait 30;

		maps\mp\_utility::decrementFauxVehicleCount();

		if ( isDefined( self ) )
			self delete ();
	}
	else
	{
		maps\mp\_utility::decrementFauxVehicleCount();
		self delete ();
	}
}

heli_leave( var_0 )
{
	self notify( "leaving" );

	if ( isdefined( self.heliType ) && self.heliType == "osprey" && isdefined( self.pathGoal ) )
	{
		self setvehgoalpos( self.pathGoal, 1 );
		common_scripts\utility::waittill_any_timeout( 5, "goal" );
	}

	if ( !isdefined( var_0 ) )
	{
		var_1 = level.heli_leave_nodes[randomint( level.heli_leave_nodes.size )];
		var_0 = var_1.origin;
	}

	var_2 = spawn( "script_origin", var_0 );

	if ( isdefined( var_2 ) )
	{
		self setlookatent( var_2 );
		var_2 thread maps\mp\killstreaks\_helicopter::wait_and_delete( 3.0 );
	}

	maps\mp\killstreaks\_helicopter::heli_reset();
	self vehicle_setspeed( 100, 45 );
	self setvehgoalpos( var_0, 1 );
	self waittillmatch( "goal" );
	self notify( "death" );
	wait 0.05;

	if ( isdefined( self.killCamEnt ) )
		self.killCamEnt delete ();

	if ( self.heliType == "osprey_gunner" )
	{
		if ( isDefined( self ) )
			self hide();

		wait 30;

		maps\mp\_utility::decrementFauxVehicleCount();

		if ( isDefined( self ) )
			self delete ();
	}
	else
	{
		maps\mp\_utility::decrementFauxVehicleCount();
		self delete ();
	}
}

syncXPStat()
{
	var_0 = maps\mp\gametypes\_rank::getRankXP();
	maps\mp\gametypes\_persistence::statSet( "experience", var_0 );
}

rank_init()
{
	level.scoreInfo = [];
	level.xpScale = getdvarint( "scr_xpscale_" );
	level.weaponxpscale = getdvarint( "scr_weaponxpscale_" );
	level.rankTable = [];
	level.weaponRankTable = [];
	precacheshader( "white" );
	precachestring( &"RANK_PLAYER_WAS_PROMOTED_N" );
	precachestring( &"RANK_PLAYER_WAS_PROMOTED" );
	precachestring( &"RANK_WEAPON_WAS_PROMOTED" );
	precachestring( &"RANK_PROMOTED" );
	precachestring( &"RANK_PROMOTED_WEAPON" );
	precachestring( &"MP_PLUS" );
	precachestring( &"RANK_ROMANI" );
	precachestring( &"RANK_ROMANII" );
	precachestring( &"RANK_ROMANIII" );
	precachestring( &"SPLASHES_LONGSHOT" );
	precachestring( &"SPLASHES_PROXIMITYASSIST" );
	precachestring( &"SPLASHES_PROXIMITYKILL" );
	precachestring( &"SPLASHES_EXECUTION" );
	precachestring( &"SPLASHES_AVENGER" );
	precachestring( &"SPLASHES_ASSISTEDSUICIDE" );
	precachestring( &"SPLASHES_DEFENDER" );
	precachestring( &"SPLASHES_POSTHUMOUS" );
	precachestring( &"SPLASHES_REVENGE" );
	precachestring( &"SPLASHES_DOUBLEKILL" );
	precachestring( &"SPLASHES_TRIPLEKILL" );
	precachestring( &"SPLASHES_MULTIKILL" );
	precachestring( &"SPLASHES_BUZZKILL" );
	precachestring( &"SPLASHES_COMEBACK" );
	precachestring( &"SPLASHES_KNIFETHROW" );
	precachestring( &"SPLASHES_ONE_SHOT_KILL" );

	if ( level.teamBased )
	{
		maps\mp\gametypes\_rank::registerScoreInfo( "kill", 100 );
		maps\mp\gametypes\_rank::registerScoreInfo( "headshot", 100 );
		maps\mp\gametypes\_rank::registerScoreInfo( "assist", 20 );
		maps\mp\gametypes\_rank::registerScoreInfo( "proximityassist", 20 );
		maps\mp\gametypes\_rank::registerScoreInfo( "proximitykill", 20 );
		maps\mp\gametypes\_rank::registerScoreInfo( "suicide", 0 );
		maps\mp\gametypes\_rank::registerScoreInfo( "teamkill", 0 );
	}
	else
	{
		maps\mp\gametypes\_rank::registerScoreInfo( "kill", 50 );
		maps\mp\gametypes\_rank::registerScoreInfo( "headshot", 50 );
		maps\mp\gametypes\_rank::registerScoreInfo( "assist", 0 );
		maps\mp\gametypes\_rank::registerScoreInfo( "suicide", 0 );
		maps\mp\gametypes\_rank::registerScoreInfo( "teamkill", 0 );
	}

	maps\mp\gametypes\_rank::registerScoreInfo( "win", 1 );
	maps\mp\gametypes\_rank::registerScoreInfo( "loss", 0.5 );
	maps\mp\gametypes\_rank::registerScoreInfo( "tie", 0.75 );
	maps\mp\gametypes\_rank::registerScoreInfo( "capture", 300 );
	maps\mp\gametypes\_rank::registerScoreInfo( "defend", 300 );
	maps\mp\gametypes\_rank::registerScoreInfo( "challenge", 2500 );
	level.maxRank = int( tablelookup( "mp/rankTable.csv", 0, "maxrank", 1 ) );
	level.maxPrestige = int( tablelookup( "mp/rankIconTable.csv", 0, "maxprestige", 1 ) );
	var_0 = 0;
	var_1 = 0;

	for ( var_0 = 0; var_0 <= min( 10, level.maxPrestige ); var_0++ )
	{
		for ( var_1 = 0; var_1 <= level.maxRank; var_1++ )
			precacheshader( tablelookup( "mp/rankIconTable.csv", 0, var_1, var_0 + 1 ) );
	}

	var_2 = 0;

	for ( var_3 = tablelookup( "mp/ranktable.csv", 0, var_2, 1 ); isdefined( var_3 ) && var_3 != ""; var_3 = tablelookup( "mp/ranktable.csv", 0, var_2, 1 ) )
	{
		level.rankTable[var_2][1] = tablelookup( "mp/ranktable.csv", 0, var_2, 1 );
		level.rankTable[var_2][2] = tablelookup( "mp/ranktable.csv", 0, var_2, 2 );
		level.rankTable[var_2][3] = tablelookup( "mp/ranktable.csv", 0, var_2, 3 );
		level.rankTable[var_2][7] = tablelookup( "mp/ranktable.csv", 0, var_2, 7 );
		precachestring( tablelookupistring( "mp/ranktable.csv", 0, var_2, 16 ) );
		var_2++;
	}

	var_4 = int( tablelookup( "mp/weaponRankTable.csv", 0, "maxrank", 1 ) );

	for ( var_5 = 0; var_5 < var_4 + 1; var_5++ )
	{
		level.weaponRankTable[var_5][1] = tablelookup( "mp/weaponRankTable.csv", 0, var_5, 1 );
		level.weaponRankTable[var_5][2] = tablelookup( "mp/weaponRankTable.csv", 0, var_5, 2 );
		level.weaponRankTable[var_5][3] = tablelookup( "mp/weaponRankTable.csv", 0, var_5, 3 );
	}

	maps\mp\gametypes\_missions::buildChallegeInfo();
	level thread maps\mp\gametypes\_rank::patientZeroWaiter();
	level thread maps\mp\gametypes\_rank::onPlayerConnect();
}

getSpawnpoint_NearTeam( var_0, var_1 )
{
	if ( !isdefined( var_0 ) )
		return undefined;

	maps\mp\gametypes\_spawnlogic::Spawnlogic_Begin();
	maps\mp\gametypes\_spawnlogic::initWeights( var_0 );

	var_2 = 2;

	if ( getDVar( "scr_alliedDistanceWeight" ) != "" )
		var_2 = getDVarFloat( "scr_alliedDistanceWeight" );

	var_3 = self.team;
	var_4 = maps\mp\_utility::getOtherTeam( var_3 );
	var_5 = getentarray( "care_package", "targetname" );

	foreach ( var_7 in var_0 )
	{
		if ( var_7.numPlayersAtLastUpdate > 0 )
		{
			var_8 = var_7.weightedDistSum[var_3];
			var_9 = var_7.distSum[var_4];
			var_7.weight = ( var_9 - var_2 * var_8 ) / var_7.numPlayersAtLastUpdate;

			if ( isdefined( level.favorCloseSpawnEnt ) )
			{
				if ( !isdefined( level.favorCloseSpawnScalar ) )
					level.favorCloseSpawnScalar = 1;

				var_10 = distance( var_7.origin, level.favorCloseSpawnEnt.origin );
				var_7.weight = var_7.weight - var_10 * level.favorCloseSpawnScalar;
			}

			if ( isdefined( level.favorclosespawnentattacker ) )
			{
				if ( !isdefined( level.favorclosespawnscalarattacker ) )
					level.favorclosespawnscalarattacker = 1;

				var_10 = distance( var_7.origin, level.favorclosespawnentattacker.origin );
				var_7.weight = var_7.weight - var_10 * level.favorclosespawnscalarattacker;
			}

			if ( isdefined( level.favorclosespawnentdefender ) )
			{
				if ( !isdefined( level.favorclosespawnscalardefender ) )
					level.favorclosespawnscalardefender = 1;

				var_10 = distance( var_7.origin, level.favorclosespawnentdefender.origin );
				var_7.weight = var_7.weight - var_10 * level.favorclosespawnscalardefender;
			}
		}
		else
			var_7.weight = 0;

		if ( var_5.size && !canspawn( var_7.origin ) )
			var_7.weight = var_7.weight - 500000;
	}

	favor_weight = 50000;

	if ( getDVar( "scr_spawnpointfavorweight" ) != "" )
		favor_weight = getDVarInt( "scr_spawnpointfavorweight" );

	if ( isdefined( var_1 ) )
	{
		for ( var_12 = 0; var_12 < var_1.size; var_12++ )
			var_1[var_12].weight = var_1[var_12].weight + favor_weight;
	}

	if ( isdefined( self.predictedSpawnPoint ) && isdefined( self.predictedSpawnPoint.weight ) )
		self.predictedSpawnPoint.weight = self.predictedSpawnPoint.weight + 100;

	maps\mp\gametypes\_spawnlogic::avoidSameSpawn();
	maps\mp\gametypes\_spawnlogic::avoidWeaponDamage( var_0 );
	maps\mp\gametypes\_spawnlogic::avoidVisibleEnemies( var_0, 1 );

	if ( isdefined( self.lastDeathPos ) && level.gameType != "dom" )
		maps\mp\gametypes\_spawnlogic::avoidRevengeSpawn( var_0, self.lastDeathPos );

	var_13 = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Final( var_0 );
	return var_13;
}

doPrintDamage( dmg, hitloc, flags )
{
	self endon( "disconnect" );

	huddamage = newclienthudelem( self );
	huddamage.alignx = "center";
	huddamage.horzalign = "center";
	huddamage.x = 10;
	huddamage.y = 235;
	huddamage.fontscale = 1.6;
	huddamage.font = "objective";
	huddamage setvalue( dmg );

	if ( ( flags & level.iDFLAGS_RADIUS ) != 0 )
		huddamage.color = ( 0.25, 0.25, 0.25 );

	if ( ( flags & level.iDFLAGS_PENETRATION ) != 0 )
		huddamage.color = ( 1, 1, 0.25 );

	if ( hitloc == "head" )
		huddamage.color = ( 1, 0.25, 0.25 );

	huddamage moveovertime( 1 );
	huddamage fadeovertime( 1 );
	huddamage.alpha = 0;
	huddamage.x = randomIntRange( 25, 70 );

	val = 1;

	if ( randomInt( 2 ) )
		val = -1;

	huddamage.y = 235 + randomIntRange( 25, 70 ) * val;

	wait 1;

	if ( isDefined( huddamage ) )
		huddamage destroy();
}

finishPlayerDamageWrapper( var_0, var_1, var_2, var_3, var_4, var_5, var_6, var_7, var_8, var_9, var_10 )
{
	if ( isDefined( level.allowPrintDamage ) && level.allowPrintDamage )
	{
		if ( !isDefined( var_1 ) )
		{
			if ( !isDefined( var_0 ) )
				self thread doPrintDamage( var_2, var_8, var_3 );
		}
		else if ( isPlayer( var_1 ) && isDefined( var_1.printDamage ) && var_1.printDamage )
			var_1 thread doPrintDamage( var_2, var_8, var_3 );
		else if ( isDefined( var_1.owner ) && isPlayer( var_1.owner ) && isDefined( var_1.owner.printDamage ) && var_1.owner.printDamage )
			var_1.owner thread doPrintDamage( var_2, var_8, var_3 );
	}

	if ( maps\mp\_utility::isUsingRemote() && var_2 >= self.health && !( var_3 & level.iDFLAGS_STUN ) )
	{
		if ( !isdefined( var_7 ) )
			var_7 = ( 0, 0, 0 );

		if ( !isdefined( var_1 ) && !isdefined( var_0 ) )
		{
			var_1 = self;
			var_0 = var_1;
		}

		maps\mp\gametypes\_damage::PlayerKilled_internal( var_0, var_1, self, var_2, var_4, var_5, var_7, var_8, var_9, 0, 1 );
	}
	else
	{
		if ( !maps\mp\gametypes\_damage::Callback_KillingBlow( var_0, var_1, var_2 - var_2 * var_10, var_3, var_4, var_5, var_6, var_7, var_8, var_9 ) )
			return;

		if ( !isalive( self ) )
			return;

		self finishplayerdamage( var_0, var_1, var_2, var_3, var_4, var_5, var_6, var_7, var_8, var_9, var_10 );
	}

	if ( var_4 == "MOD_EXPLOSIVE_BULLET" )
		self shellshock( "damage_mp", getdvarfloat( "scr_csmode" ) );

	maps\mp\gametypes\_damage::damageShellshockAndRumble( var_0, var_5, var_4, var_2, var_3, var_1 );
}

giveAllPerks()
{
	var_0 = [];
	var_0[var_0.size] = "specialty_longersprint";
	var_0[var_0.size] = "specialty_fastreload";
	var_0[var_0.size] = "specialty_scavenger";
	var_0[var_0.size] = "specialty_blindeye";
	var_0[var_0.size] = "specialty_paint";
	var_0[var_0.size] = "specialty_hardline";
	var_0[var_0.size] = "specialty_coldblooded";
	var_0[var_0.size] = "specialty_quickdraw";
	var_0[var_0.size] = "_specialty_blastshield";
	var_0[var_0.size] = "specialty_detectexplosive";
	var_0[var_0.size] = "specialty_autospot";
	var_0[var_0.size] = "specialty_bulletaccuracy";
	var_0[var_0.size] = "specialty_quieter";
	var_0[var_0.size] = "specialty_stalker";
	var_0[var_0.size] = "specialty_marksman";
	var_0[var_0.size] = "specialty_sharp_focus";
	var_0[var_0.size] = "specialty_longerrange";
	var_0[var_0.size] = "specialty_fastermelee";
	var_0[var_0.size] = "specialty_reducedsway";
	var_0[var_0.size] = "specialty_lightweight";

	// patch_mp removed these? why
	var_0[ var_0.size ] = "specialty_bulletpenetration";
	var_0[ var_0.size ] = "specialty_holdbreathwhileads";

	// too op?
	var_0[ var_0.size ] = "specialty_moredamage";

	foreach ( var_2 in var_0 )
	{
		if ( !maps\mp\_utility::_hasPerk( var_2 ) )
		{
			maps\mp\_utility::givePerk( var_2, 0 );

			if ( maps\mp\gametypes\_class::isPerkUpgraded( var_2 ) )
			{
				var_3 = tablelookup( "mp/perktable.csv", 1, var_2, 8 );
				maps\mp\_utility::givePerk( var_3, 0 );
			}
		}
	}
}

handleScavengerBagPickup( var_0 )
{
	self endon( "death" );
	level endon( "game_ended" );
	self waittill( "scavenger",  var_1  );
	var_1 notify( "scavenger_pickup" );
	var_1 playlocalsound( "scavenger_pack_pickup" );
	var_2 = var_1 getweaponslistoffhands();

	foreach ( var_4 in var_2 )
	{
		var_5 = var_1 getweaponammoclip( var_4 );
		var_1 setweaponammoclip( var_4, var_5 + 1 );
	}

	var_7 = var_1 getweaponslistprimaries();

	foreach ( var_9 in var_7 )
	{
		var_10 = var_1 getweaponammostock( var_9 );
		var_11 = weaponclipsize( var_9 );
		var_1 setweaponammostock( var_9, var_10 + var_11 );
	}

	var_1 maps\mp\gametypes\_damagefeedback::updateDamageFeedback( "scavenger" );
}

nukeSlowMo()
{
	level endon ( "nuke_cancelled" );

	if ( isDefined( level.nuked ) )
		return;

	//SetSlowMotion( <startTimescale>, <endTimescale>, <deltaTime> )
	SetSlowMotion( 1.0, 0.25, 0.5 );
	level waittill( "nuke_death" );
	SetSlowMotion( 0.25, 1, 2.0 );

	level.nuked = true;
}

remoteUAV_trackEntities( var_0, var_1, var_2 )
{
	level endon( "game_ended" );
	var_3 = undefined;

	foreach ( var_5 in var_1 )
	{
		if ( level.teamBased && ( !isdefined( var_5.team ) || var_5.team == self.team ) )
			continue;

		if ( isplayer( var_5 ) )
		{
			if ( !maps\mp\_utility::isReallyAlive( var_5 ) )
				continue;

			if ( var_5 == self )
				continue;

			var_6 = var_5.guid + "";
		}
		else
			var_6 = var_5.birthtime + "";

		if ( isdefined( var_5.sentryType ) || isdefined( var_5.turretType ) )
		{
			var_7 = ( 0, 0, 32 );
			var_8 = "hud_fofbox_hostile_vehicle";
		}
		else if ( isdefined( var_5.uavType ) )
		{
			var_7 = ( 0, 0, -52 );
			var_8 = "hud_fofbox_hostile_vehicle";
		}
		else
		{
			var_7 = ( 0, 0, 26 );
			var_8 = "veh_hud_target_unmarked";
		}

		if ( isdefined( var_5.UAVRemoteMarkedBy ) )
		{
			if ( !isdefined( var_0.markedPlayers[var_6] ) )
			{
				var_0.markedPlayers[var_6] = [];
				var_0.markedPlayers[var_6]["player"] = var_5;
				var_0.markedPlayers[var_6]["icon"] = var_5 maps\mp\_entityheadicons::setHeadIcon( self, "veh_hud_target_marked", var_7, 10, 10, 0, 0.05, 0, 0, 0, 0 );
				var_0.markedPlayers[var_6]["icon"].shader = "veh_hud_target_marked";

				if ( !isdefined( var_5.sentryType ) || !isdefined( var_5.turretType ) )
					var_0.markedPlayers[var_6]["icon"] settargetent( var_5 );
			}
			else if ( isdefined( var_0.markedPlayers[var_6] ) && isdefined( var_0.markedPlayers[var_6]["icon"] ) && isdefined( var_0.markedPlayers[var_6]["icon"].shader ) && var_0.markedPlayers[var_6]["icon"].shader != "veh_hud_target_marked" )
			{
				var_0.markedPlayers[var_6]["icon"].shader = "veh_hud_target_marked";
				var_0.markedPlayers[var_6]["icon"] setshader( "veh_hud_target_marked", 10, 10 );
				var_0.markedPlayers[var_6]["icon"] setwaypoint( 0, 0, 0, 0 );
			}

			continue;
		}

		if ( isplayer( var_5 ) )
		{
			var_9 = isdefined( var_5.spawnTime ) && ( gettime() - var_5.spawnTime ) / 1000 <= 5;
			var_10 = var_5 maps\mp\_utility::_hasPerk( "specialty_blindeye" );
			var_11 = 0;
			var_12 = 0;
		}
		else
		{
			var_9 = 0;
			var_10 = 0;
			var_11 = isdefined( var_5.carriedBy );
			var_12 = isdefined( var_5.isLeaving ) && var_5.isLeaving == 1;
		}

		if ( !isdefined( var_0.markedPlayers[var_6] ) && !var_9 && !var_10 && !var_11 && !var_12 )
		{
			var_0.markedPlayers[var_6] = [];
			var_0.markedPlayers[var_6]["player"] = var_5;
			var_0.markedPlayers[var_6]["icon"] = var_5 maps\mp\_entityheadicons::setHeadIcon( self, var_8, var_7, 10, 10, 0, 0.05, 0, 0, 0, 0 );
			var_0.markedPlayers[var_6]["icon"].shader = var_8;

			if ( !isdefined( var_5.sentryType ) || !isdefined( var_5.turretType ) )
				var_0.markedPlayers[var_6]["icon"] settargetent( var_5 );
		}

		if ( ( !isdefined( var_3 ) || var_3 != var_5 ) && ( isdefined( var_0.trace["entity"] ) && var_0.trace["entity"] == var_5 && !var_11 && !var_12 ) || distance( var_5.origin, var_2 ) < 200 * var_0.trace["fraction"] && !var_9 && !var_11 && !var_12 || !var_12 && maps\mp\killstreaks\_remoteuav::remoteUAV_canTargetUAV( var_0, var_5 ) )
		{
			var_13 = bullettrace( var_0.origin, var_5.origin + ( 0, 0, 32 ), 1, var_0 );

			if ( isdefined( var_13["entity"] ) && var_13["entity"] == var_5 || var_13["fraction"] == 1 )
			{
				self playlocalsound( "recondrone_lockon" );
				var_3 = var_5;
			}
		}
	}

	return var_3;
}

remoteUAV_unmarkRemovedPlayer( var_0 )
{
	level endon( "game_ended" );
	var_1 = common_scripts\utility::waittill_any_return( "death", "disconnect", "carried", "leaving" );

	if ( var_1 == "leaving" || !isdefined( self.uavType ) )
		self.UAVRemoteMarkedBy = undefined;

	if ( isdefined( var_0 ) )
	{
		if ( isplayer( self ) )
			var_2 = self.guid + "";
		else if ( isdefined( self.birthtime ) )
			var_2 = self.birthtime + "";
		else
			var_2 = self.birth_time + "";

		if ( var_1 == "carried" || var_1 == "leaving" )
		{
			var_0.markedPlayers[var_2]["icon"] destroy();
			var_0.markedPlayers[var_2]["icon"] = undefined;
		}

		if ( isdefined( var_2 ) && isdefined( var_0.markedPlayers[var_2] ) )
		{
			var_0.markedPlayers[var_2] = undefined;
			var_0.markedPlayers = common_scripts\utility::array_removeUndefined( var_0.markedPlayers );
		}
	}

	if ( isplayer( self ) )
		self unsetperk( "specialty_radarblip", 1 );
	else
	{
		if ( isdefined( self.remoteUAVMarkedObjID01 ) )
			maps\mp\_utility::_objective_delete( self.remoteUAVMarkedObjID01 );

		if ( isdefined( self.remoteUAVMarkedObjID02 ) )
			maps\mp\_utility::_objective_delete( self.remoteUAVMarkedObjID02 );

		if ( isdefined( self.remoteUAVMarkedObjID03 ) )
			maps\mp\_utility::_objective_delete( self.remoteUAVMarkedObjID03 );
	}
}

onPlayerConnect()
{
	for ( ;; )
	{
		level waittill( "connected", player );

		player thread onChangeKit();

		print( "Player connected: " + player.name + " guid " + player getGuid() );
		player thread onPlayerDisconnect();
	}
}

onPlayerDisconnect()
{
	name = self.name;
	guid = self getGuid();

	self waittill( "disconnect" );

	print( "Player disconnected: " + name + " guid " + guid );
}

watchNuke()
{
	setDvar( "scr_spawnpointfavorweight", "" );
	level waittill( "nuke_death" );
	setDvar( "scr_spawnpointfavorweight", "499999" );
}

onChangeKit()
{
	self endon( "disconnect" );

	self.printDamage = true;

	for ( ;; )
	{
		self waittill( "changed_kit" );

		if ( level.killstreakPrint )
			self thread watchNotifyKSMessage();
	}
}

watchNotifyKSMessage()
{
	self endon( "disconnect" );
	self endon( "changed_kit" );

	for ( lastKs = self.pers["cur_kill_streak_for_nuke"];; )
	{
		wait 0.05;

		for ( curStreak = lastKs + 1; curStreak <= self.pers["cur_kill_streak_for_nuke"]; curStreak++ )
		{
			//if (curStreak == 5)
			//	continue;

			if ( curStreak % 5 != 0 )
				continue;

			self thread streakNotify( curStreak );
		}

		lastKs = self.pers["cur_kill_streak_for_nuke"];
	}
}

streakNotify( streakVal )
{
	self endon( "disconnect" );

	notifyData = spawnStruct();

	if ( level.killstreakPrint > 1 )
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
