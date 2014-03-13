
local screenContent = {}

local function addHelpText(text, color)
	local t = {}
	t.text = text
	t.color = color //or color_white
	table.insert(screenContent, t)
end

addHelpText("Melonbomber is a game where you try to elimate the other players with explosive melons while grabbing upgrades to increase your power\n\n", Color(240, 240, 240))
addHelpText("Based on the game Bomberman, Melonbomber brings the same hectic, fast paced gameplay to GMod. Players can place explosive melons and use them to kill other players or destroy wooden crates around the map. Inside the crates can be found powerups that can give you an edge on other players. Having more players increases the fun leading to an unstopabble good time\n\n")

addHelpText("Powerups include\n", Color(240, 240, 240))
addHelpText("Speed Up", Color(0, 150, 255))
addHelpText(" - increases your running speed\n")
addHelpText("Bomb Up", Color(50,255,50))
addHelpText(" - increases the max bombs you can place at a time\n")
addHelpText("Power Up", Color(220,50,50))
addHelpText(" - increase the length of your bomb's explosions\n")
addHelpText("Bomb Kick", Color(250, 100, 0))
addHelpText(" - the power to move around bombs\n")
addHelpText("Power Bomb", Color(155, 20, 80))
addHelpText(" - a incredibly powerful mega bomb\n")
addHelpText("Remote Control", Color(220, 190, 0))
addHelpText(" - the ability to remotely detonate your bombs\n")
addHelpText("Piercing", Color(0, 70, 220))
addHelpText(" - bomb explosions pass through breakable crates\n")
addHelpText("Line Bomb", Color(150, 0, 180))
addHelpText(" - place a line of bombs with right click\n")

local menu
local function openHelpScreen()
	if IsValid(menu) then
		menu:SetVisible(!menu:IsVisible())
	else
		menu = vgui.Create("DFrame")
		GAMEMODE.ScoreboardPanel = menu
		menu:SetSize(ScrW() * 0.6, ScrH() * 0.8)
		menu:Center()
		menu:MakePopup()
		menu:SetKeyboardInputEnabled(false)
		menu:SetDeleteOnClose(false)
		menu:SetDraggable(false)
		menu:ShowCloseButton(true)
		menu:SetTitle("")
		menu:DockPadding(8, 8 + draw.GetFontHeight("RobotoHUD-25"), 8, 8)
		function menu:PerformLayout()
		end

		function menu:Paint(w, h)
			surface.SetDrawColor(130, 130, 130, 255)
			surface.DrawRect(0, 0, w, h)

			surface.SetDrawColor(80, 80, 80, 255)
			surface.DrawOutlinedRect(0, 0, w, h)

			surface.SetFont("RobotoHUD-25")
			local t = "Help"
			local tw,th = surface.GetTextSize(t)
			draw.ShadowText(t, "RobotoHUD-25", 8, 2, Color(132, 199, 29), 0)

			draw.ShadowText("learn to blow up your enemies better", "RobotoHUD-15", 8 + tw + 16, 2 + th * 0.90, Color(220, 220, 220), 0, 4)
		end

		local pnl = vgui.Create("DPanel", menu)
		pnl:Dock(FILL)
		pnl:DockPadding(4, 4, 4, 4)
		function pnl:Paint(w, h)
			surface.SetDrawColor(90, 90, 90, 255)
			surface.DrawRect(0, 0, w, h)

			surface.SetDrawColor(20, 20, 20)
			surface.DrawOutlinedRect(0, 0, w, h)
		end

		local txt = vgui.Create("RichText", pnl)
		txt:Dock(FILL)
		-- txt:AppendText( "this \n richtext \n is \n awesome \n" )
		txt:InsertColorChange(210, 210, 210, 255)
		txt:SetFontInternal("RobotoHUD-15")
		txt.Paint = function(self)
			self.m_FontName = "RobotoHUD-15"
			self:SetFontInternal( "RobotoHUD-15" )	
			self:SetBGColor(Color(0,0,0,0))		
			self.Paint = nil
		end

		for k, t in pairs(screenContent) do
			if t.color then
				txt:InsertColorChange(t.color.r, t.color.g, t.color.b, t.color.a)
			else
				txt:InsertColorChange(210, 210, 210, 255)
			end
			txt:AppendText(t.text or "")
		end
	end
end
concommand.Add("mb_helpscreen", openHelpScreen)
net.Receive("mb_openhelpmenu", openHelpScreen)