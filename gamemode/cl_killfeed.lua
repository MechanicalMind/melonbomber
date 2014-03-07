GM.KillFeed = {}


net.Receive("kill_feed_add", function (len)
	local ply = net.ReadEntity()
	local inflictor = net.ReadEntity()
	local attacker = net.ReadEntity()
	
	local t = {}
	t.time = CurTime()
	t.player = ply
	t.playerName = ply:Nick()
	local col = ply:GetPlayerColor()
	t.playerColor = Color(col.x * 255, col.y * 255, col.z * 255)
	t.inflictor = inflictor
	t.attacker = attacker
	if IsValid(attacker) && attacker:IsPlayer() && attacker != ply then
		t.attackerName = attacker:Nick()
		local col = attacker:GetPlayerColor()
		t.attackerColor = Color(col.x * 255, col.y * 255, col.z * 255)
		Msg(attacker:Nick() .. " killed " .. ply:Nick() .. "\n")
	else
		Msg(ply:Nick() .. " killed themself\n")
	end
	table.insert(GAMEMODE.KillFeed, t)	
end)

function GM:DrawKillFeed()
	local gap = draw.GetFontHeight("RobotoHUD-15") + 4
	local i = 0
	for k, t in pairs(self.KillFeed) do
		if t.time + 30 < CurTime() then
			self.KillFeed[k] = nil
		else
			surface.SetFont("RobotoHUD-15")
			local twp, thp = surface.GetTextSize(t.playerName)

			if t.attackerName then
				local killed = " killed "
				local twa, tha = surface.GetTextSize(t.attackerName)
				local twk, thk = surface.GetTextSize(killed)
				draw.ShadowText(t.attackerName, "RobotoHUD-15", ScrW() - 4 - twp - twk - twa, 4 + i * gap, t.attackerColor, 0)
				draw.ShadowText(killed, "RobotoHUD-15", ScrW() - 4 - twp - twk, 4 + i * gap, color_white, 0)
				draw.ShadowText(t.playerName, "RobotoHUD-15", ScrW() - 4 - twp, 4 + i * gap, t.playerColor, 0)
			else
				local killed = " killed themself"
				local twk, thk = surface.GetTextSize(killed)

				draw.ShadowText(killed, "RobotoHUD-15", ScrW() - 4 - twk, 4 + i * gap, color_white, 0)
				draw.ShadowText(t.playerName, "RobotoHUD-15", ScrW() - 4 - twp - twk, 4 + i * gap, t.playerColor, 0)
			end

			i = i + 1
		end
	end
end