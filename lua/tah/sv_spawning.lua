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
        if area:GetClosestPointOnArea(pos):DistToSqr(pos) <= 750 then continue end
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

    PrintTable(clusters)
    return clusters
end
