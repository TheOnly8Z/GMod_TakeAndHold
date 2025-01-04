TAH.LOADOUT_PRIMARY = 1
TAH.LOADOUT_SECONDARY = 2
TAH.LOADOUT_ITEMS = 3
TAH.LOADOUT_EQUIP = 4
TAH.LOADOUT_ARMOR = 5

TAH.LOADOUT_BUDGET = 7

TAH.LoadoutChoiceCount = {
    [TAH.LOADOUT_PRIMARY] = 3,
    [TAH.LOADOUT_SECONDARY] = 6,
    [TAH.LOADOUT_ITEMS] = 6,
    [TAH.LOADOUT_EQUIP] = 4,
    [TAH.LOADOUT_ARMOR] = 2,
}

TAH.LoadoutEntries = {
    [TAH.LOADOUT_PRIMARY] = {
        {class = "tacrp_spr", cost = 2, weight = 10},
        {class = "tacrp_uratio", cost = 2, weight = 7},
        {class = "tacrp_bekas", cost = 4, weight = 10},
        {class = "tacrp_tgs12", cost = 4, weight = 7},
        {class = "tacrp_m1", cost = 5, weight = 4},
        {class = "tacrp_civ_mp5", cost = 6, weight = 4},
        {class = "tacrp_ar15", cost = 6, weight = 2},
        {class = "tacrp_k1a", cost = 7, weight = 2},
        {class = "tacrp_ex_ump45", cost = 7, weight = 2},

        -- InterOps
        {class = "tacrp_io_k98", cost = 1, weight = 8},
        {class = "tacrp_io_k98_varmint", cost = 2, weight = 6},
        {class = "tacrp_io_cx4", cost = 5, weight = 4},
        {class = "tacrp_io_mx4", cost = 7, weight = 2},
        {class = "tacrp_io_coltsmg", cost = 6, weight = 2},

        -- AR/AK
        {class = "tacrp_ar_m16a1", cost = 7, weight = 1},
        {class = "tacrp_ak_svd", cost = 6, weight = 3},

        -- Special Delivery
        {class = "tacrp_sd_1022", cost = 3, weight = 6},
        {class = "tacrp_sd_vz58", cost = 5, weight = 3},
        {class = "tacrp_sd_m1carbine", cost = 5, weight = 3},
        {class = "tacrp_sd_delisle", cost = 3, weight = 1},
        {class = "tacrp_sd_mp40", cost = 6, weight = 2},
        {class = "tacrp_sd_thompson", cost = 6, weight = 2},
        {class = "tacrp_sd_superx3", cost = 6, weight = 5},

        -- ExoOps
        {class = "tacrp_eo_winchester", cost = 3, weight = 10},
        {class = "tacrp_eo_izzyfal", cost = 6, weight = 4},
        {class = "tacrp_eo_l85", cost = 7, weight = 3},
        {class = "tacrp_eo_sg510", cost = 7, weight = 3},

        -- Scavenger's Spoils
        {class = "tacrp_pa_smle", cost = 1, weight = 8},
        {class = "tacrp_pa_mosin", cost = 1, weight = 8},
        {class = "tacrp_pa_coachgun", cost = 1, weight = 8},
        {class = "tacrp_pa_toz106", cost = 1, weight = 4},
        {class = "tacrp_pa_toz34", cost = 1, weight = 4},
        {class = "tacrp_pa_sako85", cost = 2, weight = 6},
        {class = "tacrp_pa_auto5", cost = 3, weight = 4},
        {class = "tacrp_pa_ithaca", cost = 4, weight = 5},
        {class = "tacrp_pa_hipoint", cost = 4, weight = 3},
        {class = "tacrp_pa_luty", cost = 4, weight = 3},
        {class = "tacrp_pa_svt40", cost = 6, weight = 3},
        {class = "tacrp_pa_madsen", cost = 6, weight = 3},
        {class = "tacrp_pa_sks", cost = 6, weight = 3},
        {class = "tacrp_pa_stg44", cost = 7, weight = 3},
        {class = "tacrp_pa_ppsh", cost = 7, weight = 1},
        {class = "tacrp_pa_uzi", cost = 7, weight = 1},
    },
    [TAH.LOADOUT_SECONDARY] = {
        {class = "tacrp_ex_m1911", cost = 2, weight = 20},
        {class = "tacrp_ex_glock", cost = 3, weight = 20},
        {class = "tacrp_vertec", cost = 3, weight = 20},
        {class = "tacrp_gsr1911", cost = 3, weight = 10},
        {class = "tacrp_p2000", cost = 4, weight = 10},
        {class = "tacrp_ex_usp", cost = 4, weight = 10},
        {class = "tacrp_ex_mac10", cost = 4, weight = 5},
        {class = "tacrp_skorpion", cost = 4, weight = 5},

        -- InterOps
        {class = "tacrp_io_t850", cost = 1, weight = 15},
        {class = "tacrp_io_ruger", cost = 1, weight = 15},
        {class = "tacrp_io_ab10", cost = 2, weight = 10},
        {class = "tacrp_io_p226", cost = 4, weight = 10},
        {class = "tacrp_io_vp70", cost = 4, weight = 5},
        {class = "tacrp_io_automag", cost = 4, weight = 2},
        {class = "tacrp_io_glock18", cost = 5, weight = 2},

        -- AR
        {class = "tacrp_ar_ar15pistol", cost = 5, weight = 2},

        -- Special Delivery
        {class = "tacrp_sd_tt33", cost = 2, weight = 15},
        {class = "tacrp_sd_ppk", cost = 3, weight = 15},
        {class = "tacrp_sd_contender", cost = 1, weight = 3},
        {class = "tacrp_sd_1858", cost = 2, weight = 3},
        {class = "tacrp_sd_db", cost = 4, weight = 3},
        {class = "tacrp_sd_dualies", cost = 4, weight = 2},
        {class = "tacrp_sd_dual_ppk", cost = 4, weight = 2},
        {class = "tacrp_sd_gyrojet", cost = 3, weight = 1},

        -- ExoOps
        {class = "tacrp_eo_p210", cost = 1, weight = 12},
        {class = "tacrp_eo_browninghp", cost = 2, weight = 12},
        {class = "tacrp_eo_rhino20ds", cost = 2, weight = 12},
        {class = "tacrp_eo_p7", cost = 4, weight = 8},
        {class = "tacrp_eo_hushpup", cost = 4, weight = 8},
        {class = "tacrp_eo_megastar", cost = 4, weight = 8},
        {class = "tacrp_eo_m712", cost = 4, weight = 2},
        {class = "tacrp_eo_mp5k", cost = 6, weight = 2},
        {class = "tacrp_eo_calico", cost = 6, weight = 2},

        -- Scavenger's Spoils
        {class = "tacrp_pa_makarov", cost = 1, weight = 20},
        {class = "tacrp_pa_sw10", cost = 3, weight = 12},
        {class = "tacrp_pa_fort12", cost = 3, weight = 12},
        {class = "tacrp_pa_woodsman", cost = 2, weight = 12},
        {class = "tacrp_pa_obrez", cost = 2, weight = 8},
        {class = "tacrp_pa_automag3", cost = 3, weight = 8},
        {class = "tacrp_pa_rhino60ds", cost = 4, weight = 8},
        {class = "tacrp_pa_sw686", cost = 5, weight = 2},
        {class = "tacrp_pa_klin", cost = 4, weight = 2},
        {class = "tacrp_pa_oa93", cost = 4, weight = 2},
        {class = "tacrp_pa_cz75", cost = 4, weight = 2},
        {class = "tacrp_pa_dual_makarov", cost = 3, weight = 2},
        {class = "tacrp_pa_shorty", cost = 4, weight = 5},
    },
    [TAH.LOADOUT_ITEMS] = {
        {class = "weapon_dz_healthshot", nodefaultclip = true, ammo_type = "dz_healthshot", ammo_count = 1, cost = 1, weight = 100},
        {class = "weapon_dz_healthshot", nodefaultclip = true, ammo_type = "dz_healthshot", ammo_count = 3, cost = 2, weight = 10},
        {class = "tacrp_nade_frag", nodefaultclip = true, cost = 1, weight = 20, ammo_type = "grenade", ammo_count = 3, icon = Material("entities/tacrp_ammo_frag.png"), quicknade = "frag",},
        {class = "tacrp_nade_flashbang", nodefaultclip = true, cost = 1, weight = 20, ammo_type = "ti_flashbang", ammo_count = 3, icon = Material("entities/tacrp_ammo_flashbang.png"), quicknade = "flashbang",},
        {class = "tacrp_nade_smoke", nodefaultclip = true, cost = 1, weight = 20, ammo_type = "ti_smoke", ammo_count = 3, icon = Material("entities/tacrp_ammo_smoke.png"), quicknade = "smoke",},
        {class = "tacrp_nade_frag", nodefaultclip = true, cost = 2, weight = 10, ammo_type = "grenade", ammo_count = 6, icon = Material("entities/tacrp_ammo_frag.png"), quicknade = "frag",},
        {class = "tacrp_nade_flashbang", nodefaultclip = true, cost = 2, weight = 10, ammo_type = "ti_flashbang", ammo_count = 6, icon = Material("entities/tacrp_ammo_flashbang.png"), quicknade = "flashbang",},
        {class = "tacrp_nade_smoke", nodefaultclip = true, cost = 2, weight = 10, ammo_type = "ti_smoke", ammo_count = 6, icon = Material("entities/tacrp_ammo_smoke.png"), quicknade = "smoke",},

        {class = "tacrp_nade_gas", cost = 1, weight = 10, ammo_type = "ti_gas", ammo_count = 2, icon = Material("entities/tacrp_ammo_gas.png"), quicknade = "gas",},
        {class = "tacrp_nade_heal", nodefaultclip = true, cost = 1, weight = 10, ammo_type = "ti_heal", ammo_count = 2, icon = Material("entities/tacrp_ammo_heal.png"), quicknade = "heal",},
        {class = "tacrp_nade_thermite", nodefaultclip = true, cost = 1, weight = 10, ammo_type = "ti_thermite", ammo_count = 2, icon = Material("entities/tacrp_ammo_fire.png"), quicknade = "thermite",},
        {class = "tacrp_nade_gas", nodefaultclip = true, cost = 2, weight = 5, ammo_type = "ti_gas", ammo_count = 4, icon = Material("entities/tacrp_ammo_gas.png"), quicknade = "gas",},
        {class = "tacrp_nade_heal", nodefaultclip = true, cost = 2, weight = 5, ammo_type = "ti_heal", ammo_count = 4, icon = Material("entities/tacrp_ammo_heal.png"), quicknade = "heal",},
        {class = "tacrp_nade_thermite", nodefaultclip = true, cost = 2, weight = 5, ammo_type = "ti_thermite", ammo_count = 4, icon = Material("entities/tacrp_ammo_fire.png"), quicknade = "thermite",},

        {cost = 1, weight = 10, ammo_type = "ti_breach", ammo_count = 9, icon = Material("entities/tacrp_ammo_charge.png"), quicknade = "charge",},

        {class = "weapon_dz_bumpmine", nodefaultclip = true, ammo_type = "dz_bumpmine", ammo_count = 3, cost = 1, weight = 20, quicknade = "dz_bumpmine",},
    },
    [TAH.LOADOUT_EQUIP] = {
        {class = "tacrp_medkit", cost = 5, weight = 10},
        {class = "tacrp_riot_shield", cost = 3, weight = 10},
        {class = "tacrp_c4_detonator", cost = 3, weight = 10, name = "C4", ammo_type = "ti_c4", ammo_count = 3, nodefaultclip = true},
        {class = "tacrp_civ_m320", cost = 4, weight = 10, ammo_type = "smg1_grenade", ammo_count = 6},
        {class = "tacrp_rpg7", cost = 5, weight = 3, ammo_type = "rpg_round", ammo_count = 3},

        {cost = 1, weight = 6, name = "3 TKNS", printname = "3 Tokens", desc = "Gain tokens to use in the shop.", icon = Material("entities/tacrp_ammo_crate.png"),
        func = function(ply)
            TAH:AddTokens(ply, 3)
        end},
        {cost = 2, weight = 3, name = "6 TKNS", printname = "3 Tokens", desc = "Gain tokens to use in the shop.", icon = Material("entities/tacrp_ammo_crate.png"),
        func = function(ply)
            TAH:AddTokens(ply, 6)
        end},

        {class = "tacrp_pa_p2a1", cost = 4, weight = 5},
    },
    [TAH.LOADOUT_ARMOR] = {
        {cost = 2, weight = 10, name = "100%", printname = "Kevlar & Helmet", desc = "Body armor and helmet reduces incoming damage until it runs out.", icon = Material("entities/dz_armor_kevlar_helmet.png"),
        func = function(ply)
            ply:SetArmor(100)
            ply:SetMaxArmor(100)
            ply:DZ_ENTS_SetArmor(DZ_ENTS_ARMOR_KEVLAR)
            ply:DZ_ENTS_GiveHelmet()
        end},
        {cost = 1, weight = 10, name = "60%", printname = "Light Kevlar", desc = "Body armor reduces incoming damage to the body until it runs out.", icon = Material("entities/dz_armor_kevlar.png"),
        func = function(ply)
            ply:SetArmor(60)
            ply:SetMaxArmor(100)
            ply:DZ_ENTS_SetArmor(DZ_ENTS_ARMOR_KEVLAR)
        end},
    },
}

