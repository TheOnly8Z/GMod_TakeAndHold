AddCSLuaFile()
ENT.Base = "base_nextbot"
ENT.Spawnable = false
ENT.PrintName = "TAH Test Nextbot"

list.Set("NPC", "nextbot_tah_test", {
    Name = "Test Nextbot",
    Class = "nextbot_tah_test",
    Category = "Take And Hold"
})

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "State")
    self:NetworkVar("Entity", 0, "Weapon")
end

if CLIENT then return end

ENT.WalkSpeed = 100
ENT.RunSpeed = 250
ENT.VisionRange = 750
ENT.FOV = 100

ENT.GoalSet = {
    "patrol",
    "keep_loaded",
    "kill_enemy",
}

ENT.ActionSet = {
    "walk_random",
    "run_towards_enemy",
    "walk_towards_weapon",
    "pickup_weapon",
    "attack_melee",
    "attack_ranged",
    "reload",
}

------------------- Internal variables

ENT.CurrentGoal = nil
ENT.CurrentActionStack = {}

ENT.GoalMemory = {}
ENT.ActionMemory = {}
ENT.SuccessCheck = 0

---------------------------------------------------------
-- Weapon Handling
---------------------------------------------------------

function ENT:HasWeapon()
    return IsValid(self:GetWeapon())
end

function ENT:RemoveWeapon()
    if IsValid(self:GetWeapon()) then
        self:GetWeapon():Remove()
    end
    self:SetWeapon(NULL)
end

function ENT:DropWeapon()
    if IsValid(self:GetWeapon()) then
        local oldwpn = self:GetWeapon()

        local att = "anim_attachment_rh"
        local shootpos = self:GetAttachment(self:LookupAttachment(att))

        oldwpn:RemoveEffects(EF_BONEMERGE)
        oldwpn:SetParent(NULL)
        oldwpn:SetOwner(NULL)
        oldwpn:SetNotSolid(false)
        oldwpn:SetTrigger(true)
        oldwpn:DrawShadow(true)
        oldwpn:SetPos(shootpos.Pos)
        oldwpn:PhysicsInit(SOLID_VPHYSICS)
        oldwpn:PhysWake()
    end

    self:SetWeapon(NULL)
end

function ENT:PickupWeapon(wep)
    if IsValid(self:GetWeapon()) then self:DropWeapon() end
    local att = "anim_attachment_rh"
    local shootpos = self:GetAttachment(self:LookupAttachment(att))
    wep:DrawShadow(false)
    wep:SetSolid(SOLID_NONE)
    wep:SetParent(self)
    wep:SetNotSolid(true)
    wep:SetTrigger(false)
    wep:Fire("setparentattachment", att)
    wep:AddEffects(EF_BONEMERGE)
    wep:SetPos(shootpos.Pos)
    wep:SetAngles(self:GetForward():Angle())
    wep:SetOwner(self)
    self:SetWeapon(wep)
    self.FoundWeapon = nil

    self:StartActivity(ACT_HL2MP_IDLE_CROUCH)
    self:RestartGesture(ACT_HL2MP_GESTURE_RANGE_ATTACK_SLAM)
    coroutine.wait(1)
end

function ENT:EquipWeapon(wpn)
    if IsValid(self:GetWeapon()) then self:DropWeapon() end
    local att = "anim_attachment_rh"
    local shootpos = self:GetAttachment(self:LookupAttachment(att))
    local wep = ents.Create(wpn)
    wep:SetOwner(self)
    wep:SetPos(shootpos.Pos)
    wep:Spawn()

    wep:DrawShadow(false)
    wep:SetSolid(SOLID_NONE)
    wep:SetParent(self)
    wep:SetNotSolid(true)
    wep:SetTrigger(false)
    wep:Fire("setparentattachment", att)
    wep:AddEffects(EF_BONEMERGE)
    wep:SetAngles(self:GetForward():Angle())
    wep:SetOwner(self)

    self:SetWeapon(wep)
    self.FoundWeapon = nil
end

function ENT:WeaponReload()
    if not self:HasWeapon() then return end
    local wep = self:GetWeapon()

    self:RestartGesture(ACT_HL2MP_GESTURE_RELOAD_PISTOL)
    wep:SetNextPrimaryFire(CurTime() + 2)
    wep:SetClip1(wep:GetValue("ClipSize"))

    while wep:GetNextPrimaryFire() > CurTime() do
        if IsValid(self:GetEnemy()) then self.loco:FaceTowards(self:GetEnemy():GetPos()) end
        coroutine.yield()
    end
end

