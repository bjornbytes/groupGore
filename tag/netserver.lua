NetServer = {}

NetServer.signatures = {}
NetServer.signatures[evtJoin] = {{'tick', '16bits'}, {'map', 'string'}}
NetServer.signatures[evtLeave] = {{'id', '4bits'}}

function NetServer:activate()
	self:listen(6061)
	self.peers = {}
	
	on(evtJoin, self, function(self, data)
		print(data.username .. ' has joined!')
	end)
end

function NetServer:connect(event)
	local idx = event.peer:index()
	self.peers[event.peer] = idx
	self.peers[idx] = event.peer
end

function NetServer:receive(event)
	self.inStream.str = event.data
	self.inStream.byte, self.inStream.byteLen = nil, nil
	
	while true do
		local e = self.inStream:read('4bits')
		if e == 0 or not self.other.signatures[e] then break end
		
		local data = {}
		for _, sig in ipairs(self.other.signatures[e]) do
			data[sig[1]] = self.inStream:read(sig[2])
		end
		
		data.from = self.peers[event.peer] or event.peer
		emit(e, data)
	end
end