for cat, tbl in pairs(TAH.LoadoutEntries) do
    -- If a weapon is missing, drop it from the table
    for i, info in pairs(tbl) do
        if info.class and not weapons.Get(info.class) and not scripted_ents.Get(info.class) then
            table.remove(tbl, i)
        end
    end

    -- Label the index for networking purposes
    for i, info in pairs(tbl) do
        info.id = i
    end
end


function TAH:RollLoadoutEntries(tbl, amt)
    local results = {}
    local indices = {}
    local tbl2 = table.Copy(tbl) -- this is not a deep copy, so we should not modify the contents!

    local weight = 0
    for _, info in ipairs(tbl2) do
        weight = weight + (info.weight or 0)
    end

    for count = 1, amt or 1 do
        local rng = math.random(0, weight)
        for i, info in pairs(tbl2) do
            rng = rng - (info.weight or 0)
            if rng <= 0 then
                -- pluck out the entry and also reduce total weight
                table.insert(results, table.remove(tbl2, i))
                table.insert(indices, info.id)
                weight = weight - (info.weight or 0)
                break
            end
        end
        if table.Count(tbl2) == 0 then break end
    end

    table.sort(indices)

    return results, indices
end

-- Maybe a lower difficulty can increase starting budget
function TAH:GetPlayerBudget(ply)
    return TAH.LOADOUT_BUDGET
end

if CLIENT then
    local frame
    concommand.Add("tah_loadout_test", function()
        if frame then frame:Remove() end
        frame = vgui.Create("TAHLoadout")
        frame:Center()
        frame:MakePopup()
    end)
end