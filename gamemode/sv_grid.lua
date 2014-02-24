
ClassGrid = class()
local Grid = ClassGrid

function Grid:initialize(sqsize, width, height)
	self.squares = {}
	self.width = width
	self.height = height
	self.sqsize = sqsize
end

function Grid:setSquare(x, y, abc)
	local str = x .. ":" .. y
	self.squares[str] = abc
end

function Grid:getSquare(x, y)
	local str = x .. ":" .. y
	return self.squares[str]
end

function Grid:checkSquare(x, y)
	if x < -self.width then return true end
	if x > self.width then return true end
	if y < -self.height then return true end
	if y > self.height then return true end
	return self:getSquare(x, y) != nil
end

function Grid:countEmptySquares(x1, y1, x2, y2)
	local c = 0
	for x = x1, x2 do
		for y = y1, y2 do
			if self:getSquare(x, y) == nil then
				c = c + 1
			end
		end
	end
	return c
end

function Grid:canAccess(x, y)
	if x < -self.width then return false end
	if x > self.width then return false end
	if y < -self.height then return false end
	if y > self.height then return false end
	local sq = self:getSquare(x, y)
	if sq == nil then return true end
	if sq.gridWalkable then return true end
	return false 
end

function Grid:generateAccessible()
	local walkable = Grid(self.sqsize)
	local todo = {}

	local function doit(x, y, pow)
		pow = pow or 0
		if self:canAccess(x, y) then
			local sq = walkable:getSquare(x, y)
			if !sq || sq.pow > pow + 1 then
				walkable:setSquare(x, y, {x = x, y = y, pow = pow + 1, sq = self:getSquare(x, y)})
				table.insert(todo, {x = x, y = y})
			end
		end
	end

	for i = -self.width, self.width do
		doit(i, -self.height)
		doit(i, self.height)
	end

	for i = -self.height + 1, self.height - 1 do
		doit(-self.width, i)
		doit(self.width, i)
	end


	local i = 1
	while true do
		local v = todo[i]
		if v then
			doit(v.x + 1, v.y, walkable:getSquare(v.x, v.y).pow)
			doit(v.x - 1, v.y, walkable:getSquare(v.x, v.y).pow)
			doit(v.x, v.y + 1, walkable:getSquare(v.x, v.y).pow)
			doit(v.x, v.y - 1, walkable:getSquare(v.x, v.y).pow)
		else
			break
		end
		i = i + 1
	end
	return walkable
end