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
    
  Player.activate(self)
end

function PlayerMain:deactivate()
  self.input = nil
  
  Player.deactivate(self)
end

function PlayerMain:update()
  if self.ded then return end
  
  self:poll()
  self:buff()
  --self:move()
  --self:turn()
  self:slot()
  self:fade()
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
    return CollisionOvw:checkLineWall(self.x, self.y, p.x, p.y)
  end
  Players:with(Players.active, function(p)
    if shouldFade(p) then p.visible = math.max(p.visible - tickRate, 0)
    else p.visible = math.min(p.visible + tickRate, 1) end
  end)
end

--[[function PlayerMain:trace(data)
  if #data == 0 then return end

  local idx = 1
  for i = data[1].tick, tick do
    if data[idx + 1] and data[idx + 1].tick == i then idx = idx + 1 end
    
    local dst = (i == tick) and self or (Players.history[self.id][i] or self)
    if data[idx].x ~= math.floor(dst.x + .5) or data[idx].y ~= math.floor(dst.y + .5) then
      if math.distance(dst.x, dst.y, data[idx].x, data[idx].y) > 32 then
        dst.x = data[idx].x
        dst.y = data[idx].y
      else
        dst.x = math.lerp(dst.x, data[idx].x, .25)
        dst.y = math.lerp(dst.y, data[idx].y, .25)
      end
      for j = i + 1, tick do
        local state = table.copy(Players.history[self.id][j - 1])
        local dst = (j == tick) and self or Players.history[self.id][j]
        state:move()
        dst.x = math.lerp(dst.x, state.x, .25)
        dst.y = math.lerp(dst.y, state.y, .25)
      end
    end
  end
end]]

function PlayerMain:keyHandler(key)
  if key == 'w' or key == 'a' or key == 's' or key == 'd' then
    self.input[key] = love.keyboard.isDown(key)
    self:syncInput()
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
  Net:buffer(msgInput, table.merge({tick = tick}, table.copy(self.input)))
end