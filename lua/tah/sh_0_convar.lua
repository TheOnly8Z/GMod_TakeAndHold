TAH.ConVars = {}

TAH.ConVars["game_difficulty"]      = CreateConVar("tah_game_difficulty", "1", FCVAR_ARCHIVE + FCVAR_REPLICATED + FCVAR_NOTIFY, "Game difficulty. 0 - Casual, 1 - Standard, 2 - Tactical.", 0, 2)
TAH.ConVars["game_sandbox"]         = CreateConVar("tah_game_sandbox", "0", FCVAR_ARCHIVE + FCVAR_REPLICATED + FCVAR_NOTIFY, "Allow various sandbox mechanics (spawnmenu, properties menu, noclip) while game is active.", 0, 1)
TAH.ConVars["game_mobilitynerf"]    = CreateConVar("tah_game_mobilitynerf", "1", FCVAR_ARCHIVE + FCVAR_REPLICATED + FCVAR_NOTIFY, "Reduce player mobility while game is active, notably nerfing sprint jumping.", 0, 1)
TAH.ConVars["game_friendlyfire"]    = CreateConVar("tah_game_friendlyfire", "1", FCVAR_ARCHIVE + FCVAR_REPLICATED + FCVAR_NOTIFY, "Enable friendly fire among players. Friendly fire damage is additionally scaled by difficulty.", 0, 1)
TAH.ConVars["game_limitedammo"]     = CreateConVar("tah_game_limitedammo", "0", FCVAR_ARCHIVE + FCVAR_REPLICATED + FCVAR_NOTIFY, "Enable limited ammo mode, requiring players to scavenge for bullets.", 0, 1)
TAH.ConVars["game_applyconvars"]    = CreateConVar("tah_game_applyconvars", "1", FCVAR_ARCHIVE + FCVAR_REPLICATED + FCVAR_NOTIFY, "Apply recommended ConVars for TacRP and Danger Zone Entities.", 0, 1)
TAH.ConVars["game_playerscaling"]   = CreateConVar("tah_game_playerscaling", "1", FCVAR_ARCHIVE + FCVAR_REPLICATED + FCVAR_NOTIFY, "Scale enemy count with player count.", 0, 1)

-- Can be a table if it varies per difficulty
TAH.ExternalConVars = {
    ["tacrp_balance"] = 0,
    ["tacrp_npc_atts"] = 0,
    ["tacrp_npc_equality"] = 0,
    ["tacrp_expandedammotypes"] = 0,
    ["tacrp_holster"] = 1,
    ["tacrp_free_atts"] = 0,
    ["tacrp_lock_atts"] = 0,
    ["tacrp_loseattsondie"] = 0,

    ["tacrp_slot_hl2"] = 0,
    ["tacrp_slot_limit"] = {0, 0, 1},

    ["tacrp_sprint_reload"] = 0,
    ["tacrp_penalty_move"] = 1,
    ["tacrp_penalty_firing"] = 1,
    ["tacrp_penalty_aiming"] = 1,
    ["tacrp_penalty_reload"] = 1,
    ["tacrp_penalty_melee"] = 1,

    -- ["tacrp_infiniteammo"] = 1, -- handled elsewhere
    ["tacrp_infinitelaunchers"] = 0,
    ["tacrp_infinitegrenades"] = 0,
    ["tacrp_defaultammo"] = 4,

    ["tacrp_mult_damage"] = 1,
    ["tacrp_mult_damage_shotgun"] = 1,
    ["tacrp_mult_damage_sniper"] = 1.25,
    ["tacrp_mult_damage_magnum"] = 1.25,
    ["tacrp_mult_damage_explosive"] = 1.5,
    ["tacrp_mult_damage_melee"] = 2,
    ["tacrp_mult_headshot"] = 0.75,

    ["tacrp_smoke_affectnpcs"] = 1,
    ["tacrp_flash_affectnpcs"] = 1,
    ["tacrp_flash_affectplayers"] = 1,
    ["tacrp_gas_affectplayers"] = 1,
    ["tacrp_thermite_damage_min"] = 25,
    ["tacrp_thermite_damage_max"] = 50,
    ["tacrp_thermite_radius"] = 160,
    ["tacrp_frag_damage"] = 150,
    ["tacrp_frag_radius"] = 350,
    ["tacrp_charge_damage"] = 500,
    ["tacrp_charge_radius"] = 256,
    ["tacrp_c4_damage"] = 500,
    ["tacrp_c4_radius"] = 512,
    ["tacrp_healnade_heal"] = 2,
    ["tacrp_healnade_armor"] = 0,
    ["tacrp_healnade_damage"] = 20,
    ["tacrp_max_grenades"] = 9,

    ["tacrp_medkit_clipsize"] = 30,
    ["tacrp_medkit_regen_activeonly"] = 0,
    ["tacrp_medkit_regen_delay"] = {3, 4, 5},
    ["tacrp_medkit_regen_amount"] = 1,
    ["tacrp_medkit_heal_self"] = 3,
    ["tacrp_medkit_heal_others"] = 4,
    ["tacrp_medkit_interval"] = 0.2,

    ["tacrp_shield_melee"] = 1,
    ["tacrp_shield_riot_hp"] = 0,
    ["tacrp_shield_knockback"] = 1,
    ["tacrp_shield_riot_resistance"] = 2,

    ["dzents_case_cleanup"] = 5,
    ["dzents_case_shrink"] = 1,
    ["dzents_ammo_clip"] = 0,
    ["dzents_ammo_mult"] = {4, 3, 2},
    ["dzents_ammo_limit"] = 1,
    ["dzents_bumpmine_maxammo"] = 9,

    ["dzents_armor_enabled"] = 1,
    ["dzents_armor_fallback"] = 0,
    ["dzents_armor_onspawn"] = 0,
    ["dzents_armor_damage"] = 1,
    ["dzents_armor_durability"] = {0.8, 0.9, 1},
    ["dzents_armor_heavy_damage"] = 0.85,
    ["dzents_armor_heavy_durability"] = 1,
    ["dzents_drop_armor"] = 0,
    ["dzents_drop_equip"] = 0,

    ["dzents_pickup_instantuse"] = 1,
    ["dzents_healthshot_health"] = {90, 75, 60},
    ["dzents_healthshot_use_at_full"] = 0,
    ["dzents_healthshot_healtime"] = 3,
    ["dzents_healthshot_damage_dealt"] = 1,
    ["dzents_healthshot_damage_taken"] = {1, 1, 1.25},
    ["dzents_healthshot_speed"] = 1,
    ["dzents_healthshot_duration"] = 3,
    ["dzents_healthshot_maxammo"] = 3,
}

