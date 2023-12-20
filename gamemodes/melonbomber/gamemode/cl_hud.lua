
local function createRoboto(s)
	surface.CreateFont( "RobotoHUD-" .. s , {
		font = "Roboto-Bold",
		size = math.Round(ScrW() / 1000 * s),
		weight = 700,
		antialias = true,
		italic = false
	})
	surface.CreateFont( "RobotoHUD-L" .. s , {
		font = "Roboto",
		size = math.Round(ScrW() / 1000 * s),
		weight = 500,
		antialias = true,
		italic = false
	})
end

for i = 5, 50 do
	if i % 5 == 0 || i % 4 == 0 then
		createRoboto(i)
	end
end

function draw.ShadowText(n, f, x, y, c, px, py, shadowColor)
	draw.SimpleText(n, f, x + 1, y + 1, shadowColor or color_black, px, py)
	draw.SimpleText(n, f, x, y, c, px, py)
end

function draw.EasyPNG(path, x, y, w, h, col)
	surface.SetMaterial(Material(path, "noclamp"))
	if col then
		surface.SetDrawColor(col.r, col.g, col.b, col.a)
	else
		surface.SetDrawColor(255, 255, 255, 255)
	end
	surface.DrawTexturedRect(x, y, w, h)
end

function draw.DrawRectOutline(x, y, w, h, border)
	surface.DrawRect(x, y, w, border)
	surface.DrawRect(x, y, border, h)
	surface.DrawRect(x, y + h - border, w, border)
	surface.DrawRect(x + w - border, y, border, h)
end

local function translate(name)
	if name == "weapon_physcannon" then return "Gravity Gun" end
	return language.GetPhrase(name)
end

function GM:HUDPaint()
	if LocalPlayer():Alive() then
	end
	self:DrawGameHUD()
	self:DrawBindsHelp()
	self:DrawRoundTimer()
	self:DrawKillFeed()
end

function GM:DrawGameHUD()
	if LocalPlayer():Alive() then
		self:DrawUpgrades()
	end

	local ply = LocalPlayer()
	if self:IsCSpectating() && IsValid(self:GetCSpectatee()) && self:GetCSpectatee():IsPlayer() then
		ply = self:GetCSpectatee()
	end
	self:DrawHealth(ply)

	if ply != LocalPlayer() then
		local col = ply:GetPlayerColor()
		col = Color(col.r * 255, col.y * 255, col.z * 255)
		draw.ShadowText(ply:Nick(), "RobotoHUD-30", ScrW() / 2, ScrH() - 4, col, 1, 4)
	end
end


local tex = surface.GetTextureID("mech/ring")
local ringThin = surface.GetTextureID("mech/ring_thin")
local matWhite = Material( "model_color" )
local rt_Store = render.GetScreenEffectTexture( 0 )
local mat_Copy = Material( "pp/copy" )

local polyTex = surface.GetTextureID("VGUI/white.vmt")

local function drawPoly(x, y, w, h, percent)
	local points = 40

	if percent > 0.5 then
		local vertexes = {}
		local hpoints = points / 2
		local base = math.pi * 1.5
		local mul = 1 / hpoints * math.pi
		for i = (1 - percent) * 2 * hpoints, hpoints do
			table.insert(vertexes, {x = x + w / 2 + math.cos(i * mul + base) * w / 2, y = y + h / 2 + math.sin(i * mul + base) * h / 2})
		end
		table.insert(vertexes, {x = x + w / 2, y = y + h})
		table.insert(vertexes, {x = x + w / 2, y = y + h / 2})

		-- for i = 1, #vertexes do draw.DrawText(i, "Default", vertexes[i].x, vertexes[i].y, color_white, 0) end

		surface.SetTexture(polyTex)
		surface.DrawPoly(vertexes)
	end

	local vertexes = {}
	local hpoints = points / 2
	local base = math.pi * 0.5
	local mul = 1 / hpoints * math.pi
	local p = 0
	if percent < 0.5 then
		p = (1 - percent * 2 )
	end
	for i = p * hpoints, hpoints do
		table.insert(vertexes, {x = x + w / 2 + math.cos(i * mul + base) * w / 2, y = y + h / 2 + math.sin(i * mul + base) * h / 2})
	end
	table.insert(vertexes, {x = x + w / 2, y = y})
	table.insert(vertexes, {x = x + w / 2, y = y + h / 2})

	-- for i = 1, #vertexes do draw.DrawText(i, "Default", vertexes[i].x, vertexes[i].y, color_white, 0) end

	surface.SetTexture(polyTex)
	surface.DrawPoly(vertexes)
