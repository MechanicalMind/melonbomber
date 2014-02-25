local PlayerMeta = FindMetaTable("Player")
local EntityMeta = FindMetaTable("Entity")

function GM:PlayerInitialSpawn(ply)
	self:TeamsSetupPlayer(ply)
	self:RoundsSetupPlayer(ply)

	ply:SetMoney(10000)

	if self:GetGameState() != 0 then
		timer.Simple(0, function ()
			if IsValid(ply) then
				ply:KillSilent()
			end
		end)
	end

	self.LastPlayerSpawn = CurTime()

	net.Start("spawn_zones")
	for k, ent in pairs(ents.FindByClass("spawn_zone")) do
		net.WriteUInt(k, 16)
		net.WriteVector(ent:OBBMins())
		net.WriteVector(ent:OBBMaxs())
		net.WriteFloat(ent.grid.sqsize)
	end
	net.WriteUInt(0, 16)
	net.Send(ply)
end

function GM:PlayerLoadedLocalPlayer(ply)
end

net.Receive("clientIPE", function (len, ply)
	if !ply.ClientIPE then
		ply.ClientIPE = true
		hook.Call("PlayerLoadedLocalPlayer", GAMEMODE, ply)
	end
end)

function GM:PlayerConnect(name, ip)

end

function GM:PlayerAuthed(ply)
end

function GM:PlayerDisconnected(ply)
	ply:SetTeam(2)
end

util.AddNetworkString("hull_set")
function GM:PlayerSpawn( ply )

	-- Stop observer mode
	ply.Spectating = nil
	ply:UnSpectate()

	player_manager.OnPlayerSpawn( ply )
	player_manager.RunClass( ply, "Spawn" )

	hook.Call( "PlayerLoadout", GAMEMODE, ply )
	hook.Call( "PlayerSetModel", GAMEMODE, ply )

	ply:ResetUpgrades()
	ply:CalculateSpeed()

	ply:SetHMaxHealth(100)
	ply:SetHealth(ply:GetHMaxHealth())

	-- ply:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	ply:SetCustomCollisionCheck(true)
	GAMEMODE:PlayerSetNewHull(ply)
	net.Start("hull_set")
	net.Broadcast()

	self:PlayerSetupHands(ply)

	local col = team.GetColor(ply:Team())
 	local vec = Vector(col.r / 255,col.g / 255,col.b / 255)
 	ply:SetPlayerColor(vec)

 	ply.LastSpawnTime = CurTime()
end

function GM:PlayerSetupHands(ply)
	local oldhands = ply:GetHands()
	if ( IsValid( oldhands ) ) then oldhands:Remove() end

	local hands = ents.Create( "gmod_hands" )
	if ( IsValid( hands ) ) then
		ply:SetHands( hands )
		hands:SetOwner( ply )

		-- Which hands should we use?
		local cl_playermodel = ply:GetInfo( "cl_playermodel" )
		local info = player_manager.TranslatePlayerHands( cl_playermodel )
		if ( info ) then
			hands:SetModel( info.model )
			hands:SetSkin( info.skin )
			hands:SetBodyGroups( info.body )
		end

		-- Attach them to the viewmodel
		local vm = ply:GetViewModel( 0 )
		hands:AttachToViewmodel( vm )

		vm:DeleteOnRemove( hands )
		ply:DeleteOnRemove( hands )

		hands:Spawn()
 	end
end

function PlayerMeta:CalculateSpeed()
	// set the defaults
	local settings = {
		walkSpeed = 200,
		runSpeed = 300,
		jumpPower = 0,
		canRun = false,
		canMove = true,
		canJump = false
	}

	settings.walkSpeed = settings.walkSpeed + 20 * (self:GetRunningBoots() - 1)

	hook.Call("PlayerCalculateSpeed", ply, settings)


	// set out new speeds
	if settings.canRun then
		self:SetRunSpeed(settings.runSpeed or 1)
	else
		self:SetRunSpeed(settings.walkSpeed or 1)
	end
	if self:GetMoveType() != MOVETYPE_NOCLIP then
		if settings.canMove then
			self:SetMoveType(MOVETYPE_WALK)
		else
			self:SetMoveType(MOVETYPE_NONE)
		end
	end
	self.CanRun = settings.canRun
	self:SetWalkSpeed(settings.walkSpeed or 1)
	self:SetJumpPower(settings.jumpPower or 1)
