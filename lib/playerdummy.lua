PlayerDummy = extend(Player)

local function drawTick() return tick - (interp / tickRate) end

function PlayerDummy:activate()
  self.history = {}

  Player.activate(self)
end

function PlayerDummy:update()
  if self.recoil > 0 then self.recoil = math.lerp(self.recoil, 0, math.min(5 * tickRate, 1)) end
  self:slot()
end

function PlayerDummy:get(t)
  if t == tick then return self end
  
  if #self.history < 2 then
    return setmetatable({
      x = self.x,
      y = self.y,
      angle = self.angle,
      tick = tick,
    }, self.meta)
  end

  while self.history[1].tick < tick - 1 / tickRate and #self.history > 2 do
    table.remove(self.history, 1)
  end
 
  -- Extrapolate if needed.
  if self.history[#self.history].tick < t then
    local h1, h2 = self.history[#self.history - 1], self.history[#self.history]
    local factor = math.min(1 + ((t - h2.tick) / (h2.tick - h1.tick)), .1 / tickRate)
    local t = table.interpolate(h1, h2, factor)
    t.angle = h2.angle
    return t
  end

  -- Search backwards through history until we find something.
  for i = #self.history, 1, -1 do
    if self.history[i].tick <= t then return self.history[i] end
  end

  return self.history[1]
end

function PlayerDummy:draw()
  if self.ded then return end
  local p = table.interpolate(self:get(drawTick()), self:get(drawTick() + 1), tickDelta / tickRate)
  Player.draw(p)
end

function PlayerDummy:trace(data)
  if data.angle then data.angle = math.rad(data.angle) end
  
  table.insert(self.history, setmetatable({
    x = data.x,
    y = data.y,
    angle = data.angle,
    tick = data.tick
  }, self.meta))

  self.x, self.y, self.angle = data.x, data.y, data.angle
  self.health, self.shield = data.health or self.health, data.shield or self.shield
  self.weapon, self.skill = data.weapon or self.weapon, data.skill or self.skill
  ctx.event:emit('collision.move', {object = self, x = self.x, y = self.y})
end

function PlayerDummy:drawPosition()
  local p = table.interpolate(self:get(drawTick()), self:get(drawTick() + 1), tickDelta / tickRate)
  return p.x, p.y
end
