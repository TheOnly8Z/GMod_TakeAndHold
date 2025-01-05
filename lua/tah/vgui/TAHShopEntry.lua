local PANEL = {}

AccessorFunc(PANEL, "Item", "Item")
AccessorFunc(PANEL, "ShopPanel", "ShopPanel")

function PANEL:Init()
    self:SetText("")
    self.Icon = vgui.Create("DImage", self)
    self.Title = vgui.Create("DLabel", self)

    self:SetMouseInputEnabled(true)
end

function PANEL:GetCost()
    local tbl = TAH.ShopItems[self:GetItem()] or {}
    return tbl.cost or 0
end

function PANEL:PerformLayout(w, h)
    local tbl = TAH.ShopItems[self:GetItem()]

    -- self.Icon:Dock(FILL)
    self.Icon:SetSize(math.max(w, h), math.max(w, h))
    self.Icon:Center()

    local icon = tbl.icon
    if not icon then
        icon = Material("entities/" .. self:GetItem() .. ".png")
    end

    self.Icon:SetVisible(true)
    self.Icon:SetMaterial(icon)

    self.Title:SetText(tbl.cost .. " TOKEN" .. (tbl.cost == 1 and "" or "S"))
    self.Title:SetSize(w, ScreenScale(6))
    self.Title:SetFont("TacRP_HD44780A00_5x8_4")
    self.Title:SizeToContentsX(8)
    if self.Title:GetWide() >= w then
        self.Title:SetWide(w)
    end
    self.Title:SetContentAlignment(2)
    self.Title:SetPos(w / 2 - self.Title:GetWide() / 2, h - self.Title:GetTall() - ScreenScale(2))
end

function PANEL:OnDepressed()
    self.Pressed = true
end

function PANEL:OnReleased()
    self.Pressed = false
    -- TODO
    if TAH:GetTokens(LocalPlayer()) >= self:GetCost() then
        net.Start("tah_shop")
            net.WriteEntity(self:GetShopPanel():GetShopEntity())
            net.WriteString(self:GetItem())
        net.SendToServer()
        self:GetShopPanel():Remove()
    end
end

function PANEL:Paint(w, h)
    local col_bg, col_corner, col_text, col_image = self:GetColors()

    surface.SetDrawColor(col_bg)
    surface.DrawRect(2, 2, w - 2, h - 2)
    TacRP.DrawCorneredBox(2, 2, w - 2, h - 2, col_corner)

    self.Title:SetTextColor(col_text)
    self.Icon:SetImageColor(col_image)
end

function PANEL:GetColors()
    local hover = self:IsHovered()
    local col_bg = Color(0, 0, 0, 100)
    local col_corner = Color(255, 255, 255)
    local col_text = Color(255, 255, 255)
    local col_image = Color(255, 255, 255)

    if self.Pressed then
        if hover then
            col_bg = Color(200, 200, 200)
            col_corner = Color(150, 150, 255)
            col_text = Color(0, 0, 0)
            col_image = Color(255, 255, 255)
        else
            col_bg = Color(150, 150, 150, 150)
            col_corner = Color(50, 50, 255)
            col_text = Color(0, 0, 0)
            col_image = Color(200, 200, 200)
        end
    elseif hover then
        col_bg = Color(180, 180, 180)
        col_corner = Color(0, 0, 0)
        col_text = Color(0, 0, 0)
        col_image = Color(255, 255, 255)
    elseif TAH:GetTokens(LocalPlayer()) < self:GetCost() then
        col_text = Color(255, 150, 150)

        col_bg = Color(50, 0, 0, 100)
    end

    return col_bg, col_corner, col_text, col_image
end


function PANEL:PaintOver(w, h)

    self:SetDrawOnTop(self:IsHovered())

    -- thank u fesiug
    if self:IsHovered() then

        local class = self:GetItem()
        local tbl = TAH.ShopItems[class]

        local todo = DisableClipping(true)
        local col_bg = Color(0, 0, 0, 230)
        local col_corner = Color(255, 255, 255)
        local col_text = Color(255, 255, 255)
        local rx, ry = self:CursorPos()
        rx = rx + TacRP.SS(12)
        local bw, bh = TacRP.SS(160), TacRP.SS(18)

        local name = tbl.printname
        local subcat = tbl.subcat
        local desc = tbl.desc
        local weptbl = weapons.Get(class)
        if tbl.quicknade then
            name = TacRP.QuickNades[tbl.quicknade].FullName
            desc = TacRP.QuickNades[tbl.quicknade].Description
            subcat = TacRP.FormatTierType("9Throwable", "9Special", TacRP.UseTiers())
        elseif weptbl then
            name = TacRP:GetPhrase("wep." .. class .. ".name.full") or TacRP:GetPhrase("wep." .. class .. ".name") or weptbl.PrintName
            if not subcat and weptbl.SubCatType and weptbl.SubCatTier then
                subcat = TacRP.FormatTierType(weptbl.SubCatType, weptbl.SubCatTier, TacRP.UseTiers())
            end
            desc = TacRP:GetPhrase("wep." .. class .. ".desc") or weptbl.Description or weptbl.Purpose
        end

        if tbl.ammo_count then
            name = name .. " x" .. tbl.ammo_count
        end

        if desc and not self.DescCache then
            self.DescCache = TacRP.MultiLineText(desc, bw, "TacRP_Myriad_Pro_6")
        end
        if self.DescCache then
            bh = bh + (#self.DescCache - 1) * TacRP.SS(5)
        end
        if subcat then
            bh = bh + TacRP.SS(8)
        end

        surface.SetDrawColor(col_bg)
        TacRP.DrawCorneredBox(rx, ry, bw, bh, col_corner)

        -- Name
        surface.SetTextColor(col_text)
        surface.SetFont("TacRP_Myriad_Pro_10")
        surface.SetTextPos(rx + TacRP.SS(2), ry + TacRP.SS(1))
        surface.DrawText(name)

        -- Subtitle if available
        if subcat then
            surface.SetTextColor(col_text)
            surface.SetFont("TacRP_Myriad_Pro_8")
            surface.SetTextPos(rx + TacRP.SS(2), ry + TacRP.SS(10))
            surface.DrawText(subcat)
            ry = ry + TacRP.SS(8)
        end

        -- Description
        if self.DescCache then
            surface.SetFont("TacRP_Myriad_Pro_6")
            for i, k in ipairs(self.DescCache) do
                surface.SetTextPos(rx + TacRP.SS(2), ry + TacRP.SS(1 + 8 + 2 + 5 * (i - 1)))
                surface.DrawText(k)
            end
        end

        DisableClipping(todo)
    end
end

vgui.Register("TAHShopEntry", PANEL, "DLabel")