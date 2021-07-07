// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

isSwitchingTeams()
{
    if ( isdefined( self.switching_teams ) )
        return 1;

    return 0;
}

isTeamSwitchBalanced()
{
    var_0 = maps\mp\gametypes\_teams::CountPlayers();
    var_0[self.leaving_team]--;
    var_0[self.joining_team]++;
    return var_0[self.joining_team] - var_0[self.leaving_team] < 2;
}

isFriendlyFire( var_0, var_1 )
{
    if ( !level.teamBased )
        return 0;

    if ( !isdefined( var_1 ) )
        return 0;

    if ( !isplayer( var_1 ) && !isdefined( var_1.team ) )
        return 0;

    if ( var_0.team != var_1.team )
        return 0;

    if ( var_0 == var_1 )
        return 0;

    return 1;
}

killedSelf( var_0 )
{
    if ( !isplayer( var_0 ) )
        return 0;

    if ( var_0 != self )
        return 0;

    return 1;
}

isHeadShot( var_0, var_1, var_2, var_3 )
{
    if ( isdefined( var_3 ) )
    {
        if ( var_3.code_classname == "script_vehicle" && isdefined( var_3.owner ) )
            return 0;

        if ( var_3.code_classname == "misc_turret" && isdefined( var_3.owner ) )
            return 0;

        if ( var_3.code_classname == "script_model" && isdefined( var_3.owner ) )
            return 0;
    }

    return ( var_1 == "head" || var_1 == "helmet" ) && var_2 != "MOD_MELEE" && var_2 != "MOD_IMPACT" && !maps\mp\_utility::isEnvironmentWeapon( var_0 );
}

handleTeamChangeDeath()
{
    if ( !level.teamBased )
        return;

    if ( self.joining_team == "spectator" || !isTeamSwitchBalanced() )
    {
        self thread [[ level.onXPEvent ]]( "suicide" );
        maps\mp\_utility::incPersStat( "suicides", 1 );
        self.suicides = maps\mp\_utility::getPersStat( "suicides" );
    }
}

handleWorldDeath( var_0, var_1, var_2, var_3 )
{
    if ( !isdefined( var_0 ) )
        return;

    if ( !isdefined( var_0.team ) )
    {
        handleSuicideDeath( var_2, var_3 );
        return;
    }

    if ( level.teamBased && var_0.team != self.team || !level.teamBased )
    {
        if ( isdefined( level.onNormalDeath ) && isplayer( var_0 ) && var_0.team != "spectator" )
            [[ level.onNormalDeath ]]( self, var_0, var_1 );
    }
}

handleSuicideDeath( var_0, var_1 )
{
    self setcarddisplayslot( self, 7 );
    self openmenu( "killedby_card_display" );
    self thread [[ level.onXPEvent ]]( "suicide" );
    maps\mp\_utility::incPersStat( "suicides", 1 );
    self.suicides = maps\mp\_utility::getPersStat( "suicides" );

    if ( !maps\mp\_utility::matchMakingGame() )
        maps\mp\_utility::incPlayerStat( "suicides", 1 );

    var_2 = maps\mp\gametypes\_tweakables::getTweakableValue( "game", "suicidepointloss" );
    maps\mp\gametypes\_gamescore::_getPlayerScore( self, maps\mp\gametypes\_gamescore::_setPlayerScore( self ) - var_2 );

    if ( var_0 == "MOD_SUICIDE" && var_1 == "none" && isdefined( self.throwingGrenade ) )
        self.lastGrenadeSuicideTime = gettime();

    if ( isdefined( self.friendlydamage ) )
        self iprintlnbold( &"MP_FRIENDLY_FIRE_WILL_NOT" );
}

handleFriendlyFireDeath( var_0 )
{
    var_0 setcarddisplayslot( self, 8 );
    var_0 openmenu( "youkilled_card_display" );
    self setcarddisplayslot( var_0, 7 );
    self openmenu( "killedby_card_display" );
    var_0 thread [[ level.onXPEvent ]]( "teamkill" );
    var_0.pers["teamkills"] = var_0.pers["teamkills"] + 1.0;
    var_0.teamkillsThisRound++;

    if ( maps\mp\gametypes\_tweakables::getTweakableValue( "team", "teamkillpointloss" ) )
    {
        var_1 = maps\mp\gametypes\_rank::getScoreInfoValue( "kill" );
        maps\mp\gametypes\_gamescore::_getPlayerScore( var_0, maps\mp\gametypes\_gamescore::_setPlayerScore( var_0 ) - var_1 );
    }

    if ( level.maxAllowedTeamKills < 0 )
        return;

    if ( level.inGracePeriod )
    {
        var_2 = 1;
        var_0.pers["teamkills"] = var_0.pers["teamkills"] + level.maxAllowedTeamKills;
    }
    else if ( var_0.pers["teamkills"] > 1 && maps\mp\_utility::getTimePassed() < level.gracePeriod * 1000 + 8000 + var_0.pers["teamkills"] * 1000 )
    {
        var_2 = 1;
        var_0.pers["teamkills"] = var_0.pers["teamkills"] + level.maxAllowedTeamKills;
    }
    else
        var_2 = var_0 maps\mp\gametypes\_playerlogic::TeamKillDelay();

    if ( var_2 > 0 )
    {
        var_0.pers["teamKillPunish"] = 1;
        var_0 maps\mp\_utility::_suicide();
    }
}

handleNormalDeath( var_0, var_1, var_2, var_3, var_4 )
{
    var_1 thread maps\mp\_events::killedPlayer( var_0, self, var_3, var_4 );
    var_1 setcarddisplayslot( self, 8 );
    var_1 openmenu( "youkilled_card_display" );
    self setcarddisplayslot( var_1, 7 );
    self openmenu( "killedby_card_display" );

    if ( var_4 == "MOD_HEAD_SHOT" )
    {
        var_1 maps\mp\_utility::incPersStat( "headshots", 1 );
        var_1.headshots = var_1 maps\mp\_utility::getPersStat( "headshots" );
        var_1 maps\mp\_utility::incPlayerStat( "headshots", 1 );

        if ( isdefined( var_1.laststand ) )
            var_5 = maps\mp\gametypes\_rank::getScoreInfoValue( "kill" ) * 2;
        else
            var_5 = undefined;

        var_1 playlocalsound( "bullet_impact_headshot_2" );
    }
    else if ( isdefined( var_1.laststand ) )
        var_5 = maps\mp\gametypes\_rank::getScoreInfoValue( "kill" ) * 2;
    else
        var_5 = undefined;

    var_1 thread maps\mp\gametypes\_rank::giveRankXP( "kill", var_5, var_3, var_4 );
    var_1 maps\mp\_utility::incPersStat( "kills", 1 );
    var_1.kills = var_1 maps\mp\_utility::getPersStat( "kills" );
    var_1 maps\mp\_utility::updatePersRatio( "kdRatio", "kills", "deaths" );
    var_1 maps\mp\gametypes\_persistence::statSetChild( "round", "kills", var_1.kills );
    var_1 maps\mp\_utility::incPlayerStat( "kills", 1 );

    if ( isFlankKill( self, var_1 ) )
    {
        var_1 maps\mp\_utility::incPlayerStat( "flankkills", 1 );
        maps\mp\_utility::incPlayerStat( "flankdeaths", 1 );
    }

    var_6 = var_1.pers["cur_kill_streak"];
    self.pers["copyCatLoadout"] = undefined;

    if ( maps\mp\_utility::_hasPerk( "specialty_copycat" ) )
        self.pers["copyCatLoadout"] = var_1 maps\mp\gametypes\_class::cloneLoadout();

    if ( isalive( var_1 ) || var_1.streakType == "support" )
    {
        if ( var_1 maps\mp\_utility::killShouldAddToKillstreak( var_3 ) )
        {
            var_1 thread maps\mp\killstreaks\_killstreaks::giveAdrenaline( "kill" );
            var_1.pers["cur_kill_streak"]++;

            if ( !maps\mp\_utility::isKillstreakWeapon( var_3 ) )
                var_1.pers["cur_kill_streak_for_nuke"]++;

            var_7 = 25;

            if ( var_1 maps\mp\_utility::_hasPerk( "specialty_hardline" ) )
                var_7--;

            if ( !maps\mp\_utility::isKillstreakWeapon( var_3 ) && var_1.pers["cur_kill_streak_for_nuke"] == var_7 )
            {
                var_1 thread maps\mp\killstreaks\_killstreaks::giveKillstreak( "nuke", 0, 1, var_1, 1 );
                var_1 thread maps\mp\gametypes\_hud_message::killstreakSplashNotify( "nuke", var_7 );
            }
        }

        var_1 maps\mp\_utility::setPlayerStatIfGreater( "killstreak", var_1.pers["cur_kill_streak"] );

        if ( var_1.pers["cur_kill_streak"] > var_1 maps\mp\_utility::getPersStat( "longestStreak" ) )
            var_1 maps\mp\_utility::setPersStat( "longestStreak", var_1.pers["cur_kill_streak"] );
    }

    var_1.pers["cur_death_streak"] = 0;

    if ( var_1.pers["cur_kill_streak"] > var_1 maps\mp\gametypes\_persistence::statGetChild( "round", "killStreak" ) )
        var_1 maps\mp\gametypes\_persistence::statSetChild( "round", "killStreak", var_1.pers["cur_kill_streak"] );

    if ( var_1.pers["cur_kill_streak"] > var_1.kill_streak )
    {
        var_1 maps\mp\gametypes\_persistence::statSet( "killStreak", var_1.pers["cur_kill_streak"] );
        var_1.kill_streak = var_1.pers["cur_kill_streak"];
    }

    maps\mp\gametypes\_gamescore::givePlayerScore( "kill", var_1, self );
    maps\mp\_skill::processKill( var_1, self );
    var_8 = maps\mp\gametypes\_tweakables::getTweakableValue( "game", "deathpointloss" );
    maps\mp\gametypes\_gamescore::_getPlayerScore( self, maps\mp\gametypes\_gamescore::_setPlayerScore( self ) - var_8 );

    if ( isdefined( level.ac130player ) && level.ac130player == var_1 )
        level notify( "ai_killed",  self  );

    level notify( "player_got_killstreak_" + var_1.pers["cur_kill_streak"],  var_1  );
    var_1 notify( "got_killstreak",  var_1.pers["cur_kill_streak"]  );
    var_1 notify( "killed_enemy" );

    if ( isdefined( self.UAVRemoteMarkedBy ) )
    {
        if ( self.UAVRemoteMarkedBy != var_1 )
            self.UAVRemoteMarkedBy thread maps\mp\killstreaks\_remoteuav::remoteUAV_processTaggedAssist( self );

        self.UAVRemoteMarkedBy = undefined;
    }

    if ( isdefined( level.onNormalDeath ) && var_1.pers["team"] != "spectator" )
        [[ level.onNormalDeath ]]( self, var_1, var_0 );

    if ( !level.teamBased )
    {
        self.attackers = [];
        return;
    }

    level thread maps\mp\gametypes\_battlechatter_mp::sayLocalSoundDelayed( var_1, "kill", 0.75 );

    if ( isdefined( self.lastAttackedShieldPlayer ) && isdefined( self.lastAttackedShieldTime ) && self.lastAttackedShieldPlayer != var_1 )
    {
        if ( gettime() - self.lastAttackedShieldTime < 2500 )
        {
            self.lastAttackedShieldPlayer thread maps\mp\gametypes\_gamescore::processShieldAssist( self );

            if ( self.lastAttackedShieldPlayer maps\mp\_utility::_hasPerk( "specialty_assists" ) )
            {
                self.lastAttackedShieldPlayer.pers["assistsToKill"]++;

                if ( !( self.lastAttackedShieldPlayer.pers["assistsToKill"] % 2 ) )
                {
                    self.lastAttackedShieldPlayer maps\mp\gametypes\_missions::processChallenge( "ch_hardlineassists" );
                    self.lastAttackedShieldPlayer maps\mp\killstreaks\_killstreaks::giveAdrenaline( "kill" );
                    self.lastAttackedShieldPlayer.pers["cur_kill_streak"]++;
                }
            }
            else
                self.lastAttackedShieldPlayer.pers["assistsToKill"] = 0;
        }
        else if ( isalive( self.lastAttackedShieldPlayer ) && gettime() - self.lastAttackedShieldTime < 5000 )
        {
            var_9 = vectornormalize( anglestoforward( self.angles ) );
            var_10 = vectornormalize( self.lastAttackedShieldPlayer.origin - self.origin );

            if ( vectordot( var_10, var_9 ) > 0.925 )
            {
                self.lastAttackedShieldPlayer thread maps\mp\gametypes\_gamescore::processShieldAssist( self );

                if ( self.lastAttackedShieldPlayer maps\mp\_utility::_hasPerk( "specialty_assists" ) )
                {
                    self.lastAttackedShieldPlayer.pers["assistsToKill"]++;

                    if ( !( self.lastAttackedShieldPlayer.pers["assistsToKill"] % 2 ) )
                    {
                        self.lastAttackedShieldPlayer maps\mp\gametypes\_missions::processChallenge( "ch_hardlineassists" );
                        self.lastAttackedShieldPlayer maps\mp\killstreaks\_killstreaks::giveAdrenaline( "kill" );
                        self.lastAttackedShieldPlayer.pers["cur_kill_streak"]++;
                    }
                }
                else
                    self.lastAttackedShieldPlayer.pers["assistsToKill"] = 0;
            }
        }
    }

    if ( isdefined( self.attackers ) )
    {
        foreach ( var_12 in self.attackers )
        {
            if ( !isdefined( var_12 ) )
                continue;

            if ( var_12 == var_1 )
                continue;

            if ( self == var_12 )
                continue;

            var_12 thread maps\mp\gametypes\_gamescore::processAssist( self );

            if ( var_12 maps\mp\_utility::_hasPerk( "specialty_assists" ) )
            {
                var_12.pers["assistsToKill"]++;

                if ( !( var_12.pers["assistsToKill"] % 2 ) )
                {
                    var_12 maps\mp\gametypes\_missions::processChallenge( "ch_hardlineassists" );
                    var_12 maps\mp\killstreaks\_killstreaks::giveAdrenaline( "kill" );
                    var_12.pers["cur_kill_streak"]++;

                    if ( !maps\mp\_utility::isKillstreakWeapon( var_3 ) )
                        var_12.pers["cur_kill_streak_for_nuke"]++;

                    var_7 = 25;

                    if ( var_12 maps\mp\_utility::_hasPerk( "specialty_hardline" ) )
                        var_7--;

                    if ( !maps\mp\_utility::isKillstreakWeapon( var_3 ) && var_12.pers["cur_kill_streak_for_nuke"] == var_7 )
                    {
                        var_12 thread maps\mp\killstreaks\_killstreaks::giveKillstreak( "nuke", 0, 1, var_12, 1 );
                        var_12 thread maps\mp\gametypes\_hud_message::killstreakSplashNotify( "nuke", var_7 );
                    }
                }

                continue;
            }

            var_12.pers["assistsToKill"] = 0;
        }

        self.attackers = [];
    }
}

