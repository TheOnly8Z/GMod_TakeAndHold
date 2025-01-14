AddCSLuaFile()

ENT.Type = "point"

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

        self:Remove()
    end
end