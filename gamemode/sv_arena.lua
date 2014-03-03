

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
			if sq.gridBreakable && bomb:GetPierce() then

			else
				break
			end
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
			if sq.gridBreakable && bomb:GetPierce() then

			else
				break
			end
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
			if sq.gridBreakable && bomb:GetPierce() then

			else
				break
			end
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
			if sq.gridBreakable && bomb:GetPierce() then

			else
				break
			end
		else
			self:CombineExplosion(zone, x, y - i, bomb, combo)
		end
	end

	if !combiner then
		self:FinishExplosion(zone, combo)
	end
end

function GM:FinishExplosion(zone, combo)
	for k, v in pairs(combo.squares) do
		local x, y = k:match("([^:]+):([^:]+)")
		x = tonumber(x)
		y = tonumber(y)
		self:SpecificExplosion(zone, x, y, v)
	end
end

function GM:CombineExplosion(zone, x, y, bomb, combiner)
	combiner:setSquare(x, y, bomb)
	local center = (zone:OBBMins() + zone:OBBMaxs()) / 2
	local t = Vector(x * zone.grid.sqsize, y * zone.grid.sqsize) + center
	t.z = zone:OBBMins().z

	local ent = zone.grid:getSquare(x, y)
	if IsValid(ent) && ent:GetClass() == "mb_melon" then
		ent:Explode(zone, combiner)
	end
end

function GM:SpecificExplosion(zone, x, y, bomb)
	local center = (zone:OBBMins() + zone:OBBMaxs()) / 2
	local t = Vector(x * zone.grid.sqsize, y * zone.grid.sqsize) + center
	t.z = zone:OBBMins().z

	timer.Simple(0, function ()
		local eff = EffectData()
		eff:SetOrigin(t + Vector(0, 0, 15))
		eff:SetScale(zone.grid.sqsize / 2)
		util.Effect("pk_elecplosion", eff)
	end)

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
		local zone, x, y = self:GetGridPosFromEnt(ent)
		if zone then
			local pick = self:CreatePowerup(math.random(1, 3), zone, x, y)
			return pick
		end
	elseif math.random(1, 13) == 1 then
		local zone, x, y = self:GetGridPosFromEnt(ent)
		if zone then
			local pick = self:CreatePowerup(math.random(4, 7), zone, x, y)
			return pick
		end
	end
end

function GM:CreatePowerup(typ, zone, x, y)
	local mins, maxs = zone:OBBMins(), zone:OBBMaxs()
	local center = (mins + maxs) / 2
	local t = Vector(x * zone.grid.sqsize, y * zone.grid.sqsize) + center
	t.z = zone:OBBMins().z

	local pick = ents.Create("mb_pickup")
	pick:SetPos(t)
	pick:SetPickupType(typ)
	pick:Spawn()

	local phys = pick:GetPhysicsObject()
	if IsValid(phys) then
		phys:EnableMotion(false)
	end

	pick:SetPos(t + Vector(0, 0, -pick:OBBMins().z))
	return pick
end

function GM:PlayerPlaceBomb(ply)
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

		self:CreateBomb(zone, x, y, ply, count)
	end
end

function GM:CreateBomb(zone, x, y, owner, count)
	local center = (zone:OBBMins() + zone:OBBMaxs()) / 2
	local t = Vector(x * zone.grid.sqsize, y * zone.grid.sqsize) + center
	t.z = zone:OBBMins().z + 18
	local ent = ents.Create("mb_melon")
	ent:SetPos(t)
	ent:SetBombOwner(owner)
	ent:SetAngles(Angle(0, 0, 0))
	ent:SetExplosionLength(owner:GetBombPower())
	if owner:HasUpgrade(5) && count == 0 then
		ent:SetPowerBomb(true)
	else
		if owner:HasUpgrade(4) then
			ent:SetPierce(true)
		end
	end
	if owner:HasUpgrade(7) then
		ent:SetRemoteDetonate(true)
	end
	ent.gridSolid = true
	ent:Spawn()

	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then
		phys:EnableMotion(false)
	end

	zone.grid:setSquare(x, y, ent)
end

function GM:PlayerAltFire(ply)
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

	if count > 0 && ply:HasUpgrade(7) then
		for k, ent in pairs(ents.FindByClass("mb_melon")) do
			if ent:GetBombOwner() == ply then
				ent:Explode(zone, combo)
				break
			end
		end
	elseif ply:HasUpgrade(6) then
		local zone, x, y = self:GetGridPosFromEnt(ply)
		if zone then
			local dir = Angle(0, math.Round(ply:GetAngles().y / 90) * 90, 0):Forward()
			for i = 0, ply:GetMaxBombs() - count - 1 do
				local sx, sy = x + math.Round(dir.x) * i, y + math.Round(dir.y) * i 
				local sq = zone.grid:getSquare(sx, sy)
				if IsValid(sq) then
					if sq.gridSolid then
						break
					else
						sq:Remove()
					end
				end

				self:CreateBomb(zone, sx, sy, ply, count)
				count = count + 1
			end
		end
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
		for k, v in pairs(ply.Upgrades) do
			drops[v] = (drops[v] or 0) + 1
		end

		for k, v in pairs(drops) do
			for i = 1, v do
				local sq = table.Random(empty.squares)
				empty:setSquare(sq.x, sq.y, nil)

				local pick = self:CreatePowerup(k, zone, sq.x, sq.y)
			end
		end
		ply:ResetUpgrades()
	end
end