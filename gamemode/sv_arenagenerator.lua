
ClassGenerator = class()
local Gen = ClassGenerator

function Gen:initialize(grid, mins, maxs)
	self.containers = {}
	self.walls = {}
	self.doors = {}
	self.trees = {}
	self.decor = {}
	self.plants = {}
	self.grid = grid
	self.mins = mins
	self.maxs = maxs
	self.center = (maxs + mins) / 2
end

function Gen:spawnProp(pos, ang, mdl, opts)
	local ent = ents.Create("prop_physics")
	ent:SetPos(pos)
	ent:SetAngles(ang)
	ent:SetModel(mdl)
	ent:Spawn()
	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then
		if !opts || !opts.nofreeze then
			phys:EnableMotion(false)
		end
	end
	if !opts || !opts.nomotion then
		-- ent:SetMoveType(MOVETYPE_NONE)
	end
	local skins = ent:SkinCount()
	ent:SetSkin(math.random(skins))
	return ent
end

// 0 is neg y
// 1 is pos x
// 2 is pos y
// 3 is neg x

function Gen:createContainer(dir, x, y)
	local topLeft = Vector(0, -194 + self.grid.sqsize / 2, -61.384880)
	dir = math.Clamp(dir, 0, 3)
	local angles = Angle(0, dir * 90, 0)

	local add = self.center + Vector(self.grid.sqsize, 0, 0) * x  + Vector(0, self.grid.sqsize, 0) * y
	local jimmy = topLeft * 1
	jimmy:Rotate(angles)
	local pos = add + jimmy
	pos.z = self.mins.z
	local ent = self:spawnProp(pos, angles, "models/props_wasteland/cargo_container01.mdl")
	pos.z = pos.z - ent:OBBMins().z + math.Rand(-1,1)
	ent:SetPos(pos)

	ent.gridX = x
	ent.gridY = y
	ent.gridDir = dir
	ent.gridType = "cont"

	if math.random(0, 10) > 0 then
		local apos = pos * 1
		apos.z = apos.z + (ent:OBBMaxs() - ent:OBBMins()).z
		ent.crateAbove = self:spawnProp(apos, angles, "models/props_wasteland/cargo_container01.mdl")
		if math.random(0, 4) > 1 then
			local apos = pos * 1
			apos.z = apos.z + (ent:OBBMaxs() - ent:OBBMins()).z * 2
			ent.crateDoubleAbove = self:spawnProp(apos, angles, "models/props_wasteland/cargo_container01.mdl")
		end
	end

	-- print(ent:OBBMaxs(), ent:OBBMins())
	if dir == 0 then
		self.grid:setSquare(x, y, ent)
		self.grid:setSquare(x, y - 1, ent)
		self.grid:setSquare(x, y - 2, ent)
	elseif dir == 1 then
		self.grid:setSquare(x, y, ent)
		self.grid:setSquare(x + 1, y, ent)
		self.grid:setSquare(x + 2, y, ent)
	elseif dir == 2 then
		self.grid:setSquare(x, y, ent)
		self.grid:setSquare(x, y + 1, ent)
		self.grid:setSquare(x, y + 2, ent)
	elseif dir == 3 then
		self.grid:setSquare(x, y, ent)
		self.grid:setSquare(x - 1, y, ent)
		self.grid:setSquare(x - 2, y, ent)
	end
	table.insert(self.containers, ent)
	return ent
end


function Gen:canPlaceContainer(dir, x, y)
	if x < -self.grid.width then return false end
	if x > self.grid.width then return false end
	if y < -self.grid.height then return false end
	if y > self.grid.height then return false end
	dir = math.Clamp(dir, 0, 3)
	if dir == 0 then
		if self.grid:checkSquare(x, y) then return false end
		if self.grid:checkSquare(x, y - 1) then return false end
		if self.grid:checkSquare(x, y - 2) then return false end
		if self.grid:countEmptySquares(x - 1, y - 3, x + 1, y + 1) <= 12 then return false end
	elseif dir == 1 then
		if self.grid:checkSquare(x, y) then return false end
		if self.grid:checkSquare(x + 1, y) then return false end
		if self.grid:checkSquare(x + 2, y) then return false end
		if self.grid:countEmptySquares(x - 1, y - 1, x + 3, y + 1) <= 12 then return false end
	elseif dir == 2 then
		if self.grid:checkSquare(x, y) then return false end
		if self.grid:checkSquare(x, y + 1) then return false end
		if self.grid:checkSquare(x, y + 2) then return false end
		if self.grid:countEmptySquares(x - 1, y - 1, x + 1, y + 3) <= 12 then return false end
	elseif dir == 3 then
		if self.grid:checkSquare(x, y) then return false end
		if self.grid:checkSquare(x - 1, y) then return false end
		if self.grid:checkSquare(x - 2, y) then return false end
		if self.grid:countEmptySquares(x - 3, y - 1, x + 1, y + 1) <= 12 then return false end
	end
	return true
