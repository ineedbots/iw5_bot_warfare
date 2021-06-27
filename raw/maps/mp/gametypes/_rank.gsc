// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

init()
{
    level.scoreInfo = [];
    level.xpScale = getdvarint( "scr_xpscale" );

    if ( level.xpScale > 4 || level.xpScale < 0 )
        exitlevel( 0 );

    level.xpScale = min( level.xpScale, 4 );
    level.xpScale = max( level.xpScale, 0 );
    level.weaponxpscale = getdvarint( "scr_weaponxpscale", 1 );

    if ( level.weaponxpscale > 4 || level.weaponxpscale < 0 )
        exitlevel( 0 );

    level.weaponxpscale = min( level.weaponxpscale, 4 );
    level.weaponxpscale = max( level.weaponxpscale, 0 );
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
        registerScoreInfo( "kill", 100 );
        registerScoreInfo( "headshot", 100 );
        registerScoreInfo( "assist", 20 );
        registerScoreInfo( "proximityassist", 20 );
        registerScoreInfo( "proximitykill", 20 );
        registerScoreInfo( "suicide", 0 );
        registerScoreInfo( "teamkill", 0 );
    }
    else
    {
        registerScoreInfo( "kill", 50 );
        registerScoreInfo( "headshot", 50 );
        registerScoreInfo( "assist", 0 );
        registerScoreInfo( "suicide", 0 );
        registerScoreInfo( "teamkill", 0 );
    }

    registerScoreInfo( "win", 1 );
    registerScoreInfo( "loss", 0.5 );
    registerScoreInfo( "tie", 0.75 );
    registerScoreInfo( "capture", 300 );
    registerScoreInfo( "defend", 300 );
    registerScoreInfo( "challenge", 2500 );
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
    level thread patientZeroWaiter();
    level thread onPlayerConnect();
}

patientZeroWaiter()
{
    level endon( "game_ended" );

    while ( !isdefined( level.players ) || !level.players.size )
        wait 0.05;

    if ( !maps\mp\_utility::matchMakingGame() )
    {
        if ( getdvar( "mapname" ) == "mp_rust" && randomint( 1000 ) == 999 )
            level.patientZeroName = level.players[0].name;
    }
    else if ( getdvar( "scr_patientZero" ) != "" )
        level.patientZeroName = getdvar( "scr_patientZero" );
}

isRegisteredEvent( var_0 )
{
    if ( isdefined( level.scoreInfo[var_0] ) )
        return 1;
    else
        return 0;
}

registerScoreInfo( var_0, var_1 )
{
    level.scoreInfo[var_0]["value"] = var_1;
}

getScoreInfoValue( var_0 )
{
    var_1 = "scr_" + level.gameType + "_score_" + var_0;

    if ( getdvar( var_1 ) != "" )
        return getdvarint( var_1 );
    else
        return level.scoreInfo[var_0]["value"];
}

getScoreInfoLabel( var_0 )
{
    return level.scoreInfo[var_0]["label"];
}

getRankInfoMinXP( var_0 )
{
    return int( level.rankTable[var_0][2] );
}

getWeaponRankInfoMinXP( var_0 )
{
    return int( level.weaponRankTable[var_0][1] );
}

getRankInfoXPAmt( var_0 )
{
    return int( level.rankTable[var_0][3] );
}

getWeaponRankInfoXPAmt( var_0 )
{
    return int( level.weaponRankTable[var_0][2] );
}

getRankInfoMaxXp( var_0 )
{
    return int( level.rankTable[var_0][7] );
}

getWeaponRankInfoMaxXp( var_0 )
{
    return int( level.weaponRankTable[var_0][3] );
}

getRankInfoFull( var_0 )
{
    return tablelookupistring( "mp/ranktable.csv", 0, var_0, 16 );
}

getRankInfoIcon( var_0, var_1 )
{
    return tablelookup( "mp/rankIconTable.csv", 0, var_0, var_1 + 1 );
}

getRankInfoLevel( var_0 )
{
    return int( tablelookup( "mp/ranktable.csv", 0, var_0, 13 ) );
}

