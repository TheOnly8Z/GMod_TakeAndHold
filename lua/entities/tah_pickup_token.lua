AddCSLuaFile()

ENT.PrintName = "Token"
ENT.Category = "Tactical Takeover"
ENT.Base = "tah_base"
ENT.Spawnable = false
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.Model = "models/Items/combine_rifle_ammo01.mdl"

ENT.Static = false
ENT.Collision = COLLISION_GROUP_WEAPON
ENT.Trigger = true
ENT.TriggerBounds = 16

DEFINE_BASECLASS(ENT.Base)

function ENT:StartTouch(ply)
    if ply:IsPlayer() and ply:Alive() and ply:Team() ~= TEAM_SPECTATOR and not self.GIVEN then
        self.GIVEN = true
        TAH:AddTokens(ply, 1)
        self:EmitSound("items/battery_pickup.wav")
        self:Remove()
    end
end
