TAH.SHOP_PISTOL = 1 -- Pistols, Magnums, Akimbos
TAH.SHOP_MANUAL = 2 -- Shotguns and snipers (some are auto but idc)
TAH.SHOP_LIGHT = 3 -- Machine pistols, SMGs, Sporters
TAH.SHOP_RIFLE = 4 -- ARs, BRs, DMRs
TAH.SHOP_HEAVY = 5 -- MGs, launchers
TAH.SHOP_SUPPLY = 6 -- grenades, launcher ammo
TAH.SHOP_SPECIAL = 7 -- Not part of the normal spawn pool

function TAH:GetPlayerStartingToken(ply)
    return 5
end

TAH.ShopTierToGrade = {
    ["0Exotic"] = 5,
    ["1Elite"] = 5,
    ["2Operator"] = 4,
    ["3Security"] = 3,
    ["4Consumer"] = 2,
    ["5Value"] = 1,
}

TAH.ShopRoundInfo = {
    [1] = {
        grade_weight = {
            [5] = 0,
            [4] = 0,
            [3] = 10,
            [2] = 50,
            [1] = 40,
        },
        category_weight = {
            [TAH.SHOP_PISTOL] = 35,
            [TAH.SHOP_MANUAL] = 35,
            [TAH.SHOP_LIGHT] = 30,
        },
    },
    [2] = {
        grade_weight = {
            [5] = 0,
            [4] = 10,
            [3] = 25,
            [2] = 45,
            [1] = 20,
        },
        category_weight = {
            [TAH.SHOP_PISTOL] = 25,
            [TAH.SHOP_MANUAL] = 25,
            [TAH.SHOP_LIGHT] = 25,
            [TAH.SHOP_RIFLE] = 25,
        },
    },
    [3] = {
        grade_weight = {
            [5] = 5,
            [4] = 25,
            [3] = 50,
            [2] = 20,
            [1] = 0,
        },
        category_weight = {
            [TAH.SHOP_PISTOL] = 15,
            [TAH.SHOP_MANUAL] = 15,
            [TAH.SHOP_LIGHT] = 30,
            [TAH.SHOP_RIFLE] = 35,
            [TAH.SHOP_HEAVY] = 5,
        },
    },
    [4] = {
        grade_weight = {
            [5] = 20,
            [4] = 30,
            [3] = 50,
            [2] = 0,
            [1] = 0,
        },
        category_weight = {
            [TAH.SHOP_PISTOL] = 15,
            [TAH.SHOP_MANUAL] = 15,
            [TAH.SHOP_LIGHT] = 30,
            [TAH.SHOP_RIFLE] = 35,
            [TAH.SHOP_HEAVY] = 5,
        },
    },
    [5] = {
        grade_weight = {
            [5] = 30,
            [4] = 50,
            [3] = 20,
            [2] = 0,
            [1] = 0,
        },
        category_weight = {
            [TAH.SHOP_PISTOL] = 10,
            [TAH.SHOP_MANUAL] = 10,
            [TAH.SHOP_LIGHT] = 30,
            [TAH.SHOP_RIFLE] = 40,
            [TAH.SHOP_HEAVY] = 10,
        },
    },
}

TAH.ShopSubCatToCat = {
    ["1Pistol"] = TAH.SHOP_PISTOL,
    ["2Magnum Pistol"] = TAH.SHOP_PISTOL,
    ["3Machine Pistol"] = TAH.SHOP_LIGHT,
    ["3Akimbo"] = TAH.SHOP_PISTOL,
    ["3Submachine Gun"] = TAH.SHOP_LIGHT,
    ["4Assault Rifle"] = TAH.SHOP_RIFLE,
    ["5Battle Rifle"] = TAH.SHOP_RIFLE,
    ["5Machine Gun"] = TAH.SHOP_HEAVY,
    ["5Shotgun"] = TAH.SHOP_MANUAL,
    ["5Sporter"] = TAH.SHOP_LIGHT,
    ["6Marksman Rifle"] = TAH.SHOP_RIFLE,
    ["7Sniper Rifle"] = TAH.SHOP_MANUAL,
    -- ["6Launcher"] = TAH.SHOP_HEAVY,
}

