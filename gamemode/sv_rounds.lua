
util.AddNetworkString("gamestate")

GM.GameState = GAMEMODE and GAMEMODE.GameState or 0
GM.StateStart = GAMEMODE and GAMEMODE.StateStart or CurTime()
GM.Rounds = GAMEMODE and GAMEMODE.Rounds or 0

team.SetUp(1, "Spectators", Color(150, 150, 150))

// STATES
// 0 WAITING FOR PLAYERS
// 1 STARTING ROUND
// 2 PLAYING
// 3 END GAME RESET TIME

function GM:GetGameState()
	return self.GameState
end

function GM:GetStateStart()
	return self.StateStart
end

function GM:GetStateRunningTime()
	return CurTime() - self.StateStart
end

function GM:GetPlayingPlayers()
	local players = {}
	for k, ply in pairs(player.GetAll()) do
		if ply:Team() != 1 && ply:GetNWBool("RoundInGame") then
			table.insert(players, ply)
		end
	end
	return players
end

function GM:SetGameState(state)
	self.GameState = state
	self.StateStart = CurTime()
	net.Start("gamestate")
	net.WriteUInt(self.GameState, 32)
	net.WriteDouble(self.StateStart)
	net.Broadcast()
end

function GM:StartRound()
	local c = 0
	for k, ply in pairs(player.GetAll()) do
		if ply:Team() != 1 then // ignore spectators
			c = c + 1
		end
	end
	if c < 2 then
		local ct = ChatText()
		ct:Add("Not enough players to start round")
		ct:SendAll()
		self:SetGameState(0)
		return
	end

	self:BalanceTeams(true)

	for k, ply in pairs(player.GetAll()) do
		if ply:Team() != 1 then // ignore spectators
			ply:SetNWBool("RoundInGame", true)
			ply:KillSilent()
			ply:Spawn()
		else
			ply:SetNWBool("RoundInGame", false)
		end
	end
	self:CleanupMap()
	local ct = ChatText()
	ct:Add("Round has started")
	ct:SendAll()
	self:SetGameState(1)
	self.Rounds = self.Rounds + 1
end

function GM:EndRound(reason)

	local winningTeam
	if reason == 1 then
		local ct = ChatText()
		ct:Add("Tie everybody loses")
		ct:SendAll()
	elseif reason == 2 then
		local ct = ChatText()
		ct:Add(team.GetName(2), team.GetColor(2))
		ct:Add(" win")
		ct:SendAll()
		winningTeam = 2
	elseif reason == 3 then
		local ct = ChatText()
		ct:Add(team.GetName(3), team.GetColor(3))
		ct:Add(" win")
		ct:SendAll()
		winningTeam = 3
	end

	for k, ply in pairs(self:GetPlayingPlayers()) do
		if ply:Team() == winningTeam then
			ply:AddMoney(2500)
		else
			ply:AddMoney(1000)
		end
	end
	self:SetGameState(3)
end

function GM:RoundsSetupPlayer(ply)
	// start off not participating
	ply:SetNWBool("RoundInGame", false)

	// send game state
	net.Start("gamestate")
	net.WriteUInt(self.GameState, 32)
	net.WriteDouble(self.StateStart)
	net.Send(ply)
end

function GM:CheckForVictory()
	local red, blue = 0, 0
	for k, ply in pairs(self:GetPlayingPlayers()) do
		if ply:Alive() then
			if ply:Team() == 2 then
				red = red + 1
			elseif ply:Team() == 3 then
				blue = blue + 1
			end
		end
	end
	if red == 0 && blue == 0 then
		self:EndRound(1)
		return
	end

	if red == 0 then
		self:EndRound(3)
		return
	end
	if blue == 0 then
		self:EndRound(2)
		return
	end
end

function GM:RoundsThink()
	if self:GetGameState() == 0 then
		local c = 0
		for k, ply in pairs(player.GetAll()) do
			if ply:Team() != 1 then // ignore spectators
				c = c + 1
			end
		end
		if c >= 2 then
			self:StartRound()
		end
	elseif self:GetGameState() == 1 then
		if self:GetStateRunningTime() > 5 then
			self:SetGameState(2)
		end
	elseif self:GetGameState() == 2 then
		self:CheckForVictory()
	elseif self:GetGameState() == 3 then
		if self:GetStateRunningTime() > 5 then
			self:StartRound()
		end
	end
end

function GM:DoRoundDeaths(ply, attacker)

end
