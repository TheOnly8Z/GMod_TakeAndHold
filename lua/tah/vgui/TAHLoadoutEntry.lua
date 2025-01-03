local PANEL = {}

AccessorFunc(PANEL, "Category", "Category")
AccessorFunc(PANEL, "EntryIndex", "EntryIndex")
AccessorFunc(PANEL, "Active", "Active")


function PANEL:Init()

    self:SetText("")

    self.Icon = vgui.Create("DImage", self)
    self.Title = vgui.Create("DLabel", self)
    self.AmmoCounter = vgui.Create("DLabel", self)
    self.CostBar = vgui.Create("DPanel", self)

    self.CostBar.Paint = function(self2, w, h)
        -- surface.SetDrawColor(255, 0, 255)
        -- surface.DrawOutlinedRect(0, 0, w, h, 1)
        -- surface.DrawLine(w / 2, 0, w / 2, h)
    end


    self:SetMouseInputEnabled(true)
end


function PANEL:PerformLayout(w, h)

    local tbl = TAH.LoadoutEntries[self:GetCategory()][self:GetEntryIndex()]

    -- self.Icon:Dock(FILL)
    self.Icon:SetSize(math.max(w, h), math.max(w, h))
    self.Icon:Center()

    local icon = tbl.icon
    if tbl.class and not icon then
        icon = Material("entities/" .. tbl.class .. ".png")
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

    local blip_w, blip_h = TacRP.SS(2), TacRP.SS(4)
    self.CostBar:Clear()
    self.CostBar:SetSize(w, blip_h)
    self.CostBar:SetPos(0, h - blip_h - TacRP.SS(1))
    local x_blip = w / 2 - (tbl.cost or 0) * (2 + blip_w) / 2

    for i = 1, (tbl.cost or 0) do
        local blip = self.CostBar:Add("DPanel")
        blip:SetSize(blip_w, blip_h)
        blip:SetPos(x_blip + (i - 1) * (blip_w + 2) + 1, 0)
        -- blip:SetBackgroundColor(Color(255, 255, 255, 100))
    end
end

function PANEL:DoClick()
    self:SetActive(not self:GetActive())
end

function PANEL:Paint(w, h)
    local col_bg, col_corner, col_text, col_image = self:GetColors()

    surface.SetDrawColor(col_bg)
    surface.DrawRect(2, 2, w - 2, h - 2)
    TacRP.DrawCorneredBox(2, 2, w - 2, h - 2, col_corner)

    self.Title:SetTextColor(col_text)
    self.Icon:SetImageColor(col_image)

    -- surface.SetDrawColor(50, 50, 50, 150)
    -- surface.DrawRect(1, 1, w - 1, h - 1)
    -- surface.SetDrawColor(255, 255, 255, 150)
    -- surface.DrawOutlinedRect(1, 1, w - 1, h - 1, 1)
end

function PANEL:GetColors()
    local hover = self:IsHovered()
    local col_bg = Color(0, 0, 0, 150)
    local col_corner = Color(255, 255, 255)
    local col_text = Color(255, 255, 255)
    local col_image = Color(255, 255, 255)

    if self:GetActive() then
        if hover then
            col_bg = Color(200, 200, 200)
            col_corner = Color(150, 150, 255)
            -- col_text = Color(0, 0, 0)
            col_image = Color(255, 255, 255)
        else
            col_bg = Color(150, 150, 150, 150)
            col_corner = Color(50, 50, 255)
            -- col_text = Color(0, 0, 0)
            col_image = Color(200, 200, 200)
        end
    elseif hover then
        col_bg = Color(180, 180, 180)
        col_corner = Color(0, 0, 0)
        -- col_text = Color(0, 0, 0)
        col_image = Color(255, 255, 255)
    end

    return col_bg, col_corner, col_text, col_image
end

vgui.Register("TAHLoadoutEntry", PANEL, "DLabel")