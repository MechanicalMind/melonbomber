local PlayerMeta = FindMetaTable("Player")

function PlayerMeta:ResetUpgrades()
	self.MaxBombs = 1
	self.RunningBoots = 1
	self.PowerUps = 1
	hook.Call("PlayerResetUpgrades", self)
	self:NetworkUpgrades()
end

function PlayerMeta:GetMaxBombs()
	return self.MaxBombs or 1
end

function PlayerMeta:SetMaxBombs(amo)
	self.MaxBombs = math.Clamp(amo or 1, 1, 9)
	self:NetworkUpgrades()
end

function PlayerMeta:GetRunningBoots()
	return self.RunningBoots or 1
end

function PlayerMeta:SetRunningBoots(amo)
	self.RunningBoots = math.Clamp(amo or 1, 1, 9)
	self:CalculateSpeed()
	self:NetworkUpgrades()
end

function PlayerMeta:GetBombPower()
	return self.PowerUps or 1
end

function PlayerMeta:SetBombPower(amo)
	self.PowerUps = math.Clamp(amo or 1, 1, 9)
	self:NetworkUpgrades()
end

util.AddNetworkString("melons_upgrades")
function PlayerMeta:NetworkUpgrades()
	net.Start("melons_upgrades")
	net.WriteUInt(self:GetRunningBoots(), 8)
	net.WriteUInt(self:GetMaxBombs(), 8)
	net.WriteUInt(self:GetBombPower(), 8)
	net.Send(self)
end