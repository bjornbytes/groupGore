PlayerMain = extend(Player)

function PlayerMain:activate()
  self.prev = setmetatable({}, {__index = self})
  self.inputs = {}

  self.alpha = 1
  
  self.lastHurt = tick
  self.heartbeatSound = ctx.sound:loop({sound = 'heartbeat'})
  self.heartbeatSound:pause()

  ctx.view:setTarget(self)

  Player.activate(self)
end

function PlayerMain:deactivate()
  ctx.view:setTarget(nil)
  
  Player.deactivate(self)
end

function PlayerMain:get(t)
  assert(t == tick or t == tick - 1)
  if t == tick then
    return self
  else
    return self.prev
  end
end

function PlayerMain:update()
  if self.ded then return end
  
  self.prev.x = self.x
  self.prev.y = self.y
  self.prev.angle = self.angle

  local input = self:readInput()
  self:move(input)
  self:turn(input)
  self:slot(input)
  self:fade()
  
  if self.health < self.maxHealth * .5 then
    if self.heartbeatSound:isPaused() then self.heartbeatSound:resume() end
    local prc = self.health / self.maxHealth
    self.heartbeatSound:setVolume(math.min(1 - ((prc - .3) / .2), 1.0))
  elseif not self.heartbeatSound:isPaused() then
    self.heartbeatSound:pause()
  end
 
  ctx.net:buffer(msgInput, self.inputs[#self.inputs])
end

function PlayerMain:draw()
  if self.ded then return end

  Player.draw(table.interpolate(self.prev, self, tickDelta / tickRate))

  if love.keyboard.isDown(' ') then
    local server
    for i = 1, #Context.list do
      local c = Context.list[i]
      if c and c.tag and c.tag == 'server' then
        server = c
        break
      end
    end

    if server then
      Player.draw(server.players:get(self.id))
    end
  end
end

function PlayerMain:trace(data)
  self.x, self.y = data.x, data.y
  self.health, self.shield = data.health, data.shield

  -- Discard inputs before the ack.
  while #self.inputs > 0 and self.inputs[1].tick < data.ack + 1 do
    table.remove(self.inputs, 1)
  end
 
  -- Server reconciliation: Apply inputs that occurred after the ack.
  for i = 1, #self.inputs do
    self:move(self.inputs[i])
  end
end

function PlayerMain:readInput()
  assert(not self.inputs[tick])
  local t = {tick = tick}
  
  for _, k in pairs({'w', 'a', 's', 'd'}) do
    t[k] = love.keyboard.isDown(k)
  end
  
  t.x = ctx.view:mouseX()
  t.y = ctx.view:mouseY()
  t.l = love.mouse.isDown('l')
  t.r = love.mouse.isDown('r')

  for i = 1, 5 do
    if love.keyboard.isDown(tostring(i)) then t.slot = i break end
  end

  t.reload = love.keyboard.isDown('r')

  table.insert(self.inputs, t)

  return t
end

function PlayerMain:fade()
  local function shouldFade(p)
    if p.team == self.team then return false end
    if math.abs(math.anglediff(self.angle, math.direction(self.x, self.y, p.x, p.y))) > math.pi / 2 then return true end
    return ctx.collision:lineTest(self.x, self.y, p.x, p.y, {tag = 'wall', first = true})
  end

  ctx.players:each(function(p)
    if shouldFade(p) then p.alpha = math.max(p.alpha - tickRate, 0)
    else p.alpha = math.min(p.alpha + tickRate, 1) end
  end)
end

function PlayerMain:drawPosition()
  local p = table.interpolate(self.prev, self, tickDelta / tickRate)
  return p.x, p.y
end

function PlayerMain:hurt()
  self.lastHurt = tick
end

function PlayerMain:die()
  self.heartbeatSound:pause()
  Player.die(self)
end
