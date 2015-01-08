util.AddNetworkString("map_type_list")
util.AddNetworkString("mb_mapvotes")

function GM:NetworkMapList()
	net.Start("map_type_list")
	for k, map in pairs(MapTypes) do
		net.WriteUInt(1, 8)
		net.WriteString(k)
		net.WriteString(map.name or k)
		net.WriteString(map.description or map.desc or "")
	end
	net.WriteUInt(0, 8)
	net.Broadcast()
end

function GM:NetworkMapVotes(ply)
	net.Start("mb_mapvotes")

	for k, map in pairs(self.MapVotes) do
		net.WriteUInt(1, 8)
		net.WriteEntity(k)
		net.WriteString(map.key)
	end
	net.WriteUInt(0, 8)


	if ply then
		net.Send(ply)
	else
		net.Broadcast()
	end
end

concommand.Add("mb_votemap", function (ply, com, args)
	if GAMEMODE.MapVoting then
		if #args < 1 then
			return
		end

		local found
		for k, map in pairs(MapTypes) do
			if map.key == args[1] then
				found = map
				break
			end
		end
		if !found then
			ply:ChatPrint("Invalid map " .. args[1])
			return
		end

		GAMEMODE.MapVotes[ply] = found
		GAMEMODE:NetworkMapVotes()
	end
end)