isPlayerWeapon( var_0 )
{
    if ( weaponclass( var_0 ) == "non-player" )
        return 0;

    if ( weaponclass( var_0 ) == "turret" )
        return 0;

    if ( weaponinventorytype( var_0 ) == "primary" || weaponinventorytype( var_0 ) == "altmode" )
        return 1;

    return 0;
}

Callback_PlayerKilled( var_0, var_1, var_2, var_3, var_4, var_5, var_6, var_7, var_8 )
{
    PlayerKilled_internal( var_0, var_1, self, var_2, var_3, var_4, var_5, var_6, var_7, var_8, 0 );
}

QueueShieldForRemoval( var_0 )
{
    var_1 = 5;

    if ( !isdefined( level.shieldTrashArray ) )
        level.shieldTrashArray = [];

    if ( level.shieldTrashArray.size >= var_1 )
    {
        var_2 = level.shieldTrashArray.size - 1;
        level.shieldTrashArray[0] delete();

        for ( var_3 = 0; var_3 < var_2; var_3++ )
            level.shieldTrashArray[var_3] = level.shieldTrashArray[var_3 + 1];

        level.shieldTrashArray[var_2] = undefined;
    }

    level.shieldTrashArray[level.shieldTrashArray.size] = var_0;
}

LaunchShield( var_0, var_1 )
{
    var_2 = "weapon_riot_shield_mp";

    if ( !isdefined( self.hasriotshieldhidden ) || self.hasriotshieldhidden == 0 )
        self detachshieldmodel( var_2, "tag_weapon_left" );

    self.hasRiotShield = 0;
    self.hasRiotShieldEquipped = 0;
}

PlayerKilled_internal( var_0, var_1, var_2, var_3, var_4, var_5, var_6, var_7, var_8, var_9, var_10 )
{
    var_2 endon( "spawned" );
    var_2 notify( "killed_player" );

    if ( isdefined( var_1 ) )
        var_1.assistedSuicide = undefined;

    if ( !isdefined( var_2.iDFlags ) )
    {
        if ( var_4 == "MOD_SUICIDE" )
            var_2.iDFlags = 0;
        else if ( var_4 == "MOD_GRENADE" && issubstr( var_5, "frag_grenade" ) && var_3 == 100000 )
            var_2.iDFlags = 0;
        else if ( var_5 == "nuke_mp" )
            var_2.iDFlags = 0;
        else if ( level.friendlyfire >= 2 )
            var_2.iDFlags = 0;
        else
        {

        }
    }

    if ( var_2.hasRiotShieldEquipped )
        var_2 LaunchShield( var_3, var_4 );

    if ( !var_10 )
    {
        if ( isdefined( var_2.endGame ) )
        {
            if ( isdefined( level.nukeDetonated ) )
                self visionsetnakedforplayer( level.nukeVisionSet, 2 );
            else
                self visionsetnakedforplayer( "", 2 );
        }
        else
        {
            if ( isdefined( level.nukeDetonated ) )
                self visionsetnakedforplayer( level.nukeVisionSet, 0 );
            else
                self visionsetnakedforplayer( "", 0 );

            var_2 thermalvisionoff();
        }
    }
    else
    {
        var_2.fauxDead = 1;
        self notify( "death" );
    }

    if ( game["state"] == "postgame" )
        return;

    var_11 = 0;

    if ( !isplayer( var_0 ) && isdefined( var_0.primaryWeapon ) )
        var_12 = var_0.primaryWeapon;
    else if ( isdefined( var_1 ) && isplayer( var_1 ) && var_1 getcurrentprimaryweapon() != "none" )
        var_12 = var_1 getcurrentprimaryweapon();
    else if ( issubstr( var_5, "alt_" ) )
        var_12 = getsubstr( var_5, 4, var_5.size );
    else
        var_12 = undefined;

    if ( isdefined( var_2.useLastStandParams ) || isdefined( var_2.lastStandParams ) && var_4 == "MOD_SUICIDE" )
    {
        var_2 ensureLastStandParamsValidity();
        var_2.useLastStandParams = undefined;
        var_0 = var_2.lastStandParams.eInflictor;
        var_1 = var_2.lastStandParams.attacker;
        var_3 = var_2.lastStandParams.iDamage;
        var_4 = var_2.lastStandParams.sMeansOfDeath;
        var_5 = var_2.lastStandParams.sWeapon;
        var_12 = var_2.lastStandParams.sPrimaryWeapon;
        var_6 = var_2.lastStandParams.vDir;
        var_7 = var_2.lastStandParams.sHitLoc;
        var_11 = ( gettime() - var_2.lastStandParams.lastStandStartTime ) / 1000;
        var_2.lastStandParams = undefined;
    }

    if ( ( !isdefined( var_1 ) || var_1.classname == "trigger_hurt" || var_1.classname == "worldspawn" || var_1 == var_2 ) && isdefined( self.attackers ) )
    {
        var_13 = undefined;

        foreach ( var_15 in self.attackers )
        {
            if ( !isdefined( var_15 ) )
                continue;

            if ( !isdefined( var_2.attackerData[var_15.guid].damage ) )
                continue;

            if ( var_15 == var_2 || level.teamBased && var_15.team == var_2.team )
                continue;

            if ( var_2.attackerData[var_15.guid].lasttimedamaged + 2500 < gettime() && ( var_1 != var_2 && ( isdefined( var_2.laststand ) && var_2.laststand ) ) )
                continue;

            if ( var_2.attackerData[var_15.guid].damage > 1 && !isdefined( var_13 ) )
            {
                var_13 = var_15;
                continue;
            }

            if ( isdefined( var_13 ) && var_2.attackerData[var_15.guid].damage > var_2.attackerData[var_13.guid].damage )
                var_13 = var_15;
        }

        if ( isdefined( var_13 ) )
        {
            var_1 = var_13;
            var_1.assistedSuicide = 1;
            var_5 = var_2.attackerData[var_13.guid].weapon;
            var_6 = var_2.attackerData[var_13.guid].vDir;
            var_7 = var_2.attackerData[var_13.guid].sHitLoc;
            var_8 = var_2.attackerData[var_13.guid].psoffsettime;
            var_4 = var_2.attackerData[var_13.guid].sMeansOfDeath;
            var_3 = var_2.attackerData[var_13.guid].damage;
            var_12 = var_2.attackerData[var_13.guid].sPrimaryWeapon;
            var_0 = var_1;
        }
    }
    else if ( isdefined( var_1 ) )
        var_1.assistedSuicide = undefined;

    if ( isHeadShot( var_5, var_7, var_4, var_1 ) )
        var_4 = "MOD_HEAD_SHOT";
    else if ( var_4 != "MOD_MELEE" && !isdefined( var_2.nuked ) )
        var_2 maps\mp\_utility::playDeathSound();

    var_17 = isFriendlyFire( var_2, var_1 );

    if ( isdefined( var_1 ) )
    {
        if ( var_1.code_classname == "script_vehicle" && isdefined( var_1.owner ) )
            var_1 = var_1.owner;

        if ( var_1.code_classname == "misc_turret" && isdefined( var_1.owner ) )
        {
            if ( isdefined( var_1.vehicle ) )
                var_1.vehicle notify( "killedPlayer",  var_2  );

            var_1 = var_1.owner;
        }

        if ( var_1.code_classname == "script_model" && isdefined( var_1.owner ) )
        {
            var_1 = var_1.owner;

            if ( !isFriendlyFire( var_2, var_1 ) && var_1 != var_2 )
                var_1 notify( "crushed_enemy" );
        }
    }

    var_2 maps\mp\gametypes\_weapons::dropScavengerForDeath( var_1 );
    var_2 maps\mp\gametypes\_weapons::dropWeaponForDeath( var_1 );

    if ( !var_10 )
    {
        var_2.sessionstate = "dead";
        var_2.statusicon = "hud_status_dead";
    }

    var_2 maps\mp\gametypes\_playerlogic::removeFromAliveCount();

    if ( !isdefined( var_2.switching_teams ) )
    {
        var_2 maps\mp\_utility::incPersStat( "deaths", 1 );
        var_2.deaths = var_2 maps\mp\_utility::getPersStat( "deaths" );
        var_2 maps\mp\_utility::updatePersRatio( "kdRatio", "kills", "deaths" );
        var_2 maps\mp\gametypes\_persistence::statSetChild( "round", "deaths", var_2.deaths );
        var_2 maps\mp\_utility::incPlayerStat( "deaths", 1 );
    }

    if ( isdefined( var_1 ) && isplayer( var_1 ) )
        var_1 checkKillSteal( var_2 );

    obituary( var_2, var_1, var_5, var_4 );
    var_18 = 0;
    var_19 = maps\mp\_utility::getNextLifeId();
    var_2 logPrintPlayerDeath( var_19, var_1, var_3, var_4, var_5, var_12, var_7 );
    var_2 maps\mp\_matchdata::logPlayerLife( var_19 );
    var_2 maps\mp\_matchdata::logPlayerDeath( var_19, var_1, var_3, var_4, var_5, var_12, var_7 );

    if ( var_4 == "MOD_MELEE" )
    {
        if ( issubstr( var_5, "riotshield" ) )
        {
            var_1 maps\mp\_utility::incPlayerStat( "shieldkills", 1 );

            if ( !maps\mp\_utility::matchMakingGame() )
                var_2 maps\mp\_utility::incPlayerStat( "shielddeaths", 1 );
        }
        else
            var_1 maps\mp\_utility::incPlayerStat( "knifekills", 1 );
    }

    if ( var_2 isSwitchingTeams() )
        handleTeamChangeDeath();
    else if ( !isplayer( var_1 ) || isplayer( var_1 ) && var_4 == "MOD_FALLING" )
        handleWorldDeath( var_1, var_19, var_4, var_7 );
    else if ( var_1 == var_2 )
        handleSuicideDeath( var_4, var_7 );
    else if ( var_17 )
    {
        if ( !isdefined( var_2.nuked ) )
            handleFriendlyFireDeath( var_1 );
    }
    else
    {
        if ( var_4 == "MOD_GRENADE" && var_0 == var_1 )
            addAttacker( var_2, var_1, var_0, var_5, var_3, ( 0, 0, 0 ), var_6, var_7, var_8, var_4 );

        var_18 = 1;
        handleNormalDeath( var_19, var_1, var_0, var_5, var_4 );
        var_2 thread maps\mp\gametypes\_missions::playerKilled( var_0, var_1, var_3, var_4, var_5, var_12, var_7, var_1.modifiers );
        var_2.pers["cur_death_streak"]++;

        if ( !maps\mp\_utility::getGametypeNumLives() && !maps\mp\_utility::matchMakingGame() )
            var_2 maps\mp\_utility::setPlayerStatIfGreater( "deathstreak", var_2.pers["cur_death_streak"] );

        if ( isplayer( var_1 ) && var_2 maps\mp\_utility::isJuggernaut() )
            var_1 thread maps\mp\_utility::teamPlayerCardSplash( "callout_killed_juggernaut", var_1 );
    }

    var_20 = 0;
    var_21 = undefined;

    if ( isdefined( self.previousPrimary ) )
    {
        var_20 = 1;
        var_21 = self.previousPrimary;
        self.previousPrimary = undefined;
    }

    if ( isplayer( var_1 ) && var_1 != self && ( !level.teamBased || level.teamBased && self.team != var_1.team ) )
    {
        if ( var_20 && isdefined( var_21 ) )
            var_22 = var_21;
        else
            var_22 = self.lastDroppableWeapon;

        thread maps\mp\gametypes\_gamelogic::trackLeaderBoardDeathStats( var_22, var_4 );
        var_1 thread maps\mp\gametypes\_gamelogic::trackAttackerLeaderBoardDeathStats( var_5, var_4 );
    }

    var_2.wasswitchingteamsforonplayerkilled = undefined;

    if ( isdefined( var_2.switching_teams ) )
        var_2.wasswitchingteamsforonplayerkilled = 1;

    var_2 resetPlayerVariables();
    var_2.lastattacker = var_1;
    var_2.lastDeathPos = var_2.origin;
    var_2.deathtime = gettime();
    var_2.wantSafeSpawn = 0;
    var_2.revived = 0;
    var_2.sameShotDamage = 0;

    if ( maps\mp\killstreaks\_killstreaks::streakTypeResetsOnDeath( var_2.streakType ) )
        var_2 maps\mp\killstreaks\_killstreaks::resetAdrenaline();

    if ( var_10 )
    {
        var_18 = 0;
        var_9 = var_2 playerforcedeathanim( var_0, var_4, var_5, var_7, var_6 );
    }

    var_2.body = var_2 cloneplayer( var_9 );

    if ( var_10 )
        var_2 playerhide();

    if ( var_2 isonladder() || var_2 ismantling() || !var_2 isonground() || isdefined( var_2.nuked ) )
        var_2.body startragdoll();

    if ( !isdefined( var_2.switching_teams ) )
        thread maps\mp\gametypes\_deathicons::addDeathIcon( var_2.body, var_2, var_2.team, 5.0 );

    thread delayStartRagdoll( var_2.body, var_7, var_6, var_5, var_0, var_4 );
    var_2 thread [[ level.onPlayerKilled ]]( var_0, var_1, var_3, var_4, var_5, var_6, var_7, var_8, var_9, var_19 );

    if ( isplayer( var_1 ) )
        var_23 = var_1 getentitynumber();
    else
        var_23 = -1;

    var_24 = var_2 getKillcamEntity( var_1, var_0, var_5 );
    var_25 = -1;
    var_26 = 0;

    if ( isdefined( var_24 ) )
    {
        var_25 = var_24 getentitynumber();
        var_26 = var_24.birthtime;

        if ( !isdefined( var_26 ) )
            var_26 = 0;
    }

    if ( var_4 != "MOD_SUICIDE" && !( !isdefined( var_1 ) || var_1.classname == "trigger_hurt" || var_1.classname == "worldspawn" || var_1 == var_2 ) )
        recordFinalKillCam( 5.0, var_2, var_1, var_23, var_25, var_26, var_5, var_11, var_8 );

    var_2 setplayerdata( "killCamHowKilled", 0 );

    switch ( var_4 )
    {
        case "MOD_HEAD_SHOT":
            var_2 setplayerdata( "killCamHowKilled", 1 );
            break;
        default:
            break;
    }

    if ( !var_10 )
    {
        if ( !level.showingFinalKillcam && !level.killcam && var_18 )
        {
            if ( var_2 maps\mp\_utility::_hasPerk( "specialty_copycat" ) && isdefined( var_2.pers["copyCatLoadout"] ) )
            {
                var_2 thread maps\mp\gametypes\_killcam::waitDeathCopyCatButton( var_1 );
                wait 1.0;
            }
        }

        wait 0.25;
        var_2 thread maps\mp\gametypes\_killcam::cancelKillCamOnUse();
        wait 0.25;
        self.respawnTimerStartTime = gettime() + 1000;
        var_27 = maps\mp\gametypes\_playerlogic::TimeUntilSpawn( 1 );

        if ( var_27 < 1 )
            var_27 = 1;

        var_2 thread maps\mp\gametypes\_playerlogic::predictAboutToSpawnPlayerOverTime( var_27 );
        wait 1.0;
        var_2 notify( "death_delay_finished" );
    }

    var_28 = ( gettime() - var_2.deathtime ) / 1000;
    self.respawnTimerStartTime = gettime();

    if ( !( isdefined( var_2.cancelKillcam ) && var_2.cancelKillcam ) && var_18 && level.killcam && game["state"] == "playing" && !var_2 maps\mp\_utility::isUsingRemote() && !level.showingFinalKillcam )
    {
        var_29 = !( maps\mp\_utility::getGametypeNumLives() && !var_2.pers["lives"] );
        var_27 = maps\mp\gametypes\_playerlogic::TimeUntilSpawn( 1 );
        var_30 = var_29 && var_27 <= 0;

        if ( !var_29 )
        {
            var_27 = -1;
            level notify( "player_eliminated",  var_2  );
        }

        var_2 maps\mp\gametypes\_killcam::killcam( var_23, var_25, var_26, var_5, var_28 + var_11, var_8, var_27, maps\mp\gametypes\_gamelogic::timeUntilRoundEnd(), var_1, var_2 );
    }

    if ( game["state"] != "playing" )
    {
        if ( !level.showingFinalKillcam )
        {
            var_2.sessionstate = "dead";
            var_2 maps\mp\_utility::ClearKillcamState();
        }

        return;
    }

    if ( maps\mp\_utility::isValidClass( var_2.class ) )
        var_2 thread maps\mp\gametypes\_playerlogic::spawnClient();
}