function ENT:WeaponAttack()
    if not self:HasWeapon() then return false end
    if not IsValid(self:GetEnemy()) then return false end

    local wep = self:GetWeapon()
    local enemy = self:GetEnemy()

    local delay = 60 / wep:GetValue("RPM")
    local aps = wep:GetValue("AmmoPerShot")
    local timeout = CurTime() + delay
    while wep:GetNextPrimaryFire() > CurTime() or (CurTime() < timeout) do
        self.loco:FaceTowards(self:GetEnemy():GetPos())
        coroutine.yield()
    end

    self:StartActivity(ACT_HL2MP_IDLE_PISTOL)
    self:RestartGesture(ACT_HL2MP_GESTURE_RANGE_ATTACK_PISTOL)

    local pvar = wep:GetValue("ShootPitchVariance")
    local sshoot = wep:GetValue("Sound_Shoot")
    if wep:GetValue("Silencer") then
        sshoot = wep:GetValue("Sound_Shoot_Silenced")
    end
    if istable(sshoot) then
        sshoot = table.Random(sshoot)
    end
    self:EmitSound(sshoot, wep:GetValue("Vol_Shoot"), wep:GetValue("Pitch_Shoot") + math.Rand(-pvar, pvar), 1, CHAN_WEAPON)

    wep:SetNextPrimaryFire(CurTime() + delay)
    wep:SetClip1(wep:Clip1() - aps)

    local dir = (enemy:GetPos() - self:EyePos())
    local spread = wep:GetValue("Spread")

    if wep:GetValue("ShootEnt") then
        if IsValid(enemy) then
            dir = (enemy:WorldSpaceCenter() - self:EyePos()):GetNormalized():Angle()
            dir = dir + (spread * AngleRand() / 3.6)
        end
        wep:ShootRocket(dir)
    else
        self:FireBullets({
            Damage = wep:GetValue("Damage_Max"),
            Force = 8,
            TracerName = "tacrp_tracer",
            Tracer = wep:GetValue("TracerNum"),
            Num = wep:GetValue("Num"),
            Dir = dir,
            Src = self:EyePos(),
            Spread = Vector(spread, spread, spread),
            Callback = function(att, btr, dmg)
                local range = (btr.HitPos - btr.StartPos):Length()
                wep:AfterShotFunction(btr, dmg, range, 0, {})
            end
        })
    end

    wep:DoEffects()
    wep:DoEject()

    if wep:Clip1() < aps then return false end
end

function ENT:MeleeAttack()
    self:StartActivity(ACT_HL2MP_IDLE_FIST)
    self:RestartGesture(ACT_HL2MP_GESTURE_RANGE_ATTACK_FIST)
    self:EmitSound("WeaponFrag.Throw")

    timer.Simple(0.2, function()
        if not IsValid(self) then return end
        local tr = util.TraceHull({
            start = self:EyePos(),
            endpos = self:EyePos() + self:GetForward() * 72,
            mins = Vector(-8, -8, -8),
            maxs = Vector(8, 8, 8),
            filter = self,
            mask = MASK_SOLID,
        })
        if IsValid(tr.Entity) then
            local dmginfo = DamageInfo()
            dmginfo:SetAttacker(self)
            dmginfo:SetInflictor(self)
            dmginfo:SetDamage(5)
            dmginfo:SetDamageType(DMG_GENERIC)
            dmginfo:SetDamageForce(tr.Normal * 9001)
            dmginfo:SetDamagePosition(tr.HitPos)
            tr.Entity:DispatchTraceAttack(dmginfo, tr, tr.Normal)
            self:EmitSound("Flesh.ImpactHard")
        end
    end)

    -- local timeout = CurTime() + 0.5
    -- while CurTime() < timeout and IsValid(self:GetEnemy()) do
    --     self.loco:FaceTowards(self:GetEnemy():GetPos())
    --     coroutine.yield()
    -- end
end

function ENT:GetFoundWeapon()
    if not IsValid(self.FoundWeapon) or IsValid(self.FoundWeapon:GetOwner()) then
        self.FoundWeapon = nil
    end
    return self.FoundWeapon
end

function ENT:FindWeapon()
    for _, ent in pairs(ents.FindInSphere(self:GetPos(), self.VisionRange)) do
        if ent:IsWeapon() and not IsValid(ent:GetOwner()) and ent.ArcticTacRP then
            self.FoundWeapon = ent
            return true
        end
    end
end

---------------------------------------------------------
-- State Machine
---------------------------------------------------------

