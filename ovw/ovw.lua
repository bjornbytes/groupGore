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

function Overwatch:run(key, ...)
	local i = 1
	while i <= #self.ovws do
		ovw = self.ovws[i]
		if key == 'update' and table.has(self.toRemove, ovw) then
			f.exe(ovw.unload, ovw)
			table.remove(self.ovws, i)
		else
			if ovw[key] then ovw[key](ovw, ...) end
			i = i + 1
		end
		ovw = nil
	end
end

function Overwatch:remove(ovw)
	table.insert(self.toRemove, ovw)
end

function Overwatch:clear()
	table.each(self.ovws, f.cur(self.remove, self))
end

setmetatable(Overwatch, {
	__index = function(t, k)
		return function(...) return t:run(k, ...) end
	end
})