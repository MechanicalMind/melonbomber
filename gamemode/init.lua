AddCSLuaFile("shared.lua")

local rootFolder = (GM or GAMEMODE).Folder:sub(11) .. "/gamemode/"

// add cs lua all the cl_ or sh_ files
local files, dirs = file.Find(rootFolder .. "*", "LUA")
for k, v in pairs(files) do
	if v:sub(1,3) == "cl_" || v:sub(1,3) == "sh_" then
		AddCSLuaFile(rootFolder .. v)
	end
end


include("shared.lua")
include("sh_class.lua")
include("sh_condef.lua")
include("sv_ragdoll.lua")
include("sv_chattext.lua")
include("sv_playercolor.lua")
include("sv_player.lua")
include("sv_realism.lua")
include("sv_rounds.lua")
include("sv_spectate.lua")
include("sv_respawn.lua")
include("sv_health.lua")
include("sv_grid.lua")
include("sv_upgrades.lua")
include("sv_arena.lua")
include("sv_arenagenerator.lua")
include("sh_pickups.lua")


util.AddNetworkString("clientIPE")
util.AddNetworkString("he_opencustommenu")

resource.AddFile("materials/mech/ring.vmt")
resource.AddFile("materials/mech/ring_thin.vmt")
resource.AddFile("resource/fonts/Roboto-Black.ttf")


function GM:Initialize() 
	self.DeathRagdolls = {}
end

function GM:InitPostEntity() 
	self:InitPostEntityAndMapCleanup()
end

util.AddNetworkString("spawn_zones")
function GM:InitPostEntityAndMapCleanup() 
	for k, ent in pairs(ents.GetAll()) do
		if ent:GetClass():find("door") then
			ent:Fire("unlock","",0)
		end
	end
	for k, ent in pairs(ents.FindByClass("spawn_zone")) do
		self:SetupSpawnZone(ent)
	end
	for k, ply in pairs(player.GetAll()) do
		if ply:Alive() then
			self:PlayerSelectSpawn(ply)
		end
	end
end


local jab = 35.6
function GM:SetupSpawnZone(zone)
	local players = self:GetPlayingPlayers()
	local amo = math.max(2, #players)

	local mins, maxs = zone:OBBMins(), zone:OBBMaxs()
	local size = maxs - mins

	local area = amo * 30

	local width = math.floor(size.x / jab / 2)
	local height = math.floor(size.y / jab / 2)
	local max = math.Round(math.sqrt(area))
	print("Max width and height " .. max)
	width = math.min(width, max)
	height = math.min(height, max)

	zone.grid = ClassGrid(jab, width, height)
	local generator = ClassGenerator(zone.grid, mins, maxs)

	generator:generate()

	zone.walkable = zone.grid:generateAccessible()
end

function GM:Think()
	self:RoundsThink()
	self:SpectateThink()
	self:LineBombThink()
end

function GM:ShutDown()
end

function GM:AllowPlayerPickup( ply, ent )
	return true
end

function GM:PlayerNoClip( ply )
	timer.Simple(0, function () ply:CalculateSpeed() end)
	return ply:IsSuperAdmin() || ply:GetMoveType() == MOVETYPE_NOCLIP
end

function GM:OnEndRound()

end

function GM:OnStartRound()
	
end

function GM:EntityTakeDamage( ent, dmginfo )
end

function file.ReadDataAndContent(path)
	local f = file.Read(path, "DATA")
	if f then return f end
	f = file.Read(GAMEMODE.Folder .. "/content/data/" .. path, "GAME")
	return f
end

function GM:OnReloaded()
	for k, ent in pairs(ents.FindByClass("spawn_zone")) do
		if ent.grid then
			setClass(ent.grid, ClassGrid)
		end
	end
end

function GM:CleanupMap()
	-- for k, ply in pairs(player.GetAll()) do
	-- 	if IsValid(ply:GetCSpectatee()) && ply:GetCSpectatee():GetClass() == "prop_ragdoll" then
	-- 		ply:UnCSpectate()
	-- 	end 
	-- end
	-- for k, ent in pairs(ents.FindByClass("prop_ragdoll")) do
	-- 	ent:Remove()
	-- end
	game.CleanUpMap()
	hook.Call("InitPostEntityAndMapCleanup", self)
	hook.Call("MapCleanup", self)
end

function GM:ShowSpare2(ply)
	net.Start("he_opencustommenu")
	net.Send(ply)
end