end

function GM:DrawHealth(ply)

	self:DrawHealthFace(ply)
end

function GM:CreateHealthFace(ply)
	self.HealthFace = ClientsideModel(ply:GetModel(), RENDER_GROUP_OPAQUE_ENTITY)
	self.HealthFace:SetNoDraw( true )
		local iSeq = self.HealthFace:LookupSequence( "walk_all" );
	if ( iSeq <= 0 ) then iSeq = self.HealthFace:LookupSequence( "WalkUnarmed_all" ) end
	if ( iSeq <= 0 ) then iSeq = self.HealthFace:LookupSequence( "walk_all_moderate" ) end
	
	-- if ( iSeq > 0 ) then self.HealthFace:ResetSequence( iSeq ) end

	local f = function (self) return self.PlayerColor or Vector(1, 0, 0) end
	self.HealthFace.GetPlayerColorOverride = f
end

function GM:DrawHealthFace(ply)

	local x = 20
	local w,h = math.ceil(ScrW() * 0.09), 80
	h = w
	local y = ScrH() - 20 - h

	local ps = 0.0

	surface.SetDrawColor(150, 150, 150, 151)
	drawPoly(x + w * ps, y + h * ps, w * (1 - 2 * ps), h * (1 - 2 * ps), 1)

	render.ClearStencil()
	render.SetStencilEnable( true )
	render.SetStencilFailOperation( STENCILOPERATION_KEEP )
	render.SetStencilZFailOperation( STENCILOPERATION_KEEP )
	render.SetStencilPassOperation( STENCILOPERATION_REPLACE )
	render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_ALWAYS )
	render.SetStencilWriteMask( 1 )
	render.SetStencilTestMask( 1 )
	render.SetStencilReferenceValue( 1 )

	render.SetBlend( 0 )

	render.OverrideDepthEnable( true, false )
	-- render.SetMaterial(matWhite)
	-- render.DrawScreenQuadEx(tx, ty, tw, th)

	surface.SetDrawColor(26, 120, 245, 1)
	drawPoly(x + w * ps, y + h * ps, w * (1 - 2 * ps), h * (1 - 2 * ps), 1)

	render.SetStencilEnable( true );
	render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )
	render.SetStencilPassOperation( STENCILOPERATION_REPLACE )
	render.SetStencilReferenceValue( 1 )

	if !IsValid(self.HealthFace) then
		self:CreateHealthFace(ply)
	end

	if IsValid(self.HealthFace) then
		if self.HealthFace:GetModel() != ply:GetModel() then
			self:CreateHealthFace(ply)
		end	

		self.HealthFace.PlayerColor = ply:GetPlayerColor()

		local bone = self.HealthFace:LookupBone("ValveBiped.Bip01_Head1")
		local pos = Vector(0, 0, 70)
		local bang = Angle()
		if bone then
			pos, bang = self.HealthFace:GetBonePosition(bone)
		end

		cam.Start3D( pos + Vector(19, 0, 2), Vector(-1,0,0):Angle(), 70, x, y, w, h, 5, 4096 )
		cam.IgnoreZ( true )
		
		render.OverrideDepthEnable( false )
		render.SuppressEngineLighting( true )
		render.SetLightingOrigin(pos)
		render.ResetModelLighting(1, 1, 1)
		render.SetColorModulation(1, 1, 1)
		render.SetBlend(1)
		
		self.HealthFace:DrawModel()
		
		render.SuppressEngineLighting( false )
		cam.IgnoreZ( false )
		cam.End3D()

	end

	render.SetStencilEnable( false )
 
	render.SetStencilWriteMask( 0 );
		render.SetStencilReferenceValue( 0 );
		render.SetStencilTestMask( 0 );
		render.SetStencilEnable( false )
		render.OverrideDepthEnable( false )
		render.SetBlend( 1 )
		
		cam.IgnoreZ( false )
