util.AddNetworkString("tah_loadout")

function TAH:GiveLoadoutEntry(ply, info)
    if info.class then
        ply:Give(info.class)
    end

    if info.ammo_count and info.ammo_type then
        ply:GiveAmmo(ammo_count, ammo_type)
    end

    if info.func then
        info.func(ply)
    end
end

net.Receive("tah_loadout", function(len, ply)
    local entries = {}
    local total_budget = 0

    -- TODO: Check if player is even allowed to get a loadout at this moment

    for i = 1, net.ReadUInt(4) do
        local cat = net.ReadUInt(3)
        local index = net.ReadUInt(8)
        local entry = TAH.LoadoutEntries[cat] and TAH.LoadoutEntries[cat][index]
        if not entry then continue end
        table.insert(entries, entry)
        total_budget = total_budget + (entry.cost or 0)
    end

    -- no fraud attempt allowed
    if total_budget > TAH:GetPlayerBudget(ply) then return end

    for _, info in entries do
        TAH:GiveLoadoutEntry(ply, info)
    end
end)