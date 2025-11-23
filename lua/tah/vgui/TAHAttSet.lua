local PANEL = {}

AccessorFunc(PANEL, "Weapon", "Weapon")
AccessorFunc(PANEL, "Attachments", "Attachments")
AccessorFunc(PANEL, "Index", "Index")
AccessorFunc(PANEL, "Frame", "Frame")

local col_bg = Color(0, 0, 0, 150)

function PANEL:Init()
    -- self.Layout = vgui.Create("DIconLayout", self)
    self.BaseClass.Init(self)
    self.AttIcons = {}

    self.ButtonChoose = vgui.Create("DButton", self)
    self.ButtonChoose:SetText("")
    function self.ButtonChoose.Paint(self2, w, h)
        local c_bg, c_cnr, c_txt = TacRP.GetPanelColors(self2:IsHovered(), self2:IsDown())
        surface.SetDrawColor(c_bg)
        TacRP.DrawCorneredBox(0, 0, w, h, c_cnr)
        draw.SimpleText("Equip", "TacRP_Myriad_Pro_8", w / 2, h / 2, c_txt, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    function self.ButtonChoose.DoClick(self2)
        net.Start("tah_attbox")
            net.WriteEntity(self:GetWeapon())
            net.WriteUInt(self:GetIndex(), 4)
        net.SendToServer()

        local t = 0
        if IsValid(self:GetWeapon()) and LocalPlayer().TAH_PendingAttBox then
            for slot, att in pairs(LocalPlayer().TAH_PendingAttBox[self:GetIndex()] or {}) do
                local snd = self:GetWeapon().Attachments[slot].AttachSound
                if snd then
                    timer.Simple(t, function()
                        surface.PlaySound(snd)
                    end)
                    t = t + 0.15
                end
            end
        end


        if self:GetFrame() then
            self:GetFrame():Close()
        end
    end

    self:DockPadding(0, TacRP.SS(4), 0, TacRP.SS(4))
end

function PANEL:PerformLayout(w, h)
    self.BaseClass.PerformLayout(self, w, h)

    -- self.Layout:Dock(FILL)
    -- self.Layout:SetContentAlignment(5)
    -- self.Layout:SetSpaceX(TacRP.SS(8))
    -- self.Layout:SetLayoutDir(LEFT)
    self.ButtonChoose:SetSize(TacRP.SS(32), TacRP.SS(10))
    self.ButtonChoose:Dock(BOTTOM)
    self.ButtonChoose:DockMargin(TacRP.SS(8), TacRP.SS(4), TacRP.SS(8), 0)
    self.ButtonChoose:SetPos(w / 2 - self.ButtonChoose:GetWide() / 2, h + self.ButtonChoose:GetTall() - TacRP.SS(4))
end

function PANEL:LoadAttachments(wep, atts)
    if wep ~= nil then
        self:SetWeapon(wep)
    end
    if atts ~= nil then
        self:SetAttachments(atts)
    end
    --self:Clear()
    for _, pnl in pairs(self.AttIcons) do pnl:Remove() end
    self.AttIcons = {}

    wep = self:GetWeapon()
    if not IsValid(wep) or not wep.Attachments or wep:GetOwner() ~= LocalPlayer() then return end

    local s = TacRP.SS(32)

    for i, att in SortedPairs(self:GetAttachments() or {}) do
        if not wep.Attachments[i] then continue end
        local atttbl = TacRP.GetAttTable(att)
        if not atttbl then continue end

        local panel = self:Add("DPanel")
        panel:SetWide(s)
        panel.Paint = function() end
        panel:Dock(LEFT)
        panel:DockMargin(TacRP.SS(4), 0, TacRP.SS(4), 0)
        table.insert(self.AttIcons, panel)
        -- panel:Dock(LEFT)

        local att_new = panel:Add("TAHAttEntry")
        att_new:SetShortName(att)
        att_new:SetSlot(i)
        att_new:SetWeapon(self:GetWeapon())
        att_new:SetSize(s, s)
        att_new:Dock(TOP)

        local slot_name = vgui.Create("DPanel", panel)
        slot_name:SetSize(TacRP.SS(32), TacRP.SS(8))
        slot_name.Paint = function(self2, w, h)
            if not IsValid(self) then return end

            surface.SetDrawColor(col_bg)
            surface.DrawRect(0, 0, w, h)
            TacRP.DrawCorneredBox(0, 0, w, h, color_white)

            local txt = TacRP:TryTranslate(wep.Attachments[i].PrintName or "Slot")
            if txt then
                draw.SimpleText(txt, "TacRP_Myriad_Pro_8", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end
        slot_name:SetZPos(-1)
        slot_name:Dock(TOP)

        local arrow = vgui.Create("DPanel", panel)
        arrow:SetSize(TacRP.SS(32), TacRP.SS(6))

        if wep.Attachments[i].Installed ~= nil then
            att_new:DockMargin(0, TacRP.SS(4), 0, 0)
            att_new:Dock(TOP)

            local att_old = panel:Add("TAHAttEntry")
            att_old:SetSlot(i)
            att_old:SetWeapon(self:GetWeapon())
            att_old:SetIsMenu(true)
            att_old:SetSize(s, s)
            att_old:Dock(BOTTOM)
            att_old:DockMargin(0, 0, 0, 0)

            arrow.Paint = function(self2, w, h)
                if not IsValid(self) then return end
                draw.SimpleText("v", "TacRP_HD44780A00_5x8_5", w / 2, h / 2 + math.sin(CurTime() * 4) * h / 8, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            arrow:Dock(FILL)
        else
            slot_name:DockMargin(0, TacRP.SS(20), 0, 0)
            att_new:DockMargin(0, TacRP.SS(4), 0, 0)
            att_new:Dock(TOP)

            arrow.Paint = function(self2, w, h)
                if not IsValid(self) then return end
                draw.SimpleText("NEW!", "TacRP_HD44780A00_5x8_4", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            arrow:Dock(TOP)
        end
    end

    self:SetSize(#self.AttIcons * TacRP.SS(40), TacRP.SS(96 + 10))

    self:InvalidateLayout(true)
end

function PANEL:Paint(w, h)
    surface.SetDrawColor(col_bg)
    surface.DrawRect(2, 2, w - 2, h - 2)
    TacRP.DrawCorneredBox(2, 2, w - 2, h - 2, color_white)
end

vgui.Register("TAHAttSet", PANEL, "DPanel")