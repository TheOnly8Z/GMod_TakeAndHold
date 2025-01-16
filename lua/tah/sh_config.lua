
TAH.CONFIG_INFO = 0
TAH.CONFIG_WARN = 1
TAH.CONFIG_ERROR = 2

TAH.ConfigIcons = {
    [TAH.CONFIG_INFO] = Material("icon16/information.png"),
    [TAH.CONFIG_WARN] = Material("icon16/error.png"),
    [TAH.CONFIG_ERROR] = Material("icon16/cancel.png"),
}

TAH.ParameterList = {
    ["linear"] = {
        name = "Linear Hold Progression",
        desc = [[Hold selection will always be based on serial order, starting from 1.
Shop selection will be based on distance to the last and current hold.
Only recommended for maps that have one path from start to finish.]],
        control = "b",
        default = false,
        sortorder = 1,
    },
}

TAH.ConfigMessages = {
    -- 1. Not enough hold entities
    {severity = TAH.CONFIG_ERROR, message = "At least two holds must be set up.",
    tooltip = [[Hold entities define where the capture point is and how big it is.
Use the Hold Area tool to create hold entities. It's recommended to have at least 5 holds to avoid duplicate hold locations.]]},

    -- 2. Low hold entity count
    {severity = TAH.CONFIG_WARN, message = "There are fewer than 5 holds.",
    tooltip = [[It is recommended to have at least 5 holds so that the hold points do not repeat.]]},

    -- 3. Not enough shop entities
    {severity = TAH.CONFIG_ERROR, message = "At least one shop entity must be set up.",
    tooltip = [[Shop entities are where players spend tokens to buy ammo and supplies in between holds.
It is recommended to spread many shops across the map, as only a few will be active for each round.]]},

    -- 4. Low shop entity count
    {severity = TAH.CONFIG_WARN, message = "There are fewer than 3 shops.",
    tooltip = [[It is recommended to have at least 3 shops so that all shop items are buyable.]]},

    -- 5. Hold has no player spawns
    {severity = TAH.CONFIG_ERROR, message = "One or more holds have no player spawns linked.",
    tooltip = [[Each hold entity requires at least one player spawn, used to place the player at the start of the game.
Spawn the spawn entities in the Entities - Tactical Takeover category, then use the Spawn Linker tool to connect them to the hold.
A connected player spawn will show a yellow line between it and the hold.]]},

    -- 6. Hold has no attack spawns
    {severity = TAH.CONFIG_ERROR, message = "One or more holds have no attacker spawns linked.",
    tooltip = [[Each hold entity requires at least one attack spawn, preferrably several, so that NPCs can attack the hold point.
Spawn the spawn entities in the Entities - Tactical Takeover category, then use the Spawn Linker tool to connect them to the hold.
A connected attacker spawn will show a red line between it and the hold.]]},

    -- 7. Hold has no defend spawns
    {severity = TAH.CONFIG_WARN, message = "One or more holds have no defender spawns linked.",
    tooltip = [[Defender spawns are used to place static NPCs at strategic locations around a hold point.
While not required, it is recommended to have several defender spawns per hold.
Spawn the spawn entities in the Entities - Tactical Takeover category, then use the Spawn Linker tool to connect them to the hold.
A connected defender spawn will show a green line between it and the hold.]]},

    -- 8. Hold has no patrol spawns
    {severity = TAH.CONFIG_INFO, message = "One or more holds have no patrol spawns linked.",
    tooltip = [[Patrol spawns are used to spawn additional enemies beyond the hold in between waves.
They are recommended in large maps with some distance between holds.
Spawn the spawn entities in the Entities - Tactical Takeover category, then use the Spawn Linker tool to connect them to the hold.
A connected patrol spawn will show a blue line between it and the hold.]]},

    -- 9. All good
    {severity = TAH.CONFIG_INFO, message = "You're all set!",
    tooltip = [[If there's an issue with the current setup, it will be shown in the list here.]]},

    -- 10. No NPC Nodes
    {severity = TAH.CONFIG_ERROR, message = "This map has no NPC nodes.",
    tooltip = [[A nodegraph for the map is required for NPCs to move around.
If a map does not have NPC nodes, you need to find it on the Workshop or make your own.]]},

    -- 11. Too few crate spawns
    {severity = TAH.CONFIG_WARN, message = "There are too few crate spawns.",
    tooltip = [[Crate spawns are required for additional supply crates to spawn, containing tokens, supply and ammo.
It is recommended to spread at least 20 spawns across the map, both near holds and near shops.]]},

    -- 12. Linear Hold Progression is on, and there aren't exactly 5 holds
    {severity = TAH.CONFIG_ERROR, message = "Linear Hold Progression requires at least 5 holds.",
    tooltip = [[When Linear Hold Progression is enabled, there must be enough holds as they do not repeat.
Use the Hold Area tool to create hold entities.]]},

}

function TAH:ReadParam(key)
    local param = TAH.ParameterList[key]
    if not param then return end
    if param.control == "b" then
        return net.ReadBool()
    elseif param.control == "f" then
        return net.ReadFloat()
    elseif param.control == "i" then
        return net.ReadInt(64)
    elseif paramcontrol == "s" then
        return net.ReadString()
    end
end

function TAH:WriteParam(key, value)
    local param = TAH.ParameterList[key]
    if not param then return end
    if param.control == "b" then
        net.WriteBool(value)
    elseif param.control == "f" then
        net.WriteFloat(value)
    elseif param.control == "i" then
        net.WriteInt(value, 64)
    elseif paramcontrol == "s" then
        net.WriteString(value)
    end
end

if SERVER then
    util.AddNetworkString("tah_checkconfig")
    util.AddNetworkString("tah_parameter")

    local spawns = {
        "tah_spawn_player",
        "tah_spawn_attack",
        "tah_spawn_defend",
        "tah_spawn_patrol",
    }
    function TAH:CheckConfig()
        local messages = 0 -- bitflag
        local allow_start = true
        local holds = ents.FindByClass("tah_holdpoint")
        if self:GetParameter("linear") then
            if #holds < 5 then
                messages = messages + 2 ^ 11
                allow_start = false
            end
        else
            if #holds < 2 then
                messages = messages + 2 ^ 0
                allow_start = false
            elseif #holds < 5 then
                messages = messages + 2 ^ 1
            end
        end

        local shops = ents.FindByClass("tah_shop")
        if #shops == 0 then
            messages = messages + 2 ^ 2
            allow_start = false
        elseif #shops < 3 then
            messages = messages + 2 ^ 3
        end

        local missing = {}
        for _, hold in ipairs(holds) do
            for i, class in ipairs(spawns) do
                if missing[i] then continue end
                local has = false
                for _, ent in pairs(TAH.Spawn_Cache[class] or {}) do
                    if IsValid(ent) and ent:IsLinkedWith(hold) then
                        has = true
                        break
                    end
                end
                if not has then
                    missing[i] = true
                end
            end
        end

        for i, v in pairs(missing) do
            if v then
                messages = messages + 2 ^ (3 + i)
                if i == 1 or i == 2 then
                    allow_start = false
                end
            end
        end

        local nodefile = "maps/graphs/" .. game.GetMap() .. ".ain"
        if file.Size(nodefile, "GAME") < 128 then
            messages = messages + 2 ^ 9
            allow_start = false
        end

        local crates = ents.FindByClass("tah_crate")
        if #crates < 20 then
            messages = messages + 2 ^ 10
        end

        if messages == 0 then
            return 2 ^ 8, true
        else
            return messages, allow_start
        end
    end

    function TAH:SendConfig(ply)
        local msg, ok = TAH:CheckConfig()

        if not ply then
            ply = {}
            for _, p in pairs(player.GetAll()) do
                if p:IsAdmin() then table.insert(ply, p) end
            end
        end

        net.Start("tah_checkconfig")
            net.WriteUInt(msg, 32)
            net.WriteBool(ok)

            for k, v in SortedPairs(TAH.ParameterList) do
                TAH:WriteParam(k, TAH:GetParameter(k))
            end

            if not game.SinglePlayer() then
                local files = file.Find("tah/" .. game.GetMap() .. "/*.json", "DATA")
                net.WriteUInt(table.Count(files), 10)
                for _, str in pairs(files) do
                    net.WriteString(string.sub(str, 0, -6))
                end
            end
        net.Send(ply)
    end

    function TAH:GetParameter(key)
        if TAH.Layout.Parameters and TAH.Layout.Parameters[key] ~= nil then
            return TAH.Layout.Parameters[key]
        else
            if istable(TAH.ParameterList[key].default) then
                return table.Copy(TAH.ParameterList[key].default)
            else
                return TAH.ParameterList[key].default
            end
        end
    end

    function TAH:SetParameter(key, value)
        TAH.Layout.Parameters = TAH.Layout.Parameters or {}
        TAH.Layout.Parameters[key] = value
    end

    net.Receive("tah_checkconfig", function(len, ply)
        if not ply:IsAdmin() then return end
        TAH:SendConfig(ply)
    end)

    net.Receive("tah_parameter", function(len, ply)
        if not ply:IsAdmin() then return end

        local key = net.ReadString()
        local value = TAH:ReadParam(key)

        if key and value ~= nil then
            TAH:SetParameter(key, value)
        end

        TAH:SendConfig()
    end)
else
    TAH.ClientParameters = TAH.ClientParameters or {}
    TAH.ConfigStatus = TAH.ConfigStatus or 0
    TAH.ConfigOK = TAH.ConfigOK or false
    TAH.ConfigLayouts = TAH.ConfigLayouts or {}
    net.Receive("tah_checkconfig", function()
        TAH.ConfigStatus = net.ReadUInt(32)
        TAH.ConfigOK = net.ReadBool()
        TAH.ConfigLayouts = {["New Layout..."] = ""}

        for k, v in SortedPairs(TAH.ParameterList) do
            TAH.ClientParameters[k] = TAH:ReadParam(k)
        end

        if game.SinglePlayer() then
            local files = file.Find("tah/" .. game.GetMap() .. "/*.json", "DATA")
            for _, str in pairs(files) do
                TAH.ConfigLayouts[string.sub(str, 0, -6)] = string.sub(str, 0, -6)
            end
        else
            for i = 1, net.ReadUInt(10) do
                local name = net.ReadString()
                TAH.ConfigLayouts[name] = name
            end
        end

        TAH.GameControllerPanel:UpdateMessages()
    end)

    function TAH:GetParameter(key)
        if TAH.ClientParameters and TAH.ClientParameters[key] ~= nil then
            return TAH.ClientParameters[key]
        else
            if istable(TAH.ParameterList[key].default) then
                return table.Copy(TAH.ParameterList[key].default)
            else
                return TAH.ParameterList[key].default
            end
        end
    end

    function TAH:SetParameter(key, value)
        if not LocalPlayer():IsAdmin() then return end

        net.Start("tah_parameter")
            net.WriteString(key)
            TAH:WriteParam(key, value)
        net.SendToServer()
    end
end