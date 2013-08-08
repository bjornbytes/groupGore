NetClient = {}

function NetClient:activate()
	Udp:listen(0)
end

function NetClient:update()
	Udp:receive(function(data, ip, port)
		local id = data:byte(1)
		self.messageHandlers[id](self, data, ip, port)
	end)
end

function NetClient:send(data)
	Udp:send(data, serverIp, serverPort)
end

NetClient.messageHandlers = {
	[0] = function(self, data, ip, port)
		--
	end,
	
	[1] = function(self, data, ip, port)
		--
	end
}