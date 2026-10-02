/*
	_bot
	Author: INeedGames
	Date: 05/07/2021
	The entry point and manager of the bots.
*/

#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\bots\_bot_utility;

/*
	Initiates the whole bot scripts.
*/
init()
{
	level.bw_version = "2.3.0";
	
	if ( getdvar( "bots_main" ) == "" )
	{
		setdvar( "bots_main", true );
	}
	
	if ( !getdvarint( "bots_main" ) )
	{
		return;
	}
	
	if ( !wait_for_builtins() )
	{
		println( "FATAL: NO BUILT-INS FOR BOTS" );
	}
	
	thread load_waypoints();
	thread hook_callbacks();
	
	if ( getdvar( "bots_main_GUIDs" ) == "" )
	{
		setdvar( "bots_main_GUIDs", "" ); // guids of players who will be given host powers, comma seperated
	}
	
	if ( getdvar( "bots_main_firstIsHost" ) == "" )
	{
		setdvar( "bots_main_firstIsHost", false ); // first play to connect is a host
	}
	
	if ( getdvar( "bots_main_waitForHostTime" ) == "" )
	{
		setdvar( "bots_main_waitForHostTime", 10.0 ); // how long to wait to wait for the host player
	}
	
	if ( getdvar( "bots_main_kickBotsAtEnd" ) == "" )
	{
		setdvar( "bots_main_kickBotsAtEnd", false ); // kicks the bots at game end
	}
	
	if ( getdvar( "bots_manage_add" ) == "" )
	{
		setdvar( "bots_manage_add", 0 ); // amount of bots to add to the game
	}
	
	if ( getdvar( "bots_manage_fill" ) == "" )
	{
		setdvar( "bots_manage_fill", 0 ); // amount of bots to maintain
	}
	
	if ( getdvar( "bots_manage_fill_spec" ) == "" )
	{
		setdvar( "bots_manage_fill_spec", true ); // to count for fill if player is on spec team
	}
	
	if ( getdvar( "bots_manage_fill_mode" ) == "" )
	{
		setdvar( "bots_manage_fill_mode", 0 ); // fill mode, 0 adds everyone, 1 just bots, 2 maintains at maps, 3 is 2 with 1
	}
	
	if ( getdvar( "bots_manage_fill_kick" ) == "" )
	{
		setdvar( "bots_manage_fill_kick", false ); // kick bots if too many
	}
	
	if ( getdvar( "bots_manage_fill_watchplayers" ) == "" )
	{
		setdvar( "bots_manage_fill_watchplayers", false ); // add bots when player exists, kick if not
	}
	
	if ( getdvar( "bots_team" ) == "" )
	{
		setdvar( "bots_team", "autoassign" ); // which team for bots to join
	}
	
	if ( getdvar( "bots_team_amount" ) == "" )
	{
		setdvar( "bots_team_amount", 0 ); // amount of bots on axis team
	}
	
	if ( getdvar( "bots_team_force" ) == "" )
	{
		setdvar( "bots_team_force", false ); // force bots on team
	}
	
	if ( getdvar( "bots_team_mode" ) == "" )
	{
		setdvar( "bots_team_mode", 0 ); // counts just bots when 1
	}
	
	if ( getdvar( "bots_skill" ) == "" )
	{
		setdvar( "bots_skill", 0 ); // 0 is random, 1 is easy 7 is hard, 8 is custom, 9 is completely random
	}
	
	if ( getdvar( "bots_skill_axis_hard" ) == "" )
	{
		setdvar( "bots_skill_axis_hard", 0 ); // amount of hard bots on axis team
	}
	
	if ( getdvar( "bots_skill_axis_med" ) == "" )
	{
		setdvar( "bots_skill_axis_med", 0 );
	}
	
	if ( getdvar( "bots_skill_allies_hard" ) == "" )
	{
		setdvar( "bots_skill_allies_hard", 0 );
	}
	
	if ( getdvar( "bots_skill_allies_med" ) == "" )
	{
		setdvar( "bots_skill_allies_med", 0 );
	}
	
	if ( getdvar( "bots_skill_min" ) == "" )
	{
		setdvar( "bots_skill_min", 1 );
	}
	
	if ( getdvar( "bots_skill_max" ) == "" )
	{
		setdvar( "bots_skill_max", 7 );
	}
	
	if ( getdvar( "bots_loadout_reasonable" ) == "" ) // filter out the bad 'guns' and perks
	{
		setdvar( "bots_loadout_reasonable", false );
	}
	
	if ( getdvar( "bots_loadout_allow_op" ) == "" ) // allows jug, marty and laststand
	{
		setdvar( "bots_loadout_allow_op", true );
	}
	
	if ( getdvar( "bots_loadout_rank" ) == "" ) // what rank the bots should be around, -1 is around the players, 0 is all random
	{
		setdvar( "bots_loadout_rank", -1 );
	}
	
	if ( getdvar( "bots_loadout_prestige" ) == "" ) // what pretige the bots will be, -1 is the players, -2 is random
	{
		setdvar( "bots_loadout_prestige", -1 );
	}
	
	if ( getdvar( "bots_play_move" ) == "" ) // bots move
	{
		setdvar( "bots_play_move", true );
	}
	
	if ( getdvar( "bots_play_knife" ) == "" ) // bots knife
	{
		setdvar( "bots_play_knife", true );
	}
	
	if ( getdvar( "bots_play_fire" ) == "" ) // bots fire
	{
		setdvar( "bots_play_fire", true );
	}
	
	if ( getdvar( "bots_play_nade" ) == "" ) // bots grenade
	{
		setdvar( "bots_play_nade", true );
	}
	
	if ( getdvar( "bots_play_take_carepackages" ) == "" ) // bots take carepackages
	{
		setdvar( "bots_play_take_carepackages", true );
	}
	
	if ( getdvar( "bots_play_obj" ) == "" ) // bots play the obj
	{
		setdvar( "bots_play_obj", true );
	}
	
	if ( getdvar( "bots_play_camp" ) == "" ) // bots camp and follow
	{
		setdvar( "bots_play_camp", true );
	}
	
	if ( getdvar( "bots_play_jumpdrop" ) == "" ) // bots jump and dropshot
	{
		setdvar( "bots_play_jumpdrop", true );
	}
	
	if ( getdvar( "bots_play_target_other" ) == "" ) // bot target non play ents (vehicles)
	{
		setdvar( "bots_play_target_other", true );
	}
	
	if ( getdvar( "bots_play_killstreak" ) == "" ) // bot use killstreaks
	{
		setdvar( "bots_play_killstreak", true );
	}
	
	if ( getdvar( "bots_play_ads" ) == "" ) // bot ads
	{
		setdvar( "bots_play_ads", true );
	}
	
	if ( getdvar( "bots_play_aim" ) == "" )
	{
		setdvar( "bots_play_aim", true );
	}
	
	if ( getdvar( "bots_play_stance" ) == "" ) // force bots to only use this stance (stand, crouch or prone), anything else is normal
	{
		setdvar( "bots_play_stance", "none" );
	}
	
	if ( getdvar( "bots_play_recoil" ) == "" ) // how much weapon recoil affects the bots' aim, 0 disables
	{
		setdvar( "bots_play_recoil", 1.0 );
	}
	
	if ( getdvar( "bots_skill_dynamic" ) == "" ) // 0 off, 1 bots' difficulty by amount of human players, 2 bots' difficulty adapts to their kdr
	{
		setdvar( "bots_skill_dynamic", 0 );
	}
	
	if ( getdvar( "bots_skill_dynamic_players" ) == "" ) // bots_skill_dynamic 1, the difficulty for 1, 2, 3... human players, the last value is used for anything more
	{
		setdvar( "bots_skill_dynamic_players", "2,2,2,4,4,4,4,7" );
	}
	
	if ( getdvar( "bots_main_xp_kill" ) == "" ) // multiplier of the kill xp players get for killing a bot
	{
		setdvar( "bots_main_xp_kill", 1.0 );
	}
	
	if ( getdvar( "bots_main_xp_weapon" ) == "" ) // multiplier of the weapon xp players get for killing a bot
	{
		setdvar( "bots_main_xp_weapon", 1.0 );
	}
	
	// overrides the bots' difficulty behavior values, -1 uses the difficulty's value
	behaviors = strtok( "strafe,nade,sprint,camp,follow,crouch,switch,class,jump", "," );
	
	for ( i = 0; i < behaviors.size; i++ )
	{
		if ( getdvar( "bots_behavior_" + behaviors[ i ] ) == "" )
		{
			setdvar( "bots_behavior_" + behaviors[ i ], -1 );
		}
	}
	
	level.bot_behavior_overrides = behaviors;
	
	if ( !isdefined( game[ "botWarfare" ] ) )
	{
		game[ "botWarfare" ] = true;
		game[ "botWarfareInitTime" ] = gettime();
	}
	
	level.bot_inittime = gettime();
	
	level.defuseobject = undefined;
	level.bots_smokelist = List();
	level.bots_fraglist = List();
	
	level.bots_minsprintdistance = 315;
	level.bots_minsprintdistance *= level.bots_minsprintdistance;
	level.bots_mingrenadedistance = 256;
	level.bots_mingrenadedistance *= level.bots_mingrenadedistance;
	level.bots_maxgrenadedistance = 1024;
	level.bots_maxgrenadedistance *= level.bots_maxgrenadedistance;
	level.bots_maxknifedistance = 128;
	level.bots_maxknifedistance *= level.bots_maxknifedistance;
	level.bots_goaldistance = 27.5;
	level.bots_goaldistance *= level.bots_goaldistance;
	level.bots_noadsdistance = 200;
	level.bots_noadsdistance *= level.bots_noadsdistance;
	level.bots_maxshotgundistance = 500;
	level.bots_maxshotgundistance *= level.bots_maxshotgundistance;
	level.bots_listendist = 100;
	
	level.smokeradius = 255;
	
	level.bots = [];
	
	level.bots_fullautoguns = [];
	level.bots_fullautoguns[ "fmg9" ] = true;
	level.bots_fullautoguns[ "skorpion" ] = true;
	level.bots_fullautoguns[ "mp9" ] = true;
	level.bots_fullautoguns[ "g18" ] = true;
	level.bots_fullautoguns[ "mp5" ] = true;
	level.bots_fullautoguns[ "m9" ] = true;
	level.bots_fullautoguns[ "p90" ] = true;
	level.bots_fullautoguns[ "pp90m1" ] = true;
	level.bots_fullautoguns[ "ump45" ] = true;
	level.bots_fullautoguns[ "mp7" ] = true;
	level.bots_fullautoguns[ "ak47" ] = true;
	level.bots_fullautoguns[ "m4" ] = true;
	level.bots_fullautoguns[ "fad" ] = true;
	level.bots_fullautoguns[ "acr" ] = true;
	level.bots_fullautoguns[ "scar" ] = true;
	level.bots_fullautoguns[ "g36c" ] = true;
	level.bots_fullautoguns[ "cm901" ] = true;
	level.bots_fullautoguns[ "aa12" ] = true;
	level.bots_fullautoguns[ "m60" ] = true;
	level.bots_fullautoguns[ "mk46" ] = true;
	level.bots_fullautoguns[ "pecheneg" ] = true;
	level.bots_fullautoguns[ "sa80" ] = true;
	level.bots_fullautoguns[ "mg36" ] = true;
	
	level.bots_fullautoguns[ "ak74u" ] = true;
	
	level.bots_fullautoguns[ "25mm" ] = true;
	level.bots_fullautoguns[ "40mm" ] = true;
	level.bots_fullautoguns[ "105mm" ] = true;
	level.bots_fullautoguns[ "remote" ] = true;
	
	level thread fixGamemodes();
	level thread fixPredMissile();
	
	level thread onPlayerConnect();
	level thread addNotifyOnAirdrops();
	level thread watchScrabler();
	level thread watchRadar();
	level thread auditModels();
	
	level thread handleBots();
	level thread onPlayerChat();
	
	array_thread( getentarray( "misc_turret", "classname" ), ::turret_monitoruse_watcher );
}

