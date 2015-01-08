
include("sv_mapvote.lua")

MapTypes = {}

// inherit from _G
local meta = {}
meta.__index = _G
meta.__newindex = _G

local SGrid = class()
MapMakerGrid = SGrid

function SGrid:initialize(minx, miny, maxx, maxy)
	self.grid = {}
	self.minx = minx
	self.miny = miny
	self.maxx = maxx
	self.maxy = maxy
end

function SGrid:getEmpty(x, y)
	return self.grid[x .. ":" .. y] != nil
end

function SGrid:setWall(x, y)
	self.grid[x .. ":" .. y] = "w"
end

function SGrid:isWall(x, y)
	return self.grid[x .. ":" .. y] == "w"
end

function SGrid:setBox(x, y)
	self.grid[x .. ":" .. y] = "b"
end

function SGrid:isBox(x, y)
	return self.grid[x .. ":" .. y] == "b"
end

function SGrid:setHardBox(x, y)
	self.grid[x .. ":" .. y] = "h"
end

function SGrid:isHardBox(x, y)
	return self.grid[x .. ":" .. y] == "h"
end

function SGrid:setExplosiveBox(x, y)
	self.grid[x .. ":" .. y] = "e"
end

function SGrid:isExplosiveBox(x, y)
	return self.grid[x .. ":" .. y] == "e"
end

function SGrid:getPrintChar(x, y)
	local c = self.grid[x .. ":" .. y]
	if c == nil then return " " end
	if c == "w" then return "#" end
	if c == "b" then return "." end
	if c == "h" then return "&" end

	return "?"
end

function SGrid:print()
	local c = Color(150, 150, 150)
	for y = self.miny, self.maxy do
		for x = self.minx, self.maxx do
			MsgC(c, self:getPrintChar(x, y))
		end
		MsgC(c, "\n")
	end
end

local function loadMaps(rootFolder)
	local files, dirs = file.Find(rootFolder .. "*", "LUA")
	for k, v in pairs(files) do

		local tempG = {}
		tempG.map = {}
		setmetatable(tempG, meta)

		local name = v:sub(1, -5)
		local f = CompileFile(rootFolder .. v)
		if !f then
			return
		end
		setfenv(f, tempG)
		local b, err = pcall(f)

		local s = SERVER and "Server" or "Client"
		local b = SERVER and 90 or 0
		if !b then
			MsgC(Color(255, 50, 50 + b), s .. " loading map failed " .. name .. " from " .. rootFolder .. "\nError: " .. err .. "\n")
		else
			MsgC(Color(50, 255, 50 + b), s .. " loaded map " .. name .. " from " .. rootFolder .. "\n")
			tempG.map.key = name
			MapTypes[name] = tempG.map
			local path = "materials/melonbomber/maptypes/" .. name .. ".png"
			if file.Exists(path, "GAME") then
				resource.AddSingleFile(path)
			end
			-- local grid = MapMakerGrid(-10, -10, 10, 10)
			-- tempG.MAP:GenerateMap(grid)
			-- grid:print()
		end
	end
end

function GM:LoadMaps()
	loadMaps((GM or GAMEMODE).Folder:sub(11) .. "/gamemode/maptypes/")
	loadMaps("melonbomber/maptypes/")
end

GM:LoadMaps()