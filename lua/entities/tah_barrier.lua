AddCSLuaFile()

ENT.PrintName = "Barrier"
ENT.Type = "anim"
ENT.Spawnable = false
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:SetupDataTables()
    self:NetworkVar("Vector", 0, "MinS")
    self:NetworkVar("Vector", 1, "MaxS")
end

function ENT:Initialize()
    self:SetModel("models/hunter/blocks/cube025x025x025.mdl")
    self:DrawShadow(false)

    self.PhysCollide = CreatePhysCollideBox(self:GetMinS(), self:GetMaxS())
    self:SetCollisionBounds(self:GetMinS(), self:GetMaxS())

    self:SetCollisionGroup(COLLISION_GROUP_NONE)

    if SERVER then
        self:PhysicsInitBox(self:GetMinS(), self:GetMaxS())
        self:SetSolid(SOLID_VPHYSICS)
        self:PhysWake()

        local physobj = self:GetPhysicsObject()
        if IsValid(physobj) then
            physobj:EnableMotion(false)
        else
            ErrorNoHalt("wtf")
        end
    end

    if CLIENT then
        self:SetRenderBounds(self:GetMinS(), self:GetMaxS())
    end

    self:EnableCustomCollisions(true)
    self:SetCustomCollisionCheck(true)
    --self:CollisionRulesChanged()
end

-- Handles collisions against traces. This includes player movement.
-- function ENT:TestCollision( startpos, delta, isbox, extents, mask )
--     if not IsValid( self.PhysCollide ) then
--         return
--     end

--     if bit.band( mask, CONTENTS_MONSTERCLIP ) ~= 0 then return false end -- Let NPCs through
--     if bit.band( mask, CONTENTS_GRATE ) ~= 0 then return true end

--     -- TraceBox expects the trace to begin at the center of the box, but TestCollision is bad
--     local max = extents
--     local min = -extents
--     max.z = max.z - min.z
--     min.z = 0

--     local hit, norm, frac = self.PhysCollide:TraceBox( self:GetPos(), self:GetAngles(), startpos, startpos + delta, min, max )

--     if not hit then
--         return
--     end

--     return {
--         HitPos = hit,
--         Normal  = norm,
--         Fraction = frac,
--     }
-- end

if CLIENT then
    local mat = Material("effects/com_shield002a")
    function ENT:Draw()
    end
    function ENT:DrawTranslucent()
        render.SetMaterial(mat)
        render.DrawBox(self:GetPos(), self:GetAngles(), self:GetMinS(), self:GetMaxS(), color_white)
    end
end

hook.Add("ShouldCollide", "tah_barrier", function(ent1, ent2)
    if ent1:GetClass() == "tah_barrier" then
        return ent2:IsPlayer()
    end
    if ent2:GetClass() == "tah_barrier" then
        return ent1:IsPlayer()
    end
end)