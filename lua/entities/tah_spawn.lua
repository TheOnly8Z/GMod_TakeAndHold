AddCSLuaFile()

ENT.PrintName = "Spawn"
ENT.Category = "Take and Hold"
ENT.Base = "tah_base"
ENT.Spawnable = false
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.TAH_Spawn = true

ENT.Model = "models/props_junk/sawblade001a.mdl"

ENT.NoShadows = true
ENT.Editable = false

DEFINE_BASECLASS(ENT.Base)

function ENT:SetupDataTables()
    -- Bitflag corresponding to serial ID
    self:NetworkVar("Int", 0, "LinkBits", {
        KeyName = "link_bits",
    })
    self:NetworkVarNotify("LinkBits", function(self2, name, old, new)
        self2.LinkCache = nil
    end)
end

function ENT:GetLinkedHolds()
    if self.LinkCache == nil then
        local holds = ents.FindByClass("tah_holdpoint")
        self.LinkCache = {}
        local b = self:GetLinkBits()
        local i = 1
        while b > 0 do
            if b % 2 == 1 then
                for j, ent in pairs(holds) do
                    if ent:GetSerialID() == i then
                        self.LinkCache[i] = ent
                        table.remove(holds, j)
                        break
                    end
                end
            end
            b = bit.rshift(b, 1)
            i = i + 1
        end
    end
    return self.LinkCache
end

function ENT:SetLinkedHolds(holds)
    local b = 0
    for _, ent in pairs(holds) do
        b = bit.bor(b, 2 ^ (ent:GetSerialID() - 1))
    end
    self:SetLinkBits(b)
end

function ENT:IsLinkedWith(ent)
    if ent:GetSerialID() == 0 then return false end
    return bit.band(self:GetLinkBits(), 2 ^ (ent:GetSerialID() - 1)) ~= 0
end

function ENT:AddLinkedHold(ent)
    if ent:GetSerialID() == 0 then return end
    self:SetLinkBits(bit.bor(self:GetLinkBits(), 2 ^ (ent:GetSerialID() - 1)))
end

function ENT:RemoveLinkedHold(ent)
    if ent:GetSerialID() == 0 then return end
    self:SetLinkBits(bit.band(self:GetLinkBits(), bit.bnot(2 ^ (ent:GetSerialID() - 1))))
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
            self:GetLinkBits()
        }
    end

    function ENT:Deserialize(tbl, version)
        self:SetPos(tbl[1])
        self:SetAngles(tbl[2])
        self:SetLinkBits(tbl[3])
    end
end

if CLIENT then
    function ENT:DrawTranslucent()
        if TAH:GetRoundState() == TAH.ROUND_INACTIVE then
            self:DrawModel()
            draw.NoTexture()
            render.DrawSphere(self:GetPos() + self:GetForward() * 16, 2, 8, 8, self.Color)
            for _, v in pairs(self:GetLinkedHolds()) do
                render.DrawLine(v:GetPos(), self:GetPos(), self.Color, false)
            end
        end
    end
end