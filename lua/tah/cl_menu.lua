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
    panel:ControlHelp([[Adjusts game parameters such as:
- Armor durablity
- Starting budget
- Token gain per wave
- Effectiveness of healing items
- Friendly fire damage (if enabled)
- Ammo pickup (if enabled)

Tactical difficulty has additional modifiers:
- Limit 1 weapon per slot
- Respawn with limited health
- Take more damage when using Medi-Shots
- Special enemy units (WIP)]])

    panel:AddControl("checkbox", {
        label = "Enable Player Scaling",
        command = "tah_game_playerscaling"
    })
    panel:ControlHelp([[Adjust some game parameters according to player count, such as:
- Patrol and guard enemy count
- Attack wave interval
- Token gain per wave]])

    panel:AddControl("checkbox", {
        label = "Limited Ammo Mode",
        command = "tah_game_limitedammo"
    })
    panel:ControlHelp("Collect ammo from supply crates and fallen enemies.\nGrenade and launcher ammo are never infinite regardless of this mode.")

    panel:AddControl("checkbox", {
        label = "Limited Mobility Mode",
        command = "tah_game_mobilitynerf"
    })
    panel:ControlHelp("Does nothing (for now)")

    panel:AddControl("checkbox", {
        label = "Enable Sandbox Functions",
        command = "tah_game_sandbox"
    })
    panel:ControlHelp("Controls the use of spawnmenu, noclip and properties menu during a game.\nThe spawnmenu will still be visible, but you won't be able to spawn anything.")

    panel:AddControl("checkbox", {
        label = "Enable Friendly Fire",
        command = "tah_game_friendlyfire"
    })
    panel:ControlHelp("Friendly fire damage depends on difficulty.")

    panel:AddControl("checkbox", {
        label = "Apply Recommended ConVars",
        command = "tah_game_applyconvars"
    })
end

local menus = {
    {
        text = "Tactical Takeover", func = menu_controls
    },
}
hook.Add("PopulateToolMenu", "tah_menu", function()
    for smenu, data in pairs(menus) do
        spawnmenu.AddToolMenuOption("Utilities", "Tactical Takeover", "TAH_" .. tostring(smenu), data.text, "", "", data.func)
    end
end)

list.Set("DesktopWindows", "TAH", {
    title = "TacTakeover",
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