Overwatch = {
	ovws = {},
	toRemove = {}
}

function Overwatch:add(obj, ...)
	local oldovw = ovw
	local o = obj(...)
	table.insert(self.ovws, o)
	ovw = o
	f.exe(ovw.load, ovw, ...)
	ovw = oldovw
	return o
end

function Overwatch:remove(ovw)
	self.toRemove = ovw
end

function Overwatch:clear()
	table.each(self.ovws, f.cur(self.remove, self))
end

setmetatable(Overwatch, {
	__index = function(t, k)
		return function(...)
			local args = {...}
			table.each(t.ovws, function(o)
				ovw = o
				if k == 'update' and t.toRemove == ovw then
					f.exe(ovw.unload, ovw)
					t.ovws = table.filter(t.ovws, function(o) return o ~= ovw end)
					o = nil
				else
					if o[k] then o[k](o, unpack(args)) end
				end
				ovw = nil
			end)
		end
	end
})