init()
{
  level thread watchNuke();
}

watchNuke()
{
	setDvar("scr_spawnpointfavorweight", "");
	level waittill( "nuke_death" );
	setDvar("scr_spawnpointfavorweight", "499999");
}
