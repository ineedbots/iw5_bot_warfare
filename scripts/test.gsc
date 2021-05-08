init()
{
  level thread onConnect();
}

onConnect()
{
  for (;;)
  {
    level waittill("connected", player);

    player thread connected();
  }
}

connected()
{
  self endon("disconnect");

  for(;;)
  {
    self waittill("spawned_player");
  }
}
