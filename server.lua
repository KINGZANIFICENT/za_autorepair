local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateCallback('vehicle:repair:canAfford', function(source, cb, repairPrice)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        local cash = Player.PlayerData.money and Player.PlayerData.money.cash or 0
        if cash >= repairPrice then
            -- Remove money and notify the client that the purchase was successful using za_notify
            Player.Functions.RemoveMoney("cash", repairPrice, "vehicle repair")
            TriggerClientEvent('za_notify:client:Notify', src, "Repair purchase successful!", "success", 3000)
            cb(true)
        else
            -- Notify the client that they do not have enough cash using za_notify
            TriggerClientEvent('za_notify:client:Notify', src, "You don't have enough cash to repair your vehicle!", "error", 3000)
            cb(false)
        end
    else
        cb(false)
    end
end)
