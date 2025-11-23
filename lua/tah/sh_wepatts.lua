function TAH:CacheAttachmentSlots()
    self.AttachmentPerSlotCache = {}

    for i, k in pairs(TacRP.Attachments) do
        local attcats = k.Category

        if not istable(attcats) then
            attcats = {attcats}
        end

        for _, cat in pairs(attcats) do
            self.AttachmentPerSlotCache[cat] = self.AttachmentPerSlotCache[cat] or {}
            table.insert(self.AttachmentPerSlotCache[cat], k.ShortName)
        end
    end
end
hook.Add("TacRP_LoadAtts", "tah_wepatts", function()
    TAH:CacheAttachmentSlots()
end)

hook.Add("TacRP_CanCustomize", "tah_wepatts", function(ply, wep, att, slot, detach)
    if TAH:IsGameActive() and TAH.ConVars["game_limitedcust"]:GetBool() then
        return false, "Limited Attachment Mode"
    end
end)

function TAH:RollAttachments(ply, wep, amount, require_unowned)

    if self.AttachmentPerSlotCache == nil then
        self:CacheAttachmentSlots()
    end

    amount = amount or 1

    local result_atts = {}

    if TacRP.ConVars["free_atts"]:GetBool() then return result_atts end
    if not IsValid(wep) or not wep.ArcticTacRP or not wep.Attachments then return result_atts end

    local slot_index = {}
    for i, slot in pairs(wep.Attachments) do
        local cats = slot.Category
        if not istable(cats) then
            cats = {cats}
        end

        local has = false
        for _, cat in ipairs(cats) do
            for _, attName in ipairs(self.AttachmentPerSlotCache[cat]) do
                local attTbl = TacRP.GetAttTable(attName)
                if not attTbl then continue end

                if slot.Installed == attName then continue end

                if isfunction(attTbl.Compatibility) and attTbl.Compatibility(wep) == false then
                    continue
                end

                if require_unowned and TacRP:PlayerGetAtts(ply, attName) > 0 then
                    continue
                end

                has = true
                break
            end
            if has then break end
        end

        if has then
            table.insert(slot_index, i)
        end
    end
    local slot_left = table.Copy(slot_index)
    local slot_chosen = {}
    local one_per_slot = true
    for i = 1, amount do
        local ind = table.remove(slot_left, math.random(1, #slot_left))
        slot_chosen[ind] = (slot_chosen[ind] or 0) + 1
        if slot_chosen[ind] > 1 then
            one_per_slot = false
        end
        if #slot_left == 0 then
            slot_left = table.Copy(slot_index)
        end
    end

    for slotIndex, amt in pairs(slot_chosen) do
        local candidates = {}
        local cats = wep.Attachments[slotIndex].Category

        if not istable(cats) then
            cats = {cats}
        end

        for _, cat in ipairs(cats) do
            for _, attName in ipairs(self.AttachmentPerSlotCache[cat] or {}) do
                local attTbl = TacRP.GetAttTable(attName)
                if not attTbl then continue end

                if wep.Attachments[slotIndex].Installed == attName then continue end

                if isfunction(attTbl.Compatibility) and attTbl.Compatibility(wep) == false then
                    continue
                end

                if require_unowned and TacRP:PlayerGetAtts(ply, attName) > 0 then
                    continue
                end

                table.insert(candidates, attName)
            end
        end

        if #candidates > 0 then
            if one_per_slot then
                result_atts[slotIndex] = candidates[math.random(1, #candidates)]
            else
                for i = 1, amt do
                    table.insert(result_atts, table.remove(candidates, math.random(1, #candidates)))
                    if #candidates == 0 then
                        break
                    end
                end
            end
        end
    end

    return result_atts
end

if SERVER then
    util.AddNetworkString("tah_attbox")

    net.Receive("tah_attbox", function(len, ply)
        local wep = net.ReadEntity()
        if not ply:Alive() or not IsValid(wep) or not wep:IsWeapon() or wep:GetOwner() ~= ply or not wep.ArcticTacRP or not wep.Attachments then return end

        local choice = net.ReadUInt(4)
        if choice == 0 then
            if ply.TAH_PendingAttBox ~= nil then
                -- TODO maybe do something about this
            end
            -- TODO validate player has thing to deduct
            -- TODO only possible when active game

            ply.TAH_PendingAttBox = {}
            ply.TAH_PendingAttWeapon = wep
            for i = 1, 3 do
                table.insert(ply.TAH_PendingAttBox, TAH:RollAttachments(ply, wep, i, false))
            end

            net.Start("tah_attbox")
                net.WriteEntity(wep)
                for _, v in ipairs(ply.TAH_PendingAttBox) do
                    net.WriteUInt(table.Count(v), 3)
                    for i, att in pairs(v) do
                        net.WriteUInt(i, 4)
                        net.WriteUInt(TacRP.Attachments[att].ID, TacRP.Attachments_Bits)
                    end
                end
                net.WriteUInt(0, 3)
            net.Send(ply)
        else
            if ply.TAH_PendingAttWeapon ~= wep or not ply.TAH_PendingAttBox or not ply.TAH_PendingAttBox[choice] then return end

            for slot, att in pairs(ply.TAH_PendingAttBox[choice]) do
                wep.Attachments[slot].Installed = att
            end
            wep:NetworkWeapon()

            net.Start("tah_attbox")
                net.WriteEntity(NULL)
            net.Send(ply)

            ply.TAH_PendingAttBox = nil
            ply.TAH_PendingAttWeapon = nil
        end


    end)
end
if CLIENT then

    concommand.Add("tah_use_attbox", function()
        local wep = LocalPlayer():GetActiveWeapon()
        if not LocalPlayer():Alive() or not IsValid(wep) or not wep:IsWeapon() or wep:GetOwner() ~= LocalPlayer() or not wep.ArcticTacRP or not wep.Attachments then return end
        net.Start("tah_attbox")
            net.WriteEntity(wep)
            net.WriteUInt(0, 4)
        net.SendToServer()
    end)

    net.Receive("tah_attbox", function()
        LocalPlayer().TAH_PendingAttBox = {}
        LocalPlayer().TAH_PendingAttWeapon = net.ReadEntity()
        if not IsValid(LocalPlayer().TAH_PendingAttWeapon) then
            LocalPlayer().TAH_PendingAttBox = nil
            LocalPlayer().TAH_PendingAttWeapon = nil
            return
        end
        local n = net.ReadUInt(3)
        while n > 0 do
            local attset = {}
            for i = 1, n do
                local slot = net.ReadUInt(4)
                local att_index = net.ReadUInt(TacRP.Attachments_Bits)
                attset[slot] = TacRP.Attachments_Index[att_index]
            end
            table.insert(LocalPlayer().TAH_PendingAttBox, attset)
            n = net.ReadUInt(3)
        end

        PrintTable(LocalPlayer().TAH_PendingAttBox)

        RunConsoleCommand("tah_attbox")
    end)

    local attbox = Material("tacup/attbox.png", "smooth")
    hook.Add("TacRP_CreateCustomizeHUD", "tah_wepatts", function(wep, hud)
        if wep.Attachments then -- TAH:IsGameActive() and
            local phrase = "Use Att. Kit (1/3)"
            local dropbox = vgui.Create("DButton", hud)
            local bw, bh = TacRP.SS(40), TacRP.SS(40)
            --local airgap = TacRP.SS(8)
            local smallgap = TacRP.SS(4)
            dropbox:SetSize(bw, bh)
            if TacRP.ConVars["cust_legacy"]:GetBool() then
                dropbox:SetPos(ScrW() / 2 - bw / 2, ScrH() - bh * 2 - smallgap)
            else
                dropbox:SetPos(hud.SlotLayout:GetX() + hud.SlotLayout:GetWide() / 2 - bw / 2, hud.SlotLayout:GetY() + hud.SlotLayout:GetTall())
            end
            dropbox:SetText("")
            function dropbox.Paint(self2, w, h)
                local c_bg, c_cnr, c_txt = TacRP.GetPanelColors(self2:IsHovered(), self2:IsDown())
                surface.SetDrawColor(c_bg)
                -- surface.DrawRect(0, 0, w, h)
                TacRP.DrawCorneredBox(0, 0, w, h, c_cnr)
                surface.SetDrawColor(color_white)
                surface.SetMaterial(attbox)
                surface.DrawTexturedRect(smallgap / 2, 0, bw - smallgap, bh - smallgap)
                draw.SimpleText(TacRP:GetPhrase(phrase) or phrase, "TacRP_Myriad_Pro_6", w / 2, h, c_txt, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
            end
            function dropbox.DoClick(self2)
                if LocalPlayer().TAH_PendingAttWeapon == wep then
                    LocalPlayer():ConCommand("tah_attbox")
                else
                    LocalPlayer():ConCommand("tah_use_attbox")
                end
            end

            if LocalPlayer().TAH_PendingAttWeapon == wep then
                phrase = "Check Att. Kit (1/3)"
            elseif IsValid(LocalPlayer().TAH_PendingAttWeapon) then
                dropbox:SetEnabled(false)
            end
        end
    end)
end