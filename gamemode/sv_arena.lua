

function GM:GetGridPosFromEnt(ent)
	for k, zone in pairs(ents.FindByClass("spawn_zone")) do
		local x, y = self:GetGridPosFromEntZone(zone, ent)
		if x then
			return zone, x, y
		end
	end
end

function GM:GetGridPosFromEntZone(zone, ent)
	local mins, maxs = zone:OBBMins(), zone:OBBMaxs()
	mins = mins + ent:OBBMins()
	maxs = maxs + ent:OBBMaxs()
	local pos = ent:GetPos()
	if pos.x > mins.x && pos.x < maxs.x then
		if pos.y > mins.y && pos.y < maxs.y then
			local center = (zone:OBBMins() + zone:OBBMaxs()) / 2
			local t = pos - center
			return math.Round(t.x / zone.grid.sqsize), math.Round(t.y / zone.grid.sqsize)
		end
	end
end

function GM:CreateExplosion(zone, x, y, length, bomb, combiner)
	local combo = combiner or ClassGrid()
	length = length or 1
	self:CombineExplosion(zone, x, y, bomb, combo)
	// x+
	for i = 1, length do
		local sq = zone.grid:getSquare(x + i, y)
		if IsValid(sq) then
			if sq.gridType != "wall" then
				self:CombineExplosion(zone, x + i, y, bomb, combo)
			end
			break
		else
			self:CombineExplosion(zone, x + i, y, bomb, combo)
		end
	end

	// x-
	for i = 1, length do
		local sq = zone.grid:getSquare(x - i, y)
		if IsValid(sq) then
			if sq.gridType != "wall" then
				self:CombineExplosion(zone, x - i, y, bomb, combo)
			end
			break
		else
			self:CombineExplosion(zone, x - i, y, bomb, combo)
		end
	end

	// y+
	for i = 1, length do
		local sq = zone.grid:getSquare(x, y + i)
		if IsValid(sq) then
			if sq.gridType != "wall" then
				self:CombineExplosion(zone, x, y + i, bomb, combo)
			end
			break
		else
			self:CombineExplosion(zone, x, y + i, bomb, combo)
		end
	end

	// y-
	for i = 1, length do
		local sq = zone.grid:getSquare(x, y - i)
		if IsValid(sq) then
			if sq.gridType != "wall" then
				self:CombineExplosion(zone, x, y - i, bomb, combo)
			end
			break
		else
			self:CombineExplosion(zone, x, y - i, bomb, combo)
		end
	end

	if !combiner then
		for k, v in pairs(combo.squares) do
			local x, y = k:match("([^:]+):([^:]+)")
			x = tonumber(x)
			y = tonumber(y)
			self:SpecificExplosion(zone, x, y, v)
		end
	end
end

function GM:CombineExplosion(zone, x, y, bomb, combiner)
	combiner:setSquare(x, y, bomb)
	local center = (zone:OBBMins() + zone:OBBMaxs()) / 2
	local t = Vector(x * zone.grid.sqsize, y * zone.grid.sqsize) + center
	t.z = zone:OBBMins().z

	-- for k, ent in pairs(ents.GetAll()) do
	-- 	local s = zone.grid.sqsize / 2 - 1
	-- 	local mins, maxs = t + Vector(-s, -s, 0), t + Vector(s, s, 32)
	-- 	mins = mins - ent:OBBMaxs()
	-- 	maxs = maxs - ent:OBBMins()
	-- 	local pos = ent:GetPos()
	-- 	if pos.x > mins.x && pos.x < maxs.x then
	-- 		if pos.y > mins.y && pos.y < maxs.y then
	-- 			if ent:GetClass() == "mb_melon" then
	-- 				ent:Explode(zone, combiner)
	-- 			end
	-- 		end
	-- 	end
	-- end

	local ent = zone.grid:getSquare(x, y)
	if IsValid(ent) && ent:GetClass() == "mb_melon" then
		ent:Explode(zone, combiner)
	end
end