end

function Gen:isContainer(x, y)
	local ent = self.grid:getSquare(x, y)
	if IsValid(ent) && ent.gridType == "cont" then
		return true
	end
	return false
end



function Gen:createBox(x, y)
	local angles = Angle(0, 0, 0)

	local size = 20
	local add = self.center + Vector(self.grid.sqsize, 0, 0) * x  + Vector(0, self.grid.sqsize, 0) * y
	local pos = add * 1
	pos.z = self.mins.z

	local ent = self:spawnProp(pos, angles, "models/hunter/blocks/cube075x075x075.mdl")
	ent:SetMaterial("models/props/CS_militia/roofbeams03")
	local b = math.random(200, 255)
	ent:SetColor(Color(255, b, b))
	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then
	end
	local skins = ent:SkinCount()
	ent:SetSkin(math.random(skins))

	pos.z = pos.z - ent:OBBMins().z + math.Rand(0, 0.05) - 4
	ent:SetPos(pos)

	ent.gridX = x
	ent.gridY = y
	ent.gridType = "box"
	ent.gridWalkable = true
	ent.gridBreakable = true
	ent.gridSolid = true
	table.insert(self.plants, ent)

	self.grid:setSquare(x, y, ent)
	return ent
end

function Gen:createWall(x, y, t)
	local angles = Angle(0, 0, 90)

	local size = 20
	local add = self.center + Vector(self.grid.sqsize, 0, 0) * x  + Vector(0, self.grid.sqsize, 0) * y
	local pos = add * 1
	pos.z = self.mins.z

	local ent = self:spawnProp(pos, angles, "models/hunter/blocks/cube075x075x075.mdl")
	if t == 2 then
		ent:SetMaterial("models/props_c17/metalladder003")
	else
		ent:SetMaterial("models/props_canal/metalwall005b")
	end
	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then
	end
	local skins = ent:SkinCount()
	ent:SetSkin(math.random(skins))

	pos.z = pos.z - ent:OBBMins().z + math.Rand(-0.1, 0.1)
	ent:SetPos(pos)

	ent.gridX = x
	ent.gridY = y
	ent.gridType = "wall"
	ent.gridWalkable = false
	ent.gridSolid = true
	table.insert(self.plants, ent)

	self.grid:setSquare(x, y, ent)
	return ent
end

function Gen:generate()
	// containers
	-- for i = 1, (self.grid.width * self.grid.height) * 0.2 do
	-- 	local dir, x, y = math.random(0, 3), math.random(-self.grid.width, self.grid.width), math.random(-self.grid.height, self.grid.height)
	-- 	if self:canPlaceContainer(dir, x, y) then
	-- 		self:createContainer(dir, x, y)
	-- 	end
	-- end

	for i = 0, self.grid.width * self.grid.height * 2 * 2 - 1 do
		local x = i % (self.grid.width * 2) - self.grid.width
		local y = math.floor(i / (self.grid.width * 2)) - self.grid.height
		if x % 2 == 0 && y % 2 == 0 then
			self:createWall(x, y)
		else
			if math.random(4) != 1 then
				self:createBox(x, y)
			end
		end
	end
	for i = -self.grid.width - 1, self.grid.width do 
		self:createWall(i, -self.grid.height - 1, 2)
		self:createWall(i, self.grid.height, 2)
	end

	for i = -self.grid.height, self.grid.height - 1 do
		self:createWall(-self.grid.width - 1, i, 2)
		self:createWall(self.grid.width, i, 2)
	end



	local accessible = self.grid:generateAccessible()
	local squares = {}
	for k, v in pairs(accessible.squares) do
		if v.sq == nil then
			table.insert(squares, v)
		end
	end
	
	for i = 1, 10 do
		local sq = table.Random(squares)
		-- self:createPlant(sq.x, sq.y)
	end
end

// capture point
// models/props_combine/combinecrane002.mdl