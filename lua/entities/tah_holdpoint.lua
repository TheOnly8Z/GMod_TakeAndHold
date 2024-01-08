AddCSLuaFile()

ENT.PrintName = "Hold Point"
ENT.Category = "Take and Hold"
ENT.Base = "tah_base"
ENT.Spawnable = true
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

DEFINE_BASECLASS(ENT.Base)

ENT.Model = "models/props_trainstation/trainstation_ornament002.mdl"

ENT.Editable = true

ENT.Trigger = true
ENT.TriggerBounds = 8

ENT.ThinkInterval = 0.25

-- harmonic number growth
ENT.CaptureRate = {
    [1] = 1,
    [2] = 0.667,
    [3] = 0.545,
    [4] = 0.480,
    [5] = 0.438,
    [6] = 0.408,
    [7] = 0.386,
    [8] = 0.368,
    [9] = 0.353,
    [10] = 0.341,
}
ENT.CaptureRateMax = 0.33333

-- Capturing
ENT.CaptureStateName = {
    [0] = "Capture", -- owned by enemy
    [1] = "Defend", -- owned by us
    [2] = "Blocking", -- our point, player > enemy
    [3] = "Securing",
    [4] = "Capturing", -- enemy point, player > enemy
    [5] = "Blocked by Enemy", -- max progress, player > enemy
    [6] = "Stalemate", -- enemy = player
    [7] = "Losing", -- enemy > player
}

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "Radius", {
        KeyName = "radius",
        Edit = {
            category = "Area",
            type = "Int",
            order = 3,
            min = 128,
            max = 1024,
            readonly = true
        }
    })
    self:NetworkVar("Int", 1, "Height", {
        KeyName = "height",
        Edit = {
            category = "Area",
            type = "Int",
            order = 4,
            min = 128,
            max = 512,
            readonly = true
        }
    })
    if self:GetRadius() == 0 then
        self:SetRadius(256)
    end
    if self:GetHeight() == 0 then
        self:SetHeight(128)
    end

    self:NetworkVar("Bool", 0, "UseAABB", {
        KeyName = "useaabb",
        Edit = {
            category = "Area",
            title = "Use Bounding Box",
            type = "Boolean",
            order = 2,
            readonly = true
        }
    })
    self:NetworkVar("Vector", 0, "MinS", {
        KeyName = "mins",
    })
    self:NetworkVar("Vector", 1, "MaxS", {
        KeyName = "maxs",
    })

    self:NetworkVar("Bool", 1, "Cage", {
        KeyName = "cage",
        Edit = {
            category = "Area",
            title = "Cage",
            type = "Boolean",
            order = 1,
            readonly = false
        }
    })

    self:NetworkVar("Float", 0, "CaptureTime", {
        KeyName = "captime",
        Edit = {
            category = "Capture",
            title = "Capture Time",
            type = "Float",
            order = 1,
            readonly = false
        }
    })
    if self:GetCaptureTime() <= 0 then
        self:SetCaptureTime(10)
    end

    self:NetworkVar("Int", 2, "SerialID", {
        KeyName = "serial_id",
        Edit = {
            title = "Serial ID",
            type = "Int",
            order = 1,
            readonly = true
        }
    })

    self:NetworkVar("Bool", 2, "OwnedByPlayers")
    self:NetworkVar("Float", 1, "CaptureProgress")
    self:NetworkVar("Int", 3, "CaptureState")
    self:SetOwnedByPlayers(false)
    self:SetCaptureProgress(0)
    self:SetCaptureState(0)
end

function ENT:VectorWithinArea(pos)
    if self:GetUseAABB() then
        return pos:WithinAABox(self:GetMinS(), self:GetMaxS())
    else
        return (pos.z - self:GetPos().z) >= 0 and (pos.z - self:GetPos().z) <= self:GetHeight()
                and math.sqrt((pos.x - self:GetPos().x) ^ 2 + (pos.y - self:GetPos().y) ^ 2) <= self:GetRadius()
    end
