TOOL.Category = "Tactical Takeover"
TOOL.Name = "#tool.tah_barrier.name"

TOOL.Information = {
    {name = "left", stage = 0},
    {name = "left.1", stage = 1},
    {name = "right", stage = 0},
    {name = "right.1", stage = 1},
    {name = "reload", stage = 0},
}

if CLIENT then
    language.Add("tool.tah_barrier.name", "Barrier")
    language.Add("tool.tah_barrier.desc", "Create barriers that players cannot cross. Used during holds to keep them within the defend area.")
    language.Add("tool.tah_barrier.left", "Place Barrier")
    language.Add("tool.tah_barrier.left.1", "Select Second Point")
    language.Add("tool.tah_barrier.right", "Autofill Barrier (Click within door frame)")
    language.Add("tool.tah_barrier.right.1", "Cancel")
    language.Add("tool.tah_barrier.reload", "Toggle Barrier")
end

local function resolve_barrier(vec1, vec2)
    if math.abs(vec1.z - vec2.z) <= 16 then
        -- Horizontal
        local center = vec1 + (vec2 - vec1) / 2
        local angle = Angle(0, 0, 0)
        local width = math.abs(vec2.x - vec1.x) / 2
        local height = math.abs(vec2.y - vec1.y) / 2

        return center, angle, Vector(-width, -height, -1), Vector(width, height, 1)
    else
        -- Vertical
        if math.abs(vec1.x - vec2.x) <= 16 then
            vec2.x = vec1.x
        elseif math.abs(vec1.y - vec2.y) <= 16 then
            vec2.y = vec1.y
        end

        local center = vec1 + (vec2 - vec1) / 2
        local angle = (vec2 - vec1):GetNormalized():Cross(Vector(0, 0, 1)):Angle() --+ Angle(0, 90, 0)
        angle:RotateAroundAxis(Vector(0, 0, 1), 90)
        local width = math.sqrt((vec2.x - vec1.x) ^ 2 + (vec2.y - vec1.y) ^ 2) / 2
        local height = math.abs(vec2.z - vec1.z) / 2

        return center, angle, Vector(-width, -1, -height), Vector(width, 1, height)
    end
end

function TOOL:LeftClick(tr)
    if not IsFirstTimePredicted() then return end

    if self:GetStage() == 0 then
        self:SetStage(1)
        self.Weapon:SetNWVector("StepInfo", tr.HitPos)
    else
        if SERVER then
            local pos2 = tr.HitPos
            local center, ang, mins, maxs = resolve_barrier(self.Weapon:GetNWFloat("StepInfo"), pos2)

            local barrier = ents.Create("tah_barrier")
            barrier:SetMinS(mins)
            barrier:SetMaxS(maxs)
            barrier:SetPos(center)
            barrier:SetAngles(ang)
            barrier:Spawn()

            undo.Create( "SENT" )
                undo.SetPlayer( self.Weapon:GetOwner() )
                undo.AddEntity( barrier )
                undo.SetCustomUndoText( "Undone " .. barrier.PrintName )
            undo.Finish( "Barrier" )
        end
        self:SetStage(0)
    end
    return true
end

function TOOL:RightClick(tr)
    if self:GetStage() == 0 then
        -- Try to find a door frame
        local tr_up = util.TraceLine({
            start = tr.HitPos + tr.HitNormal,
            endpos = tr.HitPos + Vector(0, 0, 256),
            mask = MASK_SOLID_BRUSHONLY
        })
        local tr_down = util.TraceLine({
            start = tr.HitPos + tr.HitNormal,
            endpos = tr.HitPos - Vector(0, 0, 256),
            mask = MASK_SOLID_BRUSHONLY
        })
        local mid = tr_down.HitPos + (tr_up.HitPos - tr_down.HitPos) / 2

        debugoverlay.Cross(mid, 8, 5, Color(255, 255, 0), true)

        local tr1, tr2 = nil, nil
        for i = 0, 180, 45 do
            local tr_f = util.TraceLine({
                start = mid,
                endpos = mid + Angle(0, i, 0):Forward() * 2048,
                mask = MASK_SOLID_BRUSHONLY,
            })
            local tr_b = util.TraceLine({
                start = mid,
                endpos = mid - Angle(0, i, 0):Forward() * 2048,
                mask = MASK_SOLID_BRUSHONLY,
            })
            debugoverlay.Line(tr_f.HitPos, tr_b.HitPos, 1, Color(255, 255, 255, 100))
            if tr1 == nil or (tr1.Fraction + tr2.Fraction >  tr_f.Fraction + tr_b.Fraction) then
                tr1, tr2 = tr_f, tr_b
            end
        end
        if not tr1 then return end

        debugoverlay.Line(tr1.HitPos, tr2.HitPos, 5, Color(0, 0, 255, 255))

        local vec1 = Vector(tr1.HitPos.x, tr1.HitPos.y, tr_down.HitPos.z)
        local vec2 = Vector(tr2.HitPos.x, tr2.HitPos.y, tr_up.HitPos.z)

        local center, ang, mins, maxs = resolve_barrier(vec1, vec2)
        local barrier = ents.Create("tah_barrier")
        barrier:SetMinS(mins)
        barrier:SetMaxS(maxs)
        barrier:SetPos(center)
        barrier:SetAngles(ang)
        barrier:Spawn()

        undo.Create( "SENT" )
            undo.SetPlayer( self.Weapon:GetOwner() )
            undo.AddEntity( barrier )
            undo.SetCustomUndoText( "Undone " .. barrier.PrintName )
        undo.Finish( "Barrier" )

        return true
    else
        self:SetStage(0)
        return true
    end
end

function TOOL:Reload(tr)
    if not IsFirstTimePredicted() then return end
    if self:GetStage() == 0 then
        local ent = tr.Entity
        if IsValid(ent) and ent:GetClass() == "tah_barrier" then
            ent:SetEnabled(not ent:GetEnabled())
            ent:CollisionRulesChanged()
            return true
        end
    end
    return false
end

function TOOL:Think()
end

if CLIENT then
    surface.CreateFont("GModToolScreen2", {
        font = "Helvetica",
        size = 40,
        weight = 900
    })

    surface.CreateFont("GModToolScreen3", {
        font = "Helvetica",
        size = 30,
        weight = 900
    })

    local mat = Material("models/debug/debugwhite")
    hook.Add("PostDrawOpaqueRenderables", "tah_barrier", function()
        local w = LocalPlayer():GetTool()
        if not w then return end
        local wep = LocalPlayer():GetActiveWeapon()
        if not IsValid(wep) then return end

        if w.Mode == "tah_barrier" and w:GetStage() == 1 then
            local t = LocalPlayer():GetEyeTrace()
            render.SetMaterial(mat)

            local center, ang, mins, maxs = resolve_barrier(wep:GetNWFloat("StepInfo"), t.HitPos)

            render.DrawLine(wep:GetNWFloat("StepInfo"), t.HitPos, color_white, true)
            render.DrawWireframeSphere(center, 4, 4, 4, color_white)
            render.DrawWireframeBox(center, ang, mins, maxs, color_white, true)
        end
    end)
end