end

function GM:DoPlayerDeath(ply, attacker, dmginfo)

	ply:Freeze(false) // why?, *sigh*
	
	ply:CreateRagdoll()

	local ent = ply:GetNWEntity("DeathRagdoll")
	if IsValid(ent) then
		ply:CSpectate(OBS_MODE_CHASE, ent)
	end

	ply:AddDeaths(1)

	if attacker:IsValid() && attacker:IsPlayer() then
		if attacker == ply then
			attacker:AddFrags(-1)
		else
			attacker:AddFrags(1)
		end
	end
end

function GM:PlayerLoadout(ply)
end


local playerModels = {}
local function addModel(model, sex)
	local t = {}
	t.model = model
	t.sex = sex
	table.insert(playerModels, t)
end

addModel("male03", "male")
addModel("male04", "male")
addModel("male05", "male")
addModel("male07", "male")
addModel("male06", "male")
addModel("male09", "male")
addModel("male01", "male")
addModel("male02", "male")
addModel("male08", "male")
addModel("female06", "female")
addModel("female01", "female")
addModel("female03", "female")
addModel("female05", "female")
addModel("female02", "female")
addModel("female04", "female")
addModel("refugee01", "male")
addModel("refugee02", "male")
addModel("refugee03", "male")
addModel("refugee04", "male")

function GM:PlayerSetModel( ply )

	local cl_playermodel = ply:GetInfo( "cl_playermodel" )

	local playerModel = table.Random(playerModels)
	cl_playermodel = playerModel.model

	local modelname = player_manager.TranslatePlayerModel( cl_playermodel )
	util.PrecacheModel( modelname )
	ply:SetModel( modelname )
	ply.ModelSex = playerModel.sex

end

function GM:ScalePlayerDamage( ply, hitgroup, dmginfo )
end

function GM:ScaleNPCDamage( npc, hitgroup, dmginfo )
end

function GM:PlayerDeathSound()
	return false
end

util.AddNetworkString("heist_money")
function PlayerMeta:SetMoney(money)
	self.Money = money
	net.Start("heist_money")
	net.WriteDouble(self.Money or 0)
	net.Send(self)
end

function PlayerMeta:GetMoney()
	return self.Money or 0
end

function PlayerMeta:AddMoney(money)
	self:SetMoney(self:GetMoney() + money)
end

function PlayerMeta:TakeMoney(amount)
	if self:GetMoney() >= amount then
		self:SetMoney(self:GetMoney() - amount)
		return true
	end
	return false
end

