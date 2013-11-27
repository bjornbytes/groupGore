Event = {}

Event.handlers = {}

function on(event, context, fn)
	Event.handlers[event] = Event.handlers[event] or {}
	table.insert(Event.handlers[event], {context, fn})
end

function emit(event, data)
	if not Event.handlers[event] then return end
	for _, t in ipairs(Event.handlers[event]) do
		local context, fn = unpack(t)
		fn(context, data)
	end
end
