game:onplayerdamage(function(_self, inflictor, attacker, damage, dflags, mod, weapon, point, dir, hitloc)
  if (game:isplayer(attacker) ~= 1 or _self.sessionteam == attacker.sessionteam or _self == attacker) then
      return
  end

  local huddamage = game:newclienthudelem(attacker)
  huddamage.alignx = "center"
  huddamage.horzalign = "center"
  huddamage.x = 10
  huddamage.y = 235
  huddamage.fontscale = 1.6
  huddamage.font = "objective"
  huddamage:setvalue(damage)

  if (hitloc == "head") then
      huddamage.color = vector:new(1, 1, 0.25)
  end

  huddamage:moveovertime(1)
  huddamage:fadeovertime(1)
  huddamage.alpha = 0
  huddamage.x = math.random(25, 70)
  huddamage.y = 235 + math.random(25, 70) * (math.random(0, 1) == 1 and -1 or 1)

  game:ontimeout(function()
      huddamage:destroy()
  end, 1000)
end)
