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
    funcbutton(panel, "Control Menu", function()
        RunConsoleCommand("tah_menu")
    end)

    combobox(panel, "Difficulty", "tah_game_difficulty", {
        ["Casual"] = 0,
        ["Standard"] = 1,
        ["Tactical"] = 2,
    })
    panel:ControlHelp([[Adjusts game parameters for difficulty, such as:
- Incoming damage
- Armor durablity loss
- Starting budget
- Token gain per wave
- Effectiveness of healing items
- Friendly fire damage (if enabled)

It is highly recommended to play on Standard.]])

    panel:AddControl("checkbox", {
        label = "Enable Player Scaling",
        command = "tah_game_playerscaling"
    })
    panel:ControlHelp([[Adjust some game parameters according to player count, such as:
- Patrol and guard enemy count
- Attack wave interval
- Token gain per wave]])

    panel:AddControl("checkbox", {
        label = "Enable Sandbox Functions",
        command = "tah_game_sandbox"
    })
    panel:ControlHelp("Controls the use of spawnmenu, noclip and properties menu during a game.\nThe spawnmenu will still be visible, but you won't be able to spawn anything.")

    panel:AddControl("checkbox", {
        label = "Enable Friendly Fire",
        command = "tah_game_friendlyfire"
    })
    panel:ControlHelp("Also affects flashbangs and CS Gas grenades, which won't affect players with this off.")

    panel:AddControl("checkbox", {
        label = "Limited Mobility Mode",
        command = "tah_game_mobilitynerf"
    })

    panel:AddControl("checkbox", {
        label = "Apply Recommended ConVars",
        command = "tah_game_applyconvars"
    })

    -- panel:AddControl("checkbox", {
    --     label = "Limited Ammo Mode",
    --     command = "tah_game_limitedammo"
    -- })
    -- panel:ControlHelp("WORK IN PROGRESS DO NOT ENABLE!")

    --[[]
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
    ]]
end

local menus = {
    {
        text = "Take and Hold", func = menu_controls
    },
}
hook.Add("PopulateToolMenu", "tah_menu", function()
    for smenu, data in pairs(menus) do
        spawnmenu.AddToolMenuOption("Utilities", "Take And Hold", "TAH_" .. tostring(smenu), data.text, "", "", data.func)
    end
end)

list.Set("DesktopWindows", "TAH", {
    title = "Take and Hold",
    icon = "icon64/playermodel.png",
    width = 960,
    height = 700,
    init = function(icon, window)
        window:Remove()
        local panel = vgui.Create("TAHGameController")
        panel:Center()
        panel:MakePopup()
    end
})

concommand.Add("tah_menu", function()
    local panel = vgui.Create("TAHGameController")
    panel:Center()
    panel:MakePopup()
end)