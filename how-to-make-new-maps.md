# How to create a custom map type for Melonbomber
### For advanced Lua programmers only

Create a .lua file in `garrysmod/lua/melonbomber/maptypes/`

Set the name and description for the map
```lua
map.name = "Classic"
map.description = "The classic map"
```

Write the map generator function
```lua
function map:generateMap(grid)
	for x = grid.minx, grid.maxx do
		for y = grid.miny, grid.maxy do
			if x % 2 == 0 && y % 2 == 0 then
				grid:setWall(x, y)
			else
				if math.random(4) != 1 then
					grid:setBox(x, y)
				end
			end
		end 
	end
end
```

Possible block types
```lua
setWall(x, y)
setBox(x, y)
setHardBox(x, y)
setExplosiveBox(x, y)
```

Place a 96 x 96 png image of your map in `garrysmod/materials/melonbomber/maptypes`
