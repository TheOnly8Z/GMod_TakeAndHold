hook.Add("ShouldCollide", "tah", function(ent1, ent2)
    if ent1:GetClass() == "tah_barrier" then
        if not ent1:GetEnabled() then return false end
        return ent2:IsPlayer() or ent2:IsVehicle()
    end
    if ent2:GetClass() == "tah_barrier" then
        if not ent2:GetEnabled() then return false end
        return ent1:IsPlayer() or ent1:IsVehicle()
    end
end)

hook.Add("Move", "tah", function(ply, mv)
    if TAH:IsHoldActive() and ply:Alive() and ply:GetMoveType() == MOVETYPE_WALK and IsValid(TAH:GetHoldEntity()) and TAH:GetHoldEntity():GetCage() then
        local hold = TAH:GetHoldEntity()
        local pos0 = hold:GetPos()
        local pos1 = mv:GetOrigin()
        if hold:GetUseAABB() then
            local mins, maxs = hold:GetMinS(), hold:GetMaxS()
            if pos1.x < mins.x then
                mv:SetVelocity(mv:GetVelocity() - Vector(pos1.x - mins.x, 0, 0))
            elseif pos1.x > maxs.x then
                mv:SetVelocity(mv:GetVelocity() - Vector(pos1.x - maxs.x, 0, 0))
            end
            if pos1.y < mins.y then
                mv:SetVelocity(mv:GetVelocity() - Vector(0, pos1.y - mins.y, 0))
            elseif pos1.y > maxs.y then
                mv:SetVelocity(mv:GetVelocity() - Vector(0, pos1.y - maxs.y, 0))
            end
        else

            local dist = math.sqrt((pos0.x - pos1.x) ^ 2 + (pos0.y - pos1.y) ^ 2)
            if dist > hold:GetRadius() then
                local dir = pos0 - pos1
                dir:Normalize()
                mv:SetVelocity(mv:GetVelocity() + dir * (dist - hold:GetRadius()))
            end
        end
    end
end)