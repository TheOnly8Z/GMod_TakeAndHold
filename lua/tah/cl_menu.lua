local function header(panel, text)
    local ctrl = panel:Help(text)
    ctrl:SetFont("DermaDefaultBold")
    return ctrl
end

local function combobox(panel, text, convar, options)
    local cb, lb = panel:ComboBox(text, convar)
    for k, v in pairs(options) do
        cb:AddChoice(k, v)
    end
    cb:DockMargin(8, 0, 0, 0)
    lb:SizeToContents()
    return cb
end

local function funcbutton(panel, label, func)
    local ctrl = vgui.Create("DButton", panel)
    ctrl.DoClick = func
    ctrl:SetText(label)
    panel:AddPanel(ctrl)
    return ctrl
end


local function menu_controls(panel)
    header(panel, "Game Controls")
    funcbutton(panel, "Start Game", function()
            net.Start("tah_startgame")
            net.SendToServer()
        end
    )
    funcbutton(panel, "Finish Game", function()
            net.Start("tah_finishgame")
            net.SendToServer()
        end
    )


    header(panel, "\nSetup")
    local files = file.Find("tah/" .. game.GetMap() .. "/*.json", "DATA")
    local options = {["New..."] = ""}
    for _, str in pairs(files) do
        options[string.sub(str, 0, -6)] = string.sub(str, 0, -6)
    end
    local selected_layout = combobox(panel, "Layout", nil, options)
    funcbutton(panel, "Load Layout", function()
            local option = selected_layout:GetSelected()
            if not option or option == "New..." then
                Derma_Message("Select an existing layout!", "Take and Hold")
            else
                net.Start("tah_loadmetadata")
                    net.WriteString(option)
                net.SendToServer()
            end
        end
    )
    funcbutton(panel, "Save Layout", function()
            local option = selected_layout:GetSelected()
            if not option or option == "New..." then
                Derma_StringRequest("Take and Hold", "Input a save file name. If not provided, will default to date and time.", "",
                function(text)
                    if text == "" then text = nil end
                    net.Start("tah_savemetadata")
                        net.WriteString(text)
                    net.SendToServer()
                end)
            else
                net.Start("tah_savemetadata")
                    net.WriteString(option)
                net.SendToServer()
            end
        end
    )


end

local menus = {
    {
        text = "Main Controls", func = menu_controls
    },
}
hook.Add("PopulateToolMenu", "tah_menu", function()
    for smenu, data in pairs(menus) do
        spawnmenu.AddToolMenuOption("Utilities", "Take And Hold", "TAH_" .. tostring(smenu), data.text, "", "", data.func)
    end
end)

concommand.Add("tah_menu", function()
    local panel = vgui.Create("TAHGameController")
    panel:Center()
    panel:MakePopup()
end)