TAH.RoundData = {
    [1] = {
        defend_spawns = {
            {"metropolice_easy", 3},
        },
        defend_static_spawns = {
            "metropolice_hard",
        },
        defend_static_spawn_amount = 2,
        patrol_spawns = {
            {"metropolice_easy", 4},
        },
        patrol_spawn_amount = 3,

        tokens = {9, 8, 7},
        crates = {7, 6, 5},

        wave = {
            wave_duration = 90,
            wave_interval = 17,
            wave_spawns = {
                {"metropolice_melee", 3},
                {"metropolice_easy", 3},
                {"metropolice_longrange", 2},
            },
            elite_spawns = {
                {"cmbevo_metropolice_riot", 2},
                {"cmbevo_metropolice_elite", 1},
            },
            elite_count = {0, 1, 2},
        }
    },
    [2] = {
        defend_spawns = {
            {"metropolice_hard", 5},
        },
        defend_static_spawns = {
            "turret_floor",
            "metropolice_hard",
            "metropolice_hard",
            "metropolice_longrange",
        },
        defend_static_spawn_amount = 3,
        patrol_spawns = {
            {"metropolice_easy", 5},
            {"metropolice_hard", 4},
            {"metropolice_longrange", 2},
        },
        patrol_spawn_amount = 3,

        tokens = {12, 10, 8},
        crates = {8, 7, 6},

        wave = {
            wave_duration = 90,
            wave_interval = 15,
            wave_spawns = {
                {"metropolice_assault", 3},
                {"metropolice_hard", 2},
                {"metropolice_easy", 3},
                {"metropolice_longrange", 2},
            },
            elite_spawns = {
                {"cmbevo_metropolice_elite", 2},
                {"cmbevo_metropolice_riot", 3},
            },
            elite_count = {1, 1, 2},
        }
    },
    [3] = {
        defend_spawns = {
            {"combine_soldier_easy", 4},
        },
        defend_static_spawns = {
            "turret_floor",
            "combine_soldier_hard",
            "combine_soldier_hard",
        },
        defend_static_spawn_amount = 4,
        patrol_spawns = {
            {"combine_soldier_easy", 3},
        },
        patrol_spawn_amount = 3,

        tokens = {18, 15, 13},
        crates = {9, 8, 7},

        wave = {
            wave_duration = 90,
            wave_interval = 17,
            wave_spawns = {
                {"combine_soldier_easy", 2},
                {"combine_soldier_easy", 3},
                {"combine_soldier_aggro", 2},
            },
            elite_spawns = {
                {"cmbevo_armored_soldier", 3},
                {"cmbevo_metropolice_riot", 2},
            },
            elite_count = {0, 1, 2},
        }
    },
    [4] = {
        defend_spawns = {
            {"combine_soldier_hard", 3},
        },
        defend_static_spawns = {
            "turret_floor",
            "combine_elite",
        },
        defend_static_spawn_amount = 4,
        patrol_spawns = {
            {"combine_soldier_easy", 4},
            {"combine_soldier_hard", 3},
        },
        patrol_spawn_amount = 4,

        tokens = {24, 20, 16},
        crates = {12, 10, 8},

        wave = {
            wave_duration = 120,
            wave_interval = 17,
            wave_spawns = {
                {"combine_soldier_easy", 3},
                {"combine_soldier_aggro", 2},
                {"combine_soldier_hard", 2},
                {"combine_soldier_hard_aggro", 2},
                {"combine_elite", "combine_soldier_hard"},
            },
            elite_spawns = {
                {"cmbevo_armored_soldier", 3},
                {"cmbevo_metropolice_riot", 2},
            },
            elite_count = {1, 1, 2},
        }
    },
    [5] = {
        defend_spawns = {
            {"combine_elite", 5},
        },
        defend_static_spawns = {
            "turret_floor",
            "combine_elite",
        },
        defend_static_spawn_amount = 4,
        patrol_spawns = {
            {"combine_soldier_easy", 4},
            {"combine_soldier_hard", 3},
        },
        patrol_spawn_amount = 5,

        tokens = {28, 25, 22},
        crates = {15, 12, 10},

        wave = {
            wave_duration = 180,
            wave_interval = 20,
            wave_spawns = {
                {"combine_soldier_easy", 3},
                {"combine_soldier_easy", 3},
                {"combine_soldier_hard", 2},
                {"combine_soldier_hard", 2},
                {"combine_soldier_hard_aggro", 2},
                {"combine_soldier_hard_aggro", 2},
                {"combine_elite", 2},
                {"combine_elite", 2},
                {"hunter"},
            },
            elite_spawns = {
                {"cmbevo_armored_soldier", 4},
            },
            elite_count = {1, 2, 3},
        }
    },
}

