function TAH:SetRoundState(v)
    SetGlobal2Int("TAHRoundState", v)
end

function TAH:SetNodeActive(v)
    SetGlobal2Bool("TAHNodeActive", v)
end

function TAH:SetNodeTime(v)
    SetGlobal2Float("TAHNodeTime", v)
end

function TAH:SetCurrentHold(v)
    SetGlobal2Int("TAHCurrentHold", v)
end

function TAH:StartGame()
    self:SetRoundState(self.ROUND_TAKE)
    self:SetupHold()
end

function TAH:GameOver()
    self:SetRoundState(self.ROUND_INACTIVE)
    self:Cleanup()
end


function TAH:RoundThink()
    local state = self:GetRoundState()

    if state == TAH.ROUND_HOLD then
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

function TAH:SpawnNodes()

end

function TAH:SetupHold()

end

function TAH:Cleanup()

end