TAH.ShopSubCatToPrice = {
    ["1Pistol"] = {
        ["0Exotic"] = 7,
        ["1Elite"] = 7,
        ["2Operator"] = 5,
        ["3Security"] = 3,
        ["4Consumer"] = 2,
        ["5Value"] = 1,
    },
    ["2Magnum Pistol"] = {
        ["0Exotic"] = 9,
        ["1Elite"] = 9,
        ["2Operator"] = 7,
        ["3Security"] = 5,
        ["4Consumer"] = 4,
        ["5Value"] = 2,
    },
    ["3Machine Pistol"] = {
        ["0Exotic"] = 10,
        ["1Elite"] = 10,
        ["2Operator"] = 8,
        ["3Security"] = 6,
        ["4Consumer"] = 5,
        ["5Value"] = 4,
    },
    ["3Akimbo"] = {
        ["0Exotic"] = 8,
        ["1Elite"] = 8,
        ["2Operator"] = 6,
        ["3Security"] = 4,
        ["4Consumer"] = 3,
        ["5Value"] = 2,
    },
    ["3Submachine Gun"] = {
        ["0Exotic"] = 13,
        ["1Elite"] = 13,
        ["2Operator"] = 11,
        ["3Security"] = 9,
        ["4Consumer"] = 7,
        ["5Value"] = 5,
    },
    ["4Assault Rifle"] = {
        ["0Exotic"] = 15,
        ["1Elite"] = 15,
        ["2Operator"] = 13,
        ["3Security"] = 11,
        ["4Consumer"] = 9,
        ["5Value"] = 7,
    },
    ["5Battle Rifle"] = {
        ["0Exotic"] = 15,
        ["1Elite"] = 15,
        ["2Operator"] = 13,
        ["3Security"] = 11,
        ["4Consumer"] = 9,
        ["5Value"] = 7,
    },
    ["5Machine Gun"] = {
        ["0Exotic"] = 16,
        ["1Elite"] = 16,
        ["2Operator"] = 14,
        ["3Security"] = 12,
        ["4Consumer"] = 10,
        ["5Value"] = 8,
    },
    ["5Shotgun"] = {
        ["0Exotic"] = 13,
        ["1Elite"] = 13,
        ["2Operator"] = 11,
        ["3Security"] = 9,
        ["4Consumer"] = 7,
        ["5Value"] = 5,
    },
    ["5Sporter"] = {
        ["0Exotic"] = 11,
        ["1Elite"] = 11,
        ["2Operator"] = 9,
        ["3Security"] = 7,
        ["4Consumer"] = 5,
        ["5Value"] = 4,
    },
    ["6Marksman Rifle"] = {
        ["0Exotic"] = 12,
        ["1Elite"] = 12,
        ["2Operator"] = 10,
        ["3Security"] = 7,
        ["4Consumer"] = 5,
        ["5Value"] = 2,
    },
    ["7Sniper Rifle"] = {
        ["0Exotic"] = 9,
        ["1Elite"] = 9,
        ["2Operator"] = 6,
        ["3Security"] = 4,
        ["4Consumer"] = 2,
        ["5Value"] = 2,
    },
}

TAH.ShopBonus = {
    [1] = {
        "weapon_dz_healthshot",
    },
    [2] = {
        "dz_armor_kevlar_helmet",
    },
    [3] = {
        "dz_armor_heavy_ct",
    },
}

