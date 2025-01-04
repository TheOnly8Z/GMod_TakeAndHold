util.AddNetworkString("tah_savemetadata")
util.AddNetworkString("tah_loadmetadata")

-- This table holds the current map configuration and is used to save/load configs.
TAH.Metadata = {
    --[[
    DataVersion = 1,
    FileName = "default.json",
    Name = "Default Configuration",
    Holds = {},

    ]]
}

TAH.Spawn_Cache = TAH.Spawn_Cache or {}

TAH.RoundData = {
    [1] = {
        defend_spawns = {
            {"metropolice_easy", 3},
        },
        defend_static_spawns = {
            "metropolice_easy",
            "metropolice_hard",
            "turret_floor",
        },
        defend_static_spawn_amount = 2,
        patrol_spawns = {
            {"metropolice_easy", 5},
        },
        tokens = 3,

        wave = {
            wave_duration = 90,
            wave_interval = 15,
            wave_spawns = {
                {"metropolice_hard", "metropolice_easy", "scanner"},
                {"metropolice_easy", 3},
                {"scanner", "scanner", "metropolice_easy", "metropolice_easy"},
            },
        }
    },
    [2] = {
        defend_spawns = {
            {"metropolice_hard", 4},
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
        tokens = 5,

        wave = {
            wave_duration = 90,
            wave_interval = 15,
            wave_spawns = {
                {"metropolice_hard", "scanner", "scanner", "scanner"},
                {"metropolice_assault", 3},
                {"metropolice_easy", "metropolice_hard", "metropolice_assault"},
            },
        }
    },
    [3] = {
        defend_spawns = {
            {"combine_soldier_easy", 3},
        },
        defend_static_spawns = {
            "combine_soldier_easy",
            "combine_soldier_easy",
            "turret_floor",
        },
        defend_static_spawn_amount = 4,
        patrol_spawns = {
            {"combine_soldier_easy", 3},
        },
        tokens = 7,

        wave = {
            wave_duration = 90,
            wave_interval = 18,
            wave_spawns = {
                {"combine_soldier_easy", "scanner_claw"},
                {"combine_soldier_easy", 3},
                {"combine_soldier_aggro", "combine_soldier_aggro"},
            },
        }
    },
    [4] = {
        defend_spawns = {
            {"combine_soldier_easy", 5},
            {"combine_soldier_hard", 3},
        },
        defend_static_spawns = {
            "combine_soldier_hard",
            "combine_elite",
            "turret_floor",
        },
        defend_static_spawn_amount = 5,
        patrol_spawns = {
            {"combine_soldier_hard", 2},
            {"combine_soldier_hard", "combine_soldier_easy", "combine_soldier_easy"},
        },
        tokens = 10,

        wave = {
            wave_duration = 120,
            wave_interval = 18,
            wave_spawns = {
                {"combine_soldier_easy", 5},
                {"combine_soldier_hard", 3},
                {"combine_soldier_hard_aggro", 3},
                {"combine_elite", "combine_soldier_easy", "combine_soldier_easy"},
            },
        }
    },
    [5] = {
        defend_spawns = {
            {"combine_elite", 3},
            {"combine_soldier_hard", 5},
            {"combine_soldier_hard_aggro", 5},
        },
        defend_static_spawns = {
            "turret_floor",
            "combine_elite",
            "combine_elite",
        },
        defend_static_spawn_amount = 6,
        patrol_spawns = {
            {"combine_elite", 3},
            {"combine_soldier_hard", 5},
        },
        tokens = 10,

        wave = {
            wave_duration = 150,
            wave_interval = 20,
            wave_spawns = {
                {"combine_soldier_hard", 4},
                {"combine_soldier_hard_aggro", 4},
                {"combine_elite", 3},
                {"npc_hunter", 1},
            },
        }
    },
}

TAH.EnemyData = {
    ["scanner"] = {
        ent = "npc_cscanner",
        hp = 60,
        assault = 1,
        scale_damage = 1.5, -- when they crash into you
    },
    ["scanner_claw"] = {
        ent = "npc_clawscanner",
        hp = 90,
        assault = 1,
        scale_damage = 1.5, -- when they crash into you
    },
    ["turret_floor"] = {
        ent = "npc_turret_floor",
        scale_damage = 1.5,
    },
    ["metropolice_melee"] = {
        ent = "npc_metropolice",
        wep = {"weapon_stunstick"},
        hp = 60,
        prof = WEAPON_PROFICIENCY_POOR,
        longrange = 0,
        spawnflags = 131072, -- "enables more dramatic flinch animations"
        keyvalues = {["manhacks"] = "0", ["weapondrawn"] = "1"},
    },
    ["metropolice_easy"] = {
        ent = "npc_metropolice",
        wep = {"tacrp_vertec"},
        hp = 60,
        prof = WEAPON_PROFICIENCY_POOR,
        longrange = 0.25,
        spawnflags = 131072, -- "enables more dramatic flinch animations"
        keyvalues = {["manhacks"] = "0", ["weapondrawn"] = "1"},
        scale_damage = 0.6667,
    },
    ["metropolice_hard"] = {
        ent = "npc_metropolice",
        wep = {"tacrp_ex_ump45", "tacrp_p2000"},
        hp = 60,
        prof = WEAPON_PROFICIENCY_POOR,
        longrange = 0.5,
        keyvalues = {["manhacks"] = {"0", "0", "1"}, ["weapondrawn"] = "1"},
        scale_damage = 0.6667,
    },
    ["metropolice_assault"] = {
        ent = "npc_metropolice",
        wep = {"tacrp_skorpion"},
        hp = 60,
        prof = WEAPON_PROFICIENCY_POOR,
        assault = 1,
        keyvalues = {["manhacks"] = "0", ["weapondrawn"] = "1"},
        scale_damage = 0.6667,
    },
    ["combine_soldier_easy"] = {
        ent = "npc_combine_s",
        wep = {"tacrp_civ_g36k", "tacrp_mp5"},
        hp = 80,
        prof = WEAPON_PROFICIENCY_AVERAGE,
        spawnflags = SF_NPC_NO_PLAYER_PUSHAWAY,
        longrange = 0.5,
        keyvalues = {["tacticalvariant"] = "0", ["NumGrenades"] = {"0", "0", "1"}},
        scale_damage = 0.6667,
    },
    ["combine_soldier_aggro"] = {
        ent = "npc_combine_s",
        model = nil,
        wep = {"tacrp_tgs12"},
        skin = 1,
        hp = 80,
        prof = WEAPON_PROFICIENCY_POOR,
        spawnflags = SF_NPC_NO_PLAYER_PUSHAWAY,
        keyvalues = {["tacticalvariant"] = "2", ["NumGrenades"] = {"0", "0", "1"}},
        scale_damage = 0.6667,
    },
    ["combine_soldier_hard"] = {
        ent = "npc_combine_s",
        wep = {"tacrp_m4", "tacrp_mp7"},
        model = "models/combine_soldier_prisonguard.mdl",
        hp = 90,
        prof = WEAPON_PROFICIENCY_GOOD,
        spawnflags = SF_NPC_NO_PLAYER_PUSHAWAY,
        longrange = 0.5,
        keyvalues = {["tacticalvariant"] = "0", ["NumGrenades"] = {"1", "2", "3"}},
        scale_damage = 0.6667,
    },
    ["combine_soldier_hard_aggro"] = {
        ent = "npc_combine_s",
        wep = {"tacrp_fp6"},
        model = "models/combine_soldier_prisonguard.mdl",
        skin = 1,
        hp = 90,
        prof = WEAPON_PROFICIENCY_AVERAGE,
        spawnflags = SF_NPC_NO_PLAYER_PUSHAWAY,
        keyvalues = {["tacticalvariant"] = "2", ["NumGrenades"] = {"1", "2", "3"}},
        scale_damage = 0.6667,
    },
    ["combine_elite"] = {
        ent = "npc_combine_s",
        wep = "weapon_ar2",
        model = "models/combine_super_soldier.mdl",
        hp = 150,
        longrange = 0.5,
        prof = WEAPON_PROFICIENCY_VERY_GOOD,
        spawnflags = SF_NPC_NO_PLAYER_PUSHAWAY + 262144, -- Don't drop ar2 alt fire (elite only)
        keyvalues = {["tacticalvariant"] = "0", ["NumGrenades"] = {"0", "1", "1"}},
        -- scale_damage = 1.5,
    },
    ["hunter"] = {
        ent = "npc_hunter", -- now that EP2 comes with HL2 I finally have an excuse to use episodic content!
        hp = 350,
        longrange = 0,
        prof = WEAPON_PROFICIENCY_POOR, -- does not matter
        keyvalues = {["tacticalvariant"] = "0", ["NumGrenades"] = {"3", "4", "5"}},
    },
}

function TAH:IsValidMetadata(tbl)
    return true
end

function TAH:GenerateMetadata(version)
    version = version or 1 -- future proof

    TAH.Metadata = {
        DataVersion = version,
        Holds = {},
        Spawns = {
            tah_spawn_attack = {},
            tah_spawn_defend = {},
            tah_spawn_patrol = {},
        },
    }

    TAH:SerializeHolds() -- Just in case

    for _, ent in pairs(ents.GetAll()) do
        if ent:GetClass() == "tah_holdpoint" then
            TAH.Metadata.Holds[ent:GetSerialID()] = ent:Serialize(version)
        elseif TAH.Metadata.Spawns[ent:GetClass()] then
            table.insert(TAH.Metadata.Spawns[ent:GetClass()], ent:Serialize(version))
        end
    end
end

function TAH:ApplyMetadata()
    game.CleanUpMap()

    local version = TAH.Metadata.DataVersion
    TAH.DEFER_SERIALIZATION = true

    for i, str in pairs(TAH.Metadata.Holds) do
        local ent = ents.Create("tah_holdpoint")
        ent:Deserialize(str, version)
        ent:Spawn()
    end

    for class, tbl in pairs(TAH.Metadata.Spawns) do
        for _, str in pairs(tbl) do
            local ent = ents.Create(class)
            ent:Deserialize(str, version)
            ent:Spawn()
        end
    end

    TAH.DEFER_SERIALIZATION = false
end

function TAH:SaveMetadata(name, version)
    name = name or os.date("%Y%m%d_%H%M%S")

    TAH:GenerateMetadata(version)

    if not file.IsDir("tah/" .. game.GetMap(), "DATA") then file.CreateDir("tah/" .. game.GetMap()) end
    file.Write(string.lower("tah/" .. game.GetMap() .. "/" .. name .. ".json"), util.TableToJSON(TAH.Metadata, true))

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
        TAH.Metadata = util.JSONToTable(tbl)
        TAH:ApplyMetadata()
        PrintMessage(HUD_PRINTTALK, "Loaded layout " .. name .. ".")
    else
        TAH.Metadata = {}
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