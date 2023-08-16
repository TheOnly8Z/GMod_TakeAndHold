AddCSLuaFile()

ENT.PrintName = ""
ENT.Category = "Take and Hold"
ENT.Type = "anim"

ENT.Model = ""
ENT.Static = true
ENT.Collision = false
ENT.Trigger = false
ENT.TriggerBounds = nil

if SERVER then
    function ENT:Initialize()
        self:SetModel(self.Model)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetUseType(SIMPLE_USE)

        if self.Static then
            self:GetPhysicsObject():EnableMotion(false)
        end
        if not self.Collision then
            self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
        end
        if self.Trigger then
            self:SetTrigger(true)
            self:UseTriggerBounds(self.TriggerBounds ~= nil, self.TriggerBounds)
        end
    end
end