checkForceBleedout()
{
    if ( level.dieHardMode != 1 )
        return 0;

    if ( !maps\mp\_utility::getGametypeNumLives() )
        return 0;

    if ( level.livesCount[self.team] > 0 )
        return 0;

    foreach ( var_1 in level.players )
    {
        if ( !isalive( var_1 ) )
            continue;

        if ( var_1.team != self.team )
            continue;

        if ( var_1 == self )
            continue;

        if ( !var_1.inLastStand )
            return 0;
    }

    foreach ( var_1 in level.players )
    {
        if ( !isalive( var_1 ) )
            continue;

        if ( var_1.team != self.team )
            continue;

        if ( var_1.inLastStand && var_1 != self )
            var_1 lastStandBleedOut( 0 );
    }

    return 1;
}

checkKillSteal( var_0 )
{
    if ( maps\mp\_utility::matchMakingGame() )
        return;

    var_1 = 0;
    var_2 = undefined;

    if ( isdefined( var_0.attackerData ) && var_0.attackerData.size > 1 )
    {
        foreach ( var_4 in var_0.attackerData )
        {
            if ( var_4.damage > var_1 )
            {
                var_1 = var_4.damage;
                var_2 = var_4.attackerEnt;
            }
        }

        if ( isdefined( var_2 ) && var_2 != self )
            maps\mp\_utility::incPlayerStat( "killsteals", 1 );
    }
}

initFinalKillCam()
{
    level.finalKillCam_delay = [];
    level.finalKillCam_victim = [];
    level.finalKillCam_attacker = [];
    level.finalKillCam_attackerNum = [];
    level.finalKillCam_killCamEntityIndex = [];
    level.finalKillCam_killCamEntityStartTime = [];
    level.finalKillCam_sWeapon = [];
    level.finalKillCam_deathTimeOffset = [];
    level.finalKillCam_psOffsetTime = [];
    level.finalKillCam_timeRecorded = [];
    level.finalKillCam_timeGameEnded = [];
    level.finalKillCam_delay["axis"] = undefined;
    level.finalKillCam_victim["axis"] = undefined;
    level.finalKillCam_attacker["axis"] = undefined;
    level.finalKillCam_attackerNum["axis"] = undefined;
    level.finalKillCam_killCamEntityIndex["axis"] = undefined;
    level.finalKillCam_killCamEntityStartTime["axis"] = undefined;
    level.finalKillCam_sWeapon["axis"] = undefined;
    level.finalKillCam_deathTimeOffset["axis"] = undefined;
    level.finalKillCam_psOffsetTime["axis"] = undefined;
    level.finalKillCam_timeRecorded["axis"] = undefined;
    level.finalKillCam_timeGameEnded["axis"] = undefined;
    level.finalKillCam_delay["allies"] = undefined;
    level.finalKillCam_victim["allies"] = undefined;
    level.finalKillCam_attacker["allies"] = undefined;
    level.finalKillCam_attackerNum["allies"] = undefined;
    level.finalKillCam_killCamEntityIndex["allies"] = undefined;
    level.finalKillCam_killCamEntityStartTime["allies"] = undefined;
    level.finalKillCam_sWeapon["allies"] = undefined;
    level.finalKillCam_deathTimeOffset["allies"] = undefined;
    level.finalKillCam_psOffsetTime["allies"] = undefined;
    level.finalKillCam_timeRecorded["allies"] = undefined;
    level.finalKillCam_timeGameEnded["allies"] = undefined;
    level.finalKillCam_delay["none"] = undefined;
    level.finalKillCam_victim["none"] = undefined;
    level.finalKillCam_attacker["none"] = undefined;
    level.finalKillCam_attackerNum["none"] = undefined;
    level.finalKillCam_killCamEntityIndex["none"] = undefined;
    level.finalKillCam_killCamEntityStartTime["none"] = undefined;
    level.finalKillCam_sWeapon["none"] = undefined;
    level.finalKillCam_deathTimeOffset["none"] = undefined;
    level.finalKillCam_psOffsetTime["none"] = undefined;
    level.finalKillCam_timeRecorded["none"] = undefined;
    level.finalKillCam_timeGameEnded["none"] = undefined;
    level.finalKillCam_winner = undefined;
}

recordFinalKillCam( var_0, var_1, var_2, var_3, var_4, var_5, var_6, var_7, var_8 )
{
    if ( level.teamBased && isdefined( var_2.team ) )
    {
        level.finalKillCam_delay[var_2.team] = var_0;
        level.finalKillCam_victim[var_2.team] = var_1;
        level.finalKillCam_attacker[var_2.team] = var_2;
        level.finalKillCam_attackerNum[var_2.team] = var_3;
        level.finalKillCam_killCamEntityIndex[var_2.team] = var_4;
        level.finalKillCam_killCamEntityStartTime[var_2.team] = var_5;
        level.finalKillCam_sWeapon[var_2.team] = var_6;
        level.finalKillCam_deathTimeOffset[var_2.team] = var_7;
        level.finalKillCam_psOffsetTime[var_2.team] = var_8;
        level.finalKillCam_timeRecorded[var_2.team] = maps\mp\_utility::getSecondsPassed();
        level.finalKillCam_timeGameEnded[var_2.team] = maps\mp\_utility::getSecondsPassed();
    }

    level.finalKillCam_delay["none"] = var_0;
    level.finalKillCam_victim["none"] = var_1;
    level.finalKillCam_attacker["none"] = var_2;
    level.finalKillCam_attackerNum["none"] = var_3;
    level.finalKillCam_killCamEntityIndex["none"] = var_4;
    level.finalKillCam_killCamEntityStartTime["none"] = var_5;
    level.finalKillCam_sWeapon["none"] = var_6;
    level.finalKillCam_deathTimeOffset["none"] = var_7;
    level.finalKillCam_psOffsetTime["none"] = var_8;
    level.finalKillCam_timeRecorded["none"] = maps\mp\_utility::getSecondsPassed();
    level.finalKillCam_timeGameEnded["none"] = maps\mp\_utility::getSecondsPassed();
}

