AddCSLuaFile()

ENT.PrintName = ""
ENT.Category = "Take and Hold"
ENT.Type = "anim"

ENT.Model = ""
ENT.Static = true
ENT.Collision = false
ENT.Trigger = false
ENT.TriggerBounds = nil
ENT.Color = nil
if SERVER then
    function ENT:Initialize()
        self:SetModel(self.Model)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetUseType(SIMPLE_USE)

        if self.Color then
            self:SetColor(self.Color)
        end
        if self.Static then
            -- self:SetMoveType(MOVETYPE_NONE)
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