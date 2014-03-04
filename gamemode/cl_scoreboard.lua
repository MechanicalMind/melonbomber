if IsValid(GAMEMODE.ScoreboardPanel) then
	GAMEMODE.ScoreboardPanel:Remove()
end

local menu

surface.CreateFont( "ScoreboardPlayer" , {
	font = "coolvetica",
	size = 32,
	weight = 500,
	antialias = true,
	italic = false
})

local function addPlayerItem(self, mlist, ply)

	local but = vgui.Create("DPanel")
	but.player = ply
	but.ctime = CurTime()
	but:SetTall(draw.GetFontHeight("RobotoHUD-20") + 4)


	function but:Paint(w, h)

		surface.SetDrawColor(color_black)
		-- surface.DrawOutlinedRect(0, 0, w, h)

		if IsValid(ply) && ply:IsPlayer() then
			local col = ply:GetPlayerColor()
			col = Color(col.x * 255, col.y * 255, col.z * 255)
			draw.ShadowText(ply:Ping(), "RobotoHUD-20", w - 4, 0, col, 2)

			draw.ShadowText(("|"):rep(math.min(10, ply:GetScore())) .. " " .. ply:GetScore(), "RobotoHUD-20", w / 2, 0, col, 0)

			draw.ShadowText(ply:Nick(), "RobotoHUD-20", 2, 0, col, 0)
		end
	end

	mlist:AddItem(but)
end

local function doPlayerItems(self, mlist)

	for k, ply in pairs(player.GetAll()) do
		local found = false

		for t,v in pairs(mlist:GetCanvas():GetChildren()) do
			if v.player == ply then
				found = true
				v.ctime = CurTime()
			end
		end

		if !found then
			addPlayerItem(self, mlist, ply)
		end
	end
	local del = false

	for t,v in pairs(mlist:GetCanvas():GetChildren()) do
		if !v.perm && v.ctime != CurTime() then
			v:Remove()
			del = true
		end
	end
	// make sure the rest of the elements are moved up
	if del then
		timer.Simple(0, function() mlist:GetCanvas():InvalidateLayout() end)
	end
end

local function makeTeamList(parent)
	local mlist
	local pnl = vgui.Create("DPanel", parent)
	pnl:DockPadding(0, 0, 0, 0)
	function pnl:Paint(w, h)
		surface.SetDrawColor(90, 90, 90, 255)
		surface.DrawRect(0, 0, w, h)

		surface.SetDrawColor(20, 20, 20)
		surface.DrawOutlinedRect(0, 0, w, h)
	end

	function pnl:Think()
		if !self.RefreshWait || self.RefreshWait < CurTime() then
			self.RefreshWait = CurTime() + 0.1
			doPlayerItems(self, mlist)

		end
	end

	-- local headp = vgui.Create("DPanel", pnl)
	-- headp:DockMargin(0,0,0,4)
	-- headp:Dock(TOP)
	-- headp:SetTall(draw.GetFontHeight("RobotoHUD-25"))
	-- function headp:Paint() 
	-- 	draw.ShadowText(team.GetName(pteam), "RobotoHUD-25", 0, 0, team.GetColor(pteam), 0)
	-- end

	mlist = vgui.Create("DScrollPanel", pnl)
	mlist:Dock(FILL)
	function mlist:Paint(w, h)
		
	end

	// child positioning
	local canvas = mlist:GetCanvas()
	canvas:DockPadding(0, 0, 0, 0)
	function canvas:OnChildAdded( child )
		child:Dock( TOP )
		child:DockMargin( 0,0,0,4 )
	end

	local head = vgui.Create("DPanel")
	head:SetTall(draw.GetFontHeight("RobotoHUD-20"))
	head.perm = true
	function head:Paint(w, h)
		draw.ShadowText("Name", "RobotoHUD-20", w - 4, 0, color_white, 2)

		draw.ShadowText("Score", "RobotoHUD-20", w / 2, 0, color_white, 0)

		draw.ShadowText("Ping", "RobotoHUD-20", 4, 0, color_white, 0)
	end
	mlist:AddItem(head)

	return pnl
end

function GM:ScoreboardRoundResults(results)
	self:ScoreboardShow()
	menu.ResultsPanel.Results = results
	menu.ResultsPanel:InvalidateLayout()
end

