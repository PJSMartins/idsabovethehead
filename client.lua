-- CONFIGURATION
local feedbackType = "notification" -- Options: "chat" or "notification"
local distanciaMaxima = 15.0 -- Maximum distance to show IDs

-- STATE
local mostrarIDs = false

-- Draw 3D text function
function DrawText3D(x, y, z, text)
    local _, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoord())
    local dist = GetDistanceBetweenCoords(px, py, pz, x, y, z, 1)
    local scale = (1 / dist) * 2
    if scale > 0.7 then scale = 0.7 end
    if _x and _y then
        SetTextScale(1.0 * scale, 1.0 * scale)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextOutline()
        SetTextEntry("STRING")
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

-- Show notification using ox_lib
function ShowNotification(msg)
    lib.notify({
        title = 'ID',
        description = msg,
        type = 'inform'
    })
end

-- Show message in chat
function ShowChatMessage(msg, color)
    TriggerEvent("chat:addMessage", {
        color = color or {0, 255, 0},
        multiline = true,
        args = {"[ID]", msg}
    })
end

-- Main thread to draw IDs
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if mostrarIDs then
            for _, id in ipairs(GetActivePlayers()) do
                local ped = GetPlayerPed(id)
                local coords = GetEntityCoords(ped)
                local myCoords = GetEntityCoords(PlayerPedId())
                local dist = #(myCoords - coords)
                if dist < distanciaMaxima then
                    local zOffset = (id == PlayerId()) and 1.5 or 1.0
                    DrawText3D(coords.x, coords.y, coords.z + zOffset, "ID: " .. GetPlayerServerId(id))
                end
            end
        else
            Citizen.Wait(500)
        end
    end
end)

-- Command to toggle ID display
RegisterCommand("mostrarid", function()
    mostrarIDs = not mostrarIDs
    if feedbackType == "notification" then
        if mostrarIDs then
            ShowNotification("IDs ativados.")
        else
            ShowNotification("IDs desativados.")
        end
    else
        if mostrarIDs then
            ShowChatMessage("IDs ativados.", {0, 255, 0})
        else
            ShowChatMessage("IDs desativados.", {255, 0, 0})
        end
    end
end)
