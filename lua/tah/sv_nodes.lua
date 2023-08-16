TAH.Node_Cache = {}
function TAH:CleanupNodes()
    for _, ent in pairs(self.Node_Cache) do
        SafeRemoveEntity(ent)
    end
    self.Node_Cache = {}
end

function TAH:SpawnNodes()
    local wavetbl = self:GetWaveTable()
    local hold = self:GetHoldEntity()

    local types = table.Copy(wavetbl.node_spawns)
    local nodes = {}
    for i = 1, wavetbl.node_variety or 1 do
        if #types == 0 then break end
        local j = math.random(1, #types)
        local new = types[j]
        table.insert(nodes, new)
        table.remove(types, j)
    end

    local count = istable(wavetbl.node_count) and math.random(wavetbl.node_count[1], wavetbl.node_count[2]) or wavetbl.node_count

    for i = 1, count do
        local dir = hold:GetForward():Angle()
        dir:RotateAroundAxis(hold:GetUp(), math.Rand(0, 360))
        local tr = util.TraceLine({
            start = hold:GetPos() + Vector(0, 0, 16),
            endpos = hold:GetPos() + dir:Forward() * 256,
            mask = MASK_SOLID_BRUSHONLY,
        })
        local pos = tr.StartPos + tr.Normal * 256 * math.Rand(0, tr.Fraction)
        local tr2 = util.TraceLine({
            start = pos,
            endpos = pos + Vector(0, 0, 128),
            mask = MASK_SOLID_BRUSHONLY,
        })
        pos = tr2.HitPos

        debugoverlay.Line(tr.StartPos, tr.HitPos, 5, color_white, true)
        debugoverlay.Line(tr2.StartPos, tr2.HitPos, 5, Color(255, 255, 0), true)

        local ent = ents.Create(nodes[math.random(1, #nodes)])
        ent:SetPos(pos)
        ent:SetAngles(Angle(0, math.Rand(0, 360), 0))
        ent:Spawn()
        table.insert(self.Node_Cache, ent)
    end
end

function TAH:IsNodesCleared()
    for _, ent in pairs(self.Node_Cache) do
        if IsValid(ent) then return false end
    end
    return true
end