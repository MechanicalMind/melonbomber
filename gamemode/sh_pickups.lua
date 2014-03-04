

GM.Pickups = {}
if GAMEMODE then GAMEMODE.Pickups = GM.Pickups end

local function addPickup(id, name, color, model)
	local tab = {}
	tab.id = id
	tab.name = name
	tab.color = color
	tab.model = model;
	(GM or GAMEMODE).Pickups[id] = tab
	return tab
end

local pick = addPickup(1, "Speed Up", Color(0, 150, 255), "models/props_junk/Shoe001a.mdl")
pick.AddScale = 1.3
pick.NoList = true
pick.Chance = 10
function pick:OnPickup(ply)
	ply:SetRunningBoots(ply:GetRunningBoots() + 1)
end

local pick = addPickup(2, "Power Up", Color(220,50,50), "models/props_junk/gascan001a.mdl")
pick.NoList = true
pick.Chance = 10
function pick:OnPickup(ply)
	ply:SetBombPower(ply:GetBombPower() + 1)
end


local pick = addPickup(3, "Bomb Up", Color(50,255,50), "models/props_junk/watermelon01.mdl")
pick.NoList = true
pick.Chance = 10
function pick:OnPickup(ply)
	ply:SetMaxBombs(ply:GetMaxBombs() + 1)
end

local pick = addPickup(4, "Piercing", Color(0, 70, 220), "models/props_junk/sawblade001a.mdl")
pick.AddScale = 0.6
pick.Chance = 1
function pick:OnPickup(ply)
end

local pick = addPickup(5, "Power Bomb", Color(155, 20, 80), "models/props_junk/watermelon01.mdl")
pick.ModelMaterial = "models/weapons/v_crowbar/crowbar_cyl"
pick.Chance = 1
function pick:OnPickup(ply)
end


local pick = addPickup(6, "Line Bomb", Color(150, 0, 180), "models/props_junk/watermelon01.mdl")
pick.Chance = 1
function pick:OnPickup(ply)
end
function pick:DrawDecor(ent)
	local part = ent:MakeDecorPart("melon2", "models/props_junk/watermelon01.mdl")
	if part then
		local ang = ent.Melon:GetAngles()
		part:SetAngles(ang)
		part:SetPos(ent:GetPos() + Vector(0, 0, 8 + 12))
		part:DrawModel()
	end
	local part = ent:MakeDecorPart("melon3", "models/props_junk/watermelon01.mdl")
end

local pick = addPickup(7, "Remote control", Color(220, 190, 0), "models/props_rooftop/roof_dish001.mdl")
pick.AddScale = 0.4
pick.Chance = 1
function pick:OnPickup(ply)
end


local pick = addPickup(8, "Bomb Kick", Color(250, 100, 0), "models/props_junk/Shoe001a.mdl")
pick.AddScale = 1.3
pick.Chance = 3
function pick:OnPickup(ply)
end

// remote detonation
// models/props_rooftop/roof_dish001.mdl