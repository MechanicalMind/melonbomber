util.AddNetworkString("chattext_msg")

local meta = {}
meta.__index = meta

function meta:Add(string, color)
	local t = {}
	t.text = string
	t.color = color or self.default_color or color_white
	table.insert(self.msgs, t)
	return self
end

function meta:SetDefaultColor(color)
	self.default_color = color
end

function meta:SendAll()
	self:NetConstructMsg()
	net.Broadcast()
	return self
end

function meta:Send(players)
	self:NetConstructMsg()
	if players == nil then
		net.Broadcast()
	else
		net.Send(players)
	end
	return self
end

function meta:NetConstructMsg()
	net.Start("chattext_msg")
	for k, msg in pairs(self.msgs) do
		net.WriteUInt(1,8)
		net.WriteString(msg.text)
		net.WriteVector(Vector(msg.color.r, msg.color.g, msg.color.b))
	end
	net.WriteUInt(0,8)
end

function ChatText()
	local t = {}
	t.msgs = {}
	setmetatable(t, meta)
	return t
end

-- local t = ChatText()
-- t:Add("pants down", Color(255,0,0))
-- t:Add(" pants up")
-- t:SendAll()

util.AddNetworkString("msg_clients")

local meta = table.Copy(meta)

function meta:NetConstructMsg()
	net.Start("msg_clients")
	for k, line in pairs(self.msgs) do
		net.WriteUInt(1, 8)
		net.WriteUInt(line.color.r, 8)
		net.WriteUInt(line.color.g, 8)
		net.WriteUInt(line.color.b, 8)
		net.WriteString(line.text)
	end
	net.WriteUInt(0, 8)
end

function MsgClients()
	local t = {}
	t.msgs = {}
	setmetatable(t, meta)
	return t
end