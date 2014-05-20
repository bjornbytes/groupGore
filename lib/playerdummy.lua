PlayerDummy = extend(Player)

function PlayerDummy:activate()
  Player.activate(self)
end

function PlayerDummy:draw()
  if self.ded then return end
  local t = tick - (interp / tickRate) + (tickDelta / tickRate)
  local p = ctx.players:get(self.id, t)
  if p then Player.draw(p) end
end

function PlayerDummy:drawPosition()
  local t = tick - (interp / tickRate)
  local prev, cur = ctx.players.history[self.id][t - 1], ctx.players.history[self.id][t]
  if prev and cur then
    prev, cur = {x = prev.x, y = prev.y}, {x = cur.x, y = cur.y}
    local interp = table.interpolate(prev, cur, tickDelta / tickRate)
    return interp.x, interp.y
  end
  
  return 0, 0
end

function PlayerDummy:trace(data)
  local t = data.tick
  data.tick = nil
  data.id = nil
  if data.angle then data.angle = math.rad(data.angle) end
  --[[for i = t, tick do
    table.merge(data, ctx.players:get(self.id, i))
  end]]
  table.merge(data, self)
end