onPlayerConnect()
{
    for (;;)
    {
        level waittill( "connected",  var_0  );
        var_0.pers["rankxp"] = var_0 maps\mp\gametypes\_persistence::statGet( "experience" );

        if ( var_0.pers["rankxp"] < 0 )
            var_0.pers["rankxp"] = 0;

        var_1 = var_0 getRankForXp( var_0 getRankXP() );
        var_0.pers["rank"] = var_1;
        var_0.pers["participation"] = 0;
        var_0.xpUpdateTotal = 0;
        var_0.bonusUpdateTotal = 0;
        var_2 = var_0 getPrestigeLevel();
        var_0 setrank( var_1, var_2 );
        var_0.pers["prestige"] = var_2;

        if ( var_0.clientid < level.MaxLogClients )
        {
            setmatchdata( "players", var_0.clientid, "rank", var_1 );
            setmatchdata( "players", var_0.clientid, "Prestige", var_2 );
        }

        var_0.postGamePromotion = 0;

        if ( !isdefined( var_0.pers["postGameChallenges"] ) )
            var_0 setclientdvars( "ui_challenge_1_ref", "", "ui_challenge_2_ref", "", "ui_challenge_3_ref", "", "ui_challenge_4_ref", "", "ui_challenge_5_ref", "", "ui_challenge_6_ref", "", "ui_challenge_7_ref", "" );

        var_0 setclientdvar( "ui_promotion", 0 );

        if ( !isdefined( var_0.pers["summary"] ) )
        {
            var_0.pers["summary"] = [];
            var_0.pers["summary"]["xp"] = 0;
            var_0.pers["summary"]["score"] = 0;
            var_0.pers["summary"]["challenge"] = 0;
            var_0.pers["summary"]["match"] = 0;
            var_0.pers["summary"]["misc"] = 0;
            var_0 setclientdvar( "player_summary_xp", "0" );
            var_0 setclientdvar( "player_summary_score", "0" );
            var_0 setclientdvar( "player_summary_challenge", "0" );
            var_0 setclientdvar( "player_summary_match", "0" );
            var_0 setclientdvar( "player_summary_misc", "0" );
        }

        var_0 setclientdvar( "ui_opensummary", 0 );
        var_0 thread maps\mp\gametypes\_missions::updateChallenges();
        var_0.explosiveKills[0] = 0;
        var_0.xpGains = [];
        var_0.hud_xpPointsPopup = var_0 createXpPointsPopup();
        var_0.hud_xpEventPopup = var_0 createXpEventPopup();
        var_0 thread onPlayerSpawned();
        var_0 thread onJoinedTeam();
        var_0 thread onJoinedSpectators();
        var_0 thread setGamesPlayed();

        if ( var_0 getplayerdata( "prestigeDoubleXp" ) )
            var_0.prestigeDoubleXp = 1;
        else
            var_0.prestigeDoubleXp = 0;

        if ( var_0 getplayerdata( "prestigeDoubleWeaponXp" ) )
        {
            var_0.prestigeDoubleWeaponXp = 1;
            continue;
        }

        var_0.prestigeDoubleWeaponXp = 0;
    }
}

setGamesPlayed()
{
    self endon( "disconnect" );

    for (;;)
    {
        wait 30;

        if ( !self.hasDoneCombat )
            continue;

        maps\mp\gametypes\_persistence::statAdd( "gamesPlayed", 1 );
        break;
    }
}

onJoinedTeam()
{
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "joined_team" );
        thread removeRankHUD();
    }
}

onJoinedSpectators()
{
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "joined_spectators" );
        thread removeRankHUD();
    }
}

onPlayerSpawned()
{
    self endon( "disconnect" );

    for (;;)
        self waittill( "spawned_player" );
}

roundUp( var_0 )
{
    if ( int( var_0 ) != var_0 )
        return int( var_0 + 1 );
    else
        return int( var_0 );
}

