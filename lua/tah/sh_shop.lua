TAH.SHOP_PISTOL = 1 -- Pistols, Magnums, Akimbos
TAH.SHOP_MANUAL = 2 -- Shotguns and snipers (some are auto but idc)
TAH.SHOP_LIGHT = 3 -- Machine pistols, SMGs, Sporters
TAH.SHOP_RIFLE = 4 -- ARs, BRs, DMRs
TAH.SHOP_HEAVY = 5 -- MGs, launchers
TAH.SHOP_SUPPLY = 6 -- grenades, launcher ammo
TAH.SHOP_SPECIAL = 7 -- Not part of the normal spawn pool

function TAH:GetPlayerStartingToken(ply)
    local difficulty = TAH.ConVars["game_difficulty"]:GetInt()
    if difficulty == 0 then
        return 5
    elseif difficulty == 1 then
        return 3
    elseif difficulty == 2 then
        return 2
    end
end

TAH.ShopTierToGrade = {
    ["Exotic"] = 5,
    ["Elite"] = 5,
    ["Operator"] = 4,
    ["Security"] = 3,
    ["Consumer"] = 2,
    ["Value"] = 1,
}

TAH.ShopRoundInfo = {
    [1] = {
        grade_weight = {
            [5] = 0,
            [4] = 5,
            [3] = 10,
            [2] = 45,
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
            [5] = 5,
            [4] = 10,
            [3] = 20,
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
            [5] = 10,
            [4] = 25,
            [3] = 50,
            [2] = 15,
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
    ["Pistol"] = TAH.SHOP_PISTOL,
    ["Magnum Pistol"] = TAH.SHOP_PISTOL,
    ["Machine Pistol"] = TAH.SHOP_LIGHT,
    ["Akimbo"] = TAH.SHOP_PISTOL,
    ["Submachine Gun"] = TAH.SHOP_LIGHT,
    ["Assault Rifle"] = TAH.SHOP_RIFLE,
    ["Battle Rifle"] = TAH.SHOP_RIFLE,
    ["Machine Gun"] = TAH.SHOP_HEAVY,
    ["Shotgun"] = TAH.SHOP_MANUAL,
    ["Sporter"] = TAH.SHOP_LIGHT,
    ["Marksman Rifle"] = TAH.SHOP_RIFLE,
    ["Sniper Rifle"] = TAH.SHOP_MANUAL,
    -- ["Launcher"] = TAH.SHOP_HEAVY,
}

TAH.ShopSubCatToPrice = {
    ["Pistol"] = {
        ["Exotic"] = 8,
        ["Elite"] = 7,
        ["Operator"] = 5,
        ["Security"] = 3,
        ["Consumer"] = 2,
        ["Value"] = 1,
    },
    ["Magnum Pistol"] = {
        ["Exotic"] = 10,
        ["Elite"] = 9,
        ["Operator"] = 7,
        ["Security"] = 5,
        ["Consumer"] = 4,
        ["Value"] = 2,
    },
    ["Machine Pistol"] = {
        ["Exotic"] = 13,
        ["Elite"] = 12,
        ["Operator"] = 10,
        ["Security"] = 8,
        ["Consumer"] = 6,
        ["Value"] = 3,
    },
    ["Akimbo"] = {
        ["Exotic"] = 10,
        ["Elite"] = 9,
        ["Operator"] = 7,
        ["Security"] = 5,
        ["Consumer"] = 4,
        ["Value"] = 3,
    },
    ["Submachine Gun"] = {
        ["Exotic"] = 14,
        ["Elite"] = 13,
        ["Operator"] = 11,
        ["Security"] = 9,
        ["Consumer"] = 7,
        ["Value"] = 5,
    },
    ["Assault Rifle"] = {
        ["Exotic"] = 16,
        ["Elite"] = 15,
        ["Operator"] = 13,
        ["Security"] = 11,
        ["Consumer"] = 9,
        ["Value"] = 7,
    },
    ["Battle Rifle"] = {
        ["Exotic"] = 16,
        ["Elite"] = 15,
        ["Operator"] = 13,
        ["Security"] = 11,
        ["Consumer"] = 9,
        ["Value"] = 7,
    },
    ["Machine Gun"] = {
        ["Exotic"] = 19,
        ["Elite"] = 18,
        ["Operator"] = 16,
        ["Security"] = 14,
        ["Consumer"] = 12,
        ["Value"] = 10,
    },
    ["Shotgun"] = {
        ["Exotic"] = 15,
        ["Elite"] = 14,
        ["Operator"] = 12,
        ["Security"] = 9,
        ["Consumer"] = 4,
        ["Value"] = 3,
    },
    ["Sporter"] = {
        ["Exotic"] = 12,
        ["Elite"] = 11,
        ["Operator"] = 9,
        ["Security"] = 7,
        ["Consumer"] = 5,
        ["Value"] = 3,
    },
    ["Marksman Rifle"] = {
        ["Exotic"] = 15,
        ["Elite"] = 14,
        ["Operator"] = 11,
        ["Security"] = 7,
        ["Consumer"] = 5,
        ["Value"] = 2,
    },
    ["Sniper Rifle"] = {
        ["Exotic"] = 10,
        ["Elite"] = 9,
        ["Operator"] = 6,
        ["Security"] = 4,
        ["Consumer"] = 3,
        ["Value"] = 2,
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
    ["tacrp_nade_thermite"] = {cat = TAH.SHOP_SUPPLY, nodefaultclip = true, cost = 1, weight = 75, ammo_type = "ti_thermite", ammo_count = 2, quicknade = "thermite",},
    ["tacrp_nade_heal"] = {cat = TAH.SHOP_SUPPLY, nodefaultclip = true, cost = 3, weight = 25, ammo_type = "ti_heal", ammo_count = 1, quicknade = "heal",},
    ["tacrp_nade_charge"] = {cat = TAH.SHOP_SUPPLY, nodefaultclip = true, cost = 1, weight = 25, ammo_type = "ti_breach", ammo_count = 5, quicknade = "charge",},
    ["weapon_dz_bumpmine"] = {cat = TAH.SHOP_SUPPLY, nodefaultclip = true, ammo_type = "dz_bumpmine", ammo_count = 3, cost = 1, weight = 25, quicknade = "dz_bumpmine",},

    ["!smg1_grenade"] = {cat = TAH.SHOP_SUPPLY, cost = 1, weight = 25, ammo_type = "smg1_grenade", ammo_count = 5, icon = Material("entities/item_ammo_smg1_grenade.png"),
        printname = "SMG Grenades",
        desc = "Ammunition for grenade launchers."
    },
    ["!rpg_round"] = {cat = TAH.SHOP_SUPPLY, cost = 1, weight = 10, ammo_type = "rpg_round", ammo_count = 3, icon = Material("entities/item_rpg_round.png"),
        printname = "RPG Rounds",
        desc = "Ammunition for rocket launchers."
    },

    ["weapon_dz_healthshot"] = {cat = TAH.SHOP_SPECIAL, nodefaultclip = true, ammo_type = "dz_healthshot", ammo_count = 1, cost = 2, weight = 100},
    ["dz_armor_kevlar_helmet"] = {cat = TAH.SHOP_SPECIAL, cost = 3, weight = 25, printname = "Kevlar & Helmet",
        desc = "Body armor and helmet reduces incoming damage until it runs out."
    },
    ["dz_armor_heavy_ct"] = {cat = TAH.SHOP_SPECIAL, cost = 30, weight = 25, printname = "Heavy Assault Suit",
    desc = "Heavy armor reduces incoming damage significantly, but reduces mobility and prevents the usage of rifles."
},
}

TAH.ShopItems = TAH.ShopItems or {}
TAH.ShopLookup = TAH.ShopLookup or {}
TAH.Shop_Cache = TAH.Shop_Cache or {}

function TAH:PopulateShop()
    TAH.ShopItems = table.Copy(TAH.ShopDefaults)
    TAH.ShopLookup = {}

    -- If default item is not installed, remove the entry
    for class, data in pairs(TAH.ShopItems) do
        if string.Left(class, 1) ~= "!" and not weapons.Get(class) and not scripted_ents.Get(class) then
            TAH.ShopItems[class] = nil
        end
    end

    for _, class in pairs(TacRP.GetWeaponList()) do
        if TAH.ShopItems[class] then continue end -- skip if already defined
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
        if not shop:GetEnabled() or not shop.Items or not table.HasValue(shop.Items, class) then return end

        if TAH:GetTokens(ply) < entry.cost then return end

        if string.Left(class, 1) == "!" then
            -- does not give an entity
            TAH:GiveItem(ply, entry)
        else
            if true then
                for i=1, entry.ammo_count or 1 do
                    local ent = ents.Create(class)
                    assert(ent:IsValid(), "spawned ent is not valid")
                    local pos, ang = shop:GetShopSpawnVectors()
                    ent:SetPos( pos )
                    ent:SetAngles( ang )
                    ent:Spawn()

                    shop:ItemBoughtHere(ply, ent)
                end
            else -- old behavior
                TAH:GiveItem(ply, entry, class)
            end
        end

        TAH:AddTokens(ply, -entry.cost)

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