local PANEL = {}

DEFINE_BASECLASS("DFrame")

local color_spent = Color(150, 150, 150)

function PANEL:Init()
    if not LocalPlayer():IsAdmin() then
        Derma_Message("Only admins can use this menu!", "Tactical Takeover", "OK")
        self:Remove()
        return
    end

    if TAH.GameControllerPanel ~= nil then
        TAH.GameControllerPanel:Remove()
    end

    TAH.GameControllerPanel = self

    self:SetSize(ScreenScale(128), ScreenScale(160))
    self:SetTitle("Tactical Takeover")
    self:ShowCloseButton(true)
    self:SetBackgroundBlur(false)

    self.LayoutBox = self:Add("DComboBox")
    self.ParameterForm = self:Add("DIconLayout")
    self.Parameters = {}
    self.Messages = self:Add("DIconLayout")
    self.ParameterLabel = self:Add("DLabel")
    self.MessagesLabel = self:Add("DLabel")


    self.LayoutSaveLoad = self:Add("DPanel")
    self.LayoutSaveLoad.Paint = function() end
    self.SaveButton = self.LayoutSaveLoad:Add("DButton")
    self.LoadButton = self.LayoutSaveLoad:Add("DButton")

    self.StartStopBtn = self:Add("DButton")
    self.HintLabel = self:Add("DLabel")

    local oldpaint = self.StartStopBtn.Paint
    self.StartStopBtn.Paint = function(self2, w, h)
        oldpaint(self2, w, h)
        if (TAH:GetRoundState() == TAH.ROUND_INACTIVE) ~= self2.LastState then
            self2.LastState = TAH:GetRoundState() == TAH.ROUND_INACTIVE
            self2:SetText(self2.LastState and "START GAME" or "STOP GAME")
        end
    end

    local placeholder = self.Messages:Add("DLabel")
    placeholder:Dock(FILL)
    placeholder:SetContentAlignment(5)
    placeholder:SetFont("TacRP_HD44780A00_5x8_4")
    placeholder:SetText("... VALIDATING LAYOUT ...")

    --[[]
    local font = "TacRP_HD44780A00_5x8_6"
    self.StatePanel:Dock(TOP)
    self.StatePanel:SetTall(ScreenScale(12))
    self.StatePanel.Paint = function(self2, w, h)
        draw.SimpleText(TAH:IsGameActive() and "Active Game" or "Inactive", font, w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    ]]

    net.Start("tah_checkconfig")
    net.SendToServer()
end

local AddControl = {
    ["b"] = function(p, k, d)
        local pnl = p:Add("DCheckBoxLabel")
        pnl:SetText(d.name)
        pnl:SetDark(false)
        pnl:SetChecked(TAH:GetParameter(k))
        pnl.OnChange = function(self, v)
            TAH:SetParameter(k, v)
        end
        return pnl
    end,
}

