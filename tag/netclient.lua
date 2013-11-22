NetClient = {}

NetClient.signatures = {}
NetClient.signatures[msgJoin] = {{'username', 'string'}}
NetClient.signatures[msgLeave] = {}
NetClient.signatures[msgClass] = {{'class', '4bits'}, {'team', '1bit'}}

NetClient.receive = {}
NetClient.receive['default'] = function(self, event) emit(event.msg, event.data) end

NetClient.receive[msgJoin] = function(self, event)
	myId = event.data.id
	setmetatable(Players:get(myId), {__index = PlayerMain})
end

NetClient.receive[msgSnapshot] = function(self, event)
	tick = event.data.tick
	Map:load(event.data.map)
end

function NetClient:activate()
	self:connectTo(serverIp, 6061)
	self.messageBuffer = {}
	
	on(evtJoin, self, function(self, data)
		print(data.username .. ' has joined!')
	end)
	
	on(evtLeave, self, function(self, data)
		print('Player ' .. data.id .. ' has left!')
	end)
	
	on(evtClass, self, function(self, data)
		Players:setClass(data.id, data.class, data.team)
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

function NetClient:buffer(msg, data)
	table.insert(self.messageBuffer, {msg, data})
end

function NetServer:sync()
	if #self.messageBuffer == 0 then return end
	
	self.outStream:clear()
	
	while #self.messageBuffer > 0 do
		self:pack(unpack(self.messageBuffer[1]))
		table.remove(self.messageBuffer, 1)
	end
	
	self.server:send(tostring(self.outStream))
end