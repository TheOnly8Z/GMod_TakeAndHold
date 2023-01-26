AddCSLuaFile()

ENT.PrintName = "Base Node"
ENT.Type = "anim"
ENT.Spawnable = false
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.Model = "models/hunter/blocks/cube025x025x025.mdl"
ENT.MaxHealth = 10

function ENT:Initialize()
    if SERVER then
        self:SetModel(self.Model)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:GetPhysicsObject():EnableMotion(false)

        self:SetMaxHealth(self.MaxHealth)
        self:SetHealth(self.MaxHealth)

        self:SetTrigger(false)
    end

    self:OnInitialize()
    self:SetCustomCollisionCheck(true)
end

function ENT:OnInitialize()
    self:SetColor(Color(255, 0, 0))
end

if SERVER then
    function ENT:OnTakeDamage(dmginfo)
        self:SetHealth(self:Health() - dmginfo:GetDamage())
        if self:Health() <= 0 then
            self:EmitSound("physics/glass/glass_cup_break2.wav", 100, 120)
            self:Remove()
        end

        return dmginfo:GetDamage()
    end
end