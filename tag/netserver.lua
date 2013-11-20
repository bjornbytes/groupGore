NetServer = {}

NetServer.signatures = {}
NetServer.signatures[evtJoin] = {{'id', '4bits'}, {'username', 'string'}}
NetServer.signatures[evtLeave] = {{'id', '4bits'}, {'reason', 'string'}}
NetServer.signatures[msgJoin] = {{'id', '4bits'}}
NetServer.signatures[msgSnapshot] = {
	{'tick', '16bits'},
	{'map', 'string'},
	{'clients', {{'id', '4bits'}, {'username', 'string'}}}
}

NetServer.receive = {}
NetServer.receive['default'] = f.empty

NetServer.receive[msgJoin] = function(self, event)
	self.peers[event.peer].username = event.data.username
	self:send(msgJoin, event.peer, {id = self.peers[event.peer].id})
	self:emit(evtJoin, {id = self.peers[event.peer].id, username = event.data.username})

	local ps = {}
	table.with(self.peers, function(p) table.insert(ps, p) end)
	self:send(msgSnapshot, event.peer, {tick = tick, map = 'jungleCarnage', clients = ps})
end

NetServer.receive[msgLeave] = function(self, event)
	self:emit(evtLeave, {id = self.peers[event.peer].id, reason = 'left'})
	self.peers[event.peer] = nil
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
	self.peers[event.peer] = {id = idx}
end

function NetServer:send(msg, peer, data)
	self.outStream:clear()
	self:pack(msg, data)
	peer:send(tostring(self.outStream))
end

function NetServer:emit(evt, data)
	table.insert(self.eventBuffer, {evt, data})
	emit(evt, data)
end

function NetServer:sync()
	self.outStream:clear()
	
	while #self.eventBuffer > 0 do
		self:pack(unpack(self.eventBuffer[1]))
		table.remove(self.eventBuffer, 1)
	end
	
	self.host:broadcast(tostring(self.outStream))
end