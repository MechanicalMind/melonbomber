if GAMEMODE && IsValid(GAMEMODE.EndRoundPanel) then
	GAMEMODE.EndRoundPanel:Remove()
end

local menu

local muted = Material("icon32/muted.png")
local unmuted = Material("icon32/unmuted.png")
local grad = surface.GetTextureID("gui/center_gradient")
local score = Material("icon16/flag_yellow.png")
local ping = Material("icon16/transmit_blue.png")

local function addPlayerItem(self, mlist, ply)

	local but = vgui.Create("DButton")
	but.player = ply
	but.ctime = CurTime()
	but:SetTall(32)
	but:SetText("")

	local avatar = vgui.Create("AvatarImage", but)
	avatar:Dock(LEFT)
	avatar:SetWide(32)
	avatar:SetPlayer(ply)
	function avatar:DoClick() but:DoClick() end

	
	function but:Paint(w, h)

		if menu.Results && ply == menu.Results.winner then
			surface.SetDrawColor(70, 50, 10, 241)
		else
			surface.SetDrawColor(30, 30, 30, 241)
		end
		surface.DrawRect(0, 0, w, h)

		surface.SetTexture(grad)
		surface.SetDrawColor(150, 150, 150, 10)
		if menu.Results && ply == menu.Results.winner then
			surface.SetDrawColor(255, 223, 0, 30)
		else
			surface.SetDrawColor(150, 150, 150, 10)
		end
		surface.DrawTexturedRectRotated(w / 2, h / 2, h, w, 90)

		if IsValid(ply) && ply:IsPlayer() then
			local col = ply:GetPlayerColor()
			col = Color(col.x * 255, col.y * 255, col.z * 255)
			
			surface.SetDrawColor(col.r, col.g, col.b, 255)
			surface.DrawRect(w - 32, 0, 32, h)

			surface.SetTexture(grad)
			surface.SetDrawColor(255, 255, 255, 10)
			surface.DrawTexturedRectRotated(w - 16, h / 2, 32, 32, 90)

			local s = 32 + 4
			if ply:IsSpeaking() then

				local v = ply:VoiceVolume()

				local x, y = self:LocalToScreen(0, 0)
				render.SetScissorRect(x, y, x + s + 32 * (0.5 + v / 2), y + h, true)

				// draw mute icon
				surface.SetMaterial(unmuted)
				surface.SetDrawColor(255, 255, 255, 255)
				-- surface.SetDrawColor(255, 255, 255, 255 * math.Clamp(v, 0.1, 1))
				surface.DrawTexturedRect(s, h / 2 - 16, 32, 32)
				s = s + 32 + 4

				render.SetScissorRect(0, 0, 0, 0, false)
			end

			if ply:IsMuted() then

				// draw mute icon
				surface.SetMaterial(muted)
				surface.SetDrawColor(255, 255, 255, 255)
				surface.DrawTexturedRect(s, h / 2 - 16, 32, 32)
				s = s + 32 + 4
			end

			// render ping icon
			surface.SetMaterial(ping)
			surface.SetDrawColor(255, 255, 255, 255)
			surface.DrawTexturedRect(w * 0.8, h / 2 - 8, 16, 16)

			// draw ping
			draw.SimpleText(ply:Ping(), "RobotoHUD-L16", w * 0.8 + 4 + 16, h / 2, color_white, 0, 1)

			surface.SetMaterial(score)
			surface.SetDrawColor(255, 255, 255, 255)
			surface.DrawTexturedRect(w * 0.6, h / 2 - 8, 16, 16)

			draw.SimpleText(ply:GetScore(), "RobotoHUD-L16", w * 0.6 + 16 + 4, h / 2, Color(247, 223, 84), 0, 1)

			draw.SimpleText(ply:Nick(), "RobotoHUD-16", s, h / 2, color_white, 0, 1)
		end
	end

	function but:DoClick()
		if IsValid(ply) then
			GAMEMODE:DoScoreboardActionPopup(ply)
		end
	end

	mlist:AddItem(but)
end

