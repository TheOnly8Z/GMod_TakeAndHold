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
    self:NetworkVarNotify( "Enabled", self.OnToggleEnabled )
end

function ENT:OnToggleEnabled(name, old, new)
    if new then
        self:SetSkin(0)
        self.Visited = false
    else
        self:SetSkin(1)
    end
end

function ENT:Initialize()
    BaseClass.Initialize(self)

    table.insert(TAH.Shop_Cache, self)
end

function ENT:OnRemove()
    table.RemoveByValue(TAH.Shop_Cache, self)
end

if SERVER then
    function ENT:UpdateTransmitState()
        if self:GetEnabled() or TAH:GetRoundState() == TAH.ROUND_INACTIVE then
            return TRANSMIT_ALWAYS
        end
        return TRANSMIT_PVS
    end
end


function ENT:SetItems(tbl)
    self.Items = tbl
end

function ENT:Use(ply)
    if not self.Items or not self:GetEnabled() or TAH:GetRoundState() ~= TAH.ROUND_TAKE then return end
    net.Start("tah_shop")
        net.WriteEntity(self)
        net.WriteUInt(#self.Items, 4)
        for _, class in ipairs(self.Items) do
            net.WriteString(class)
        end
    net.Send(ply)
end