TAH.ShopDefaults = {
    ["tacrp_sd_contender"] = {cat = TAH.SHOP_PISTOL, cost = 2, grade = 1, weight = 100},
    ["tacrp_sd_gyrojet"] = {cat = TAH.SHOP_PISTOL, cost = 6, grade = 3, weight = 100},

    ["tacrp_m320"] = {cat = TAH.SHOP_HEAVY, cost = 8, grade = 3, weight = 50},
    ["tacrp_pa_m79"] = {cat = TAH.SHOP_HEAVY, cost = 8, grade = 3, weight = 25},
    ["tacrp_h_jdj"] = {cat = TAH.SHOP_HEAVY, cost = 6, grade = 3, weight = 25},
    ["tacrp_rpg7"] = {cat = TAH.SHOP_HEAVY, cost = 10, grade = 4, weight = 25},
    ["tacrp_io_chinalake"] = {cat = TAH.SHOP_HEAVY, cost = 12, grade = 4, weight = 25},
    ["tacrp_h_smaw"] = {cat = TAH.SHOP_HEAVY, cost = 12, grade = 5, weight = 25},
    ["tacrp_h_xm25"] = {cat = TAH.SHOP_HEAVY, cost = 16, grade = 5, weight = 25},
    ["tacrp_pa_m202"] = {cat = TAH.SHOP_HEAVY, cost = 16, grade = 5, weight = 25},

    ["tacrp_nade_frag"] = {cat = TAH.SHOP_SUPPLY, nodefaultclip = true, cost = 1, weight = 100, ammo_type = "grenade", ammo_count = 2, quicknade = "frag",},
    ["tacrp_nade_flashbang"] = {cat = TAH.SHOP_SUPPLY, nodefaultclip = true, cost = 1, weight = 100, ammo_type = "ti_flashbang", ammo_count = 2, quicknade = "flashbang",},
    ["tacrp_nade_smoke"] = {cat = TAH.SHOP_SUPPLY, nodefaultclip = true, cost = 1, weight = 100, ammo_type = "ti_smoke", ammo_count = 2, quicknade = "smoke",},
    ["tacrp_nade_gas"] = {cat = TAH.SHOP_SUPPLY, nodefaultclip = true, cost = 1, weight = 75, ammo_type = "ti_gas", ammo_count = 2, quicknade = "gas",},
    ["tacrp_nade_heal"] = {cat = TAH.SHOP_SUPPLY, nodefaultclip = true, cost = 1, weight = 75, ammo_type = "ti_heal", ammo_count = 2, quicknade = "heal",},
    ["tacrp_nade_thermite"] = {cat = TAH.SHOP_SUPPLY, nodefaultclip = true, cost = 1, weight = 75, ammo_type = "ti_thermite", ammo_count = 2, quicknade = "thermite",},
    ["tacrp_nade_charge"] = {cat = TAH.SHOP_SUPPLY, nodefaultclip = true, cost = 1, weight = 25, ammo_type = "ti_breach", ammo_count = 5, quicknade = "charge",},
    ["weapon_dz_bumpmine"] = {cat = TAH.SHOP_SUPPLY, nodefaultclip = true, ammo_type = "dz_bumpmine", ammo_count = 3, cost = 1, weight = 25, quicknade = "dz_bumpmine",},

    ["!smg1_grenade"] = {cat = TAH.SHOP_SUPPLY, cost = 1, weight = 50, ammo_type = "smg1_grenade", ammo_count = 3, icon = Material("entities/item_ammo_smg1_grenade.png"),
        printname = "SMG Grenades",
        desc = "Ammunition for grenade launchers."
    },
    ["!rpg_round"] = {cat = TAH.SHOP_SUPPLY, cost = 1, weight = 25, ammo_type = "rpg_round", ammo_count = 2, icon = Material("entities/item_rpg_round.png"),
        printname = "RPG Rounds",
        desc = "Ammunition for rocket launchers."
    },

    ["weapon_dz_healthshot"] = {cat = TAH.SHOP_SPECIAL, nodefaultclip = true, ammo_type = "dz_healthshot", ammo_count = 1, cost = 1, weight = 100},
    ["dz_armor_kevlar_helmet"] = {cat = TAH.SHOP_SPECIAL, cost = 2, weight = 25, printname = "Kevlar & Helmet",
        desc = "Body armor and helmet reduces incoming damage until it runs out."
    },
    ["dz_armor_heavy_ct"] = {cat = TAH.SHOP_SPECIAL, cost = 20, weight = 25, printname = "Heavy Assault Suit",
    desc = "Heavy armor reduces incoming damage significantly, but reduces mobility and prevents the usage of rifles."
},
}