local function doPlayerItems(self, mlist)

	local add = false
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
			add = true
		end
	end
	local del = false

	for t,v in pairs(mlist:GetCanvas():GetChildren()) do
		if !v.perm && v.ctime != CurTime() then
			v:Remove()
			del = true
		end
	end
	// make sure the rest of the elements are sorted and moved up to fill gaps
	if del || add then
		timer.Simple(0, function() 
			local childs = mlist:GetCanvas():GetChildren()
			table.sort(childs, function (a, b)
				if !IsValid(a) then return false end
				if !IsValid(b) then return false end
				if !IsValid(a.player) then return false end
				if !IsValid(b.player) then return false end
				return a.player:Team() * 1000 + a.player:EntIndex() < b.player:Team() * 1000 + b.player:EntIndex()
			end)
			
			for k, v in pairs(childs) do
				v:SetParent(mlist)
			end
			mlist:GetCanvas():InvalidateLayout() 
		end)
	end
end

concommand.Add("ph_endroundmenu_close", function ()
	if IsValid(menu) then
		menu:Close()
	end
end)

function GM:OpenEndRoundMenu()
	chat.Close()
	if IsValid(menu) then
		menu.ChatTextEntry:SetText("")
		menu:SetVisible(true)
		return
	end
	self:CreateEndRoundMenu()
	menu:SetVisible(true)
end

