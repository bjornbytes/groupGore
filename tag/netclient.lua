NetClient = {}

function NetClient:activate()
	Udp:listen(0)
	local _, port = Udp.udp:getsockname()
	
	Net:begin(Net.msgInit)
	   :write(username)
	   :write(port, 16)
	   :send()
end

function NetClient:send()
	assert(self.message)
	local body = string.char(self.message.header) .. tostring(self.message.stream)
	Udp:send(body, serverIp, serverPort)
	self.message = nil
end

NetClient.receiveHandlers = {
	[0] = function(self, data, ip, port)
		--
	end,
	
	[1] = function(self, data, ip, port)
		--
	end
}