NetClient = {}

NetClient.signatures = {}
NetClient.signatures[msgJoin] = {{'username', 'string'}}
NetClient.signatures[msgLeave] = {}

NetClient.receive = {}
NetClient.receive['default'] = function(self, event) emit(event.msg, event.data) end

NetClient.receive[msgJoin] = function(self, event)
	print('myId', event.data.id)
end

NetClient.receive[msgSnapshot] = function(self, event)
	print(event.data.tick)
	print(event.data.map)
	print(#event.data.clients)
end

function NetClient:activate()
	self:connectTo(serverIp, 6061)
	
	on(evtJoin, self, function(self, data)
		print(data.username .. ' has joined!')
	end)
	
	on(evtLeave, self, function(self, data)
		print('Player ' .. data.id .. ' has left!')
	end)
end

function NetClient:connect(event)
	self.server = event.peer
	self:send(msgJoin, {username = username})
end

function NetClient:send(msg, data)
	self.outStream:clear()
	self:pack(msg, data)
	self.server:send(tostring(self.outStream))
end

function NetClient:sync()
	--
end