function GM:CreateEndRoundMenu()
	if IsValid(menu) then
		return
	end

	menu = vgui.Create("DFrame")
	menu:ParentToHUD()
	GAMEMODE.EndRoundPanel = menu
	local t = ScrH() * 0.05
	menu:SetSize(ScrW() - t * 2, ScrH() - t * 2)
	menu:Center()
	menu:SetTitle("")
	menu:MakePopup()
	menu:SetKeyboardInputEnabled(false)
	menu:SetDeleteOnClose(false)
	menu:SetDraggable(false)
	menu:ShowCloseButton(false)
	menu:DockPadding(8, 8, 8, 8)
	menu:SetVisible(false)

	local matBlurScreen = Material( "pp/blurscreen" )
	function menu:Paint(w, h)
		DisableClipping(true)

		local x, y = self:LocalToScreen( 0, 0 )

		local Fraction = 0.4

		surface.SetMaterial( matBlurScreen )	
		surface.SetDrawColor( 255, 255, 255, 255 )

		for i=0.33, 1, 0.33 do
			matBlurScreen:SetFloat( "$blur", Fraction * 5 * i )
			matBlurScreen:Recompute()
			if ( render ) then render.UpdateScreenEffectTexture() end
			surface.DrawTexturedRect( x * -1, y * -1, ScrW(), ScrH() )
		end
		
		surface.SetDrawColor(50, 50, 50, 135)
		surface.DrawRect(-x, -y, ScrW(), ScrH())

		DisableClipping(false)
	end

	local leftpnl = vgui.Create("DPanel", menu)
	leftpnl:Dock(LEFT)
	function leftpnl:PerformLayout()
		self:SetWide(menu:GetWide() * 0.4)
	end
	function leftpnl:Paint(w, h)
	end

	// player list section
	local listpnl = vgui.Create("DPanel", leftpnl)
	listpnl:Dock(FILL)
	listpnl:DockPadding(10, 10, 10, 10)
	function listpnl:Paint(w, h)
		surface.SetDrawColor(120, 120, 120, 241)
		surface.DrawRect(0, 0, w, h)

		surface.SetTexture(grad)
		surface.SetDrawColor(255, 255, 255, 30)
		surface.DrawTexturedRectRotated(w / 2, h / 2, h, w, 90)
	end


	local plist = vgui.Create("DScrollPanel", listpnl)
	menu.PlayerList = plist
	plist:Dock(FILL)
	function plist:Paint(w, h)

	end

	function plist:Think()
		if !self.RefreshWait || self.RefreshWait < CurTime() then
			self.RefreshWait = CurTime() + 0.1
			doPlayerItems(self, plist)

		end
	end

	local canvas = plist:GetCanvas()
	canvas:DockPadding(0, 0, 0, 0)
	function canvas:OnChildAdded( child )
		child:Dock(TOP)
		child:DockMargin(0, 0, 0, 4)
	end

	// chat section
	local pnl = vgui.Create("DPanel", leftpnl)
	pnl:Dock(BOTTOM)
	pnl:DockMargin(0, 20, 0, 0)
	pnl:DockPadding(10, 10, 10, 10)
	function pnl:PerformLayout()
		self:SetTall(leftpnl:GetTall() * 0.5)
	end

	function pnl:Paint(w, h)
		surface.SetDrawColor(30, 30, 30, 252)
		surface.DrawRect(0, 0, w, h)
		
		surface.SetTexture(grad)
		surface.SetDrawColor(90, 90, 90, 20)
		surface.DrawTexturedRectRotated(w / 2, h / 2, h, w, 90)
	end


	local sayPnl = vgui.Create("DPanel", pnl)
	sayPnl:Dock(BOTTOM)
	sayPnl:DockPadding(4, 4, 4, 4)
	sayPnl:SetTall(draw.GetFontHeight("RobotoHUD-15") + 8)

	local entry = vgui.Create("DTextEntry", sayPnl)

	function sayPnl:Paint(w, h)
		if entry.Focused then
			surface.SetDrawColor(20, 20, 20, 190)
		else
			surface.SetDrawColor(50, 50, 50, 190)
		end
		surface.DrawRect(0, 0, w, h)
	end

	local say = vgui.Create("DLabel", sayPnl)
	say:Dock(LEFT)
	say:SetFont("RobotoHUD-15")
	say:SetTextColor(Color(220, 220, 220))
	say:SetText("Say:")
	say:DockMargin(4, 0, 0, 0)
	say:SizeToContentsX()

	entry:Dock(FILL)
	menu.ChatTextEntry = entry
	entry:SetFont("RobotoHUD-15")
	entry:SetTextColor(color_white)
	function entry:OnEnter(...)
		self.Focused = true
		RunConsoleCommand("say", self:GetValue())
		self:SetText("")
		timer.Simple(0, function ()
			menu:SetKeyboardInputEnabled(true)
			self:RequestFocus()
			self.Focused = true
		end)
	end
	local colCursor = Color(255, 0, 0)
	local colText = Color(180, 180, 180)
	function entry:Paint(w, h)
		self:DrawTextEntryText( self.Focused and color_white or colText, self.m_colHighlight, colCursor )
	end
	function entry:OnGetFocus()
		self.Focused = true
		menu:SetKeyboardInputEnabled(true)
	end
	function entry:OnLoseFocus()
		self.Focused = false
		menu:SetKeyboardInputEnabled(false)
	end


	local mlist = vgui.Create("DScrollPanel", pnl)
	menu.ChatList = mlist
	mlist:Dock(FILL)
	function mlist:Paint(w, h)
		
	end

	local canvas = mlist:GetCanvas()
	canvas:DockPadding(0, 0, 0, 0)
	function canvas:OnChildAdded( child )
		child:Dock(TOP)
		child:DockMargin(0, 0, 0, 1)
	end

	function mlist.VBar:SetUp( _barsize_, _canvassize_ )

		local oldSize = self.CanvasSize

		self.BarSize 	= _barsize_
		self.CanvasSize = math.max( _canvassize_ - _barsize_, 1 )

		self:SetEnabled( _canvassize_ > _barsize_ )

		self:InvalidateLayout()
		
		if self:GetScroll() == oldSize || (oldSize == 1 && self:GetScroll() == 0) then
			self:SetScroll(self.CanvasSize) 
		end
	end

	// results section
	local respnl = vgui.Create("DPanel", menu)
	menu.ResultsPanel = respnl
	respnl:Dock(FILL)
	respnl:DockMargin(20, 0, 0, 0)
	respnl:DockPadding(0, 0, 0, 0)
	function respnl:Paint(w, h)
	end

	local winner = vgui.Create("DPanel", respnl)
	menu.WinningTeam = winner
	winner:Dock(TOP)
	winner:DockMargin(0, 0, 0, 0)
	winner:SetTall(draw.GetFontHeight("RobotoHUD-30") + 20)
	winner.text = ""
	winner.textColor = color_white
	function winner:Paint(w, h)
		surface.SetDrawColor(30, 30, 30, 252)
		surface.DrawRect(0, 0, w, h)
		
		surface.SetTexture(grad)
		surface.SetDrawColor(90, 90, 90, 20)
		surface.DrawTexturedRectRotated(w / 2, h / 2, h, w, 90)
		draw.ShadowText(self.text, "RobotoHUD-30", 20, h / 2, winner.textColor, 0, 1)
	end


	// map vote
	local votepnl = vgui.Create("DPanel", respnl)
	menu.VotePanel = votepnl
	votepnl:Dock(FILL)
	votepnl:DockMargin(0, 20, 0, 0)
	votepnl:DockPadding(0, 0, 0, 0)
	function votepnl:Paint(w, h)
		surface.SetDrawColor(120, 120, 120, 241)
		surface.DrawRect(0, 0, w, h)

		surface.SetTexture(grad)
		surface.SetDrawColor(255, 255, 255, 30)
		surface.DrawTexturedRectRotated(w / 2, h / 2, h, w, 90)
	end

	local timeleft = vgui.Create("DPanel", votepnl)
	timeleft:Dock(BOTTOM)
	timeleft:SetTall(draw.GetFontHeight("RobotoHUD-20"))
	local col = Color(220, 220, 220)
	function timeleft:Paint(w, h)
		if GAMEMODE:GetGameState() == 3 then
			local settings = GAMEMODE:GetRoundSettings()
			local roundTime = settings.NextRoundWait or 30
			local time = math.max(0, roundTime - GAMEMODE:GetStateRunningTime())
			draw.ShadowText("Next round in " .. math.ceil(time), "RobotoHUD-20", w - 4, 0, col, 2)
		end
	end

	local mlist = vgui.Create("DScrollPanel", votepnl)
	menu.MapVoteList = mlist
	mlist:Dock(FILL)
	mlist:DockMargin(0, 0, 0, 0)
	function mlist:Paint(w, h)
		-- surface.SetDrawColor(30, 30, 30, 252)
		-- surface.DrawRect(0, 0, w, h)
		
		-- surface.SetTexture(grad)
		-- surface.SetDrawColor(90, 90, 90, 20)
		-- surface.DrawTexturedRectRotated(w / 2, h / 2, h, w, 90)
	end

	local canvas = mlist:GetCanvas()
	canvas:DockPadding(10, 10, 10, 10)
	function canvas:OnChildAdded( child )
		child:Dock(TOP)
		child:DockMargin(0, 0, 0, 10)
	end
