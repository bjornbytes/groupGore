PlayerMain = {}
setmetatable(PlayerMain, {__index = Player})

function PlayerMain:activate()
  self.input = {}
  
  self.input.w = false
  self.input.a = false
  self.input.s = false
  self.input.d = false
  
  self.input.mx = 0
  self.input.my = 0
  self.input.l = false
  self.input.r = false
  
  self.input.weapon = 1
  self.input.skill = 1
  while self.slots[self.input.skill].type ~= 'skill' do self.input.skill = self.input.skill + 1 end
  self.input.reload = false
  
  self.visible = 1
  
  self.heartbeatSound = ovw.sound:loop('heartbeat')
  self.heartbeatSound:pause()

  Player.activate(self)
end

function PlayerMain:deactivate()
  self.input = nil
  
  Player.deactivate(self)
end

function PlayerMain:update()
  if self.ded then return end
  
  self:poll()
  self:move()
  self:turn()
  self:slot()
  self:fade()
  
  if self.health < self.maxHealth * .5 then
    if self.heartbeatSound:isPaused() then self.heartbeatSound:resume() end
    local prc = self.health / self.maxHealth
    self.heartbeatSound:setVolume(math.min(1 - ((prc - .3) / .2), 1.0))
  elseif not self.heartbeatSound:isPaused() then
    self.heartbeatSound:pause()
  end
  
  ovw.net:buffer(msgInput, table.merge({tick = tick}, table.copy(self.input)))
  
  Player.update(self)
end

function PlayerMain:draw()
  if self.ded then return end

  local p = ovw.players:get(self.id, tick - 1 + tickDelta / tickRate)
  if p then Player.draw(p) end
end

function PlayerMain:drawPosition()
  local p = ovw.players:get(self.id, tick - 1 + tickDelta / tickRate)
  if p then return p.x, p.y end
  return 0, 0
end

function PlayerMain:poll()
  self.input.mx, self.input.my = mouseX(), mouseY()
end

function PlayerMain:fade()
  local function shouldFade(p)
    if p.team == self.team then return false end
    if math.abs(math.anglediff(self.angle, math.direction(self.x, self.y, p.x, p.y))) > math.pi / 2 then return true end
    return ovw.collision:lineTest(self.x, self.y, p.x, p.y, {tag = 'wall', first = true})
  end
  ovw.players:with(ovw.players.active, function(p)
    if shouldFade(p) then p.visible = math.max(p.visible - tickRate, 0)
    else p.visible = math.min(p.visible + tickRate, 1) end
  end)
end

function PlayerMain:die()
  self.heartbeatSound:pause()
  Player.die(self)
end

function PlayerMain:keyHandler(key)
  if key == 'w' or key == 'a' or key == 's' or key == 'd' then
    self.input[key] = love.keyboard.isDown(key)
  elseif key == 'r' then
    self.input.reload = love.keyboard.isDown(key)
  elseif key:match('^[1-5]$') and love.keyboard.isDown(key) then
    key = tonumber(key)
    local slotType = self.slots[key].type
    if self.input[slotType] ~= key then self.input[slotType] = key end
  end
end

function PlayerMain:mouseHandler(x, y, button)
  self.input[button] = love.mouse.isDown(button)
end

function PlayerMain:trace(data)
  local p
  local t = data.tick
  local ack = data.ack
  data.tick = nil
  data.ack = nil
  data.id = nil
  data.angle = nil

  self.health = data.health or self.health
  self.shield = data.shield or self.shield
  
  local state = self:copy()--ovw.players.history[self.id][tick - 1]
  if not state then return end
  
  table.merge(data, state)
  
  for i = ack + 1, tick - 1 do
    p = ovw.players:get(self.id, i)
    if p then
      state.input = p.input
      state:move()
      self.x, self.y = state.x, state.y
      ovw.collision:update()
      state.x, state.y = self.x, self.y
    end
  end
  
  p = ovw.players:get(self.id, tick - 1)
  if p then
    table.merge({x = state.x, y = state.y}, p)
  end
  
  table.merge({x = state.x, y = state.y}, self)
end

function PlayerMain:copy()
  return table.merge({
    input = table.copy(self.input)
  }, Player.copy(self))
end