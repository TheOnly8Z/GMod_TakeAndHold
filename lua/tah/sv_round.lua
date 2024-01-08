TAH.NextNPCSpawn = 0

function TAH:StartGame()
    self:SetCurrentRound(1)
    self:SetCurrentWave(0)
    self:SetWaveTime(-1)
    self:SetupHold()

    PrintMessage(HUD_PRINTTALK, "Game Start.")
end

function TAH:FinishGame()
    PrintMessage(HUD_PRINTTALK, "Game Over: Round " .. self:GetCurrentRound() .. ".")

    self:SetRoundState(self.ROUND_INACTIVE)
    self:SetHoldEntity(nil)
    self:SetCurrentRound(1)
    self:SetCurrentWave(0)
    self:SetWaveTime(-1)
    self:Cleanup()
end

-- Set specified entity to be the next hold (or random hold entity if none specified).
-- Spawn patrols and activate supply points.
function TAH:SetupHold(ent)
    if not IsValid(ent) then
        local points = ents.FindByClass("tah_holdpoint")
        ent = points[math.random(1, #points)]
    end
    self:SetHoldEntity(ent)
    self:SetRoundState(self.ROUND_TAKE)
    ent:SetCaptureProgress(0)
    ent:SetOwnedByPlayers(false)
    self:SetWaveTime(CurTime() + 300) -- TODO configure time
    PrintMessage(HUD_PRINTTALK, "Round " .. self:GetCurrentRound() .. " - Secure target access point.")

    -- spawn defenders for hold point
    local roundtbl = self:GetRoundTable()
    local spawn = roundtbl.defend_spawns[math.random(1, #roundtbl.defend_spawns)]
    self:SpawnEnemyGuard(spawn[1], ent:GetPos(), nil, spawn[2])

    -- spawn defenders on defend spots
    if roundtbl.defend_spot_spawns then
        local spawns = ents.FindByClass("tah_spawn_defend")
        for _, spot in pairs(spawns) do
            local dist_sqr = spot:GetPos():DistToSqr(ent:GetPos())
            if dist_sqr >= 1000 * 1000 then return end
            local name = roundtbl.defend_spot_spawns[math.random(1, #roundtbl.defend_spot_spawns)]
            self:SpawnEnemyGuard(name, spot:GetPos(), Angle(0, spot:GetAngles().y, 0), 1, true)
        end
    end

    -- spawn patrols
end

-- Start hold phase with the current active hold entity.
function TAH:StartHold()
    if self:GetRoundState() == self.ROUND_TAKE then
        PrintMessage(HUD_PRINTTALK, "Initializing uplink.")
        self:SetCurrentWave(1)
        self:StartWave()

        for _, ent in pairs(ents.FindByClass("tah_barrier")) do
            ent:SetEnabled(true)
        end
    end
end

-- Finish the hold and advance. If successful, give player some tokens.
function TAH:FinishHold(win)
    if self:IsHoldActive() then
        local has_next = self:HasNextRound()
        self:SetCurrentWave(0)

        if win then
            PrintMessage(HUD_PRINTTALK, "Uplink successful.")
        else
            PrintMessage(HUD_PRINTTALK, "Uplink failure.")
        end

        for _, ent in pairs(ents.FindByClass("tah_barrier")) do
            ent:SetEnabled(false)
        end

        if has_next then
            self:SetCurrentRound(self:GetCurrentRound() + 1)
            self:SetupHold() -- TODO: create hold sequence to prevent repeat holds
        else
            -- no more holds. gg
            self:FinishGame()
        end
    end
end

-- Initate a new wave.
function TAH:StartWave()
    local wavetbl = self:GetWaveTable()

    self:CleanupEnemies(true)
    self:SetRoundState(self.ROUND_WAVE)
    self:SetWaveTime(CurTime() + wavetbl.wave_duration)
    self.NextNPCSpawn = CurTime() + 5

    PrintMessage(HUD_PRINTTALK, "Incoming hostiles - maintain uplink.")
end

-- Transition from wave phase to node phase.
-- function TAH:StartNodes()
--     local wavetbl = self:GetWaveTable()

--     self:SetRoundState(TAH.ROUND_NODE)
--     self:SetWaveTime(CurTime() + wavetbl.node_duration)

--     self:SpawnNodes()

--     PrintMessage(HUD_PRINTTALK, "Neutralize nodes before system lockdown.")
-- end

-- Complete node phase and advance to next wave, or finish hold.
-- If failure, finishes hold immediately.
-- function TAH:FinishNodes(win)

--     self:CleanupEnemies(true)
--     self:CleanupNodes()

--     if win and self:HasNextWave() then
--         -- Advance to next wave.
--         self:SetCurrentWave(self:GetCurrentWave() + 1)
--         self:StartWave()
--     else
--         -- All waves for current round done.
--         self:FinishHold(win)
--     end
-- end

function TAH:Cleanup()
    self:CleanupEnemies(true)

    -- TODO: Maybe do something about hold/supply entities?
end

function TAH:RoundThink()
    local state = self:GetRoundState()
    local hold = self:GetHoldEntity()

    if not IsValid(hold) then
        PrintMessage(HUD_PRINTTALK, "Hold entity deleted - game interrupted.")
        TAH:FinishGame()
        return
    end

    if (hold._NextThink or 0) < CurTime() then
        hold._NextThink = CurTime() + hold.ThinkInterval
        hold:UpdateProgress()
    end

    if self:IsHoldActive() then
        local wavetbl = self:GetWaveTable()

        if self:GetWaveTime() < CurTime() then
            if hold:GetOwnedByPlayers() and hold:GetCaptureProgress() == 0 and hold:GetCaptureState() == 1 then
                TAH:FinishHold(true)
            end
        elseif self.NextNPCSpawn < CurTime() then
            self.NextNPCSpawn = CurTime() + (istable(wavetbl.wave_interval) and math.Rand(wavetbl.wave_interval[1], wavetbl.wave_interval[2]) or wavetbl.wave_interval)

            local spawn = wavetbl.wave_spawns[math.random(1, #wavetbl.wave_spawns)]

            self:SpawnEnemyWave(hold, spawn)
        end
    else
        -- Ran out of time before capturing
        if self:GetWaveTime() < CurTime() and hold:GetCaptureProgress() == 0 then
            TAH:FinishGame()
        end
        -- idk spawn some patrols once in a while?
    end
end
hook.Add("Tick", "TAH_RoundThink", function()
    if TAH:GetRoundState() ~= TAH.ROUND_INACTIVE then
        TAH:RoundThink()
    end
end)