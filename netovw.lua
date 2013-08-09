Net = {}
Net.msgInit = 1

function Net:load(tag)
	assert(tag)
	
	local tags = {
		client = NetClient,
		server = NetServer
	}
	
	setmetatable(self, {__index = tags[tag]})
	f.exe(self.activate)
end

function Net:begin(header)
	self.message = {}
	self.message.header = header
	self.message.stream = Stream.create()
	return self
end

function Net:write(data, len)
	self.message.stream:write(data, len)
	return self
end

local dir
dir = '/tag'
for _, file in ipairs(love.filesystem.enumerate(dir)) do
  if file:match('net.*\.lua') then love.filesystem.load(dir .. '/' .. file)() end
end