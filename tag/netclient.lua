NetClient = {}

NetClient.signatures = {}
NetClient.signatures[evtJoin] = {{'username', 'string'}}
NetClient.signatures[evtLeave] = {}

function NetClient:activate()
	self:connectTo(serverIp, 6061)
end

function NetClient:connect(event)
	self.server = event.peer
	self:send(evtJoin, {username = username})
end

function NetClient:receive(event)
	self.inStream.str = event.data
	self.inStream.byte, self.inStream.byteLen = nil, nil
	
	while true do
		local e = self.inStream:read('4bits')
		if e == 0 or not self.other.signatures[e] then break end
		
		local data = {}
		for _, sig in ipairs(self.other.signatures[e]) do
			data[sig[1]] = self.inStream:read(sig[2])
		end
		
		emit(e, data)
	end
end