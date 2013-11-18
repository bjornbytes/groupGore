Net = {}

function Net:load(tag)
	assert(tag)
	
	local tags = {
		client = NetClient,
		server = NetServer
	}
	
	self.inStream = Stream()
	self.outStream = Stream()
	
	setmetatable(self, {__index = tags[tag]})
	f.exe(self.activate, self)
end

function Net:listen(port)
	self.host = enet.host_create(port and '*:' .. port or nil)
end

function Net:connectTo(ip, port)
	if not self.host then self:listen() end
	self.host:connect(ip .. ':' .. port)
end

function Net:update()
	while true do
		local event = self.host:service()
		if not event then break end
		
		f.exe(self[event.type], self, event)
	end
end

function Net:sync()
	self.host:broadcast(tostring(self.outStream))
	self.outStream.str = ''
end

function Net:send(event, data)
	self.outStream:write(event, '4bits')
	for _, sig in ipairs(self.signatures[event]) do
		self.outStream:write(data[sig[1]], sig[2])
	end
end

local dir
dir = '/tag'
for _, file in ipairs(love.filesystem.getDirectoryItems(dir)) do
  if file:match('net.*%.lua') then love.filesystem.load(dir .. '/' .. file)() end
end
NetClient.other = NetServer
NetServer.other = NetClient