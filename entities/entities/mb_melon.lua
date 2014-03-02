
AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )


ENT.PrintName		= "Melon"
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
		local i = 40
		-- self:PhysicsInitBox(Vector(-40, -40, -40), Vector(40, 40, 40))
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		
		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:Wake()
			-- phys:SetDamping(0.3, 0.3)
			-- local int = 0.0011
			-- phys:SetInertia(Vector(int,int,int))
			-- phys:SetMass(50)
		end
		
		self:SetHealth(1)

		self:SetUseType( SIMPLE_USE )

		self:PrecacheGibs()

		self.NoCollided = true
		self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		self:DrawShadow(false)
	else 
		
	end

	self.CreateTime = CurTime()
	self.ExplodeTime = CurTime() + 3
	
end

if ( CLIENT ) then

	function ENT:Draw()
		if !self.Melon then
			self.Melon = ClientsideModel("models/props_junk/watermelon01.mdl")
			self.Melon:SetNoDraw(true)
			self.Melon:SetAngles(AngleRand())
		end
		local left = (3 - (self.ExplodeTime - CurTime()) ) / 3
		self.Melon:SetModelScale(left * 0.2 + 1.2 + math.sin((CurTime() - self.CreateTime) * 4) * 0.15, 0)
		self.Melon:SetPos(self:GetPos() + Vector(0, 0, -18 + 6))
		self.Melon:DrawModel()
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

	if ( data.DeltaTime > 0.2 ) then
		sound.Play("physics/flesh/flesh_squishy_impact_hard" .. math.random(1, 4) .. ".wav", self:GetPos(), 75, math.random( 90, 120 ), math.Clamp( data.Speed / 450, 0, 1 ) )
	end
	
end

function ENT:OnTakeDamage( dmginfo )
	-- self:TakePhysicsDamage( dmginfo )
	-- local nh = self:Health() - dmginfo:GetDamage()
	-- if nh <= 0 then
	-- 	self:GibBreakClient(dmginfo:GetDamageForce())
	-- 	self:Remove()
	-- end
end

function ENT:Think()
	if SERVER then

		if self.NoCollided then
			local withinRange = false
			for k, ply in pairs(player.GetAll()) do
				if ply:Alive() then
					local t = self:GetPos() - ply:GetPos()
					// 18 is half block
					// 35 is half player width
					// 1 is hacky fix
					local d = 18 + 10 + 1
					if math.abs(t.x) < d && math.abs(t.y) < d then
						withinRange = true
						break
					end
				end
			end

			// if noone is standing on the bomb make it collide with players
			if !withinRange then
				self:SetCollisionGroup(COLLISION_GROUP_NONE)
			end
		end

		if self.ExplodeTime < CurTime() then
			self:Explode()
		end

		self:NextThink(CurTime() + 0.1)
		return true
	end
end

function ENT:Explode(zone, combiner)
	if self.HasExploded then return end
	self.HasExploded = true
	-- self:GibBreakClient(Vector(0, 0, 4))
	self:Remove()

	if zone then
		local x, y = GAMEMODE:GetGridPosFromEntZone(zone, self)
		if x then
			GAMEMODE:CreateExplosion(zone, x, y, self.ExplosionLength, self, combiner)
		end
	else
		local zone, x, y = GAMEMODE:GetGridPosFromEnt(self)
		if zone then
			GAMEMODE:CreateExplosion(zone, x, y, self.ExplosionLength, self)
		end
	end
end

// big chunks
// models/props_junk/watermelon01_chunk01a.mdl
// models/props_junk/watermelon01_chunk01b.mdl
// models/props_junk/watermelon01_chunk01c.mdl

// little chunks
// models/props_junk/watermelon01_chunk02a.mdl
// models/props_junk/watermelon01_chunk02b.mdl
// models/props_junk/watermelon01_chunk02c.mdl

function ENT:Use( ply, caller )
end

function ENT:GetBombOwner()
	return self.BombOwner
end

function ENT:SetBombOwner(ply)
	self.BombOwner = ply
end