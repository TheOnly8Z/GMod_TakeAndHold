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
end

if CLIENT then
    local mat = Material("effects/com_shield002a")
    function ENT:Draw()
    end
    function ENT:DrawTranslucent()
        render.SetMaterial(mat)
        render.DrawBox(self:GetPos(), self:GetAngles(), self:GetMinS(), self:GetMaxS(), color_white)
    end
end