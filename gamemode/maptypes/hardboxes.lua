map.name = "Hard Boxes"

function map:generateMap(grid)
	for x = grid.minx, grid.maxx do
		for y = grid.miny, grid.maxy do
			if x % 2 == 0 && y % 2 == 0 then
				grid:setWall(x, y)
			else
				if math.random(4) != 1 then
					if math.random(1, 15) == 1 then
						grid:setHardBox(x, y)
					else
						grid:setBox(x, y)
					end
				end
			end
		end 
	end
end