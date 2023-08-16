-- This table holds the current map configuration and is used to save/load configs.
TAH.Metadata = {
    {}, -- Hold zones
    {}, -- Supply zones
    {}, -- Props
}

TAH.RoundData = {
    [1] = {
        defend_spawns = {
            {"metropolice_easy", 4},
        },
        patrol_spawns = {
            {"metropolice_easy", 5},
        },
        tokens = 3,

        waves = {
            [1] = {
                wave_duration = 90,
                wave_interval = {8, 12},
                wave_spawns = {
                    {"metropolice_hard", 2},
                    {"metropolice_easy", 4},
                },

                node_duration = 30,
                node_count = 3,
                node_variety = 1,
                node_spawns = {"tah_node_base"},
            },
        }
    },
    [2] = {
        defend_spawns = {
            {"metropolice_hard", 4},
        },
        patrol_spawns = {
            {"metropolice_easy", 6},
            {"metropolice_hard", 4},
        },
        tokens = 3,

        waves = {
            [1] = {
                wave_duration = 90,
                wave_interval = {12, 15},
                wave_spawns = {
                    {"metropolice_hard", 3},
                    {"metropolice_easy", 5},
                },

                node_duration = 30,
                node_count = 3,
                node_variety = 1,
                node_spawns = {"tah_node_base"},
            },
            [2] = {
                wave_duration = 90,
                wave_interval = {9, 13},
                wave_spawns = {
                    {"metropolice_hard", 3},
                    {"metropolice_easy", 5},
                },

                node_duration = 30,
                node_count = 5,
                node_variety = 1,
                node_spawns = {"tah_node_base"},
            },
        }
    },
}

TAH.EnemyData = {
    ["metropolice_easy"] = {
        ent = "npc_metropolice",
        wep = {"weapon_stunstick", "weapon_pistol", "weapon_pistol"},
        hp = 40,
        prof = WEAPON_PROFICIENCY_POOR,
        spawnflags = 131072, -- "enables more dramatic flinch animations"
        keyvalues = {["manhacks"] = "0", ["weapondrawn"] = "1"},
    },
    ["metropolice_hard"] = {
        ent = "npc_metropolice",
        wep = {"weapon_smg1", "weapon_smg1", "weapon_pistol"},
        hp = 40,
        prof = WEAPON_PROFICIENCY_AVERAGE,
        keyvalues = {["manhacks"] = {"0", "0", "1"}, ["weapondrawn"] = "1"},
    },
    ["combine_soldier_easy"] = {
        ent = "npc_combine_s",
        wep = "weapon_smg1",
        hp = 60,
        prof = WEAPON_PROFICIENCY_AVERAGE,
        spawnflags = nil,
        keyvalues = {["tacticalvariant"] = "0", ["NumGrenades"] = "0"},
    },
    ["combine_soldier_aggro"] = {
        ent = "npc_combine_s",
        model = nil,
        wep = {"weapon_smg1", "weapon_shotgun", "weapon_shotgun"},
        skin = 1,
        hp = 60,
        prof = WEAPON_PROFICIENCY_POOR,
        spawnflags = nil,
        keyvalues = {["tacticalvariant"] = "2", ["NumGrenades"] = {"0", "0", "1"}},
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