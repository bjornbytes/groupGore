NetClient = {}

function NetClient:connect(peer)
	self.server = peer
	self:send(Net.msgJoin, Net.server, {
		username = username
	})
end

function NetClient:activate()
	self:connectTo(serverIp, 6061)
end