eraseFinalKillCam()
{
    level.finalKillCam_delay["axis"] = undefined;
    level.finalKillCam_victim["axis"] = undefined;
    level.finalKillCam_attacker["axis"] = undefined;
    level.finalKillCam_attackerNum["axis"] = undefined;
    level.finalKillCam_killCamEntityIndex["axis"] = undefined;
    level.finalKillCam_killCamEntityStartTime["axis"] = undefined;
    level.finalKillCam_sWeapon["axis"] = undefined;
    level.finalKillCam_deathTimeOffset["axis"] = undefined;
    level.finalKillCam_psOffsetTime["axis"] = undefined;
    level.finalKillCam_timeRecorded["axis"] = undefined;
    level.finalKillCam_timeGameEnded["axis"] = undefined;
    level.finalKillCam_delay["allies"] = undefined;
    level.finalKillCam_victim["allies"] = undefined;
    level.finalKillCam_attacker["allies"] = undefined;
    level.finalKillCam_attackerNum["allies"] = undefined;
    level.finalKillCam_killCamEntityIndex["allies"] = undefined;
    level.finalKillCam_killCamEntityStartTime["allies"] = undefined;
    level.finalKillCam_sWeapon["allies"] = undefined;
    level.finalKillCam_deathTimeOffset["allies"] = undefined;
    level.finalKillCam_psOffsetTime["allies"] = undefined;
    level.finalKillCam_timeRecorded["allies"] = undefined;
    level.finalKillCam_timeGameEnded["allies"] = undefined;
    level.finalKillCam_delay["none"] = undefined;
    level.finalKillCam_victim["none"] = undefined;
    level.finalKillCam_attacker["none"] = undefined;
    level.finalKillCam_attackerNum["none"] = undefined;
    level.finalKillCam_killCamEntityIndex["none"] = undefined;
    level.finalKillCam_killCamEntityStartTime["none"] = undefined;
    level.finalKillCam_sWeapon["none"] = undefined;
    level.finalKillCam_deathTimeOffset["none"] = undefined;
    level.finalKillCam_psOffsetTime["none"] = undefined;
    level.finalKillCam_timeRecorded["none"] = undefined;
    level.finalKillCam_timeGameEnded["none"] = undefined;
    level.finalKillCam_winner = undefined;
}

doFinalKillcam()
{
    level waittill( "round_end_finished" );
    level.showingFinalKillcam = 1;
    var_0 = "none";

    if ( isdefined( level.finalKillCam_winner ) )
        var_0 = level.finalKillCam_winner;

    var_1 = level.finalKillCam_delay[var_0];
    var_2 = level.finalKillCam_victim[var_0];
    var_3 = level.finalKillCam_attacker[var_0];
    var_4 = level.finalKillCam_attackerNum[var_0];
    var_5 = level.finalKillCam_killCamEntityIndex[var_0];
    var_6 = level.finalKillCam_killCamEntityStartTime[var_0];
    var_7 = level.finalKillCam_sWeapon[var_0];
    var_8 = level.finalKillCam_deathTimeOffset[var_0];
    var_9 = level.finalKillCam_psOffsetTime[var_0];
    var_10 = level.finalKillCam_timeRecorded[var_0];
    var_11 = level.finalKillCam_timeGameEnded[var_0];

    if ( !isdefined( var_2 ) || !isdefined( var_3 ) )
    {
        level.showingFinalKillcam = 0;
        level notify( "final_killcam_done" );
        return;
    }

    var_12 = 15;
    var_13 = var_11 - var_10;

    if ( var_13 > var_12 )
    {
        level.showingFinalKillcam = 0;
        level notify( "final_killcam_done" );
        return;
    }

    if ( isdefined( var_3 ) )
    {
        var_3.finalKill = 1;

        if ( level.gameType == "conf" && isdefined( level.finalKillCam_attacker[var_3.team] ) && level.finalKillCam_attacker[var_3.team] == var_3 )
        {
            var_3 maps\mp\gametypes\_missions::processChallenge( "ch_theedge" );

            if ( isdefined( var_3.modifiers["revenge"] ) )
                var_3 maps\mp\gametypes\_missions::processChallenge( "ch_moneyshot" );

            if ( isdefined( var_3.inFinalStand ) && var_3.inFinalStand )
                var_3 maps\mp\gametypes\_missions::processChallenge( "ch_lastresort" );

            if ( isdefined( var_2 ) && isdefined( var_2.explosiveInfo ) && isdefined( var_2.explosiveInfo["stickKill"] ) && var_2.explosiveInfo["stickKill"] )
                var_3 maps\mp\gametypes\_missions::processChallenge( "ch_stickman" );

            if ( isdefined( var_2.attackerData[var_3.guid] ) && isdefined( var_2.attackerData[var_3.guid].sMeansOfDeath ) && isdefined( var_2.attackerData[var_3.guid].weapon ) && issubstr( var_2.attackerData[var_3.guid].sMeansOfDeath, "MOD_MELEE" ) && issubstr( var_2.attackerData[var_3.guid].weapon, "riotshield_mp" ) )
                var_3 maps\mp\gametypes\_missions::processChallenge( "ch_owned" );

            switch ( level.finalKillCam_sWeapon[var_3.team] )
            {
                case "artillery_mp":
                    var_3 maps\mp\gametypes\_missions::processChallenge( "ch_finishingtouch" );
                    break;
                case "stealth_bomb_mp":
                    var_3 maps\mp\gametypes\_missions::processChallenge( "ch_technokiller" );
                    break;
                case "pavelow_minigun_mp":
                    var_3 maps\mp\gametypes\_missions::processChallenge( "ch_transformer" );
                    break;
                case "sentry_minigun_mp":
                    var_3 maps\mp\gametypes\_missions::processChallenge( "ch_absentee" );
                    break;
                case "ac130_105mm_mp":
                case "ac130_40mm_mp":
                case "ac130_25mm_mp":
                    var_3 maps\mp\gametypes\_missions::processChallenge( "ch_deathfromabove" );
                    break;
                case "remotemissile_projectile_mp":
                    var_3 maps\mp\gametypes\_missions::processChallenge( "ch_dronekiller" );
                    break;
                case "cobra_20mm_mp":
                    var_3 maps\mp\gametypes\_missions::processChallenge( "ch_og" );
                    break;
                default:
                    break;
            }
        }
    }

    var_14 = ( gettime() - var_2.deathtime ) / 1000;

    foreach ( var_16 in level.players )
    {
        var_16 closepopupmenu();
        var_16 closeingamemenu();

        if ( isdefined( level.nukeDetonated ) )
            var_16 visionsetnakedforplayer( level.nukeVisionSet, 0 );
        else
            var_16 visionsetnakedforplayer( "", 0 );

        var_16.killcamentitylookat = var_2 getentitynumber();

        if ( ( var_16 != var_2 || !maps\mp\_utility::isRoundBased() || maps\mp\_utility::isLastRound() ) && var_16 maps\mp\_utility::_hasPerk( "specialty_copycat" ) )
            var_16 maps\mp\_utility::_unsetPerk( "specialty_copycat" );

        var_16 thread maps\mp\gametypes\_killcam::killcam( var_4, var_5, var_6, var_7, var_14 + var_8, var_9, 0, 12, var_3, var_2 );
    }

    wait 0.1;

    while ( anyPlayersInKillcam() )
        wait 0.05;

    level notify( "final_killcam_done" );
    level.showingFinalKillcam = 0;
}

anyPlayersInKillcam()
{
    foreach ( var_1 in level.players )
    {
        if ( isdefined( var_1.killcam ) )
            return 1;
    }

    return 0;
}

resetPlayerVariables()
{
    self.killedPlayersCurrent = [];
    self.switching_teams = undefined;
    self.joining_team = undefined;
    self.leaving_team = undefined;
    self.pers["cur_kill_streak"] = 0;
    self.pers["cur_kill_streak_for_nuke"] = 0;
    maps\mp\gametypes\_gameobjects::detachUseModels();
}

getKillcamEntity( var_0, var_1, var_2 )
{
    if ( !isdefined( var_1 ) || var_1 == var_0 )
        return undefined;

    switch ( var_2 )
    {
        case "bouncingbetty_mp":
        case "artillery_mp":
        case "stealth_bomb_mp":
        case "pavelow_minigun_mp":
        case "apache_minigun_mp":
        case "littlebird_guard_minigun_mp":
        case "osprey_minigun_mp":
        case "airdrop_trap_explosive_mp":
        case "bomb_site_mp":
            return var_1.killCamEnt;
        case "sam_projectile_mp":
            if ( isdefined( var_1.samTurret ) && isdefined( var_1.samTurret.killCamEnt ) )
                return var_1.samTurret.killCamEnt;

            break;
        case "ims_projectile_mp":
            if ( isdefined( var_0 ) && isdefined( var_0.imsKillCamEnt ) )
                return var_0.imsKillCamEnt;

            break;
        case "none":
            if ( isdefined( var_1.targetname ) && var_1.targetname == "care_package" )
                return var_1.killCamEnt;

            break;
        case "ac130_105mm_mp":
        case "ac130_40mm_mp":
        case "ac130_25mm_mp":
        case "remotemissile_projectile_mp":
        case "remote_turret_mp":
        case "osprey_player_minigun_mp":
        case "ugv_turret_mp":
            return undefined;
    }

    if ( var_1.classname == "script_origin" || var_1.classname == "script_model" || var_1.classname == "script_brushmodel" )
    {
        if ( isdefined( var_1.killCamEnt ) && !var_0 attackerInRemoteKillstreak() )
            return var_1.killCamEnt;
        else
            return undefined;
    }

    return var_1;
}

attackerInRemoteKillstreak()
{
    if ( !isdefined( self ) )
        return 0;

    if ( isdefined( level.ac130player ) && self == level.ac130player )
        return 1;

    if ( isdefined( level.chopper ) && isdefined( level.chopper.gunner ) && self == level.chopper.gunner )
        return 1;

    if ( isdefined( level.remote_mortar ) && isdefined( level.remote_mortar.owner ) && self == level.remote_mortar.owner )
        return 1;

    if ( isdefined( self.using_remote_turret ) && self.using_remote_turret )
        return 1;

    if ( isdefined( self.using_remote_tank ) && self.using_remote_tank )
        return 1;

    return 0;
}

HitlocDebug( var_0, var_1, var_2, var_3, var_4 )
{
    var_5 = [];
    var_5[0] = 2;
    var_5[1] = 3;
    var_5[2] = 5;
    var_5[3] = 7;

    if ( !getdvarint( "scr_hitloc_debug" ) )
        return;

    if ( !isdefined( var_0.hitlocInited ) )
    {
        for ( var_6 = 0; var_6 < 6; var_6++ )
            var_0 setclientdvar( "ui_hitloc_" + var_6, "" );

        var_0.hitlocInited = 1;
    }

    if ( level.splitscreen || !isplayer( var_0 ) )
        return;

    var_7 = 6;

    if ( !isdefined( var_0.damageInfo ) )
    {
        var_0.damageInfo = [];

        for ( var_6 = 0; var_6 < var_7; var_6++ )
        {
            var_0.damageInfo[var_6] = spawnstruct();
            var_0.damageInfo[var_6].damage = 0;
            var_0.damageInfo[var_6].hitloc = "";
            var_0.damageInfo[var_6].bp = 0;
            var_0.damageInfo[var_6].jugg = 0;
            var_0.damageInfo[var_6].colorIndex = 0;
        }

        var_0.damageInfoColorIndex = 0;
        var_0.damageInfoVictim = undefined;
    }

    for ( var_6 = var_7 - 1; var_6 > 0; var_6-- )
    {
        var_0.damageInfo[var_6].damage = var_0.damageInfo[var_6 - 1].damage;
        var_0.damageInfo[var_6].hitloc = var_0.damageInfo[var_6 - 1].hitloc;
        var_0.damageInfo[var_6].bp = var_0.damageInfo[var_6 - 1].bp;
        var_0.damageInfo[var_6].jugg = var_0.damageInfo[var_6 - 1].jugg;
        var_0.damageInfo[var_6].colorIndex = var_0.damageInfo[var_6 - 1].colorIndex;
    }

    var_0.damageInfo[0].damage = var_2;
    var_0.damageInfo[0].hitloc = var_3;
    var_0.damageInfo[0].bp = var_4 & level.iDFLAGS_PENETRATION;
    var_0.damageInfo[0].jugg = var_1 maps\mp\_utility::isJuggernaut();

    if ( isdefined( var_0.damageInfoVictim ) && var_0.damageInfoVictim != var_1 )
    {
        var_0.damageInfoColorIndex++;

        if ( var_0.damageInfoColorIndex == var_5.size )
            var_0.damageInfoColorIndex = 0;
    }

    var_0.damageInfoVictim = var_1;
    var_0.damageInfo[0].colorIndex = var_0.damageInfoColorIndex;

    for ( var_6 = 0; var_6 < var_7; var_6++ )
    {
        var_8 = "^" + var_5[var_0.damageInfo[var_6].colorIndex];

        if ( var_0.damageInfo[var_6].hitloc != "" )
        {
            var_9 = var_8 + var_0.damageInfo[var_6].hitloc;

            if ( var_0.damageInfo[var_6].bp )
                var_9 += " (BP)";

            if ( var_0.damageInfo[var_6].jugg )
                var_9 += " (Jugg)";

            var_0 setclientdvar( "ui_hitloc_" + var_6, var_9 );
        }

        var_0 setclientdvar( "ui_hitloc_damage_" + var_6, var_8 + var_0.damageInfo[var_6].damage );
    }
}