end

function GM:DrawUpgrade(name, amo, col, x, y)
	surface.SetFont("RobotoHUD-30")
	local w, h = surface.GetTextSize(amo)
	draw.ShadowText(amo, "RobotoHUD-30", x, y, col, 0)
	draw.ShadowText(name, "RobotoHUD-10", x + w + h * 0.2, y + h * 0.65, col, 0, 1)
end

GM.UpgradesNotif = {}

function GM:DrawUpgrades()
	local x = 20 + math.ceil(ScrW() * 0.09) + 20
	local w,h = math.ceil(ScrW() * 0.09), 80
	h = w
	local y = ScrH() - 20 - h

	local f15 = draw.GetFontHeight("RobotoHUD-15")
	local f25 = draw.GetFontHeight("RobotoHUD-30") * 0.8
	self:DrawUpgrade("Bombs", self:GetMaxBombs(), Color(50,255,50), x, y)
	self:DrawUpgrade("Speed", self:GetRunningBoots(), Color(0, 150, 255), x, y + f25 + 4)
	self:DrawUpgrade("Power", self:GetBombPower(), Color(220,50,50), x, y + f25 * 2 + 4 * 2)

	local f20 = draw.GetFontHeight("RobotoHUD-20")
	local i = 0
	for k, pickup in pairs(GAMEMODE.Pickups) do
		if !pickup.NoList && self:HasUpgrade(k) then
			local x, y = ScrW() - 4, ScrH() - 4 - f20 * i
			draw.ShadowText(pickup.name, "RobotoHUD-20", x, y, pickup.color or color_white, 2, 4)
			i = i + 1
		end
	end

	if self.UpgradePopup && self.Pickups[self.UpgradePopup.id] then
		if self.UpgradePopup.time + 3 < CurTime() then
			self.UpgradePopup = nil
		else
			local pickup = self.Pickups[self.UpgradePopup.id]
			local y = ScrH() - draw.GetFontHeight("RobotoHUD-20") - draw.GetFontHeight("RobotoHUD-15") * 2
			draw.ShadowText(pickup.name, "RobotoHUD-20", ScrW() / 2, y, pickup.color or color_white, 1, 1)
			if pickup.Description then
				draw.ShadowText(pickup.Description, "RobotoHUD-15", ScrW() / 2, y + draw.GetFontHeight("RobotoHUD-20"), color_white, 1, 1)
			end
		end
	end
end

net.Receive("melons_pickup_upgrade", function (len)
	local id = net.ReadUInt(16)

	GAMEMODE.UpgradePopup = {id = id, time = CurTime()}
end)


function GM:HUDShouldDraw(name)
	if name == "CHudHealth" then return false end
	if name == "CHudAmmo" then return false end
	return true
end

function GM:DrawRoundTimer()

	if self:GetGameState() == 1 then
		local time = math.ceil(5 - self:GetStateRunningTime())
		if time > 0 then
			draw.ShadowText(time, "RobotoHUD-40", ScrW() / 2, ScrH() / 3, color_white, 1, 1)
		end
	elseif self:GetGameState() == 2 then
		if self:GetStateRunningTime() < 2 then
			draw.ShadowText("GO!", "RobotoHUD-50", ScrW() / 2, ScrH() / 3, color_white, 1, 1)
		end
	end
end