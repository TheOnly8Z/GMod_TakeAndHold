local PANEL = {}
AccessorFunc(PANEL, "Category", "Category")
AccessorFunc(PANEL, "Entries", "Entries")
AccessorFunc(PANEL, "LoadoutPanel", "LoadoutPanel")

function PANEL:LoadEntries()
    self:Clear()
    self.EntryPanels = {}

    for _, i in pairs(self:GetEntries()) do
        local entry = self:Add("TAHLoadoutEntry")
        entry:SetCategory(self:GetCategory())
        entry:SetEntryIndex(i)
        entry:SetLoadoutPanel(self:GetLoadoutPanel())
        if self:GetCategory() == TAH.LOADOUT_PRIMARY then
            entry:SetSize(TacRP.SS(64), TacRP.SS(32))
        else
            entry:SetSize(TacRP.SS(32), TacRP.SS(32))
        end
        self.EntryPanels[i] = entry
    end
end

function PANEL:GetActiveEntries()
    local entries = {}
    for i, entry in pairs(self.EntryPanels or {}) do
        if entry:GetActive() then
            table.insert(entries, i)
        end
    end
    return entries
end

-- function PANEL:Paint(w, h)
--     surface.SetDrawColor(255, 0, 0)
--     surface.DrawRect(0, 0, w, h)
-- end

vgui.Register("TAHLoadoutLayout", PANEL, "DIconLayout")