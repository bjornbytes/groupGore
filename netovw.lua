Net = {}
Net.msgJoin = 1
Net.msgClass = 2
Net.msgSync = 3

function Net:load(tag)
	assert(tag)
	
	local tags = {
		client = NetClient,
		server = NetServer
	}
	
	setmetatable(self, {__index = tags[tag]})
	f.exe(self.activate, self)
end

function Net:listen(port)
	self.host = enet.host_create(port and 'localhost:' .. port or port)
end

function Net:connectTo(ip, port)
	if not self.host then self:listen() end
	self.host:connect(ip .. ':' .. port)
end

function Net:update()
	local event = self.host:service()
	while event do	
		if event and event.type == 'receive' then
			local id = event.data:byte(1)
			local data = Stream.unpack(event.data:sub(2), self.signatures.inbound[id])
			f.exe(self.receive[id], self, data, event.peer)
		else
			f.exe(self[event.type], self, event.peer)
		end
		event = self.host:service()
	end
end

function Net:send(id, peer, data)
	local str = Stream.pack(data, self.signatures.outbound[id]):truncate()
	peer:send(string.char(id) .. str)
end

function Net:broadcast(id, data)
	local str = Stream.pack(data, self.signatures.outbound[id]):truncate()
	self.host:broadcast(string.char(id) .. str)
end

local dir
dir = '/tag'
for _, file in ipairs(love.filesystem.getDirectoryItems(dir)) do
  if file:match('net.*\.lua') then love.filesystem.load(dir .. '/' .. file)() end
end
NetClient.signatures.inbound = NetServer.signatures.outbound
NetServer.signatures.inbound = NetClient.signatures.outbound
