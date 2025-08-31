local washing = false
local Bridge = exports['community_bridge']:Bridge()

-- Register ox_target zones
CreateThread(function()
    for _, data in pairs(Config.SmeltingZone) do
        local zoneData = data.zone
        Bridge.Target.AddBoxZone(
            'smelt_menu_' .. data.num,
            zoneData.coords,
            zoneData.size,
            zoneData.rotation,
            Config.debug,
            Config.debug,
            {
                {
                    name = 'smelt_menu_' .. data.num,
                    icon = 'fa-solid fa-fire',
                    label = 'Open Smelting Menu',
                    onSelect = function()
                        OpenSmeltContext()
                    end,
                },
            }
        )
    end
end)

-- Open dynamic ox_lib context menu
function OpenSmeltContext()
    local options = {}

    for itemName, data in pairs(Config.SmeltConversion) do
        local inputLabel = data.input_label or itemName
        local outputLabel = data.output_label or data.converting_to

        table.insert(options, {
            title = "Smelt " .. inputLabel,
            description = ("Convert %dx %s to %dx %s"):format(
                data.conversion_count,
                inputLabel,
                data.converting_to_count,
                outputLabel
            ),
            icon = "fa-solid fa-recycle",
            onSelect = function()
                TriggerServerEvent("botz_mining:smelt_start", itemName)
            end
        })
    end

    lib.registerContext({
        id = 'smelt_context_menu',
        title = 'Smelting Station',
        options = options
    })

    lib.showContext('smelt_context_menu')
end



RegisterNetEvent('botz_mining:smelt_notify', function(text, type)
    lib.notify({ title = 'Smelting', description = text, type = type or 'inform' })
end)

RegisterNetEvent('botz_mining:smelt_progress', function(time, label)
    local playerPed = PlayerPedId()
    washing = true
    TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_CONST_DRILL', 0, true)
    lib.progressCircle({
        duration = time,
        label = label,
        position = 'bottom',
        useWhileDead = false,
        canCancel = false,
        disable = { move = true, car = true, combat = true }
    })
    ClearPedTasks(playerPed)
    washing = false
end)
