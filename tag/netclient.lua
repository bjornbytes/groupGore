NetClient = {}

NetClient.signatures = {}
NetClient.signatures[msgJoin] = {{'username', 'string'}}
NetClient.signatures[msgLeave] = {}
NetClient.signatures[msgClass] = {{'class', '4bits'}, {'team', '1bit'}}
NetClient.signatures[msgInput] = {
	{'tick', '16bits'},
	{'w', 'bool'}, {'a', 'bool'}, {'s', 'bool'}, {'d', 'bool'},
	{'mx', '12bits'}, {'my', '12bits'}, {'l', 'bool'}, {'r', 'bool'},
	{'weapon', '3bits'}, {'skill', '3bits'}, {'reload', 'bool'}
}

NetClient.receive = {}
NetClient.receive['default'] = function(self, event) emit(event.msg, event.data) end

NetClient.receive[msgJoin] = function(self, event)
	myId = event.data.id
	setmetatable(Players:get(myId), {__index = PlayerMain})
end

NetClient.receive[msgSnapshot] = function(self, event)
	table.print(event.data)
	tick = event.data.tick
	Map:load(event.data.map)
	for i = 1, #event.data.players do
		local p = event.data.players[i]
		if p.class > 0 then
			Players:activate(p.id)
			Players:setClass(p.id, p.class, p.team)
		end
	end
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
	
	on(evtSync, self, function(self, data)
		local p = Players:get(data.id)
		if p.id ~= myId then
			local t = data.tick
			data.tick = nil
			data.id = nil
			data.angle = math.rad(data.angle)
			for i = t, tick do
				local dst = Players.history[p.id][i]
				if i == tick then dst = p end
				table.merge(data, dst)
			end
		end
	end)
end

function NetClient:connect(event)
	self.server = event.peer
	self:send(msgJoin, {username = username})
end

function NetClient:send(msg, data)
	if not self.server then return end
	
	self.outStream:clear()
	self:pack(msg, data)
	self.server:send(tostring(self.outStream))
end

function NetClient:buffer(msg, data)
	table.insert(self.messageBuffer, {msg, data})
end

function NetClient:sync()
	if #self.messageBuffer == 0 then return end
	
	self.outStream:clear()
	
	while #self.messageBuffer > 0 do
		self:pack(unpack(self.messageBuffer[1]))
		table.remove(self.messageBuffer, 1)
	end
	
	self.server:send(tostring(self.outStream))
end

NetClient.emit = f.empty