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
end

function PlayerMain:poll()
  local mouse = self.input.mouse
  mouse.x, mouse.y = mouseX(), mouseY()
end

function PlayerMain:sync()
  Net:write(self.id, 4)
     :write(table.count(self.syncBuffer), 6)
  
  for i = tick - 5, tick do
    if self.syncBuffer[i] then      
      local input = self.input
      Net:write(i, 16)
         :write(1, 4) -- Flags
         :write(input.wasd.w and 1 or 0, 1)
         :write(input.wasd.a and 1 or 0, 1)
         :write(input.wasd.s and 1 or 0, 1)
         :write(input.wasd.d and 1 or 0, 1)
      
      self.syncBuffer[i] = nil
    end
  end
end

function PlayerMain:keyHandler(key)
  if key == 'w' or key == 'a' or key == 's' or key == 'd' then
    self.input.wasd[key] = love.keyboard.isDown(key)
    self.syncBuffer[tick] = self.syncBuffer[tick] or {}
    self.syncBuffer[tick].wasd = true
  elseif key == 'r' then
    self.input.slot.reload = love.keyboard.isDown(key)
  elseif key:match('^[1-5]$') and love.keyboard.isDown(key) then
    key = tonumber(key)
    local slotType = self.slots[key].type
    if self.input.slot[slotType] ~= key then self.input.slot[slotType] = key end
  end
end