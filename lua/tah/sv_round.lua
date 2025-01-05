TAH.NextNPCSpawn = 0
TAH.UnusedHolds = {}
TAH.ActivePlayers = {}

util.AddNetworkString("tah_startgame")
util.AddNetworkString("tah_finishgame")

function TAH:StartGame()
    self:SetCurrentRound(1)
    self:SetCurrentWave(0)
    self:SetWaveTime(-1)
    self.UnusedHolds = ents.FindByClass("tah_holdpoint")
    for _, ply in pairs(player.GetAll()) do
        self:SetTokens(ply, self:GetPlayerStartingToken(ply))
    end
    for _, ent in pairs(TAH.UnusedHolds) do
        ent:SetOwnedByPlayers(false)
        ent:SetCaptureProgress(0)
        ent:SetCaptureState(0)
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

function TAH:FinishGame()
    PrintMessage(HUD_PRINTTALK, "Game Over: Round " .. self:GetCurrentRound() .. ".")

    self:SetRoundState(self.ROUND_INACTIVE)
    self:SetHoldEntity(nil)
    self:SetCurrentRound(1)
    self:SetCurrentWave(0)
    self:SetWaveTime(-1)
    self:Cleanup()
end
net.Receive("tah_finishgame", function(len, ply)
    if not ply:IsAdmin() then return end
    if TAH:GetRoundState() == TAH.ROUND_INACTIVE then return end
    TAH:FinishGame()
end)

