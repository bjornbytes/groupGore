Overwatch = {
	ovws = {},
	toRemove = {}
}

function Overwatch:add(obj)
	local oldovw = ovw
	local o = obj()
	table.insert(self.ovws, o)
	ovw = o
	ovw:load()
	ovw = oldovw
end

function Overwatch:remove(ovw)
	self.toRemove = ovw
end

setmetatable(Overwatch, {
	__index = function(t, k)
		return function(...)
			local args = {...}
			table.with(t.ovws, function(o)
				ovw = o
				if k == 'update' and t.toRemove == ovw then
					ovw:unload()
					t.ovws = table.filter(t.ovws, function(o) return o ~= ovw end)
				else
					if o[k] then o[k](o, unpack(args)) end
				end
				ovw = nil
			end)
		end
	end
})