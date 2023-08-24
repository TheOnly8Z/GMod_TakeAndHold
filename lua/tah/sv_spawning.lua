TAH.NPC_Cache = {}

TAH.SpawnGroups = {}

local function heuristic_cost_estimate(start, goal)
    -- Perhaps play with some calculations on which corner is closest/farthest or whatever
    return start:GetCenter():Distance(goal:GetCenter())
end

-- using CNavAreas as table keys doesn't work, we use IDs
local function reconstruct_path(cameFrom, current)
    local total_path = {current}

    current = current:GetID()

    while cameFrom[current] do
        current = cameFrom[current]
        table.insert(total_path, navmesh.GetNavAreaByID(current))
    end

    return total_path
end

-- A* algorithm from gmod wiki
-- not perfect but we only want to know IF there's a path, so good enough!
local function Astar(start, goal)
    if not IsValid(start) or not IsValid(goal) then return false end
    if start == goal then return true end
    start:ClearSearchLists()
    start:AddToOpenList()
    local cameFrom = {}
    start:SetCostSoFar(0)
    start:SetTotalCost(heuristic_cost_estimate(start, goal))
    start:UpdateOnOpenList()

    while not start:IsOpenListEmpty() do
        local current = start:PopOpenList() -- Remove the area with lowest cost in the open list and return it
        if current == goal then return reconstruct_path(cameFrom, current) end
        current:AddToClosedList()

        for k, neighbor in pairs(current:GetAdjacentAreas()) do
            local newCostSoFar = current:GetCostSoFar() + heuristic_cost_estimate(current, neighbor)
            if neighbor:IsUnderwater() then continue end -- Add your own area filters or whatever here

            if (neighbor:IsOpen() or neighbor:IsClosed()) and neighbor:GetCostSoFar() <= newCostSoFar then
                continue
            else
                neighbor:SetCostSoFar(newCostSoFar)
                neighbor:SetTotalCost(newCostSoFar + heuristic_cost_estimate(neighbor, goal))

                if neighbor:IsClosed() then
                    neighbor:RemoveFromClosedList()
                end

                if neighbor:IsOpen() then
                    -- This area is already on the open list, update its position in the list to keep costs sorted
                    neighbor:UpdateOnOpenList()
                else
                    neighbor:AddToOpenList()
                end

                cameFrom[neighbor:GetID()] = current:GetID()
            end
        end
    end

    return false
end

-- local dissolver
local function use_dissolver(ent)

    local dmginfo = DamageInfo()
    dmginfo:SetDamage(ent:GetMaxHealth() * 100)
    dmginfo:SetAttacker(ent)
    dmginfo:SetInflictor(ent)
    dmginfo:SetDamageType(DMG_DIRECT + DMG_DISSOLVE + DMG_NEVERGIB)
    ent:TakeDamageInfo(dmginfo)
    SafeRemoveEntityDelayed(ent, 1)

    -- if not IsValid(dissolver) then
    --     dissolver = ents.Create("env_entity_dissolver")
    --     dissolver:SetPos(ent:GetPos())
    --     dissolver:Spawn()
    --     dissolver:Activate()
    --     dissolver:SetKeyValue("magnitude", 100)
    --     dissolver:SetKeyValue("dissolvetype", 0)
    -- end

    -- local name = "tah_dissolve_" .. ent:EntIndex()
    -- ent:SetName(name)
    -- dissolver:Fire("Dissolve", name)

    -- timer.Create("tah_dissolver", 60, 1, function()
    --     if IsValid(dissolver) then
    --         dissolver:Remove()
    --     end
    -- end)
end

function TAH:CleanupEnemies(dramatic)
    for i, ent in pairs(self.NPC_Cache) do
        if not IsValid(ent) then
            table.remove(self.NPC_Cache, i)
            continue
        end
        if dramatic then
            use_dissolver(ent)
        else
            SafeRemoveEntity(ent)
        end
    end
    self.NPC_Cache = {}
end

function TAH:TrySpawns(ent)
    local pos = ent:GetPos()
    local start = navmesh.GetNearestNavArea(pos)
    local found = {}
    local areas = navmesh.Find(pos, 3000, 64, 64)

    -- find all lists that:
    -- 1. are not visible from this position
    -- 2. are at least 750 units away
    -- 3. have a path to this position
    for k, area in ipairs(areas) do
        if area:IsPotentiallyVisible(start) then continue end
        local pos1 = area:GetClosestPointOnArea(pos)
        pos1.z = 0
        local pos2 = Vector(pos)
        pos2.z = 0
        if area:GetClosestPointOnArea(pos):Distance(pos) <= (ent.GetRadius and ent:GetRadius() or 512) + 256 then continue end
        local path = Astar(start, area)
        if not istable(path) then continue end
        area:Draw()
        table.insert(found, area)
    end

    -- cluster all adjacent navmeshes into one table
    -- this way, each table is loosely a "direction" enemies can spawn from
    -- so we can distribute spawns evenly
    local clusters = {}
    for k, area in ipairs(found) do
        local adjacent = false

        for i, v in pairs(clusters) do
            for _, a2 in pairs(v) do
                if table.HasValue(a2:GetAdjacentAreas(), area) then
                    adjacent = true
                    break
                end
            end
            if adjacent then
                table.insert(v, area)
                break
            end
        end

        if not adjacent then
            table.insert(clusters, {area})
            debugoverlay.Sphere(area:GetCenter(), 32, 10, color_white, true)
        end
    end

    -- PrintTable(clusters)
    return clusters
end

