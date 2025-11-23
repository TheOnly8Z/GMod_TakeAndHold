AddCSLuaFile()

ENT.PrintName = "Attachment Pickup"
ENT.Category = "Tactical Takeover"
ENT.Base = "tah_base"
ENT.Spawnable = false
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.Model = "models/tacint/props_containers/supply_case-2.mdl"

ENT.Static = false
ENT.Collision = COLLISION_GROUP_WEAPON
ENT.Trigger = true
ENT.TriggerBounds = 16

ENT.AmmoType = "tah_attbox"
ENT.AmmoCount = 1

DEFINE_BASECLASS(ENT.Base)

local up = Vector(0, 0, 1)
function ENT:StartTouch(ply)
    if ply:IsPlayer() and ply:Alive() and ply:Team() ~= TEAM_SPECTATOR and not self.GIVEN then
        local given = ply:GiveAmmo(self.AmmoCount, self.AmmoType, false)
        if given == 0 then return end
        self.GIVEN = true
        self:EmitSound("dz_ents/armor_pickup_0" .. math.random(1, 2) .. ".wav")

        local eff = EffectData()
        eff:SetOrigin(self:GetPos())
        eff:SetEntity(self)

        local shelltype = "RifleShellEject"
        for i = 1, math.random(1, 4) do
            eff:SetAngles((up + VectorRand() * 0.1):Angle())
            util.Effect(shelltype, eff)
        end

        self:Remove()
    end
end
