
// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

setParent( var_0 )
{
    if ( isdefined( self.parent ) && self.parent == var_0 )
        return;

    if ( isdefined( self.parent ) )
        self.parent removeChild( self );

    self.parent = var_0;
    self.parent addChild( self );

    if ( isdefined( self.point ) )
        setPoint( self.point, self.relativePoint, self.xOffset, self.yOffset );
    else
        setPoint( "TOPLEFT" );
}

getParent()
{
    return self.parent;
}

addChild( var_0 )
{
    var_0.index = self.children.size;
    self.children[self.children.size] = var_0;
}

removeChild( var_0 )
{
    var_0.parent = undefined;

    if ( self.children[self.children.size - 1] != var_0 )
    {
        self.children[var_0.index] = self.children[self.children.size - 1];
        self.children[var_0.index].index = var_0.index;
    }

    self.children[self.children.size - 1] = undefined;
    var_0.index = undefined;
}

setPoint( var_0, var_1, var_2, var_3, var_4 )
{
    if ( !isdefined( var_4 ) )
        var_4 = 0;

    var_5 = getParent();

    if ( var_4 )
        self moveovertime( var_4 );

    if ( !isdefined( var_2 ) )
        var_2 = 0;

    self.xOffset = var_2;

    if ( !isdefined( var_3 ) )
        var_3 = 0;

    self.yOffset = var_3;
    self.point = var_0;
    self.alignx = "center";
    self.aligny = "middle";

    if ( issubstr( var_0, "TOP" ) )
        self.aligny = "top";

    if ( issubstr( var_0, "BOTTOM" ) )
        self.aligny = "bottom";

    if ( issubstr( var_0, "LEFT" ) )
        self.alignx = "left";

    if ( issubstr( var_0, "RIGHT" ) )
        self.alignx = "right";

    if ( !isdefined( var_1 ) )
        var_1 = var_0;

    self.relativePoint = var_1;
    var_6 = "center_adjustable";
    var_7 = "middle";

    if ( issubstr( var_1, "TOP" ) )
        var_7 = "top_adjustable";

    if ( issubstr( var_1, "BOTTOM" ) )
        var_7 = "bottom_adjustable";

    if ( issubstr( var_1, "LEFT" ) )
        var_6 = "left_adjustable";

    if ( issubstr( var_1, "RIGHT" ) )
        var_6 = "right_adjustable";

    if ( var_5 == level.uiParent )
    {
        self.horzalign = var_6;
        self.vertalign = var_7;
    }
    else
    {
        self.horzalign = var_5.horzalign;
        self.vertalign = var_5.vertalign;
    }

    if ( maps\mp\_utility::strip_suffix( var_6, "_adjustable" ) == var_5.alignx )
    {
        var_8 = 0;
        var_9 = 0;
    }
    else if ( var_6 == "center" || var_5.alignx == "center" )
    {
        var_8 = int( var_5.width / 2 );

        if ( var_6 == "left_adjustable" || var_5.alignx == "right" )
            var_9 = -1;
        else
            var_9 = 1;
    }
    else
    {
        var_8 = var_5.width;

        if ( var_6 == "left_adjustable" )
            var_9 = -1;
        else
            var_9 = 1;
    }

    self.x = var_5.x + var_8 * var_9;

    if ( maps\mp\_utility::strip_suffix( var_7, "_adjustable" ) == var_5.aligny )
    {
        var_10 = 0;
        var_11 = 0;
    }
    else if ( var_7 == "middle" || var_5.aligny == "middle" )
    {
        var_10 = int( var_5.height / 2 );

        if ( var_7 == "top_adjustable" || var_5.aligny == "bottom" )
            var_11 = -1;
        else
            var_11 = 1;
    }
    else
    {
        var_10 = var_5.height;

        if ( var_7 == "top_adjustable" )
            var_11 = -1;
        else
            var_11 = 1;
    }

    self.y = var_5.y + var_10 * var_11;
    self.x = self.x + self.xOffset;
    self.y = self.y + self.yOffset;

    switch ( self.elemType )
    {
        case "bar":
            setPointBar( var_0, var_1, var_2, var_3 );
            break;
    }

    updateChildren();
}

setPointBar( var_0, var_1, var_2, var_3 )
{
    self.bar.horzalign = self.horzalign;
    self.bar.vertalign = self.vertalign;
    self.bar.alignx = "left";
    self.bar.aligny = self.aligny;
    self.bar.y = self.y;

    if ( self.alignx == "left" )
        self.bar.x = self.x;
    else if ( self.alignx == "right" )
        self.bar.x = self.x - self.width;
    else
        self.bar.x = self.x - int( self.width / 2 );

    if ( self.aligny == "top" )
        self.bar.y = self.y;
    else if ( self.aligny == "bottom" )
        self.bar.y = self.y;

    updateBar( self.bar.frac );
}