/*
	Change func pointer to ours, so that we can link the player ref to the rocket
*/
fixPredMissile()
{
	for ( i = 0; i < 19; i++ )
	{
		if ( isdefined( level.killstreakfuncs ) && isdefined( level.killstreakfuncs[ "predator_missile" ] ) )
		{
			level.killstreakfuncs[ "predator_missile" ] = ::tryUsePredatorMissileFix;
			break;
		}
		
		wait 0.05;
	}
}

/*
	Starts the threads for bots.
*/
handleBots()
{
	level thread teamBots();
	level thread diffBots();
	level addBots();
	
	while ( !level.intermission )
	{
		wait 0.05;
	}
	
	setdvar( "bots_manage_add", getBotArray().size );
	
	if ( !getdvarint( "bots_main_kickBotsAtEnd" ) )
	{
		return;
	}
	
	bots = getBotArray();
	
	for ( i = 0; i < bots.size; i++ )
	{
		kick( bots[ i ] getentitynumber() );
	}
}

/*
	The hook callback for when any player becomes damaged.
*/
onPlayerDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset )
{
	if ( self is_bot() )
	{
		self maps\mp\bots\_bot_internal::onDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset );
		self maps\mp\bots\_bot_script::onDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset );
	}
	
	self [[ level.prevcallbackplayerdamage ]]( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset );
}

