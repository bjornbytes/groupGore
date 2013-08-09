NetServer = {}

function NetServer:activate()
	Udp:listen(6061)
end

function NetServer:send(clients, except)
	assert(self.message)
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

NetServer.messageHandlers = {
	[0] = function(self, data, ip, port)
		--
	end,
	
	[1] = function(self, data, ip, port)
		--
	end
}