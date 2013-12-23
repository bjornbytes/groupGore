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
  self.input.skill = 3
  self.input.reload = false
  
  self.visible = 1
  
  self.lastWasd = tick
  
  self.xDebt = 0
  self.yDebt = 0
  
  self.targetX = self.x
  self.targetY = self.y
  
  Player.activate(self)
end

function PlayerMain:deactivate()
  self.input = nil
  
  Player.deactivate(self)
end

function PlayerMain:update()
  if self.ded then return end
  
  if (self.xDebt > 0 or self.yDebt > 0) and self.speed > 0 then
    for i = tick - 10, tick do
      local state = (i == tick) and self or ovw.players.history[self.id][i]
      state.x = state.x + (self.xDebt / 10)
      state.y = state.y + (self.yDebt / 10)
    end
    self.xDebt = self.xDebt - (self.xDebt / 10)
    self.yDebt = self.yDebt - (self.yDebt / 10)
  end
  
  self:poll()
  self:buff()
  self:move()
  self:turn()
  self:slot()
  self:fade()
end

function PlayerMain:draw()
  if self.ded then return end
  local previous = ovw.players.history[self.id][tick - 1]
  if previous then
    Player.draw(table.interpolate(previous, self, tickDelta / tickRate))
  end
end

function PlayerMain:poll()
  local prevx, prevy = self.input.mx, self.input.my
  self.input.mx, self.input.my = mouseX(), mouseY()
  if prevx ~= self.input.mx or prevy ~= self.input.my then self:syncInput() end
end

function PlayerMain:fade()
  local function shouldFade(p)
    if p.team == self.team then return false end
    if math.abs(math.anglediff(self.angle, math.direction(self.x, self.y, p.x, p.y))) > math.pi / 2 then return true end
    return ovw.collision:checkLineWall(self.x, self.y, p.x, p.y)
  end
  ovw.players:with(ovw.players.active, function(p)
    if shouldFade(p) then p.visible = math.max(p.visible - tickRate, 0)
    else p.visible = math.min(p.visible + tickRate, 1) end
  end)
end

function PlayerMain:keyHandler(key)
  if key == 'w' or key == 'a' or key == 's' or key == 'd' then
    self.input[key] = love.keyboard.isDown(key)
    self:syncInput()
    self.lastWasd = tick
    if not self.input[key] then self.lastWasd = self.lastWasd - 1 end
  elseif key == 'r' then
    self.input.reload = love.keyboard.isDown(key)
    self:syncInput()
  elseif key:match('^[1-5]$') and love.keyboard.isDown(key) then
    key = tonumber(key)
    local slotType = self.slots[key].type
    if self.input[slotType] ~= key then self.input[slotType] = key end
    self:syncInput()
  end
end

function PlayerMain:mouseHandler(x, y, button)
  self.input[button] = love.mouse.isDown(button)
  self:syncInput()
end

function PlayerMain:syncInput()
  ovw.net:buffer(msgInput, table.merge({tick = tick}, table.copy(self.input)))
end

function PlayerMain:trace(data)
  local t = data.tick
  local ack = data.ack
  data.tick = nil
  data.ack = nil
  data.id = nil
  data.angle = nil
  
  local correctDrift = true
  if correctDrift then
    self.targetX = data.x
    self.targetY = data.y
    
    local state = table.copy(ovw.players.history[self.id][t])
    if not state then return end
    
    local d = math.distance(data.x, data.y, state.x, state.y)
    self.xDebt = data.x - state.x
    self.yDebt = data.y - state.y
    if d > 64 then
      for i = t, tick do
        local dst = (i == tick) and self or ovw.players.history[self.id][i]
        table.merge(data, dst)
      end
      self.xDebt = 0
      self.yDebt = 0
      return
    else
      table.merge(data, ovw.players.history[self.id][t])
    end
  else
    table.merge(data, ovw.players.history[self.id][t])
  end
  
  local state = table.copy(ovw.players.history[self.id][math.max(ack, tick - (1 / tickRate) + 1)])
  if not state then return end
  
  for i = ack + 1, tick do
    local dst = (i == tick) and self or ovw.players.history[self.id][i]
    if dst then
      if dst ~= self then
        state.input = dst.input
        state:move()
      end
      table.merge({x = state.x, y = state.y}, dst)
    end
  end
  
  self.health = data.health
end