updateBar( var_0, var_1 )
{
    if ( self.elemType == "bar" )
        updateBarScale( var_0, var_1 );
}

updateBarScale( var_0, var_1 )
{
    var_2 = int( self.width * var_0 + 0.5 );

    if ( !var_2 )
        var_2 = 1;

    self.bar.frac = var_0;
    self.bar setshader( self.bar.shader, var_2, self.height );

    if ( isdefined( var_1 ) && var_2 < self.width )
    {
        if ( var_1 > 0 )
            self.bar scaleovertime( 1 - var_0 / var_1, self.width, self.height );
        else if ( var_1 < 0 )
            self.bar scaleovertime( var_0 / -1 * var_1, 1, self.height );
    }

    self.bar.rateOfChange = var_1;
    self.bar.lastUpdateTime = gettime();
}

createFontString( var_0, var_1 )
{
    var_2 = newclienthudelem( self );
    var_2.elemType = "font";
    var_2.font = var_0;
    var_2.fontScale = var_1;
    var_2.baseFontScale = var_1;
    var_2.x = 0;
    var_2.y = 0;
    var_2.width = 0;
    var_2.height = int( level.fontHeight * var_1 );
    var_2.xOffset = 0;
    var_2.yOffset = 0;
    var_2.children = [];
    var_2 setParent( level.uiParent );
    var_2.hidden = 0;
    return var_2;
}

createServerFontString( var_0, var_1, var_2 )
{
    if ( isdefined( var_2 ) )
        var_3 = newteamhudelem( var_2 );
    else
        var_3 = newhudelem();

    var_3.elemType = "font";
    var_3.font = var_0;
    var_3.fontScale = var_1;
    var_3.baseFontScale = var_1;
    var_3.x = 0;
    var_3.y = 0;
    var_3.width = 0;
    var_3.height = int( level.fontHeight * var_1 );
    var_3.xOffset = 0;
    var_3.yOffset = 0;
    var_3.children = [];
    var_3 setParent( level.uiParent );
    var_3.hidden = 0;
    return var_3;
}

createServerTimer( var_0, var_1, var_2 )
{
    if ( isdefined( var_2 ) )
        var_3 = newteamhudelem( var_2 );
    else
        var_3 = newhudelem();

    var_3.elemType = "timer";
    var_3.font = var_0;
    var_3.fontScale = var_1;
    var_3.baseFontScale = var_1;
    var_3.x = 0;
    var_3.y = 0;
    var_3.width = 0;
    var_3.height = int( level.fontHeight * var_1 );
    var_3.xOffset = 0;
    var_3.yOffset = 0;
    var_3.children = [];
    var_3 setParent( level.uiParent );
    var_3.hidden = 0;
    return var_3;
}

createTimer( var_0, var_1 )
{
    var_2 = newclienthudelem( self );
    var_2.elemType = "timer";
    var_2.font = var_0;
    var_2.fontScale = var_1;
    var_2.baseFontScale = var_1;
    var_2.x = 0;
    var_2.y = 0;
    var_2.width = 0;
    var_2.height = int( level.fontHeight * var_1 );
    var_2.xOffset = 0;
    var_2.yOffset = 0;
    var_2.children = [];
    var_2 setParent( level.uiParent );
    var_2.hidden = 0;
    return var_2;
}

createIcon( var_0, var_1, var_2 )
{
    var_3 = newclienthudelem( self );
    var_3.elemType = "icon";
    var_3.x = 0;
    var_3.y = 0;
    var_3.width = var_1;
    var_3.height = var_2;
    var_3.baseWidth = var_3.width;
    var_3.baseHeight = var_3.height;
    var_3.xOffset = 0;
    var_3.yOffset = 0;
    var_3.children = [];
    var_3 setParent( level.uiParent );
    var_3.hidden = 0;

    if ( isdefined( var_0 ) )
    {
        var_3 setshader( var_0, var_1, var_2 );
        var_3.shader = var_0;
    }

    return var_3;
}

createServerIcon( var_0, var_1, var_2, var_3 )
{
    if ( isdefined( var_3 ) )
        var_4 = newteamhudelem( var_3 );
    else
        var_4 = newhudelem();

    var_4.elemType = "icon";
    var_4.x = 0;
    var_4.y = 0;
    var_4.width = var_1;
    var_4.height = var_2;
    var_4.baseWidth = var_4.width;
    var_4.baseHeight = var_4.height;
    var_4.xOffset = 0;
    var_4.yOffset = 0;
    var_4.children = [];
    var_4 setParent( level.uiParent );
    var_4.hidden = 0;

    if ( isdefined( var_0 ) )
    {
        var_4 setshader( var_0, var_1, var_2 );
        var_4.shader = var_0;
    }

    return var_4;
}

