TOOL.Category = "Take and Hold"
TOOL.Name = "#tool.tah_link.name"

TOOL.Information = {
    {name = "left", stage = 0},
    {name = "left.op0", stage = 1, op = 0},
    {name = "left.op1", stage = 1, op = 1},
    {name = "left.multi", stage = 1, op = 0, icon2 = "gui/r.png"},
    {name = "left.multi", stage = 1, op = 1, icon2 = "gui/r.png"},

    {name = "right", stage = 0, op = 0},
    {name = "right", stage = 0, op = 1},
    {name = "right.1", stage = 1, op = 0},
    {name = "right.1", stage = 1, op = 1},
    {name = "reload", stage = 0},
}

if CLIENT then
    language.Add("tool.tah_link.name", "Spawn Linker")
    language.Add("tool.tah_link.desc", "Connect spawns with hold points.")
    language.Add("tool.tah_link.left", "Add Link")
    language.Add("tool.tah_link.left.op0", "Select spawn/hold to link with")
    language.Add("tool.tah_link.left.op1", "Select spawn/hold to unlink with")
    language.Add("tool.tah_link.left.multi", "Link/unlink multiple")
    language.Add("tool.tah_link.right", "Remove Link")
    language.Add("tool.tah_link.right.1", "Cancel")
    language.Add("tool.tah_link.reload", "Clear Links")

end

function TOOL:Reset()
    self.Weapon:SetNWEntity("LinkSource", nil)
    self:SetStage(0)
    self:SetOperation(0)
end

function TOOL:LeftClick(tr)
    if not IsFirstTimePredicted() or TAH:GetRoundState() ~= TAH.ROUND_INACTIVE then return end
    local ent = tr.Entity

    if self:GetStage() == 0 and (ent.TAH_Spawn or ent:GetClass() == "tah_holdpoint") then
        self.Weapon:SetNWEntity("LinkSource", ent)
        self:SetStage(1)
        self:SetOperation(0)
        return true
    elseif self:GetStage() == 1 then
        local other = self.Weapon:GetNWEntity("LinkSource")
        if other.TAH_Spawn and ent:GetClass() == "tah_holdpoint" then
            if self:GetOperation() == 0 then
                other:AddLinkedHold(ent)
            else
                other:RemoveLinkedHold(ent)
            end
            if not self:GetOwner():KeyDown(IN_RELOAD) then self:Reset() end
            return true
        elseif ent.TAH_Spawn and other:GetClass() == "tah_holdpoint" then
            if self:GetOperation() == 0 then
                ent:AddLinkedHold(other)
            else
                ent:RemoveLinkedHold(other)
            end
            if not self:GetOwner():KeyDown(IN_RELOAD) then self:Reset() end
            return true
        end
    end
end

function TOOL:RightClick(tr)
    if not IsFirstTimePredicted() or TAH:GetRoundState() ~= TAH.ROUND_INACTIVE then return end
    local ent = tr.Entity

    if self:GetStage() == 0 and (ent.TAH_Spawn or ent:GetClass() == "tah_holdpoint") then
        self.Weapon:SetNWEntity("LinkSource", ent)
        self:SetStage(1)
        self:SetOperation(1)
        return true
    elseif self:GetStage() == 1 then
        self:Reset()
        return true
    end
end

function TOOL:Reload(tr)
    if not IsFirstTimePredicted() or TAH:GetRoundState() ~= TAH.ROUND_INACTIVE then return end
    local ent = tr.Entity

    if self:GetStage() == 0 then
        if ent.TAH_Spawn then
            ent:SetLinkBits(0)
            return true
        elseif ent:GetClass() == "tah_holdpoint" then
            for _, tbl in pairs(TAH.Spawn_Cache) do
                for _, spawn in pairs(tbl) do
                    spawn:RemoveLinkedHold(ent)
                end
            end
            return true
        end
    end
    return false
end

function TOOL:Think()
    if self:GetStage() > 0 and not IsValid(self.Weapon:GetNWEntity("LinkSource")) then
        self:Reset()
    end
end

local toolmask = bit.bor( CONTENTS_SOLID, CONTENTS_MOVEABLE, CONTENTS_MONSTER, CONTENTS_WINDOW, CONTENTS_DEBRIS, CONTENTS_GRATE, CONTENTS_AUX )

if CLIENT then
    local clr_nolink = Color(255, 150, 150, 255)
    local clr_link = Color(150, 255, 150, 255)
    hook.Add("PostDrawTranslucentRenderables", "tah_link", function()
        local w = LocalPlayer():GetTool()
        if not w then return end
        local wep = LocalPlayer():GetActiveWeapon()
        if not IsValid(wep) then return end

        if w.Mode == "tah_link" and w:GetStage() == 1 and IsValid(wep:GetNWEntity("LinkSource")) then
            -- local t = LocalPlayer():GetEyeTrace()
            local tr = util.GetPlayerTrace(LocalPlayer())
            tr.mask = toolmask
            tr.mins = vector_origin
            tr.maxs = tr.mins
            local t = util.TraceHull(tr)

            local ent = t.Entity
            local other = wep:GetNWEntity("LinkSource")

            local clr = clr_nolink
            if IsValid(ent) and (other.TAH_Spawn and ent:GetClass() == "tah_holdpoint") or (ent.TAH_Spawn and other:GetClass() == "tah_holdpoint") then
                clr = clr_link
            end

            render.DrawLine(other:GetPos(), t.HitPos, clr, false)
        end
    end)
end