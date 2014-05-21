Context = {
  list = {},
}

function Context:add(obj, ...)
  local c = obj(...)
  table.insert(self.list, c)
  
  local tmp = ctx
  ctx = c
  f.exe(ctx.load, ctx, ...)
  ctx = tmp
  
  return c
end

function Context:run(key, ...)
  for i = #self.list, 1, -1 do
    ctx = self.list[i]
    if key == 'update' then
      ctx.tick = ctx.tick or 0
      ctx.tick = ctx.tick + 1
    end
    tick = ctx.tick
    if ctx[key] then ctx[key](ctx, ...) end
    ctx = nil
    tick = nil
  end
end

function Context:remove(ctx)
  for i = 1, #self.list do
    if self.list[i] == ctx then
      return table.remove(self.list, i)
    end
  end
end

function Context:clear()
  table.each(self.list, f.cur(self.remove, self))
end

setmetatable(Context, {
  __index = function(t, k)
    return function(...) return t:run(k, ...) end
  end
})
