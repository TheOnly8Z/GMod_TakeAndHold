hook.Add("EntityTakeDamage", "TAH", function(ent, dmginfo)
    if TAH:GetRoundState() == TAH.ROUND_INACTIVE then return end

    local attacker = dmginfo:GetAttacker()
    local inflictor = dmginfo:GetInflictor()

    -- Scale NPC damage, but only if they're using their weapon (or no weapon at all)
    if IsValid(attacker) and attacker.TAH_DamageScale and (inflictor == attacker or inflictor == attacker:GetActiveWeapon()) then
        dmginfo:ScaleDamage(attacker.TAH_DamageScale)
    end

    -- Turn off NPC FF
    if attacker:IsNPC() and ent:IsNPC() and attacker:Disposition(ent) == D_LI then return true end
end)