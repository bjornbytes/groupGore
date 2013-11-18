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
	self.host = enet.host_create(port and 'localhost:' .. port or 'localhost:6061')
end

function Net:connectTo(ip, port)
	if not self.host then self:listen() end
	remotePeer = self.host:connect(ip .. ':' .. port)
end

function Net:update()
	if remotePeer then print(remotePeer:state()) end
	while true do
		local event = self.host:service()
		if not event then break end
		
		if event.type ~= 'receive' then f.exe(self[event.type], self, event.peer)
		else
			self.inStream.str = event.data
			self.inStream.byte, self.inStream.byteLen = nil, nil
			
			while true do
				local e = self.inStream:read('4bits')
				if e == 0 or not self.other.signatures[e] then break end
				
				local data = {}
				for _, sig in ipairs(self.other.signatures[e]) do
					data[sig[1]] = self.inStream:read(sig[2])
				end
				
				emit(e, data)
			end
		end
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
  if file:match('net.*\.lua') then love.filesystem.load(dir .. '/' .. file)() end
end
NetClient.other = NetServer
NetServer.other = NetClient