/*
	The hook callback when any player gets killed.
*/
onPlayerKilled( eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration )
{
	if ( self is_bot() )
	{
		self maps\mp\bots\_bot_internal::onKilled( eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration );
		self maps\mp\bots\_bot_script::onKilled( eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration );
	}
	
	// the osprey gunner killcam crashes the game ("G_GetPlayerViewOrigin: Couldn't find tag_player on
	// player's view-link parent"), so those kills get no killcam and never become the final killcam
	if ( isdefined( sWeapon ) && sWeapon == "osprey_player_minigun_mp" )
	{
		self thread skipKillcam();
		level thread keepFinalKillcam( eAttacker );
	}
	
	self [[ level.prevcallbackplayerkilled ]]( eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration );
	
	if ( self is_bot() )
	{
		self scaleKillXP( eAttacker, sWeapon, sMeansOfDeath );
	}
}

/*
	Scales the xp a player got for killing this bot, according to the bots_main_xp_* dvars
*/
scaleKillXP( attacker, sWeapon, sMeansOfDeath )
{
	if ( !isdefined( attacker ) )
	{
		return;
	}
	
	if ( !isplayer( attacker ) && isdefined( attacker.owner ) )
	{
		attacker = attacker.owner;
	}
	
	if ( !isplayer( attacker ) || attacker == self || attacker is_bot() || !attacker rankingenabled() )
	{
		return;
	}
	
	if ( level.teambased && ( attacker.team == self.team || !level.teamcount[ "allies" ] || !level.teamcount[ "axis" ] ) )
	{
		return;
	}
	
	xpScale = getdvarfloat( "bots_main_xp_kill" );
	
	if ( xpScale != 1 && !isdefined( attacker.ischeater ) )
	{
		xpScaler = 1;
		
		if ( isdefined( attacker.xpscaler ) )
		{
			xpScaler = attacker.xpscaler;
		}
		
		xp = int( maps\mp\gametypes\_rank::getscoreinfovalue( "kill" ) * xpScaler * level.xpscale * ( xpScale - 1 ) );
		
		if ( xp != 0 )
		{
			oldXp = attacker maps\mp\gametypes\_rank::getrankxp();
			
			if ( oldXp + xp < 0 )
			{
				xp = 0 - oldXp;
			}
			
			attacker maps\mp\gametypes\_rank::incrankxp( xp );
			
			if ( attacker maps\mp\gametypes\_rank::updaterank( oldXp ) )
			{
				attacker thread maps\mp\gametypes\_rank::updaterankannouncehud();
			}
			
			attacker maps\mp\gametypes\_rank::syncxpstat();
			
			if ( xp > 0 )
			{
				attacker thread maps\mp\gametypes\_rank::xppointspopup( xp, 0, ( 1, 1, 0.5 ), 0 );
			}
		}
	}
	
	weapScale = getdvarfloat( "bots_main_xp_weapon" );
	
	if ( weapScale == 1 || !isdefined( sWeapon ) || !attacker maps\mp\gametypes\_rank::weaponshouldgetxp( sWeapon, sMeansOfDeath ) )
	{
		return;
	}
	
	if ( !isdefined( attacker.primaryweapon ) || !isdefined( attacker.secondaryweapon ) )
	{
		return;
	}
	
	if ( attacker.primaryweapon != sWeapon && attacker.secondaryweapon != sWeapon && weaponaltweaponname( attacker.primaryweapon ) != sWeapon )
	{
		return;
	}
	
	// get the base weapon name the same way the stock rank script does
	toks = strtok( sWeapon, "_" );
	
	if ( toks[ 0 ] == "iw5" )
	{
		baseWeap = toks[ 0 ] + "_" + toks[ 1 ];
	}
	else if ( toks[ 0 ] == "alt" )
	{
		baseWeap = toks[ 1 ] + "_" + toks[ 2 ];
	}
	else
	{
		baseWeap = toks[ 0 ];
	}
	
	if ( toks[ 0 ] == "gl" )
	{
		baseWeap = toks[ 1 ];
	}
	
	if ( !attacker isitemunlocked( baseWeap ) )
	{
		return;
	}
	
	// stock gives 100 weapon xp per kill, and skips weapons that are max rank (or have no ranks, like secondaries)
	oldWeapXp = attacker maps\mp\gametypes\_rank::getweaponrankxp( baseWeap );
	maxWeapXp = attacker maps\mp\gametypes\_rank::getweaponmaxrankxp( baseWeap );
	
	if ( maxWeapXp <= 0 || oldWeapXp >= maxWeapXp )
	{
		return;
	}
	
	newWeapXp = int( clamp( oldWeapXp + int( 100 * ( weapScale - 1 ) ), 0, maxWeapXp ) );
	
	if ( newWeapXp == oldWeapXp )
	{
		return;
	}
	
	attacker setplayerdata( "weaponXP", baseWeap, newWeapXp );
	
	if ( attacker maps\mp\gametypes\_rank::updateweaponrank( newWeapXp, baseWeap ) )
	{
		attacker thread maps\mp\gametypes\_rank::updateweaponrankannouncehud();
	}
}

/*
	Skips this death's killcam. The game clears cancelKillcam a moment after death and checks it about
	a second later, so it is kept set until then.
*/
skipKillcam()
{
	self endon( "disconnect" );
	self endon( "spawned_player" );
	
	for ( i = 0; i < 70; i++ )
	{
		self.cancelKillcam = true;
		wait 0.05;
	}
}

/*
	Puts the final killcam recording back to what it was before this kill, once the game has recorded it.
*/
keepFinalKillcam( attacker )
{
	if ( !isdefined( level.finalKillCam_attacker ) )
	{
		return;
	}
	
	keys = [];
	keys[ keys.size ] = "none";
	
	if ( level.teambased && isdefined( attacker ) && isdefined( attacker.team ) )
	{
		keys[ keys.size ] = attacker.team;
	}
	
	names = strtok( "delay victim attacker attackerNum killCamEntityIndex killCamEntityStartTime sWeapon deathTimeOffset psOffsetTime timeRecorded timeGameEnded", " " );
	saved = [];
	
	for ( i = 0; i < keys.size; i++ )
	{
		saved[ i ] = [];
		
		for ( j = 0; j < names.size; j++ )
		{
			saved[ i ][ j ] = getFinalKillcamField( names[ j ], keys[ i ] );
		}
	}
	
	waittillframeend;
	
	for ( i = 0; i < keys.size; i++ )
	{
		for ( j = 0; j < names.size; j++ )
		{
			setFinalKillcamField( names[ j ], keys[ i ], saved[ i ][ j ] );
		}
	}
}

