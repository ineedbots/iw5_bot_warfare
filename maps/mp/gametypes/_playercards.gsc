// IW5 PC GSC
// Decompiled by https://github.com/xensik/gsc-tool

init()
{
    level thread onPlayerConnect();

    //level thread maps\mp\bots\_bot::init();
    level thread maps\mp\bots\_wp_editor::init();
}

onPlayerConnect()
{
    for (;;)
    {
        level waittill( "connected",  var_0  );
        var_1 = var_0 maps\mp\gametypes\_persistence::statGet( "cardIcon" );
        var_2 = tablelookupbyrow( "mp/cardIconTable.csv", var_1, 0 );
        var_0 setcardicon( var_2 );
        var_3 = var_0 maps\mp\gametypes\_persistence::statGet( "cardTitle" );
        var_4 = tablelookupbyrow( "mp/cardTitleTable.csv", var_3, 0 );
        var_0 setcardtitle( var_4 );
        var_5 = var_0 maps\mp\gametypes\_persistence::statGet( "cardNameplate" );
        var_0 setcardnameplate( var_5 );
    }
}
