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