local function disable_during_game(ply)
    if not TAH.ConVars["game_sandbox"]:GetBool() and TAH:IsGameActive() then
        ply:PrintMessage(HUD_PRINTCENTER, "Sandbox functionality is disabled while Tactical Takeover is active.")
        return false
    end
end

hook.Add("PlayerNoClip", "tah_convar", function(ply, state)
    if state and not TAH.ConVars["game_sandbox"]:GetBool() and TAH:IsGameActive() then
        return false
    end
end)

hook.Add("PlayerSpawnObject", "tah_convar", disable_during_game)
hook.Add("PlayerSpawnSWEP", "tah_convar", disable_during_game)
hook.Add("PlayerGiveSWEP", "tah_convar", disable_during_game)
hook.Add("PlayerSpawnVehicle", "tah_convar", disable_during_game)
hook.Add("PlayerSpawnNPC", "tah_convar", disable_during_game)
hook.Add("PlayerSpawnSENT", "tah_convar", disable_during_game)
hook.Add("CanProperty", "tah_convar", disable_during_game)
hook.Add("CanTool", "tah_convar", disable_during_game)

if SERVER then

    function TAH:ApplyConVars()
        if not self.ConVars["game_applyconvars"]:GetBool() then return end

        local diff = self.ConVars["game_difficulty"]:GetInt()

        for k, v in pairs(self.ExternalConVars) do
            if GetConVar(k) then
                if istable(v) then
                    v = v[diff + 1]
                end
                RunConsoleCommand(k, tostring(v))
                --[[]
                if isstring(v) then
                    GetConVar(k):SetString(v)
                else
                    GetConVar(k):SetFloat(v)
                end
                ]]
            end
        end

        TacRP.ConVars["infiniteammo"]:SetBool(not self.ConVars["game_limitedammo"]:GetBool())
        -- TacRP.ConVars["flash_affectplayers"]:SetBool(self.ConVars["game_friendlyfire"]:GetBool())
        -- TacRP.ConVars["gas_affectplayers"]:SetBool(self.ConVars["game_friendlyfire"]:GetBool())

        RunConsoleCommand("sk_npc_dmg_stunstick", "80") -- this ends up doing 20 damage for some reason

        -- duh
        RunConsoleCommand("ai_disabled", "0")
        RunConsoleCommand("ai_ignoreplayers", "0")

        -- adjust maximum ammo
        if self.ConVars["game_limitedammo"]:GetBool() then
            RunConsoleCommand("gmod_maxammo", "9999") -- using engine ammo capacity is not worth the issues
            RunConsoleCommand("sk_max_pistol", "300")
            RunConsoleCommand("sk_max_357", "60")
            RunConsoleCommand("sk_max_smg1", "300")
            RunConsoleCommand("sk_max_ar2", "200")
            RunConsoleCommand("sk_max_buckshot", "48")
            RunConsoleCommand("sk_max_crossbow", "100")
        end
    end

    function TAH:GetPlayerScaling(target)
        if not self.ConVars["game_playerscaling"]:GetBool() then
            return 1
        end
        return Lerp(((#TAH.ActivePlayers - 1) / 9) ^ 1.5, 1, target)
    end
end