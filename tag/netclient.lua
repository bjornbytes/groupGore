NetClient = {}

function NetClient:activate()
	Udp:listen(0)
	local _, port = Udp.udp:getsockname()
	
	Net:begin(Net.msgInit)
	   :write(username)
	   :write(port, 16)
	   :send()
	
	while not myId do
		Net:receive()
	end
end

function NetClient:update()
	Udp:receive(function(data, ip, port)
		local stream = Stream.create(data)
		local id = stream:read(8)
		self.messageHandlers[id](stream)
	end)
end

function NetClient:send()
	assert(self.message)
	local body = string.char(self.message.header) .. tostring(self.message.stream)
	Udp:send(body, serverIp, serverPort)
	self.message = nil
end

NetClient.receiveHandlers = {
	[Net.msgInit] = function(stream)
		myId = stream:read(4)
	end
}