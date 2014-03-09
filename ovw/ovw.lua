Overwatch = class()

function Overwatch:addComponent(child, options, ...)
	options = options or {}
	local priority = options.priority or 5
	options.priority = nil
	
	self.components = self.components or {}
	self.components[priority] = self.components[priority] or {}
	self.components[child] = child(...)
	table.insert(self.components[priority], {object = self.components[child], options = options})

	self:compileComponents()
	
	return self.components[child]
end

function Overwatch:getComponent(component)
	return self.components[component]
end

function Overwatch:removeComponent(component)
	for i = 1, 10 do
		for i, c in pairs(self.components[i]) do
			if c == self.components[component] then table.remove(self.components[i], i) break end
		end
	end
	
	self.components[component] = nil
	self:compileComponents()
end

function Overwatch:compileComponents()
	self.callbacks = {}
	local events = {'update', 'draw', 'keypressed', 'keyreleased', 'textinput', 'mousepressed', 'mousereleased', 'resize'}
	for i = 1, 10 do
		table.each(self.components[i], function(t)
			local handlers = t.object
			if t.options.only then handlers = table.only(handlers, t.options.only)
			elseif t.options.except then handlerse = table.except(handlers, t.options.except)
			else handlers = table.only(handlers, events) end
			table.each(events, function(event)
				if handlers[event] then
					self.callbacks[event] = self.callbacks[event] or {}
					table.insert(self.callbacks[event], t.object)
				end
			end)
		end)
	end
	
	table.each(events, function(event)
		if not self[event] then
			self[event] = Overwatch.run(self, event)
		end
	end)
end

function Overwatch:run(key)
	if self.callbacks[key] then
		return function(...)
			for _, obj in pairs(self.callbacks[key]) do
				obj[key](obj, ...)
			end
		end
	end
	
	return f.empty
end