/*
	Reads one of the game's level.finalKillCam_<name>[ key ] values.
*/
getFinalKillcamField( name, key )
{
	switch ( name )
	{
		case "delay":
			return level.finalKillCam_delay[ key ];
			
		case "victim":
			return level.finalKillCam_victim[ key ];
			
		case "attacker":
			return level.finalKillCam_attacker[ key ];
			
		case "attackerNum":
			return level.finalKillCam_attackerNum[ key ];
			
		case "killCamEntityIndex":
			return level.finalKillCam_killCamEntityIndex[ key ];
			
		case "killCamEntityStartTime":
			return level.finalKillCam_killCamEntityStartTime[ key ];
			
		case "sWeapon":
			return level.finalKillCam_sWeapon[ key ];
			
		case "deathTimeOffset":
			return level.finalKillCam_deathTimeOffset[ key ];
			
		case "psOffsetTime":
			return level.finalKillCam_psOffsetTime[ key ];
			
		case "timeRecorded":
			return level.finalKillCam_timeRecorded[ key ];
	}
	
	return level.finalKillCam_timeGameEnded[ key ];
}

/*
	Writes one of the game's level.finalKillCam_<name>[ key ] values.
*/
setFinalKillcamField( name, key, value )
{
	switch ( name )
	{
		case "delay":
			level.finalKillCam_delay[ key ] = value;
			break;
			
		case "victim":
			level.finalKillCam_victim[ key ] = value;
			break;
			
		case "attacker":
			level.finalKillCam_attacker[ key ] = value;
			break;
			
		case "attackerNum":
			level.finalKillCam_attackerNum[ key ] = value;
			break;
			
		case "killCamEntityIndex":
			level.finalKillCam_killCamEntityIndex[ key ] = value;
			break;
			
		case "killCamEntityStartTime":
			level.finalKillCam_killCamEntityStartTime[ key ] = value;
			break;
			
		case "sWeapon":
			level.finalKillCam_sWeapon[ key ] = value;
			break;
			
		case "deathTimeOffset":
			level.finalKillCam_deathTimeOffset[ key ] = value;
			break;
			
		case "psOffsetTime":
			level.finalKillCam_psOffsetTime[ key ] = value;
			break;
			
		case "timeRecorded":
			level.finalKillCam_timeRecorded[ key ] = value;
			break;
			
		default:
			level.finalKillCam_timeGameEnded[ key ] = value;
			break;
	}
}

/*
	Starts the callbacks.
*/
hook_callbacks()
{
	level waittill( "prematch_over" ); // iw4madmin waits this long for some reason...
	wait 0.05; // so we need to be one frame after it sets up its callbacks.
	level.prevcallbackplayerdamage = level.callbackplayerdamage;
	level.callbackplayerdamage = ::onPlayerDamage;
	
	level.prevcallbackplayerkilled = level.callbackplayerkilled;
	level.callbackplayerkilled = ::onPlayerKilled;
}

/*
	Fixes gamemodes when level starts.
*/
fixGamemodes()
{
	for ( i = 0; i < 19; i++ )
	{
		if ( isdefined( level.bombzones ) && level.gametype == "sd" )
		{
			for ( i = 0; i < level.bombzones.size; i++ )
			{
				level.bombzones[ i ].onuse = ::onUsePlantObjectFix;
			}
			
			break;
		}
		
		if ( isdefined( level.radios ) && level.gametype == "koth" )
		{
			level thread fixKoth();
			
			break;
		}
		
		if ( isdefined( level.bombzones ) && level.gametype == "dd" )
		{
			level thread fixDem();
			
			break;
		}
		
		wait 0.05;
	}
}

/*
	Converts t5 dd to iw4
*/
fixDem()
{
	for ( ;; )
	{
		level.bombaplanted = level.aplanted;
		level.bombbplanted = level.bplanted;
		
		for ( i = 0; i < level.bombzones.size; i++ )
		{
			if ( isdefined( level.bombzones[ i ].trigger.trigger_off ) )
			{
				level.bombzones[ i ].bombexploded = true;
			}
			else
			{
				level.bombzones[ i ].bombexploded = undefined;
			}
		}
		
		wait 0.05;
	}
}

/*
	Fixes the king of the hill headquarters obj
*/
fixKoth()
{
	level.radio = undefined;
	
	for ( ;; )
	{
		wait 0.05;
		
		if ( !isdefined( level.radioobject ) )
		{
			continue;
		}
		
		for ( i = level.radios.size - 1; i >= 0; i-- )
		{
			if ( level.radioobject != level.radios[ i ].gameobject )
			{
				continue;
			}
			
			level.radio = level.radios[ i ];
			break;
		}
		
		while ( isdefined( level.radioobject ) && level.radio.gameobject == level.radioobject )
		{
			wait 0.05;
		}
	}
}

/*
	Loop
*/
auditModels_loop()
{
	s_models = getentarray( "script_model", "classname" );
	
	for ( i = s_models.size - 1; i >= 0; i-- )
	{
		model = s_models[ i ];
		
		if ( !isdefined( model ) )
		{
			continue;
		}
		
		if ( isdefined( model.bot_audit_model ) )
		{
			continue;
		}
		
		if ( model.model == "com_deploy_ballistic_vest_friend_world" )
		{
			model.bot_audit_model = true;
			level.vest_boxes[ level.vest_boxes.size ] = model;
		}
	}
}

/*
	Audits all the important models cause iw5 script is kek
*/
auditModels()
{
	level.vest_boxes = [];
	
	for ( ;; )
	{
		wait 0.05;
		
		level.vest_boxes = array_removeundefined( level.vest_boxes );
		
		auditModels_loop();
	}
}

