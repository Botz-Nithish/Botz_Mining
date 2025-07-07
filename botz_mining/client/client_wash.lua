local washing = false
ESX = exports["es_extended"]:getSharedObject()

-- Register ox_target washing zones
CreateThread(function()
    for _, data in pairs(Config.WashingZone) do
        local zoneData = data.zone
        exports.ox_target:addBoxZone({
            coords = zoneData.coords,
            size = zoneData.size,
            rotation = zoneData.rotation,
            debug = Config.debug,
            drawSprite = Config.debug,
            options = {
                {
                    name = 'wash_menu_' .. data.num,
                    icon = 'fa-solid fa-water',
                    label = 'Open Washing Menu',
                    onSelect = function()
                        OpenWashingContext()
                    end,
                },
            },
        })
    end
end)

-- Open dynamic ox_lib washing context menu
function OpenWashingContext()
    local options = {}

    -- Get all items from ox_inventory
    local oxItems = exports.ox_inventory:Items()

    for itemName, data in pairs(Config.WashConversion) do
        local inputItem = oxItems[itemName]
        local outputItem = oxItems[data.converting_to]

        -- If item exists in ox inventory, use label; otherwise, fallback to itemName
        local inputLabel = inputItem and inputItem.label or ("Unknown (%s)"):format(itemName)
        local outputLabel = outputItem and outputItem.label or ("Unknown (%s)"):format(data.converting_to)
        local desc = data.desc or ("Convert " .. inputLabel)

        table.insert(options, {
            title = "Wash " .. inputLabel,
            description = desc .. (" (%dx %s → %dx %s)"):format(
                data.conversion_count,
                inputLabel,
                data.converting_to_count,
                outputLabel
            ),
            icon = "fa-solid fa-droplet",
            onSelect = function()
                TriggerServerEvent("botz_mining:washing_start", itemName)
            end
        })
    end

    lib.registerContext({
        id = 'wash_context_menu',
        title = 'Washing Station',
        options = options
    })

    lib.showContext('wash_context_menu')
end


-- Notifications
RegisterNetEvent('botz_mining:washing_notify', function(text, type)
    lib.notify({ title = 'Washing', description = text, type = type or 'inform' })
end)

-- Progress + animation
RegisterNetEvent('botz_mining:washing_progress', function(time, label)
    local ped = PlayerPedId()
    washing = true

    TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_BUM_WASH', 0, true)

    lib.progressCircle({
        duration = time,
        label = label,
        position = 'bottom',
        useWhileDead = false,
        canCancel = false,
        disable = { move = true, car = true, combat = true }
    })

    ClearPedTasks(ped)
    washing = false
end)
