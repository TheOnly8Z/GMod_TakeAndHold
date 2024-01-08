AddCSLuaFile()

ENT.PrintName = "Spawn"
ENT.Category = "Take and Hold"
ENT.Base = "tah_base"
ENT.Spawnable = false
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.Model = "models/props_junk/sawblade001a.mdl"
ENT.DefaultRadius = 1024

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
            max = 4096,
            readonly = false
        }
    })
    if self:GetRadius() == 0 then
        self:SetRadius(self.DefaultRadius)
    end
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

        TAH.Spawn_Cache[self:GetClass()] = TAH.Spawn_Cache[self:GetClass()] or {}
        self.CacheIndex = table.insert(TAH.Spawn_Cache[self:GetClass()], self)
    end

    function ENT:OnRemove()
        if self.CacheIndex then
            table.remove(TAH.Spawn_Cache[self:GetClass()], self.CacheIndex)
        end
    end

    function ENT:Serialize(version)
        return {
            self:GetPos(),
            self:GetAngles(),
            self:GetRadius()
        }
    end

    function ENT:Deserialize(tbl, version)
        self:SetPos(tbl[1])
        self:SetAngles(tbl[2])
        self:SetRadius(tbl[3])
    end
end

if CLIENT then
    function ENT:DrawTranslucent()
        if TAH:GetRoundState() == TAH.ROUND_INACTIVE then
            self:DrawModel()
            render.DrawSphere(self:GetPos() + self:GetForward() * 16, 2, 8, 8, self.Color)
            for _, v in pairs(ents.FindByClass("tah_holdpoint")) do
                if v:GetPos():Distance(self:GetPos()) <= self:GetRadius() then
                    render.DrawLine(v:GetPos(), self:GetPos(), self.Color, false)
                end
            end
        end
    end
end