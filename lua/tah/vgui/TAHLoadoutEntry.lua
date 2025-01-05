local PANEL = {}

AccessorFunc(PANEL, "Category", "Category")
AccessorFunc(PANEL, "EntryIndex", "EntryIndex")
AccessorFunc(PANEL, "Active", "Active")
AccessorFunc(PANEL, "Cost", "Cost")
AccessorFunc(PANEL, "LoadoutPanel", "LoadoutPanel")

function PANEL:Init()
    self:SetText("")
    self.Icon = vgui.Create("DImage", self)
    self.Title = vgui.Create("DLabel", self)
    self.AmmoCounter = vgui.Create("DLabel", self)
    self:SetMouseInputEnabled(true)
    self:SetCost(0)
end

function PANEL:PerformLayout(w, h)

    local tbl = TAH.LoadoutEntries[self:GetCategory()][self:GetEntryIndex()]

    -- self.Icon:Dock(FILL)
    self.Icon:SetSize(math.max(w, h), math.max(w, h))
    self.Icon:Center()

    local icon = tbl.icon
    if not icon then
        if tbl.quicknade and TacRP.QuickNades[tbl.quicknade].AmmoEnt then
            icon = Material("entities/" .. TacRP.QuickNades[tbl.quicknade].AmmoEnt .. ".png", "smooth")
        elseif tbl.class then
            icon = Material("entities/" .. tbl.class .. ".png", "smooth")
        end
    end

    self.Icon:SetVisible(true)
    self.Icon:SetMaterial(icon)

    self.Title:SetText(tbl.name or "")
    self.Title:SetSize(w, ScreenScale(6))
    self.Title:SetFont("TacRP_HD44780A00_5x8_4")
    self.Title:SizeToContentsX(8)
    if self.Title:GetWide() >= w then
        self.Title:SetWide(w)
    end
    self.Title:SetContentAlignment(5)
    self.Title:SetPos(w / 2 - self.Title:GetWide() / 2, h / 2 - self.Title:GetTall() / 2)

    self.AmmoCounter:SetText("")
    if tbl.ammo_count then
        self.AmmoCounter:SetText("x" .. tbl.ammo_count)
        self.AmmoCounter:SetSize(w, ScreenScale(6))
        self.AmmoCounter:SetFont("TacRP_HD44780A00_5x8_4")
        self.AmmoCounter:SizeToContentsX(8)
        if self.AmmoCounter:GetWide() >= w then
            self.AmmoCounter:SetWide(w)
        end
        self.AmmoCounter:SetContentAlignment(3)
        self.AmmoCounter:SetPos(0, 0)
    end

    -- self.CostBar:Clear()
    -- self.CostBar:SetSize(w, blip_h)
    -- self.CostBar:SetPos(0, h - blip_h - TacRP.SS(1))
    self:SetCost(tbl.cost or 0)
end

function PANEL:DoClick()
    local budget = self:GetLoadoutPanel():GetBudget()
    if self:GetActive() then
        self:SetActive(false)
        self:GetLoadoutPanel():SetBudget(budget + self:GetCost())
    elseif budget >= self:GetCost() then
        self:SetActive(true)
        self:GetLoadoutPanel():SetBudget(budget - self:GetCost())
    end
end

local col_cantafford = Color(255, 150, 150, 255)

function PANEL:Paint(w, h)
    local col_bg, col_corner, col_text, col_image = self:GetColors()

    surface.SetDrawColor(col_bg)
    surface.DrawRect(2, 2, w - 2, h - 2)
    TacRP.DrawCorneredBox(2, 2, w - 2, h - 2, col_corner)

    self.AmmoCounter:SetTextColor(col_text)
    self.Icon:SetImageColor(col_image)

    -- surface.SetDrawColor(50, 50, 50, 150)
    -- surface.DrawRect(1, 1, w - 1, h - 1)
    -- surface.SetDrawColor(255, 255, 255, 150)
    -- surface.DrawOutlinedRect(1, 1, w - 1, h - 1, 1)
end

function PANEL:GetColors()
    local hover = self:IsHovered()
    local col_bg = Color(0, 0, 0, 100)
    local col_corner = Color(255, 255, 255)
    local col_text = Color(255, 255, 255)
    local col_image = Color(255, 255, 255)

    if self:GetActive() then
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
    elseif self:GetLoadoutPanel():GetBudget() < self:GetCost() then
        col_image = Color(200, 200, 200)
        col_bg = Color(50, 0, 0, 100)
    end

    return col_bg, col_corner, col_text, col_image
end


function PANEL:PaintOver(w, h)

    self:SetDrawOnTop(self:IsHovered())

    if (self:GetCost() or 0) > 0 then
        local blip_w, blip_h = TacRP.SS(2), TacRP.SS(4)

        local x_blip = w / 2 - self:GetCost() * (2 + blip_w) / 2

        for i = 1, self:GetCost() do
            draw.RoundedBoxEx(4, x_blip + (i - 1) * (blip_w + 2) + 1, h - blip_h - 4, blip_w, blip_h,
                (self:GetActive() or self:GetLoadoutPanel():GetBudget() >= i) and color_white or col_cantafford,
                i == 1, i == self:GetCost(), i == 1, i == self:GetCost())
        end
    end

    if self:IsHovered() then
        local tbl = TAH.LoadoutEntries[self:GetCategory()][self:GetEntryIndex()]

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
        local weptbl = weapons.Get(tbl.class)
        if tbl.quicknade then
            name = TacRP.QuickNades[tbl.quicknade].FullName
            desc = TacRP.QuickNades[tbl.quicknade].Description
            subcat = TacRP.FormatTierType("9Throwable", "9Special", TacRP.UseTiers())
        elseif weptbl then
            name = TacRP:GetPhrase("wep." .. tbl.class .. ".name.full") or TacRP:GetPhrase("wep." .. tbl.class .. ".name") or weptbl.PrintName
            if not subcat and weptbl.SubCatType and weptbl.SubCatTier then
                subcat = TacRP.FormatTierType(weptbl.SubCatType, weptbl.SubCatTier, TacRP.UseTiers())
            end
            desc = TacRP:GetPhrase("wep." .. tbl.class .. ".desc") or weptbl.Description or weptbl.Purpose
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

vgui.Register("TAHLoadoutEntry", PANEL, "DLabel")