function GM:ScoreboardShow()
	if IsValid(menu) then
		menu:SetVisible(true)
	else
		menu = vgui.Create("DFrame")
		GAMEMODE.ScoreboardPanel = menu
		menu:SetSize(ScrW() * 0.8, ScrH() * 0.8)
		menu:Center()
		menu:MakePopup()
		menu:SetKeyboardInputEnabled(false)
		menu:SetDeleteOnClose(false)
		menu:SetDraggable(false)
		menu:ShowCloseButton(false)
		menu:SetTitle("")
		menu:DockPadding(8, 8, 8, 8)
		function menu:PerformLayout()
			if IsValid(menu.Cops) then
				menu.Cops:SetWidth(self:GetWide() * 0.5)
			end
		end

		function menu:Paint(w, h)
			surface.SetDrawColor(130, 130, 130, 255)
			surface.DrawRect(0, 0, w, h)

			surface.SetDrawColor(80, 80, 80, 255)
			surface.DrawOutlinedRect(0, 0, w, h)
		end

		menu.Credits = vgui.Create("DPanel", menu)
		menu.Credits:Dock(TOP)
		menu.Credits:DockMargin(0, 0, 0, 4)
		function menu.Credits:Paint(w, h) 
			surface.SetFont("RobotoHUD-25")
			local t = GAMEMODE.Name or ""
			local tw,th = surface.GetTextSize(t)
			draw.ShadowText(t, "RobotoHUD-25", 4, 0, Color(132, 199, 29), 0)

			draw.ShadowText("by Mechanical Mind version " .. tostring(GAMEMODE.Version or "error"), "RobotoHUD-15", 4 + tw + 24, h  * 0.9, Color(220, 220, 220), 0, 4)
		end

		function menu.Credits:PerformLayout()
			surface.SetFont("RobotoHUD-25")
			local w,h = surface.GetTextSize(GAMEMODE.Name or "")
			self:SetTall(h)
		end

		local results = vgui.Create("DPanel", menu)
		menu.ResultsPanel = results
		results:Dock(TOP)
		results:DockMargin(0,0,0,4)
		results:SetTall(draw.GetFontHeight("RobotoHUD-25"))
		function results:Paint(w, h)
			surface.SetDrawColor(90, 90, 90, 255)
			surface.DrawRect(0, 0, w, h)

			if self.Results then
				if self.Results.reason == 1 then
					draw.ShadowText("Round tied", "RobotoHUD-20", 4, 4, color_white, 0)

					local f20 = draw.GetFontHeight("RobotoHUD-20")
					draw.ShadowText("Everyone loses", "RobotoHUD-50", f20 + 4, f20 + 4, color_white, 0)
				elseif self.Results.reason == 2 then
					local col = self.Results.winnerColor
					col = Color(col.x * 255, col.y * 255, col.z * 255)

					surface.SetDrawColor(col)
					surface.DrawRect(0, 0, w, h)

					surface.SetDrawColor(50, 50, 50, 50)
					surface.DrawRect(0, h / 2, w, h / 2)

					local f20 = draw.GetFontHeight("RobotoHUD-20")
					draw.ShadowText("The winner is", "RobotoHUD-20", 4, 4, color_white, 0)

					surface.SetFont("RobotoHUD-50")
					local tw, th = surface.GetTextSize(self.Results.winnerName)

					draw.ShadowText(self.Results.winnerName, "RobotoHUD-50", f20 + 4, f20 + 4, color_white, 0)
				end
			end

			surface.SetDrawColor(20, 20, 20)
			surface.DrawOutlinedRect(0, 0, w, h)
		end

		function results:PerformLayout()
			if self.Results then
				local f20 = draw.GetFontHeight("RobotoHUD-20")
				local f50 = draw.GetFontHeight("RobotoHUD-50")
				self:SetTall(f20 + f50 + 8)
			else
				self:SetTall(0)
			end
		end

		menu.PlayerList = makeTeamList(menu)
		menu.PlayerList:Dock(FILL)
	end
end
function GM:ScoreboardHide()
	if GAMEMODE.GameState == 3 then
		return
	end
	if IsValid(menu) then
		menu.ResultsPanel.Results = nil
		menu.ResultsPanel:InvalidateLayout()
		menu:Close()
	end
end

function GM:HUDDrawScoreBoard()
end

