-- This table holds the current map configuration and is used to save/load configs.
TakeAndHold.Metadata = {
    {}, -- Hold zones
    {}, -- Supply zones
    {}, -- Props
}

function TakeAndHold:IsValidMetadata(tbl)
    return true
end

function TakeAndHold:SaveMetadata(name)
    file.Write(string.lower("takeandhold/" .. game.GetMap() .. "/" .. name .. ".txt"), util.TableToJSON(TakeAndHold.Metadata, false))
end

function TakeAndHold:LoadMetadata(name)
    local tbl = file.Read(string.lower("takeandhold/" .. game.GetMap() .. "/" .. name .. ".txt"))
    if self:IsValidMetadata(tbl) then
        TakeAndHold.Metadata = tbl
    else
        TakeAndHold.Metadata = {{}, {}, {}}
    end
end