giveRecentShieldXP()
{
    self endon( "death" );
    self endon( "disconnect" );
    self notify( "giveRecentShieldXP" );
    self endon( "giveRecentShieldXP" );
    self.recentShieldXP++;
    wait 20.0;
    self.recentShieldXP = 0;
}

Callback_PlayerDamage_internal( var_0, var_1, var_2, var_3, var_4, var_5, var_6, var_7, var_8, var_9, var_10 )
{
    if ( !maps\mp\_utility::isReallyAlive( var_2 ) )
        return;

    if ( isdefined( var_1 ) && var_1.classname == "script_origin" && isdefined( var_1.type ) && var_1.type == "soft_landing" )
        return;

    if ( var_6 == "killstreak_emp_mp" )
        return;

    if ( var_6 == "bouncingbetty_mp" && !maps\mp\gametypes\_weapons::mineDamageHeightPassed( var_0, var_2 ) )
        return;

    if ( var_6 == "bouncingbetty_mp" && ( var_2 getstance() == "crouch" || var_2 getstance() == "prone" ) )
        var_3 = int( var_3 / 2 );

    if ( var_6 == "xm25_mp" && var_5 == "MOD_IMPACT" )
        var_3 = 95;

    if ( var_6 == "emp_grenade_mp" && var_5 != "MOD_IMPACT" )
        var_2 notify( "emp_grenaded",  var_1  );

    if ( isdefined( level.hostMigrationTimer ) )
        return;

    if ( var_5 == "MOD_FALLING" )
        var_2 thread emitFallDamage( var_3 );

    if ( var_5 == "MOD_EXPLOSIVE_BULLET" && var_3 != 1 )
    {
        var_3 *= getdvarfloat( "scr_explBulletMod" );
        var_3 = int( var_3 );
    }

    if ( isdefined( var_1 ) && var_1.classname == "worldspawn" )
        var_1 = undefined;

    if ( isdefined( var_1 ) && isdefined( var_1.gunner ) )
        var_1 = var_1.gunner;

    var_11 = isdefined( var_1 ) && !isdefined( var_1.gunner ) && ( var_1.classname == "script_vehicle" || var_1.classname == "misc_turret" || var_1.classname == "script_model" );
    var_12 = level.teamBased && isdefined( var_1 ) && var_2 != var_1 && isdefined( var_1.team ) && ( var_2.pers["team"] == var_1.team || isdefined( var_1.teamchangedthisframe ) );
    var_13 = isdefined( var_1 ) && isdefined( var_0 ) && isdefined( var_2 ) && isplayer( var_1 ) && var_1 == var_0 && var_1 == var_2;

    if ( var_13 )
        return;

    var_14 = 0.0;

    if ( var_4 & level.iDFLAGS_STUN )
    {
        var_14 = 0.0;
        var_3 = 0.0;
    }
    else if ( var_9 == "shield" )
    {
        if ( var_12 && level.friendlyfire == 0 )
            return;

        if ( var_5 == "MOD_PISTOL_BULLET" || var_5 == "MOD_RIFLE_BULLET" || var_5 == "MOD_EXPLOSIVE_BULLET" && !var_12 )
        {
            if ( isplayer( var_1 ) )
            {
                var_1.lastAttackedShieldPlayer = var_2;
                var_1.lastAttackedShieldTime = gettime();
            }

            var_2 notify( "shield_blocked" );

            if ( maps\mp\_utility::isEnvironmentWeapon( var_6 ) )
                var_15 = 25;
            else
                var_15 = maps\mp\perks\_perks::cac_modified_damage( var_2, var_1, var_3, var_5, var_6, var_7, var_8, var_9 );

            var_2.shieldDamage = var_2.shieldDamage + var_15;

            if ( !maps\mp\_utility::isEnvironmentWeapon( var_6 ) || common_scripts\utility::cointoss() )
                var_2.shieldBulletHits++;

            if ( var_2.shieldBulletHits >= level.riotShieldXPBullets )
            {
                if ( self.recentShieldXP > 4 )
                    var_16 = int( 50 / self.recentShieldXP );
                else
                    var_16 = 50;

                var_2 thread maps\mp\gametypes\_rank::giveRankXP( "shield_damage", var_16 );
                var_2 thread giveRecentShieldXP();
                var_2 thread maps\mp\gametypes\_missions::genericChallenge( "shield_damage", var_2.shieldDamage );
                var_2 thread maps\mp\gametypes\_missions::genericChallenge( "shield_bullet_hits", var_2.shieldBulletHits );
                var_2.shieldDamage = 0;
                var_2.shieldBulletHits = 0;
            }
        }

        if ( var_4 & level.iDFLAGS_SHIELD_EXPLOSIVE_IMPACT )
        {
            if ( !var_12 )
                var_2 thread maps\mp\gametypes\_missions::genericChallenge( "shield_explosive_hits", 1 );

            var_9 = "none";

            if ( !( var_4 & level.iDFLAGS_SHIELD_EXPLOSIVE_IMPACT_HUGE ) )
                var_3 *= 0.0;
        }
        else if ( var_4 & level.iDFLAGS_SHIELD_EXPLOSIVE_SPLASH )
        {
            if ( isdefined( var_0 ) && isdefined( var_0.stuckEnemyEntity ) && var_0.stuckEnemyEntity == var_2 )
                var_3 = 151;

            var_2 thread maps\mp\gametypes\_missions::genericChallenge( "shield_explosive_hits", 1 );
            var_9 = "none";
        }
        else
            return;
    }
    else if ( var_5 == "MOD_MELEE" && issubstr( var_6, "riotshield" ) )
    {
        if ( !( var_12 && level.friendlyfire == 0 ) )
        {
            var_14 = 0.0;
            var_2 stunplayer( 0.0 );
        }
    }

    if ( isdefined( var_0 ) && isdefined( var_0.stuckEnemyEntity ) && var_0.stuckEnemyEntity == var_2 )
        var_3 = 151;

    if ( !var_12 )
        var_3 = maps\mp\perks\_perks::cac_modified_damage( var_2, var_1, var_3, var_5, var_6, var_7, var_8, var_9 );

    if ( isdefined( level.modifyPlayerDamage ) )
        var_3 = [[ level.modifyPlayerDamage ]]( var_2, var_1, var_3, var_5, var_6, var_7, var_8, var_9 );

    if ( !var_3 )
        return 0;

    var_2.iDFlags = var_4;
    var_2.iDFlagsTime = gettime();

    if ( game["state"] == "postgame" )
        return;

    if ( var_2.sessionteam == "spectator" )
        return;

    if ( isdefined( var_2.canDoCombat ) && !var_2.canDoCombat )
        return;

    if ( isdefined( var_1 ) && isplayer( var_1 ) && isdefined( var_1.canDoCombat ) && !var_1.canDoCombat )
        return;

    if ( var_11 && var_12 )
    {
        if ( var_5 == "MOD_CRUSH" )
        {
            var_2 maps\mp\_utility::_suicide();
            return;
        }

        if ( !level.friendlyfire )
            return;
    }

    if ( !isdefined( var_8 ) )
        var_4 |= level.iDFLAGS_NO_KNOCKBACK;

    var_17 = 0;

    if ( var_2.health == var_2.maxHealth && ( !isdefined( var_2.laststand ) || !var_2.laststand ) || !isdefined( var_2.attackers ) && !isdefined( var_2.laststand ) )
    {
        var_2.attackers = [];
        var_2.attackerData = [];
    }

    if ( isHeadShot( var_6, var_9, var_5, var_1 ) )
        var_5 = "MOD_HEAD_SHOT";

    if ( maps\mp\gametypes\_tweakables::getTweakableValue( "game", "onlyheadshots" ) )
    {
        if ( var_5 == "MOD_PISTOL_BULLET" || var_5 == "MOD_RIFLE_BULLET" || var_5 == "MOD_EXPLOSIVE_BULLET" )
            return;
        else if ( var_5 == "MOD_HEAD_SHOT" )
        {
            if ( var_2 maps\mp\_utility::isJuggernaut() )
                var_3 = 75;
            else
                var_3 = 150;
        }
    }

    if ( var_6 == "none" && isdefined( var_0 ) )
    {
        if ( isdefined( var_0.destructible_type ) && issubstr( var_0.destructible_type, "vehicle_" ) )
            var_6 = "destructible_car";
    }

    if ( gettime() < var_2.spawnTime + level.killstreakSpawnShield )
    {
        var_18 = int( max( var_2.health / 4, 1 ) );

        if ( var_3 >= var_18 && maps\mp\_utility::isKillstreakWeapon( var_6 ) )
            var_3 = var_18;
    }

    if ( !( var_4 & level.iDFLAGS_NO_PROTECTION ) )
    {
        if ( !level.teamBased && var_11 && isdefined( var_1.owner ) && var_1.owner == var_2 )
        {
            if ( var_5 == "MOD_CRUSH" )
                var_2 maps\mp\_utility::_suicide();

            return;
        }

        if ( ( issubstr( var_5, "MOD_GRENADE" ) || issubstr( var_5, "MOD_EXPLOSIVE" ) || issubstr( var_5, "MOD_PROJECTILE" ) ) && isdefined( var_0 ) && isdefined( var_1 ) )
        {
            if ( var_2 != var_1 && var_0.classname == "grenade" && var_2.lastspawntime + 3500 > gettime() && isdefined( var_2.lastspawnpoint ) && distance( var_0.origin, var_2.lastspawnpoint.origin ) < 250 )
                return;

            var_2.explosiveInfo = [];
            var_2.explosiveInfo["damageTime"] = gettime();
            var_2.explosiveInfo["damageId"] = var_0 getentitynumber();
            var_2.explosiveInfo["returnToSender"] = 0;
            var_2.explosiveInfo["counterKill"] = 0;
            var_2.explosiveInfo["chainKill"] = 0;
            var_2.explosiveInfo["cookedKill"] = 0;
            var_2.explosiveInfo["throwbackKill"] = 0;
            var_2.explosiveInfo["suicideGrenadeKill"] = 0;
            var_2.explosiveInfo["weapon"] = var_6;
            var_19 = issubstr( var_6, "frag_" );

            if ( var_1 != var_2 )
            {
                if ( ( issubstr( var_6, "c4_" ) || issubstr( var_6, "claymore_" ) ) && isdefined( var_1 ) && isdefined( var_0.owner ) )
                {
                    var_2.explosiveInfo["returnToSender"] = var_0.owner == var_2;
                    var_2.explosiveInfo["counterKill"] = isdefined( var_0.wasDamaged );
                    var_2.explosiveInfo["chainKill"] = isdefined( var_0.wasChained );
                    var_2.explosiveInfo["bulletPenetrationKill"] = isdefined( var_0.wasDamagedFromBulletPenetration );
                    var_2.explosiveInfo["cookedKill"] = 0;
                }

                if ( isdefined( var_1.lastGrenadeSuicideTime ) && var_1.lastGrenadeSuicideTime >= gettime() - 50 && var_19 )
                    var_2.explosiveInfo["suicideGrenadeKill"] = 1;
            }

            if ( var_19 )
            {
                var_2.explosiveInfo["cookedKill"] = isdefined( var_0.isCooked );
                var_2.explosiveInfo["throwbackKill"] = isdefined( var_0.threwBack );
            }

            var_2.explosiveInfo["stickKill"] = isdefined( var_0.isStuck ) && var_0.isStuck == "enemy";
            var_2.explosiveInfo["stickFriendlyKill"] = isdefined( var_0.isStuck ) && var_0.isStuck == "friendly";

            if ( isplayer( var_1 ) && var_1 != self )
                maps\mp\gametypes\_gamelogic::setInflictorStat( var_0, var_1, var_6 );
        }

        if ( issubstr( var_5, "MOD_IMPACT" ) && ( var_6 == "m320_mp" || issubstr( var_6, "gl" ) || issubstr( var_6, "gp25" ) || var_6 == "xm25_mp" ) )
        {
            if ( isplayer( var_1 ) && var_1 != self )
                maps\mp\gametypes\_gamelogic::setInflictorStat( var_0, var_1, var_6 );
        }

        if ( isplayer( var_1 ) && isdefined( var_1.pers["participation"] ) )
            var_1.pers["participation"]++;
        else if ( isplayer( var_1 ) )
            var_1.pers["participation"] = 1;

        var_20 = var_2.health / var_2.maxHealth;

        if ( var_12 )
        {
            if ( !maps\mp\_utility::matchMakingGame() && isplayer( var_1 ) )
                var_1 maps\mp\_utility::incPlayerStat( "mostff", 1 );

            if ( level.friendlyfire == 0 || !isplayer( var_1 ) && level.friendlyfire != 1 )
            {
                if ( var_6 == "artillery_mp" || var_6 == "stealth_bomb_mp" )
                    var_2 damageShellshockAndRumble( var_0, var_6, var_5, var_3, var_4, var_1 );

                return;
            }
            else if ( level.friendlyfire == 1 )
            {
                if ( var_3 < 1 )
                    var_3 = 1;

                if ( var_2 maps\mp\_utility::isJuggernaut() )
                    var_3 = maps\mp\perks\_perks::cac_modified_damage( var_2, var_1, var_3, var_5, var_6, var_7, var_8, var_9 );

                var_2.lastDamageWasFromEnemy = 0;
                var_2 finishPlayerDamageWrapper( var_0, var_1, var_3, var_4, var_5, var_6, var_7, var_8, var_9, var_10, var_14 );
            }
            else if ( level.friendlyfire == 2 && maps\mp\_utility::isReallyAlive( var_1 ) )
            {
                var_3 = int( var_3 * 0.5 );

                if ( var_3 < 1 )
                    var_3 = 1;

                var_1.lastDamageWasFromEnemy = 0;
                var_1.friendlydamage = 1;
                var_1 finishPlayerDamageWrapper( var_0, var_1, var_3, var_4, var_5, var_6, var_7, var_8, var_9, var_10, var_14 );
                var_1.friendlydamage = undefined;
            }
            else if ( level.friendlyfire == 3 && maps\mp\_utility::isReallyAlive( var_1 ) )
            {
                var_3 = int( var_3 * 0.5 );

                if ( var_3 < 1 )
                    var_3 = 1;

                var_2.lastDamageWasFromEnemy = 0;
                var_1.lastDamageWasFromEnemy = 0;
                var_2 finishPlayerDamageWrapper( var_0, var_1, var_3, var_4, var_5, var_6, var_7, var_8, var_9, var_10, var_14 );

                if ( maps\mp\_utility::isReallyAlive( var_1 ) )
                {
                    var_1.friendlydamage = 1;
                    var_1 finishPlayerDamageWrapper( var_0, var_1, var_3, var_4, var_5, var_6, var_7, var_8, var_9, var_10, var_14 );
                    var_1.friendlydamage = undefined;
                }
            }

            var_17 = 1;
        }
        else
        {
            if ( var_3 < 1 )
                var_3 = 1;

            if ( isdefined( var_1 ) && isplayer( var_1 ) )
                addAttacker( var_2, var_1, var_0, var_6, var_3, var_7, var_8, var_9, var_10, var_5 );

            if ( var_5 == "MOD_EXPLOSIVE" || var_5 == "MOD_GRENADE_SPLASH" && var_3 < var_2.health )
                var_2 notify( "survived_explosion",  var_1  );

            if ( isdefined( var_1 ) )
                level.lastLegitimateAttacker = var_1;

            if ( isdefined( var_1 ) && isplayer( var_1 ) && isdefined( var_6 ) )
                var_1 thread maps\mp\gametypes\_weapons::checkHit( var_6, var_2 );

            if ( isdefined( var_1 ) && isplayer( var_1 ) && isdefined( var_6 ) && var_1 != var_2 )
            {
                var_1 thread maps\mp\_events::damagedPlayer( self, var_3, var_6 );
                var_2.attackerPosition = var_1.origin;
            }
            else
                var_2.attackerPosition = undefined;

            if ( issubstr( var_5, "MOD_GRENADE" ) && isdefined( var_0.isCooked ) )
                var_2.wasCooked = gettime();
            else
                var_2.wasCooked = undefined;

            var_2.lastDamageWasFromEnemy = isdefined( var_1 ) && var_1 != var_2;

            if ( var_2.lastDamageWasFromEnemy )
                var_1.damagedPlayers[var_2.guid] = gettime();

            var_2 finishPlayerDamageWrapper( var_0, var_1, var_3, var_4, var_5, var_6, var_7, var_8, var_9, var_10, var_14 );

            if ( isdefined( level.ac130player ) && isdefined( var_1 ) && level.ac130player == var_1 )
                level notify( "ai_pain",  var_2  );

            var_2 thread maps\mp\gametypes\_missions::playerDamaged( var_0, var_1, var_3, var_5, var_6, var_9 );
        }

        if ( var_11 && isdefined( var_1.gunner ) )
            var_21 = var_1.gunner;
        else
            var_21 = var_1;

        if ( isdefined( var_21 ) && var_21 != var_2 && var_3 > 0 && ( !isdefined( var_9 ) || var_9 != "shield" ) )
        {
            if ( var_4 & level.iDFLAGS_STUN )
                var_22 = "stun";
            else if ( isexplosivedamagemod( var_5 ) && var_2 maps\mp\_utility::_hasPerk( "_specialty_blastshield" ) )
                var_22 = "hitBodyArmor";
            else if ( var_2 maps\mp\_utility::_hasPerk( "specialty_combathigh" ) )
                var_22 = "hitEndGame";
            else if ( isdefined( var_2.hasLightArmor ) )
                var_22 = "hitLightArmor";
            else if ( var_2 maps\mp\_utility::isJuggernaut() )
                var_22 = "hitJuggernaut";
            else if ( !shouldWeaponFeedback( var_6 ) )
                var_22 = "none";
            else
                var_22 = "standard";

            var_21 thread maps\mp\gametypes\_damagefeedback::updateDamageFeedback( var_22 );
        }

        maps\mp\gametypes\_gamelogic::sethasdonecombat( var_2, 1 );
    }

    if ( isdefined( var_1 ) && var_1 != var_2 && !var_17 )
        level.useStartSpawn = 0;

    if ( var_3 > 0 && isdefined( var_1 ) && !var_2 maps\mp\_utility::isUsingRemote() )
        var_2 thread maps\mp\gametypes\_shellshock::bloodEffect( var_1.origin );

    if ( var_2.sessionstate != "dead" )
    {
        var_23 = var_2 getentitynumber();
        var_24 = var_2.name;
        var_25 = var_2.pers["team"];
        var_26 = var_2.guid;
        var_27 = "";

        if ( isplayer( var_1 ) )
        {
            var_28 = var_1 getentitynumber();
            var_29 = var_1.guid;
            var_30 = var_1.name;
            var_27 = var_1.pers["team"];
        }
        else
        {
            var_28 = -1;
            var_29 = "";
            var_30 = "";
            var_27 = "world";
        }

        logprint( "D;" + var_26 + ";" + var_23 + ";" + var_25 + ";" + var_24 + ";" + var_29 + ";" + var_28 + ";" + var_27 + ";" + var_30 + ";" + var_6 + ";" + var_3 + ";" + var_5 + ";" + var_9 + "\n" );
    }

    HitlocDebug( var_1, var_2, var_3, var_9, var_4 );

    if ( isdefined( var_1 ) && var_1 != var_2 )
    {
        if ( isplayer( var_1 ) )
            var_1 maps\mp\_utility::incPlayerStat( "damagedone", var_3 );

        var_2 maps\mp\_utility::incPlayerStat( "damagetaken", var_3 );
    }
}

