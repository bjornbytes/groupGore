NetServer = {}

function NetServer:activate()
	Udp:listen(6061)
end

function NetServer:update()
	Udp:receive(function(data, ip, port)
		local id = data:byte(1)
		self.messageHandlers[id](self, data, ip, port)
	end)
end

function NetServer:send(data, client)
	Udp:send(data, client.ip, client.port)
end

function NetServer:sendAll(data)
	--
end

NetServer.messageHandlers = {
	[0] = function(self, data, ip, port)
		--
	end,
	
	[1] = function(self, data, ip, port)
		--
	end
}