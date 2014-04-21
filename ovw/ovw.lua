Overwatch = {
  ovws = {},
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
  for i = #self.ovws, 1, -1 do
    ovw = self.ovws[i]
    if ovw[key] then ovw[key](ovw, ...) end
    ovw = nil
  end
end

function Overwatch:remove(ovw)
  for i = 1, #self.ovws do
    if self.ovws[i] == ovw then
      return table.remove(self.ovws, i)
    end
  end
end

function Overwatch:clear()
  table.each(self.ovws, f.cur(self.remove, self))
end

setmetatable(Overwatch, {
  __index = function(t, k)
    return function(...) return t:run(k, ...) end
  end
})
