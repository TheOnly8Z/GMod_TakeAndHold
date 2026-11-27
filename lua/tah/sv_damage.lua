hook.Add("EntityTakeDamage", "TAH", function(ent, dmginfo)
    if TAH:GetRoundState() == TAH.ROUND_INACTIVE then return end

    local attacker = dmginfo:GetAttacker()
    local inflictor = dmginfo:GetInflictor()

    if IsValid(attacker) then
            -- Scale NPC damage, but only if they're using their weapon (or no weapon at all)
        if attacker.TAH_DamageScale and (inflictor == attacker or inflictor == attacker:GetActiveWeapon()) then
            dmginfo:ScaleDamage(attacker.TAH_DamageScale)
        end

        -- Turn off NPC FF
        if attacker:IsNPC() and ent:IsNPC() and attacker:Disposition(ent) == D_LI then return true end

        if ent:IsPlayer() and attacker:IsPlayer() and ent ~= attacker then
            if not TAH.ConVars["game_friendlyfire"]:GetBool() then
                return true
            end
            local d = TAH.ConVars["game_difficulty"]:GetInt()
            if d == 0 then
                dmginfo:ScaleDamage(0.15)
            elseif d == 1 then
                dmginfo:ScaleDamage(0.5)
            end
        end
    end


end)

-- Simulate armor calculation
-- https://github.com/ValveSoftware/source-sdk-2013/blob/0d8dceea4310fde5706b3ce1c70609d72a38efdf/mp/src/game/server/player.cpp#L1061
local function calcarmor(dmginfo, armor, flBonus, flRatio, fHeavyArmorBonus)
    if not flBonus then
        flBonus = 1
    end
    flRatio = flRatio or 0.2
    fHeavyArmorBonus = fHeavyArmorBonus or 1

    local dmg = dmginfo:GetDamage()
    if dmginfo:IsDamageType(DMG_BLAST) then
        flBonus = flBonus * 2
    end
    if armor > 0 then
        local flNew = dmg * flRatio
        local flArmor = (dmg - flNew) * flBonus * fHeavyArmorBonus

        if flArmor == 0 then
            flArmor = 1
            -- flArmor = math.max(1, flArmor)
        end

        if flArmor > armor then
            flArmor = armor * (1 / flBonus)
            flNew = dmg - flArmor
            -- m_DmgSave = armor -- ?
            armor = 0
        else
            -- m_DmgSave = flArmor
            armor = math.max(0, armor - flArmor)
        end

        dmg = flNew
    end
    return dmg, armor
end
local bitflags_blockable = DMG_BULLET + DMG_BUCKSHOT + DMG_BLAST

hook.Add("ScaleNPCDamage", "ZZZZZ_TAH", function(ent, hitgroup, dmginfo)
    if ent.TAH_NPC and ent.TAH_Profile and bit.band(dmginfo:GetDamageType(), bitflags_blockable) ~= 0 then

        local inflictor = dmginfo:GetInflictor()
        if inflictor == dmginfo:GetAttacker() and inflictor:IsPlayer() then
            inflictor = inflictor:GetActiveWeapon()
        end

        local data = TAH.EnemyData[ent.TAH_Profile]
        if data.armor and data.armor.hitgroups[hitgroup] then

            local durability = ent:GetNW2Float("TAH_NPC_Armor", data.armor.durability)

            if durability > 0 then
                -- affects how much armor is reduced from damage
                local armorbonus = 0.5
                -- affects what fraction of damage is converted to armor damage (1 means none)
                local armorratio = data.armor.hitgroups[hitgroup]

                local ap = 0.5
                local ab = 1
                if IsValid(inflictor) and inflictor.ArcticTacRP then
                    ap = inflictor:GetValue("ArmorPenetration")
                    ab = inflictor:GetValue("ArmorBonus")
                end

                local healthdmg, newarmor = calcarmor(dmginfo, durability, armorbonus * ab, armorratio * ap * 2)

                -- Block damage and hurt armor
                dmginfo:SetDamage(healthdmg)
                ent:SetNW2Float("TAH_NPC_Armor", newarmor)
            end
        end
    end
end)