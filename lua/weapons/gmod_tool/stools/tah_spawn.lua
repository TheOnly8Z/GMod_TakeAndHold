TOOL.Category = "Tactical Takeover"
TOOL.Name = "#tool.tah_spawn.name"

TOOL.Information = {
    {name = "player", stage = 0, op = 0},
    {name = "attack", stage = 0, op = 1},
    {name = "defend", stage = 0, op = 2},
    {name = "patrol", stage = 0, op = 3},
    {name = "left", stage = 0},
    {name = "right", stage = 0},
    {name = "reload", stage = 0},
}

local op_to_ent = {
    [0] = "tah_spawn_player",
    [1] = "tah_spawn_attack",
    [2] = "tah_spawn_defend",
    [3] = "tah_spawn_patrol",
}

if CLIENT then
    language.Add("tool.tah_spawn.name", "Spawn Creator")
    language.Add("tool.tah_spawn.desc", "Create spawn points for holds.")
    language.Add("tool.tah_spawn.player", "Current Spawn Type: Player")
    language.Add("tool.tah_spawn.attack", "Current Spawn Type: Attack")
    language.Add("tool.tah_spawn.defend", "Current Spawn Type: Defend")
    language.Add("tool.tah_spawn.patrol", "Current Spawn Type: Patrol")

    language.Add("tool.tah_spawn.left", "Place Spawn")
    language.Add("tool.tah_spawn.right", "Link/Unlink Hold")
    language.Add("tool.tah_spawn.reload", "Select Spawn Type")
end

TOOL.Holds = {}
TOOL.HoldsDict = {}

function TOOL:Deploy()
    self.Weapon:SetNWEntity("HoldEntity", NULL)
    self:SetStage(0)
    self:SetOperation(0)
end

function TOOL:LeftClick(tr)
    if not IsFirstTimePredicted() then return end

    if SERVER then
        local other = tr.Entity
        local hold = self.Weapon:GetNWEntity("HoldEntity", NULL)

        if IsValid(other) and other.TAH_Spawn then
            if not other:IsLinkedWith(hold) then
                other:AddLinkedHold(hold)
            else
                other:RemoveLinkedHold(hold)
            end
        else
            local ent = ents.Create(op_to_ent[self:GetOperation()])
            ent:SetPos(tr.HitPos)
            ent:SetAngles(Angle(0, self.Weapon:GetOwner():GetAngles().y + 180, 0))
            ent:Spawn()

            if IsValid(hold) then
                ent:AddLinkedHold(hold)
            end

            undo.Create( "SENT" )
                undo.SetPlayer( self.Weapon:GetOwner() )
                undo.AddEntity( ent )
                undo.SetCustomUndoText( "Undone " .. ent.PrintName )
            undo.Finish( "Spawn" )
        end



        --[[]
        for i, hold in ipairs(self.Holds) do
            if IsValid(hold) then
                ent:AddLinkedHold(hold)
            else
                self.HoldsDict[hold] = nil
                table.remove(self.Holds, i)
            end
        end
        ]]
    end

    return true
end

function TOOL:RightClick(tr)
    if not IsFirstTimePredicted() then return end

    local ent = tr.Entity
    if ent:GetClass() == "tah_holdpoint" and ent ~= self.Weapon:GetNWEntity("HoldEntity", NULL) then
        self.Weapon:SetNWEntity("HoldEntity", ent)
        --[[]
        if self.HoldsDict[ent] then
            table.RemoveByValue(self.Holds, ent)
            self.HoldsDict[ent] = nil
        else
            table.insert(self.Holds, ent)
            self.HoldsDict[ent] = true
        end
        if SERVER and game.SinglePlayer() then
            self.Weapon:CallOnClient("SecondaryAttack") -- blehhh
        end
        ]]
        return true
    elseif IsValid(self.Weapon:GetNWEntity("HoldEntity", NULL)) then
        self.Weapon:SetNWEntity("HoldEntity", NULL)
        return true
    end
end

function TOOL:Reload(tr)
    if not IsFirstTimePredicted() then return end
    if self:GetStage() == 0 then
        self:SetOperation((self:GetOperation() + 1) % 4)
    end
    return true
end

function TOOL:Think()
end

if CLIENT then
    hook.Add("PostDrawTranslucentRenderables", "tah_spawn", function()
        local w = LocalPlayer():GetTool()
        if not w then return end
        local wep = LocalPlayer():GetActiveWeapon()
        if not IsValid(wep) then return end

        if w.Mode == "tah_spawn" and IsValid(wep:GetNWEntity("HoldEntity", NULL)) then
            local t = LocalPlayer():GetEyeTrace()
            render.DrawLine(wep:GetNWEntity("HoldEntity", NULL):GetPos(), t.HitPos, color_white, false)
            --[[]
            for i, hold in ipairs(w.Holds) do
                if IsValid(hold) then
                    render.DrawLine(hold:GetPos(), t.HitPos, scripted_ents.Get(op_to_ent[w:GetOperation()]).Color, false)
                end
            end
            ]]
        end
    end)
end