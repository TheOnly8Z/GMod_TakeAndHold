AddCSLuaFile()

ENT.PrintName = "Crate Spawn"
ENT.Category = "Tactical Takeover"
ENT.Base = "tah_base"
ENT.Spawnable = true
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.TAH_SaveEntity = true

ENT.Model = "models/Items/item_item_crate.mdl"
ENT.Color = Color(255, 255, 255, 150)
ENT.NoShadows = true
ENT.Collision = false

DEFINE_BASECLASS(ENT.Base)


local mins, maxs, clr = Vector(-15, -17, 0), Vector(17, 15, 24), Color(255, 200, 100, 255)
if CLIENT then
    function ENT:DrawTranslucent()
        if TAH:GetRoundState() == TAH.ROUND_INACTIVE then
            self:DrawModel()
            render.SetColorMaterial()
            render.DrawWireframeBox(self:GetPos(), self:GetAngles(), mins, maxs, clr, true)
        end
    end
end