shouldWeaponFeedback( var_0 )
{
    switch ( var_0 )
    {
        case "artillery_mp":
        case "stealth_bomb_mp":
            return 0;
    }

    return 1;
}

checkVictimStutter( var_0, var_1, var_2, var_3, var_4 )
{
    if ( var_4 == "MOD_PISTOL_BULLET" || var_4 == "MOD_RIFLE_BULLET" || var_4 == "MOD_HEAD_SHOT" )
    {
        if ( distance( var_0.origin, var_1.origin ) > 256 )
            return;

        var_5 = var_0 getvelocity();

        if ( lengthsquared( var_5 ) < 10 )
            return;

        var_6 = maps\mp\_utility::findIsFacing( var_0, var_1, 25 );

        if ( var_6 )
            var_0 thread stutterStep();
    }
}

stutterStep( var_0 )
{
    self endon( "disconnect" );
    self endon( "death" );
    level endon( "game_ended" );
    self.inStutter = 1;
    self.moveSpeedScaler = 0.05;
    maps\mp\gametypes\_weapons::updateMoveSpeedScale();
    wait 0.5;
    self.moveSpeedScaler = 1;

    if ( maps\mp\_utility::_hasPerk( "specialty_lightweight" ) )
        self.moveSpeedScaler = maps\mp\_utility::lightWeightScalar();

    maps\mp\gametypes\_weapons::updateMoveSpeedScale();
    self.inStutter = 0;
}

addAttacker( var_0, var_1, var_2, var_3, var_4, var_5, var_6, var_7, var_8, var_9 )
{
    if ( !isdefined( var_0.attackerData ) )
        var_0.attackerData = [];

    if ( !isdefined( var_0.attackerData[var_1.guid] ) )
    {
        var_0.attackers[var_1.guid] = var_1;
        var_0.attackerData[var_1.guid] = spawnstruct();
        var_0.attackerData[var_1.guid].damage = 0;
        var_0.attackerData[var_1.guid].attackerEnt = var_1;
        var_0.attackerData[var_1.guid].firstTimeDamaged = gettime();
    }

    if ( maps\mp\gametypes\_weapons::isPrimaryWeapon( var_3 ) && !maps\mp\gametypes\_weapons::isSideArm( var_3 ) )
        var_0.attackerData[var_1.guid].isPrimary = 1;

    var_0.attackerData[var_1.guid].damage = var_0.attackerData[var_1.guid].damage + var_4;
    var_0.attackerData[var_1.guid].weapon = var_3;
    var_0.attackerData[var_1.guid].vPoint = var_5;
    var_0.attackerData[var_1.guid].vDir = var_6;
    var_0.attackerData[var_1.guid].sHitLoc = var_7;
    var_0.attackerData[var_1.guid].psoffsettime = var_8;
    var_0.attackerData[var_1.guid].sMeansOfDeath = var_9;
    var_0.attackerData[var_1.guid].attackerEnt = var_1;
    var_0.attackerData[var_1.guid].lasttimedamaged = gettime();

    if ( isdefined( var_2 ) && !isplayer( var_2 ) && isdefined( var_2.primaryWeapon ) )
        var_0.attackerData[var_1.guid].sPrimaryWeapon = var_2.primaryWeapon;
    else if ( isdefined( var_1 ) && isplayer( var_1 ) && var_1 getcurrentprimaryweapon() != "none" )
        var_0.attackerData[var_1.guid].sPrimaryWeapon = var_1 getcurrentprimaryweapon();
    else
        var_0.attackerData[var_1.guid].sPrimaryWeapon = undefined;
}

resetAttackerList()
{
    self endon( "disconnect" );
    self endon( "death" );
    level endon( "game_ended" );
    wait 1.75;
    self.attackers = [];
    self.attackerData = [];
}

Callback_PlayerDamage( var_0, var_1, var_2, var_3, var_4, var_5, var_6, var_7, var_8, var_9 )
{
    Callback_PlayerDamage_internal( var_0, var_1, self, var_2, var_3, var_4, var_5, var_6, var_7, var_8, var_9 );
}

finishPlayerDamageWrapper( var_0, var_1, var_2, var_3, var_4, var_5, var_6, var_7, var_8, var_9, var_10 )
{
    if ( maps\mp\_utility::isUsingRemote() && var_2 >= self.health && !( var_3 & level.iDFLAGS_STUN ) )
    {
        if ( !isdefined( var_7 ) )
            var_7 = ( 0, 0, 0 );

        if ( !isdefined( var_1 ) && !isdefined( var_0 ) )
        {
            var_1 = self;
            var_0 = var_1;
        }

        PlayerKilled_internal( var_0, var_1, self, var_2, var_4, var_5, var_7, var_8, var_9, 0, 1 );
    }
    else
    {
        if ( !Callback_KillingBlow( var_0, var_1, var_2 - var_2 * var_10, var_3, var_4, var_5, var_6, var_7, var_8, var_9 ) )
            return;

        if ( !isalive( self ) )
            return;

        self finishplayerdamage( var_0, var_1, var_2, var_3, var_4, var_5, var_6, var_7, var_8, var_9, var_10 );
    }

    if ( var_4 == "MOD_EXPLOSIVE_BULLET" )
        self shellshock( "damage_mp", getdvarfloat( "scr_csmode" ) );

    damageShellshockAndRumble( var_0, var_5, var_4, var_2, var_3, var_1 );
}

