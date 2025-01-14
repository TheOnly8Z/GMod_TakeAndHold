AddCSLuaFile()

ENT.PrintName = ""
ENT.Category = "Tactical Takeover"
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
            if self.Color.a < 255 then
                self:SetRenderMode(RENDERMODE_TRANSCOLOR)
            end
        end
        if self.Static then
            -- self:SetMoveType(MOVETYPE_NONE)
            self:GetPhysicsObject():EnableMotion(false)
        else
            self:PhysWake()
        end
        if self.Collision == false then
            self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
        elseif self.Collision ~= true and self.Collision ~= nil then
            self:SetCollisionGroup(self.Collision)
        end
        if self.Trigger then
            self:SetTrigger(true)
            self:UseTriggerBounds(self.TriggerBounds ~= nil, self.TriggerBounds)
        end
        if self.NoShadows then
            self:DrawShadow(false)
        end
    end

    function ENT:Serialize(version)
        return {self:GetPos(), self:GetAngles()}
    end

    function ENT:Deserialize(tbl, version)
        local pos, ang = tbl[1], tbl[2]
        self:SetPos(pos)
        self:SetAngles(ang)
    end
end