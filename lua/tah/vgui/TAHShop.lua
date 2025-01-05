local PANEL = {}
DEFINE_BASECLASS("DFrame")

AccessorFunc(PANEL, "ShopEntity", "ShopEntity")

local ss = 32

function PANEL:SetItems(tbl)
    self.Items = tbl
    self.ItemPanels = {}

    self.ItemLayout:Clear()
    self.ItemLayout:Dock(FILL)
    self.ItemLayout:SetLayoutDir(TOP)
    self.ItemLayout:SetSpaceX(4)
    self.ItemLayout:SetSpaceY(4)

    for i, class in ipairs(self.Items) do
        local item = self.ItemLayout:Add("TAHShopEntry")
        item:SetSize(TacRP.SS(ss), TacRP.SS(ss))
        item:SetItem(class)
        item:SetShopPanel(self)
        self.ItemPanels[i] = item
    end
end

function PANEL:Init()
    self:SetSize(TacRP.SS(ss * 4) + 24, TacRP.SS(ss * 2) + 40)
    self:SetTitle("Shop")
    self:ShowCloseButton(true)

    self.ItemLayout = self:Add("DIconLayout")
    self.ItemLayout:Clear()
    self.ItemLayout:Dock(FILL)
    self.ItemLayout:SetLayoutDir(LEFT)
    self.ItemLayout:SetSpaceX(TacRP.SS(3))
    self.ItemLayout:SetSpaceY(8)
end

vgui.Register("TAHShop", PANEL, "DFrame")