function ENT:AdjustState(state)
    self:SetState(state)
    if self:GetState() == TAH_NB_GOTO then
        if IsValid(self:GetEnemy()) then
            if self:HasWeapon() then
                self:StartActivity(ACT_HL2MP_RUN_PISTOL)
            else
                self:StartActivity(ACT_HL2MP_RUN)
            end
            self.loco:SetDesiredSpeed(self.RunSpeed)
        else
            self:StartActivity(ACT_HL2MP_WALK)
            self.loco:SetDesiredSpeed(self.WalkSpeed)
        end
    elseif self:GetState() == TAH_NB_ACT then
        if self:HasWeapon() then
            self:StartActivity(ACT_HL2MP_IDLE_PISTOL)
        else
            self:StartActivity(ACT_HL2MP_IDLE)
        end
        self.loco:SetDesiredSpeed(5)
    end
end

function ENT:PerformAction(act)
    print("doing action", act)
    local tbl = TAH.NB_Actions[act]
    if tbl.state then
        self:AdjustState(tbl.state)
    end
    return tbl.action(self)
end

---------------------------------------------------------
-- GMod nextbot stuff
---------------------------------------------------------

function ENT:Initialize()
    self:SetModel("models/player/police.mdl")
    self.LoseTargetDist = 2000
    self.SearchRadius = 1000

    self:SetFOV(self.FOV)
    self:SetMaxVisionRange(self.VisionRange)

    self.loco:SetStepHeight(24)
    self.loco:SetAcceleration(800)
    self.loco:SetDeceleration(800)
    self.loco:SetMaxYawRate(360)

    -- self:StartActivity(ACT_HL2MP_IDLE)
    -- self:EquipWeapon("tacrp_ex_glock")
end

function ENT:SetEnemy(ent)
    self.Enemy = ent
end

function ENT:GetEnemy()
    return self.Enemy
end

function ENT:HaveEnemy()
    if self:GetEnemy() and IsValid(self:GetEnemy()) then
        if self:GetRangeTo(self:GetEnemy():GetPos()) > self.LoseTargetDist then
            return self:FindEnemy()
        elseif self:GetEnemy():IsPlayer() and not self:GetEnemy():Alive() then
            return self:FindEnemy()
        end
        return true
    else
        return self:FindEnemy()
    end
end

function ENT:FindEnemy()
    if GetConVar("ai_ignoreplayers"):GetBool() then return false end
    -- local _ents = ents.FindInCone(self:GetPos(), self:GetForward(), self.VisionRange, 0)
    local _ents = ents.FindInSphere(self:GetPos(), self.VisionRange)

    for k, v in ipairs(_ents) do
        if v:IsPlayer() and v:Alive() then
            self:SetEnemy(v)

            return true
        end
    end

    self:SetEnemy(nil)

    return false
end

