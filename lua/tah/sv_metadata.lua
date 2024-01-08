-- This table holds the current map configuration and is used to save/load configs.
TAH.Metadata = {
    {}, -- Hold zones
    {}, -- Supply zones
    {}, -- Props
}

TAH.Spawn_Cache = TAH.Spawn_Cache or {}

TAH.RoundData = {
    [1] = {
        defend_spawns = {
            {"metropolice_easy", 4},
        },
        defend_static_spawns = {
            "metropolice_hard",
            "metropolice_hard",
            "turret_floor",
        },
        defend_static_spawn_amount = 3,
        patrol_spawns = {
            {"metropolice_easy", 5},
        },
        tokens = 3,

        wave = {
            wave_duration = 90,
            wave_interval = 12,
            wave_spawns = {
                {"metropolice_hard", "metropolice_easy", "scanner"},
                {"metropolice_easy", 3},
                {"scanner", "scanner", "metropolice_easy", "metropolice_easy"},
            },
        }
    },
    --[[]
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
                wave_interval = {12, 18},
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
                wave_interval = {12, 15},
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
    ]]
}

TAH.EnemyData = {
    ["scanner"] = {
        ent = "npc_cscanner",
        hp = 60,
        assault = 1,
    },
    ["turret_floor"] = {
        ent = "npc_turret_floor",
    },
    ["metropolice_easy"] = {
        ent = "npc_metropolice",
        wep = {"weapon_stunstick", "tacrp_vertec", "tacrp_ex_glock", "tacrp_civ_mp5"},
        hp = 80,
        prof = WEAPON_PROFICIENCY_POOR,
        longrange = 0.25,
        spawnflags = 131072, -- "enables more dramatic flinch animations"
        keyvalues = {["manhacks"] = "0", ["weapondrawn"] = "1"},
    },
    ["metropolice_hard"] = {
        ent = "npc_metropolice",
        wep = {"tacrp_mp5", "tacrp_ex_ump45", "tacrp_p2000", "tacrp_ex_usp"},
        hp = 90,
        prof = WEAPON_PROFICIENCY_POOR,
        longrange = 0.25,
        keyvalues = {["manhacks"] = {"0", "0", "1"}, ["weapondrawn"] = "1"},
    },
    ["combine_soldier_easy"] = {
        ent = "npc_combine_s",
        wep = {"tacrp_m4", "tacrp_ex_m4a1"},
        hp = 100,
        prof = WEAPON_PROFICIENCY_AVERAGE,
        spawnflags = SF_NPC_NO_PLAYER_PUSHAWAY,
        longrange = 0.25,
        keyvalues = {["tacticalvariant"] = "0", ["NumGrenades"] = {"0", "0", "1"}},
    },
    ["combine_soldier_aggro"] = {
        ent = "npc_combine_s",
        model = nil,
        wep = {"tacrp_mp7", "tacrp_tgs12", "tacrp_tgs12"},
        skin = 1,
        hp = 100,
        prof = WEAPON_PROFICIENCY_POOR,
        spawnflags = SF_NPC_NO_PLAYER_PUSHAWAY,
        keyvalues = {["tacticalvariant"] = "2", ["NumGrenades"] = {"0", "0", "1"}},
    },
    ["combine_soldier_hard"] = {
        ent = "npc_combine_s",
        wep = {"tacrp_sg551", "tacrp_pdw"},
        model = "models/combine_soldier_prisonguard.mdl",
        hp = 125,
        prof = WEAPON_PROFICIENCY_GOOD,
        spawnflags = SF_NPC_NO_PLAYER_PUSHAWAY,
        longrange = 0.4,
        keyvalues = {["tacticalvariant"] = "0", ["NumGrenades"] = {"1", "2", "3"}},
    },
    ["combine_soldier_hard_aggro"] = {
        ent = "npc_combine_s",
        wep = {"tacrp_superv", "tacrp_fp6", "tacrp_fp6"},
        model = "models/combine_soldier_prisonguard.mdl",
        skin = 1,
        hp = 125,
        prof = WEAPON_PROFICIENCY_AVERAGE,
        spawnflags = SF_NPC_NO_PLAYER_PUSHAWAY,
        keyvalues = {["tacticalvariant"] = "2", ["NumGrenades"] = {"1", "2", "3"}},
    },
    ["combine_elite"] = {
        ent = "npc_combine_s",
        wep = {"tacrp_hk417", "tacrp_hk417", "tacrp_uratio"},
        model = "models/combine_super_soldier.mdl",
        hp = 150,
        longrange = 0.5,
        prof = WEAPON_PROFICIENCY_GOOD,
        spawnflags = SF_NPC_NO_PLAYER_PUSHAWAY + 262144, -- Don't drop ar2 alt fire (elite only)
        keyvalues = {["tacticalvariant"] = "0", ["NumGrenades"] = {"3", "4", "5"}},
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