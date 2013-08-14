PlayerMain = {}
setmetatable(PlayerMain, {__index = Player})

function PlayerMain:activate()
  self.input = {}
  
  self.input.wasd = {}
  self.input.wasd.w = false
  self.input.wasd.a = false
  self.input.wasd.s = false
  self.input.wasd.d = false
  
  self.input.mouse = {}
  self.input.mouse.x = 0
  self.input.mouse.y = 0
  self.input.mouse.l = false
  self.input.mouse.r = false
  
  self.input.slot = {}
  self.input.slot.weapon = 1
  self.input.slot.skill = 3
  self.input.slot.reload = false
  
  self.syncBuffer = {}
  self.syncFrom = tick
  
  Player.activate(self)
end

function PlayerMain:deactivate()
  self.input = nil
  
  Player.deactivate(self)
end

function PlayerMain:update()
  self:poll()
  self:buff()
  self:move()
  self:turn()
  self:slot()
  self:fade()
end

function PlayerMain:poll()
  local mouse, prevx, prevy = self.input.mouse, self.input.mouse.x, self.input.mouse.y
  mouse.x, mouse.y = mouseX(), mouseY()
  if prevx ~= mouse.x or prevy ~= mouse.y then self.syncBuffer[tick] = true end
end

function PlayerMain:sync()
  local ct = table.count(self.syncBuffer)
  if self.syncBuffer[tick + 1] then ct = ct - 1 end
  Net:write(ct, 6)
  for i = self.syncFrom, tick do
    if self.syncBuffer[i] then
      local input = Players.history[self.id][i].input
      Net:write(i, 16)
         :write(input.wasd.w, 1)
         :write(input.wasd.a, 1)
         :write(input.wasd.s, 1)
         :write(input.wasd.d, 1)
         :write(math.floor(input.mouse.x + .5), 16)
         :write(math.floor(input.mouse.y + .5), 16)
         :write(input.mouse.l, 1)
         :write(input.mouse.r, 1)
         :write(input.slot.weapon, 3)
         :write(input.slot.skill, 3)
         :write(input.slot.reload, 1)
      
      self.syncBuffer[i] = nil
    end
  end
  
  self.syncFrom = tick + 1
end

function PlayerMain:fade()
  local function shouldFade(p)
    if p.team == self.team then return false end
    if math.abs(math.anglediff(self.angle, math.direction(self.x, self.y, p.x, p.y))) > math.pi / 2 then return true end
    return CollisionOvw:checkLineWall(self.x, self.y, p.x, p.y)
  end
  Players:with(Players.active, function(p)
    if shouldFade(p) then p.visible = math.max(p.visible - tickRate, 0)
    else p.visible = math.min(p.visible + tickRate, 1) end
  end)
end

function PlayerMain:trace(data)
  if #data == 0 then return end

  local idx = 1
  for i = data[1].tick, tick do
    if data[idx + 1] and data[idx + 1].tick == i then idx = idx + 1 end
    
    local dst = (i == tick) and self or (Players.history[self.id][i] or self)
    if data[idx].x ~= math.floor(dst.x + .5) or data[idx].y ~= math.floor(dst.y + .5) then
      dst.x = math.lerp(dst.x, data[idx].x, .25)
      dst.y = math.lerp(dst.y, data[idx].y, .25)
      for j = i + 1, tick do
        local state = table.copy(Players.history[self.id][j - 1])
        local dst = (j == tick) and self or Players.history[self.id][j]
        state:update()
        dst.x = math.lerp(dst.x, state.x, .25)
        dst.y = math.lerp(dst.y, state.y, .25)
      end
    end
  end
end

function PlayerMain:keyHandler(key)
  local dirty = false
  if key == 'w' or key == 'a' or key == 's' or key == 'd' then
    self.input.wasd[key] = love.keyboard.isDown(key)
    dirty = true
  elseif key == 'r' then
    self.input.slot.reload = love.keyboard.isDown(key)
    dirty = true
  elseif key:match('^[1-5]$') and love.keyboard.isDown(key) then
    key = tonumber(key)
    local slotType = self.slots[key].type
    if self.input.slot[slotType] ~= key then self.input.slot[slotType] = key end
    dirty = true
  end
  
  if love.keyboard.isDown(key) and dirty then
    self.syncBuffer[tick] = true
  elseif not love.keyboard.isDown(key) and dirty then
    self.syncBuffer[tick + 1] = true
  end
end

function PlayerMain:mouseHandler(x, y, button)
  self.input.mouse[button] = love.mouse.isDown(button)
  
  if love.mouse.isDown(button) then
    self.syncBuffer[tick] = true
  elseif not love.mouse.isDown(button) then
    self.syncBuffer[tick + 1] = true
  end
end