end

if SERVER then

    function ENT:Initialize()
        BaseClass.Initialize(self)

        TAH:SerializeHolds(self)

        -- if self:GetName() == "" then
        --     if self:MapCreationID() ~= -1 then
        --         self:SetKeyValue("targetname", "tah_hold_" .. self:MapCreationID())
        --     else
        --         self:SetKeyValue("targetname", "tah_hold_" .. self:GetCreationID())
        --     end
        -- end
    end

    function ENT:OnEnemyCapture(enemies)
        self:SetOwnedByPlayers(false)
        self:SetCaptureProgress(0)
        -- Lost control point, failed!
        if TAH:GetHoldEntity() == self and TAH:GetRoundState() == TAH.ROUND_WAVE then
            TAH:FinishHold(false)
        end
    end

    function ENT:OnPlayerCapture(players)
        self:SetOwnedByPlayers(true)
        self:SetCaptureProgress(0)
        if TAH:GetHoldEntity() == self and TAH:GetRoundState() == TAH.ROUND_TAKE then
            TAH:StartHold()
        end
    end

    function ENT:UpdateProgress()
        local enemies = {}
        local players = {}

        for _, ent in pairs(TAH.NPC_Cache) do
            if IsValid(ent) and ent:Health() > 0 and self:VectorWithinArea(ent:WorldSpaceCenter()) then
                table.insert(enemies, ent)
            end
        end
        for _, ply in pairs(player.GetAll()) do
            if IsValid(ply) and ply:Alive() and ply:Team() ~= TEAM_SPECTATOR and self:VectorWithinArea(ply:WorldSpaceCenter()) then
                table.insert(players, ply)
            end
        end

        local delta = 0
        if #players > #enemies then
            delta = 1 / self:GetCaptureTime() / (self.CaptureRate[#players - #enemies] or self.CaptureRateMax)
        elseif #enemies > #players then
            delta = -1 / self:GetCaptureTime() / (self.CaptureRate[#enemies - #players] or self.CaptureRateMax)
        end

        if self:GetOwnedByPlayers() then delta = delta * -1 end

        self:SetCaptureProgress(math.Clamp(self:GetCaptureProgress() + delta * self.ThinkInterval, 0, 1))
        if self:GetCaptureProgress() >= 1 then
            if self:GetOwnedByPlayers() and #players == 0 then
                self:OnEnemyCapture(enemies)
                self:SetCaptureState(0)
            elseif not self:GetOwnedByPlayers() and #enemies == 0 then
                self:OnPlayerCapture(players)
                self:SetCaptureState(1)
            end
        end

        if self:GetOwnedByPlayers() then
            if self:GetCaptureProgress() == 0 and #enemies == 0 then
                self:SetCaptureState(1)
            elseif #players > #enemies then
                if self:GetCaptureProgress() > 0 then
                    self:SetCaptureState(3)
                else
                    self:SetCaptureState(2)
                end
            elseif #players == #enemies then
                self:SetCaptureState(6)
            elseif #players < #enemies then
                if self:GetCaptureProgress() == 1 then
                    self:SetCaptureState(2)
                else
                    self:SetCaptureState(7)
                end
            end
        else
            if self:GetCaptureProgress() == 0 and #players == 0 then
                self:SetCaptureState(0)
            elseif #players < #enemies then
                if self:GetCaptureProgress() > 0 then
                    self:SetCaptureState(7)
                else
                    self:SetCaptureState(5)
                end
            elseif #players == #enemies then
                self:SetCaptureState(6)
            elseif #players > #enemies then
                if self:GetCaptureProgress() == 1 then
                    self:SetCaptureState(5)
                else
                    self:SetCaptureState(4)
                end
            end
        end
    end

    function ENT:Think()
    end

    function ENT:OnRemove()
        TAH:SerializeHolds()
    end
elseif CLIENT then
    function ENT:DrawTranslucent()
        self:DrawModel()
    end
end