Callback_PlayerLastStand( var_0, var_1, var_2, var_3, var_4, var_5, var_6, var_7, var_8 )
{
    var_9 = spawnstruct();
    var_9.eInflictor = var_0;
    var_9.attacker = var_1;
    var_9.iDamage = var_2;
    var_9.attackerPosition = var_1.origin;

    if ( var_1 == self )
        var_9.sMeansOfDeath = "MOD_SUICIDE";
    else
        var_9.sMeansOfDeath = var_3;

    var_9.sWeapon = var_4;

    if ( isdefined( var_1 ) && isplayer( var_1 ) && var_1 getcurrentprimaryweapon() != "none" )
        var_9.sPrimaryWeapon = var_1 getcurrentprimaryweapon();
    else
        var_9.sPrimaryWeapon = undefined;

    var_9.vDir = var_5;
    var_9.sHitLoc = var_6;
    var_9.lastStandStartTime = gettime();
    var_10 = mayDoLastStand( var_4, var_3, var_6 );

    if ( isdefined( self.endGame ) )
        var_10 = 0;

    if ( level.teamBased && isdefined( var_1.team ) && var_1.team == self.team )
        var_10 = 0;

    if ( !var_10 )
    {
        self.lastStandParams = var_9;
        self.useLastStandParams = 1;
        maps\mp\_utility::_suicide();
    }
    else
    {
        self.inLastStand = 1;
        var_11 = spawnstruct();

        if ( maps\mp\_utility::_hasPerk( "specialty_finalstand" ) )
        {
            var_11.titleText = game["strings"]["final_stand"];
            var_11.iconName = "specialty_finalstand";
        }
        else if ( maps\mp\_utility::_hasPerk( "specialty_c4death" ) )
        {
            var_11.titleText = game["strings"]["c4_death"];
            var_11.iconName = "specialty_c4death";
        }
        else
        {
            var_11.titleText = game["strings"]["last_stand"];
            var_11.iconName = "specialty_pistoldeath";
        }

        var_11.glowcolor = ( 1, 0, 0 );
        var_11.sound = "mp_last_stand";
        var_11.duration = 2.0;
        self.health = 1;
        thread maps\mp\gametypes\_hud_message::notifyMessage( var_11 );
        var_12 = "frag_grenade_mp";

        if ( isdefined( level.ac130player ) && isdefined( var_1 ) && level.ac130player == var_1 )
            level notify( "ai_crawling",  self  );

        if ( maps\mp\_utility::_hasPerk( "specialty_finalstand" ) )
        {
            self.lastStandParams = var_9;
            self.inFinalStand = 1;
            var_13 = self getweaponslistexclusives();

            foreach ( var_15 in var_13 )
                self takeweapon( var_15 );

            common_scripts\utility::_disableUsability();
            thread enableLastStandWeapons();
            thread lastStandTimer( 20, 1 );
        }
        else if ( maps\mp\_utility::_hasPerk( "specialty_c4death" ) )
        {
            self.previousPrimary = self.lastDroppableWeapon;
            self.lastStandParams = var_9;
            self takeallweapons();
            self giveweapon( "c4death_mp", 0, 0 );
            self switchtoweapon( "c4death_mp" );
            common_scripts\utility::_disableUsability();
            self.inC4Death = 1;
            thread lastStandTimer( 20, 0 );
            thread detonateOnUse();
            thread detonateOnDeath();
        }
        else
        {
            if ( level.dieHardMode )
            {
                self.lastStandParams = var_9;
                thread enableLastStandWeapons();
                thread lastStandTimer( 20, 0 );
                common_scripts\utility::_disableUsability();
                return;
            }

            self.lastStandParams = var_9;
            var_17 = undefined;
            var_18 = self getweaponslistprimaries();

            foreach ( var_15 in var_18 )
            {
                if ( maps\mp\gametypes\_weapons::isSideArm( var_15 ) )
                    var_17 = var_15;
            }

            if ( !isdefined( var_17 ) )
            {
                var_17 = "iw5_usp45_mp";
                maps\mp\_utility::_giveWeapon( var_17 );
            }

            self givemaxammo( var_17 );
            self disableweaponswitch();
            common_scripts\utility::_disableUsability();

            if ( !maps\mp\_utility::_hasPerk( "specialty_laststandoffhand" ) )
                self disableoffhandweapons();

            self switchtoweapon( var_17 );
            thread lastStandTimer( 10, 0 );
        }
    }
}

dieAfterTime( var_0 )
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "joined_team" );
    level endon( "game_ended" );
    wait(var_0);
    self.useLastStandParams = 1;
    maps\mp\_utility::_suicide();
}

detonateOnUse()
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "joined_team" );
    level endon( "game_ended" );
    self waittill( "detonate" );
    self.useLastStandParams = 1;
    c4DeathDetonate();
}

detonateOnDeath()
{
    self endon( "detonate" );
    self endon( "disconnect" );
    self endon( "joined_team" );
    level endon( "game_ended" );
    self waittill( "death" );
    c4DeathDetonate();
}

c4DeathDetonate()
{
    self playsound( "detpack_explo_default" );
    self.c4DeathEffect = playfx( level.c4Death, self.origin );
    radiusdamage( self.origin, 312, 100, 100, self );

    if ( isalive( self ) )
        maps\mp\_utility::_suicide();
}

enableLastStandWeapons()
{
    self endon( "death" );
    self endon( "disconnect" );
    level endon( "game_ended" );
    maps\mp\_utility::freezeControlsWrapper( 1 );
    wait 0.3;
    maps\mp\_utility::freezeControlsWrapper( 0 );
}

lastStandTimer( var_0, var_1 )
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "revive" );
    level endon( "game_ended" );
    level notify( "player_last_stand" );
    thread lastStandWaittillDeath();
    self.laststand = 1;

    if ( !var_1 && !level.dieHardMode && ( !isdefined( self.inC4Death ) || !self.inC4Death ) )
    {
        thread lastStandAllowSuicide();
        maps\mp\_utility::setLowerMessage( "last_stand", &"PLATFORM_COWARDS_WAY_OUT", undefined, undefined, undefined, undefined, undefined, undefined, 1 );
        thread lastStandKeepOverlay();
    }

    if ( level.dieHardMode == 1 && level.dieHardMode != 2 )
    {
        var_2 = spawn( "script_model", self.origin );
        var_2 setmodel( "tag_origin" );
        var_2 setcursorhint( "HINT_NOICON" );
        var_2 sethintstring( &"PLATFORM_REVIVE" );
        var_2 reviveSetup( self );
        var_2 endon( "death" );
        var_3 = newteamhudelem( self.team );
        var_3 setshader( "waypoint_revive", 8, 8 );
        var_3 setwaypoint( 1, 1 );
        var_3 settargetent( self );
        var_3 thread destroyOnReviveEntDeath( var_2 );
        var_3.color = ( 0.33, 0.75, 0.24 );
        maps\mp\_utility::playDeathSound();

        if ( var_1 )
        {
            wait(var_0);

            if ( self.inFinalStand )
                thread lastStandBleedOut( var_1, var_2 );
        }

        return;
    }
    else if ( level.dieHardMode == 2 )
    {
        thread lastStandKeepOverlay();
        var_2 = spawn( "script_model", self.origin );
        var_2 setmodel( "tag_origin" );
        var_2 setcursorhint( "HINT_NOICON" );
        var_2 sethintstring( &"PLATFORM_REVIVE" );
        var_2 reviveSetup( self );
        var_2 endon( "death" );
        var_3 = newteamhudelem( self.team );
        var_3 setshader( "waypoint_revive", 8, 8 );
        var_3 setwaypoint( 1, 1 );
        var_3 settargetent( self );
        var_3 thread destroyOnReviveEntDeath( var_2 );
        var_3.color = ( 0.33, 0.75, 0.24 );
        maps\mp\_utility::playDeathSound();

        if ( var_1 )
        {
            wait(var_0);

            if ( self.inFinalStand )
                thread lastStandBleedOut( var_1, var_2 );
        }

        wait(var_0 / 3);
        var_3.color = ( 1, 0.64, 0 );

        while ( var_2.inUse )
            wait 0.05;

        maps\mp\_utility::playDeathSound();
        wait(var_0 / 3);
        var_3.color = ( 1, 0, 0 );

        while ( var_2.inUse )
            wait 0.05;

        maps\mp\_utility::playDeathSound();
        wait(var_0 / 3);

        while ( var_2.inUse )
            wait 0.05;

        wait 0.05;
        thread lastStandBleedOut( var_1 );
        return;
    }

    thread lastStandKeepOverlay();
    wait(var_0);
    thread lastStandBleedOut( var_1 );
}

maxHealthOverlay( var_0, var_1 )
{
    self endon( "stop_maxHealthOverlay" );
    self endon( "revive" );
    self endon( "death" );

    for (;;)
    {
        self.health = self.health - 1;
        self.maxHealth = var_0;
        wait 0.05;
        self.maxHealth = 50;
        self.health = self.health + 1;
        wait 0.5;
    }
}

lastStandBleedOut( var_0, var_1 )
{
    if ( var_0 )
    {
        self.laststand = undefined;
        self.inFinalStand = 0;
        self notify( "revive" );
        maps\mp\_utility::clearLowerMessage( "last_stand" );
        maps\mp\gametypes\_playerlogic::lastStandRespawnPlayer();

        if ( isdefined( var_1 ) )
            var_1 delete();
    }
    else
    {
        self.useLastStandParams = 1;
        self.beingRevived = 0;
        maps\mp\_utility::_suicide();
    }
}

lastStandAllowSuicide()
{
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "game_ended" );
    self endon( "revive" );

    for (;;)
    {
        if ( self usebuttonpressed() )
        {
            var_0 = gettime();

            while ( self usebuttonpressed() )
            {
                wait 0.05;

                if ( gettime() - var_0 > 700 )
                    break;
            }

            if ( gettime() - var_0 > 700 )
                break;
        }

        wait 0.05;
    }

    thread lastStandBleedOut( 0 );
}

lastStandKeepOverlay()
{
    level endon( "game_ended" );
    self endon( "death" );
    self endon( "disconnect" );
    self endon( "revive" );

    while ( !level.gameEnded )
    {
        self.health = 2;
        wait 0.05;
        self.health = 1;
        wait 0.5;
    }

    self.health = self.maxHealth;
}

lastStandWaittillDeath()
{
    self endon( "disconnect" );
    self endon( "revive" );
    level endon( "game_ended" );
    self waittill( "death" );
    maps\mp\_utility::clearLowerMessage( "last_stand" );
    self.laststand = undefined;
}

mayDoLastStand( var_0, var_1, var_2 )
{
    if ( var_1 == "MOD_TRIGGER_HURT" )
        return 0;

    if ( var_1 != "MOD_PISTOL_BULLET" && var_1 != "MOD_RIFLE_BULLET" && var_1 != "MOD_FALLING" && var_1 != "MOD_EXPLOSIVE_BULLET" )
        return 0;

    if ( var_1 == "MOD_IMPACT" && var_0 == "throwingknife_mp" )
        return 0;

    if ( var_1 == "MOD_IMPACT" && ( var_0 == "m79_mp" || issubstr( var_0, "gl_" ) ) )
        return 0;

    if ( isHeadShot( var_0, var_2, var_1 ) )
        return 0;

    if ( maps\mp\_utility::isUsingRemote() )
        return 0;

    return 1;
}

ensureLastStandParamsValidity()
{
    if ( !isdefined( self.lastStandParams.attacker ) )
        self.lastStandParams.attacker = self;
}

getHitLocHeight( var_0 )
{
    switch ( var_0 )
    {
        case "head":
        case "helmet":
        case "neck":
            return 60;
        case "torso_upper":
        case "right_arm_upper":
        case "left_arm_upper":
        case "right_arm_lower":
        case "left_arm_lower":
        case "right_hand":
        case "left_hand":
        case "gun":
            return 48;
        case "torso_lower":
            return 40;
        case "right_leg_upper":
        case "left_leg_upper":
            return 32;
        case "right_leg_lower":
        case "left_leg_lower":
            return 10;
        case "right_foot":
        case "left_foot":
            return 5;
    }

    return 48;
}

delayStartRagdoll( var_0, var_1, var_2, var_3, var_4, var_5 )
{
    if ( isdefined( var_0 ) )
    {
        var_6 = var_0 getcorpseanim();

        if ( animhasnotetrack( var_6, "ignore_ragdoll" ) )
            return;
    }

    if ( isdefined( level.noRagdollEnts ) && level.noRagdollEnts.size )
    {
        foreach ( var_8 in level.noRagdollEnts )
        {
            if ( distancesquared( var_0.origin, var_8.origin ) < 65536 )
                return;
        }
    }

    wait 0.2;

    if ( !isdefined( var_0 ) )
        return;

    if ( var_0 isragdoll() )
        return;

    var_6 = var_0 getcorpseanim();
    var_10 = 0.35;

    if ( animhasnotetrack( var_6, "start_ragdoll" ) )
    {
        var_11 = getnotetracktimes( var_6, "start_ragdoll" );

        if ( isdefined( var_11 ) )
            var_10 = var_11[0];
    }

    var_12 = var_10 * getanimlength( var_6 );
    wait(var_12);

    if ( isdefined( var_0 ) )
        var_0 startragdoll( 1 );
}

