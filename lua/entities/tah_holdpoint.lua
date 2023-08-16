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
    self:NetworkVar("Int", 1, "Height", {
        KeyName = "height",
        Edit = {
            category = "Area",
            type = "Int",
            order = 4,
            min = 128,
            max = 512,
            readonly = true
        }
    })
    if self:GetRadius() == 0 then
        self:SetRadius(256)
    end
    if self:GetHeight() == 0 then
        self:SetHeight(128)
    end

    self:NetworkVar("Bool", 0, "UseAABB", {
        KeyName = "useaabb",
        Edit = {
            category = "Area",
            title = "Use Bounding Box",
            type = "Boolean",
            order = 2,
            readonly = true
        }
    })
    self:NetworkVar("Vector", 0, "MinS", {
        KeyName = "mins",
    })
    self:NetworkVar("Vector", 1, "MaxS", {
        KeyName = "maxs",
    })

    self:NetworkVar("Bool", 1, "Cage", {
        KeyName = "ignorearea",
        Edit = {
            category = "Area",
            title = "Ignore Area",
            type = "Boolean",
            order = 1,
            readonly = false
        }
    })
end

function ENT:VectorWithinArea(pos)
    if self:GetUseAABB() then
        return pos:WithinAABox(self:GetMinS(), self:GetMaxS())
    else
        return (pos.z - self:GetPos().z) >= 0 and (pos.z - self:GetPos().z) <= self:GetHeight()
                and math.sqrt((pos.x - self:GetPos().x) ^ 2 + (pos.y - self:GetPos().y) ^ 2) <= self:GetRadius()
    end
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
