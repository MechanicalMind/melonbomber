map.name = "Rings"
map.description = "Rings of walls with a 2 wide gap in between"

local s = 3
function map:generateMap(grid)
	for x = grid.minx, grid.maxx do
		for y = grid.miny, grid.maxy do
			local px, py = math.abs(x), math.abs(y)
			if (px % s == 0 && py <= px) || (py % s == 0 && px <= py) then
				if x % s == 0 && y % s == 0 && px != py then
					local bg = math.max(px, py)
					local g = px == bg and py or px
					if ((g / s) + bg / s - 1) % 2 == 0 then
						grid:setHardBox(x, y)
					end
				else
					grid:setWall(x, y)
				end
			else
				if math.random(4) != 1 then
					grid:setBox(x, y)
				end
			end
		end 
	end
end