TAH.NextNPCSpawn = 0
TAH.UnusedHolds = TAH.UnusedHolds or {}
TAH.ActivePlayers = TAH.ActivePlayers or {}
TAH.CleanupEntities = TAH.CleanupEntities or {}

util.AddNetworkString("tah_startgame")
util.AddNetworkString("tah_finishgame")

function TAH:StartGame()
    self:SetCurrentRound(1)
    self:SetCurrentWave(0)
    self:SetWaveTime(-1)

    self:ApplyConVars()

    if TAH:GetParameter("linear") then
        -- Go by serial order
        self:SetHoldEntity(TAH.SerialIDToHold[1])
    else
        self.UnusedHolds = ents.FindByClass("tah_holdpoint")
        local viablestartingholds = {}
        for i, ent in pairs(TAH.UnusedHolds) do
            ent:SetOwnedByPlayers(false)
            ent:SetCaptureProgress(0)
            ent:SetCaptureState(0)
            if #TAH:GetLinkedSpawns(ent, "tah_spawn_player") > 0 then
                table.insert(viablestartingholds, i)
            end
        end
        local ind = viablestartingholds[math.random(1, #viablestartingholds)]
        local hold = table.remove(TAH.UnusedHolds, ind)
        self:SetHoldEntity(hold)
    end


    for _, ent in pairs(ents.FindByClass("tah_crate")) do
        ent:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
    end

    local ply_spawn = TAH:GetLinkedSpawns(self:GetHoldEntity(), "tah_spawn_player")
    if #ply_spawn > 0 then
        ply_spawn = ply_spawn[math.random(1, #ply_spawn)]
    else
        ply_spawn = nil
    end

    for _, ply in pairs(player.GetAll()) do
        self:SetTokens(ply, self:GetPlayerStartingToken(ply))
        if ply_spawn then
            local pos = TAH:FindPlayerSpot(ply_spawn:GetPos(), ply)
            ply:SetPos(pos)
            ply:SetAngles(Angle(0, ply_spawn:GetAngles().y, 0))
        end
    end

    for _, ent in pairs(TAH.Shop_Cache) do
        if IsValid(ent) then
            ent:SetEnabled(false)
            ent:SetItems(nil)
        end
    end

    -- self:SetupHold()
    self:SetupLoadout()

    PrintMessage(HUD_PRINTTALK, "Game Start.")
end
net.Receive("tah_startgame", function(len, ply)
    if not ply:IsAdmin() then return end
    if TAH:GetRoundState() ~= TAH.ROUND_INACTIVE then return end
    TAH:StartGame()
end)

function TAH:FinishGame(win)
    if win then
        PrintMessage(HUD_PRINTTALK, "Game Over: All holds secure.")
    else
        PrintMessage(HUD_PRINTTALK, "Game Over: Round " .. self:GetCurrentRound() .. ".")
    end

    self:SetRoundState(self.ROUND_INACTIVE)
    self:SetHoldEntity(nil)
    self:SetCurrentRound(1)
    self:SetCurrentWave(0)
    self:SetWaveTime(-1)
    self:Cleanup()

    for _, ent in pairs(ents.FindByClass("tah_crate")) do
        ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
    end
end
net.Receive("tah_finishgame", function(len, ply)
    if not ply:IsAdmin() then return end
    if TAH:GetRoundState() == TAH.ROUND_INACTIVE then return end
    TAH:FinishGame()
end)

function TAH:SetupLoadout()
    self:SetRoundState(TAH.ROUND_SETUP)

    -- TODO: Give players the option to opt out and spectate
    self.ActivePlayers = player.GetAll()

    for _, ply in pairs(self.ActivePlayers) do
        ply:SetMaxHealth(100)
        ply:SetHealth(100)
        ply:SetMaxArmor(100)
        ply:SetArmor(0)
        ply:RemoveAllAmmo()
        ply:StripWeapons()
        ply:Freeze(true)
        ply.TAH_Loadout = {}
        net.Start("tah_loadout")
        for i = 1, TAH.LOADOUT_LAST do
            local _, indices = self:RollLoadoutEntries(TAH.LoadoutEntries[i], TAH.LoadoutChoiceCount[i])
            ply.TAH_Loadout[i] = indices
            for j = 1, #indices do
                net.WriteUInt(indices[j], 8)
            end
        end
        net.Send(ply)
        PrintTable(ply.TAH_Loadout)
    end
end

-- Set specified entity to be the next hold (or random hold entity if none specified).
-- Spawn patrols and activate supply points.
function TAH:SetupHold(ent)
    local lasthold = self:GetHoldEntity()

    if not IsValid(ent) then
        if self:GetParameter("linear") then
            ent = self.SerialIDToHold[self:GetCurrentRound()]
        else
            if #self.UnusedHolds == 0 then
                self.UnusedHolds = ents.FindByClass("tah_holdpoint")
                if IsValid(self:GetHoldEntity()) then
                    table.RemoveByValue(self.UnusedHolds, self:GetHoldEntity())
                end
            end

            if #self.UnusedHolds > 1 and IsValid(self:GetHoldEntity()) then
                -- if we have choices, from the second hold onwards we try to distance the holds
                local cur = self:GetHoldEntity()
                local dist = {}
                local holds = table.Copy(self.UnusedHolds)
                for i, hold in pairs(holds) do
                    dist[hold] = hold:GetPos():DistToSqr(cur:GetPos())

                end
                table.sort(holds, function(a, b) return dist[a] < dist[b] end)

                -- remove up to 1 closest holds
                table.remove(holds, 1)
                ent = holds[math.random(1, #holds)]
                table.RemoveByValue(self.UnusedHolds, ent)
            else
                ent = table.remove(self.UnusedHolds, math.random(1, #self.UnusedHolds))
            end
        end
    end
    if not IsValid(lasthold) then
        lasthold = ent
    end

    self:SetHoldEntity(ent)
    self:SetRoundState(self.ROUND_TAKE)
    ent:SetCaptureProgress(0)
    ent:SetOwnedByPlayers(false)
    self:SetWaveTime(CurTime())
    PrintMessage(HUD_PRINTTALK, "Round " .. self:GetCurrentRound() .. " - Secure target access point.")

    local spawns = self:GetLinkedSpawns(ent, "tah_spawn_defend")

    -- spawn defenders for hold point
    local roundtbl = self:GetRoundTable()
    local spawn = roundtbl.defend_spawns[math.random(1, #roundtbl.defend_spawns)]
    local guardamt = math.Round(self:GetPlayerScaling(2) * spawn[2])
    self:SpawnEnemyGuard(spawn[1], #spawns > 0 and spawns[math.random(1, #spawns)]:GetPos() or ent:GetPos(), nil, guardamt)

    -- spawn defenders on defend spots
    if #spawns > 0 and roundtbl.defend_static_spawns and (roundtbl.defend_static_spawn_amount or 0) > 0 then
        for i = 1, math.min(#spawns, math.Round(self:GetPlayerScaling(2) * roundtbl.defend_static_spawn_amount)) do
            local ind = math.random(1, #spawns)
            local spot = spawns[ind]
            local name = roundtbl.defend_static_spawns[math.random(1, #roundtbl.defend_static_spawns)]
            self:SpawnEnemyGuard(name, spot:GetPos(), Angle(0, spot:GetAngles().y, 0), 1, true)
            table.remove(spawns, ind)
        end
    end

    -- spawn patrols on patrol spawns
    local patrolspawns = self:GetLinkedSpawns(ent, "tah_spawn_patrol")
    local amt = roundtbl.patrol_spawn_amount * self:GetPlayerScaling(3)
    while amt > 0 and #patrolspawns > 0 do
        local ind = math.random(1, #patrolspawns)
        local spot = patrolspawns[ind]
        local valid = true
        for _, ply in pairs(self.ActivePlayers) do
            if not ply:Alive() or ply:Team() == TEAM_SPECTATOR then continue end
            local dsqr = ply:GetPos():DistToSqr(spot:GetPos())
            if dsqr <= 512 ^ 2 then
                valid = false
                break
            end
            if dsqr <= 1500 ^ 2 then
                local tr = util.TraceLine({
                    start = ply:EyePos(),
                    endpos = spot:GetPos() + Vector(0, 0, 32),
                    mask = MASK_OPAQUE,
                    filter = {ply, spot},
                })
                if tr.Fraction < 1 then
                    valid = false
                    break
                end
            end
        end
        if valid then
            local data = roundtbl.patrol_spawns[math.random(1, #roundtbl.patrol_spawns)]
            self:SpawnEnemyPatrol(data[1], spot:GetPos(), data[2])
            amt = amt - 1
        end
        table.remove(patrolspawns, ind)
    end

    -- set active shop and roll items
    local active_shops = {}
    local shop_distance = {}
    local shops = table.Copy(self.Shop_Cache)

    -- in linear mode, pick the midpoint between last hold and current hold to calc distance
    local pos = self:GetParameter("linear") and (lasthold:GetPos() + (ent:GetPos() - lasthold:GetPos()) / 2) or ent:GetPos()

    for i, shop in pairs(self.Shop_Cache) do
        if IsValid(shop) then
            shop:SetEnabled(false)
            shop:SetItems()
            shop_distance[shop] = shop:GetPos():DistToSqr(pos)
        else
            table.remove(self.Shop_Cache, i)
        end
    end
    table.sort(shops, function(a, b) return shop_distance[a] < shop_distance[b] end)

    -- This amount of shops should be active
    local shop_count = table.Count(shops)
    local active_shop_count = math.min(shop_count, math.ceil(self:GetCurrentRound() / 2))
    if not self:GetParameter("linear") and shop_count - active_shop_count > 0 then
        -- exclude the closest shop if not linear hold
        table.remove(shops, 1)
    end

    for i = 1, active_shop_count do
        local ind
        if self:GetParameter("linear") then
            ind = math.random(1, active_shop_count - i + 1) -- always closest, but can be in random order
        else
            ind = math.random(1, #shops)
        end

        local shop = shops[ind]
        shop:SetEnabled(true)
        local items = self:RollShopForRound(nil, 4)

        -- health/armor
        if self.ShopBonus[i] then
            table.Add(items, self.ShopBonus[i])
        end

        -- Add random supply to shop
        local results = {}
        for j = 1, 3 do
            local class = self:RollShopCategory(self.SHOP_SUPPLY, 1, results)
            table.insert(items, class)
            results[class] = true
        end

        -- spawn a patrol near active shop
        local traces = {}
        for _, dir in pairs(self.Directions) do
            local tr = util.TraceHull({
                start = shop:GetPos(),
                endpos = shop:GetPos() + dir * 256,
                filter = shop,
                mask = MASK_NPCSOLID_BRUSHONLY,
                mins = Vector(-16, -16, 16),
                maxs = Vector(16, 16, 72),
            })
            table.insert(traces, {tr.Fraction, tr.HitPos})
        end
        table.SortByMember(traces, 1, false)
        if traces[1][1] > 0.1 then
            local data = roundtbl.patrol_spawns[math.random(1, #roundtbl.patrol_spawns)]
            self:SpawnEnemyPatrol(data[1], traces[1][2], data[2])
        end

        shop:SetItems(items)
        table.insert(active_shops, shop)
        table.remove(shops, ind)
    end

    -- spawn item crates
    local crates = ents.FindByClass("tah_crate")
    local crates_dist = {}
    for i, crate in ipairs(crates) do
        local p = crate:GetPos()
        crates_dist[crate] = p:DistToSqr(pos)
        for _, shop in pairs(active_shops) do
            crates_dist[crate] = math.min(crates_dist[crate], p:DistToSqr(shop:GetPos()))
        end
    end
    -- sort crates by proximity to current hold or active shop
    table.sort(crates, function(a, b) return crates_dist[a] < crates_dist[b] end)

    local crate_count = math.min(#crates, roundtbl.crates[self.ConVars["game_difficulty"]:GetInt() + 1])

    -- only the closest crates are eligible for spawning, with some bias towards the closest spots
    local max = math.min(#crates, math.Round(crate_count * 1.5))

    for i = 1, crate_count do
        local rng = 1 + math.Round(math.random() ^ 1.5 * (max - 1))
        local spot = crates[rng]
        table.remove(crates, rng)
        max = max - 1

        -- If box spawn is occupied, skip the spawn
        -- this uses a smaller bound than the crate because hull trace ignores rotation
        local tr = util.TraceHull({
            start = spot:GetPos(),
            endpos = spot:GetPos(),
            mins = Vector(-10, -10, 0),
            maxs = Vector(10, 10, 24),
            mask = MASK_SOLID,
        })
        if tr.Hit then
            continue
        end

        local crate = ents.Create("item_item_crate")
        crate:SetPos(spot:GetPos())
        crate:SetAngles(spot:GetAngles())
        crate:SetKeyValue("ItemClass", "tah_dynamic_resupply")
        crate:SetKeyValue("ItemCount", 1)
        crate:Spawn()
        crate:Activate()

        table.insert(self.CleanupEntities, crate)
    end
end

-- Start hold phase with the current active hold entity.
function TAH:StartHold()
    if self:GetRoundState() == self.ROUND_TAKE then
        PrintMessage(HUD_PRINTTALK, "Defend the objective.")
        self:SetCurrentWave(1)
        self:StartWave()

        for _, ent in pairs(ents.FindByClass("tah_barrier")) do
            ent:SetEnabled(true)
        end
    end
end

-- Finish the hold and advance. If successful, give player some tokens.
function TAH:FinishHold(win)
    if self:IsHoldActive() then
        local has_next = self:HasNextRound()
        self:SetCurrentWave(0)

        if win then
            PrintMessage(HUD_PRINTTALK, "Hold successful.")
        else
            PrintMessage(HUD_PRINTTALK, "Hold failed.")
        end

        for _, ent in pairs(ents.FindByClass("tah_barrier")) do
            ent:SetEnabled(false)
        end

        if win and has_next then
            -- Award currency
            for _, ply in pairs(player.GetAll()) do
                local award = math.Round(self:GetRoundTable().tokens[self.ConVars["game_difficulty"]:GetInt() + 1] * self:GetPlayerScaling(0.4))
                self:AddTokens(ply, award)
            end

            self:SetCurrentRound(self:GetCurrentRound() + 1)
            self:SetupHold()

            local hold = self:GetHoldEntity()
            timer.Simple(0.5, function() self:RespawnPlayers(hold) end)
        else
            -- no more holds. gg
            self:FinishGame(true)
        end
    end
end

-- Initate a new wave.
function TAH:StartWave()
    local wavetbl = self:GetWaveTable()

    self:CleanupEnemies(true)
    self:SetRoundState(self.ROUND_WAVE)
    self:SetWaveTime(CurTime() + wavetbl.wave_duration)
    self.NextNPCSpawn = CurTime()
end

function TAH:Cleanup()
    self:CleanupEnemies(true)

    -- TODO: Maybe do something about hold/supply entities?
    for _, ent in pairs(self.CleanupEntities) do
        if IsValid(ent) then
            SafeRemoveEntity(ent)
        end
    end
    self.CleanupEntities = {}

    for _, ent in pairs(ents.FindByClass("tah_barrier")) do
        ent:SetEnabled(false)
    end

    for _, ply in pairs(player.GetAll()) do
        ply.TAH_Loadout = nil
        if ply.TAH_LastTeam then
            ply:SetTeam(ply.TAH_LastTeam)
            ply.TAH_LastTeam = nil
        else
            ply:SetTeam(TEAM_UNASSIGNED)
        end
        if ply:Alive() then
            ply:KillSilent()
            ply:Spawn()

            if self:GetRoundState() ~= self.ROUND_INACTIVE and self.ConVars["game_difficulty"] >= 2 then
                ply:SetHealth(ply:GetMaxHealth() * 0.5)
            end
        end
    end
end

function TAH:RoundThink()
    local state = self:GetRoundState()
    local hold = self:GetHoldEntity()

    if state == self.ROUND_SETUP then
        local ready = true
        for i, ply in pairs(self.ActivePlayers) do
            if not IsValid(ply) then table.remove(self.ActivePlayers, i) continue end
            if ply.TAH_Loadout then ready = false break end
        end
        if ready then
            self:SetupHold(hold)
        end
        return
    end

    if not IsValid(hold) then
        PrintMessage(HUD_PRINTTALK, "Hold entity deleted - game interrupted.")
        self:FinishGame()
        return
    end

    if (hold._NextThink or 0) < CurTime() then
        hold._NextThink = CurTime() + hold.ThinkInterval
        hold:UpdateProgress()
    end

    local alive = false
    for _, ply in pairs(player.GetAll()) do
        if ply:Alive() and ply:Team() ~= TEAM_SPECTATOR then
            alive = true
            break
        end
    end
    if not alive then
        self:FinishGame()
        return
    end

    if self:IsHoldActive() then
        local wavetbl = self:GetWaveTable()

        if self:GetWaveTime() < CurTime() then
            if hold:GetOwnedByPlayers() and hold:GetCaptureProgress() == 0 and hold:GetCaptureState() == 1 then
                self:FinishHold(true)
            end
        elseif self.NextNPCSpawn < CurTime() then
            self.NextNPCSpawn = CurTime() + self:GetPlayerScaling(0.5) * (istable(wavetbl.wave_interval) and math.Rand(wavetbl.wave_interval[1], wavetbl.wave_interval[2]) or wavetbl.wave_interval)

            local spawn = wavetbl.wave_spawns[math.random(1, #wavetbl.wave_spawns)]

            self:SpawnEnemyWave(hold, spawn)
        end
    else
        -- Ran out of time before capturing
        -- if self:GetWaveTime() < CurTime() and hold:GetCaptureProgress() == 0 then
        --     TAH:FinishGame()
        -- end
        -- idk spawn some patrols once in a while?
    end
end
hook.Add("Tick", "TAH_RoundThink", function()
    if TAH:GetRoundState() ~= TAH.ROUND_INACTIVE then
        TAH:RoundThink()
    end
end)

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
        RunConsoleCommand("sk_max_357", "36")
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