/*
	Loop
*/
watchRadar_loop()
{
	for ( i = level.players.size - 1; i >= 0; i-- )
	{
		player = level.players[ i ];
		player.bot_isinradar = false;
	}
	
	for ( i = level.players.size - 1; i >= 0; i-- )
	{
		grenade = level.players[ i ].deployedportableradar;
		
		if ( !isdefined( grenade ) )
		{
			continue;
		}
		
		if ( grenade.model != "weapon_radar" )
		{
			continue;
		}
		
		for ( h = level.players.size - 1; h >= 0; h-- )
		{
			player = level.players[ h ];
			
			if ( !isreallyalive( player ) )
			{
				continue;
			}
			
			if ( isdefined( grenade.owner ) && grenade.owner == player )
			{
				continue;
			}
			
			if ( level.teambased && grenade.team == player.team )
			{
				continue;
			}
			
			if ( player _hasperk( "specialty_coldblooded" ) )
			{
				continue;
			}
			
			if ( distancesquared( player.origin, grenade.origin ) > 256 * 256 )
			{
				continue;
			}
			
			player.bot_isinradar = true;
		}
	}
	
	for ( i = level.players.size - 1; i >= 0; i-- )
	{
		if ( !isdefined( level.players[ i ].personalradar ) )
		{
			continue;
		}
		
		if ( !isreallyalive( level.players[ i ] ) )
		{
			continue;
		}
		
		for ( h = level.players.size - 1; h >= 0; h-- )
		{
			player = level.players[ h ];
			
			if ( !isreallyalive( player ) )
			{
				continue;
			}
			
			if ( level.players[ i ] == player )
			{
				continue;
			}
			
			if ( level.teambased && level.players[ i ].team == player.team )
			{
				continue;
			}
			
			if ( player _hasperk( "specialty_coldblooded" ) )
			{
				continue;
			}
			
			if ( distancesquared( player.origin, level.players[ i ].origin ) > 256 * 256 )
			{
				continue;
			}
			
			player.bot_isinradar = true;
		}
	}
	
	if ( isdefined( level.gameflag ) && isdefined( level.gameflag.carrier ) && isdefined( level.gameflag.portable_radar ) )
	{
		for ( h = level.players.size - 1; h >= 0; h-- )
		{
			player = level.players[ h ];
			
			if ( !isreallyalive( player ) )
			{
				continue;
			}
			
			if ( level.teambased && level.gameflag.carrier.team != player.team )
			{
				continue;
			}
			
			if ( player _hasperk( "specialty_coldblooded" ) )
			{
				continue;
			}
			
			if ( distancesquared( player.origin, level.gameflag.carrier.origin ) > 256 * 256 )
			{
				continue;
			}
			
			player.bot_isinradar = true;
		}
	}
}

/*
	Watches radars
*/
watchRadar()
{
	for ( ;; )
	{
		wait 1;
		
		watchRadar_loop();
	}
}

/*
	Loop
*/
watchScrabler_loop()
{
	for ( i = level.players.size - 1; i >= 0; i-- )
	{
		player = level.players[ i ];
		player.bot_isscrambled = false;
	}
	
	for ( i = level.scramblers.size - 1; i >= 0; i-- )
	{
		scrambler = level.scramblers[ i ];
		
		if ( !isdefined( scrambler ) )
		{
			continue;
		}
		
		for ( h = level.players.size - 1; h >= 0; h-- )
		{
			player = level.players[ h ];
			
			if ( !isreallyalive( player ) )
			{
				continue;
			}
			
			if ( isdefined( scrambler.owner ) && scrambler.owner == player )
			{
				continue;
			}
			
			if ( level.teambased && scrambler.team == player.team )
			{
				continue;
			}
			
			if ( player _hasperk( "specialty_spygame" ) )
			{
				continue;
			}
			
			if ( distancesquared( player.origin, scrambler.origin ) > 256 * 256 )
			{
				continue;
			}
			
			player.bot_isscrambled = true;
		}
	}
	
	drones = [];
	
	if ( isdefined( level.remote_uav[ "axis" ] ) )
	{
		drones[ drones.size ] = level.remote_uav[ "axis" ];
	}
	
	if ( isdefined( level.remote_uav[ "allies" ] ) )
	{
		drones[ drones.size ] = level.remote_uav[ "allies" ];
	}
	
	for ( i = drones.size - 1; i >= 0; i-- )
	{
		drone = drones[ i ];
		
		for ( h = level.players.size - 1; h >= 0; h-- )
		{
			player = level.players[ h ];
			
			if ( !isreallyalive( player ) )
			{
				continue;
			}
			
			if ( isdefined( drone.owner ) && drone.owner == player )
			{
				continue;
			}
			
			if ( level.teambased && drone.team == player.team )
			{
				continue;
			}
			
			if ( player _hasperk( "specialty_spygame" ) )
			{
				continue;
			}
			
			if ( distancesquared( player.origin, drone.origin ) > 256 * 256 )
			{
				continue;
			}
			
			player.bot_isscrambled = true;
		}
	}
}

/*
	Watches scrambler
*/
watchScrabler()
{
	for ( ;; )
	{
		wait 1;
		
		watchScrabler_loop();
	}
}

/*
	Loop
*/
addNotifyOnAirdrops_loop()
{
	dropCrates = getentarray( "care_package", "targetname" );
	
	for ( i = dropCrates.size - 1; i >= 0; i-- )
	{
		airdrop = dropCrates[ i ];
		
		if ( isdefined( airdrop.doingphysics ) )
		{
			continue;
		}
		
		airdrop.doingphysics = true;
		airdrop thread doNotifyOnAirdrop();
	}
}

/*
	Adds a notify when the airdrop is dropped
*/
addNotifyOnAirdrops()
{
	for ( ;; )
	{
		wait 1;
		addNotifyOnAirdrops_loop();
	}
}

/*
	Does the notify
*/
doNotifyOnAirdrop()
{
	self endon( "death" );
	self waittill( "physics_finished" );
	
	self.doingphysics = false;
	
	if ( isdefined( self.owner ) )
	{
		self.owner notify( "crate_physics_done" );
	}
	
	self thread onCarepackageCaptured();
}

/*
	Waits to be captured
*/
onCarepackageCaptured()
{
	self endon( "death" );
	
	self waittill( "captured", player );
	
	if ( isdefined( self.owner ) && self.owner is_bot() )
	{
		self.owner BotNotifyBotEvent( "crate_cap", "captured", self, player );
	}
}

/*
	Thread when any player connects. Starts the threads needed.
*/
onPlayerConnect()
{
	for ( ;; )
	{
		level waittill( "connected", player );
		
		player.bot_isscrambled = false;
		player.bot_isinradar = false;
		
		player thread onGrenadeFire();
		player thread onWeaponFired();
		
		player thread connected();
	}
}

/*
	When a bot disconnects.
*/
onDisconnectPlayer()
{
	name = self.name;
	
	self waittill( "disconnect" );
	waittillframeend;
	
	for ( i = 0; i < level.bots.size; i++ )
	{
		bot = level.bots[ i ];
		bot BotNotifyBotEvent( "connection", "disconnected", self, name );
	}
}