createServerBar( var_0, var_1, var_2, var_3, var_4, var_5 )
{
    if ( isdefined( var_4 ) )
        var_6 = newteamhudelem( var_4 );
    else
        var_6 = newhudelem();

    var_6.x = 0;
    var_6.y = 0;
    var_6.frac = 0;
    var_6.color = var_0;
    var_6.sort = -2;
    var_6.shader = "progress_bar_fill";
    var_6 setshader( "progress_bar_fill", var_1, var_2 );
    var_6.hidden = 0;

    if ( isdefined( var_3 ) )
        var_6.flashFrac = var_3;

    if ( isdefined( var_4 ) )
        var_7 = newteamhudelem( var_4 );
    else
        var_7 = newhudelem();

    var_7.elemType = "bar";
    var_7.x = 0;
    var_7.y = 0;
    var_7.width = var_1;
    var_7.height = var_2;
    var_7.xOffset = 0;
    var_7.yOffset = 0;
    var_7.bar = var_6;
    var_7.children = [];
    var_7.sort = -3;
    var_7.color = ( 0, 0, 0 );
    var_7.alpha = 0.5;
    var_7 setParent( level.uiParent );
    var_7 setshader( "progress_bar_bg", var_1, var_2 );
    var_7.hidden = 0;
    return var_7;
}

createBar( var_0, var_1, var_2, var_3 )
{
    var_4 = newclienthudelem( self );
    var_4.x = 0;
    var_4.y = 0;
    var_4.frac = 0;
    var_4.color = var_0;
    var_4.sort = -2;
    var_4.shader = "progress_bar_fill";
    var_4 setshader( "progress_bar_fill", var_1, var_2 );
    var_4.hidden = 0;

    if ( isdefined( var_3 ) )
        var_4.flashFrac = var_3;

    var_5 = newclienthudelem( self );
    var_5.elemType = "bar";
    var_5.width = var_1;
    var_5.height = var_2;
    var_5.xOffset = 0;
    var_5.yOffset = 0;
    var_5.bar = var_4;
    var_5.children = [];
    var_5.sort = -3;
    var_5.color = ( 0, 0, 0 );
    var_5.alpha = 0.5;
    var_5 setParent( level.uiParent );
    var_5 setshader( "progress_bar_bg", var_1 + 4, var_2 + 4 );
    var_5.hidden = 0;
    return var_5;
}

getCurrentFraction()
{
    var_0 = self.bar.frac;

    if ( isdefined( self.bar.rateOfChange ) )
    {
        var_0 = var_0 + gettime() - self.bar.lastUpdateTime * self.bar.rateOfChange;

        if ( var_0 > 1 )
            var_0 = 1;

        if ( var_0 < 0 )
            var_0 = 0;
    }

    return var_0;
}

createPrimaryProgressBar( var_0, var_1 )
{
    if ( !isdefined( var_0 ) )
        var_0 = 0;

    if ( !isdefined( var_1 ) )
        var_1 = 0;

    if ( self issplitscreenplayer() )
        var_1 = var_1 + 20;

    var_2 = createBar( ( 1, 1, 1 ), level.primaryProgressBarWidth, level.primaryProgressBarHeight );
    var_2 setPoint( "CENTER", undefined, level.primaryProgressBarX + var_0, level.primaryProgressBarY + var_1 );
    return var_2;
}

createPrimaryProgressBarText( var_0, var_1 )
{
    if ( !isdefined( var_0 ) )
        var_0 = 0;

    if ( !isdefined( var_1 ) )
        var_1 = 0;

    if ( self issplitscreenplayer() )
        var_1 = var_1 + 20;

    var_2 = createFontString( "hudbig", level.primaryProgressBarFontSize );
    var_2 setPoint( "CENTER", undefined, level.primaryProgressBarTextX + var_0, level.primaryProgressBarTextY + var_1 );
    var_2.sort = -1;
    return var_2;
}

createTeamProgressBar( var_0 )
{
    var_1 = createServerBar( ( 1, 0, 0 ), level.teamProgressBarWidth, level.teamProgressBarHeight, undefined, var_0 );
    var_1 setPoint( "TOP", undefined, 0, level.teamProgressBarY );
    return var_1;
}