function GM:SpecificExplosion(zone, x, y, bomb)
	local center = (zone:OBBMins() + zone:OBBMaxs()) / 2
	local t = Vector(x * zone.grid.sqsize, y * zone.grid.sqsize) + center
	t.z = zone:OBBMins().z

	local eff = EffectData()
	eff:SetOrigin(t + Vector(0, 0, 15))
	eff:SetScale(zone.grid.sqsize / 2)
	util.Effect("pk_elecplosion", eff)

	sound.Play("BaseExplosionEffect.Sound", t, 75, math.Rand(-80, 120))

	for k, ent in pairs(ents.FindByClass("mb_pickup")) do
		local s = zone.grid.sqsize / 2 - 1
		local mins, maxs = t + Vector(-s, -s, 0), t + Vector(s, s, 32)
		mins = mins - ent:OBBMaxs()
		maxs = maxs - ent:OBBMins()
		local pos = ent:GetPos()
		if pos.x > mins.x && pos.x < maxs.x then
			if pos.y > mins.y && pos.y < maxs.y then
				ent:Remove()
			end
		end
	end

	local ent = zone.grid:getSquare(x, y)
	if IsValid(ent) then
		if ent.gridBreakable then
			self:GibCrate(ent)
			self:CreatePickup(ent)
			ent:Remove()
		end
	end

	for k, ent in pairs(player.GetAll()) do
		local s = zone.grid.sqsize / 2 - 1
		local mins, maxs = t + Vector(-s, -s, 0), t + Vector(s, s, 32)
		mins = mins - ent:OBBMaxs()
		maxs = maxs - ent:OBBMins()
		local pos = ent:GetPos()
		if pos.x > mins.x && pos.x < maxs.x then
			if pos.y > mins.y && pos.y < maxs.y then
				if ent:Alive() then
					local dmg = DamageInfo()
					if IsValid(bomb) then
						dmg:SetInflictor(bomb)
						if IsValid(bomb:GetBombOwner()) then
							dmg:SetAttacker(bomb:GetBombOwner())
						else
							dmg:SetAttacker(bomb)
						end
						dmg:SetDamagePosition(bomb:GetPos())
						dmg:SetDamageForce((ent:GetShootPos() - bomb:GetPos()):GetNormal() * 10 )
					end
					dmg:SetDamage(400)
					ent:TakeDamageInfo(dmg)
				end
			end
		end
	end
end

function GM:GibCrate(ent)

	for i = 1, math.random(1, 3) do
		local i = math.random(1, 8)
		if i == 8 then i = 9 end
		local gib = ents.Create("prop_physics")
		gib:SetPos(ent:GetPos() + Vector(0, 0, 30))
		gib:SetModel("models/props_junk/wood_crate001a_chunk0" .. i .. ".mdl")
		gib:SetMaterial("models/props/CS_militia/roofbeams03")
		gib:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		gib:Spawn()
		gib:Fire("kill", "", math.Rand(3, 8))

		local phys = gib:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetVelocity(VectorRand() * 300)
		end
	end
end

function GM:CreatePickup(ent)
	if math.random(1, 3) == 1 then
		local pick = ents.Create("mb_pickup")
		pick:SetPos(ent:GetPos())
		pick:SetPickupType(math.random(1, 3))
		pick:Spawn()

		local phys = pick:GetPhysicsObject()
		if IsValid(phys) then
			phys:EnableMotion(false)
		end

		pick:SetPos(ent:GetPos() + Vector(0, 0, pick:OBBMins().z))
		return pick
	end
end

function GM:CreatePowerup(typ, pos)
	local pick = ents.Create("mb_pickup")
	pick:SetPos(pos)
	pick:SetPickupType(typ)
	pick:Spawn()

	local phys = pick:GetPhysicsObject()
	if IsValid(phys) then
		phys:EnableMotion(false)
	end

	pick:SetPos(pos + Vector(0, 0, -pick:OBBMins().z + 1))
	return pick
end

