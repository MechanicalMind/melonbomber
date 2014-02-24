
GM.GameState = GAMEMODE and GAMEMODE.GameState or 0
GM.StateStart = GAMEMODE and GAMEMODE.StateStart or CurTime()

function GM:GetGameState()
	return self.GameState
end

function GM:GetStateStart()
	return self.StateStart
end

function GM:GetStateRunningTime()
	return CurTime() - self.StateStart
end

net.Receive("gamestate", function (len)
	GAMEMODE.GameState = net.ReadUInt(32)
	GAMEMODE.StateStart = net.ReadDouble()
end)