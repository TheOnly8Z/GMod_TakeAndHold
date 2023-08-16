TAH.ROUND_INACTIVE = -1 -- No game going on
TAH.ROUND_TAKE     = 0 -- Hold has not begun
TAH.ROUND_WAVE     = 1 -- Hold in progress, no nodes
TAH.ROUND_NODE     = 2 -- Hold in progress, nodes appeared

function TAH:GetRoundState()
    return GetGlobal2Int("TAHRoundState", -1)
end

-- Check if there is an ongoing hold.
function TAH:IsHoldActive()
    return self:GetRoundState() == TAH.ROUND_WAVE or self:GetRoundState() == TAH.ROUND_NODE
end

-- Time until the current hold phase ends. (Wave -> Node, Node -> Failed hold)
function TAH:GetWaveTime()
    return GetGlobal2Float("TAHWaveTime", -1)
end

-- A round consists of a take phase, then a hold phase with one or more waves.
function TAH:GetCurrentRound()
    return GetGlobal2Int("TAHCurrentRound", -1)
end

function TAH:GetCurrentWave()
    return GetGlobal2Int("TAHCurrentWave", -1)
end

-- The entity that respresents the hold point.
function TAH:GetHoldEntity()
    return GetGlobal2Entity("TAHHoldEntity")
end

-- Returns the table for current round and wave.
function TAH:GetWaveTable()
    if not TAH.WaveData[self:GetCurrentRound()] then return nil end
    return TAH.WaveData[self:GetCurrentRound()][self:GetCurrentWave()]
end

function TAH:HasNextWave()
    if not TAH.WaveData[self:GetCurrentRound()] then return false end
    return istable(TAH.WaveData[self:GetCurrentRound()][self:GetCurrentWave() + 1])
end

function TAH:HasNextRound()
    return istable(TAH.WaveData[self:GetCurrentRound() + 1])
end

function TAH:SetRoundState(v)
    SetGlobal2Int("TAHRoundState", v)
end

function TAH:SetWaveTime(v)
    SetGlobal2Float("TAHWaveTime", v)
end

function TAH:SetCurrentRound(v)
    SetGlobal2Int("TAHCurrentRound", v)
end

function TAH:SetCurrentWave(v)
    SetGlobal2Int("TAHCurrentWave", v)
end

function TAH:SetHoldEntity(v)
    SetGlobal2Entity("TAHHoldEntity", v)
end