Event = class()

function Event:init()
	self.handlers = {}
end

function Event:on(event, context, fn)
	self.handlers[event] = self.handlers[event] or {}
	table.insert(self.handlers[event], {context, fn})
end

function Event:emit(event, data)
	if not self.handlers[event] then return end
	for _, t in ipairs(self.handlers[event]) do
		local context, fn = unpack(t)
		fn(context, data)
	end
end
