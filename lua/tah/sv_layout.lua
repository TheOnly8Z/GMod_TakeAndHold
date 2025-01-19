util.AddNetworkString("tah_savemetadata")
util.AddNetworkString("tah_loadmetadata")

-- This table holds the current map configuration and is used to save/load configs.
TAH.Layout = TAH.Layout or {
    --[[
    DataVersion = 1,
    FileName = "default.json",
    Name = "Default Configuration",
    Holds = {},

    ]]
}

TAH.Parameters = TAH.Parameters or {}

TAH.Spawn_Cache = TAH.Spawn_Cache or {}

function TAH:IsValidMetadata(tbl)
    return true
end

function TAH:GenerateMetadata(version)
    version = version or 1 -- future proof

    TAH.Layout = {
        DataVersion = version,
        Holds = {},
        Spawns = {
            tah_spawn_attack = {},
            tah_spawn_defend = {},
            tah_spawn_patrol = {},
            tah_spawn_player = {},
        },
        Entities = {
        },
        Parameters = table.Copy(TAH.Parameters),
    }

    TAH:SerializeHolds() -- Just in case

    for _, ent in pairs(ents.GetAll()) do
        if ent:GetClass() == "tah_holdpoint" then
            TAH.Layout.Holds[ent:GetSerialID()] = ent:Serialize(version)
        elseif TAH.Layout.Spawns[ent:GetClass()] then
            table.insert(TAH.Layout.Spawns[ent:GetClass()], ent:Serialize(version))
        elseif ent.TAH_SaveEntity then
            TAH.Layout.Entities[ent:GetClass()] = TAH.Layout.Entities[ent:GetClass()] or {}
            table.insert(TAH.Layout.Entities[ent:GetClass()], ent:Serialize(version))
        end
    end
end

function TAH:ApplyMetadata()
    game.CleanUpMap()

    local version = TAH.Layout.DataVersion
    TAH.DEFER_SERIALIZATION = true

    TAH.Parameters = table.Copy(TAH.Layout.Parameters)

    for i, str in pairs(TAH.Layout.Holds) do
        local ent = ents.Create("tah_holdpoint")
        ent:Deserialize(str, version)
        ent:Spawn()
    end

    for class, tbl in pairs(TAH.Layout.Spawns) do
        for _, str in pairs(tbl) do
            local ent = ents.Create(class)
            ent:Deserialize(str, version)
            ent:Spawn()
        end
    end

    for class, tbl in pairs(TAH.Layout.Entities or {}) do
        for _, str in pairs(tbl) do
            local ent = ents.Create(class)
            ent:Deserialize(str, version)
            ent:Spawn()
        end
    end

    TAH.DEFER_SERIALIZATION = false

    TAH:SendConfig()
end

function TAH:SaveMetadata(name, version)
    name = name or os.date("%Y%m%d_%H%M%S")

    TAH:GenerateMetadata(version)

    if not file.IsDir("tah/" .. game.GetMap(), "DATA") then file.CreateDir("tah/" .. game.GetMap()) end
    file.Write(string.lower("tah/" .. game.GetMap() .. "/" .. name .. ".json"), util.TableToJSON(TAH.Layout, true))

    PrintMessage(HUD_PRINTTALK, "Saved layout " .. name .. ".")
end
net.Receive("tah_savemetadata", function(len, ply)
    if not ply:IsAdmin() then return end
    local filename = net.ReadString()
    TAH:SaveMetadata(filename)
end)

function TAH:LoadMetadata(name)
    local tbl = file.Read(string.lower("tah/" .. game.GetMap() .. "/" .. name .. ".json"))
    if self:IsValidMetadata(tbl) then
        TAH.Layout = util.JSONToTable(tbl)
        TAH:ApplyMetadata()
        PrintMessage(HUD_PRINTTALK, "Loaded layout " .. name .. ".")
    else
        TAH.Layout = {}
    end
end
net.Receive("tah_loadmetadata", function(len, ply)
    if not ply:IsAdmin() then return end
    local filename = net.ReadString()
    TAH:LoadMetadata(filename)
end)

concommand.Add("tah_autolink", function()
    local holds = ents.FindByClass("tah_holdpoint")
    for _, ent in pairs(ents.FindByClass("tah_spawn_*")) do
        if ent:GetLinkBits() > 0 then continue end
        local best_hold, dist = nil, math.huge
        for _, hold in pairs(holds) do
            local newdist = hold:GetPos():DistToSqr(ent:GetPos())
            if newdist < dist then
                best_hold = hold
                dist = newdist
            end
        end
        ent:AddLinkedHold(best_hold)
    end
end)

-- Tempoarily set this to true to disable serialization check on holds; use when loading a configuration
TAH.DEFER_SERIALIZATION = false

function TAH:SerializeHolds(new_hold)
    if TAH.DEFER_SERIALIZATION then return end

    local cur_serial = {}
    local serial = ents.FindByClass("tah_holdpoint")
    if new_hold then table.RemoveByValue(serial, new_hold) end
    local need_update = false

    -- Serial ID must be consecutive; check this by using the # operator on the table
    for i, ent in pairs(serial) do
        if ent:GetSerialID() == 0 or cur_serial[ent:GetSerialID()] then
            need_update = true
            break
        else
            cur_serial[ent:GetSerialID()] = ent
        end
    end
    if #cur_serial ~= #serial then need_update = true end

    if need_update then
        -- Adjust existing IDs to be consecutive, add new one at the end
        local i = 1
        for _, ent in SortedPairs(cur_serial) do
            ent:SetSerialID(i)
            i = i + 1
        end
        if new_hold then
            new_hold:SetSerialID(i)
        end
    elseif new_hold then
        new_hold:SetSerialID(#serial + 1)
    end
end
