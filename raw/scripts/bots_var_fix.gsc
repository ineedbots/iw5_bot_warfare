#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\bots\_bot_utility;

main()
{
	replaceFunc( maps\mp\gametypes\_missions::mayProcessChallenges, ::mayProcessChallenges );
}

mayProcessChallenges()
{
	if ( self is_bot() )
		return false;

	return ( level.rankedMatch );
}
