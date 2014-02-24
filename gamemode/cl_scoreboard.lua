local menu

surface.CreateFont( "ScoreboardPlayer" , {
	font = "coolvetica",
	size = 32,
	weight = 500,
	antialias = true,
	italic = false
})

local function addPlayerItem(self, mlist, ply, pteam)

	local but = vgui.Create("DPanel")
	but.player = ply
	but.ctime = CurTime()
	but:SetTall(draw.GetFontHeight("RobotoHUD-20"))


	function but:Paint(w, h)

		surface.SetDrawColor(color_black)
		-- surface.DrawOutlinedRect(0, 0, w, h)

		if IsValid(ply) && ply:IsPlayer() then
			draw.ShadowText(ply:Ping(), "RobotoHUD-20", self:GetWide() - 2, 0, color_white, 2)

			draw.ShadowText(ply:Nick(), "RobotoHUD-20", 2, 0, color_white, 0)
		end
	end

	mlist:AddItem(but)
end

local function doPlayerItems(self, mlist, pteam)

	for k, ply in pairs(team.GetPlayers(pteam)) do
		local found = false

		for t,v in pairs(mlist:GetCanvas():GetChildren()) do
			if v.player == ply then
				found = true
				v.ctime = CurTime()
			end
		end

		if !found then
			addPlayerItem(self, mlist, ply, pteam)
		end
	end
	local del = false

	for t,v in pairs(mlist:GetCanvas():GetChildren()) do
		if v.ctime != CurTime() then
			v:Remove()
			del = true
		end
	end
	// make sure the rest of the elements are moved up
	if del then
		timer.Simple(0, function() mlist:GetCanvas():InvalidateLayout() end)
	end
end

local function makeTeamList(parent, pteam)
	local mlist
	local pnl = vgui.Create("DPanel", parent)
	pnl:DockPadding(2,2,2,2)
	function pnl:Paint(w, h)
	end

	function pnl:Think()
		if !self.RefreshWait || self.RefreshWait < CurTime() then
			self.RefreshWait = CurTime() + 0.1
			doPlayerItems(self, mlist, pteam)

		end
	end

	local headp = vgui.Create("DPanel", pnl)
	headp:DockMargin(0,0,0,4)
	headp:Dock(TOP)
	headp:SetTall(draw.GetFontHeight("RobotoHUD-25"))
	function headp:Paint() 
		draw.ShadowText(team.GetName(pteam), "RobotoHUD-25", 0, 0, team.GetColor(pteam), 0)
	end

	local but = vgui.Create("DButton", headp)
	but:Dock(RIGHT)
	but:SetText("")
	surface.SetFont("RobotoHUD-20")
	local tw, th = surface.GetTextSize("Join")
	but:SetWide(tw + 4)
	function but:DoClick()
		RunConsoleCommand("car_jointeam", pteam)
	end
	function but:Paint(w, h)
		surface.SetDrawColor(team.GetColor(pteam))
		-- surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(color_black)
		-- surface.DrawOutlinedRect(0, 0, w, h)

		local col = table.Copy(team.GetColor(pteam))
		if self:IsDown() then
			surface.SetDrawColor(50,50,50,120)
			-- surface.DrawRect(1, 1, w - 2, h - 2)
			col.r = col.r * 0.8
			col.g = col.g * 0.8
			col.b = col.b * 0.8
		elseif self:IsHovered() then
			surface.SetDrawColor(255,255,255,30)
			-- surface.DrawRect(1, 1, w - 2, h - 2)
			col.r = col.r * 1.2
			col.g = col.g * 1.2
			col.b = col.b * 1.2
		end
		draw.ShadowText("Join", "RobotoHUD-20", 2, h / 2 - th / 2, col, 0)
	end

	mlist = vgui.Create("DScrollPanel", pnl)
	mlist:Dock(FILL)
	function mlist:Paint(w, h)
		draw.RoundedBox(4, 0, 0, w, h, Color(20,20,20,160))
	end

	// child positioning
	local canvas = mlist:GetCanvas()
	canvas:DockPadding(4, 4, 4, 4)
	function canvas:OnChildAdded( child )
		child:Dock( TOP )
		child:DockMargin( 0,0,0,4 )
	end

	return pnl
end


function GM:ScoreboardShow()
	if IsValid(menu) then
		menu:SetVisible(true)
	else
		menu = vgui.Create("DFrame")
		menu:SetSize(ScrW() * 0.8, ScrH() * 0.8)
		menu:Center()
		menu:MakePopup()
		menu:SetKeyboardInputEnabled(false)
		menu:SetDeleteOnClose(false)
		menu:SetDraggable(false)
		menu:ShowCloseButton(false)
		menu:SetTitle("")
		menu:DockPadding(4,4,4,4)
		function menu:PerformLayout()
			if IsValid(menu.Cops) then
				menu.Cops:SetWidth(self:GetWide() * 0.5)
			end
		end

		function menu:Paint(w, h)
			-- draw.RoundedBox(4, 0, 0, w, h, Color(20,20,20,160))
		end

		menu.Cops = makeTeamList(menu, 2)
		menu.Cops:Dock(LEFT)
		menu.Robbers = makeTeamList(menu, 3)
		menu.Robbers:Dock(FILL)
	end
end
function GM:ScoreboardHide()
	if IsValid(menu) then
		menu:Close()
	end
end

function GM:HUDDrawScoreBoard()
end

