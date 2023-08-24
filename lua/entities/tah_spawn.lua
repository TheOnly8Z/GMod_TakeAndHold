AddCSLuaFile()

ENT.PrintName = "Spawn"
ENT.Category = "Take and Hold"
ENT.Base = "tah_base"
ENT.Spawnable = false
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.Model = "models/props_junk/sawblade001a.mdl"

ENT.NoShadows = true
ENT.Editable = true

DEFINE_BASECLASS(ENT.Base)

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "Radius", {
        KeyName = "radius",
        Edit = {
            category = "Area",
            type = "Int",
            order = 3,
            min = 128,
            max = 1024,
            readonly = true
        }
    })
end

if SERVER then
    function ENT:Initialize()
        BaseClass.Initialize(self)

        if self:GetName() == "" then
            if self:MapCreationID() ~= -1 then
                self:SetKeyValue("targetname", "tah_spawn_" .. self:MapCreationID())
            else
                self:SetKeyValue("targetname", "tah_spawn_" .. self:GetCreationID())
            end
        end
    end
end

if CLIENT then
    function ENT:DrawTranslucent()
        if TAH:GetRoundState() == TAH.ROUND_INACTIVE then
            self:DrawModel()
        end
    end
end