function PANEL:PerformLayout(w, h)
    BaseClass.PerformLayout(self, w, h)

    self.LayoutBox:Dock(TOP)
    self.LayoutBox:SetFont("DermaDefaultBold")
    self.LayoutBox:SetTall(ScreenScale(10))
    self.LayoutBox:DockMargin(ScreenScale(4), ScreenScale(1), ScreenScale(4), ScreenScale(1))
    self.LayoutBox.OnSelect = function(self2, i, value, data)
        self.LoadButton:SetEnabled(data ~= "")
    end
    self.LayoutBox:SetZPos(0)

    self.ParameterLabel:SetFont("TacRP_HD44780A00_5x8_6")
    self.ParameterLabel:SetText("Layout Parameters")
    self.ParameterLabel:SizeToContents()
    self.ParameterLabel:SetContentAlignment(5)
    self.ParameterLabel:SetZPos(1)
    self.ParameterLabel:Dock(TOP)
    self.ParameterLabel:SetTooltip("A list of configurable parameters specific to this layout.\nParameters are saved when you saved the layout.")

    self.ParameterForm:SetLayoutDir(TOP)
    self.ParameterForm:SetSpaceY(4)
    self.ParameterForm:Layout()
    self.ParameterForm:DockMargin(ScreenScale(4), ScreenScale(4), ScreenScale(4), ScreenScale(1))
    self.ParameterForm:Dock(TOP)
    self.ParameterForm:SetZPos(2)

    self.LayoutSaveLoad:Dock(TOP)
    self.LayoutSaveLoad:SetTall(ScreenScale(10))
    self.LayoutSaveLoad:SetZPos(3)

    self.SaveButton:SetFont("TacRP_HD44780A00_5x8_4")
    self.SaveButton:SetText("SAVE LAYOUT")
    self.SaveButton:SetWide(self:GetWide() / 2 - ScreenScale(8))
    self.SaveButton:Dock(LEFT)
    self.SaveButton:DockMargin(ScreenScale(4), 0, 0, 0)
    self.SaveButton.DoClick = function(self2)
        local _, data = self.LayoutBox:GetSelected()
        if data == "" then
            Derma_StringRequest("Tactical Takeover", "Input a save file name.", "",
            function(text)
                if text == "" then text = nil end
                net.Start("tah_savemetadata")
                    net.WriteString(text)
                net.SendToServer()
            end)
        else
            net.Start("tah_savemetadata")
                net.WriteString(data)
            net.SendToServer()
        end
    end
    self.SaveButton:SetTooltip("Saves the existing layout to the selected file. The layout must be valid for it to be saved.")

    self.LoadButton:SetFont("TacRP_HD44780A00_5x8_4")
    self.LoadButton:SetText("LOAD LAYOUT")
    self.LoadButton:Dock(RIGHT)
    self.LoadButton:SetWide(self:GetWide() / 2 - ScreenScale(8))
    self.LoadButton:DockMargin(0, 0, ScreenScale(4), 0)
    self.LoadButton:SetEnabled(false) -- TAH:GetRoundState() == TAH.ROUND_INACTIVE
    self.LoadButton:SetTooltip("Loads the selected layout from file. This will cause a map cleanup!")
    self.LoadButton.DoClick = function(self2)
        local _, data = self.LayoutBox:GetSelected()
        if data == "" then
            Derma_Message("Select an existing layout!", "Tactical Takeover")
        else
            Derma_Query("Are you sure you want to load \"" .. data .. "\"?\nThis will clean up the map!", "Tactical Takeover", "Yes", function()
                net.Start("tah_loadmetadata")
                    net.WriteString(data)
                net.SendToServer()
            end, "No")
        end
    end

    self.HintLabel:SetContentAlignment(5)
    self.HintLabel:SetText([[How to play:
1. Spawn and place Hold Points, Shops, and Crate Spawns.
2. Use the Toolgun to make NPC/Player Spawns and link them to holds.
3. Configure parameters and fix any listed problems.
4. Save your loadout so you can load it later.
5. Press "Start Game" and play!

If your layout is invalid, the problems list will explain what's wrong.
Hover your mouse over the message or any button to learn more.]])
    self.HintLabel:SizeToContents()
    self.HintLabel:DockMargin(ScreenScale(1), ScreenScale(4), ScreenScale(1), 0)
    self.HintLabel:Dock(BOTTOM)
    self.HintLabel:SetZPos(1)

    self.StartStopBtn:SetFont("TacRP_HD44780A00_5x8_4")
    self.StartStopBtn:SetTall(ScreenScale(14))
    self.StartStopBtn:DockMargin(ScreenScale(16), ScreenScale(2), ScreenScale(16), 0)
    self.StartStopBtn:Dock(BOTTOM)
    self.StartStopBtn:SetZPos(2)

    self.StartStopBtn.DoClick = function(self2)
        if TAH:GetRoundState() ~= TAH.ROUND_INACTIVE then
            net.Start("tah_finishgame")
            net.SendToServer()
            self:Remove()
        else
            net.Start("tah_startgame")
            net.SendToServer()
            self:Remove()
        end
    end
    self.StartStopBtn:SetEnabled(TAH.ConfigOK)
    self.StartStopBtn:SetTooltip("Start or stop a game. The current layout must be valid for the game to start.")
    self.StartStopBtn:SetZPos(4)

    self.MessagesLabel:SetFont("TacRP_HD44780A00_5x8_6")
    self.MessagesLabel:SetText("Problems")
    self.MessagesLabel:SizeToContents()
    self.MessagesLabel:SetContentAlignment(5)
    self.MessagesLabel:SetZPos(6)
    self.MessagesLabel:Dock(TOP)
    self.MessagesLabel:DockMargin(ScreenScale(1), ScreenScale(4), ScreenScale(1), ScreenScale(1))
    self.MessagesLabel:SetTooltip("A list of issues with the current layout.\nIf there is a red error, the problem is critical and you cannot start the game!")

    self.Messages:SetLayoutDir(TOP)
    self.Messages:SetSpaceY(4)
    self.Messages:Layout()
    self.Messages:DockMargin(ScreenScale(1), ScreenScale(2), ScreenScale(1), ScreenScale(1))
    self.Messages:Dock(FILL)

end

function PANEL:UpdateMessages()
    self.ParameterForm:Clear()
    self.Messages:Clear()
    self.LayoutBox:Clear()
    self.Parameters = {}
    self.StartStopBtn.LastState = nil

    self:InvalidateLayout(true)

    self.SaveButton:SetEnabled(TAH.ConfigOK)
    self.StartStopBtn:SetEnabled(TAH.ConfigOK)
    for i = 1, #TAH.ConfigMessages do
        if bit.band(TAH.ConfigStatus, 2 ^ (i - 1)) ~= 0 then
            local panel = self.Messages:Add("DPanel")
            panel:Dock(TOP)
            panel:SetTall(24)
            panel:SetTooltip(TAH.ConfigMessages[i].tooltip)
            panel:SetZPos(i + (2 - TAH.ConfigMessages[i].severity) * 100)
            local icon = panel:Add("DImage")
            icon:SetMaterial(TAH.ConfigIcons[TAH.ConfigMessages[i].severity])
            icon:SetSize(16, 16)
            icon:SetPos(4, 4)
            local msg = panel:Add("DLabel")
            msg:DockMargin(24, 0, 0, 0)
            msg:Dock(FILL)
            msg:SetTextColor(color_black)
            msg:SetText(TAH.ConfigMessages[i].message)
        end
    end

    for k, v in pairs(TAH.ConfigLayouts) do
        self.LayoutBox:AddChoice(k, v)
    end
    self.LayoutBox:ChooseOptionID(1)

    for k, v in SortedPairsByMemberValue(TAH.ParameterList, "sortorder") do
        self.Parameters[k] = AddControl[v.control](self.ParameterForm, k, v)
        self.Parameters[k]:Dock(TOP)
        self.Parameters[k]:SetTall(24)
        self.Parameters[k]:SetTooltip(v.desc)
    end
end

vgui.Register("TAHGameController", PANEL, "DFrame")