/*
	When a bot disconnects.
*/
onDisconnect()
{
	self waittill( "disconnect" );
	
	level.bots = array_remove( level.bots, self );
}

/*
	Called when a player connects.
*/
connected()
{
	self endon( "disconnect" );
	
	for ( i = 0; i < level.bots.size; i++ )
	{
		bot = level.bots[ i ];
		bot BotNotifyBotEvent( "connection", "connected", self, self.name );
	}
	
	self thread onDisconnectPlayer();
	
	if ( !isdefined( self.pers[ "bot_host" ] ) )
	{
		self thread doHostCheck();
	}
	
	if ( !self is_bot() )
	{
		return;
	}
	
	if ( !isdefined( self.pers[ "isBot" ] ) )
	{
		// fast_restart occured...
		self.pers[ "isBot" ] = true;
	}
	
	if ( !isdefined( self.pers[ "isBotWarfare" ] ) )
	{
		self.pers[ "isBotWarfare" ] = true;
		self thread added();
	}
	
	self thread maps\mp\bots\_bot_internal::connected();
	self thread maps\mp\bots\_bot_script::connected();
	
	level.bots[ level.bots.size ] = self;
	self thread onDisconnect();
	self thread watchBotDebugEvent();

	waittillframeend; // wait for waittills to process
	level notify( "bot_connected", self );
}

/*
	DEBUG
*/
watchBotDebugEvent()
{
	self endon( "disconnect" );
	
	for ( ;; )
	{
		self waittill( "bot_event", msg, str, b, c, d, e, f, g );
		
		if ( getdvarint( "bots_main_debug" ) >= 2 )
		{
			big_str = "Bot Warfare debug: " + self.name + ": " + msg;
			
			if ( isdefined( str ) && isstring( str ) )
			{
				big_str += ", " + str;
			}
			
			if ( isdefined( b ) && isstring( b ) )
			{
				big_str += ", " + b;
			}
			
			if ( isdefined( c ) && isstring( c ) )
			{
				big_str += ", " + c;
			}
			
			if ( isdefined( d ) && isstring( d ) )
			{
				big_str += ", " + d;
			}
			
			if ( isdefined( e ) && isstring( e ) )
			{
				big_str += ", " + e;
			}
			
			if ( isdefined( f ) && isstring( f ) )
			{
				big_str += ", " + f;
			}
			
			if ( isdefined( g ) && isstring( g ) )
			{
				big_str += ", " + g;
			}
			
			BotBuiltinPrintConsole( big_str );
		}
		else if ( msg == "debug" && getdvarint( "bots_main_debug" ) )
		{
			BotBuiltinPrintConsole( "Bot Warfare debug: " + self.name + ": " + str );
		}
	}
}

/*
	When a bot gets added into the game.
*/
added()
{
	self endon( "disconnect" );
	
	self thread maps\mp\bots\_bot_internal::added();
	self thread maps\mp\bots\_bot_script::added();
}

/*
	Adds a bot to the game.
*/
add_bot()
{
	bot = addtestclient();
	
	if ( isdefined( bot ) )
	{
		bot.pers[ "isBot" ] = true;
		bot.pers[ "isBotWarfare" ] = true;
		bot thread added();
	}
}

/*
	Loop
*/
diffBots_loop()
{
	var_allies_hard = getdvarint( "bots_skill_allies_hard" );
	var_allies_med = getdvarint( "bots_skill_allies_med" );
	var_axis_hard = getdvarint( "bots_skill_axis_hard" );
	var_axis_med = getdvarint( "bots_skill_axis_med" );
	var_skill = getdvarint( "bots_skill" );
	
	allies_hard = 0;
	allies_med = 0;
	axis_hard = 0;
	axis_med = 0;
	
	if ( var_skill == 8 )
	{
		playercount = level.players.size;
		
		for ( i = 0; i < playercount; i++ )
		{
			player = level.players[ i ];
			
			if ( !isdefined( player.pers[ "team" ] ) )
			{
				continue;
			}
			
			if ( !player is_bot() )
			{
				continue;
			}
			
			if ( player.pers[ "team" ] == "axis" )
			{
				if ( axis_hard < var_axis_hard )
				{
					axis_hard++;
					player.pers[ "bots" ][ "skill" ][ "base" ] = 7;
				}
				else if ( axis_med < var_axis_med )
				{
					axis_med++;
					player.pers[ "bots" ][ "skill" ][ "base" ] = 4;
				}
				else
				{
					player.pers[ "bots" ][ "skill" ][ "base" ] = 1;
				}
			}
			else if ( player.pers[ "team" ] == "allies" )
			{
				if ( allies_hard < var_allies_hard )
				{
					allies_hard++;
					player.pers[ "bots" ][ "skill" ][ "base" ] = 7;
				}
				else if ( allies_med < var_allies_med )
				{
					allies_med++;
					player.pers[ "bots" ][ "skill" ][ "base" ] = 4;
				}
				else
				{
					player.pers[ "bots" ][ "skill" ][ "base" ] = 1;
				}
			}
		}
	}
	else if ( var_skill != 0 && var_skill != 9 )
	{
		playercount = level.players.size;
		
		for ( i = 0; i < playercount; i++ )
		{
			player = level.players[ i ];
			
			if ( !player is_bot() )
			{
				continue;
			}
			
			player.pers[ "bots" ][ "skill" ][ "base" ] = var_skill;
		}
	}
	
	if ( var_skill != 8 && var_skill != 9 )
	{
		dynamicBotsDiff( var_skill );
	}
	
	playercount = level.players.size;
	min_diff = getdvarint( "bots_skill_min" );
	max_diff = getdvarint( "bots_skill_max" );
	
	if ( min_diff > max_diff )
	{
		temp = min_diff;
		min_diff = max_diff;
		max_diff = temp;
	}
	
	for ( i = 0; i < playercount; i++ )
	{
		player = level.players[ i ];
		
		if ( !player is_bot() )
		{
			continue;
		}
		
		player.pers[ "bots" ][ "skill" ][ "base" ] = int( clamp( player.pers[ "bots" ][ "skill" ][ "base" ], min_diff, max_diff ) );
	}
}

