local PANEL = {}
DEFINE_BASECLASS("DFrame")

AccessorFunc(PANEL, "ShopEntity", "ShopEntity")

function PANEL:SetItems(tbl)
    self.Items = tbl
    self.ItemPanels = {}

    self.ItemLayout:Clear()
    self.ItemLayout:Dock(FILL)
    self.ItemLayout:SetLayoutDir(LEFT)
    self.ItemLayout:SetSpaceY(8)

    for i, class in ipairs(self.Items) do
        local item = self.ItemLayout:Add("TAHShopEntry")
        item:SetSize(TacRP.SS(48), TacRP.SS(48))
        item:SetItem(class)
        item:SetShopPanel(self)
        self.ItemPanels[i] = item
    end
end

function PANEL:Init()
    self:SetSize(TacRP.SS(256), TacRP.SS(48) + 40)
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