map.name = "All Boxes"

function map:generateMap(grid)
	for x = grid.minx, grid.maxx do
		for y = grid.miny, grid.maxy do
			if math.random(4) != 1 then
				grid:setBox(x, y)
			end
		end 
	end
end