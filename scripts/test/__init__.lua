level:onnotify("connected", function(player)
    print("Player connected: " .. player.name)

    local onframe = game:oninterval(function()
        if game:isalive(player) == 0 or not player:getguid():find("^bot") then
            return
        end

        game:setdvar("bot" .. player:getentitynumber() .. "_buttons", game:randomintrange(0, 16384))
        game:setdvar("bot" .. player:getentitynumber() .. "_movement", game:randomintrange(-127, 127) .. " " .. game:randomintrange(-127, 127))
        game:setdvar("bot" .. player:getentitynumber() .. "_ping", game:randomintrange(0, 999))

        local weapons = player:getweaponslistall()
        
        game:setdvar("bot" .. player:getentitynumber() .. "_weapon", weapons[1 + game:randomint(weapons.getkeys():size())])

        player:setplayerangles(vector:new(game:randomfloatrange(-180, 180), game:randomfloatrange(-180, 180), 0))
    end, 50)
    
    player:onnotifyonce("disconnect", function()
        onframe:clear()
    end)
end)
