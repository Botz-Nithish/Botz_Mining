local Bridge = exports['community_bridge']:Bridge()

mining_zone = {}
local pickaxeObject 
local startmining_notif
local miningSphere


Citizen.CreateThread(function()
    for k, v in pairs(Config.MiningZone) do
        mining_zone[k] = Bridge.Target.AddBoxZone(
            "Mining_zone" .. k, -- name
            v.targetzone.coords, -- vector3
            v.targetzone.size, -- {x, y, z}
            v.targetzone.rotation, -- heading
            { -- options
                {
                    icon = "fas fa-pickaxe",
                    label = "Start Mining " .. k,
                    distance = 2.0,
                    onSelect = function()
                        if Config.debug then
                            print("Selected Zone: ",json.encode(v))
                        end
                        startMining(v)
                    end
                }
            },
            Config.debug -- debug
        )
    end
end)




function AttachPickaxe(playerPed)
    local model = `prop_tool_pickaxe`
    lib.requestModel(model, 100)
    pickaxeObject = CreateObject(model, GetEntityCoords(cache.ped), true, false, false)
    AttachEntityToEntity(pickaxeObject, cache.ped, GetPedBoneIndex(cache.ped, 57005), 0.09, 0.03, -0.02, -78.0, 13.0, 28.0, false, true, true, true, 0, true)
end

function DisattachPickaxe()
    if DoesEntityExist(pickaxeObject) then
        if Config.debug then
            print('entity does exist')
        end
        DetachEntity(pickaxeObject, true, true)
        DeleteEntity(pickaxeObject)
        pickaxeObject = nil
    end    
end

function startMining(data)
    startmining_notif = exports['glitch-notifications']:ShowNotification("Mining", "You should aim at the zone and left click. To Cancel Mining use /cancelmining in chat", 0, "#ffbf00")
    local playerPed = PlayerPedId()
    SetEntityHeading(playerPed, data.freezepedat.w)
    freezeplayer(playerPed)
    AttachPickaxe(playerPed)
    generateCircle(data)
    showCrosshair()
end


