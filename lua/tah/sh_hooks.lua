hook.Add("ShouldCollide", "takeandhold", function(ent1, ent2)
    if ent1:GetClass() == "tah_barrier" then
        return ent2:IsPlayer()
    end
    if ent2:GetClass() == "tah_barrier" then
        return ent1:IsPlayer()
    end
end)