giveRankXP( var_0, var_1, var_2, var_3, var_4 )
{
    self endon( "disconnect" );
    var_5 = "none";

    if ( !maps\mp\_utility::rankingEnabled() )
    {
        if ( var_0 == "assist" )
        {
            if ( isdefined( self.taggedassist ) )
                self.taggedassist = undefined;
            else
            {
                var_6 = &"MP_ASSIST";

                if ( maps\mp\_utility::_hasPerk( "specialty_assists" ) )
                {
                    if ( !( self.pers["assistsToKill"] % 2 ) )
                        var_6 = &"MP_ASSIST_TO_KILL";
                }

                thread xpEventPopup( var_6 );
            }
        }

        return;
    }

    if ( level.teamBased && ( !level.teamCount["allies"] || !level.teamCount["axis"] ) )
        return;
    else if ( !level.teamBased && level.teamCount["allies"] + level.teamCount["axis"] < 2 )
        return;

    if ( !isdefined( var_1 ) )
        var_1 = getScoreInfoValue( var_0 );

    if ( !isdefined( self.xpGains[var_0] ) )
        self.xpGains[var_0] = 0;

    var_7 = 0;
    var_8 = 0;

    switch ( var_0 )
    {
        case "kill":
        case "headshot":
        case "shield_damage":
            var_1 *= self.xpScaler;
        case "destroy":
        case "suicide":
        case "assist":
        case "teamkill":
        case "capture":
        case "defend":
        case "assault":
        case "return":
        case "pickup":
        case "plant":
        case "save":
        case "defuse":
        case "kill_confirmed":
        case "kill_denied":
        case "tags_retrieved":
        case "team_assist":
        case "kill_bonus":
        case "kill_carrier":
        case "draft_rogue":
        case "survivor":
        case "final_rogue":
        case "gained_gun_rank":
        case "dropped_enemy_gun_rank":
        case "got_juggernaut":
        case "kill_as_juggernaut":
        case "kill_juggernaut":
        case "jugg_on_jugg":
            if ( maps\mp\_utility::getGametypeNumLives() > 0 && var_0 != "shield_damage" )
            {
                var_9 = max( 1, int( 10 / maps\mp\_utility::getGametypeNumLives() ) );
                var_1 = int( var_1 * var_9 );
            }

            var_10 = 0;
            var_11 = 0;

            if ( self.prestigeDoubleXp )
            {
                var_12 = self getplayerdata( "prestigeDoubleXpTimePlayed" );

                if ( var_12 >= self.bufferedStatsMax["prestigeDoubleXpMaxTimePlayed"] )
                {
                    self setplayerdata( "prestigeDoubleXp", 0 );
                    self setplayerdata( "prestigeDoubleXpTimePlayed", 0 );
                    self setplayerdata( "prestigeDoubleXpMaxTimePlayed", 0 );
                    self.prestigeDoubleXp = 0;
                }
                else
                    var_11 = 2;
            }

            if ( !self.prestigeDoubleXp )
            {
                for ( var_13 = 0; var_13 < 3; var_13++ )
                {
                    if ( self getplayerdata( "xpMultiplierTimePlayed", var_13 ) < self.bufferedChildStatsMax["xpMaxMultiplierTimePlayed"][var_13] )
                        var_10 += int( self getplayerdata( "xpMultiplier", var_13 ) );
                }
            }

            if ( var_11 > 0 )
                var_1 = int( var_1 * level.xpScale * var_11 );
            else if ( var_10 > 0 )
                var_1 = int( var_1 * level.xpScale * var_10 );
            else
                var_1 = int( var_1 * level.xpScale );

            if ( isdefined( level.nukeDetonated ) && level.nukeDetonated )
            {
                if ( level.teamBased && level.nukeInfo.team == self.team )
                    var_1 *= level.nukeInfo._unk_field_ID54;
                else if ( !level.teamBased && level.nukeInfo.player == self )
                    var_1 *= level.nukeInfo._unk_field_ID54;

                var_1 = int( var_1 );
            }

            var_14 = getRestXPAward( var_1 );
            var_1 += var_14;

            if ( var_14 > 0 )
            {
                if ( isLastRestXPAward( var_1 ) )
                    thread maps\mp\gametypes\_hud_message::splashNotify( "rested_done" );

                var_8 = 1;
            }

            break;
        case "challenge":
            var_10 = 0;

            if ( self getplayerdata( "challengeXPMultiplierTimePlayed", 0 ) < self.bufferedChildStatsMax["challengeXPMaxMultiplierTimePlayed"][0] )
            {
                var_10 += int( self getplayerdata( "challengeXPMultiplier", 0 ) );

                if ( var_10 > 0 )
                    var_1 = int( var_1 * var_10 );
            }

            break;
    }

    if ( !var_8 )
    {
        if ( self getplayerdata( "restXPGoal" ) > getRankXP() )
            self setplayerdata( "restXPGoal", self getplayerdata( "restXPGoal" ) + var_1 );
    }

    var_15 = getRankXP();
    self.xpGains[var_0] = self.xpGains[var_0] + var_1;
    incRankXP( var_1 );

    if ( maps\mp\_utility::rankingEnabled() && updateRank( var_15 ) )
        thread updateRankAnnounceHUD();

    syncXPStat();
    var_16 = maps\mp\gametypes\_missions::isWeaponChallenge( var_4 );

    if ( var_16 )
        var_2 = self getcurrentweapon();

    if ( var_0 == "shield_damage" )
    {
        var_2 = self getcurrentweapon();
        var_3 = "MOD_MELEE";
    }

    if ( weaponShouldGetXP( var_2, var_3 ) || var_16 )
    {
        var_17 = strtok( var_2, "_" );

        if ( var_17[0] == "iw5" )
            var_18 = var_17[0] + "_" + var_17[1];
        else if ( var_17[0] == "alt" )
            var_18 = var_17[1] + "_" + var_17[2];
        else
            var_18 = var_17[0];

        if ( var_17[0] == "gl" )
            var_18 = var_17[1];

        if ( self isitemunlocked( var_18 ) )
        {
            if ( self.primaryWeapon == var_2 || self.secondaryWeapon == var_2 || weaponaltweaponname( self.primaryWeapon ) == var_2 || isdefined( self.tookWeaponFrom ) && isdefined( self.tookWeaponFrom[var_2] ) )
            {
                var_19 = getWeaponRankXP( var_18 );

                switch ( var_0 )
                {
                    case "kill":
                        var_20 = 100;
                        break;
                    default:
                        var_20 = var_1;
                        break;
                }

                var_20 = int( var_20 * level.weaponxpscale );

                if ( self.prestigeDoubleWeaponXp )
                {
                    var_21 = self getplayerdata( "prestigeDoubleWeaponXpTimePlayed" );

                    if ( var_21 >= self.bufferedStatsMax["prestigeDoubleWeaponXpMaxTimePlayed"] )
                    {
                        self setplayerdata( "prestigeDoubleWeaponXp", 0 );
                        self setplayerdata( "prestigeDoubleWeaponXpTimePlayed", 0 );
                        self setplayerdata( "prestigeDoubleWeaponXpMaxTimePlayed", 0 );
                        self.prestigeDoubleWeaponXp = 0;
                    }
                    else
                        var_20 *= 2;
                }

                if ( self getplayerdata( "weaponXPMultiplierTimePlayed", 0 ) < self.bufferedChildStatsMax["weaponXPMaxMultiplierTimePlayed"][0] )
                {
                    var_22 = int( self getplayerdata( "weaponXPMultiplier", 0 ) );

                    if ( var_22 > 0 )
                        var_20 *= var_22;
                }

                var_23 = var_19 + var_20;

                if ( !isWeaponMaxRank( var_18 ) )
                {
                    var_24 = getWeaponMaxRankXP( var_18 );

                    if ( var_23 > var_24 )
                    {
                        var_23 = var_24;
                        var_20 = var_24 - var_19;
                    }

                    if ( !isdefined( self.weaponsUsed ) )
                    {
                        self.weaponsUsed = [];
                        self.weaponXpEarned = [];
                    }

                    var_25 = 0;
                    var_26 = 999;

                    for ( var_13 = 0; var_13 < self.weaponsUsed.size; var_13++ )
                    {
                        if ( self.weaponsUsed[var_13] == var_18 )
                        {
                            var_25 = 1;
                            var_26 = var_13;
                        }
                    }

                    if ( var_25 )
                        self.weaponXpEarned[var_26] = self.weaponXpEarned[var_26] + var_20;
                    else
                    {
                        self.weaponsUsed[self.weaponsUsed.size] = var_18;
                        self.weaponXpEarned[self.weaponXpEarned.size] = var_20;
                    }

                    self setplayerdata( "weaponXP", var_18, var_23 );
                    maps\mp\_matchdata::logWeaponStat( var_18, "XP", var_20 );
                    maps\mp\_utility::incPlayerStat( "weaponxpearned", var_20 );

                    if ( maps\mp\_utility::rankingEnabled() && updateWeaponRank( var_23, var_18 ) )
                        thread updateWeaponRankAnnounceHUD();
                }
            }
        }
    }

    if ( !level.hardcoreMode )
    {
        if ( var_0 == "teamkill" )
            thread xpPointsPopup( 0 - getScoreInfoValue( "kill" ), 0, ( 1, 0, 0 ), 0 );
        else
        {
            var_27 = ( 1, 1, 0.5 );

            if ( var_8 )
                var_27 = ( 1, 0.65, 0 );

            thread xpPointsPopup( var_1, var_7, var_27, 0 );

            if ( var_0 == "assist" )
            {
                if ( isdefined( self.taggedassist ) )
                    self.taggedassist = undefined;
                else
                {
                    var_6 = &"MP_ASSIST";

                    if ( maps\mp\_utility::_hasPerk( "specialty_assists" ) )
                    {
                        if ( !( self.pers["assistsToKill"] % 2 ) )
                            var_6 = &"MP_ASSIST_TO_KILL";
                    }

                    thread xpEventPopup( var_6 );
                }
            }
        }
    }

    switch ( var_0 )
    {
        case "kill":
        case "suicide":
        case "headshot":
        case "assist":
        case "teamkill":
        case "capture":
        case "defend":
        case "assault":
        case "return":
        case "pickup":
        case "plant":
        case "defuse":
        case "kill_confirmed":
        case "kill_denied":
        case "tags_retrieved":
        case "team_assist":
        case "kill_bonus":
        case "kill_carrier":
        case "draft_rogue":
        case "survivor":
        case "final_rogue":
        case "gained_gun_rank":
        case "dropped_enemy_gun_rank":
        case "got_juggernaut":
        case "kill_as_juggernaut":
        case "kill_juggernaut":
        case "jugg_on_jugg":
            self.pers["summary"]["score"] = self.pers["summary"]["score"] + var_1;
            self.pers["summary"]["xp"] = self.pers["summary"]["xp"] + var_1;
            break;
        case "win":
        case "loss":
        case "tie":
            self.pers["summary"]["match"] = self.pers["summary"]["match"] + var_1;
            self.pers["summary"]["xp"] = self.pers["summary"]["xp"] + var_1;
            break;
        case "challenge":
            self.pers["summary"]["challenge"] = self.pers["summary"]["challenge"] + var_1;
            self.pers["summary"]["xp"] = self.pers["summary"]["xp"] + var_1;
            break;
        default:
            self.pers["summary"]["misc"] = self.pers["summary"]["misc"] + var_1;
            self.pers["summary"]["xp"] = self.pers["summary"]["xp"] + var_1;
            break;
    }
}

