

function GM:GetGridPosFromEnt(ent)
	for k, zone in pairs(ents.FindByClass("spawn_zone")) do
		local mins, maxs = zone:OBBMins(), zone:OBBMaxs()
		mins = mins + ent:OBBMins()
		maxs = maxs + ent:OBBMaxs()
		local pos = ent:GetPos()
		if pos.x > mins.x && pos.x < maxs.x then
			if pos.y > mins.y && pos.y < maxs.y then
				local center = (zone:OBBMins() + zone:OBBMaxs()) / 2
				local t = pos - center
				return zone, math.Round(t.x / zone.grid.sqsize), math.Round(t.y / zone.grid.sqsize)
			end
		end
	end
end

function GM:CreateExplosion(zone, x, y, length)
	length = length or 1
	self:SpecificExplosion(zone, x, y)
	// x+
	for i = 1, length do
		self:SpecificExplosion(zone, x + i, y)
		if IsValid(zone.grid:getSquare(x + i, y)) then
			break
		end
	end

	// x-
	for i = 1, length do
		self:SpecificExplosion(zone, x - i, y)
		if IsValid(zone.grid:getSquare(x - i, y)) then
			break
		end
	end

	// y+
	for i = 1, length do
		self:SpecificExplosion(zone, x, y + i)
		if IsValid(zone.grid:getSquare(x, y + i)) then
			break
		end
	end

	// y-
	for i = 1, length do
		self:SpecificExplosion(zone, x, y - i)
		if IsValid(zone.grid:getSquare(x, y - i)) then
			break
		end
	end
end

function GM:SpecificExplosion(zone, x, y)
	local center = (zone:OBBMins() + zone:OBBMaxs()) / 2
	local t = Vector(x * zone.grid.sqsize, y * zone.grid.sqsize) + center
	t.z = zone:OBBMins().z

	local eff = EffectData()
	eff:SetOrigin(t + Vector(0, 0, 15))
	util.Effect("pk_elecplosion", eff)
	-- util.Effect("AntlionGib", eff)

	sound.Play("BaseExplosionEffect.Sound", t, 75, math.Rand(-80, 120))

	for k, ent in pairs(ents.GetAll()) do
		local s = zone.grid.sqsize / 2 - 1
		local mins, maxs = t + Vector(-s, -s, 0), t + Vector(s, s, 32)
		mins = mins - ent:OBBMaxs()
		maxs = maxs - ent:OBBMins()
		local pos = ent:GetPos()
		if pos.x > mins.x && pos.x < maxs.x then
			if pos.y > mins.y && pos.y < maxs.y then
				if ent:GetClass() == "mb_melon" then
					ent:Explode()
				elseif ent.gridBreakable then
					ent:GibBreakClient(Vector(0, 0, 4))
					ent:Remove()
					-- ent:SetColor(Color(math.random(0,255),math.random(0,255),math.random(0,255)))
				elseif ent:IsPlayer() then
					if ent:Alive() then
						ent:Kill()
					end
				elseif ent:IsNPC() then
					ent:Kill()
				end
			end
		end
	end
end

function GM:CreateBomb(ply)
	if !(self:GetGameState() == 2 || self:GetGameState() == 0) then return end
	if ply.BombLast && ply.BombLast + 0.3 > CurTime() then return end
	ply.BombLast = CurTime()

	local zone, x, y = self:GetGridPosFromEnt(ply)
	if zone then
		local center = (zone:OBBMins() + zone:OBBMaxs()) / 2
		local t = Vector(x * zone.grid.sqsize, y * zone.grid.sqsize) + center
		t.z = zone:OBBMins().z + 18
		local ent = ents.Create("mb_melon")
		ent:SetPos(t)
		ent:SetBombOwner(ply)
		ent:SetAngles(Angle(0, 0, 0))
		ent:Spawn()

		local phys = ent:GetPhysicsObject()
		if IsValid(phys) then
			phys:EnableMotion(false)
		else
			ent:SetMoveType(MOVETYPE_NONE)
		end
	end

	
end