function generateCircle(data)
    local i = math.random(1,#data.SphereZone)
    local sphereData = data.SphereZone[i]
    miningSphere = lib.zones.sphere({
        coords = sphereData.coords,
        radius = sphereData.radius,
        debug = true,
        debugColour = vec4(0,255,0, 80),
    })
    playMining(data,miningSphere)
end

function freezeplayer(playerPed)
    FreezeEntityPosition(playerPed, true) --Freeze Player
    local currentWeapon = GetSelectedPedWeapon(cache.ped)
    RemoveWeaponFromPed(cache.ped, currentWeapon)
    DisablePlayerFiring(cache.ped, true)
end

function playMining(data, miningSphere)
    keybind = lib.addKeybind({
        name = 'respects',
        description = 'press F to pay respects',
        defaultKey = "E",
        onPressed = function(self)
            if Config.debug then
                print(('pressed %s (%s)'):format(self.currentKey, self.name))
            end
        end,
        onReleased = function(self)
            ToggleKeybind(false)
            lib.requestAnimDict('melee@hatchet@streamed_core', 100)
            TaskPlayAnim(cache.ped, 'melee@hatchet@streamed_core', 'plyr_rear_takedown_b', 8.0, -8.0, -1, 2, 0, false, false, false)
            local hit, _, hitCoords = lib.raycast.fromCamera(511, 4, 10)
            if hit and miningSphere:contains(hitCoords) then
                miningSphere:remove()
                local res = lib.callback.await('botz_mining:minedrock',false)
                if res == 0 then 
                lib.notify({ title = ' Mining', description = 'Mined Successful',position='top', type = 'success'})
            elseif res == 1 then
                lib.notify({ title = ' Mining', description = 'Inventory is full or error occured',position='top', type = 'warn' })
            end
                Wait(2500)
                ToggleKeybind(true)
                generateCircle(data)
            else
                lib.notify({ title = ' Mining', description = 'Aim at the Green Circle!',position='top', type = 'warn'})
                Wait(2500)
                ToggleKeybind(true)
            end
        end
    })
end

function ToggleKeybind(bool)
    if bool then keybind:disable(false) else keybind:disable(true) end
end


RegisterCommand("cancelmining", function()
    if miningSphere and miningSphere.remove then
        miningSphere:remove()
        miningSphere = nil
    end
    if lib.progressCircle({
        duration = 3000,
        position = 'bottom',
        useWhileDead = true,
        canCancel = false,
        disable = {
            car = true,
        },
    }) then 
        if Config.debug then
            print('Cancelling Mining')
        end
        DisattachPickaxe()    
        local playerPed = PlayerPedId()
        ClearPedTasksImmediately(playerPed)
        FreezeEntityPosition(playerPed, false)

        ToggleKeybind(false)
        DisablePlayerFiring(playerPed, false)
        SetPlayerCanDoDriveBy(PlayerId(), true)
        SetEntityInvincible(playerPed, false)
        EnableControlAction(0, 24, true)  -- Shoot
        EnableControlAction(0, 25, true)  -- Aim
        EnableControlAction(0, 140, true) -- Melee Light
        EnableControlAction(0, 141, true) -- Melee Heavy
        EnableControlAction(0, 142, true) -- Melee Alternate
    
    -- Re-equip weapon if needed
    SetCurrentPedWeapon(playerPed, GetSelectedPedWeapon(playerPed), true)
        if startmining_notif then
            exports['glitch-notifications']:RemoveNotification(startmining_notif)
            startmining_notif = nil
        end
        hideCrosshair() 
    else 
        lib.notify({ title = 'Mining', description = 'Try Cancelling Mining again',position='top', type = 'warn'})
    end

end, false)

function showCrosshair()
    -- NUI focus only for game controls, not the cursor
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(true)
    SendNUIMessage({ action = 'show' }) 
end

function hideCrosshair()
    SetNuiFocusKeepInput(false)
    SendNUIMessage({ action = 'hide' }) 
end

RegisterNUICallback('hide', function(data, cb)
    cb('ok') 
end)

RegisterNUICallback('show', function(data, cb)
    cb('ok') 
end)


CreateThread(function()
    if not Config.ShowBlips then return end

    for _, zone in pairs(Config.blips.mining) do
        local blip = AddBlipForCoord(zone.coords.x, zone.coords.y, zone.coords.z)
        SetBlipSprite(blip, zone.sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, zone.scale)
        SetBlipColour(blip, zone.color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(zone.label)
        EndTextCommandSetBlipName(blip)

        if zone.radius then
            local radiusBlip = AddBlipForRadius(zone.coords.x, zone.coords.y, zone.coords.z, zone.radius)
            SetBlipColour(radiusBlip, zone.color)
            SetBlipAlpha(radiusBlip, 75)
        end
    end

    -- Smelting Zones
    for _, zone in pairs(Config.blips.smelting) do
        local blip = AddBlipForCoord(zone.coords.x, zone.coords.y, zone.coords.z)
        SetBlipSprite(blip, zone.sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, zone.scale)
        SetBlipColour(blip, zone.color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(zone.label)
        EndTextCommandSetBlipName(blip)
    end

    -- Washing Zones
    for _, zone in pairs(Config.blips.washing) do
        local blip = AddBlipForCoord(zone.coords.x, zone.coords.y, zone.coords.z)
        SetBlipSprite(blip, zone.sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, zone.scale)
        SetBlipColour(blip, zone.color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(zone.label)
        EndTextCommandSetBlipName(blip)
    end
end)


local miningBlips = {}
local insideZone = false

-- Function to create mining blips dynamically
local function createMiningBlips()
    for _, data in ipairs(Config.MiningZone) do
        local coords = vec3(data.freezepedat.x, data.freezepedat.y, data.freezepedat.z)

        local blip = AddBlipForCoord(coords)
        SetBlipSprite(blip, 527)
        SetBlipScale(blip, 0.75)
        SetBlipColour(blip, 5)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Mining Zone")
        EndTextCommandSetBlipName(blip)

        table.insert(miningBlips, blip)
    end
end

-- Function to remove all created mining blips
local function removeMiningBlips()
    for _, blip in ipairs(miningBlips) do
        RemoveBlip(blip)
    end
    miningBlips = {}
end

-- Create Sphere Zones to trigger blip logic
CreateThread(function()
    for _, zone in ipairs(Config.ShowBlip_Zone) do
        lib.zones.sphere({
            coords = zone.coords,
            radius = zone.radius,
            debug = Config.Debug or false,
            onEnter = function()
                if not insideZone then
                    insideZone = true
                    createMiningBlips()
                end
            end,
            onExit = function()
                insideZone = false
                removeMiningBlips()
            end,
        })
    end
end)


SellShop = function()
    lib.RequestModel(Config.Sell_Ped.model)
    Sell_Ped = CreatePed(0, Config.Sell_Ped.model, Config.Sell_Ped.location, Config.Sell_Ped.heading, false, true)
    FreezeEntityPosition(Sell_Ped, true)
    SetBlockingOfNonTemporaryEvents(Sell_Ped, true)
    SetEntityInvincible(Sell_Ped, true)
    TaskStartScenarioInPlace(Sell_Ped, Config.Sell_Ped.scenario, 0, true) 
end

local function onEnterped(self)
    SellShop()
    exports.ox_target:addLocalEntity(Sell_Ped, {
        name = 'oilrig_trigger_ped',
        icon = self.target_icon,
        label = self.target_label,
        distance = 2,
        canInteract = function(entity, coords, distance)
            return IsPedOnFoot(cache.ped) and not IsPlayerDead(cache.ped)
        end,
        onSelect = function()
            TriggerEvent('botz_mining:openSellMenu') 
        end
    })
end



local function onExitped(self)
    DeleteEntity(Sell_Ped)
    exports.ox_target:removeLocalEntity(Sell_Ped, nil)
end
 
local points = lib.points.new({
    coords = Config.Sell_Ped.location,
    heading = Config.Sell_Ped.heading,
    distance = Config.Sell_Ped.distance,
    model = Config.Sell_Ped.model,
    scenario = Config.Sell_Ped.scenario,
    target_label = Config.Sell_Ped.target_label,
	target_icon = Config.Sell_Ped.target_icon,
    onEnter = onEnterped,
    onExit = onExitped,
})

RegisterNetEvent('botz_mining:openSellMenu', function()
    local sellOptions = {}

    for itemName, price  in pairs(Config.Sell_Shop) do
        local itemInfo = Bridge.Inventory.GetItemInfo(itemName)
        table.insert(sellOptions,{
            title = ('Sell %s'):format(itemInfo.label),
            description = ('Sell for $%s'):format(price),
            icon = 'dollar-sign',
            onSelect = function()
                TriggerServerEvent('botz_mining:sellItem', itemName)
            end
        })
    end
    lib.registerContext({
        id = 'sell_menu',
        title = 'Sell Items',
        options = sellOptions
    })

    lib.showContext('sell_menu')
end)