AddCSLuaFile()

ENT.PrintName = "Crate Spawn"
ENT.Category = "Tactical Takeover"
ENT.Base = "tah_base"
ENT.Spawnable = true
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.TAH_SaveEntity = true

ENT.Model = "models/Items/item_item_crate.mdl"
ENT.Color = Color(255, 255, 255, 150)
ENT.NoShadows = true
ENT.Collision = false

DEFINE_BASECLASS(ENT.Base)