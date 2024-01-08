local clr_friendly = Color(75, 75, 255)
local clr_friendly2 = Color(75, 75, 170)
local clr_enemy = Color(255, 75, 75)
local clr_enemy2 = Color(170, 75, 75)
local clr_outline = Color(0, 0, 0, 150)
local clr_text = Color(255, 255, 255, 255)

local ring_outline = Material("tacup/ring_outline.png", "smooth mips")
local ring_outer = Material("tacup/ring_outer.png", "smooth mips")
local ring_inner = Material("tacup/ring_inner.png", "smooth mips")

local function circle(x, y, radius, seg, angle)
    local cir = {}

    if angle == nil then
        angle = 360
    end

    table.insert(cir, {
        x = x,
        y = y,
        u = 0.5,
        v = 0.5
    })

    for i = 0, seg do
        local a = math.rad((i / seg) * -360)

        if math.deg(a) * -1 <= angle then
            table.insert(cir, {
                x = x + math.sin(a) * radius,
                y = y + math.cos(a) * radius,
                u = math.sin(a) / 2 + 0.5,
                v = math.cos(a) / 2 + 0.5
            })
        end
    end

    if angle ~= 360 then
        table.insert(cir, {
            x = x,
            y = y,
            u = 0.5,
            v = 0.5
        })
    end

    local a = math.rad(0) -- This is need for non absolute segment counts

    table.insert(cir, {
        x = x + math.sin(a) * radius,
        y = y + math.cos(a) * radius,
        u = math.sin(a) / 2 + 0.5,
        v = math.cos(a) / 2 + 0.5
    })

    surface.DrawPoly(cir)
end

function TAH:DrawPointIndicator(x, y, s, a, font)
    local hold = TAH:GetHoldEntity()
    if not IsValid(hold) then return end

    s = s or ScreenScale(16)
    font = font or "TacRP_HD44780A00_5x8_5"

    local letter = string.Left(TAH.PointNames[(TAH:GetCurrentRound() - 1) % 26 + 1], 1)

    local c = hold:GetOwnedByPlayers() and clr_friendly or clr_enemy
    local c2 = hold:GetOwnedByPlayers() and clr_enemy2 or clr_friendly2
    local c3 = hold:GetOwnedByPlayers() and clr_friendly2 or clr_enemy2

    local f = hold:GetCaptureProgress()

    surface.SetDrawColor(0, 0, 0, a)
    surface.SetMaterial(ring_outline)
    surface.DrawTexturedRect(x - s / 2, y - s / 2, s, s)

    render.ClearStencil()
    render.SetStencilEnable(true)
    render.SetStencilWriteMask(1)
    render.SetStencilTestMask(1)
    render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NEVER)
    render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
    render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
    render.SetStencilPassOperation(STENCILOPERATION_KEEP)
    render.SetStencilReferenceValue(1)

    surface.SetDrawColor(1, 1, 1)
    circle(x, y, s + 100, 300, f * 360)

    render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
    render.SetStencilReferenceValue(1)
    render.SetStencilFailOperation(STENCILOPERATION_ZERO)
    render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
    render.SetStencilPassOperation(STENCILOPERATION_KEEP)

    surface.SetDrawColor(c2.r, c2.g, c2.b, a)
    surface.SetMaterial(ring_outer)
    surface.DrawTexturedRect(x - s / 2, y - s / 2, s, s)

    render.ClearStencil()
    render.SetStencilWriteMask(1)
    render.SetStencilTestMask(1)
    render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NEVER)
    render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
    render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
    render.SetStencilPassOperation(STENCILOPERATION_KEEP)
    render.SetStencilReferenceValue(1)

    surface.SetDrawColor(1, 1, 1)
    circle(x, y, s + 100, 300, f * 360)

    render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
    render.SetStencilReferenceValue(2)
    render.SetStencilFailOperation(STENCILOPERATION_KEEP)
    render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
    render.SetStencilPassOperation(STENCILOPERATION_ZERO)

    surface.SetDrawColor(c3.r, c3.g, c3.b, a)
    surface.SetMaterial(ring_outer)
    surface.DrawTexturedRect(x - s / 2, y - s / 2, s, s)

    render.SetStencilEnable(false)

    surface.SetDrawColor(c.r, c.g, c.b, a)
    surface.SetMaterial(ring_inner)
    surface.DrawTexturedRect(x - s / 2, y - s / 2, s, s)

    clr_text.a = 255
    clr_outline.a = a / 255 * 150
    draw.SimpleTextOutlined(letter, font, x, y - 1, clr_text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, clr_outline)
end

hook.Add("HUDPaint", "TAH_HUD", function()
    if TAH:GetRoundState() ~= TAH.ROUND_INACTIVE then
        local hold = TAH:GetHoldEntity()
        if not IsValid(hold) then return end

        local name = TAH.PointNames[(TAH:GetCurrentRound() - 1) % 26 + 1]

        local x, y = ScrW() / 2, ScreenScale(12)
        local s = ScreenScale(16)
        local font = "TacRP_HD44780A00_5x8_5"
        local a = 220
        if hold:VectorWithinArea(EyePos()) then
            draw.SimpleTextOutlined(name, "TacRP_Myriad_Pro_12", x, y, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, clr_outline)
            draw.RoundedBox(4, x - ScreenScale(64), y + ScreenScale(7), ScreenScale(128), ScreenScale(1), color_white)
            y = y + ScreenScale(16)
            local message = hold.CaptureStateName[hold:GetCaptureState()]
            if message then
                surface.SetFont("TacRP_Myriad_Pro_10")
                local tw, _ = surface.GetTextSize(message)
                x = x - tw / 2
                s = ScreenScale(12)
                font = "TacRP_HD44780A00_5x8_4"
                draw.SimpleTextOutlined(message, "TacRP_Myriad_Pro_10", x + s / 2 + ScreenScale(4), y, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2, clr_outline)
                --
            end
        else
            -- cam.Start3D()
            -- local hold2dpos = (hold:WorldSpaceCenter() + Vector(0, 0, 96)):ToScreen()
            -- cam.End3D()
            -- x = hold2dpos.x
            -- y = hold2dpos.y
            -- a = 150
            -- s = ScreenScale(12)
            -- font = "TacRP_HD44780A00_5x8_4"
        end

        TAH:DrawPointIndicator(x, y, s, a, font)
    end
end)