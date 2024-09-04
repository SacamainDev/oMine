local totalDuration = 30000
local scaleReductionInterval = 1500
local inMission = false
local props = {} 
local jtabbasseducayou = false
local hat = nil
local PickAxe = nil

CreateThread(function ()
    RequestModel(oMine.Pnj.model)
    while not HasModelLoaded(oMine.Pnj.model) do
        Citizen.Wait(100)
    end

    local npcPed = CreatePed(4, oMine.Pnj.model, oMine.Pnj.coords, false, false)
    SetEntityInvincible(npcPed, true)
    FreezeEntityPosition(npcPed, true)
    SetBlockingOfNonTemporaryEvents(npcPed, true)
    TaskStartScenarioInPlace(npcPed, "CODE_HUMAN_MEDIC_TIME_OF_DEATH", 0, true)
end)

exports['qb-target']:AddBoxZone("mine_zone", vector3(-595.04, 2091.48, 131.45), 2, 2, {
    name = "mine_zone",
    heading = 45,
    debugPoly = false,
    minZ = 130.45,
    maxZ = 135.45
}, {
    options = {
        {
            icon = 'fa-solid fa-check',
            label = oMine.startMine,
            action = function()
                startMining()
            end,
            canInteract = function()
                return not inMission
            end
        },
        {
            icon = 'fa-solid fa-check',
            label = oMine.EndMine,
            action = function()
                stopMining()
            end,
            canInteract = function()
                return inMission
            end
        }
    },
    distance = 3.0
})

function startMining()
    inMission = true
    local model = "ch_prop_drills_hat03x"
    local modelHash = GetHashKey(model)
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Citizen.Wait(100)
    end

    local Ped = PlayerPedId()
    hat = CreateObject(modelHash, GetEntityCoords(Ped), false, 0, false)
    SetEntityAsMissionEntity(hat, true, true)
    Wait(100)
    AttachEntityToEntity(hat, PlayerPedId(), GetPedBoneIndex(Ped, 31086), 0.12215069287765, 0.00014057222364616, 0.0037870789248155, 1.2029027216017e-14, 87.632234775355, -178.76583251066, true, true, false, true, 1, true)
    local propHash = GetHashKey('prop_mineshaft_door')
    local laporte = GetClosestObjectOfType(-595.04, 2091.48, 131.45, 30.0, propHash, false, false, false)
    Wait(100)
    if laporte ~= 0 then
        SetEntityAsMissionEntity(laporte, true, true)
        DeleteEntity(laporte)
    end

    local cayouHash = GetHashKey('h4_prop_rock_lrg_01')
    RequestModel(cayouHash)
    while not HasModelLoaded(cayouHash) do
        Wait(100)
    end

    local model = "prop_tool_pickaxe"
    local coords = vector3(0, 0, 0)
    local heading = 0.0
    local modelHash = GetHashKey(model)

    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Citizen.Wait(100)
    end

    PickAxe = CreateObject(modelHash, coords.x, coords.y, coords.z, false, 0, false)
    SetEntityHeading(PickAxe, heading)
    AttachEntityToEntity(PickAxe, Ped, GetPedBoneIndex(Ped, 57005), 0.09, -0.53, -0.22, 252.0, 180.0, 0.0, false, true, true, true, 0, true)

    for _, data in pairs(oMine.Cayoupos) do
        local cayou = CreateObject(cayouHash, data.coords.x, data.coords.y, data.coords.z, false, 0, false)
        SetEntityRotation(cayou, data.rotation.x, data.rotation.y, data.rotation.z, 2, true)
        FreezeEntityPosition(cayou, true)
        SetEntityMatrix(cayou, vector3(-0.000, 1.0, 0.0), vector3(1.0, 0.0, -0.00), vector3(0.0, 0.0, 2.50), vector3(data.coords.x, data.coords.y, data.coords.z))
        table.insert(props, cayou)
        exports['qb-target']:AddTargetEntity(cayou, {
            options = {
                {
                    icon = "fa-solid fa-person-digging",
                    label = oMine.MineRock,
                    action = function(entity)
                        local coords = GetEntityCoords(entity)
                        MinerCayou(cayou, coords)
                    end,
                    canInteract = function(entity)
                        local distance = #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(entity))
                        return distance < 2.5 and not jtabbasseducayou
                    end
                }
            },
            distance = 2.5
        })        
        
    end
end

function stopMining()
    inMission = false
    for _, prop in ipairs(props) do
        if DoesEntityExist(prop) then
            DeleteEntity(prop)
            DeleteEntity(PickAxe)
            DeleteEntity(hat)
        end
    end
    props = {}
end

function MinerCayou(cayou, sleepcallbae)
    jtabbasseducayou = true
    local Ped = PlayerPedId()
    local dict = "amb@world_human_hammering@male@base"
    local anim = "base"

    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(100)
    end

    if not DoesEntityExist(PickAxe) then 
        local model = "prop_tool_pickaxe"
        local coords = vector3(0, 0, 0)
        local heading = 0.0
        local modelHash = GetHashKey(model)
    
        RequestModel(modelHash)
        while not HasModelLoaded(modelHash) do
            Citizen.Wait(100)
        end
    
        PickAxe = CreateObject(modelHash, coords.x, coords.y, coords.z, false, 0, false)
        SetEntityHeading(PickAxe, heading)
        AttachEntityToEntity(PickAxe, Ped, GetPedBoneIndex(Ped, 57005), 0.09, -0.53, -0.22, 252.0, 180.0, 0.0, false, true, true, true, 0, true)
    end

    local startTime = GetGameTimer()
    local lastScaleReductionTime = startTime

    Citizen.CreateThread(function()
        while GetGameTimer() - startTime < totalDuration do
            Citizen.Wait(0)

            local currentTime = GetGameTimer()
            if currentTime - lastScaleReductionTime >= scaleReductionInterval then
                local scaleFactor = 1.0 - ((currentTime - startTime) / totalDuration) * 0.2

                local forward, right, up, position = GetEntityMatrix(cayou)
                forward = forward * scaleFactor
                right = right * scaleFactor
                up = up * scaleFactor
                SetEntityMatrix(cayou, forward, right, up, position)
                TaskPlayAnim(Ped, dict, anim, 8.0, -8.0, -1, 2, 0, false, false, false)
                lastScaleReductionTime = currentTime
            end
        end

        ClearPedTasks(Ped)
        DeleteEntity(PickAxe)
        DeleteEntity(cayou)
        jtabbasseducayou = false
        TriggerServerEvent("oMine:AddReward", sleepcallbae)
    end)
end