Event = {}

Event.handlers = {}

function Event:init(tag)
	if tag == 'client' then emit = f.empty end
end

function on(event, context, fn)
	Event.handlers[event] = Event.handlers[event] or {}
	table.insert(Event.handlers[event], {context, fn})
end


function emit(event, data)
	for _, t in ipairs(Event.handlers[event]) do
		local context, fn = unpack(t)
		fn(context, data)
	end
	Net:emit(event, data)
end
