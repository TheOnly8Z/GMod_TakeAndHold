AddCSLuaFile()

ENT.PrintName = "Shop"
ENT.Category = "Take and Hold"
ENT.Base = "tah_base"
ENT.Spawnable = true
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.Model = "models/props_combine/combine_interface001.mdl"

ENT.Collision = true

ENT.TAH_Shop = true
ENT.TAH_SaveEntity = true

DEFINE_BASECLASS(ENT.Base)

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "Enabled")
end

if SERVER then
    function ENT:Initialize()
        BaseClass.Initialize(self)

        -- self:SetItems(TAH:RollShopForRound(1, 5))
        -- self:SetEnabled(true)

        TAH.Shop_Cache[self:GetClass()] = TAH.Spawn_Cache[self:GetClass()] or {}
        self.CacheIndex = table.insert(TAH.Shop_Cache[self:GetClass()], self)
    end

    function ENT:OnRemove()
        if self.CacheIndex then
            table.remove(TAH.Shop_Cache[self:GetClass()], self.CacheIndex)
        end
    end

    function ENT:UpdateTransmitState()
        if TAH:GetRoundState() == TAH.ROUND_INACTIVE then
            return TRANSMIT_ALWAYS
        end
        return TRANSMIT_PVS
    end
end


function ENT:SetItems(tbl)
    self.Items = tbl
end

function ENT:Use(ply)
    if not self.Items or not self:GetEnabled() then return end
    net.Start("tah_shop")
        net.WriteEntity(self)
        net.WriteUInt(#self.Items, 4)
        for _, class in ipairs(self.Items) do
            net.WriteString(class)
        end
    net.Send(ply)
end