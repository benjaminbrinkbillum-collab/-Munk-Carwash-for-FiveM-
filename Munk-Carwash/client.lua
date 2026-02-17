if GetCurrentResourceName() ~= 'Munk-Carwash' then
    print('^1[ERROR]^7 Resource folder must be named ^3Munk-Carwash^7 for this script to work!')
    return
end
local spawnedNPCs = {}
local npcHomePositions = {}

local function spawnNPCs()
    for i, loc in ipairs(Config.Locations) do
        local modelName = Config.NPCModel
        local model = type(modelName) == 'string' and GetHashKey(modelName) or modelName
        RequestModel(model)
        local tries = 0
        while not HasModelLoaded(model) and tries < 1000 do Wait(10) tries = tries + 1 end
        if not HasModelLoaded(model) then
        else
            local coords = loc.coords or loc
            local heading = loc.heading or 0.0
            local ped = CreatePed(4, model, coords.x, coords.y, coords.z, heading, false, true)
            SetEntityInvincible(ped, true)
            SetBlockingOfNonTemporaryEvents(ped, true)
            SetEntityHeading(ped, heading)
            FreezeEntityPosition(ped, false)
            Wait(100)
            PlaceObjectOnGroundProperly(ped)
            spawnedNPCs[i] = ped
            npcHomePositions[ped] = {coords = coords, heading = heading}
        end
    end
end

CreateThread(function()
    spawnNPCs()
    
    for _, loc in ipairs(Config.Locations) do
        local coords = loc.coords or loc
        local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
        SetBlipSprite(blip, 100) -- Carwash icon
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.8)
        SetBlipColour(blip, 3)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(Config.Text[Config.Locale].blip)
        EndTextCommandSetBlipName(blip)
    end
        local lang = Config.Text[Config.Locale]
        exports.ox_target:addLocalEntity(spawnedNPCs, {
            {
                label = lang.basic_label,
                icon = 'fa-solid fa-soap',
                onSelect = function(data)
                    TriggerServerEvent('munk-carwash:tryWash', 'basic', data.entityLoc)
                end
            },
            Config.EnablePremium and {
                label = lang.premium_label,
                icon = 'fa-solid fa-gem',
                onSelect = function(data)
                    TriggerServerEvent('munk-carwash:tryWash', 'premium', data.entityLoc)
                end
            } or nil
        })
end)

RegisterNetEvent('munk-carwash:startWash', function(type, loc)
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh == 0 then
        TriggerServerEvent('munk-carwash:tryWashNotInVehicle')
        return
    end
    local npc = nil
    for _, p in pairs(spawnedNPCs) do
        if #(GetEntityCoords(p) - GetEntityCoords(ped)) < 10.0 then
            npc = p
            break
        end
    end
    if not npc then return end
    FreezeEntityPosition(npc, false)
    local vehCoords = GetEntityCoords(veh)
    local vehHeading = GetEntityHeading(veh)
    local vehCenter = GetEntityCoords(veh)
    local vehForward = GetEntityForwardVector(veh)
    local vehRight = vector3(-vehForward.y, vehForward.x, 0.0)
    local spots = {
        {pos = vehCenter + vehForward * 2.0, face = vehCenter}, -- front
        {pos = vehCenter - vehForward * 2.0, face = vehCenter}, -- rear
        {pos = vehCenter - vehRight * 2.0, face = vehCenter - vehRight * 3.0},   -- left (face slightly more toward car)
        {pos = vehCenter + vehRight * 2.0, face = vehCenter + vehRight * 3.0},   -- right (face slightly more toward car)
    }
    local cleanTime = math.floor(Config.WashTime / #spots)
    for i, spot in ipairs(spots) do
        TaskGoToCoordAnyMeans(npc, spot.pos.x, spot.pos.y, spot.pos.z, 1.0, 0, 0, 786603, 0xbf800000)
        local dist = #(GetEntityCoords(npc) - spot.pos)
        local t = 0
        while dist > 1.2 and t < 5000 do
            Wait(250)
            dist = #(GetEntityCoords(npc) - spot.pos)
            t = t + 250
        end
        -- Face the car center or slightly inside for sides
        local npcPos = GetEntityCoords(npc)
        local dx = spot.face.x - npcPos.x
        local dy = spot.face.y - npcPos.y
        local heading = math.deg(math.atan2(dx, dy)) + 180
        if heading < 0 then heading = heading + 360 end
        if heading >= 360 then heading = heading - 360 end
        SetEntityHeading(npc, heading)
        TaskStartScenarioInPlace(npc, 'WORLD_HUMAN_MAID_CLEAN', 0, true)
        Wait(cleanTime)
        ClearPedTasks(npc)
    end
    SetVehicleDirtLevel(veh, 0.0)
    WashDecalsFromVehicle(veh, 1.0)
    Wait(100)
    SetVehicleDirtLevel(veh, 0.0)
    if type == 'premium' then
        if SetVehicleEnveffScale then
            -- Apply a much stronger shine
            SetVehicleEnveffScale(veh, 2.0)
            -- Reapply a few times to ensure effect
            for i = 1, 3 do
                Wait(200)
                SetVehicleEnveffScale(veh, 2.0)
            end
            CreateThread(function()
                Wait(120000)
                SetVehicleEnveffScale(veh, 0.0)
            end)
        end
    end
    -- Walk NPC home, then freeze and notify
    local home = npcHomePositions[npc]
    if home then
        FreezeEntityPosition(npc, false)
        TaskGoToCoordAnyMeans(npc, home.coords.x, home.coords.y, home.coords.z, 1.0, 0, 0, 786603, 0xbf800000)
        local dist = #(GetEntityCoords(npc) - home.coords)
        local t = 0
        while dist > 1.2 and t < 10000 do
            Wait(250)
            dist = #(GetEntityCoords(npc) - home.coords)
            t = t + 250
        end
        SetEntityHeading(npc, home.heading)
        ClearPedTasks(npc)
        Wait(100)
        FreezeEntityPosition(npc, true)
        -- NPC says message to player as notification
        TriggerServerEvent('munk-carwash:notify', Config.Text[Config.Locale].car_clean, 'success')
    else
        FreezeEntityPosition(npc, true)
        Config.Notify(PlayerId(), 'Din bil er nu ren!', 'success')
    end
end)
