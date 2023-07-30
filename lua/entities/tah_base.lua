AddCSLuaFile()

ENT.PrintName = ""
ENT.Category = "Take and Hold"
ENT.Type = "anim"

ENT.Model = ""
ENT.Static = true

if SERVER then
    function ENT:Initialize()
        self:SetModel(self.Model)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetUseType(SIMPLE_USE)

        if self.Static then
            self:GetPhysicsObject():EnableMotion(false)
        end
    end
end