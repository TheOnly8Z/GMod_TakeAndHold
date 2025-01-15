AddCSLuaFile()

ENT.PrintName = "Dynamic Resupply"
ENT.Category = "Tactical Takeover"
ENT.Type = "point"

ENT.DefaultWeightTable = {
    ["tah_token"] = 20,

    ["dz_ammobox"] = 10, -- only when limited ammo mode is on
    ["dz_ammobox_belt"] = 10, -- only when limited ammo mode is on

    ["weapon_dz_healthshot"] = 5, -- weight increases when player has none and more when low hp
    ["dz_armor_half"] = 5, -- weight increases when player has low armor

    ["item_ammo_smg1_grenade"] = 3, -- weight increases when player has a weapon that uses this
    ["item_rpg_round"] = 3, -- weight increases when player has a weapon that uses this

    ["tacrp_ammo_frag"] = 9,
    ["tacrp_ammo_flashbang"] = 9,
    ["tacrp_ammo_smoke"] = 9,
    ["tacrp_ammo_heal"] = 6,
    ["tacrp_ammo_thermite"] = 6,
    ["tacrp_ammo_gas"] = 6,
    ["tacrp_ammo_charge"] = 3,
    ["weapon_dz_bumpmine"] = 3,
    ["tacrp_ammo_c4"] = 3,

    ["tacrp_civ_m320"] = 1,
}

if SERVER then
    function ENT:Initialize()
        -- Resupply some stuff ig

        -- Assume the closest player is the one who needs it
        local ply, plydist
        for _, p in pairs(TAH.ActivePlayers) do
            if p:Alive() and p:Team() ~= TEAM_SPECTATOR then
                local d = p:GetPos():DistToSqr(self:GetPos())
                if not ply or d <= plydist then
                    ply = p
                    plydist = d
                end
            end
        end
        if not ply then self:Remove() return end

        local tbl = table.Copy(self.DefaultWeightTable)

        if not TAH.ConVars["game_limitedammo"]:GetBool() then
            tbl["dz_ammobox"] = nil
            tbl["dz_ammobox_belt"] = nil
        end

        tbl["dz_armor_half"] = tbl["dz_armor_half"] * Lerp((ply:Armor() / ply:GetMaxArmor()) ^ 0.5, 4, 0)

        -- snoop around for nearby healthshots, so player cannot toss them and commit healthcare fraud
        -- this will actually also find ones that are on any player, so you better not be hoarding 'em
        -- sharing is caring, eh?
        local has_healthshot = false
        for _, ent in pairs(ents.FindInSphere(self:GetPos(), 1024)) do
            if ent:GetClass() == "weapon_dz_healthshot" then
                has_healthshot = true
                break
            end
        end
        if not has_healthshot then
            tbl["weapon_dz_healthshot"] = tbl["weapon_dz_healthshot"] * Lerp((ply:Health() / ply:GetMaxHealth()) ^ 0.5, 6, 3)
        end

        local need_smg_grenade = false
        local need_rpg_round = false
        for _, wep in ipairs(ply:GetWeapons()) do
            if string.lower(wep:GetPrimaryAmmoType()) == "smg1_grenade" then
                need_smg_grenade = true
            elseif string.lower(wep:GetPrimaryAmmoType()) == "rpg_round" then
                need_rpg_round = true
            end
        end
        if need_smg_grenade then
            tbl["item_ammo_smg1_grenade"] = tbl["item_ammo_smg1_grenade"] * Lerp(ply:GetAmmoCount("smg1_grenade") / 5, 6, 3)
        end
        if need_rpg_round then
            tbl["item_rpg_round"] = tbl["item_rpg_round"] * Lerp(ply:GetAmmoCount("rpg_round") / 3, 5, 2)
        end

        -- testing
        local ent = ents.Create(TAH:WeightedRandom(tbl))
        ent:SetPos(self:WorldSpaceCenter() + VectorRand() * 8)
        ent:SetAngles(Angle(0, math.Rand(0, 359), 0))
        ent:Spawn()

        table.insert(TAH.CleanupEntities, ent)

        self:Remove()
    end
end