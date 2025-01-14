surface.CreateFont("TAH_96", {
    font = "Arial",
    size = 96,
    weight = 600,
})

local color_barrier = Color(25, 75, 200, 50)
local color_crate = Color(200, 120, 0, 100)

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
        local noz = LocalPlayer():KeyDown(IN_WALK)
        cam.IgnoreZ(noz)
        for _, ent in pairs(ents.GetAll()) do
            if ent:GetClass() == "tah_holdpoint" then
                if ent:GetUseAABB() then
                    render.DrawWireframeBox(Vector(), Angle(), ent:GetMinS(), ent:GetMaxS(), color_white, not noz)
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

                local ang = EyeAngles()
                ang:RotateAroundAxis(ang:Right(), 90)
                ang:RotateAroundAxis(ang:Up(), -90)
                cam.IgnoreZ(true)
                cam.Start3D2D(ent:GetPos() + Vector(0, 0, 32), ang, ent:GetPos():Distance(EyePos()) / 2048)
                    draw.SimpleTextOutlined(ent:GetSerialID(), "TacRP_Myriad_Pro_32", 0, 0, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 4, color_black)
                cam.End3D2D()
                cam.IgnoreZ(noz)
            elseif ent.TAH_Shop then
                local ang = EyeAngles()
                ang:RotateAroundAxis(ang:Right(), 90)
                ang:RotateAroundAxis(ang:Up(), -90)
                cam.IgnoreZ(true)
                cam.Start3D2D(ent:GetPos() + Vector(0, 0, 64), ang, ent:GetPos():Distance(EyePos()) / 2048)
                    draw.SimpleTextOutlined(ent.PrintName, "TacRP_Myriad_Pro_12", 0, 0, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 4, color_black)
                cam.End3D2D()
                cam.IgnoreZ(noz)
            elseif ent.TAH_Spawn then
                render.SetColorMaterial()
                for _, v in pairs(ent:GetLinkedHolds()) do
                    render.DrawSphere(ent:GetPos(), 8, 8, 8, ent.Color)
                    render.DrawLine(v:GetPos(), ent:GetPos(), ent.Color, not noz)
                end
            elseif ent:GetClass() == "tah_barrier" then
                render.SetColorMaterial()
                render.DrawBox(ent:GetPos(), ent:GetAngles(), ent:GetMinS(), ent:GetMaxS(), color_barrier)
            elseif ent:GetClass() == "tah_crate" then
                render.DrawSphere(ent:WorldSpaceCenter(), 12, 8, 8, color_crate)
            end
        end
        cam.IgnoreZ(false)
    end
end)

hook.Add("OnEntityCreated", "TAH_Render", function(ent)
    if TAH:GetRoundState() == TAH.ROUND_INACTIVE then return end
    if IsValid(ent) and ent:GetClass() == "class C_ClientRagdoll" then
        timer.Simple(5, function()
            if IsValid(ent) then
                ent:DrawShadow(false)
                ent:SetRenderMode(RENDERMODE_TRANSALPHA)
                ent:SetRenderFX(kRenderFxFadeFast)
                timer.Simple(1.5, function() if IsValid(ent) then ent:Remove() end end)
            end
        end)
    end
end)