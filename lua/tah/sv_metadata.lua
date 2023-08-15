-- This table holds the current map configuration and is used to save/load configs.
TAH.Metadata = {
    {}, -- Hold zones
    {}, -- Supply zones
    {}, -- Props
}

TAH.WaveData = {
    [1] = {
        [1] = {
            wave_duration = 60,
            node_duration = 60,
            wave_count = 5,
            node_count = 3,
            wave_spawns = {
                {"combine_soldier_easy", 3},
            },
            node_types = {"tah_node_base"},
        },
    }
}

TAH.EnemyData = {
    ["combine_soldier_easy"] = {
        ent = "npc_combine_s",
        model = nil,
        wep = "weapon_smg1",
        hp = 50,
        prof = WEAPON_PROFICIENCY_AVERAGE,
        spawnflags = nil,
        keyvalues = {["tacticalvariant"] = "0"},
    },
}

function TAH:IsValidMetadata(tbl)
    return true
end

function TAH:SaveMetadata(name)
    file.Write(string.lower("tah/" .. game.GetMap() .. "/" .. name .. ".txt"), util.TableToJSON(TAH.Metadata, false))
end

function TAH:LoadMetadata(name)
    local tbl = file.Read(string.lower("tah/" .. game.GetMap() .. "/" .. name .. ".txt"))
    if self:IsValidMetadata(tbl) then
        TAH.Metadata = tbl
    else
        TAH.Metadata = {{}, {}, {}}
    end
end