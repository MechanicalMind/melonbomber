local PlayerMeta = FindMetaTable("Player")

function PlayerMeta:ResetUpgrades()
	self.MaxBombs = 1
	self.RunningBoots = 1
	self.PowerUps = 1
	hook.Call("PlayerResetUpgrades", self)
end

function PlayerMeta:GetMaxBombs()
	return math.max(self.MaxBombs or 1, 1)
end

function PlayerMeta:SetMaxBombs(amo)
	self.MaxBombs = amo
end

function PlayerMeta:GetRunningBoots()
	return math.max(self.RunningBoots or 1, 1)
end

function PlayerMeta:SetRunningBoots(amo)
	self.RunningBoots = amo
	self:CalculateSpeed()
end

function PlayerMeta:GetBombPower()
	return math.max(self.PowerUps or 1, 1)
end

function PlayerMeta:SetBombPower(amo)
	self.PowerUps = amo
end