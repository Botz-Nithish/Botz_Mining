-- ESX = exports["es_extended"]:getSharedObject()
local Bridge = exports['community_bridge']:Bridge()


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
    if Config.debug then
        print('printing ITem:' .. selectedItem .. ' Rock: ' .. Config.rock_count)
    end
    
    local success = Bridge.Inventory.AddItem(source, selectedItem, Config.rock_count)
    if success then
        return 0
    else
        return 1
    end
end)

-- ESX.RegisterServerCallback('smelting:getInventory', function(source, cb)
--     local xPlayer = ESX.GetPlayerFromId(source)
--     cb(xPlayer.getInventory())
-- end)

RegisterServerEvent("botz_mining:smelt_start", function(item)
    local src = source
    local data = Config.SmeltConversion[item]
    if not data then return end

    -- Use labels from config
    local inputLabel = data.input_label or item
    local outputLabel = data.output_label or data.converting_to

    local hasItem =  Bridge.Inventory.GetItemCount(source, item)
    if hasItem < data.conversion_count then
        TriggerClientEvent("botz_mining:smelt_notify", src, "Not enough " .. inputLabel, "error")
        return
    end

    local removed = Bridge.Inventory.RemoveItem(src, item, data.conversion_count)
    if not removed then
        TriggerClientEvent("botz_mining:smelt_notify", src, "Failed to remove " .. inputLabel, "error")
        return
    end

    TriggerClientEvent("botz_mining:smelt_progress", src, 5000, "Smelting " .. inputLabel)

    Wait(5000)

    local added = Bridge.Inventory.AddItem(src, data.converting_to, data.converting_to_count)
    if not added then
        TriggerClientEvent("botz_mining:smelt_notify", src, "Failed to add " .. outputLabel, "error")
        return
    end

    TriggerClientEvent("botz_mining:smelt_notify", src, "Received " .. data.converting_to_count .. "x " .. outputLabel, "success")
end)



RegisterServerEvent("botz_mining:washing_start", function(item)
    local src = source
    local data = Config.WashConversion[item]
    if not data then return end

    local inputLabel = data.input_label or item
    local outputLabel = data.output_label or data.converting_to

    local hasItem =  Bridge.Inventory.GetItemCount(source, item)
    if hasItem < data.conversion_count then
        TriggerClientEvent("botz_mining:washing_notify", src, "Not enough " .. inputLabel, "error")
        return
    end

    local removed = Bridge.Inventory.RemoveItem(src, item, data.conversion_count)
    if not removed then
        TriggerClientEvent("botz_mining:washing_notify", src, "Failed to remove items", "error")
        return
    end

    TriggerClientEvent("botz_mining:washing_progress", src, 5000, "Washing " .. inputLabel)

    Wait(5000)

    local added = exports.Bridge.Inventory.AddItem(src, data.converting_to, data.converting_to_count)
    if not added then
        TriggerClientEvent("botz_mining:washing_notify", src, "Failed to add " .. outputLabel, "error")
        return
    end

    TriggerClientEvent("botz_mining:washing_notify", src, "Received " .. data.converting_to_count .. "x " .. outputLabel, "success")
end)


RegisterServerEvent('botz_mining:sellItem', function(itemName)
    local src = source
    local xPlayer = Bridge.Framework.GetPlayerIdentifier(src)
    local itemAmount = Bridge.Inventory.GetItemCount(source, itemName)
    if not Config.Sell_Shop[itemName] then return end
    if not itemAmount or itemAmount == 0 then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Sell Failed',
            description = 'You don’t have any ' .. itemName,
            type = 'error'
        })
        return
    end

    local price = Config.Sell_Shop[itemName] * itemAmount
    Bridge.Inventory.RemoveItem(src, itemName, itemAmount)
    Bridge.Framework.AddAccountBalance(src, "cash", price)
    TriggerClientEvent('ox_lib:notify', src, {
        title = 'Items Sold',
        description = ('You sold %d %s for $%d'):format(itemAmount, itemName, price),
        type = 'success'
    })
end)
