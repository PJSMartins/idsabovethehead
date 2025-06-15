local mostrarIDs = false
local distanciaMaxima = 15.0

function DrawText3D(x, y, z, text)
    local _, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoord())
    local dist = GetDistanceBetweenCoords(px, py, pz, x, y, z, 1)
    local scale = (1/dist)*2
    if scale > 0.7 then scale = 0.7 end -- Limite máximo para não ficar exagerado
    if _x and _y then
        SetTextScale(1.0*scale, 1.0*scale) -- Aumentado de 0.35 para 0.55
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextOutline()
        SetTextEntry("STRING")
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

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
                    -- Ajusta a altura do texto para o próprio jogador
                    local zOffset = (id == PlayerId()) and 1.5 or 1.0
                    DrawText3D(coords.x, coords.y, coords.z + zOffset, "ID: "..GetPlayerServerId(id))
                end
            end
        else
            Citizen.Wait(500)
        end
    end
end)

RegisterCommand("mostrarid", function()
    mostrarIDs = not mostrarIDs
    TriggerEvent("chat:addMessage", {
        args = { mostrarIDs and "^2[ID]" or "^1[ID]", mostrarIDs and "IDs ativados." or "IDs desativados." }
    })
end)
