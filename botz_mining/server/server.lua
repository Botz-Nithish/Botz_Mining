ESX = exports["es_extended"]:getSharedObject()



lib.callback.register('botz_mining:minedrock', function(source)
    local roll = math.random()
    local cumulative = 0.0
    local selectedItem = nil

    for _, reward in ipairs(Config.rewards) do
        cumulative = cumulative + reward.probability
        if roll <= cumulative then
            selectedItem = reward.item
            break
        end
    end

    if not selectedItem then
        selectedItem = 'rock' 
    end

    local success, response = exports.ox_inventory:AddItem(source, selectedItem, Config.rock_count)
    if success then
        return 0
    else
        return 1
    end
end)

ESX.RegisterServerCallback('smelting:getInventory', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    cb(xPlayer.getInventory())
end)

RegisterServerEvent("botz_mining:smelt_start", function(item)
    local src = source
    local items = exports.ox_inventory:Items()
    local data = Config.SmeltConversion[item]
    if not data then return end

    local inputLabel = items[item] and items[item].label or item
    local outputLabel = items[data.converting_to] and items[data.converting_to].label or data.converting_to

    local hasItem = exports.ox_inventory:Search(src, 'count', item)
    if hasItem < data.conversion_count then
        TriggerClientEvent("botz_mining:smelt_notify", src, "Not enough " .. inputLabel, "error")
        return
    end

    local removed = exports.ox_inventory:RemoveItem(src, item, data.conversion_count)
    if not removed then
        TriggerClientEvent("botz_mining:smelt_notify", src, "Failed to remove " .. inputLabel, "error")
        return
    end

    TriggerClientEvent("botz_mining:smelt_progress", src, 5000, "Smelting " .. inputLabel)

    Wait(5000)

    local added = exports.ox_inventory:AddItem(src, data.converting_to, data.converting_to_count)
    if not added then
        TriggerClientEvent("botz_mining:smelt_notify", src, "Failed to add " .. outputLabel, "error")
        return
    end

    TriggerClientEvent("botz_mining:smelt_notify", src, "Received " .. data.converting_to_count .. "x " .. outputLabel, "success")
end)


RegisterServerEvent("botz_mining:washing_start", function(item)
    local src = source
    local items = exports.ox_inventory:Items()
    local data = Config.WashConversion[item]
    if not data then return end

    local inputLabel = items[item] and items[item].label or item
    local outputLabel = items[data.converting_to] and items[data.converting_to].label or data.converting_to
    local hasItem = exports.ox_inventory:Search(src, 'count', item)

    if hasItem < data.conversion_count then
        TriggerClientEvent("botz_mining:washing_notify", src, "Not enough " .. inputLabel, "error")
        return
    end

    local removed = exports.ox_inventory:RemoveItem(src, item, data.conversion_count)
    if not removed then
        TriggerClientEvent("botz_mining:washing_notify", src, "Failed to remove items", "error")
        return
    end

    TriggerClientEvent("botz_mining:washing_progress", src, 5000, "Washing " .. inputLabel)

    Wait(5000)

    local added = exports.ox_inventory:AddItem(src, data.converting_to, data.converting_to_count)
    if not added then
        TriggerClientEvent("botz_mining:washing_notify", src, "Failed to add " .. outputLabel, "error")
        return
    end

    TriggerClientEvent("botz_mining:washing_notify", src, "Received " .. data.converting_to_count .. "x " .. outputLabel, "success")
end)