function TAH:SetupLoadout()
    TAH:SetRoundState(TAH.ROUND_SETUP)

    -- TODO: Give players the option to opt out and spectate
    TAH.ActivePlayers = player.GetAll()

    for _, ply in pairs(TAH.ActivePlayers) do
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
            local _, indices = TAH:RollLoadoutEntries(TAH.LoadoutEntries[i], TAH.LoadoutChoiceCount[i])
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
    if not IsValid(ent) then
        if #TAH.UnusedHolds == 0 then
            TAH.UnusedHolds = ents.FindByClass("tah_holdpoint")
        end
        ent = table.remove(TAH.UnusedHolds, math.random(1, #TAH.UnusedHolds))
    end
    self:SetHoldEntity(ent)
    self:SetRoundState(self.ROUND_TAKE)
    ent:SetCaptureProgress(0)
    ent:SetOwnedByPlayers(false)
    self:SetWaveTime(CurTime() + 300) -- TODO configure time
    PrintMessage(HUD_PRINTTALK, "Round " .. self:GetCurrentRound() .. " - Secure target access point.")

    local spawns = TAH:GetLinkedSpawns(ent, "tah_spawn_defend")

    -- spawn defenders for hold point
    local roundtbl = self:GetRoundTable()
    local spawn = roundtbl.defend_spawns[math.random(1, #roundtbl.defend_spawns)]
    self:SpawnEnemyGuard(spawn[1], #spawns > 0 and spawns[math.random(1, #spawns)]:GetPos() or ent:GetPos(), nil, spawn[2])

    -- spawn defenders on defend spots
    if #spawns > 0 and roundtbl.defend_static_spawns and (roundtbl.defend_static_spawn_amount or 0) > 0 then
        for i = 1, math.min(#spawns, roundtbl.defend_static_spawn_amount) do
            local ind = math.random(1, #spawns)
            local spot = spawns[ind]
            local name = roundtbl.defend_static_spawns[math.random(1, #roundtbl.defend_static_spawns)]
            self:SpawnEnemyGuard(name, spot:GetPos(), Angle(0, spot:GetAngles().y, 0), 1, true)
            table.remove(spawns, ind)
        end
    end

    -- spawn patrols on patrol spawns
    local patrolspawns = TAH:GetLinkedSpawns(ent, "tah_spawn_patrol")
    if #patrolspawns > 0 and  (roundtbl.patrol_spawn_amount or 0) > 0 then
        for i = 1, math.min(#patrolspawns, roundtbl.patrol_spawn_amount) do
            local ind = math.random(1, #patrolspawns)
            local spot = patrolspawns[ind]
            local data = roundtbl.patrol_spawns[math.random(1, #roundtbl.patrol_spawns)]
            self:SpawnEnemyPatrol(data[1], spot:GetPos(), data[2])
            table.remove(patrolspawns, ind)
        end
    end

    -- temp: just activate all shops
    -- for _, shop in pairs(TAH.Shop_Cache) do
    --     if IsValid(shop) then
    --         shop:SetEnabled(true)
    --         shop:SetItems(TAH:RollShopForRound(nil, 5))
    --     end
    -- end

    -- set active shop and roll items
    local shop_distance = {}
    local shops = table.Copy(TAH.Shop_Cache)
    for i, shop in pairs(TAH.Shop_Cache) do
        if IsValid(shop) then
            shop:SetEnabled(false)
            shop:SetItems()
            shop_distance[shop] = shop:GetPos():DistToSqr(ent:GetPos())
        else
            table.remove(TAH.Shop_Cache, i)
        end
    end
    table.sort(shops, function(a, b) return shop_distance[a] < shop_distance[b] end)

    -- This amount of shops should be active
    local shop_count = table.Count(shops)
    local active_shop_count = math.min(shop_count, math.ceil(self:GetCurrentRound() / 2))
    if shop_count - active_shop_count > 0 then
        -- exclude the closest shop
        table.remove(shops, 1)
    end

    for i = 1, active_shop_count do
        local ind = math.random(1, #shops)
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
            local class = TAH:RollShopCategory(TAH.SHOP_SUPPLY, 1, results)
            table.insert(items, class)
            results[class] = true
        end

        shop:SetItems(items)
        table.remove(shops, ind)
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
                self:AddTokens(ply, self:GetRoundTable().tokens or 0)
            end

            self:SetCurrentRound(self:GetCurrentRound() + 1)
            self:SetupHold()

            local hold = self:GetHoldEntity()
            timer.Simple(0.5, function() self:RespawnPlayers(hold) end)
        else
            -- no more holds. gg
            self:FinishGame()
            self:RespawnPlayers()
        end
    end
end

-- Initate a new wave.
function TAH:StartWave()
    local wavetbl = self:GetWaveTable()

    self:CleanupEnemies(true)
    self:SetRoundState(self.ROUND_WAVE)
    self:SetWaveTime(CurTime() + wavetbl.wave_duration)
    self.NextNPCSpawn = CurTime() + 5
end

function TAH:Cleanup()
    self:CleanupEnemies(true)

    -- TODO: Maybe do something about hold/supply entities?

    for _, ply in pairs(player.GetAll()) do
        if ply.TAH_LastTeam then
            ply:SetTeam(ply.TAH_LastTeam)
            ply.TAH_LastTeam = nil
        end
    end
end

function TAH:RoundThink()
    local state = self:GetRoundState()
    local hold = self:GetHoldEntity()

    if state == TAH.ROUND_SETUP then
        local ready = true
        for i, ply in pairs(TAH.ActivePlayers) do
            if not IsValid(ply) then table.remove(TAH.ActivePlayers, i) continue end
            if ply.TAH_Loadout then ready = false break end
        end
        if ready then
            self:SetupHold()
        end
        return
    end

    if not IsValid(hold) then
        PrintMessage(HUD_PRINTTALK, "Hold entity deleted - game interrupted.")
        TAH:FinishGame()
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
        TAH:FinishGame()
        return
    end

    if self:IsHoldActive() then
        local wavetbl = self:GetWaveTable()

        if self:GetWaveTime() < CurTime() then
            if hold:GetOwnedByPlayers() and hold:GetCaptureProgress() == 0 and hold:GetCaptureState() == 1 then
                TAH:FinishHold(true)
            end
        elseif self.NextNPCSpawn < CurTime() then
            self.NextNPCSpawn = CurTime() + (istable(wavetbl.wave_interval) and math.Rand(wavetbl.wave_interval[1], wavetbl.wave_interval[2]) or wavetbl.wave_interval)

            local spawn = wavetbl.wave_spawns[math.random(1, #wavetbl.wave_spawns)]

            self:SpawnEnemyWave(hold, spawn)
        end
    else
        -- Ran out of time before capturing
        if self:GetWaveTime() < CurTime() and hold:GetCaptureProgress() == 0 then
            TAH:FinishGame()
        end
        -- idk spawn some patrols once in a while?
    end
end
hook.Add("Tick", "TAH_RoundThink", function()
    if TAH:GetRoundState() ~= TAH.ROUND_INACTIVE then
        TAH:RoundThink()
    end
end)