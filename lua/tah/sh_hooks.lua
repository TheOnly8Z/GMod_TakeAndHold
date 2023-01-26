hook.Add("ShouldCollide", "takeandhold", function(ent1, ent2)
    if ent1:GetClass() == "tah_barrier" then
        return ent1:GetEnabled() and (ent2:IsPlayer() or ent2:IsVehicle())
    end
    if ent2:GetClass() == "tah_barrier" then
        return ent2:GetEnabled() and  (ent1:IsPlayer() or ent1:IsVehicle())
    end
end)