/*
	Adjusts the bots' difficulty with the bots_skill_dynamic dvar
*/
dynamicBotsDiff( var_skill )
{
	mode = getdvarint( "bots_skill_dynamic" );
	playercount = level.players.size;
	
	if ( mode != 1 && mode != 2 )
	{
		// turned off, put the bots back to the difficulty they had before
		for ( i = 0; i < playercount; i++ )
		{
			player = level.players[ i ];
			
			if ( !player is_bot() || !isdefined( player.pers[ "bots" ][ "skill" ][ "dynamic_base" ] ) )
			{
				continue;
			}
			
			if ( var_skill == 0 )
			{
				player.pers[ "bots" ][ "skill" ][ "base" ] = player.pers[ "bots" ][ "skill" ][ "dynamic_base" ];
			}
			
			player.pers[ "bots" ][ "skill" ][ "dynamic_base" ] = undefined;
		}
		
		return;
	}
	
	if ( mode == 1 )
	{
		// difficulty from the amount of human players
		humans = 0;
		
		for ( i = 0; i < playercount; i++ )
		{
			if ( !level.players[ i ] is_bot() )
			{
				humans++;
			}
		}
		
		skills = strtok( getdvar( "bots_skill_dynamic_players" ), "," );
		
		if ( !skills.size )
		{
			return;
		}
		
		skill = int( skills[ int( clamp( humans - 1, 0, skills.size - 1 ) ) ] );
		
		for ( i = 0; i < playercount; i++ )
		{
			player = level.players[ i ];
			
			if ( !player is_bot() )
			{
				continue;
			}
			
			if ( !isdefined( player.pers[ "bots" ][ "skill" ][ "dynamic_base" ] ) )
			{
				player.pers[ "bots" ][ "skill" ][ "dynamic_base" ] = player.pers[ "bots" ][ "skill" ][ "base" ];
			}
			
			player.pers[ "bots" ][ "skill" ][ "base" ] = skill;
		}
		
		return;
	}
	
	// difficulty adapts to each bot's kdr, the worse the bot is doing the harder it gets
	for ( i = 0; i < playercount; i++ )
	{
		player = level.players[ i ];
		
		if ( !player is_bot() )
		{
			continue;
		}
		
		if ( !isdefined( player.pers[ "bots" ][ "skill" ][ "dynamic_base" ] ) )
		{
			player.pers[ "bots" ][ "skill" ][ "dynamic_base" ] = player.pers[ "bots" ][ "skill" ][ "base" ];
		}
		
		base = player.pers[ "bots" ][ "skill" ][ "dynamic_base" ];
		
		if ( var_skill != 0 )
		{
			base = var_skill;
		}
		
		kills = 0;
		deaths = 0;
		
		if ( isdefined( player.pers[ "kills" ] ) )
		{
			kills = player.pers[ "kills" ];
		}
		
		if ( isdefined( player.pers[ "deaths" ] ) )
		{
			deaths = player.pers[ "deaths" ];
		}
		
		adjust = 0;
		
		// wait for a few kills/deaths before adapting
		if ( kills + deaths >= 3 )
		{
			kdr = ( kills * 1.0 ) / max( deaths, 1 );
			
			if ( kdr >= 1 )
			{
				adjust = 0 - int( min( ( kdr - 1 ) * 2, 3 ) );
			}
			else
			{
				adjust = int( min( ( 1 - kdr ) * 4, 3 ) );
			}
		}
		
		player.pers[ "bots" ][ "skill" ][ "base" ] = base + adjust;
	}
}

/*
	A server thread for monitoring all bot's difficulty levels for custom server settings.
*/
diffBots()
{
	for ( ;; )
	{
		wait 1.5;
		
		diffBots_loop();
	}
}

/*
	Loop
*/
teamBots_loop()
{
	teamAmount = getdvarint( "bots_team_amount" );
	toTeam = getdvar( "bots_team" );
	
	alliesbots = 0;
	alliesplayers = 0;
	axisbots = 0;
	axisplayers = 0;
	
	playercount = level.players.size;
	
	for ( i = 0; i < playercount; i++ )
	{
		player = level.players[ i ];
		
		if ( !isdefined( player.pers[ "team" ] ) )
		{
			continue;
		}
		
		if ( player is_bot() )
		{
			if ( player.pers[ "team" ] == "allies" )
			{
				alliesbots++;
			}
			else if ( player.pers[ "team" ] == "axis" )
			{
				axisbots++;
			}
		}
		else
		{
			if ( player.pers[ "team" ] == "allies" )
			{
				alliesplayers++;
			}
			else if ( player.pers[ "team" ] == "axis" )
			{
				axisplayers++;
			}
		}
	}
	
	allies = alliesbots;
	axis = axisbots;
	
	if ( !getdvarint( "bots_team_mode" ) )
	{
		allies += alliesplayers;
		axis += axisplayers;
	}
	
	if ( toTeam != "custom" )
	{
		if ( getdvarint( "bots_team_force" ) )
		{
			if ( toTeam == "autoassign" )
			{
				if ( abs( axis - allies ) > 1 )
				{
					toTeam = "axis";
					
					if ( axis > allies )
					{
						toTeam = "allies";
					}
				}
			}
			
			if ( toTeam != "autoassign" )
			{
				playercount = level.players.size;
				
				for ( i = 0; i < playercount; i++ )
				{
					player = level.players[ i ];
					
					if ( !isdefined( player.pers[ "team" ] ) )
					{
						continue;
					}
					
					if ( !player is_bot() )
					{
						continue;
					}
					
					if ( player.pers[ "team" ] == toTeam )
					{
						continue;
					}
					
					if ( toTeam == "allies" )
					{
						player thread [[ level.allies ]]();
					}
					else if ( toTeam == "axis" )
					{
						player thread [[ level.axis ]]();
					}
					else
					{
						player thread [[ level.spectator ]]();
					}
					
					break;
				}
			}
		}
	}
	else
	{
		playercount = level.players.size;
		
		for ( i = 0; i < playercount; i++ )
		{
			player = level.players[ i ];
			
			if ( !isdefined( player.pers[ "team" ] ) )
			{
				continue;
			}
			
			if ( !player is_bot() )
			{
				continue;
			}
			
			if ( player.pers[ "team" ] == "axis" )
			{
				if ( axis > teamAmount )
				{
					player thread [[ level.allies ]]();
					break;
				}
			}
			else
			{
				if ( axis < teamAmount )
				{
					player thread [[ level.axis ]]();
					break;
				}
				else if ( player.pers[ "team" ] != "allies" )
				{
					player thread [[ level.allies ]]();
					break;
				}
			}
		}
	}
}

/*
	A server thread for monitoring all bot's teams for custom server settings.
*/
teamBots()
{
	for ( ;; )
	{
		wait 1.5;
		teamBots_loop();
	}
}

