Net = {}

evtJoin  = 1
evtLeave = 2

msgJoin  = 3
msgLeave = 4

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
		
		if event.type == 'receive' then
			self.inStream:clear()
			self.inStream.str = event.data
			
			while true do 
				event.msg = self.inStream:read('4bits')
				if event.msg == 0 or not self.other.signatures[event.msg] then break end			
				
				local data = {}
				for _, sig in ipairs(self.other.signatures[event.msg]) do
					data[sig[1]] = self.inStream:read(sig[2])
				end
				
				event.data = data
				;(self.receive[event.msg] or self.receive.default)(self, event)
			end
		else
			f.exe(self[event.type], self, event)
		end
	end
end

local dir
dir = '/tag'
for _, file in ipairs(love.filesystem.getDirectoryItems(dir)) do
  if file:match('net.*%.lua') then love.filesystem.load(dir .. '/' .. file)() end
end
NetClient.other = NetServer
NetServer.other = NetClient