TAH.EnemyData = {
    -- Scanners don't really navigate well...
    ["scanner"] = {
        ent = "npc_cscanner",
        hp = 40,
        assault = 0,
        scale_damage = 1.5, -- when they crash into you
    },
    ["scanner_claw"] = {
        ent = "npc_clawscanner",
        hp = 70,
        assault = 0,
        scale_damage = 1.5, -- when they crash into you
        input = "EquipMine",
    },
    ["turret_floor"] = {
        ent = "npc_turret_floor",
        scale_damage = 2,
    },
    ["metropolice_melee"] = {
        ent = "npc_metropolice",
        wep = {"weapon_stunstick"},
        hp = 50,
        prof = WEAPON_PROFICIENCY_POOR,
        longrange = 0,
        spawnflags = 131072, -- "enables more dramatic flinch animations"
        keyvalues = {["manhacks"] = {"0", "0", "1"}, ["weapondrawn"] = "1"},
        scale_damage = 1.5,
    },
    ["metropolice_easy"] = {
        ent = "npc_metropolice",
        wep = {"tacrp_vertec"},
        hp = 50,
        prof = WEAPON_PROFICIENCY_POOR,
        longrange = 0.25,
        spawnflags = 131072, -- "enables more dramatic flinch animations"
        keyvalues = {["manhacks"] = "0", ["weapondrawn"] = "1"},
        scale_damage = 0.5,
    },
    ["metropolice_hard"] = {
        ent = "npc_metropolice",
        wep = {"tacrp_skorpion", "tacrp_p2000"},
        hp = 50,
        prof = WEAPON_PROFICIENCY_POOR,
        longrange = 0.5,
        assault = 0.5,
        keyvalues = {["manhacks"] = {"0", "0", "1"}, ["weapondrawn"] = "1"},
        scale_damage = 0.5,
    },
    ["metropolice_assault"] = {
        ent = "npc_metropolice",
        wep = {"tacrp_skorpion"},
        hp = 50,
        prof = WEAPON_PROFICIENCY_POOR,
        assault = 1,
        keyvalues = {["manhacks"] = "0", ["weapondrawn"] = "1"},
        scale_damage = 0.5,
    },
    ["metropolice_longrange"] = {
        ent = "npc_metropolice",
        wep = {"tacrp_civ_g36k"},
        hp = 50,
        prof = WEAPON_PROFICIENCY_GOOD,
        longrange = 1,
        assault = 0,
        keyvalues = {["manhacks"] = {"0", "0", "1"}, ["weapondrawn"] = "1"},
        scale_damage = 0.3,
    },
    ["combine_soldier_easy"] = {
        ent = "npc_combine_s",
        wep = {"tacrp_aug"},
        hp = 70,
        prof = WEAPON_PROFICIENCY_AVERAGE,
        spawnflags = SF_NPC_NO_PLAYER_PUSHAWAY + 131072, -- 131072: dont drop grenades
        longrange = 0.5,
        keyvalues = {["tacticalvariant"] = {"0", "0", "2"}, ["NumGrenades"] = {"0", "1", "2"}},
        scale_damage = 0.4,
    },
    ["combine_soldier_aggro"] = {
        ent = "npc_combine_s",
        model = nil,
        wep = {"tacrp_fp6"},
        skin = 1,
        hp = 70,
        prof = WEAPON_PROFICIENCY_POOR,
        spawnflags = SF_NPC_NO_PLAYER_PUSHAWAY + 131072,
        assault = 0.5,
        keyvalues = {["tacticalvariant"] = "1", ["NumGrenades"] = {"0", "1", "2"}},
        scale_damage = 0.4,
    },
    ["combine_soldier_hard"] = {
        ent = "npc_combine_s",
        wep = {"tacrp_dsa58", "tacrp_m4", "tacrp_mp7"},
        model = "models/combine_soldier_prisonguard.mdl",
        hp = 80,
        prof = WEAPON_PROFICIENCY_GOOD,
        spawnflags = SF_NPC_NO_PLAYER_PUSHAWAY + 131072,
        longrange = 0.5,
        keyvalues = {["tacticalvariant"] = {"0", "0", "2"}, ["NumGrenades"] = {"3", "4", "5"}},
        scale_damage = 0.4,
    },
    ["combine_soldier_hard_aggro"] = {
        ent = "npc_combine_s",
        wep = {"tacrp_m4star10"},
        model = "models/combine_soldier_prisonguard.mdl",
        skin = 1,
        hp = 80,
        prof = WEAPON_PROFICIENCY_AVERAGE,
        spawnflags = SF_NPC_NO_PLAYER_PUSHAWAY + 131072,
        assault = 0.5,
        keyvalues = {["tacticalvariant"] = "1", ["NumGrenades"] = {"3", "4", "5"}},
        scale_damage = 0.3,
    },
    ["combine_elite"] = {
        ent = "npc_combine_s",
        wep = "weapon_ar2",
        model = "models/combine_super_soldier.mdl",
        hp = 120,
        longrange = 0.5,
        assault = 0.25,
        prof = WEAPON_PROFICIENCY_GOOD,
        spawnflags = SF_NPC_NO_PLAYER_PUSHAWAY + 262144, -- Don't drop ar2 alt fire (elite only)
        keyvalues = {["tacticalvariant"] = {"0", "1", "2"}, ["NumGrenades"] = {"1", "3", "5"}},
        scale_damage = 2.5,
    },
    ["hunter"] = {
        ent = "npc_hunter", -- now that EP2 comes with HL2 I finally have an excuse to use episodic content!
        hp = 350,
        prof = WEAPON_PROFICIENCY_POOR, -- does not matter
    },

    ["cmbevo_metropolice_riot"] = {
        ent = "npc_metropolice",
        wep = {"weapon_stunstick"},
        model = "models/cmb_evo/police_riot.mdl",
        hp = 50,
        prof = WEAPON_PROFICIENCY_POOR,
        longrange = 0,
        spawnflags = 0,
        keyvalues = {["parentname"] = "cmbevo_metropolice_riot", ["manhacks"] = {"0", "0", "1"}, ["weapondrawn"] = "1"},
        scale_damage = 1.5,
    },

    ["cmbevo_metropolice_elite"] = {
        ent = "npc_metropolice",
        wep = {"cmbevo_357"},
        model = "models/cmb_evo/police_elite_armored.mdl",
        hp = 80,
        prof = WEAPON_PROFICIENCY_POOR,
        longrange = 1,
        spawnflags = 0,
        keyvalues = {["parentname"] = "cmbevo_metropolice_elite", ["manhacks"] = {"0", "0", "1"}, ["weapondrawn"] = "1"},
    },

    ["cmbevo_armored_soldier"] = {
        ent = "npc_combine_s",
        wep = {"tacrp_mp5"},
        model = "models/cmb_evo/armored_soldier_new.mdl",
        hp = 70,
        prof = WEAPON_PROFICIENCY_AVERAGE,
        spawnflags = SF_NPC_NO_PLAYER_PUSHAWAY + 131072, -- 131072: dont drop grenades
        longrange = 0,
        assault = 0.5,
        keyvalues = {["parentname"] = "cmbevo_armored_soldier", ["tacticalvariant"] = "1", ["NumGrenades"] = {"0", "1", "2"}},
        scale_damage = 0.4,
    },
}
