function TakeAndHold:SetRoundState(v)
    SetGlobal2Int("TAHRoundState", v)
end

function TakeAndHold:SetNodeActive(v)
    SetGlobal2Bool("TAHNodeActive", v)
end

function TakeAndHold:SetNodeTime(v)
    SetGlobal2Float("TAHNodeTime", v)
end

function TakeAndHold:RoundThink()
    local state = self:GetRoundState()

    if state == TakeAndHold.ROUND_HOLD then
        local next_node = self:GetNodeTime()
        if next_node ~= -1 and next_node > CurTime() then
            if self:GetNodeActive() then
                -- Failed
                self:GameOver()
            else
                -- Spawn the nodes
                self:SpawnNodes()
                self:SetNodeActive(true)
            end
        end
    end
end

function TakeAndHold:SpawnNodes()

end

function TakeAndHold:GameOver()
    self:SetRoundState(self.ROUND_INACTIVE)
end

function TakeAndHold:Cleanup()

end