weaponShouldGetXP( var_0, var_1 )
{
    if ( self isitemunlocked( "cac" ) && !maps\mp\_utility::isJuggernaut() && isdefined( var_0 ) && isdefined( var_1 ) && !maps\mp\_utility::isKillstreakWeapon( var_0 ) )
    {
        if ( maps\mp\_utility::isBulletDamage( var_1 ) )
            return 1;

        if ( isexplosivedamagemod( var_1 ) || var_1 == "MOD_IMPACT" )
        {
            if ( maps\mp\_utility::getWeaponClass( var_0 ) == "weapon_projectile" || maps\mp\_utility::getWeaponClass( var_0 ) == "weapon_assault" )
                return 1;
        }

        if ( var_1 == "MOD_MELEE" )
        {
            if ( maps\mp\_utility::getWeaponClass( var_0 ) == "weapon_riot" )
                return 1;
        }
    }

    return 0;
}

updateRank( var_0 )
{
    var_1 = getRank();

    if ( var_1 == self.pers["rank"] )
        return 0;

    var_2 = self.pers["rank"];
    self.pers["rank"] = var_1;
    self setrank( var_1 );
    return 1;
}

updateWeaponRank( var_0, var_1 )
{
    var_2 = getWeaponRank( var_1 );

    if ( var_2 == self getplayerdata( "weaponRank", var_1 ) )
        return 0;

    self.pers["weaponRank"] = var_2;
    self setplayerdata( "weaponRank", var_1, var_2 );
    thread maps\mp\gametypes\_missions::masteryChallengeProcess( var_1 );
    return 1;
}

