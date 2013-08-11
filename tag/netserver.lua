NetServer = {}

function NetServer:activate()
	Udp:listen(6061)
	
	self.clients = {}
	self.clientsByIp = {}
end

function NetServer:update()
	Udp:receive(function(data, ip, port)
		local stream = Stream.create(data)
		local id, client = stream:read(4), self:lookup(ip, port)
		
		if not client and id == Net.msgJoin then
			self.messageHandlers[id](self, ip, port, stream)
		else
			self.messageHandlers[id](self, self:lookup(ip, port), stream)
		end
	end)
end

function NetServer:send(clients, except)
	self.message:write('')
	if type(clients) == 'table' then
		if except then clients[except] = nil end
		for _, client in pairs(clients) do
			Udp:send(self.message, client.ip, client.port)
		end
	else
		local id = clients
		Udp:send(self.message, self.clients[id].ip, self.clients[id].port)
	end
	self.message = nil
end

function NetServer:lookup(ip, port)
	return self.clientsByIp[ip .. port]
end

NetServer.messageHandlers = {
	[Net.msgJoin] = function(self, ip, port, stream)
		local name, listen = stream:read('', 16)
		local ct = 0
	  table.iwith(self.clients, function() ct = ct + 1 end)
		local client = {
			id = ct + 1,
			ip = ip,
			port = listen,
			name = name
		}
		self.clients[client.id] = client
		self.clientsByIp[ip .. port] = client
		
		print('Client ' .. name .. ' joined!  Assigned id ' .. client.id)
		
		Net:begin(Net.msgJoin)
		   :write(client.id, 4)
		   :write(tick, 16)
		   :write(ct, 4)
		   
		for i = 1, 16 do
			if self.clients[i] and i ~= client.id then
				local p = Players:get(i)
				if not p.active then
					Net:write(p.id, 4)
					   :write(self.clients[p.id].name)
					   :write(0, 4)
					   :write(0, 1)
				else
					Net:write(p.id, 4)
					   :write(self.clients[p.id].name)
					   :write(data.classes[p.class], 4)
					   :write(0, 1)
					   :write(p.x, 16)
					   :write(p.y, 16)
				end
			end
		end
		
		Net:send(client.id)
	end,
	
	[Net.msgLeave] = function(self, client, stream)
		for k, v in pairs(self.clientsByIp) do
			if v == client then self.clientsByIp[k] = nil end
		end
		self.clients[client.id] = nil
		table.print(self.clients)
	end,
	
	[Net.msgClass] = function(self, client, stream)
		local class, team = stream:read(4, 1)
		if not Players:get(client.id).active then
			Players:activate(client.id, 'server', class, team)
		else
			local p = Players:get(client.id)
			p.class, p.team = class, team
		end
		
		Net:begin(Net.msgClass)
		   :write(client.id, 4)
		   :write(class, 4)
		   :write(team, 1)
		   :send(self.clients)
	end,
	
	[Net.msgSync] = function(self, client, stream)
		local playerCt = stream:read(4)
		print('Receiving sync for ' .. playerCt .. ' players')
		for _ = 1, playerCt do
			local id = stream:read(4)
			local tickCt = stream:read(6)
			for _ = 1, tickCt do
				local t, flags = stream:read(16, 4)
				local w, a, s, d = stream:read(1, 1, 1, 1)
			  print(t, flags, w, a, s, d)
			end
		end
	end
}