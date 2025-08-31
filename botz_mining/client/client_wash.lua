local washing = false
local Bridge = exports['community_bridge']:Bridge()

-- Register ox_target washing zones
CreateThread(function()
    for _, data in pairs(Config.WashingZone) do
        local zoneData = data.zone
        Bridge.Target.AddBoxZone(
            'wash_menu_' .. data.num,
            zoneData.coords,
            zoneData.size,
            zoneData.rotation,
            Config.debug,
            {
                {
                    name = 'wash_menu_' .. data.num,
                    icon = 'fa-solid fa-water',
                    label = 'Open Washing Menu',
                    onSelect = function()
                        OpenWashingContext()
                    end,
                },
            }
        )
    end
end)



function OpenWashingContext()
    local options = {}

    for itemName, data in pairs(Config.WashConversion) do
        local inputLabel = data.input_label or itemName
        local outputLabel = data.output_label or data.converting_to

        -- Dynamically generate the description
        local desc = ("Converts %dx %s into %dx %s"):format(
            data.conversion_count,
            inputLabel,
            data.converting_to_count,
            outputLabel
        )

        table.insert(options, {
            title = "Wash " .. inputLabel,
            description = desc,
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
