surface.CreateFont("TAH_96", {
    font = "Arial",
    size = 96,
    weight = 600,
})

hook.Add("PostDrawTranslucentRenderables", "TAH_Render", function()

    local hold = TAH:GetHoldEntity()
    if IsValid(hold) then
        for i = 1, 5 do
            cam.Start3D2D(hold:GetPos() + Vector(0, 0, (i - 1) * 8), Angle(0, 0, 0), 0.01)
                surface.DrawCircle(0, 0, hold:GetRadius() * 100, 255, 255, 255, 255 - i * 50)
                if i == 1 then
                    surface.DrawCircle(0, 0, hold:GetRadius() * 100 * (CurTime() % 2) / 2, 255, 255, 255, 200 * (1 - (CurTime() % 2) / 2))
                end
            cam.End3D2D()
        end
    end

    if TAH:GetRoundState() == TAH.ROUND_INACTIVE then
        for _, ent in pairs(ents.FindByClass("tah_holdpoint")) do
            if ent:GetUseAABB() then
                render.DrawWireframeBox(Vector(), Angle(), ent:GetMinS(), ent:GetMaxS(), color_white, true)
            else
                local f = (CurTime() % 3) / 3
                render.DrawLine(ent:GetPos(), ent:GetPos() + Vector(0, 0, ent:GetHeight()), color_white, true)
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