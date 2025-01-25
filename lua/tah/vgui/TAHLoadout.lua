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
    text:SetText("Choose your starting loadout (unspent budget will be lost)")

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
    btn:SetZPos(1)

    self.Confirm.Paint = function(self2, w, h)
        local x = budget:GetWide() + ScreenScale(4)
        local box_h = h - 8
        for i = 1, self.StartingBudget do
            draw.RoundedBox(4, x + (i - 1) * (box_h / 2 + ScreenScale(1)), 4, box_h / 2, box_h, i <= self:GetBudget() and color_white or color_spent)
        end
    end

    local random = self.Confirm:Add("DButton")
    -- random:SetFont("TacRP_HD44780A00_5x8_4")
    random:SetText("")
    random:SetMaterial(Material("tacup/dice.png", "smooth"))
    -- random:SizeToContents()
    random:SetWide(self.Confirm:GetTall())
    random:Dock(RIGHT)
    random:DockMargin(0, 0, 4, 0)
    random.DoClick = function(self2)
        self:RandomLoadout()
    end
    random:SetZPos(2)

    local clear = self.Confirm:Add("DButton")
    clear:SetFont("TacRP_HD44780A00_5x8_4")
    clear:SetText("C")
    clear:SetWide(self.Confirm:GetTall())
    clear:Dock(RIGHT)
    clear:DockMargin(0, 0, 4, 0)
    clear.DoClick = function(self2)
        self:ClearLoadout()
    end
    clear:SetZPos(3)

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

function PANEL:ApplyLoadout(entries)
    self:ClearLoadout()
    for i = 1, TAH.LOADOUT_LAST do
        self.Entries[i]:SetActiveEntries(entries[i] or {})
    end
end

function PANEL:RandomLoadout()
    local entries = {}
    local budget = self.StartingBudget

    -- more secondary with cost >= 3 means more likely to start with just pistol
    local goodsecondary = {}
    for _, v in ipairs(LocalPlayer().TAH_Loadout[TAH.LOADOUT_SECONDARY]) do
        local entry = TAH.LoadoutEntries[TAH.LOADOUT_SECONDARY][v]
        if entry.cost >= 3 then
            table.insert(goodsecondary, v)
        end
    end

    if math.random() < Lerp(#goodsecondary / #LocalPlayer().TAH_Loadout[TAH.LOADOUT_SECONDARY], 0, 0.5) then
        -- 1 secondary, 0 primary
        local ind = goodsecondary[math.random(1, #goodsecondary)]
        entries[TAH.LOADOUT_SECONDARY] = {ind}
        budget = budget - TAH.LoadoutEntries[TAH.LOADOUT_SECONDARY][ind].cost
    else
        -- 1 primary, 0-1 secondary
        local tbl = LocalPlayer().TAH_Loadout[TAH.LOADOUT_PRIMARY]
        local ind = tbl[math.random(1, #tbl)]
        entries[TAH.LOADOUT_PRIMARY] = {ind}
        budget = budget - TAH.LoadoutEntries[TAH.LOADOUT_PRIMARY][ind].cost

        -- the more expensive the primary, the less likely we will bring a secondary
        if math.random() < Lerp(budget / self.StartingBudget, 0, 0.75) then
            local secondary = {}
            for _, v in ipairs(LocalPlayer().TAH_Loadout[TAH.LOADOUT_SECONDARY]) do
                local entry = TAH.LoadoutEntries[TAH.LOADOUT_SECONDARY][v]
                if entry.cost <= budget then
                    table.insert(secondary, v)
                end
            end
            local ind2 = secondary[math.random(1, #secondary)]
            entries[TAH.LOADOUT_SECONDARY] = {ind2}
            budget = budget - TAH.LoadoutEntries[TAH.LOADOUT_SECONDARY][ind2].cost
        end
    end

    -- get the best armor we can afford
    entries[TAH.LOADOUT_ARMOR] = {}
    if budget > 0 then
        local armorindex = -1
        local armorcost = -1
        for _, v in ipairs(LocalPlayer().TAH_Loadout[TAH.LOADOUT_ARMOR]) do
            local entry = TAH.LoadoutEntries[TAH.LOADOUT_ARMOR][v]
            if entry.cost <= budget and (armorindex < 0 or armorcost < entry.cost or (armorcost == entry.cost and math.random() < 0.5)) then
                armorindex = v
                armorcost = entry.cost
            end
        end
        if armorindex > 0 then
            entries[TAH.LOADOUT_ARMOR] = {armorindex}
            budget = budget - armorcost
        end
    end

    -- chance to buy equipment
    entries[TAH.LOADOUT_EQUIP] = {}
    if budget > 0 then
        for _, v in ipairs(LocalPlayer().TAH_Loadout[TAH.LOADOUT_EQUIP]) do
            local entry = TAH.LoadoutEntries[TAH.LOADOUT_EQUIP][v]
            if entry.cost <= budget and math.random() <= 1 / (1 + (entry.cost - 1) * 0.5) then
                table.insert(entries[TAH.LOADOUT_EQUIP], v)
                budget = budget - entry.cost
            end
        end
    end

    -- spend the rest on random items
    local items = table.Copy(LocalPlayer().TAH_Loadout[TAH.LOADOUT_ITEMS])
    entries[TAH.LOADOUT_ITEMS] = {}
    while budget > 0 and items[1] do
        local i = math.random(1, #items)
        local ind = items[i]
        local entry = TAH.LoadoutEntries[TAH.LOADOUT_ITEMS][ind]
        if entry.cost <= budget then
            table.insert(entries[TAH.LOADOUT_ITEMS], ind)
            budget = budget - entry.cost
        end
        table.remove(items, i)
    end

    self:ApplyLoadout(entries)
end

function PANEL:ClearLoadout()
    for _, panel in pairs(self.Entries) do
        panel:ClearEntries()
    end
    -- should not be necessary but just in case
    self:SetBudget(self.StartingBudget)
end

vgui.Register("TAHLoadout", PANEL, "DFrame")