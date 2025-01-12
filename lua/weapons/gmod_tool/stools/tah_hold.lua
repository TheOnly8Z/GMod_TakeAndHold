TOOL.Category = "Take and Hold"
TOOL.Name = "#tool.tah_hold.name"

TOOL.Information = {
    {name = "cyl", stage = 0, op = 0},
    {name = "aabb", stage = 0, op = 1},
    {name = "cyl", stage = 1, op = 0},
    {name = "aabb", stage = 1, op = 1},
    {name = "cyl", stage = 2, op = 0},
    {name = "aabb", stage = 2, op = 1},
    {name = "left", stage = 0, op = 0},
    {name = "left", stage = 0, op = 1},
    {name = "left.cyl.1", stage = 1, op = 0},
    {name = "left.cyl.2", stage = 2, op = 0},
    {name = "left.aabb.1", stage = 1, op = 1},
    {name = "left.aabb.2", stage = 2, op = 1},
    {name = "right", stage = 1},
    {name = "right", stage = 2},
    {name = "reload", stage = 0, op = 0},
    {name = "reload", stage = 0, op = 1},
    {name = "reload.self", stage = 1, op = 0},
    {name = "reload.self", stage = 1, op = 1},
    {name = "reload.self", stage = 2, op = 0},
    {name = "reload.self", stage = 2, op = 1},
}

if CLIENT then
    language.Add("tool.tah_hold.name", "Hold Area")
    language.Add("tool.tah_hold.desc", "Create or change the shape and size of hold areas.")
    language.Add("tool.tah_hold.aabb", "Current Mode: Bounding Box")
    language.Add("tool.tah_hold.cyl", "Current Mode: Cylinder")
    language.Add("tool.tah_hold.left", "Select/Place Hold Entity")
    language.Add("tool.tah_hold.left.aabb.1", "Assign First Corner")
    language.Add("tool.tah_hold.left.aabb.2", "Assign Second Corner")
    language.Add("tool.tah_hold.left.cyl.1", "Assign Radius")
    language.Add("tool.tah_hold.left.cyl.2", "Assign Height")
    language.Add("tool.tah_hold.right", "Cancel")
    language.Add("tool.tah_hold.reload", "Switch Modes")
    language.Add("tool.tah_hold.reload.self", "Use Player Position")

end

local function place(self, pos2)
    local hold = self.Weapon:GetNWEntity("HoldEntity")
    if not IsValid(hold) then
        hold = ents.Create("tah_holdpoint")
        hold:SetPos(self.Weapon:GetNWVector("HoldVector"))
        hold:Spawn()
    end

    if self:GetOperation() == 0 then
        local pos0 = hold:GetPos()
        local pos1 = self.Weapon:GetNWFloat("StepInfo")
        pos1.z = pos0.z
        hold:SetUseAABB(false)
        hold:SetRadius(math.max(128, math.ceil(pos0:Distance(pos1))))
        hold:SetHeight(math.max(128, math.ceil(pos2.z - pos0.z)))
    elseif self:GetOperation() == 1 then
        local mins, maxs = self.Weapon:GetNWFloat("StepInfo"), pos2
        OrderVectors(mins, maxs)
        hold:SetUseAABB(true)
        hold:SetMinS(mins)
        hold:SetMaxS(maxs)
    end
end

function TOOL:Deploy()
    self.Weapon:SetNWEntity("HoldEntity", NULL)
    self.Weapon:SetNWVector("HoldVector", NULL)
    self:SetStage(0)
    self:SetOperation(0)
end

function TOOL:LeftClick(tr)
    if not IsFirstTimePredicted() then return end

    if self:GetStage() == 0 then
        if IsValid(tr.Entity) and tr.Entity:GetClass() == "tah_holdpoint" then
            self.Weapon:SetNWEntity("HoldEntity", tr.Entity)
            self.Weapon:SetNWVector("HoldVector", NULL)
        else
            self.Weapon:SetNWEntity("HoldEntity", NULL)
            self.Weapon:SetNWVector("HoldVector", tr.HitPos)
        end
        self:SetStage(1)
    elseif self:GetStage() == 1 then
        self:SetStage(2)
        self.Weapon:SetNWVector("StepInfo", tr.HitPos)
    else
        if SERVER then
            place(self, tr.HitPos)
        end
        self:SetStage(0)
    end
    return true
