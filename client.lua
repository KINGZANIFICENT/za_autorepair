local QBCore = exports['qb-core']:GetCoreObject()

-- Function to draw 3D text for prompts
function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local camCoords = GetGameplayCamCoords()
    local distance = GetDistanceBetweenCoords(camCoords.x, camCoords.y, camCoords.z, x, y, z, 1)
    local scale = (1 / distance) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    scale = scale * fov
    if onScreen then
        SetTextScale(0.0 * scale, 0.55 * scale)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(true)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

-- Main thread: handles repair prompt and repair process
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        
        for _, repair in ipairs(Config.RepairLocations) do
            local distance = #(playerCoords - repair.coords)
            
            if distance < 10.0 then
                DrawMarker(1, repair.coords.x, repair.coords.y, repair.coords.z - 1.0, 
                    0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 0, 255, 0, 100, false, true, 2, nil, nil, false)
                    
                if IsPedInAnyVehicle(playerPed, false) and distance < 2.0 then
                    DrawText3D(repair.coords.x, repair.coords.y, repair.coords.z + 1.0,
                        "Press [E] to repair your vehicle ($" .. repair.price .. ")")
                        
                    if IsControlJustReleased(0, 38) then -- E key
                        local vehicle = GetVehiclePedIsIn(playerPed, false)
                        if vehicle then
                            QBCore.Functions.TriggerCallback('vehicle:repair:canAfford', function(canAfford)
                                if canAfford then
                                    QBCore.Functions.Progressbar("repair_vehicle", "Repairing Vehicle...", Config.RepairDuration, false, true, {
                                        disableMovement = true,
                                        disableCarMovement = true,
                                        disableMouse = false,
                                        disableCombat = true,
                                    }, {}, {}, {}, function() -- onFinish callback
                                        if DoesEntityExist(vehicle) and IsEntityAVehicle(vehicle) then
                                            SetVehicleEngineHealth(vehicle, 1000.0)
                                            SetVehicleFuelLevel(vehicle, 100.0)
                                            SetVehicleFixed(vehicle)
                                            TriggerEvent('za_notify:client:Notify', "Your vehicle has been repaired!", "success", 3000)
                                        else
                                            TriggerEvent('za_notify:client:Notify', "Vehicle not found.", "error", 3000)
                                        end
                                    end, function(cancelled) -- onCancel callback
                                        TriggerEvent('za_notify:client:Notify', "Repair canceled", "error", 3000)
                                    end)
                                end
                            end, repair.price)
                        end
                    end
                end
            end
        end
    end
end)