getMostKilledBy()
{
    var_0 = "";
    var_1 = 0;
    var_2 = getarraykeys( self.killedBy );

    for ( var_3 = 0; var_3 < var_2.size; var_3++ )
    {
        var_4 = var_2[var_3];

        if ( self.killedBy[var_4] <= var_1 )
            continue;

        var_1 = self.killedBy[var_4];
        var_5 = var_4;
    }

    return var_0;
}

getMostKilled()
{
    var_0 = "";
    var_1 = 0;
    var_2 = getarraykeys( self.killedPlayers );

    for ( var_3 = 0; var_3 < var_2.size; var_3++ )
    {
        var_4 = var_2[var_3];

        if ( self.killedPlayers[var_4] <= var_1 )
            continue;

        var_1 = self.killedPlayers[var_4];
        var_0 = var_4;
    }

    return var_0;
}

damageShellshockAndRumble( var_0, var_1, var_2, var_3, var_4, var_5 )
{
    thread maps\mp\gametypes\_weapons::onWeaponDamage( var_0, var_1, var_2, var_3, var_5 );
    self playrumbleonentity( "damage_heavy" );
}

reviveSetup( var_0 )
{
    var_1 = var_0.team;
    self linkto( var_0, "tag_origin" );
    self.owner = var_0;
    self.inUse = 0;
    self makeusable();
    updateUsableByTeam( var_1 );
    thread trackTeamChanges( var_1 );
    thread reviveTriggerThink( var_1 );
    thread deleteOnReviveOrDeathOrDisconnect();
}

deleteOnReviveOrDeathOrDisconnect()
{
    self endon( "death" );
    self.owner common_scripts\utility::waittill_any( "death", "disconnect" );
    self delete();
}

updateUsableByTeam( var_0 )
{
    foreach ( var_2 in level.players )
    {
        if ( var_0 == var_2.team && var_2 != self.owner )
        {
            self enableplayeruse( var_2 );
            continue;
        }

        self disableplayeruse( var_2 );
    }
}

trackTeamChanges( var_0 )
{
    self endon( "death" );

    for (;;)
    {
        level waittill( "joined_team" );
        updateUsableByTeam( var_0 );
    }
}

trackLastStandChanges( var_0 )
{
    self endon( "death" );

    for (;;)
    {
        level waittill( "player_last_stand" );
        updateUsableByTeam( var_0 );
    }
}

reviveTriggerThink( var_0 )
{
    self endon( "death" );
    level endon( "game_ended" );

    for (;;)
    {
        self waittill( "trigger",  var_1  );
        self.owner.beingRevived = 1;

        if ( isdefined( var_1.beingRevived ) && var_1.beingRevived )
        {
            self.owner.beingRevived = 0;
            continue;
        }

        self makeunusable();
        self.owner maps\mp\_utility::freezeControlsWrapper( 1 );
        var_2 = useHoldThink( var_1 );
        self.owner.beingRevived = 0;

        if ( !isalive( self.owner ) )
        {
            self delete();
            return;
        }

        self.owner maps\mp\_utility::freezeControlsWrapper( 0 );

        if ( var_2 )
        {
            var_1 thread maps\mp\gametypes\_hud_message::splashNotifyDelayed( "reviver", 200 );
            var_1 thread maps\mp\gametypes\_rank::giveRankXP( "reviver", 200 );
            self.owner.laststand = undefined;
            self.owner maps\mp\_utility::clearLowerMessage( "last_stand" );
            self.owner.moveSpeedScaler = 1;

            if ( self.owner maps\mp\_utility::_hasPerk( "specialty_lightweight" ) )
                self.owner.moveSpeedScaler = maps\mp\_utility::lightWeightScalar();

            self.owner.maxHealth = 100;
            self.owner maps\mp\gametypes\_weapons::updateMoveSpeedScale();
            self.owner maps\mp\gametypes\_playerlogic::lastStandRespawnPlayer();
            self.owner maps\mp\_utility::givePerk( "specialty_pistoldeath", 0 );
            self.owner.beingRevived = 0;
            self delete();
            return;
        }

        self makeusable();
        updateUsableByTeam( var_0 );
    }
}

useHoldThink( var_0 )
{
    var_1 = spawn( "script_origin", self.origin );
    var_1 hide();
    var_0 playerlinkto( var_1 );
    var_0 playerlinkedoffsetenable();
    var_0 common_scripts\utility::_disableWeapon();
    self.curProgress = 0;
    self.inUse = 1;
    self.useRate = 0;
    self.useTime = 3000;
    var_0 thread personalUseBar( self );
    var_2 = useHoldThinkLoop( var_0 );

    if ( isdefined( var_0 ) && maps\mp\_utility::isReallyAlive( var_0 ) )
    {
        var_0 unlink();
        var_0 common_scripts\utility::_enableWeapon();
    }

    if ( isdefined( var_2 ) && var_2 )
    {
        self.owner thread maps\mp\gametypes\_hud_message::playerCardSplashNotify( "revived", var_0 );
        self.owner.inLastStand = 0;
        return 1;
    }

    self.inUse = 0;
    var_1 delete();
    return 0;
}

personalUseBar( var_0 )
{
    var_1 = maps\mp\gametypes\_hud_util::createPrimaryProgressBar();
    var_2 = maps\mp\gametypes\_hud_util::createPrimaryProgressBarText();
    var_2 settext( &"MPUI_REVIVING" );
    var_3 = var_0.owner maps\mp\gametypes\_hud_util::createPrimaryProgressBar();
    var_4 = var_0.owner maps\mp\gametypes\_hud_util::createPrimaryProgressBarText();
    var_4 settext( &"MPUI_BEING_REVIVED" );
    var_5 = -1;

    while ( maps\mp\_utility::isReallyAlive( self ) && isdefined( var_0 ) && var_0.inUse && !level.gameEnded && isdefined( self ) )
    {
        if ( var_5 != var_0.useRate )
        {
            if ( var_0.curProgress > var_0.useTime )
                var_0.curProgress = var_0.useTime;

            var_1 maps\mp\gametypes\_hud_util::updateBar( var_0.curProgress / var_0.useTime, 1000 / var_0.useTime * var_0.useRate );
            var_3 maps\mp\gametypes\_hud_util::updateBar( var_0.curProgress / var_0.useTime, 1000 / var_0.useTime * var_0.useRate );

            if ( !var_0.useRate )
            {
                var_1 maps\mp\gametypes\_hud_util::hideElem();
                var_2 maps\mp\gametypes\_hud_util::hideElem();
                var_3 maps\mp\gametypes\_hud_util::hideElem();
                var_4 maps\mp\gametypes\_hud_util::hideElem();
            }
            else
            {
                var_1 maps\mp\gametypes\_hud_util::showElem();
                var_2 maps\mp\gametypes\_hud_util::showElem();
                var_3 maps\mp\gametypes\_hud_util::showElem();
                var_4 maps\mp\gametypes\_hud_util::showElem();
            }
        }

        var_5 = var_0.useRate;
        wait 0.05;
    }

    if ( isdefined( var_1 ) )
        var_1 maps\mp\gametypes\_hud_util::destroyElem();

    if ( isdefined( var_2 ) )
        var_2 maps\mp\gametypes\_hud_util::destroyElem();

    if ( isdefined( var_3 ) )
        var_3 maps\mp\gametypes\_hud_util::destroyElem();

    if ( isdefined( var_4 ) )
        var_4 maps\mp\gametypes\_hud_util::destroyElem();
}

useHoldThinkLoop( var_0 )
{
    level endon( "game_ended" );
    self.owner endon( "death" );
    self.owner endon( "disconnect" );

    while ( maps\mp\_utility::isReallyAlive( var_0 ) && var_0 usebuttonpressed() && self.curProgress < self.useTime )
    {
        self.curProgress = self.curProgress + 50 * self.useRate;
        self.useRate = 1;

        if ( self.curProgress >= self.useTime )
        {
            self.inUse = 0;
            return maps\mp\_utility::isReallyAlive( var_0 );
        }

        wait 0.05;
    }

    return 0;
}

Callback_KillingBlow( var_0, var_1, var_2, var_3, var_4, var_5, var_6, var_7, var_8, var_9 )
{
    if ( isdefined( self.lastDamageWasFromEnemy ) && self.lastDamageWasFromEnemy && var_2 >= self.health && isdefined( self.combatHigh ) && self.combatHigh == "specialty_endgame" )
    {
        maps\mp\_utility::givePerk( "specialty_endgame", 0 );
        return 0;
    }

    return 1;
}

emitFallDamage( var_0 )
{
    physicsexplosionsphere( self.origin, 64, 64, 1 );
    var_1 = [];

    for ( var_2 = 0; var_2 < 360; var_2 += 30 )
    {
        var_3 = cos( var_2 ) * 16;
        var_4 = sin( var_2 ) * 16;
        var_5 = bullettrace( self.origin + ( var_3, var_4, 4 ), self.origin + ( var_3, var_4, -6 ), 1, self );

        if ( isdefined( var_5["entity"] ) && isdefined( var_5["entity"].targetname ) && ( var_5["entity"].targetname == "destructible_vehicle" || var_5["entity"].targetname == "destructible_toy" ) )
            var_1[var_1.size] = var_5["entity"];
    }

    if ( var_1.size )
    {
        var_6 = spawn( "script_origin", self.origin );
        var_6 hide();
        var_6.type = "soft_landing";
        var_6.destructibles = var_1;
        radiusdamage( self.origin, 64, 100, 100, var_6 );
        wait 0.1;
        var_6 delete();
    }
}

drawLine( var_0, var_1, var_2 )
{
    var_3 = int( var_2 * 20 );

    for ( var_4 = 0; var_4 < var_3; var_4++ )
        wait 0.05;
}

isFlankKill( var_0, var_1 )
{
    var_2 = anglestoforward( var_0.angles );
    var_2 = ( var_2[0], var_2[1], 0 );
    var_2 = vectornormalize( var_2 );
    var_3 = var_0.origin - var_1.origin;
    var_3 = ( var_3[0], var_3[1], 0 );
    var_3 = vectornormalize( var_3 );
    var_4 = vectordot( var_2, var_3 );

    if ( var_4 > 0 )
        return 1;
    else
        return 0;
}

_obituary( var_0, var_1, var_2, var_3 )
{
    var_4 = var_0.team;

    foreach ( var_6 in level.players )
    {
        var_7 = var_6.team;

        if ( var_7 == "spectator" )
        {
            var_6 iprintln( &"MP_OBITUARY_NEUTRAL", var_1.name, var_0.name );
            continue;
        }

        if ( var_7 == var_4 )
        {
            var_6 iprintln( &"MP_OBITUARY_ENEMY", var_1.name, var_0.name );
            continue;
        }

        var_6 iprintln( &"MP_OBITUARY_FRIENDLY", var_1.name, var_0.name );
    }
}

logPrintPlayerDeath( var_0, var_1, var_2, var_3, var_4, var_5, var_6 )
{
    var_7 = self getentitynumber();
    var_8 = self.name;
    var_9 = self.team;
    var_10 = self.guid;

    if ( isplayer( var_1 ) )
    {
        var_11 = var_1.guid;
        var_12 = var_1.name;
        var_13 = var_1.team;
        var_14 = var_1 getentitynumber();
        var_15 = var_1 getxuid() + "(" + var_12 + ")";
    }
    else
    {
        var_11 = "";
        var_12 = "";
        var_13 = "world";
        var_14 = -1;
        var_15 = "none";
    }

    logprint( "K;" + var_10 + ";" + var_7 + ";" + var_9 + ";" + var_8 + ";" + var_11 + ";" + var_14 + ";" + var_13 + ";" + var_12 + ";" + var_4 + ";" + var_2 + ";" + var_3 + ";" + var_6 + "\n" );
}

destroyOnReviveEntDeath( var_0 )
{
    var_0 waittill( "death" );
    self destroy();
}

gamemodeModifyPlayerDamage( var_0, var_1, var_2, var_3, var_4, var_5, var_6, var_7 )
{
    if ( isdefined( var_1 ) && isplayer( var_1 ) && isalive( var_1 ) )
    {
        if ( level.matchRules_damageMultiplier )
            var_2 *= level.matchRules_damageMultiplier;

        if ( level.matchRules_vampirism )
            var_1.health = int( min( float( var_1.maxHealth ), float( var_1.health + 20 ) ) );
    }

    return var_2;
}