function GM:PlayerSelectSpawn( ply )

	local has = {}
	for k, ent in pairs(ents.FindByClass("spawn_zone")) do
		if ent.walkable then
			table.insert(has, ent)
		end
	end
	if #has <= 0 then 
		self:PlayerSelectSpawn2(ply)
		return 
	end

	local zone = has[math.random(#has)]
	local jab = zone.walkable.sqsize

	local sq = table.Random(zone.walkable.squares)

	local mins, maxs = zone:OBBMins(), zone:OBBMaxs()
	local center = (mins + maxs) / 2

	local pos = center + Vector(jab, 0, 0) * sq.x  + Vector(0, jab, 0) * sq.y
	pos.z = mins.z + 4
	ply:SetPos(pos)

	
end

function GM:PlayerSelectSpawn2( pl )

	if ( GAMEMODE.TeamBased ) then
	
		local ent = GAMEMODE:PlayerSelectTeamSpawn( pl:Team(), pl )
		if ( IsValid(ent) ) then return ent end
	
	end

	-- Save information about all of the spawn points
	-- in a team based game you'd split up the spawns
	if ( !IsTableOfEntitiesValid( self.SpawnPoints ) ) then
	
		self.LastSpawnPoint = 0
		self.SpawnPoints = ents.FindByClass( "info_player_start" )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_deathmatch" ) )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_combine" ) )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_rebel" ) )
		
		-- CS Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_counterterrorist" ) )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_terrorist" ) )
		
		-- DOD Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_axis" ) )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_allies" ) )

		-- (Old) GMod Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "gmod_player_start" ) )
		
		-- TF Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_teamspawn" ) )
		
		-- INS Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "ins_spawnpoint" ) )  

		-- AOC Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "aoc_spawnpoint" ) )

		-- Dystopia Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "dys_spawn_point" ) )

		-- PVKII Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_pirate" ) )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_viking" ) )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_knight" ) )

		-- DIPRIP Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "diprip_start_team_blue" ) )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "diprip_start_team_red" ) )
 
		-- OB Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_red" ) )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_blue" ) )        
 
		-- SYN Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_coop" ) )
 
		-- ZPS Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_human" ) )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_zombie" ) )      
 
		-- ZM Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_deathmatch" ) )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_zombiemaster" ) )  		

	end
	
	local Count = table.Count( self.SpawnPoints )
	
	if ( Count == 0 ) then
		Msg("[PlayerSelectSpawn] Error! No spawn points!\n")
		return nil
	end
	
	-- If any of the spawnpoints have a MASTER flag then only use that one.
	-- This is needed for single player maps.
	for k, v in pairs( self.SpawnPoints ) do
		
		if ( v:HasSpawnFlags( 1 ) ) then
			return v
		end
		
	end
	
	local ChosenSpawnPoint = nil
	
	-- Try to work out the best, random spawnpoint
	for i=0, Count do
	
		ChosenSpawnPoint = table.Random( self.SpawnPoints )

		if ( ChosenSpawnPoint &&
			ChosenSpawnPoint:IsValid() &&
			ChosenSpawnPoint:IsInWorld() &&
			ChosenSpawnPoint != pl:GetVar( "LastSpawnpoint" ) &&
			ChosenSpawnPoint != self.LastSpawnPoint ) then
			
			if ( hook.Call( "IsSpawnpointSuitable", GAMEMODE, pl, ChosenSpawnPoint, i == Count ) ) then
			
				self.LastSpawnPoint = ChosenSpawnPoint
				pl:SetVar( "LastSpawnpoint", ChosenSpawnPoint )
				return ChosenSpawnPoint
			
			end
			
		end
			
	end
	
	return ChosenSpawnPoint
	
end

function GM:PlayerDeathThink(ply)
	if self:CanRespawn(ply) then
		ply:Spawn()
	else
		self:ChooseSpectatee(ply)
	end
end

function GM:PlayerDeath(ply, Inflictor, attacker )

	self:DoRoundDeaths(ply, attacker)

	ply.NextSpawnTime = CurTime() + 1
	ply.DeathTime = CurTime()
	ply.SpectateTime = CurTime() + 4

	if IsValid(attacker) && attacker:IsPlayer() && attacker != ply then
		attacker:AddMoney(100)
		attacker:AddExp(10)
	end
	
	if ( Inflictor && Inflictor == attacker && (Inflictor:IsPlayer() || Inflictor:IsNPC()) ) then
	
		Inflictor = Inflictor:GetActiveWeapon()
		if ( !Inflictor || Inflictor == NULL ) then Inflictor = attacker end
	
	end

	self:RagdollSetDeathDetails(ply, Inflictor, attacker)
end


function GM:PlayerSwitchWeapon(ply, oldwep, newwep)
end

function GM:KeyPress(ply, key, c, d)
	if ply:Alive() then
		if key == IN_ATTACK then
			self:CreateBomb(ply)
		end
	end
end

function GM:PlayerSwitchFlashlight(ply)
	return false
end