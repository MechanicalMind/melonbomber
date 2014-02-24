GM.Unlocks = {}
GM.WeaponLoadout = {}

function GM:HasUnlock(name)
	if self.Unlocks[name] then
		return true
	end
	return false
end

function GM:GetWeaponLoadout(name)
	return self.WeaponLoadout[name]
end

net.Receive("player_unlocks", function (len)
	GAMEMODE.Unlocks = {}
	while net.ReadUInt(8) != 0 do
		local name = net.ReadString()
		local v = net.ReadUInt(8) != 0
		GAMEMODE.Unlocks[name] = v
	end

	GAMEMODE:UpdateCustomMenu()
end)

net.Receive("player_weaponloadout", function (len)
	GAMEMODE.WeaponLoadout = {}
	while net.ReadUInt(8) != 0 do
		local name = net.ReadString()
		local v = net.ReadString()
		GAMEMODE.WeaponLoadout[name] = v
	end
	
	GAMEMODE:UpdateCustomMenu()
end)