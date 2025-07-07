



Config = {}


Config.rock_count = 1
Config.ShowBlips = true -- global toggle for blips
Config.rewards = { --These are the rewards for the 1st step that is mining the ores these are based on probability
    {
        item = 'mining_gold_ore',
        probability = 0.20
    },
    {
        item = 'mining_silver_ore',
        probability = 0.20
    },
    {
        item = 'mining_steel_ore',
        probability = 0.20
    },
    {
        item = 'mining_copper_ore',
        probability = 0.20
    },
    {
        item = 'mining_iron_ore',
        probability = 0.20
    },--add more as you want
}


Config.MiningZone = { -- You can add how much ever as you want increase the zoneindex by 1 each time.
    {
        zoneindex = 1,
        freezepedat = vec4(3021.7681, 2782.5256, 54.0028, 299.1118), --The player will freeze at this position this is to ensure that a player cant use 2 zones at a time
        targetzone = { -- The location  where the zone is located
            coords = vec3(3023.0, 2783.0, 53.65),
            size = vec3(1, 1, 1),
            rotation = 25.0,
        },
        SphereZone = { 
            { -- These are the zones where the players should aim! add as much as you want just increement the number by 1
                number = 1,
                coords = vec3(3023.9, 2782.6, 54.2),
                radius = 0.25,
            },
            {
                number = 2,
                coords = vec3(3023.9, 2782.6, 54.2),
                radius = 0.25,
            },
            {
                number = 3,
                coords = vec3(3022.8, 2783.45, 53.65),
                radius = 0.25,
            },
            {
                number = 4,
                coords = vec3(3023.15, 2782.1, 53.65),
                radius = 0.25,
            },
            {
                number = 5,
                coords = vec3(3024.0, 2783.5, 54.5),
                radius = 0.25,
            },
        }
    },
    {
        zoneindex = 2,
        freezepedat = vec4(3018.0986, 2794.8232, 55.3636, 300.5585),
        targetzone = {
            coords = vec3(3019.0, 2795.0, 55.0),
            size = vec3(1, 1, 2),
            rotation = 15.0,
        },
        SphereZone = { -- Ensure this is an array and not nil
            {
                number = 1,
                coords = vec3(3019.2, 2795.1, 55.3),
                radius = 0.2,
            },
            {
                number = 2,
                coords = vec3(3019.5, 2794.9, 56.0),
                radius = 0.2,
            },
            
        }
    }, -- add more!
}






Config.SmeltConversion={  --This is The 3rd Step From washing -> Smelting
    ['iron'] = {
        conversion_count=4, --How much washed stone needed
        converting_to = 'mining_iron_ingot', -- The item name of the washed stone
        converting_to_count = 1, --How much item should be recieved for each conversion_count
        desc = 'Testing', --BETA i dont think i have used this
    },
    ['steel'] = {
        conversion_count=4,
        converting_to = 'mining_steel_ingot',
        converting_to_count = 1,
        desc = 'Testing',
    },
    ['gold'] = {
        conversion_count=4,
        converting_to = 'mining_gold_ingot',
        converting_to_count = 1,
        desc = 'Testing',
    },
    ['silver'] = {
        conversion_count=4,
        converting_to = 'mining_silver_ingot',
        converting_to_count = 1,
        desc = 'Testing',
    },
    ['copper'] = {
        conversion_count=4,
        converting_to = 'mining_copper_ingot',
        desc = 'Testing',
        converting_to_count = 1,
    }--add more as you want
}


Config.SmeltingZone={
    {
        num = 1,
        zone = {
            name = "smelt_1",
            coords = vec3(1086.5, -2004.0, 31.0),
            size = vec3(3.5, 4.5, 2.5),
            rotation = 320.0,
        },

    },
    {
        num =2,
        zone = {
            name = "smelt_2",
            coords = vec3(1111.0, -2009.0, 31.0),
            size = vec3(7.5, 6.5, 4.5),
            rotation = 325.0,
        },
    }
}


Config.WashingZone = {
    {
        num = 1,
        zone = {
            name = "water_zone",
            coords = vec3(1969.0, 542.0, 161.0),
            size = vec3(13.0, 43, 5),
            rotation = 0.0,
        },

    },
    --More can be added just increement the num by 1 each time you put new zone
}

Config.WashConversion={ --Similar to Smelt conversion
    ['mining_iron_ore'] = {
        conversion_count=4,
        converting_to = 'iron',
        converting_to_count = 1,
        desc = 'Testing',
    },
    ['mining_steel_ore'] = {
        conversion_count=4,
        converting_to = 'steel',
        converting_to_count = 1,
        desc = 'Testing',
    },
    ['mining_gold_ore'] = {
        conversion_count=4,
        converting_to = 'gold',
        converting_to_count = 1,
        desc = 'Testing',
    },
    ['mining_silver_ore'] = {
        conversion_count=4,
        converting_to = 'silver',
        converting_to_count = 1,
        desc = 'Testing',
    },
    ['mining_copper_ore'] = {
        conversion_count=4,
        converting_to = 'copper',
        desc = 'Testing',
        converting_to_count = 1,
    }
}

Config.blips = { --These are the Blips for each step
    mining = {
        {
            coords = vector3(2951.28, 2781.91, 40.36),
            radius = 80.0,
            sprite = 85,
            color = 5,
            scale = 1.1,
            label = "Mining Area",
        },
        -- Add more
    },
    smelting = {
        {
            coords = vector3(1086.5, -2004.0, 31.0),
            sprite = 618,
            color = 43,
            scale = 0.85,
            label = "Smelting Zone 1",
        },
        {
            coords = vector3(1111.0, -2009.0, 31.0),
            sprite = 618,
            color = 43,
            scale = 0.85,
            label = "Smelting Zone 2",
        },
        -- Add more smelting blips here
    },
    washing = {
        {
            coords = vector3(1963.3740, 549.9418, 161.6142),
            sprite = 605,
            color = 29,
            scale = 0.85,
            label = "Washing Zone",
        },
        -- Add more washing blips here
    }
}

Config.ShowBlip_Zone = {
    {
        name = "MINING_ZONE",
        coords = vec3(2970.0, 2768.0, 41.0),
        radius = 267.0,
    },
    
}
