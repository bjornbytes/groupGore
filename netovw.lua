Net = {}

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
	while true do
		local event = self.host:service()
		if not event then break end
		
		if event.type ~= 'receive' then f.exe(self[event.type], self, event.peer)
		else
			while #event.data do
				local str, e, data = readEvent(event.data)
				event.data = str
				Event:emit(e, data)
			end
		end
	end
end

function Net:sync()
	-- send all buffered events
end

local function readEvent(str)
	--
end

local function writeEvent(event, data)
	--
end

local dir
dir = '/tag'
for _, file in ipairs(love.filesystem.getDirectoryItems(dir)) do
  if file:match('net.*\.lua') then love.filesystem.load(dir .. '/' .. file)() end
end
