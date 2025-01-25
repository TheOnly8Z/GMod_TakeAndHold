local PANEL = {}
AccessorFunc(PANEL, "Category", "Category")
AccessorFunc(PANEL, "Entries", "Entries")
AccessorFunc(PANEL, "LoadoutPanel", "LoadoutPanel")
AccessorFunc(PANEL, "CurrentCost", "CurrentCost")

function PANEL:LoadEntries()
    self:Clear()
    self.EntryPanels = {}
    self:SetCurrentCost(0)

    self.IsLimitedSlot = TAH.LoadoutLimitedSlot[self:GetCategory()]

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

function PANEL:GetCategoryCost()
    if self.IsLimitedSlot then
        return self:GetCurrentCost()
    else
        return 0
    end
end

function PANEL:OnEntryUpdated(panel)
    if panel:GetActive() then
        self:SetCurrentCost(self:GetCurrentCost() + panel:GetCost())
        if self.IsLimitedSlot then
            for i, entry in pairs(self.EntryPanels or {}) do
                if entry ~= panel and entry:GetActive() then
                    -- self:GetLoadoutPanel():SetBudget(self:GetLoadoutPanel():GetBudget() + entry:GetCost())
                    entry:SetActive(false)
                end
            end
        end
    else
        self:SetCurrentCost(self:GetCurrentCost() - panel:GetCost())
    end
end

function PANEL:SetActiveEntries(entries)
    self:ClearEntries()
    for _, i in ipairs(entries) do
        local entry = self.EntryPanels[i]
        entry:SetActive(true)
        -- self:GetLoadoutPanel():SetBudget(self:GetLoadoutPanel():GetBudget() - entry:GetCost())
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

function PANEL:ClearEntries()
    for i, entry in pairs(self.EntryPanels or {}) do
        if entry:GetActive() then
            -- self:GetLoadoutPanel():SetBudget(self:GetLoadoutPanel():GetBudget() + entry:GetCost())
            entry:SetActive(false)
        end
    end
end

-- function PANEL:Paint(w, h)
--     surface.SetDrawColor(255, 0, 0)
--     surface.DrawRect(0, 0, w, h)
-- end

vgui.Register("TAHLoadoutLayout", PANEL, "DIconLayout")