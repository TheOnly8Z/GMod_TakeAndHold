AddCSLuaFile()

ENT.PrintName = "Barrier"
ENT.Type = "anim"
ENT.Spawnable = false
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.TAH_SaveEntity = true

function ENT:SetupDataTables()
    self:NetworkVar("Vector", 0, "MinS")
    self:NetworkVar("Vector", 1, "MaxS")

    self:NetworkVar("Bool", 0, "Enabled")
end

function ENT:Initialize()
    self:SetModel("models/hunter/blocks/cube025x025x025.mdl")
    self:DrawShadow(false)

    self.PhysCollide = CreatePhysCollideBox(self:GetMinS(), self:GetMaxS())
    self:SetCollisionBounds(self:GetMinS(), self:GetMaxS())

    self:SetCollisionGroup(COLLISION_GROUP_NONE)

    if SERVER then
        self:PhysicsInitBox(self:GetMinS(), self:GetMaxS())
        self:SetSolid(SOLID_VPHYSICS)
        self:PhysWake()

        local physobj = self:GetPhysicsObject()
        if IsValid(physobj) then
            physobj:EnableMotion(false)
        else
            ErrorNoHalt("wtf")
        end
    end

    if CLIENT then
        self:SetRenderBounds(self:GetMinS(), self:GetMaxS())
    end

    self:EnableCustomCollisions(true)
    self:SetCustomCollisionCheck(true)

    self:SetEnabled(false)
end

function ENT:TestCollision(startpos, delta, isbox, extents, mask)
    if self:GetEnabled() and not (mask == MASK_SHOT or mask == MASK_SHOT_HULL) then return true end
    --if bit.band(mask, CONTENTS_GRATE) ~= 0 then return true end
end

if SERVER then
    function ENT:Serialize(version)
        return {
            self:GetPos(),
            self:GetAngles(),
            self:GetMinS(),
            self:GetMaxS()
        }
    end

    function ENT:Deserialize(tbl, version)
        self:SetPos(tbl[1])
        self:SetAngles(tbl[2])
        self:SetMinS(tbl[3])
        self:SetMaxS(tbl[4])
    end
elseif CLIENT then
    local mat = Material("effects/com_shield002a")

    function ENT:DrawTranslucent()
        if self:GetEnabled() then
            render.SetMaterial(mat)
            render.DrawBox(self:GetPos(), self:GetAngles(), self:GetMinS(), self:GetMaxS(), color_white)
        --[[]
        elseif IsValid(LocalPlayer():GetActiveWeapon()) and LocalPlayer():GetActiveWeapon():GetClass() == "gmod_tool"
                and (LocalPlayer():GetTool() or {}).Mode == "tah_barrier" then
            render.DrawWireframeBox(self:GetPos(), self:GetAngles(), self:GetMinS(), self:GetMaxS(), color_white, true)
        ]]
        end
    end
end