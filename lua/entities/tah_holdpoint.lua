AddCSLuaFile()

ENT.PrintName = "Hold Point"
ENT.Category = "Take and Hold"
ENT.Base = "tah_base"
ENT.Spawnable = true
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.Model = "models/props_trainstation/trainstation_ornament002.mdl"

ENT.Editable = true

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
end