if GetResourceState("es_extended") ~= "missing" then
    ESX = exports["es_extended"]:getSharedObject()
elseif GetResourceState("qbcore") ~= "missing" then
    QBCore = exports['qb-core']:GetCoreObject()
end
  
RegisterServerEvent('oMine:AddReward')
AddEventHandler('oMine:AddReward', function(coords)
    if GetResourceState("es_extended") ~= "missing" then
        local xPlayer = ESX.GetPlayerFromId(source)
        if #(GetEntityCoords(GetPlayerPed(source)) - coords) < 10.0 then 
            xPlayer.addMoney(oMine.reward)
        end
    elseif GetResourceState("qb-core") ~= "missing" then
        local xPlayer = QBCore.Functions.GetPlayer(source)
        if #(GetEntityCoords(GetPlayerPed(source)) - coords) < 10.0 then 
            xPlayer.Functions.AddMoney('cash', oMine.reward)
        end
    end
end)  