updateRankAnnounceHUD()
{
    self endon( "disconnect" );
    self notify( "update_rank" );
    self endon( "update_rank" );
    var_0 = self.pers["team"];

    if ( !isdefined( var_0 ) )
        return;

    if ( !maps\mp\_utility::levelFlag( "game_over" ) )
        level common_scripts\utility::waittill_notify_or_timeout( "game_over", 0.25 );

    var_1 = getRankInfoFull( self.pers["rank"] );
    var_2 = level.rankTable[self.pers["rank"]][1];
    var_3 = int( var_2[var_2.size - 1] );
    thread maps\mp\gametypes\_hud_message::promotionSplashNotify();

    if ( var_3 > 1 )
        return;

    for ( var_4 = 0; var_4 < level.players.size; var_4++ )
    {
        var_5 = level.players[var_4];
        var_6 = var_5.pers["team"];

        if ( isdefined( var_6 ) && var_5 != self )
        {
            if ( var_6 == var_0 )
                var_5 iprintln( &"RANK_PLAYER_WAS_PROMOTED", self, var_1 );
        }
    }
}

updateWeaponRankAnnounceHUD()
{
    self endon( "disconnect" );
    self notify( "update_weapon_rank" );
    self endon( "update_weapon_rank" );
    var_0 = self.pers["team"];

    if ( !isdefined( var_0 ) )
        return;

    if ( !maps\mp\_utility::levelFlag( "game_over" ) )
        level common_scripts\utility::waittill_notify_or_timeout( "game_over", 0.25 );

    thread maps\mp\gametypes\_hud_message::weaponPromotionSplashNotify();
}

