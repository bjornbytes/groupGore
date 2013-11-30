Overwatch = {
	ovws = {}
}

function Overwatch:add(obj)
	local o = obj()
	table.insert(self.ovws, o)
	ovw = o
	ovw:load()
	ovw = nil
end

function Overwatch:remove(ovw)
	ovw:unload()
	self.ovws = table.filter(self.ovws, function(o) return o ~= ovw end)
end

setmetatable(Overwatch, {
	__index = function(t, k)
		return function(...)
			local args = {...}
			table.with(t.ovws, function(o)
				ovw = o
				if o[k] then o[k](o, unpack(args)) end
				ovw = nil
			end)
		end
	end
})