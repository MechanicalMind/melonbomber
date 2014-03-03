

GM.Pickups = {}
if GAMEMODE then GAMEMODE.Pickups = GM.Pickups end

local function addPickup(id, name, color, model)
	local tab = {}
	tab.name = name
	tab.color = color
	tab.model = model;
	(GM or GAMEMODE).Pickups[id] = tab
	return tab
end

local pick = addPickup(1, "Speed", Color(0, 150, 255), "models/props_junk/Shoe001a.mdl")
function pick:OnPickup(ply)
	ply:SetRunningBoots(ply:GetRunningBoots() + 1)
end
function pick:CanPickup(ply)
	return ply:GetRunningBoots() < 9
end


local pick = addPickup(2, "Bomb Power", Color(220,50,50), "models/props_junk/gascan001a.mdl")
function pick:OnPickup(ply)
	ply:SetBombPower(ply:GetBombPower() + 1)
end
function pick:CanPickup(ply)
	return ply:GetBombPower() < 9
end


local pick = addPickup(3, "Max Bombs", Color(50,255,50), "models/props_junk/watermelon01.mdl")
function pick:OnPickup(ply)
	ply:SetMaxBombs(ply:GetMaxBombs() + 1)
end
function pick:CanPickup(ply)
	return ply:GetMaxBombs() < 9
end