endGameUpdate()
{
    var_0 = self;
}

createXpPointsPopup()
{
    var_0 = newclienthudelem( self );
    var_0.horzalign = "center";
    var_0.vertalign = "middle";
    var_0.alignx = "center";
    var_0.aligny = "middle";
    var_0.x = 30;

    if ( level.splitscreen )
        var_0.y = -30;
    else
        var_0.y = -50;

    var_0.font = "hudbig";
    var_0.fontScale = 0.65;
    var_0.archived = 0;
    var_0.color = ( 0.5, 0.5, 0.5 );
    var_0.sort = 10000;
    var_0 maps\mp\gametypes\_hud::fontPulseInit( 3.0 );
    return var_0;
}

xpPointsPopup( var_0, var_1, var_2, var_3 )
{
    self endon( "disconnect" );
    self endon( "joined_team" );
    self endon( "joined_spectators" );

    if ( var_0 == 0 )
        return;

    self notify( "xpPointsPopup" );
    self endon( "xpPointsPopup" );
    self.xpUpdateTotal = self.xpUpdateTotal + var_0;
    self.bonusUpdateTotal = self.bonusUpdateTotal + var_1;
    wait 0.05;

    if ( self.xpUpdateTotal < 0 )
        self.hud_xpPointsPopup.label = &"";
    else
        self.hud_xpPointsPopup.label = &"MP_PLUS";

    self.hud_xpPointsPopup.color = var_2;
    self.hud_xpPointsPopup.glowcolor = var_2;
    self.hud_xpPointsPopup.glowalpha = var_3;
    self.hud_xpPointsPopup setvalue( self.xpUpdateTotal );
    self.hud_xpPointsPopup.alpha = 0.85;
    self.hud_xpPointsPopup thread maps\mp\gametypes\_hud::fontPulse( self );
    var_4 = max( int( self.bonusUpdateTotal / 20 ), 1 );

    if ( self.bonusUpdateTotal )
    {
        while ( self.bonusUpdateTotal > 0 )
        {
            self.xpUpdateTotal = self.xpUpdateTotal + min( self.bonusUpdateTotal, var_4 );
            self.bonusUpdateTotal = self.bonusUpdateTotal - min( self.bonusUpdateTotal, var_4 );
            self.hud_xpPointsPopup setvalue( self.xpUpdateTotal );
            wait 0.05;
        }
    }
    else
        wait 1.0;

    self.hud_xpPointsPopup fadeovertime( 0.75 );
    self.hud_xpPointsPopup.alpha = 0;
    self.xpUpdateTotal = 0;
}

