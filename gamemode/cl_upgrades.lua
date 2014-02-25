
function GM:GetMaxBombs()
	return self.MaxBombs or 1
end

function GM:GetRunningBoots()
	return self.RunningBoots or 1
end

function GM:GetBombPower()
	return self.PowerUps or 1
end


net.Receive("melons_upgrades", function (len)
	GAMEMODE.RunningBoots = net.ReadUInt(8)
	GAMEMODE.MaxBombs = net.ReadUInt(8)
	GAMEMODE.PowerUps = net.ReadUInt(8)
end)