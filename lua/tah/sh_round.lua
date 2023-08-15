TAH.ROUND_INACTIVE = -1
TAH.ROUND_TAKE = 0
TAH.ROUND_HOLD = 1

function TAH:GetRoundState()
    return GetGlobal2Int("TAHRoundState", -1)
end

-- Whether there are currently nodes to shoot.
function TAH:GetNodeActive()
    return GetGlobal2Bool("TAHNodeActive", false)
end

-- If NodeActive is true, returns the time at which the hold will fail.
-- If NodeActive is false, returns when nodes will appear.
function TAH:GetNodeTime()
    return GetGlobal2Float("TAHNodeTime", -1)
end

function TAH:GetCurrentHold()
    return GetGlobal2Int("TAHCurrentHold", -1)
end

function TAH:GetNodeProgress()
    return GetGlobal2Float("TAHNodeProgress", 0)
end

function TAH:GetHoldEntity()
    return GetGlobal2Entity("TAHHoldEntity")
end