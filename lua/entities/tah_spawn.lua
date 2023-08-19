AddCSLuaFile()

ENT.PrintName = "Spawn"
ENT.Category = "Take and Hold"
ENT.Base = "tah_base"
ENT.Spawnable = false
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.Model = "models/props_junk/sawblade001a.mdl"

ENT.NoShadows = true
ENT.Editable = true

function ENT:SetupDataTables()
end

if CLIENT then
    function ENT:DrawTranslucent()
        if TAH:GetRoundState() == TAH.ROUND_INACTIVE then
            self:DrawModel()
        end
    end
end