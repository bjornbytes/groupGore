PlayerDummy = extend(Player)

local function drawTick() return tick - (interp / tickRate) end

function PlayerDummy:activate()
  self.history = {}
  self.dinosaur = setmetatable({}, self)

  Player.activate(self)
end

function PlayerDummy:get(t)
  
  -- The most recent received snapshot is merged into self for convenience.
  if t == tick then return self end

  -- Search backwards through history until we find something.
  for i = t, drawTick() - 1, -1 do
    if self.history[i] then return self.history[i] end
  end

  -- If we don't have anything in history, just return dinosaur.
  return self.dinosaur
end

function PlayerDummy:draw()
  if self.ded then return end
  
  local t = drawTick()
  table.interpolate(self:get(t), self:get(t + 1), tickDelta / tickRate):draw()
end

function PlayerDummy:drawPosition()
  local p = table.interpolate(self:get(drawTick()), self:get(drawTick() + 1), tickDelta / tickRate)
  return p.x, p.y
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