local function check_action_cost(self, actions, cost, depth)
    actions = istable(actions) and actions or {actions}
    cost = cost or 0
    depth = (depth or 0) + 1

    if depth >= 99 then
        ErrorNoHalt("AHHH TOO DEEP TOO DEEP!!!\n")
        return false
    end

    -- the last action on the stack is the one we're checking
    local action = TAH.NB_Actions[actions[#actions]]

    -- add cost of current action
    if isfunction(action.cost) then
        cost = cost + (action.cost(self) or 0)
    else
        cost = cost + tonumber(action.cost or 0)
    end

    -- for the current action, check preconds
    for _, v in pairs(action.preconds or {}) do
        local precond = TAH.NB_PreConds[v]
        if not precond.check(self) then
            -- if precond is not matching, check its fulfilling actions
            if not precond.action then
                -- no action is assigned to this precond; this action is not completable
                return false
            elseif not table.HasValue(actions, precond.action) then
                -- add the precond's action onto the stack if it isn't on it yet, and track costs
                table.insert(actions, precond.action)
                cost, actions = check_action_cost(self, actions, cost, depth)
            end
        end
    end

    return cost, actions
end

function ENT:RunBehaviour()
    while true do

        -- If we do not currently have a goal, find one
        if self.CurrentGoal == nil then
            local nextprio = -math.huge

            for _, goal in pairs(self.GoalSet) do
                print(self, "checking goal", goal)

                if self.GoalMemory[goal] and TAH.NB_Goals[goal].retry
                        and self.GoalMemory[goal] + TAH.NB_Goals[goal].retry > CurTime() then
                    continue
                elseif self.CurrentGoal == nil or TAH.NB_Goals[goal].priority > nextprio then
                    local bestcost = math.huge
                    local beststack = {}
                    for _, v in pairs(TAH.NB_Goals[goal].actions) do
                        if not table.HasValue(self.ActionSet, v) then continue end
                        -- TODO this should be A* with fancy graph distance and stuff
                        local cost, actions = check_action_cost(self, v)
                        print(v, cost, table.ToString(istable(actions) and actions or {}))
                        if cost ~= false and cost < bestcost then
                            beststack = actions
                            bestcost = cost
                        end
                    end

                    if #beststack ~= 0 then
                        print("goal set to", nextgoal)
                        self.CurrentGoal = goal
                        self.CurrentActionStack = beststack
                    end
                end
            end
        end

        print(self, tostring(self.CurrentGoal), table.ToString(self.CurrentActionStack))
        -- PrintTable(self.CurrentActionStack)

        -- Attempt to perform current action
        if self.CurrentGoal and #self.CurrentActionStack > 0 then
            local result = self:PerformAction(self.CurrentActionStack[#self.CurrentActionStack])
            if result == true then
                -- current goal is good, remove from action stack
                local oldact = table.remove(self.CurrentActionStack, #self.CurrentActionStack)
                print("completed action", oldact)

                -- goal is complete if all actions are done
                if #self.CurrentActionStack == 0 then
                    print("completed goal", self.CurrentGoal)
                    self.CurrentGoal = nil
                    coroutine.wait(0.1)
                end
            elseif result == false then
                print("failed goal", self.CurrentGoal)
                -- Remember that we failed this goal now, so we don't try it too soon
                self.GoalMemory[self.CurrentGoal] = CurTime()
                -- abandon current action stack cause we failed
                self.CurrentGoal = nil
                self.CurrentActionStack = {}
                coroutine.wait(0.1)
            else
                if self.SuccessCheck >= 99 then
                    ErrorNoHalt("AHHHH!!!!\n")
                    self.SuccessCheck = 0
                    self.CurrentGoal = nil
                    self.CurrentActionStack = {}
                    coroutine.wait(0.1)
                end
                -- Re-check our pre-conds
                local cost, actions = check_action_cost(self, self.CurrentActionStack)
                if cost == false then
                    -- prereq failed, fail goal
                    print("failed goal (recheck)", self.CurrentGoal)
                    self.GoalMemory[self.CurrentGoal] = CurTime()
                    self.CurrentGoal = nil
                    self.CurrentActionStack = {}
                    coroutine.wait(0.1)
                else
                    print("readjusted actions")
                    PrintTable(actions)
                    self.CurrentActionStack = actions
                    self.SuccessCheck = (self.SuccessCheck or 0) + 1
                end
            end
        else
            coroutine.wait(0.5)
            self.SuccessCheck = 0
        end
    end

    -- while true do
    --     if self:HaveEnemy() then
    --         self.loco:FaceTowards(self:GetEnemy():GetPos())
    --         self:StartActivity(ACT_HL2MP_RUN_PISTOL)
    --         self.loco:SetDesiredSpeed(200)
    --         self.loco:SetAcceleration(900)
    --         self:ChaseEnemy()
    --         self.loco:SetAcceleration(400)
    --         self:StartActivity(ACT_HL2MP_WALK_PISTOL)
    --     else
    --         self:StartActivity(ACT_HL2MP_WALK_PISTOL)
    --         self.loco:SetDesiredSpeed(100)
    --         self:MoveToPos(self:GetPos() + Vector(math.Rand(-1, 1), math.Rand(-1, 1), 0) * 400) -- Walk to a random place within about 400 units (yielding)
    --         self:StartActivity(ACT_HL2MP_WALK_PISTOL)
    --     end

    --     coroutine.wait(2)
    -- end
end

function ENT:ChaseEnemy(options)
    if not IsValid(self:GetEnemy()) then return "failed" end
    options = options or {}

    local path = Path("Follow")
    path:SetMinLookAheadDistance(options.lookahead or 300)
    path:SetGoalTolerance(options.tolerance or 64)
    path:Compute(self, self:GetEnemy():GetPos())
    if not path:IsValid() then return "failed" end

    local timeout = CurTime() + (options.timeout or 1)

    while path:IsValid() and self:HaveEnemy() do

        if CurTime() > timeout then
            return "timeout"
        elseif options.stopinrange and self:GetEnemy():GetPos():Distance(self:GetPos()) <= options.tolerance then
            return "ok"
        elseif path:GetAge() > 0.1 then
            path:Compute(self, self:GetEnemy():GetPos())
        end

        path:Update(self)

        if options.draw then
            path:Draw()
        end

        if self.loco:IsStuck() then
            self:HandleStuck()

            return "stuck"
        end

        coroutine.yield()
    end

    return "ok"
end

function ENT:BodyUpdate()
    self:BodyMoveXY()
end

function ENT:OnKilled(dmginfo)
    self:DropWeapon()
    self:BecomeRagdoll(dmginfo)
end