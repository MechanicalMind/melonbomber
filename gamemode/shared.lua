GM.Name 	= "Melonbomber"
GM.Author 	= "MechanicalMind"
// Credits to waddlesworth for the logo and icon
GM.Email 	= ""
GM.Website 	= "http://codingconcoctions.com/melonbomber/"
GM.Version 	= "1.3.1"
GM.GCCEntryID = 3

team.SetUp(1, "Spectators", Color(50, 50, 50))
team.SetUp(2, "Player", Color(150, 150, 150))

local up = Vector(0, 0, 1):Angle()

function GM:Move( ply, mv )

end

function GM:SetupMove(ply, mv)
end

function GM:FinishMove(ply, mv)

end

function GM:ShouldCollide(ent1, ent2)
	if !IsValid(ent1) then return true end
	if !IsValid(ent2) then return true end

	// nocollide melons you are standing on
	if ent1:IsPlayer() && ent2:GetClass() == "mb_melon" then
		if ent2:GetNWBool("MelonCollide" .. ent1:EntIndex()) then
			return true
		end
		return false
	end
	if ent2:IsPlayer() && ent1:GetClass() == "mb_melon" then
		if ent1:GetNWBool("MelonCollide" .. ent2:EntIndex()) then
			return true
		end
		return false
	end

	// nocollide players
	if ent1:IsPlayer() && ent2:IsPlayer() then
		return false
	end
	return true
end

function GM:PlayerSetNewHull(ply)
	local s = 20
	ply:SetHull(Vector(-s / 2, -s / 2, 0), Vector(s / 2, s / 2, 72))
	ply:SetHullDuck(Vector(-s / 2, -s / 2, 0), Vector(s / 2, s / 2, 36))
end