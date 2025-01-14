hook.Add("PostPlayerDeath", "TAH_Death", function(ply)
    if TAH:GetRoundState() ~= TAH.ROUND_INACTIVE and ply:Team() ~= TEAM_SPECTATOR then
        ply.TAH_LastTeam = ply:Team()
        ply:SetTeam(TEAM_SPECTATOR)
        ply:Spectate(OBS_MODE_ROAMING)
    end
end)

hook.Add("PlayerDeathThink", "TAH_Death", function(ply)
    if TAH:GetRoundState() ~= TAH.ROUND_INACTIVE and ply:Team() == TEAM_SPECTATOR then
        return true
    end
end)

local mins, maxs = Vector(-16, -16, 0), Vector(16, 16, 72)
local function trace(pos, filter)
    local tr = util.TraceHull({
        start = pos,
        endpos = pos,
        mins = mins,
        maxs = maxs,
        filter = filter,
        mask = MASK_PLAYERSOLID,
        collisiongroup = COLLISION_GROUP_PLAYER,
    })
    debugoverlay.Box(pos, mins, maxs, 5, tr.Hit and Color(255, 255, 255, 0) or Color(0, 255, 0, 0))
    return not tr.Hit and not tr.AllSolid
end
function TAH:FindPlayerSpot(pos, filter)
    if trace(pos, filter) then return pos end
    for i = 1, 8 do
        for _, v in pairs(TAH.Directions) do
            local pos2 = pos + v * (32 * i)
            if trace(pos2, filter) then
                return pos2
            end
        end
    end
    return false
end

function TAH:RespawnPlayers(hold)
    for _, ply in pairs(player.GetAll()) do
        if ply:Team() == TEAM_SPECTATOR then
            if hold then
                ply.TAH_LastHold = hold
                timer.Simple(0.01, function()
                    local pos = TAH:FindPlayerSpot(hold:GetPos(), ply) or hold:GetPos()
                    ply:SetPos(pos)
                end)
            end
            ply:SetTeam(ply.TAH_LastTeam or TEAM_UNASSIGNED)
            ply.TAH_LastTeam = nil
            ply:Spawn()
        end
    end
end

hook.Add("OnNPCKilled", "tah_death", function(ent, attacker, inflictor)
    -- On limited ammo mode, NPCs will drop some bullets with their ammo type
    local wep = ent:GetActiveWeapon()
    if IsValid(wep) and TAH.ConVars["game_limitedammo"] and TAH:IsGameActive() and math.random() <= 1 / 3 then
        local ammotype = game.GetAmmoName(wep:GetPrimaryAmmoType())
        if ammotype then
            local amt = DZ_ENTS.AmmoTypeGiven[DZ_ENTS:GetWeaponAmmoCategory(ammotype)]
            local pickup = ents.Create("tah_pickup_ammo")
            pickup:SetPos(ent:WorldSpaceCenter() + VectorRand() * 8)
            pickup:SetAngles(AngleRand())
            pickup.AmmoType = string.lower(ammotype)
            pickup.AmmoCount = math.Round(amt * math.Rand(0.5, 1))
            pickup:Spawn()
            pickup:GetPhysicsObject():SetVelocityInstantaneous(VectorRand() * 64 + Vector(0, 0, 256))
            pickup:GetPhysicsObject():SetAngleVelocityInstantaneous(VectorRand() * 512)

            table.insert(TAH.CleanupEntities, pickup)
            SafeRemoveEntityDelayed(pickup, 60)
        end
    end
end)