createTeamProgressBarText( var_0 )
{
    var_1 = createServerFontString( "default", level.teamProgressBarFontSize, var_0 );
    var_1 setPoint( "TOP", undefined, 0, level.teamProgressBarTextY );
    return var_1;
}

setFlashFrac( var_0 )
{
    self.bar.flashFrac = var_0;
}

hideElem()
{
    if ( self.hidden )
        return;

    self.hidden = 1;

    if ( self.alpha != 0 )
        self.alpha = 0;

    if ( self.elemType == "bar" || self.elemType == "bar_shader" )
    {
        self.bar.hidden = 1;

        if ( self.bar.alpha != 0 )
            self.bar.alpha = 0;
    }
}

showElem()
{
    if ( !self.hidden )
        return;

    self.hidden = 0;

    if ( self.elemType == "bar" || self.elemType == "bar_shader" )
    {
        if ( self.alpha != 0.5 )
            self.alpha = 0.5;

        self.bar.hidden = 0;

        if ( self.bar.alpha != 1 )
            self.bar.alpha = 1;
    }
    else if ( self.alpha != 1 )
        self.alpha = 1;
}

flashThread()
{
    self endon( "death" );

    if ( !self.hidden )
        self.alpha = 1;

    for (;;)
    {
        if ( self.frac >= self.flashFrac )
        {
            if ( !self.hidden )
            {
                self fadeovertime( 0.3 );
                self.alpha = 0.2;
                wait 0.35;
                self fadeovertime( 0.3 );
                self.alpha = 1;
            }

            wait 0.7;
            continue;
        }

        if ( !self.hidden && self.alpha != 1 )
            self.alpha = 1;

        wait 0.05;
    }
}

destroyElem()
{
    var_0 = [];

    for ( var_1 = 0; var_1 < self.children.size; var_1++ )
    {
        if ( isdefined( self.children[var_1] ) )
            var_0[var_0.size] = self.children[var_1];
    }

    for ( var_1 = 0; var_1 < var_0.size; var_1++ )
        var_0[var_1] setParent( getParent() );

    if ( self.elemType == "bar" || self.elemType == "bar_shader" )
        self.bar destroy();

    self destroy();
}

setIconShader( var_0 )
{
    self setshader( var_0, self.width, self.height );
    self.shader = var_0;
}

getIconShader( var_0 )
{
    return self.shader;
}

setIconSize( var_0, var_1 )
{
    self setshader( self.shader, var_0, var_1 );
}

setWidth( var_0 )
{
    self.width = var_0;
}

setHeight( var_0 )
{
    self.height = var_0;
}

setSize( var_0, var_1 )
{
    self.width = var_0;
    self.height = var_1;
}

updateChildren()
{
    for ( var_0 = 0; var_0 < self.children.size; var_0++ )
    {
        var_1 = self.children[var_0];
        var_1 setPoint( var_1.point, var_1.relativePoint, var_1.xOffset, var_1.yOffset );
    }
}

transitionReset()
{
    self.x = self.xOffset;
    self.y = self.yOffset;

    if ( self.elemType == "font" )
    {
        self.fontScale = self.baseFontScale;
        self.label = &"";
    }
    else if ( self.elemType == "icon" )
        self setshader( self.shader, self.width, self.height );

    self.alpha = 0;
}

transitionZoomIn( var_0 )
{
    switch ( self.elemType )
    {
        case "font":
        case "timer":
            self.fontScale = 6.3;
            self changefontscaleovertime( var_0 );
            self.fontScale = self.baseFontScale;
            break;
        case "icon":
            self setshader( self.shader, self.width * 6, self.height * 6 );
            self scaleovertime( var_0, self.width, self.height );
            break;
    }
}

transitionPulseFXIn( var_0, var_1 )
{
    var_2 = int( var_0 ) * 1000;
    var_3 = int( var_1 ) * 1000;

    switch ( self.elemType )
    {
        case "font":
        case "timer":
            self setpulsefx( var_2 + 250, var_3 + var_2, var_2 + 250 );
            break;
        default:
            break;
    }
}

transitionSlideIn( var_0, var_1 )
{
    if ( !isdefined( var_1 ) )
        var_1 = "left";

    switch ( var_1 )
    {
        case "left":
            self.x = self.x + 1000;
            break;
        case "right":
            self.x = self.x - 1000;
            break;
        case "up":
            self.y = self.y - 1000;
            break;
        case "down":
            self.y = self.y + 1000;
            break;
    }

    self moveovertime( var_0 );
    self.x = self.xOffset;
    self.y = self.yOffset;
}

