local PANEL = {}

AccessorFunc(PANEL, "Budget", "Budget")


DEFINE_BASECLASS("DFrame")

local color_spent = Color(150, 150, 150)

function PANEL:Init()
    self:SetSize(TacRP.SS(196), TacRP.SS(196))
    self:SetTitle("Loadout")

    self.BudgetPanel = self:Add("DPanel")
    self.Entries = self:Add("DIconLayout")
    self.Confirm = self:Add("DPanel")

    self.BudgetPanel:Dock(TOP)
    self.BudgetPanel:SetTall(TacRP.SS(12))
    self.BudgetPanel.Paint = function(self2, w, h) end
    local text = self.BudgetPanel:Add("DLabel")
    text:Dock(FILL)
    text:SetContentAlignment(5)
    text:SetFont("TacRP_Myriad_Pro_8")
    text:SetText("Choose your starting equipment (excess budget will be lost)")

    self.Confirm:Dock(BOTTOM)
    self.Confirm:DockMargin(8, 4, 4, 4)
    self.Confirm:SetTall(TacRP.SS(14))
    local budget = self.Confirm:Add("DLabel")
    budget:SetContentAlignment(4)
    budget:SetFont("TacRP_HD44780A00_5x8_6")
    budget:SetText("BUDGET:")
    budget:SizeToContents()
    budget:Dock(LEFT)

    local btn = self.Confirm:Add("DButton")
    btn:SetFont("TacRP_HD44780A00_5x8_4")
    btn:SetText("  Confirm Loadout  ")
    btn:SizeToContents()
    btn:Dock(RIGHT)

    self.Confirm.Paint = function(self2, w, h)
        local x = budget:GetWide() + TacRP.SS(4)
        local box_h = h - 8
        for i = 1, self.StartingBudget do
            draw.RoundedBox(4, x + (i - 1) * (box_h / 2 + TacRP.SS(1)), 4, box_h / 2, box_h, i <= self:GetBudget() and color_white or color_spent)
        end
    end

    self.Entries:Clear()
    self.Entries:Dock(FILL)
    self.Entries:SetLayoutDir(TOP)
    self.Entries:SetSpaceY(8)

    for k, v in SortedPairs(TAH.LoadoutEntries) do
        local _, indices = TAH:RollLoadoutEntries(v, TAH.LoadoutChoiceCount[k])
        local layout = self.Entries:Add("TAHLoadoutLayout")
        layout:SetLoadoutPanel(self)
        layout.OwnLine = true
        layout:SetTall(TacRP.SS(32))
        layout:Dock(TOP)
        layout:SetCategory(k)
        layout:SetEntries(indices)
        layout:LoadEntries()
    end

    self.StartingBudget = TAH:GetPlayerBudget(LocalPlayer())
    self:SetBudget(self.StartingBudget)
end

vgui.Register("TAHLoadout", PANEL, "DFrame")