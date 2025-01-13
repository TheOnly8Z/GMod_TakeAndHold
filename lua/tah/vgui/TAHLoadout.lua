local PANEL = {}

AccessorFunc(PANEL, "Budget", "Budget")


DEFINE_BASECLASS("DFrame")

local color_spent = Color(150, 150, 150)

function PANEL:Init()
    self:SetSize(ScreenScale(196), ScreenScale(196))
    self:SetTitle("Loadout")
    self:ShowCloseButton(false)
    self:SetBackgroundBlur(false)

    self.BudgetPanel = self:Add("DPanel")
    self.EntriesPanel = self:Add("DIconLayout")
    self.Confirm = self:Add("DPanel")

    self.Entries = {}

    self.BudgetPanel:Dock(TOP)
    self.BudgetPanel:SetTall(ScreenScale(12))
    self.BudgetPanel.Paint = function(self2, w, h) end
    local text = self.BudgetPanel:Add("DLabel")
    text:Dock(FILL)
    text:SetContentAlignment(5)
    text:SetFont("TacRP_Myriad_Pro_8")
    text:SetText("Choose your starting equipment (excess budget will be lost)")

    self.Confirm:Dock(BOTTOM)
    self.Confirm:DockMargin(8, 4, 4, 0)
    self.Confirm:SetTall(ScreenScale(12))
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
    btn.DoClick = function(self2)
        if self:GetBudget() > 0 then
            Derma_Query("Are you sure? You have " .. self:GetBudget() .. " unspent budget.\nIf you continue, they will be lost!", "Loadout", "Yes", function()
                net.Start("tah_loadout")
                    for i = 1, TAH.LOADOUT_LAST do
                        local entries = self.Entries[i]:GetActiveEntries()
                        net.WriteUInt(#entries, 4)
                        for _, v in ipairs(entries) do
                            net.WriteUInt(v, 8)
                        end
                    end
                net.SendToServer()
                self:Remove()
            end, "No")
        else
            net.Start("tah_loadout")
                for i = 1, TAH.LOADOUT_LAST do
                    local entries = self.Entries[i]:GetActiveEntries()
                    net.WriteUInt(#entries, 4)
                    for _, v in ipairs(entries) do
                        net.WriteUInt(v, 8)
                    end
                end
            net.SendToServer()
            self:Remove()
        end
    end

    self.Confirm.Paint = function(self2, w, h)
        local x = budget:GetWide() + ScreenScale(4)
        local box_h = h - 8
        for i = 1, self.StartingBudget do
            draw.RoundedBox(4, x + (i - 1) * (box_h / 2 + ScreenScale(1)), 4, box_h / 2, box_h, i <= self:GetBudget() and color_white or color_spent)
        end
    end

    self.EntriesPanel:Clear()
    self.EntriesPanel:Dock(FILL)
    self.EntriesPanel:SetLayoutDir(TOP)
    self.EntriesPanel:SetSpaceY(8)

    for i = 1, TAH.LOADOUT_LAST do
        local indices = LocalPlayer().TAH_Loadout[i]
        local layout = self.EntriesPanel:Add("TAHLoadoutLayout")
        layout:SetLoadoutPanel(self)
        layout.OwnLine = true
        layout:SetTall(ScreenScale(32))
        layout:Dock(TOP)
        layout:SetCategory(i)
        layout:SetEntries(indices)
        layout:LoadEntries()
        self.Entries[i] = layout
    end

    self.StartingBudget = TAH:GetPlayerBudget(LocalPlayer())
    self:SetBudget(self.StartingBudget)
end

vgui.Register("TAHLoadout", PANEL, "DFrame")