/*
	Loops
*/
addBots_loop()
{
	botsToAdd = getdvarint( "bots_manage_add" );
	
	if ( botsToAdd > 0 )
	{
		setdvar( "bots_manage_add", 0 );
		
		if ( botsToAdd > 64 )
		{
			botsToAdd = 64;
		}
		
		for ( ; botsToAdd > 0; botsToAdd-- )
		{
			level add_bot();
			wait 0.25;
		}
	}
	
	fillMode = getdvarint( "bots_manage_fill_mode" );
	
	if ( fillMode == 2 || fillMode == 3 || fillMode == 5 )
	{
		setdvar( "bots_manage_fill", getGoodMapAmount() );
	}
	
	fillAmount = getdvarint( "bots_manage_fill" );
	
	players = 0;
	bots = 0;
	spec = 0;
	axisplayers = 0;
	alliesplayers = 0;
	
	playercount = level.players.size;
	
	for ( i = 0; i < playercount; i++ )
	{
		player = level.players[ i ];
		
		if ( player is_bot() )
		{
			bots++;
		}
		else if ( !isdefined( player.pers[ "team" ] ) || ( player.pers[ "team" ] != "axis" && player.pers[ "team" ] != "allies" ) )
		{
			spec++;
		}
		else
		{
			players++;
			
			if ( player.pers[ "team" ] == "axis" )
			{
				axisplayers++;
			}
			else if ( player.pers[ "team" ] == "allies" )
			{
				alliesplayers++;
			}
		}
	}
	
	if ( getdvarint( "bots_manage_fill_spec" ) )
	{
		players += spec;
	}
	
	if ( !randomint( 999 ) )
	{
		setdvar( "testclients_doreload", true );
		wait 0.1;
		setdvar( "testclients_doreload", false );
		doExtraCheck();
	}
	
	amount = bots;
	
	if ( fillMode == 0 || fillMode == 2 )
	{
		amount += players;
	}
	
	// use bots as balance
	if ( fillMode == 4 || fillMode == 5 )
	{
		diffPlayers = abs( alliesplayers - axisplayers );
		amount = fillAmount - ( diffPlayers - bots );
		
		if ( players + diffPlayers < fillAmount )
		{
			amount = players + bots;
		}
	}
	
	if ( players <= 0 && getdvarint( "bots_manage_fill_watchplayers" ) )
	{
		amount = fillAmount + bots;
	}
	
	if ( amount < fillAmount )
	{
		setdvar( "bots_manage_add", fillAmount - amount );
	}
	else if ( amount > fillAmount && getdvarint( "bots_manage_fill_kick" ) )
	{
		botsToKick = amount - fillAmount;
		
		if ( botsToKick > 64 )
		{
			botsToKick = 64;
		}
		
		for ( i = 0; i < botsToKick; i++ )
		{
			tempBot = getBotToKick();
			
			if ( isdefined( tempBot ) )
			{
				kick( tempBot getentitynumber(), "EXE_PLAYERKICKED" );
				
				wait 0.25;
			}
		}
	}
}

/*
	A server thread for monitoring all bot's in game. Will add and kick bots according to server settings.
*/
addBots()
{
	level endon( "game_ended" );
	
	bot_wait_for_host();
	
	for ( ;; )
	{
		wait 1.5;
		
		addBots_loop();
	}
}

/*
	A thread for ALL players, will monitor and grenades thrown.
*/
onGrenadeFire()
{
	self endon( "disconnect" );
	
	for ( ;; )
	{
		self waittill ( "grenade_fire", grenade, weaponName );
		
		if ( !isdefined( grenade ) )
		{
			continue;
		}
		
		grenade.name = weaponName;
		
		if ( weaponName == "smoke_grenade_mp" )
		{
			grenade thread AddToSmokeList();
		}
		else if ( issubstr( weaponName, "frag_" ) )
		{
			grenade thread AddToFragList( self );
		}
	}
}

/*
	Adds a frag grenade to the list of all frags
*/
AddToFragList( who )
{
	grenade = spawnstruct();
	grenade.origin = self getorigin();
	grenade.velocity = ( 0, 0, 0 );
	grenade.grenade = self;
	grenade.owner = who;
	grenade.team = who.team;
	grenade.throwback = undefined;
	
	grenade thread thinkFrag();
	
	level.bots_fraglist ListAdd( grenade );
}

/*
	Watches while the frag exists
*/
thinkFrag()
{
	while ( isdefined( self.grenade ) )
	{
		nowOrigin = self.grenade getorigin();
		self.velocity = ( nowOrigin - self.origin ) * 20;
		self.origin = nowOrigin;
		
		wait 0.05;
	}
	
	level.bots_fraglist ListRemove( self );
}

/*
	Adds a smoke grenade to the list of smokes in the game. Used to prevent bots from seeing through smoke.
*/
AddToSmokeList()
{
	grenade = spawnstruct();
	grenade.origin = self getorigin();
	grenade.state = "moving";
	grenade.grenade = self;
	
	grenade thread thinkSmoke();
	
	level.bots_smokelist ListAdd( grenade );
}

/*
	The smoke grenade logic.
*/
thinkSmoke()
{
	while ( isdefined( self.grenade ) )
	{
		self.origin = self.grenade getorigin();
		self.state = "moving";
		wait 0.05;
	}
	
	self.state = "smoking";
	wait 11.5;
	
	level.bots_smokelist ListRemove( self );
}

/*
	A thread for ALL players when they fire.
*/
onWeaponFired()
{
	self endon( "disconnect" );
	self.bots_firing = false;
	
	for ( ;; )
	{
		self waittill( "weapon_fired" );
		self thread doFiringThread();
	}
}

/*
	Lets bot's know that the player is firing.
*/
doFiringThread()
{
	self endon( "disconnect" );
	self endon( "weapon_fired" );
	self.bots_firing = true;
	wait 1;
	self.bots_firing = false;
}

/*
	When a player chats
*/
onPlayerChat()
{
	for ( ;; )
	{
		level waittill( "say", message, player, is_hidden );
		
		for ( i = 0; i < level.bots.size; i++ )
		{
			bot = level.bots[ i ];
			
			bot BotNotifyBotEvent( "chat", "chat", message, player, is_hidden );
		}
	}
}

/*
	Monitors turret usage
*/
turret_monitoruse_watcher()
{
	self endon( "death" );
	
	for ( ;; )
	{
		self waittill ( "trigger", player );
		
		self monitor_player_turret( player );
		
		self.owner = undefined;
		
		if ( isdefined( player ) )
		{
			player.turret = undefined;
		}
	}
}

/*
	While player uses turret
*/
monitor_player_turret( player )
{
	player endon( "death" );
	player endon( "disconnect" );
	
	player.turret = self;
	self.owner = player;
	
	self waittill( "turret_deactivate" );
}
