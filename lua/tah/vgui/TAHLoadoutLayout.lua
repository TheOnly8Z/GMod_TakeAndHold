local PANEL = {}
AccessorFunc(PANEL, "Category", "Category")
AccessorFunc(PANEL, "Entries", "Entries")
AccessorFunc(PANEL, "Scroll", "Scroll")

function PANEL:LoadEntries()
    self:Clear()

    for _, i in pairs(self:GetEntries()) do
        local entry = self:Add("TAHLoadoutEntry")
        entry:SetCategory(self:GetCategory())
        entry:SetEntryIndex(i)
        entry:SetSize(TacRP.SS(32), TacRP.SS(32))
    end

    -- self:InvalidateLayout(true)

    if self:GetScroll() then
        self:GetScroll():SetVisible(true)
        self:GetScroll():SetTall(math.min(ScrH() * 0.9, #atts * (TacRP.SS(32) + self:GetSpaceY())))
        self:GetScroll():CenterVertical()
        self:GetScroll():GetVBar():SetScroll(0)
    end
end

-- function PANEL:Paint(w, h)
--     surface.SetDrawColor(255, 0, 0)
--     surface.DrawRect(0, 0, w, h)
-- end

vgui.Register("TAHLoadoutLayout", PANEL, "DIconLayout")