createXpEventPopup()
{
    var_0 = newclienthudelem( self );
    var_0.children = [];
    var_0.horzalign = "center";
    var_0.vertalign = "middle";
    var_0.alignx = "center";
    var_0.aligny = "middle";
    var_0.x = 55;

    if ( level.splitscreen )
        var_0.y = -20;
    else
        var_0.y = -35;

    var_0.font = "hudbig";
    var_0.fontScale = 0.65;
    var_0.archived = 0;
    var_0.color = ( 0.5, 0.5, 0.5 );
    var_0.sort = 10000;
    var_0.elemType = "msgText";
    var_0 maps\mp\gametypes\_hud::fontPulseInit( 3.0 );
    return var_0;
}

xpeventpopupfinalize( var_0, var_1, var_2 )
{
    self endon( "disconnect" );
    self endon( "joined_team" );
    self endon( "joined_spectators" );
    self notify( "xpEventPopup" );
    self endon( "xpEventPopup" );

    if ( level.hardcoreMode )
        return;

    wait 0.05;

    if ( !isdefined( var_1 ) )
        var_1 = ( 1, 1, 0.5 );

    if ( !isdefined( var_2 ) )
        var_2 = 0;

    if ( !isdefined( self ) )
        return;

    self.hud_xpEventPopup.color = var_1;
    self.hud_xpEventPopup.glowcolor = var_1;
    self.hud_xpEventPopup.glowalpha = var_2;
    self.hud_xpEventPopup settext( var_0 );
    self.hud_xpEventPopup.alpha = 0.85;
    wait 1.0;

    if ( !isdefined( self ) )
        return;

    self.hud_xpEventPopup fadeovertime( 0.75 );
    self.hud_xpEventPopup.alpha = 0;
    self notify( "PopComplete" );
}

xpeventpopupterminate()
{
    self endon( "PopComplete" );
    common_scripts\utility::waittill_any( "joined_team", "joined_spectators" );
    self.hud_xpEventPopup fadeovertime( 0.05 );
    self.hud_xpEventPopup.alpha = 0;
}

xpEventPopup( var_0, var_1, var_2 )
{
    thread xpeventpopupfinalize( var_0, var_1, var_2 );
    thread xpeventpopupterminate();
}

removeRankHUD()
{
    self.hud_xpPointsPopup.alpha = 0;
}

getRank()
{
    var_0 = self.pers["rankxp"];
    var_1 = self.pers["rank"];

    if ( var_0 < getRankInfoMinXP( var_1 ) + getRankInfoXPAmt( var_1 ) )
        return var_1;
    else
        return getRankForXp( var_0 );
}

getWeaponRank( var_0 )
{
    var_1 = self getplayerdata( "weaponXP", var_0 );
    return getWeaponRankForXp( var_1, var_0 );
}

levelForExperience( var_0 )
{
    return getRankForXp( var_0 );
}

