NetServer = {}

NetServer.signatures = {}
NetServer.signatures[evtJoin] = {{'id', '4bits'}, {'username', 'string'}}
NetServer.signatures[evtLeave] = {{'id', '4bits'}, {'reason', 'string'}}
NetServer.signatures[msgJoin] = {{'tick', '16bits'}, {'map', 'string'}}

NetServer.receive = {}
NetServer.receive['default'] = f.empty

NetServer.receive[msgJoin] = function(self, event)
	self:send(msgJoin, event.peer, {tick = tick, map = 'jungleCarnage'})
	self:emit(evtJoin, {id = self.peers[event.peer], username = event.data.username})
end

NetServer.receive[msgLeave] = function(self, event)
	self:emit(evtLeave, {id = self.peers[event.peer], reason = 'left'})
	event.peer:disconnect_now()
end

function NetServer:activate()
	self:listen(6061)
	
	self.peers = {}
	self.eventBuffer = {}
	
	on(evtJoin, self, function(self, data)
		print(data.username .. ' has joined!')
	end)
	
	on(evtLeave, self, function(self, data)
		print('Player ' .. data.id .. ' has left!')
	end)
end

function NetServer:connect(event)
	local idx = event.peer:index()
	self.peers[event.peer] = idx
end

function NetServer:send(msg, peer, data)
	self.outStream:clear()
	self.outStream:write(msg, '4bits')
	
	for _, sig in ipairs(self.signatures[msg]) do
		self.outStream:write(data[sig[1]], sig[2])
	end
	
	peer:send(tostring(self.outStream))
end

function NetServer:emit(evt, data)
	table.insert(self.eventBuffer, {evt, data})
	emit(evt, data)
end

function NetServer:sync()
	self.outStream:clear()
	
	while #self.eventBuffer > 0 do
		local evt, data = unpack(self.eventBuffer[1])
		
		self.outStream:write(evt, '4bits')
		for _, sig in ipairs(self.signatures[evt]) do
			self.outStream:write(data[sig[1]], sig[2])
		end
		
		table.remove(self.eventBuffer, 1)
	end
	
	self.host:broadcast(tostring(self.outStream))
end