util.AddNetworkString("tah_loadout")

function TAH:GiveLoadoutEntry(ply, info)
    if info.class then
        ply:Give(info.class, info.nodefaultclip)
    end

    if info.ammo_count and info.ammo_type then
        ply:GiveAmmo(info.ammo_count, info.ammo_type)
    end

    if info.func then
        info.func(ply)
    end
end

net.Receive("tah_loadout", function(len, ply)
    local entries = {}
    local total_budget = 0

    if not ply.TAH_Loadout or TAH:GetRoundState() ~= TAH.ROUND_SETUP then return end

    for i = 1, TAH.LOADOUT_LAST do
        for j = 1, net.ReadUInt(4) do
            local index = net.ReadUInt(8)


            -- Ensure the player actually rolled this entry
            local entry = TAH.LoadoutEntries[i][index]
            print(i, index, table.ToString(entry))
            if not entry or not table.HasValue(ply.TAH_Loadout[i], index) then continue end

            table.insert(entries, entry)
            total_budget = total_budget + (entry.cost or 0)
        end
    end

    PrintTable(entries)

    -- no fraud attempt allowed
    if total_budget > TAH:GetPlayerBudget(ply) then return end

    for _, info in pairs(entries) do
        TAH:GiveLoadoutEntry(ply, info)
    end
    ply.TAH_Loadout = nil
    ply:Freeze(false)
end)