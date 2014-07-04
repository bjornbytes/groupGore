PlayerMain = extend(Player)

function PlayerMain:activate()
  self.prev = setmetatable({}, self.meta)
  self.inputs = {}
  self.displaces = {}

  self.alpha = 1
  
  if self.heartbeatSound then self.heartbeatSound:stop() end
  self.heartbeatSound = ctx.sound:loop({sound = 'heartbeat', gui = true})
  if self.heartbeatSound then self.heartbeatSound:pause() end

  ctx.view.target = self

  Player.activate(self)
end

function PlayerMain:get(t)
  if t == tick then
    return self
  else
    return self.prev
  end
end

function PlayerMain:update()
  if self.ded then
    self.ded = timer.rot(self.ded)
    return self:fade()
  end
  
  self.prev.x = self.x
  self.prev.y = self.y
  self.prev.z = self.z
  self.prev.angle = self.angle

  local input = self:readInput()
  self:move(input)
  self:turn(input)
  self:slot(input)
  self:fade()
  
  if self.heartbeatSound then
    if self.health < self.maxHealth * .5 then
      if self.heartbeatSound:isPaused() then self.heartbeatSound:resume() end
      local prc = self.health / self.maxHealth
      self.heartbeatSound:setVolume(math.min(1 - ((prc - .3) / .2), 1.0))
    elseif not self.heartbeatSound:isPaused() then
      self.heartbeatSound:pause()
    end
  end
 
  ctx.net:buffer(msgInput, input)

  Player.update(self)
end

function PlayerMain:draw()
  if self.ded then return end
  local lerpd = table.interpolate(self.prev, self, tickDelta / tickRate)
  self.drawAngle = lerpd.angle
  self.drawX, self.drawY = ctx.view:three(lerpd.x, lerpd.y, lerpd.z)
  self.drawScale = 1 + (ctx.view:convertZ(lerpd.z) / 500)
  Player.draw(lerpd)
end

function PlayerMain:trace(data)
  self.x, self.y = data.x / 10, data.y / 10
  self.health, self.shield = data.health, data.shield

  -- Discard inputs before the ack.
  while #self.inputs > 0 and self.inputs[1].tick < data.ack + 1 do
    table.remove(self.inputs, 1)
  end

  -- Server reconciliation: Apply inputs that occurred after the ack.
  for i = 1, #self.inputs do
    self:move(self.inputs[i])
  end

  self.moving = true
  ctx.collision:update()
  self.moving = nil
end

function PlayerMain:readInput()
  assert(not self.inputs[tick])
  local t = {tick = tick}

  for _, k in pairs({'w', 'a', 's', 'd'}) do
    t[k] = ctx.input:keyDown(k)
  end
  
  t.x = ctx.view:worldMouseX()
  t.y = ctx.view:worldMouseY()
  t.l = ctx.input:mouseDown('l')
  t.r = ctx.input:mouseDown('r')

  for i = 1, 5 do
    if ctx.input:keyDown(tostring(i)) then t.slot = i break end
  end

  t.reload = ctx.input:keyDown('r')

  table.insert(self.inputs, t)

  return t
end

function PlayerMain:fade()
  local s = self.ded and self.killer or self
  local function shouldFade(p)
    if p.team == s.team then return false end
    local vision = s.ded and 2 * math.pi or math.pi / 2
    if math.abs(math.anglediff(s.angle, math.direction(s.x, s.y, p.x, p.y))) > vision then return true end
    return ctx.collision:lineTest(s.x, s.y, p.x, p.y, {tag = 'wall', first = true})
  end

  ctx.players:each(function(p)
    if shouldFade(p) then p.alpha = math.max(p.alpha - tickRate, 0)
    else p.alpha = math.min(p.alpha + tickRate, 1) end
  end)
end

function PlayerMain:hurt(data)
  ctx.view:screenshake(math.clamp(data.amount, 0, 50) / 2)
end

function PlayerMain:die()
  if self.heartbeatSound then self.heartbeatSound:pause() end
  Player.die(self)
  ctx.view:screenshake(20)
  ctx.view.target = nil
  ctx.view.target = self.killer
end
