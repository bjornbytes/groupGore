NetClient = {}

function NetClient:activate()
	Udp:listen(0)
	local _, port = Udp.udp:getsockname()
	
	self.clients = {}
	
	Net:begin(Net.msgJoin)
	   :write(username)
	   :write(port, 16)
	   :send()
	
	while not myId do
		Net:update()
	end
end

function NetClient:update()
	Udp:receive(function(data, ip, port)
		local stream = Stream.create(data)
		local id = stream:read(4)
		self.messageHandlers[id](self, stream)
	end)
end

function NetClient:send()
	assert(self.message)
	self.message:write('')
	Udp:send(self.message, serverIp, serverPort)
	self.message = nil
end

NetClient.messageHandlers = {
	[Net.msgJoin] = function(self, stream)
		myId, tick = stream:read(4, 16)
		local ct = stream:read(4)
		for i = 1, ct do
			local id, name, class, team = stream:read(4, '', 4, 1)
			
			self.clients[id] = {
				id = id,
				name = name
			}
			
			if class > 0 then
				Players:activate(id, 'dummy', data.class.brute)
				local p = Players:get(id)
				p.x, p.y = stream:read(16, 16)
			end
		end
		print('myId is ' .. myId)
	end,
	
	[Net.msgLeave] = function(self, stream)
		local id = stream:read(4)
		Players:deactivate(id)
		self.clients[id] = nil
		print('Someone left.')
	end,
	
	[Net.msgClass] = function(self, stream)
		local id, class, team = stream:read(4, 4, 1)
		if not Players:get(id).active then
			local tag = id == myId and 'main' or 'dummy'
			Players:activate(id, tag, class, team)
		else
			Players:setClass(id, class, team)
		end
	end
}