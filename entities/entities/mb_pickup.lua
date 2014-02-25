
AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )


ENT.PrintName		= "Pickup"
ENT.Author			= "Mechanical Mind"
ENT.Information		= ""
ENT.Category		= "Melons"

ENT.Editable			= true
ENT.Spawnable			= true
ENT.AdminOnly			= false
ENT.RenderGroup 		= RENDERGROUP_TRANSLUCENT


function ENT:SetupDataTables()

end

function ENT:SpawnFunction( ply, tr, ClassName )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 10
	
	local ent = ents.Create( ClassName )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	
	return ent
	
end


function ENT:Initialize()

	if ( SERVER ) then

		self:SetModel("models/hunter/blocks/cube075x075x075.mdl")

		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		
		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:Wake()
		end
		
		self:SetHealth(1)
		self:SetUseType( SIMPLE_USE )
		self:SetTrigger(true)
		self:PrecacheGibs()

		self:SetCollisionGroup(COLLISION_GROUP_WORLD)
		self:DrawShadow(false)
	else 
		
	end

	self.CreateTime = CurTime()
	self.ExplodeTime = CurTime() + 3
	
end

function ENT:SetPickupType(int)
	if GAMEMODE.Pickups && GAMEMODE.Pickups[int] then
		self.PickupType = int
		self:SetNWInt("pickupType", int)
	else
		self.PickupType = nil
		self:SetNWInt("pickupType", 0)
	end
end

function ENT:GetPickupType()
	if SERVER then
		return self.PickupType
	end
	return self:GetNWInt("pickupType", 0)
end

if ( CLIENT ) then

	local circle = Material("SGM/playercircle")
	function ENT:Draw()
		if GAMEMODE.Pickups then
			local pickup = GAMEMODE.Pickups[self:GetPickupType()]
			if pickup then
				if !self.Melon then
					self.Melon = ClientsideModel(pickup.model or "models/props_junk/watermelon01.mdl")
					self.Melon:SetNoDraw(true)
					-- self.Melon:SetAngles(AngleRand())
				end
				self.Melon:SetModelScale(1.1 + math.sin((CurTime() - self.CreateTime) * 1.2) * 0.05, 0)
				self.Melon:SetPos(self:GetPos() + Vector(0, 0, -18 + 6))
				self.Melon:DrawModel()

				local mins = self:OBBMins()

				render.SetMaterial(circle)
				local col = table.Copy(pickup.color)
				col.a = 120
				render.DrawQuadEasy(self:GetPos() + Vector(0, 0, mins.z), Vector(0,0, 1), 32, 32, col, 0)
			end
		else
			self:DrawModel()
		end
	end

end

function ENT:OnRemove()
	if CLIENT then
		if IsValid(self.Melon) then
			self.Melon:Remove()
		end
	end
end

function ENT:PhysicsCollide( data, physobj )

end

function ENT:OnTakeDamage( dmginfo )
end

function ENT:Think()
	if SERVER then

		self:NextThink(CurTime() + 0.1)
		return true
	end
end

function ENT:Use( ply, caller )
end

function ENT:StartTouch(ent)
	if IsValid(ent) && ent:IsPlayer() then
		local pickup = GAMEMODE.Pickups[self:GetPickupType()]
		if pickup then
			if pickup.OnPickup then
				pickup:OnPickup(ent)
			end
		end
		self:Remove()
	end
end