weaponLevelForExperience( var_0 )
{
    return getWeaponRankForXp( var_0 );
}

getCurrentWeaponXP()
{
    var_0 = self getcurrentweapon();

    if ( isdefined( var_0 ) )
        return self getplayerdata( "weaponXP", var_0 );

    return 0;
}

getRankForXp( var_0 )
{
    var_1 = 0;
    var_2 = level.rankTable[var_1][1];

    while ( isdefined( var_2 ) && var_2 != "" )
    {
        if ( var_0 < getRankInfoMinXP( var_1 ) + getRankInfoXPAmt( var_1 ) )
            return var_1;

        var_1++;

        if ( isdefined( level.rankTable[var_1] ) )
        {
            var_2 = level.rankTable[var_1][1];
            continue;
        }

        var_2 = undefined;
    }

    var_1--;
    return var_1;
}

getWeaponRankForXp( var_0, var_1 )
{
    if ( !isdefined( var_0 ) )
        var_0 = 0;

    var_2 = tablelookup( "mp/statstable.csv", 4, var_1, 2 );
    var_3 = int( tablelookup( "mp/weaponRankTable.csv", 0, var_2, 1 ) );

    for ( var_4 = 0; var_4 < var_3 + 1; var_4++ )
    {
        if ( var_0 < getWeaponRankInfoMinXP( var_4 ) + getWeaponRankInfoXPAmt( var_4 ) )
            return var_4;
    }

    return var_4 - 1;
}

getSPM()
{
    var_0 = getRank() + 1;
    return ( 3 + var_0 * 0.5 ) * 10;
}

getPrestigeLevel()
{
    return maps\mp\gametypes\_persistence::statGet( "prestige" );
}

getRankXP()
{
    return self.pers["rankxp"];
}

getWeaponRankXP( var_0 )
{
    return self getplayerdata( "weaponXP", var_0 );
}

getWeaponMaxRankXP( var_0 )
{
    var_1 = tablelookup( "mp/statstable.csv", 4, var_0, 2 );
    var_2 = int( tablelookup( "mp/weaponRankTable.csv", 0, var_1, 1 ) );
    var_3 = getWeaponRankInfoMaxXp( var_2 );
    return var_3;
}

isWeaponMaxRank( var_0 )
{
    var_1 = self getplayerdata( "weaponXP", var_0 );
    var_2 = getWeaponMaxRankXP( var_0 );
    return var_1 >= var_2;
}

incRankXP( var_0 )
{
    if ( !maps\mp\_utility::rankingEnabled() )
        return;

    if ( isdefined( self.isCheater ) )
        return;

    var_1 = getRankXP();
    var_2 = int( min( var_1, getRankInfoMaxXp( level.maxRank ) ) ) + var_0;

    if ( self.pers["rank"] == level.maxRank && var_2 >= getRankInfoMaxXp( level.maxRank ) )
        var_2 = getRankInfoMaxXp( level.maxRank );

    self.pers["rankxp"] = var_2;
}

getRestXPAward( var_0 )
{
    if ( !getdvarint( "scr_restxp_enable" ) )
        return 0;

    var_1 = getdvarfloat( "scr_restxp_restedAwardScale" );
    var_2 = int( var_0 * var_1 );
    var_3 = self getplayerdata( "restXPGoal" ) - getRankXP();

    if ( var_3 <= 0 )
        return 0;

    return var_2;
}

isLastRestXPAward( var_0 )
{
    if ( !getdvarint( "scr_restxp_enable" ) )
        return 0;

    var_1 = getdvarfloat( "scr_restxp_restedAwardScale" );
    var_2 = int( var_0 * var_1 );
    var_3 = self getplayerdata( "restXPGoal" ) - getRankXP();

    if ( var_3 <= 0 )
        return 0;

    if ( var_2 >= var_3 )
        return 1;

    return 0;
}

syncXPStat()
{
    if ( level.xpScale > 4 || level.xpScale <= 0 )
        exitlevel( 0 );

    var_0 = getRankXP();
    maps\mp\gametypes\_persistence::statSet( "experience", var_0 );
}
