GM.KillFeed = {}


net.Receive("kill_feed_add", function (len)
	local ply = net.ReadEntity()
	local inflictor = net.ReadEntity()
	local attacker = net.ReadEntity()
	local damageType = net.ReadUInt(32)
	if !IsValid(ply) then return end

	local t = {}
	t.time = CurTime()
	t.player = ply
	t.playerName = ply:Nick()
	local col = ply:GetPlayerColor()
	t.playerColor = Color(col.x * 255, col.y * 255, col.z * 255)
	t.inflictor = inflictor
	t.attacker = attacker
	t.damageType = damageType

	t.text = {}
	if IsValid(attacker) && attacker:IsPlayer() && attacker != ply then
		local col = attacker:GetPlayerColor()
		col = Color(col.x * 255, col.y * 255, col.z * 255)
		table.insert(t.text, col)
		table.insert(t.text, attacker:GetName())
		table.insert(t.text, color_white)
		table.insert(t.text, " killed ")
		local col = ply:GetPlayerColor()
		col = Color(col.x * 255, col.y * 255, col.z * 255)
		table.insert(t.text, col)
		table.insert(t.text, ply:GetName())
	elseif t.damageType == DMG_AIRBOAT then
		table.insert(t.text, Color(170, 10, 10))
		table.insert(t.text, "Death blocks")
		table.insert(t.text, color_white)
		table.insert(t.text, " killed ")
		local col = ply:GetPlayerColor()
		col = Color(col.x * 255, col.y * 255, col.z * 255)
		table.insert(t.text, col)
		table.insert(t.text, ply:GetName())
	else
		local col = ply:GetPlayerColor()
		col = Color(col.x * 255, col.y * 255, col.z * 255)
		table.insert(t.text, col)
		table.insert(t.text, ply:GetName())
		table.insert(t.text, color_white)
		table.insert(t.text, " killed themself")
	end
	surface.SetFont("RobotoHUD-15")
	local w = 0
	local col = color_white
	for k, v in pairs(t.text) do
		if type(v) == "string" then
			local tw, th = surface.GetTextSize(v)
			w = w + tw
			MsgC(col, v)
		else
			col = v
		end
	end
	Msg("\n")
	t.textWidth = w

	table.insert(GAMEMODE.KillFeed, t)
end)

function GM:DrawKillFeed()
	local gap = draw.GetFontHeight("RobotoHUD-15") + 4
	local down = 0
	local k = 1
	while true do
		if k > #GAMEMODE.KillFeed then
			break
		end
		local t = GAMEMODE.KillFeed[k]
		if t.time + 30 < CurTime() then
			table.remove(self.KillFeed, k)
		else
			surface.SetFont("RobotoHUD-15")
			local twp, thp = surface.GetTextSize(t.playerName)

			if t.text then
				local x = 0
				local col = color_white
				for k, v in pairs(t.text) do
					if type(v) == "string" then
						local killed = " killed "
						local tw, th = surface.GetTextSize(v)
						draw.ShadowText(v, "RobotoHUD-15", ScrW() - 4 - t.textWidth + x, 4 + down * gap, col, 0)
						x = x + tw
					else
						col = v
					end
				end
			end

			down = down + 1
			k = k + 1
		end
	end
end

