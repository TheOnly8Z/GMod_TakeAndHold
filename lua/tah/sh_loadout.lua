TAH.LOADOUT_PRIMARY = 1 -- roll 3, max 1
TAH.LOADOUT_SECONDARY = 2 -- roll 2, max 1
TAH.LOADOUT_ITEMS = 3 -- roll 4
TAH.LOADOUT_EQUIP = 4 -- roll 1, max 1
TAH.LOADOUT_ARMOR = 5 -- roll all, max 1

TAH.LOADOUT_BUDGET = 7

TAH.LoadoutEntries = {
    [TAH.LOADOUT_PRIMARY] = {
        ["tacrp_spr"] = {cost = 2, weight = 10},
        ["tacrp_uratio"] = {cost = 2, weight = 7},
        ["tacrp_bekas"] = {cost = 4, weight = 10},
        ["tacrp_tgs12"] = {cost = 4, weight = 7},
        ["tacrp_m1"] = {cost = 5, weight = 4},
        ["tacrp_civ_mp5"] = {cost = 5, weight = 4},
        ["tacrp_k1a"] = {cost = 7, weight = 2},
        ["tacrp_ex_ump45"] = {cost = 7, weight = 2},
        ["tacrp_ar15"] = {cost = 7, weight = 2},
    },
    [TAH.LOADOUT_SECONDARY] = {
        ["tacrp_ex_m1911"] = {cost = 2, weight = 20},
        ["tacrp_ex_glock"] = {cost = 3, weight = 20},
        ["tacrp_vertec"] = {cost = 3, weight = 20},
        ["tacrp_ex_mac10"] = {cost = 4, weight = 5},
        ["tacrp_skorpion"] = {cost = 4, weight = 5},
    },
    [TAH.LOADOUT_ITEMS] = {
        ["!frag"] = {cost = 2, weight = 30, ammo_type = "grenade", ammo_count = 3, icon = Material("entities/tacrp_ammo_frag.png")},
        ["!flashbang"] = {cost = 1, weight = 30, ammo_type = "ti_flashbang", ammo_count = 2, icon = Material("entities/tacrp_ammo_flashbang.png")},
        ["!gas"] = {cost = 2, weight = 10, ammo_type = "ti_gas", ammo_count = 3, icon = Material("entities/tacrp_ammo_gas.png")},
        ["!smoke"] = {cost = 2, weight = 10, ammo_type = "ti_smoke", ammo_count = 3, icon = Material("entities/tacrp_ammo_smoke.png")},
        ["!heal"] = {cost = 2, weight = 10, ammo_type = "ti_heal", ammo_count = 1, icon = Material("entities/tacrp_ammo_heal.png")},
        ["!thermite"] = {cost = 1, weight = 10, ammo_type = "ti_thermite", ammo_count = 1, icon = Material("entities/tacrp_ammo_fire.png")},
        ["!breach"] = {cost = 1, weight = 1, ammo_type = "ti_breach", ammo_count = 5, icon = Material("entities/tacrp_ammo_breach.png")},
        ["weapon_dz_bumpmine"] = {cost = 1, weight = 10},
        ["weapon_dz_healthshot"] = {cost = 1, weight = 100},
    },
    [TAH.LOADOUT_EQUIP] = {
        ["tacrp_medkit"] = {cost = 5, weight = 10},
        ["tacrp_riot_shield"] = {cost = 3, weight = 10},
        ["tacrp_civ_m320"] = {cost = 4, weight = 10, ammo_type = "smg1_grenade", ammo_count = 3},
    },
    [TAH.LOADOUT_ARMOR] = {
        ["!armor_100"] = {cost = 3, weight = 10, name = "100%", icon = Material("entities/dz_armor_kevlar_helmet.png"),
        func = function(ply)
            ply:SetArmor(100)
            ply:SetMaxArmor(100)
            ply:DZ_ENTS_SetArmor(DZ_ENTS_ARMOR_KEVLAR)
            ply:DZ_ENTS_GiveHelmet()
        end},
        ["!armor_60"] = {cost = 2, weight = 10, name = "60%", icon = Material("entities/dz_armor_kevlar.png"),
        func = function(ply)
            ply:SetArmor(60)
            ply:SetMaxArmor(100)
            ply:DZ_ENTS_SetArmor(DZ_ENTS_ARMOR_KEVLAR)
        end},
        ["!armor_30"] = {cost = 1, weight = 10, name = "30%", icon = Material("entities/dz_armor_kevlar.png"),
        func = function(ply)
            ply:SetArmor(30)
            ply:SetMaxArmor(100)
            ply:DZ_ENTS_SetArmor(DZ_ENTS_ARMOR_KEVLAR)
        end},
    },

}