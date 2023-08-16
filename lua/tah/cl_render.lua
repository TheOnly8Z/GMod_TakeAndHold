surface.CreateFont("TAH_96", {
    font = "Arial",
    size = 96,
    weight = 600,
})

hook.Add("PostDrawTranslucentRenderables", "TAH_Render", function()

    local ent = TAH:GetHoldEntity()
    if IsValid(ent) then
        for i = 1, 5 do
            cam.Start3D2D(ent:GetPos() + Vector(0, 0, 4 + (i - 1) * 8), Angle(0, 0, 0), 0.01)
                surface.DrawCircle(0, 0, ent:GetRadius() * 100, 255, 255, 255, 255 - i * 50)
                if i == 1 then
                    surface.DrawCircle(0, 0, ent:GetRadius() * 100 * (CurTime() % 2) / 2, 255, 255, 255, 200 * (1 - (CurTime() % 2) / 2))
                end
            cam.End3D2D()
        end
    end

    -- for _, ent in pairs(ents.FindByClass("tah_holdpoint")) do
    --     for i = 1, 5 do
    --         cam.Start3D2D(ent:GetPos() + Vector(0, 0, 4 + (i - 1) * 8), Angle(0, 0, 0), 0.01)
    --             surface.DrawCircle(0, 0, ent:GetRadius() * 100, 255, 255, 255, 255 - i * 50)
    --             if i == 1 then
    --                 surface.DrawCircle(0, 0, ent:GetRadius() * 100 * (CurTime() % 2) / 2, 255, 255, 255, 200 * (1 - (CurTime() % 2) / 2))
    --             end
    --         cam.End3D2D()
    --     end


    --     -- local pos = ent:GetPos() + Vector(0, 0, 64)

    --     -- local ang = (ent:GetPos() + Vector(0, 0, 64) - LocalPlayer():EyePos()):Angle()
    --     -- ang:RotateAroundAxis(ang:Forward(), 90)
    --     -- ang:RotateAroundAxis(ang:Right(), 90)

    --     -- cam.Start3D2D(pos, ang, 0.1)
    --     --     surface.DrawCircle(0, 0, 128, 255, 0, 0, 255)
    --     --     draw.SimpleText("60", "TAH_96", 0, 0, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    --     -- cam.End3D2D()
    -- end
end)