TAH.ShopItems = TAH.ShopItems or {}
TAH.ShopLookup = TAH.ShopLookup or {}
TAH.Shop_Cache = TAH.Shop_Cache or {}

function TAH:PopulateShop()
    TAH.ShopItems = table.Copy(TAH.ShopDefaults)
    TAH.ShopLookup = {}
    for _, class in pairs(TacRP.GetWeaponList()) do
        if TAH.ShopItems[class] then continue end -- skip if already defined in defaults
        local wep = weapons.Get(class)
        local grade = TAH.ShopTierToGrade[wep.SubCatTier]
        local cat = TAH.ShopSubCatToCat[wep.SubCatType]
        if cat and grade then
            TAH.ShopItems[class] = {cat = cat, cost = TAH.ShopSubCatToPrice[wep.SubCatType][wep.SubCatTier], grade = grade, weight = 100}
        end
    end

    for class, info in pairs(TAH.ShopItems) do
        local grade = info.grade or 1
        TAH.ShopLookup[info.cat] = TAH.ShopLookup[info.cat] or {}
        TAH.ShopLookup[info.cat][grade] = TAH.ShopLookup[info.cat][grade] or {}
        table.insert(TAH.ShopLookup[info.cat][grade], class)
    end
end
hook.Add("InitPostEntity", "TAH_Shop", function()
    TAH:PopulateShop()
end)

function TAH:WeightedRandom(tbl)
    local weight = 0
    for k, v in pairs(tbl) do
        weight = weight + v
    end

    local rng = math.random(weight)
    for k, v in pairs(tbl) do
        rng = rng - v
        if rng <= 0 then
            return k
        end
    end
end

function TAH:RollShopForRound(round, amt)
    amt = amt or 1
    round = round or self:GetCurrentRound()

    local results = {}
    for i = 1, amt do
        local cat, grade = self:WeightedRandom(self.ShopRoundInfo[round].category_weight), self:WeightedRandom(self.ShopRoundInfo[round].grade_weight)
        local class = TAH:RollShopCategory(cat, grade, results)
        results[class] = true
    end
    return table.GetKeys(results)
end

function TAH:RollShopCategory(cat, grade, exclude)
    exclude = exclude or {}
    local tbl = table.Copy(TAH.ShopLookup[cat][grade])
    local weight = 0
    for i, class in ipairs(tbl) do
        if exclude[class] then
            table.remove(tbl, i)
            continue
        end
        weight = weight + TAH.ShopItems[class].weight
    end

    local rng = math.random(weight)
    for j, class in ipairs(tbl) do
        rng = rng - (TAH.ShopItems[class].weight or 0)
        if rng <= 0 then
            return class
        end
    end
end

if SERVER then
    util.AddNetworkString("tah_shop")

    net.Receive("tah_shop", function(len, ply)
        local shop = net.ReadEntity()

        local class = net.ReadString()
        local entry = TAH.ShopItems[class]
        if not shop:GetActive() or not shop.Items or not table.HasValue(shop.Items, class) then return end

        if TAH:GetTokens(ply) < entry.cost then return end

        TAH:AddTokens(ply, -entry.cost)

        if string.Left(class, 1) == "!" then
            -- does not give an entity
            TAH:GiveItem(ply, entry)
        else
            TAH:GiveItem(ply, entry, class)
        end

        -- TODO reroll shop?
    end)
elseif CLIENT then
    net.Receive("tah_shop", function()
        local shop = net.ReadEntity()
        local entries = {}
        for i = 1, net.ReadUInt(4) do
            table.insert(entries, net.ReadString())
        end
        shop.Visited = true

        local frame = vgui.Create("TAHShop")
        frame:SetShopEntity(shop)
        frame:SetItems(entries)
        frame:Center()
        frame:MakePopup()
    end)
end