end

function TOOL:RightClick(tr)
    if self:GetStage() ~= 0 then
        self:SetStage(0)
        return true
    end
end

function TOOL:Reload(tr)
    if not IsFirstTimePredicted() then return end
    if self:GetStage() == 0 then
        self:SetOperation((self:GetOperation() + 1) % 2)
    elseif self:GetStage() == 1 then
        self:SetStage(2)
        self.Weapon:SetNWVector("StepInfo", self:GetOwner():GetPos())
    else
        if SERVER then
            place(self, self:GetOwner():GetPos())
        end
        self:SetStage(0)
    end
    return true
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
    hook.Add("PostDrawOpaqueRenderables", "tah_hold", function()
        local w = LocalPlayer():GetTool()
        if not w then return end
        local wep = LocalPlayer():GetActiveWeapon()
        if not IsValid(wep) then return end

        if w.Mode == "tah_hold" and w:GetStage() > 0 then
            local t = LocalPlayer():GetEyeTrace()
            render.SetMaterial(mat)

            local pos0 = IsValid(wep:GetNWEntity("HoldEntity")) and wep:GetNWEntity("HoldEntity"):GetPos() or wep:GetNWVector("HoldVector")
            local pos1 = w:GetStage() == 2 and wep:GetNWVector("StepInfo") or t.HitPos
            local pos2 = t.HitPos

            if w:GetOperation() == 0 then
                local rad = math.max(128, math.sqrt((pos0.x - pos1.x) ^ 2 + (pos0.y - pos1.y) ^ 2))
                local rad2 = math.max(128, math.sqrt((pos0.x - LocalPlayer():GetPos().x) ^ 2 + (pos0.y - LocalPlayer():GetPos().y) ^ 2))
                if w:GetStage() == 2 then rad2 = rad end
                cam.Start3D2D(pos0, Angle(0, 0, 0), 0.01)
                    surface.DrawCircle(0, 0, rad * 100, 255, 255, 0, 255)
                    surface.DrawCircle(0, 0, rad2 * 100, 255, 255, 255, 100)
                cam.End3D2D()
                if w:GetStage() >= 2 then
                    cam.Start3D2D(pos0 + Vector(0, 0, math.max(128, pos2.z - pos0.z)), Angle(0, 0, 0), 0.01)
                        surface.DrawCircle(0, 0, rad * 100, 255, 255, 0, 255)
                    cam.End3D2D()
                    cam.Start3D2D(pos0 + Vector(0, 0, math.max(128, LocalPlayer():GetPos().z - pos0.z)), Angle(0, 0, 0), 0.01)
                        surface.DrawCircle(0, 0, rad * 100, 255, 255, 255, 100)
                    cam.End3D2D()
                    render.DrawLine(pos0, Vector(pos0.x, pos0.y, pos2.z), Color(255, 128, 0), true)
                    render.DrawLine(Vector(pos0.x, pos0.y, pos2.z), pos2, Color(255, 128, 0), true)
                else
                    render.DrawLine(pos0, pos1, Color(255, 128, 0), true)
                    render.DrawLine(pos0, Vector(LocalPlayer():GetPos().x, LocalPlayer():GetPos().y, pos0.z), Color(255, 255, 255, 100), false)
                end
            elseif w:GetOperation() == 1 then
                if w:GetStage() >= 2 then
                    render.DrawLine(pos1, pos2, Color(255, 128, 0), true)
                    render.DrawWireframeBox(Vector(), Angle(), pos1, pos2, Color(255, 255, 0), true)
                    render.DrawWireframeBox(Vector(), Angle(), pos1, LocalPlayer():GetPos(), Color(255, 255, 255, 100), false)
                else
                    render.DrawLine(pos0, pos1, Color(255, 128, 0), true)
                end
            end

            -- render.DrawLine(wep:GetNWFloat("StepInfo"), t.HitPos, color_white, true)
            -- render.DrawWireframeSphere(center, 4, 4, 4, color_white)
            -- render.DrawWireframeBox(center, ang, mins, maxs, color_white, true)
        end
    end)
end