function GM:CreateBomb(ply)
	if !(self:GetGameState() == 2 || self:GetGameState() == 0) then return end
	if ply.BombLast && ply.BombLast + 0.05 > CurTime() then return end
	if ply.LastSpawnTime && ply.LastSpawnTime + 1 > CurTime() then return end
	ply.BombLast = CurTime()

	local count = 0
	for k, ent in pairs(ents.FindByClass("mb_melon")) do
		if ent:GetBombOwner() == ply then
			count = count + 1
		end
	end

	if count >= ply:GetMaxBombs() then
		return
	end

	local zone, x, y = self:GetGridPosFromEnt(ply)
	if zone then
		local sq = zone.grid:getSquare(x, y)
		if IsValid(sq) then return end

		local center = (zone:OBBMins() + zone:OBBMaxs()) / 2
		local t = Vector(x * zone.grid.sqsize, y * zone.grid.sqsize) + center
		t.z = zone:OBBMins().z + 18
		local ent = ents.Create("mb_melon")
		ent:SetPos(t)
		ent:SetBombOwner(ply)
		ent:SetAngles(Angle(0, 0, 0))
		ent:Spawn()
		ent.ExplosionLength = ply:GetBombPower()

		local phys = ent:GetPhysicsObject()
		if IsValid(phys) then
			phys:EnableMotion(false)
		end

		zone.grid:setSquare(x, y, ent)
	end

	
end

function GM:ArenaFindPlayerSpawn(ply)
	local has = {}
	for k, ent in pairs(ents.FindByClass("spawn_zone")) do
		if ent.walkable then
			table.insert(has, ent)
		end
	end
	if #has <= 0 then 
		return 
	end

	local zone = has[math.random(#has)]
	local jab = zone.walkable.sqsize

	local sq = table.Random(zone.walkable.squares)
	-- local sq = {x = math.random(-zone.width, zone.width - 1), y = math.random(-zone.height, zone.height - 1)}

	local mins, maxs = zone:OBBMins(), zone:OBBMaxs()
	local center = (mins + maxs) / 2

	local pos = center + Vector(jab, 0, 0) * sq.x  + Vector(0, jab, 0) * sq.y
	pos.z = mins.z + 4

	return pos, zone, sq

end

function GM:ClearBoxesAroundSquare(zone, x, y, len)
	len = len or 1

	local mins, maxs = zone:OBBMins(), zone:OBBMaxs()
	local center = (mins + maxs) / 2
	local s = zone.grid.sqsize * len - 2 + zone.grid.sqsize / 2
	local t = Vector(x * zone.grid.sqsize, y * zone.grid.sqsize) + center
	t.z = zone:OBBMins().z

	for k, ent in pairs(ents.FindByClass("prop_physics")) do
		local mins, maxs = t + Vector(-s, -s, mins.z), t + Vector(s, s, maxs.z)
		mins = mins - ent:OBBMaxs()
		maxs = maxs - ent:OBBMins()
		local pos = ent:GetPos()
		if pos.x > mins.x && pos.x < maxs.x then
			if pos.y > mins.y && pos.y < maxs.y then
				if ent.gridBreakable then
					ent:Remove()
				end
			end
		end
	end
end


function GM:ScatterPowerups(ply)

	local zone, x, y = self:GetGridPosFromEnt(ply)
	if zone then
		local empty = zone.grid:generateEmpty()

		local drops = {}
		drops[1] = ply:GetRunningBoots() - 1
		drops[2] = ply:GetBombPower() - 1
		drops[3] = ply:GetMaxBombs() - 1

		for k, v in pairs(drops) do
			for i = 1, v do
				local sq = table.Random(empty.squares)
				empty:setSquare(sq.x, sq.y, nil)

				local mins, maxs = zone:OBBMins(), zone:OBBMaxs()
				local center = (mins + maxs) / 2
				local t = Vector(sq.x * zone.grid.sqsize, sq.y * zone.grid.sqsize) + center
				t.z = zone:OBBMins().z

				local pick = self:CreatePowerup(k, t)
			end
		end
	end
end