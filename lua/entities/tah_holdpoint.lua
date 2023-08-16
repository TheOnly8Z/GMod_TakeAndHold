AddCSLuaFile()

ENT.PrintName = "Hold Point"
ENT.Category = "Take and Hold"
ENT.Base = "tah_base"
ENT.Spawnable = true
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.Model = "models/props_trainstation/trainstation_ornament002.mdl"

ENT.Editable = true

ENT.Trigger = true
ENT.TriggerBounds = 8

function ENT:SetupDataTables()
    self:NetworkVar("Float", 0, "Radius", {
        KeyName = "radius",
        Edit = {
            type = "Float",
            order = 1,
            min = 64,
            max = 1024,
        }
    })
    self:SetRadius(128)
end

if SERVER then
    function ENT:Touch(ent)
        if ent:IsPlayer() and TAH:GetRoundState() == TAH.ROUND_TAKE and TAH:GetHoldEntity() == self then
            -- TODO: Ensure all other players are inside!
            TAH:StartHold()
        end
    end
elseif CLIENT then
    function ENT:DrawTranslucent()
        self:DrawModel()
    end
end