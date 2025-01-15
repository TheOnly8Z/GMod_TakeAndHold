AddCSLuaFile()

ENT.PrintName = "Token"
ENT.Category = "Tactical Takeover"
ENT.Base = "tah_base"
ENT.Spawnable = false
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.Model = "models/props_survival/upgrades/upgrade_dz_armor.mdl"

ENT.Static = false
ENT.Collision = COLLISION_GROUP_WEAPON
ENT.Trigger = true
ENT.TriggerBounds = 16

ENT.ArmorAmount = {60, 50, 40}

DEFINE_BASECLASS(ENT.Base)

function ENT:StartTouch(ply)
    if ply:IsPlayer() and ply:Alive() and ply:Team() ~= TEAM_SPECTATOR and not self.GIVEN and ply:GetMaxArmor() > ply:Armor() then
        self.GIVEN = true
        if ply:DZ_ENTS_GetArmor() <= DZ_ENTS_ARMOR_KEVLAR then
            ply:DZ_ENTS_SetArmor(DZ_ENTS_ARMOR_KEVLAR)
            ply:SetMaxArmor(100)
        end
        ply:SetArmor(math.min(ply:GetMaxArmor(), ply:Armor() + self.ArmorAmount[TAH.ConVars["game_difficulty"]:GetInt() + 1]))
        ply:EmitSound("dz_ents/armor_pickup_01.wav")
        self:Remove()
    end
end
