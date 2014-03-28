Event = class()

function Event:init()
	self.handlers = {}
end

function Event:on(event, fn)
	self.handlers[event] = self.handlers[event] or {}
	table.insert(self.handlers[event], fn)
end

function Event:emit(event, data)
	if not self.handlers[event] then return end
	for _, fn in ipairs(self.handlers[event]) do
		fn(data)
	end
end
