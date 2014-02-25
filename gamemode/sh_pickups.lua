

GM.Pickups = {}
if GAMEMODE then GAMEMODE.Pickups = GM.Pickups end

local function addPickup(name, color, model)
	local tab = {}
	tab.name = name
	tab.color = color
	tab.model = model
	table.insert((GM or GAMEMODE).Pickups, tab)
	return tab
end

local pick = addPickup("Speed", Color(0,150,255), "models/props_junk/Shoe001a.mdl")
function pick:OnPickup(ply)
	ply:SetRunningBoots(ply:GetRunningBoots() + 1)
end


local pick = addPickup("Bomb Power", Color(220,50,50), "models/props_lab/cactus.mdl")
function pick:OnPickup(ply)
	ply:SetBombPower(ply:GetBombPower() + 1)
end


local pick = addPickup("Max Bombs", Color(50,255,50), "models/props_c17/TrapPropeller_Engine.mdl")
function pick:OnPickup(ply)
	ply:SetMaxBombs(ply:GetMaxBombs() + 1)
end