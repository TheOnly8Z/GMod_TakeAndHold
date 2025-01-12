
TAH.CONFIG_INFO = 0
TAH.CONFIG_WARN = 1
TAH.CONFIG_ERROR = 2

TAH.ConfigIcons = {
    [TAH.CONFIG_INFO] = Material("icon16/information.png"),
    [TAH.CONFIG_WARN] = Material("icon16/error.png"),
    [TAH.CONFIG_ERROR] = Material("icon16/cancel.png"),
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
Spawn the spawn entities in the Entities - Take and Hold category, then use the Spawn Linker tool to connect them to the hold.
A connected player spawn will show a yellow line between it and the hold.]]},

    -- 6. Hold has no attack spawns
    {severity = TAH.CONFIG_ERROR, message = "One or more holds have no attacker spawns linked.",
    tooltip = [[Each hold entity requires at least one attack spawn, preferrably several, so that NPCs can attack the hold point.
Spawn the spawn entities in the Entities - Take and Hold category, then use the Spawn Linker tool to connect them to the hold.
A connected attacker spawn will show a red line between it and the hold.]]},

    -- 7. Hold has no defend spawns
    {severity = TAH.CONFIG_WARN, message = "One or more holds have no defender spawns linked.",
    tooltip = [[Defender spawns are used to place static NPCs at strategic locations around a hold point.
While not required, it is recommended to have several defender spawns per hold.
Spawn the spawn entities in the Entities - Take and Hold category, then use the Spawn Linker tool to connect them to the hold.
A connected defender spawn will show a green line between it and the hold.]]},

    -- 8. Hold has no patrol spawns
    {severity = TAH.CONFIG_WARN, message = "One or more holds have no patrol spawns linked.",
    tooltip = [[Patrol spawns are used to spawn additional enemies beyond the hold in between waves.
While not required, it is recommended to have several patrol spawns per hold.
Spawn the spawn entities in the Entities - Take and Hold category, then use the Spawn Linker tool to connect them to the hold.
A connected defender spawn will show a blue line between it and the hold.]]},

    -- 9. All good
    {severity = TAH.CONFIG_INFO, message = "You're all set!",
    tooltip = [[If there's an issue with the current setup, it will be shown in the list here.]]},

    -- 10. No NPC Nodes
    {severity = TAH.CONFIG_ERROR, message = "This map has no NPC nodes.",
    tooltip = [[A nodegraph for the map is required for NPCs to move around.
If a map does not have NPC nodes, you need to find it on the Workshop or make your own.]]},

}

if SERVER then
    util.AddNetworkString("tah_checkconfig")

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
        if #holds < 2 then
            messages = messages + 2 ^ 0
            allow_start = false
        elseif #holds < 5 then
            messages = messages + 2 ^ 1
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
                if i == 5 or i == 6 then
                    allow_start = false
                end
            end
        end

        local nodefile = "maps/graphs/" .. game.GetMap() .. ".ain"
        if file.Size(nodefile, "GAME") < 128 then
            messages = messages + 2 ^ 9
            allow_start = false
        end

        if messages == 0 then
            return 2 ^ 8, true
        else
            return messages, allow_start
        end
    end

    net.Receive("tah_checkconfig", function(len, ply)
        if not ply:IsAdmin() then return end

        local msg, ok = TAH:CheckConfig()

        net.Start("tah_checkconfig")
            net.WriteUInt(msg, 32)
            net.WriteBool(ok)

            if not game.SinglePlayer() then
                local files = file.Find("tah/" .. game.GetMap() .. "/*.json", "DATA")
                net.WriteUInt(table.Count(files), 10)
                for _, str in pairs(files) do
                    net.WriteString(string.sub(str, 0, -6))
                end
            end
        net.Send(ply)
    end)
else
    TAH.ConfigStatus = TAH.ConfigStatus or 0
    TAH.ConfigOK = TAH.ConfigOK or false
    TAH.ConfigLayouts = TAH.ConfigLayouts or {}
    net.Receive("tah_checkconfig", function()
        TAH.ConfigStatus = net.ReadUInt(32)
        TAH.ConfigOK = net.ReadBool()
        TAH.ConfigLayouts = {["New Layout..."] = ""}

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
end