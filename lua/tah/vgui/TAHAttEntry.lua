local PANEL = {}

function PANEL:PerformLayout(w, h)
    self.BaseClass.PerformLayout(self, w, h)
end

function PANEL:Think()
    self.BaseClass.Think(self)
end

function PANEL:Paint(w, h)
    local wep = self:GetWeapon()

    if not IsValid(wep) then return end

    local hover = self:IsHovered()
    self:SetDrawOnTop(hover)

    local col_bg, col_corner, col_text, col_image = self:GetColors()

    surface.SetDrawColor(col_bg)
    surface.DrawRect(0, 0, w, h)
    TacRP.DrawCorneredBox(0, 0, w, h, col_corner)

    self.Title:SetTextColor(col_text)
    self.Icon:SetImageColor(col_image)

    if self:GetIsMenu() then
        draw.SimpleText("X", "TacRP_HD44780A00_5x8_8", w / 2, h / 2, col_bg, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

function PANEL:GetColors()

    local wep = self:GetWeapon()
    local att = self:GetShortName()
    -- local atttbl = TacRP.GetAttTable(att)
    local empty = self:GetInstalled() == nil
    local hover = self:IsHovered()
    local attached = IsValid(wep) and self:GetSlot()
            and wep.Attachments[self:GetSlot()].Installed == att
    self:SetDrawOnTop(hover)
    -- local has = empty and 0 or TacRP:PlayerGetAtts(wep:GetOwner(), att)

    local col_bg = Color(0, 0, 0, 150)
    local col_corner = Color(255, 255, 255)
    local col_text = Color(255, 255, 255)
    local col_image = Color(255, 255, 255)

    if attached and not self:GetIsMenu() then
        col_bg = Color(150, 150, 150, 150)
        col_corner = Color(50, 50, 255)
        col_text = Color(0, 0, 0)
        col_image = Color(200, 200, 200)
        if hover then
            col_bg = Color(255, 255, 255)
            col_corner = Color(150, 150, 255)
            col_text = Color(0, 0, 0)
            col_image = Color(255, 255, 255)
        end
    else
        if not self:GetIsMenu() then
            if hover then
                col_bg = Color(255, 255, 255)
                col_corner = Color(0, 0, 0)
                col_text = Color(0, 0, 0)
                col_image = Color(255, 255, 255)
            end
        else
            if hover then
                col_bg = Color(150, 150, 150)
                col_corner = Color(25, 0, 0)
                col_text = Color(0, 0, 0)
                col_image = Color(255, 255, 255)
            else
                col_bg = Color(25, 20, 20, 150)
                col_corner = Color(255, 0, 0)
                col_text = Color(255, 0, 0)
                col_image = Color(200, 200, 200)
            end
        end
    end

    return col_bg, col_corner, col_text, col_image
end

function PANEL:DoClick()
    local wep = self:GetWeapon()
    if not IsValid(wep) or wep:GetOwner() ~= LocalPlayer() then return end
    -- local att = self:GetShortName()
    -- local slot = self:GetSlot()
    -- local attslot = wep.Attachments[slot]

    -- if self:GetIsMenu() then
    --     if self:GetSlotLayout():GetActiveSlot() == slot then
    --         self:GetSlotLayout():SetSlot(0)
    --     else
    --         self:GetSlotLayout():SetSlot(slot)
    --     end
    -- elseif attslot.Installed then
    --     if attslot.Installed == att then
    --         wep:Detach(slot)
    --     else
    --         wep:Detach(slot, true, true)
    --         wep:Attach(slot, att)
    --     end
    -- else
    --     wep:Attach(slot, att)
    -- end
end
function PANEL:DoRightClick()
    local wep = self:GetWeapon()
    if not IsValid(wep) or wep:GetOwner() ~= LocalPlayer() then return end

    -- local att = self:GetShortName()
    -- local slot = self:GetSlot()
    -- local attslot = wep.Attachments[slot]

    -- if attslot.Installed and attslot.Installed == att then
    --     wep:Detach(slot)
    -- end
end

vgui.Register("TAHAttEntry", PANEL, "TacRPAttSlot")