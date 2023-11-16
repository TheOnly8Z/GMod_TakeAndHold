surface.CreateFont("TAH_96", {
    font = "Arial",
    size = 96,
    weight = 600,
})

hook.Add("PostDrawTranslucentRenderables", "TAH_Render", function()

    local hold = TAH:GetHoldEntity()
    if IsValid(hold) then
        if hold:GetUseAABB() then
            local mins, maxs = hold:GetMinS(), hold:GetMaxS()
            local mid = Vector((mins.x + maxs.x) / 2, (mins.y + maxs.y) / 2, mins.z)
            local w, h = maxs.x - mins.x, maxs.y - mins.y

            for i = 0, 3 do
                cam.Start3D2D(mid + Vector(0, 0, i * 8), Angle(0, 0, 0), 0.01)
                    surface.SetDrawColor(255, 255, 255, 80 - i * 20)
                    surface.DrawOutlinedRect(-w * 0.5 * 100, -h * 0.5 * 100, w * 100, h * 100, 32)
                cam.End3D2D()
            end

            for i = 0, 3 do
                cam.Start3D2D(mid + Vector(0, 0, maxs.z - mins.z - i * 8), Angle(0, 0, 0), 0.01)
                    surface.SetDrawColor(255, 255, 255, 80 - i * 20)
                    surface.DrawOutlinedRect(-w * 0.5 * 100, -h * 0.5 * 100, w * 100, h * 100, 32)
                cam.End3D2D()
            end
        else
            for i = 1, 5 do
                cam.Start3D2D(hold:GetPos() + Vector(0, 0, (i - 1) * 8), Angle(0, 0, 0), 0.01)
                    surface.DrawCircle(0, 0, hold:GetRadius() * 100, 255, 255, 255, 100 - i * 15)
                    if i == 1 then
                        surface.DrawCircle(0, 0, hold:GetRadius() * 100 * (CurTime() % 2) / 2, 255, 255, 255, 200 * (1 - (CurTime() % 2) / 2))
                    end
                cam.End3D2D()
            end
            for i = 1, 3 do
                cam.Start3D2D(hold:GetPos() + Vector(0, 0, hold:GetHeight() - (i - 1) * 10), Angle(0, 0, 0), 0.01)
                    surface.DrawCircle(0, 0, hold:GetRadius() * 100, 255, 255, 255, 100 - i * 30)
                cam.End3D2D()
            end
        end
    end

    if TAH:GetRoundState() == TAH.ROUND_INACTIVE then
        for _, ent in pairs(ents.FindByClass("tah_holdpoint")) do

            if ent:GetUseAABB() then
                render.DrawWireframeBox(Vector(), Angle(), ent:GetMinS(), ent:GetMaxS(), color_white, true)
            else
                local f = (CurTime() % 3) / 3
                -- render.DrawLine(ent:GetPos(), ent:GetPos() + Vector(0, 0, ent:GetHeight()), color_white, true)
                -- grounded circle
                cam.Start3D2D(ent:GetPos(), Angle(0, 0, 0), 0.01)
                    surface.DrawCircle(0, 0, ent:GetRadius() * 100, 255, 255, 255, 255)
                    surface.DrawCircle(0, 0, ent:GetRadius() * 100 * f, 255, 255, 255, 200 * (1 - f))
                cam.End3D2D()
                -- top circle
                cam.Start3D2D(ent:GetPos() + Vector(0, 0, ent:GetHeight() * f), Angle(0, 0, 0), 0.01)
                    surface.DrawCircle(0, 0, ent:GetRadius() * 100, 255, 255, 255, 200 * (1 - f))
                cam.End3D2D()
                -- vertical pulse
                cam.Start3D2D(ent:GetPos() + Vector(0, 0, ent:GetHeight()), Angle(0, 0, 0), 0.01)
                    surface.DrawCircle(0, 0, ent:GetRadius() * 100, 255, 255, 255, 255)
                cam.End3D2D()
            end
        end
    end
end)