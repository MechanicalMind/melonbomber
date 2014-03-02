
function EFFECT:Init( data )

	self.StartTime = CurTime()
	self.NextFlame = CurTime()

	self.pos = data:GetOrigin()
	self.Scale = data:GetScale()
			
	self.Emitter = ParticleEmitter( self.pos ) 

	for i = 1, 20 do
		
		local t = VectorRand() * self.Scale
		t.z = math.abs(t.z)
		local particle = self.Emitter:Add( "Effects/fire_embers" .. math.random(1,3), self.pos + t)
		particle:SetVelocity( VectorRand() * 0 )
		particle:SetDieTime( 0.4)
		particle:SetStartAlpha( 255 )
		particle:SetEndAlpha( 0 )
		particle:SetStartSize( math.Rand(8, 32) )
		particle:SetEndSize( 2 )   
		particle:SetRoll( math.random(0,360) )
		//particle:SetRollDelta( 0 )
		particle:SetColor( 255,255,255 )
		
		
	end
	
	for i = 1, 3 do
		
		local particle = self.Emitter:Add( "particle/particle_smokegrenade1", self.pos + VectorRand() * self.Scale / 2)
		particle:SetVelocity( VectorRand(0, 0, 10) )
		particle:SetDieTime( 4.2)
		particle:SetStartAlpha( 255 )
		particle:SetEndAlpha( 0 )
		particle:SetStartSize( 20 )
		particle:SetEndSize( 40 )   
		particle:SetRoll( math.random(0,360) )
		//particle:SetRollDelta( 0 )
		particle:SetColor( 150, 150, 150 )
		
	end
		
	
end

function EFFECT:Think( )
	if self.StartTime + 1 < CurTime() then
		self.Emitter:Finish()
		return false
	end

	if self.NextFlame + 0.1 < CurTime() then
		self.NextFlame = CurTime()

	end

	return true
end

function EFFECT:Render()
end
