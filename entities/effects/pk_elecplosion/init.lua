
function EFFECT:Init( data )

	local pos = data:GetOrigin()
	
	//sound.Play( "weapons/explode"..math.random(3,5).. ".wav", pos, 90, 130 )
	-- sound.Play( "npc/roller/mine/rmine_explode_shock1.wav", pos, 90, 130 )
		
	local emitter = ParticleEmitter( pos ) 
	
		for i = 1, 20 do
			
			local t = VectorRand() * 20
			t.z = math.abs(t.z)
			local particle = emitter:Add( "Effects/fire_embers" .. math.random(1,3), pos + t)
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
			
			local particle = emitter:Add( "particle/particle_smokegrenade1", pos + VectorRand() * 10)
			particle:SetVelocity( VectorRand(0, 0, 10) )
			particle:SetDieTime( 4.2)
			particle:SetStartAlpha( 255 )
			particle:SetEndAlpha( 0 )
			particle:SetStartSize( 20 )
			particle:SetEndSize( 40 )   
			particle:SetRoll( math.random(0,360) )
			//particle:SetRollDelta( 0 )
			particle:SetColor( 150, 150, 150 )
			
			-- local particle = emitter:Add( "particle/sparkles", pos)
			-- particle:SetVelocity( VectorRand() * 20 )
			-- particle:SetDieTime( 2.6)
			-- particle:SetStartAlpha( 50 )
			-- particle:SetEndAlpha( 0 )
			-- particle:SetStartSize( 30 )
			-- particle:SetEndSize( 70 )   
			-- particle:SetRoll( 0 )
			-- particle:SetRollDelta( 0 )
			-- particle:SetColor( 220,150, 150 )
		end
		
	emitter:Finish()
	
end

function EFFECT:Think( )
	return false
end

function EFFECT:Render()
end
