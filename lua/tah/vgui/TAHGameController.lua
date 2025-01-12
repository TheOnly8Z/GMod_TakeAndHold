local PANEL = {}

DEFINE_BASECLASS("DFrame")

local color_spent = Color(150, 150, 150)

function PANEL:Init()
    if not LocalPlayer():IsAdmin() then
        Derma_Message("Only admins can use this menu!", "Take and Hold", "OK")
        self:Remove()
        return
    end

    if TAH.GameControllerPanel ~= nil then
        TAH.GameControllerPanel:Remove()
    end

    TAH.GameControllerPanel = self

    self:SetSize(TacRP.SS(128), TacRP.SS(160))
    self:SetTitle("Take And Hold")
    self:ShowCloseButton(true)
    self:SetBackgroundBlur(false)

    self.StatePanel = self:Add("DPanel")
    self.Messages = self:Add("DIconLayout")
    self.LayoutBox = self:Add("DComboBox")

    local font = "TacRP_HD44780A00_5x8_6"
    self.StatePanel:Dock(TOP)
    self.StatePanel:SetTall(TacRP.SS(12))
    self.StatePanel.Paint = function(self2, w, h)
        draw.SimpleText(TAH:IsGameActive() and "Active Game" or "Inactive", font, w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    self.LayoutBox:Dock(TOP)
    self.LayoutBox:SetTall(TacRP.SS(8))
    self.LayoutBox:DockMargin(TacRP.SS(1), TacRP.SS(4), TacRP.SS(1), TacRP.SS(2))
    self.LayoutBox.OnSelect = function(self2, i, value, data)
        self.LoadButton:SetEnabled(data ~= "")
    end

    local layoutsaveload = self:Add("DPanel")
    layoutsaveload:Dock(TOP)
    layoutsaveload:SetTall(TacRP.SS(12))
    layoutsaveload.Paint = function() end

    self.SaveButton = layoutsaveload:Add("DButton")
    self.SaveButton:SetFont("TacRP_HD44780A00_5x8_4")
    self.SaveButton:SetText("SAVE LAYOUT")
    self.SaveButton:SetWide(self:GetWide() / 2 - TacRP.SS(8))
    self.SaveButton:Dock(LEFT)
    self.SaveButton:DockMargin(TacRP.SS(4), 0, 0, 0)
    self.SaveButton.DoClick = function(self2)
        local _, data = self.LayoutBox:GetSelected()
        if data == "" then
            Derma_StringRequest("Take and Hold", "Input a save file name.", "",
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

    self.LoadButton = layoutsaveload:Add("DButton")
    self.LoadButton:SetFont("TacRP_HD44780A00_5x8_4")
    self.LoadButton:SetText("LOAD LAYOUT")
    self.LoadButton:Dock(RIGHT)
    self.LoadButton:SetWide(self:GetWide() / 2 - TacRP.SS(8))
    self.LoadButton:DockMargin(0, 0, TacRP.SS(4), 0)
    self.LoadButton:SetEnabled(false) -- TAH:GetRoundState() == TAH.ROUND_INACTIVE
    self.LoadButton:SetTooltip("Loads the selected layout from file. This will cause a map cleanup!")
    self.LoadButton.DoClick = function(self2)
        local _, data = self.LayoutBox:GetSelected()
        if data == "" then
            Derma_Message("Select an existing layout!", "Take and Hold")
        else
            Derma_Query("Are you sure you want to load \"" .. data .. "\"?\nThis will clean up the map!", "Take and Hold", "Yes", function()
                net.Start("tah_loadmetadata")
                    net.WriteString(data)
                net.SendToServer()
            end, "No")
        end
    end
    self.Messages:SetLayoutDir(TOP)
    self.Messages:SetSpaceY(4)
    self.Messages:Layout()
    self.Messages:DockMargin(TacRP.SS(1), TacRP.SS(2), TacRP.SS(1), TacRP.SS(1))
    self.Messages:Dock(FILL)

    local placeholder = self.Messages:Add("DLabel")
    placeholder:Dock(FILL)
    placeholder:SetContentAlignment(5)
    placeholder:SetFont("TacRP_HD44780A00_5x8_4")
    placeholder:SetText("... VALIDATING LAYOUT ...")


    local hint = self:Add("DLabel")
    hint:SetContentAlignment(5)
    hint:SetText([[How to play:
1. Spawn and place Hold Points and Shops.
2. Use the Toolgun to link spawn points to holds.
3. Save your loadout so you can load it later.
4. Press "Start Game" and play!

If your layout is invalid, there will be error and warning messages.
Hover your mouse over the message or any button to learn more.]])
    hint:SizeToContents()
    hint:DockMargin(TacRP.SS(1), TacRP.SS(4), TacRP.SS(1), 0)
    hint:Dock(BOTTOM)

    self.StartStopBtn = self:Add("DButton")
    self.StartStopBtn:SetFont("TacRP_HD44780A00_5x8_4")
    self.StartStopBtn:SetTall(TacRP.SS(14))
    self.StartStopBtn:DockMargin(TacRP.SS(16), TacRP.SS(2), TacRP.SS(16), 0)
    self.StartStopBtn:Dock(BOTTOM)
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
    local oldpaint = self.StartStopBtn.Paint
    self.StartStopBtn.Paint = function(self2, w, h)
        oldpaint(self2, w, h)
        if (TAH:GetRoundState() == TAH.ROUND_INACTIVE) ~= self2.LastState then
            self2.LastState = TAH:GetRoundState() == TAH.ROUND_INACTIVE
            self2:SetText(self2.LastState and "START GAME" or "STOP GAME")
        end
    end
    self.StartStopBtn:SetEnabled(TAH.ConfigOK)
    self.StartStopBtn:SetTooltip("Start or stop a game. The current layout must be valid for the game to start.")

    net.Start("tah_checkconfig")
    net.SendToServer()
end

function PANEL:UpdateMessages()
    self.Messages:Clear()
    self.LayoutBox:Clear()
    self.StartStopBtn.LastState = nil

    self.SaveButton:SetEnabled(TAH.ConfigOK)
    self.StartStopBtn:SetEnabled(TAH.ConfigOK)

    for i = 1, #TAH.ConfigMessages do
        if bit.band(TAH.ConfigStatus, 2 ^ (i - 1)) ~= 0 then
            local panel = self.Messages:Add("DPanel")
            panel:Dock(TOP)
            panel:SetTall(24)
            panel:SetTooltip(TAH.ConfigMessages[i].tooltip)
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
end

vgui.Register("TAHGameController", PANEL, "DFrame")