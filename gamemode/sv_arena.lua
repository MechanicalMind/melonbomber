

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

function GM:IsGridPosClear(zone, x, y)
	local sq = zone.grid:getSquare(x, y)
	if IsValid(sq) && sq.gridSolid then return false end

	local center = (zone:OBBMins() + zone:OBBMaxs()) / 2
	local t = Vector(x * zone.grid.sqsize, y * zone.grid.sqsize) + center
	t.z = zone:OBBMins().z
	
	local s = zone.grid.sqsize / 2 - 1
	for k, ent in pairs(player.GetAll()) do
		if ent:Alive() then
			local mins, maxs = t + Vector(-s, -s, 0), t + Vector(s, s, 32)
			mins = mins - ent:OBBMaxs()
			maxs = maxs - ent:OBBMins()
			local pos = ent:GetPos()
			if pos.x > mins.x && pos.x < maxs.x then
				if pos.y > mins.y && pos.y < maxs.y then
					return false
				end
			end
		end
	end

	return true
end

function GM:CreateExplosion(zone, x, y, length, bomb, combiner)
	if bomb:GetPowerBomb() then
		sound.Play("npc/scanner/cbot_energyexplosion1.wav", bomb:GetPos(), 100, math.Rand(80, 120))
		sound.Play("BaseExplosionEffect.Sound", bomb:GetPos(), 100, math.Rand(80, 120))
		-- sound.Play("npc/roller/mine/rmine_explode_shock1.wav", bomb:GetPos(), 100, math.Rand(80, 120))
	else
		sound.Play("BaseExplosionEffect.Sound", bomb:GetPos(), 100, math.Rand(80, 120))
	end

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
			if sq:GetClass() == "mb_melon" || sq:GetClass() == "mb_pickup" || (sq.gridBreakable && bomb:GetPierce()) then
				// keep going if we have pierce and it was a box
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
			if sq:GetClass() == "mb_melon" || sq:GetClass() == "mb_pickup" || (sq.gridBreakable && bomb:GetPierce()) then
				// keep going if we have pierce and it was a box
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
			if sq:GetClass() == "mb_melon" || sq:GetClass() == "mb_pickup" || (sq.gridBreakable && bomb:GetPierce()) then
				// keep going if we have pierce and it was a box
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
			if sq:GetClass() == "mb_melon" || sq:GetClass() == "mb_pickup" || (sq.gridBreakable && bomb:GetPierce()) then
				// keep going if we have pierce and it was a box
			else
				break
			end
		else
			self:CombineExplosion(zone, x, y - i, bomb, combo)
		end
	end

	if !combiner then
		self:FinishExplosion(zone, combo, bomb:GetOwner())
	end
end

function GM:FinishExplosion(zone, combo, attacker)
	for k, v in pairs(combo.squares) do
		local x, y = k:match("([^:]+):([^:]+)")
		x = tonumber(x)
		y = tonumber(y)
		self:SpecificExplosion(zone, x, y, v, attacker)
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

function GM:SpecificExplosion(zone, x, y, bomb, attacker)
	local center = (zone:OBBMins() + zone:OBBMaxs()) / 2
	local t = Vector(x * zone.grid.sqsize, y * zone.grid.sqsize) + center
	t.z = zone:OBBMins().z

	local mag = 1
	if bomb:GetPowerBomb() then
		mag = 2
	end
	timer.Simple(0, function ()
		local eff = EffectData()
		eff:SetOrigin(t + Vector(0, 0, 15))
		eff:SetScale(zone.grid.sqsize / 2)
		eff:SetMagnitude(mag)
		util.Effect("pk_elecplosion", eff, true, true)
	end)

	local ent = zone.grid:getSquare(x, y)
	if IsValid(ent) then
		if ent.gridBreakable then
			self:GibCrate(ent)
			self:CreatePickup(ent)
			ent:Remove()
		elseif ent:GetClass() == "mb_pickup" then
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
						if IsValid(attacker) then
							dmg:SetAttacker(attacker)
						elseif IsValid(bomb:GetBombOwner()) then
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

	ent:EmitSound("physics/wood/wood_plank_break" .. math.random(1, 4) .. ".wav")
end

function GM:CreatePickup(ent)
	local zone, x, y = self:GetGridPosFromEnt(ent)
	if zone then
		if math.random(1, 3) == 1 then
			local random = WeightedRandom()
			for k, pickup in pairs(self.Pickups) do
				random:Add(pickup.Chance or 1, pickup.id)
			end
			local pick = self:CreatePowerup(random:Roll(), zone, x, y)
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
	zone.grid:setSquare(x, y, pick)
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
	t.z = zone:OBBMins().z
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

	ent:SetPos(t + Vector(0, 0, -ent:OBBMins().z))

	if ent:GetRemoteDetonate() then
		ent:EmitSound("npc/roller/mine/rmine_predetonate.wav", 65, 70)
	else
	end
		ent:EmitSound("npc/roller/blade_cut.wav", 65, 70)

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
			if ply.LastMoveKeyDown == IN_FORWARD then
				dir = Vector(0, 1, 0)
			elseif ply.LastMoveKeyDown == IN_BACK then
				dir = Vector(0, -1, 0)
			elseif ply.LastMoveKeyDown == IN_MOVELEFT then
				dir = Vector(-1, 0, 0)
			elseif ply.LastMoveKeyDown == IN_MOVERIGHT then
				dir = Vector(1, 0, 0)
			end
			ply:EmitSound("npc/scanner/scanner_nearmiss" .. math.random(1,2) .. ".wav")
			local placed = 0
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
				local center = (zone:OBBMins() + zone:OBBMaxs()) / 2
				local t = Vector(sx * zone.grid.sqsize, sy * zone.grid.sqsize) + center
				t.z = zone:OBBMins().z

				// don't place through players
				local shouldbreak = false
				for k, ent in pairs(player.GetAll()) do
					if ent != ply && ent:Alive() then
						local s = zone.grid.sqsize / 2 - 1
						local mins, maxs = t + Vector(-s, -s, 0), t + Vector(s, s, 32)
						mins = mins - ent:OBBMaxs()
						maxs = maxs - ent:OBBMins()
						local pos = ent:GetPos()
						if pos.x > mins.x && pos.x < maxs.x then
							if pos.y > mins.y && pos.y < maxs.y then
								shouldbreak = true
								break
							end
						end
					end
				end
				if shouldbreak then
					break
				end

				placed = placed + 1
				timer.Simple(placed * 0.15, function () self:CreateBomb(zone, sx, sy, ply, count) end)
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

function GM:LineBombThink()
	for k, ply in pairs(player.GetAll()) do
		lastkey = nil
		if ply:KeyDown(IN_FORWARD) then
			lastkey = IN_FORWARD
		end
		if ply:KeyDown(IN_BACK) then
			if lastkey then
				lastkey = nil
			else
				lastkey = IN_BACK
			end
		end
		if ply:KeyDown(IN_MOVELEFT) then
			if lastkey then
				lastkey = nil
			else
				lastkey = IN_MOVELEFT
			end
		end
		if ply:KeyDown(IN_MOVERIGHT) then
			if lastkey then
				lastkey = nil
			else
				lastkey = IN_MOVERIGHT
			end
		end
		if lastkey != nil then
			ply.LastMoveKeyDown = lastkey
		end
	end
end