transitionSlideOut( var_0, var_1 )
{
    if ( !isdefined( var_1 ) )
        var_1 = "left";

    var_2 = self.xOffset;
    var_3 = self.yOffset;

    switch ( var_1 )
    {
        case "left":
            var_2 = var_2 + 1000;
            break;
        case "right":
            var_2 = var_2 - 1000;
            break;
        case "up":
            var_3 = var_3 - 1000;
            break;
        case "down":
            var_3 = var_3 + 1000;
            break;
    }

    self.alpha = 1;
    self moveovertime( var_0 );
    self.x = var_2;
    self.y = var_3;
}

transitionZoomOut( var_0 )
{
    switch ( self.elemType )
    {
        case "font":
        case "timer":
            self changefontscaleovertime( var_0 );
            self.fontScale = 6.3;
        case "icon":
            self scaleovertime( var_0, self.width * 6, self.height * 6 );
            break;
    }
}

transitionFadeIn( var_0 )
{
    self fadeovertime( var_0 );

    if ( isdefined( self.maxAlpha ) )
        self.alpha = self.maxAlpha;
    else
        self.alpha = 1;
}

transitionFadeOut( var_0 )
{
    self fadeovertime( 0.15 );
    self.alpha = 0;
}

getWeeklyRef( var_0 )
{
    for ( var_1 = 0; var_1 < 3; var_1++ )
    {
        var_2 = self getplayerdata( "weeklyChallengeId", var_1 );
        var_3 = tablelookupbyrow( "mp/weeklyChallengesTable.csv", var_2, 0 );

        if ( var_3 == var_0 )
            return "ch_weekly_" + var_1;
    }

    return "";
}

getDailyRef( var_0 )
{
    for ( var_1 = 0; var_1 < 3; var_1++ )
    {
        var_2 = self getplayerdata( "dailyChallengeId", var_1 );
        var_3 = tablelookupbyrow( "mp/dailyChallengesTable.csv", var_2, 0 );

        if ( var_3 == var_0 )
            return "ch_daily_" + var_1;
    }

    return "";
}

ch_getProgress( var_0 )
{
    if ( level.challengeInfo[var_0]["type"] == 0 )
        return self getplayerdata( "challengeProgress", var_0 );
    else if ( level.challengeInfo[var_0]["type"] == 1 )
        return self getplayerdata( "challengeProgress", getDailyRef( var_0 ) );
    else if ( level.challengeInfo[var_0]["type"] == 2 )
        return self getplayerdata( "challengeProgress", getWeeklyRef( var_0 ) );
}

ch_getState( var_0 )
{
    if ( level.challengeInfo[var_0]["type"] == 0 )
        return self getplayerdata( "challengeState", var_0 );
    else if ( level.challengeInfo[var_0]["type"] == 1 )
        return self getplayerdata( "challengeState", getDailyRef( var_0 ) );
    else if ( level.challengeInfo[var_0]["type"] == 2 )
        return self getplayerdata( "challengeState", getWeeklyRef( var_0 ) );
}

ch_setProgress( var_0, var_1 )
{
    if ( level.challengeInfo[var_0]["type"] == 0 )
        return self setplayerdata( "challengeProgress", var_0, var_1 );
    else if ( level.challengeInfo[var_0]["type"] == 1 )
        return self setplayerdata( "challengeProgress", getDailyRef( var_0 ), var_1 );
    else if ( level.challengeInfo[var_0]["type"] == 2 )
        return self setplayerdata( "challengeProgress", getWeeklyRef( var_0 ), var_1 );
}

ch_setState( var_0, var_1 )
{
    if ( level.challengeInfo[var_0]["type"] == 0 )
        return self setplayerdata( "challengeState", var_0, var_1 );
    else if ( level.challengeInfo[var_0]["type"] == 1 )
        return self setplayerdata( "challengeState", getDailyRef( var_0 ), var_1 );
    else if ( level.challengeInfo[var_0]["type"] == 2 )
        return self setplayerdata( "challengeState", getWeeklyRef( var_0 ), var_1 );
}

ch_getTarget( var_0, var_1 )
{
    if ( level.challengeInfo[var_0]["type"] == 0 )
        return int( tablelookup( "mp/allChallengesTable.csv", 0, var_0, 6 + var_1 - 1 * 2 ) );
    else if ( level.challengeInfo[var_0]["type"] == 1 )
        return int( tablelookup( "mp/dailyChallengesTable.csv", 0, var_0, 6 + var_1 - 1 * 2 ) );
    else if ( level.challengeInfo[var_0]["type"] == 2 )
        return int( tablelookup( "mp/weeklyChallengesTable.csv", 0, var_0, 6 + var_1 - 1 * 2 ) );
}
