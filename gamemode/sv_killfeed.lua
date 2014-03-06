
util.AddNetworkString("kill_feed_add")

function GM:AddKillFeed(ply, inflictor, attacker)
	net.Start("kill_feed_add")
	net.WriteEntity(ply)
	net.WriteEntity(inflictor)
	net.WriteEntity(attacker)
	net.Broadcast()
end
