Net = {}
Net.msgJoin = 1
Net.msgLeave = 2

function Net:load(tag)
	assert(tag)
	
	local tags = {
		client = NetClient,
		server = NetServer
	}
	
	setmetatable(self, {__index = tags[tag]})
	f.exe(self.activate, self)
end

function Net:begin(header)
	self.message = Stream.create()
	self.message:write(header, 4)
	return self
end

function Net:write(data, len)
	self.message:write(data, len)
	return self
end

local dir
dir = '/tag'
for _, file in ipairs(love.filesystem.enumerate(dir)) do
  if file:match('net.*\.lua') then love.filesystem.load(dir .. '/' .. file)() end
end