function TAH:SelectEnemySpawn(pos)
    -- TODO this should be cached
    local spawns = ents.FindByClass("tah_spawn_attack")
    local pool = {}
    for _, ent in pairs(spawns) do
        local dist_sqr = ent:GetPos():DistToSqr(pos)
        -- if dist_sqr <= 500 * 500 or dist_sqr >= 3000 * 3000 then return end
        table.insert(pool, ent)
    end
    return pool[math.random(1, #pool)]
end

function TAH:SpawnEnemyType(name, pos, squad)
    local data = TAH.EnemyData[name]
    squad = squad or "tah"

    local ent = ents.Create(data.ent)
    ent:SetPos(pos)
    ent:SetAngles(Angle(0, math.Rand(0, 360), 0))

    if data.wep then
        ent:SetKeyValue( "additionalequipment", istable(data.wep) and data.wep[math.random(1, #data.wep)] or data.wep)
        -- ent:Give(istable(data.wep) and data.wep[math.random(1, #data.wep)] or data.wep)
    end
    if data.model then
        ent:SetModel(istable(data.model) and data.model[math.random(1, #data.model)] or data.model)
    end
    if data.skin then
        ent:SetSkin(data.skin)
    end
    ent:SetKeyValue("spawnflags", bit.bor(data.spawnflags or 0, SF_NPC_NO_WEAPON_DROP, SF_NPC_FADE_CORPSE, SF_NPC_LONG_RANGE))
    if data.keyvalues then
        for k, v in pairs(data.keyvalues) do
            ent:SetKeyValue(k, istable(v) and v[math.random(1, #v)] or v)
        end
    end

    ent:Spawn()

    if data.hp then
        ent:SetMaxHealth(data.hp)
        ent:SetHealth(data.hp)
    end
    if data.prof then
        ent:SetCurrentWeaponProficiency(data.prof)
    end

    ent:SetSquad(squad)
    -- ent:Fire("SetReadinessHigh")
    ent:SetLagCompensated(true)

    ent.TAH_NPC = true
    table.insert(TAH.NPC_Cache, ent)

    return ent
end

function TAH:SpawnEnemyWave(ent, tbl)
    -- local spawns = TAH:TrySpawns(ent)
    -- spawns = spawns[math.random(1, #spawns)]
    local spawn = TAH:SelectEnemySpawn(ent:GetPos())

    local squad_name = "tah" .. math.random(99999)

    local assault_delay = math.Rand(1, 3)

    local amt = #tbl
    local is_count = #tbl == 2 and isnumber(tbl[2])

    if is_count then
        amt = tbl[2]
    end

    for i = 1, amt do
        local pos
        local off = (i - 1) * 16
        for j = 1, 10 do
            -- pos = spawns[math.random(1, #spawns)]:GetRandomPoint() + Vector(math.Rand(-8, 8) * j, math.Rand(-8, 8) * j, 8)
            pos = spawn:GetPos() + Vector(math.Rand(-8 - off, 8 + off) * j, math.Rand(-8 - off, 8 + off) * j, 8)
            local tr = util.TraceHull({
                start = pos,
                endpos = pos,
                mask = MASK_SOLID,
                mins = Vector(-16, -16, 0),
                maxs = Vector(16, 16, 72)
            })
            if not tr.Hit then
                break
            else
                pos = nil
            end
        end
        if not pos then print("failed to find spot!") continue end

        local npc = TAH:SpawnEnemyType(is_count and tbl[1] or tbl[i], pos, squad_name)

        -- Force NPCs to scatter a bit before they can approach.
        -- This staggers their approach a bit so they don't look like a conga line.
        -- npc:Fire("SetReadinessHigh")
        npc:SetNPCState(NPC_STATE_ALERT)
        npc:SetSchedule(SCHED_RUN_RANDOM)

        timer.Simple(assault_delay + math.Rand(0, 1), function()
            if IsValid(npc) and IsValid(ent) then
                npc.TAH_Ready = true
                -- Time to approach the hold point
                if not IsValid(npc:GetEnemy()) then
                    npc:SetTarget(ent)
                    npc:SetSchedule(SCHED_TARGET_CHASE)
                end
            end
        end)
    end
end

function TAH:SpawnEnemyGuard(spot, name, amt)
    local squad_name = "tah" .. math.random(99999)

    for i = 1, (amt or 3) do
        local pos
        for j = 1, 10 * amt do
            pos = spot + Vector(math.Rand(-4, 4) * (j + 8), math.Rand(-4, 4) * (j + 8), 8)
            local tr = util.TraceHull({
                start = pos,
                endpos = pos,
                mask = MASK_SOLID,
                mins = Vector(-16, -16, 0),
                maxs = Vector(16, 16, 72)
            })
            if not tr.Hit then
                break
            else
                pos = nil
            end
        end
        if not pos then print("failed to find spot!") continue end

        local npc = TAH:SpawnEnemyType(name, pos, squad_name)
        npc:SetNPCState(NPC_STATE_IDLE)
        npc:SetSaveValue("m_vecLastPosition", pos)
        npc:Fire("StartPatrolling")
    end
end

timer.Create("TAH_NPC_Herding", 3, 0, function()
    if not IsValid(TAH:GetHoldEntity()) or not TAH:IsHoldActive() then return end
    for i, npc in pairs(TAH.NPC_Cache) do
        if not IsValid(npc) or not npc.TAH_NPC then
            table.remove(TAH.NPC_Cache, i)
            continue
        end
        if npc.TAH_Ready and not IsValid(npc:GetTarget()) and not IsValid(npc:GetEnemy()) then
            npc:SetTarget(TAH:GetHoldEntity())
            npc:SetSchedule(SCHED_TARGET_CHASE)
        end
    end
end)