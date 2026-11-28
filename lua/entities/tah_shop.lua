AddCSLuaFile()

ENT.PrintName = "Shop"
ENT.Category = "Tactical Takeover"
ENT.Base = "tah_base"
ENT.Spawnable = true
ENT.RenderGroup = RENDERGROUP_OPAQUE

ENT.Model = "models/props_combine/combine_interface001.mdl"

ENT.Collision = true

ENT.TAH_Shop = true
ENT.TAH_SaveEntity = true
ENT.TextOffset = Vector(0, 0, 56)
ENT.Spawn_Offset = Vector(14, 0, 32.5)
ENT.Spawn_Angle = Angle(0, -90, 50)
ENT.Spawn_TimeFloating = 2
ENT.Spawn_Push = Vector(0, 12, 12) / ENT.Spawn_TimeFloating
ENT.Spawn_PushAngle = Vector(360, 0, 0) / ENT.Spawn_TimeFloating

DEFINE_BASECLASS(ENT.Base)

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "Enabled")
    self:NetworkVarNotify( "Enabled", self.OnToggleEnabled )
end

function ENT:OnToggleEnabled(name, old, new)
    if new then
        self:SetSkin(0)
        self.Visited = false
    else
        self:SetSkin(1)
    end
end

function ENT:Initialize()
    BaseClass.Initialize(self)

    table.insert(TAH.Shop_Cache, self)
end

function ENT:OnRemove()
    table.RemoveByValue(TAH.Shop_Cache, self)
end

if SERVER then
    function ENT:UpdateTransmitState()
        if self:GetEnabled() or TAH:GetRoundState() == TAH.ROUND_INACTIVE then
            return TRANSMIT_ALWAYS
        end
        return TRANSMIT_PVS
    end
end


function ENT:SetItems(tbl)
    self.Items = tbl
end

function ENT:Use(ply)
    if not self.Items or not self:GetEnabled() or TAH:GetRoundState() ~= TAH.ROUND_TAKE then return end
    net.Start("tah_shop")
        net.WriteEntity(self)
        net.WriteUInt(#self.Items, 4)
        for _, class in ipairs(self.Items) do
            net.WriteString(class)
        end
    net.Send(ply)
end

function ENT:GetShopSpawnMatrix()
    local spawn = Matrix()
    spawn:SetTranslation(self:GetPos())
    spawn:SetAngles(self:GetAngles())
    spawn:Translate(self.Spawn_Offset)
    spawn:Rotate(self.Spawn_Angle)
    return spawn
end

function ENT:GetShopSpawnVectors()
    local spawn = self:GetShopSpawnMatrix()
    return spawn:GetTranslation(), spawn:GetAngles()
end

function ENT:GetPushVectors()
    local spawn = self:GetShopSpawnMatrix()
    local spawn_inverse_translation = spawn:GetInverse():GetTranslation()
    local push = Matrix( spawn )
    push:Translate( self.Spawn_Push )
    push:Translate( spawn_inverse_translation )
    return push:GetTranslation(), self.Spawn_PushAngle
end

if SERVER then
    util.AddNetworkString("tah_shop_ItemBoughtHere")

    function ENT:ItemBoughtHere(ply, ent)
        local phys = ent:GetPhysicsObject()
        assert(phys:IsValid(), "spawned item physics object not valid")

        local push, pushangle = self:GetPushVectors()
        phys:EnableGravity( false )
        phys:SetMass( 50000 ) -- mass gets reset when a player drops it so i'm not too worried
        phys:AddVelocity( push )
        phys:AddAngleVelocity( pushangle )
        
        phys:EnableCollisions( false )
        timer.Simple(self.Spawn_TimeFloating - engine.TickInterval(), function()
            if not phys:IsValid() then return end
            phys:EnableCollisions( true )
        end)

        timer.Simple(self.Spawn_TimeFloating, function()
            if not phys:IsValid() then return end
            phys:EnableMotion( false )
            phys:EnableGravity( true )
            phys:Wake()
        end)

        -- gross timer to replicate item
        net.Start("tah_shop_ItemBoughtHere")
            net.WriteEntity(self)
            net.WriteUInt( ent:EntIndex(), MAX_EDICT_BITS )
        net.SendPVS(self:GetPos())
    end
end

if CLIENT then
    local COLOR_BLUE = Color( 0, 0, 127 )
    local COLOR_CYAN = Color( 0, 127, 127 )
    function ENT:Draw(flags)
        self:DrawModel(flags)
        if false then
            debugoverlay.Cross( self:GetPos(), 1, 0, color_white )
            debugoverlay.Cross( self:GetPos() + self.TextOffset, 1, 0, COLOR_BLUE )
            local pos, ang = self:GetShopSpawnVectors()
            local push, rot = self:GetPushVectors()
            debugoverlay.Axis(pos, ang, 16, 0)
            debugoverlay.Line(pos, pos + push, 0, COLOR_CYAN, true)
            debugoverlay.Cross(pos + push, 1, 0, COLOR_CYAN, true)
        end
    end

    net.Receive("tah_shop_ItemBoughtHere", function()
        local shop = net.ReadEntity()
        if not shop:IsValid() then print("tah_shop_ItemBoughtHere shop not valid") return end
        local item_index = net.ReadUInt( MAX_EDICT_BITS )
        timer.Simple(engine.TickInterval() + 0.001, function()
            local item = Entity( item_index )
            if not item:IsValid() then return end
            shop:ItemBoughtEffects(item)
        end)
    end)

    function ENT:ItemBoughtEffects(ent)
        local pos, ang = self:GetShopSpawnVectors()
        local edata = EffectData()
            edata:SetOrigin(pos)
            edata:SetNormal( ang:Right() * -1 )
            edata:SetRadius( ent:BoundingRadius() )
        util.Effect("AR2Explosion", edata)

        local edata = EffectData()
            edata:SetOrigin( ent:GetPos() )
            edata:SetEntity( ent )
        util.Effect("propspawn", edata)
        self:EmitSound("ambient/energy/powerdown2.wav")
        for i=0, 3, 0.5 do
            local fract = math.Clamp( math.Remap(i, 0, 3, 0, 1 ), 0, 1 )
            timer.Simple(i - math.random() * 0.5 * (1-fract), function()
                if not ent:IsValid() then return end
                ent:EmitSound("ambient/energy/spark" .. math.random(1, 6) .. ".wav")
                local edata = EffectData()
                edata:SetEntity(ent)
                edata:SetMagnitude(4)--10 * math.ease.InQuint( fract ))
                util.Effect("TeslaHitboxes", edata)

                local phys = ent:GetPhysicsObject()
                if not phys:IsValid() then return end
                phys:AddVelocity( VectorRand(-1, 1) * i )
                phys:AddAngleVelocity( VectorRand(0, 3) * i )

                local edata = EffectData()
                    edata:SetOrigin( ent:GetPos() )
                    edata:SetNormal( ent:GetRight() * -1 )
                    edata:SetMagnitude( .5 )
                    edata:SetScale( .5 )
                    edata:SetRadius( 4 )
                util.Effect("Sparks", edata)
            end)
        end
        timer.Simple(self.Spawn_TimeFloating, function()
            if not ent:IsValid() then return end
            local edata = EffectData()
                edata:SetOrigin( ent:GetPos() )
                edata:SetNormal( ent:GetRight() * -1 )
                edata:SetRadius( 32 )
            util.Effect("cball_explode", edata)
        end)
    end
end