TakeAndHold.ROUND_INACTIVE = -1
TakeAndHold.ROUND_TAKE = 0
TakeAndHold.ROUND_HOLD = 1

function TakeAndHold:GetRoundState()
    return GetGlobal2Int("TAHRoundState", -1)
end

-- Whether there are currently nodes to shoot.
function TakeAndHold:GetNodeActive()
    return GetGlobal2Bool("TAHNodeActive", false)
end

-- If NodeActive is true, returns the time at which the hold will fail.
-- If NodeActive is false, returns when nodes will appear.
function TakeAndHold:GetNodeTime()
    return GetGlobal2Float("TAHNodeTime", -1)
end

function TakeAndHold:GetCurrentHold()
    return GetGlobal2Int("TAHCurrentHold", -1)
end