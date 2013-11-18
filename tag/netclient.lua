NetClient = {}

NetClient.signatures = {}
NetClient.signatures[evtJoin] = {{'username', 'string'}}
NetClient.signatures[evtLeave] = {}

function NetClient:connect(peer)
	self.server = peer
	self:send(evtJoin, {username = username})
end

function NetClient:activate()
	self:connectTo(serverIp, 6061)
end