end

function GM:CloseEndRoundMenu()
	if IsValid(menu) then
		menu:Close()
	end
end

function GM:EndRoundMenuResults(res)
	self:OpenEndRoundMenu()

	menu.Results = res
	menu.ChatList:Clear()
	if res.reason == 2 then
		menu.WinningTeam.text = res.winnerName .. " won"
		menu.WinningTeam.textColor = Color(res.winnerColor.x * 255, res.winnerColor.y * 255, res.winnerColor.z * 255)
	else
		menu.WinningTeam.text = "Round tied"
		menu.WinningTeam.textColor = Color(150, 150, 150)
	end

end

net.Receive("map_type_list", function ()

	local maps = {}
	while net.ReadUInt(8) != 0 do
		local t = {}
		t.key = net.ReadString()
		t.name = net.ReadString()
		t.desc = net.ReadString()
		table.insert(maps, math.random(0, #maps), t)
	end

	GAMEMODE.SelfMapVote = nil
	GAMEMODE.MapVotes = {}
	GAMEMODE.MapVotesByMap = {}

	GAMEMODE:CreateEndRoundMenu()

	menu.MapVoteList:Clear()

	local displaySize = 96 + 2

	for k, map in pairs(maps) do
		local but = vgui.Create("DButton")
		but:SetText("")
		but:SetTall(displaySize)
		local png
		local path = "materials/melonbomber/maptypes/" .. map.key .. ".png"
		if file.Exists(path, "GAME") then
			png = Material(path, "noclamp")
		end
		local dname = map.name
		local z = tonumber(util.CRC(dname):sub(1, 8))
		local mcol = Color(z % 255, z / 255 % 255, z / 255 / 255 % 255, 50)
		local gray = Color(230, 230, 230)

		but.VotesScroll = 0
		but.VotesScrollDir = 1
		local wrap
		function but:Paint(w, h)
			if self.Hovered then
				surface.SetDrawColor(50, 50, 50, 50)
				surface.DrawRect(0, 0, w, h)
			end

			draw.ShadowText(dname, "RobotoHUD-16", displaySize + 6, 4, color_white, 0)
			local fg = draw.GetFontHeight("RobotoHUD-16")
			if !wrap then
				wrap = WrapText("RobotoHUD-L15", math.floor((w - (displaySize + 6 + 4)) * 0.7), {gray, map.desc})
			end
			if wrap then
				wrap:Paint(displaySize + 6, 4 + fg)
			end
			-- draw.ShadowText(map.desc, "RobotoHUD-L15", displaySize + 10, 10 + fg, gray, 0)
			surface.SetDrawColor(50, 50, 50, 255)
			surface.DrawRect(0, 0, displaySize, displaySize)
			local border = 1
			if png then
				surface.SetMaterial(png)
				surface.SetDrawColor(255, 255, 255, 255)
				surface.DrawTexturedRect(border, border, displaySize - border * 2, displaySize - border * 2)
			else
				surface.SetDrawColor(mcol)
				surface.DrawRect(border, border, displaySize - border * 2, displaySize - border * 2)
			end

			local votes = 0
			if GAMEMODE.MapVotesByMap[map] then
				votes = #GAMEMODE.MapVotesByMap[map]
			end

			local fg2 = draw.GetFontHeight("RobotoHUD-L15")
			if votes > 0 then
				draw.ShadowText(votes .. (votes > 1 and " votes" or " vote"), "RobotoHUD-L15", displaySize + 6, 4 + fg + 10 + fg2, color_white, 0)
			end

			local i = 0
			for ply, key in pairs(GAMEMODE.MapVotes) do
				if IsValid(ply) && key == map.key then
					draw.ShadowText(ply:Nick(), "RobotoHUD-L15", w, i * fg2 - self.VotesScroll, gray, 2)
					i = i + 1
				end
			end

			if i * fg2 > displaySize then
				self.VotesScroll = self.VotesScroll + FrameTime() * 14 * self.VotesScrollDir
				if self.VotesScroll > i * fg2 - displaySize then
					self.VotesScrollDir = -1
				elseif self.VotesScroll < 0 then
					self.VotesScrollDir = 1
				end
			end
		end

		function but:DoClick()
			RunConsoleCommand("mb_votemap", map.key)
		end
		menu.MapVoteList:AddItem(but)
	end
end)

net.Receive("mb_mapvotes", function (len)

	local mapVotes = {}

	while true do
		local k = net.ReadUInt(8)
		if k <= 0 then break end
		local ply = net.ReadEntity()
		local map = net.ReadString()
		mapVotes[ply] = map
	end

	GAMEMODE.SelfMapVote = nil

	local byMap = {}
	for ply, map in pairs(mapVotes) do
		byMap[map] = byMap[map] or {}
		table.insert(byMap[map], ply)

		if ply == LocalPlayer() then
			GAMEMODE.SelfMapVote = map
		end
	end
	
	GAMEMODE.MapVotes = mapVotes
	GAMEMODE.MapVotesByMap = byMap
end)

function GM:EndRoundAddChatText(...)
	if !IsValid(menu) then
		return
	end

	local pnl = vgui.Create("DPanel")
	pnl.Text = {...}
	function pnl:PerformLayout()
		if self.Text then
			self.TextLines = WrapText("RobotoHUD-15", self:GetWide() - 16, self.Text)
		end
		if self.TextLines then
			self:SetTall(self.TextLines.height)
		end
	end

	function pnl:Paint(w, h)
		-- surface.SetDrawColor(255, 0, 0, 255)
		-- surface.DrawOutlinedRect(0, 0, w, h)
		if self.TextLines then
			self.TextLines:Paint(4, draw.GetFontHeight("RobotoHUD-15") * -0.2)
		end
	end
	menu.ChatList:AddItem(pnl)
end

function GM:CloseRoundMenu()
	if IsValid(menu) then
		menu:SetVisible(false)
	end
end