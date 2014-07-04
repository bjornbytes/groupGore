PlayerDummy = extend(Player)

local function drawTick() return tick - (interp / tickRate) end

function PlayerDummy:activate()
  self.history = {}

  Player.activate(self)
end

function PlayerDummy:update()
  self:slot()
  
  Player.update(self)
end

function PlayerDummy:get(t)
  if t == tick then return self end
  
  if #self.history < 2 then
    return setmetatable({
      x = self.x,
      y = self.y,
      z = self.z,
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
  local lerpd = table.interpolate(self:get(drawTick()), self:get(drawTick() + 1), tickDelta / tickRate)
  self.drawAngle = lerpd.angle
  self.drawX, self.drawY = ctx.view:three(lerpd.x, lerpd.y, lerpd.z)
  self.drawScale = 1 + (ctx.view:convertZ(lerpd.z) / 500)
  Player.draw(lerpd)
end

function PlayerDummy:trace(data)
  if data.angle then data.angle = math.rad(data.angle) end
  if data.x then data.x = data.x / 10 end
  if data.y then data.y = data.y / 10 end
  
  table.insert(self.history, setmetatable({
    x = data.x,
    y = data.y,
    z = data.z,
    angle = data.angle,
    tick = data.tick
  }, self.meta))

  self.x, self.y, self.z, self.angle = data.x, data.y, data.z, data.angle
  self.health, self.shield = data.health or self.health, data.shield or self.shield
  self.weapon, self.skill = data.weapon or self.weapon, data.skill or self.skill
end
