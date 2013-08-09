NetServer = {}

function NetServer:activate()
	Udp:listen(6061)
	
	self.clients = {}
	self.clientsByIp = {}
end

function NetServer:update()
	Udp:receive(function(data, ip, port)
		local stream = Stream.create(data)
		local id, client = stream:read(8), self:lookup(ip, port)
		
		if not client and id = Net.msgInit then
			self.messageHandlers[id](ip, port, stream)
		else
			self.messageHandlers[id](self:lookup(ip, port), stream)
		end
	end)
end

function NetServer:send(clients, except)
	local body = string.char(self.message.header) .. tostring(self.message.stream)
	if type(clients) == 'table' then
		if except then clients[except] = nil end
		for _, client in pairs(clients) do
			Udp:send(body, client.ip, client.port)
		end
	else
		Udp:send(body, clients.ip, clients.port)
	end
	self.message = nil
end

function NetServer:lookup(ip, port)
	return self.clientsByIp[ip .. port]
end

NetServer.messageHandlers = {
	[1] = function(ip, port, stream)
		local name, listen = stream:read('', 16)
		local client = Client.create(ip, port, name, listen)
		self.clients[client.id] = client
		self.clientsByIp[ip .. port] = client
		
		Net:begin(Net.msgInit)
		   :write(client.id, 4)
		   :send(client)
	end
}