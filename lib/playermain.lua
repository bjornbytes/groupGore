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
  
  ovw.net:buffer(msgInput, table.merge({tick = tick}, table.copy(self.input)))
end

function PlayerMain:draw()
  if self.ded then return end
  
  if love.keyboard.isDown(' ') then
    local server
    for i = 1, #Overwatch.ovws do
      local o = Overwatch.ovws[i]
      if o and o.tag and o.tag == 'server' then
        server = o
        break
      end
    end
    
    if server then
      Player.draw(server.players:get(self.id))
    end
  else
    local t = tick
    local previous = ovw.players.history[self.id][t - 1]
    local current = ovw.players.history[self.id][t]
    if current and previous then
      Player.draw(table.interpolate(previous, current, tickDelta / tickRate))
    end
  end
end

function PlayerMain:drawPosition()
  local t = tick
  local prev, cur = ovw.players.history[self.id][t - 1], ovw.players.history[self.id][t]
  if prev then
    prev, cur = {x = prev.x, y = prev.y}, {x = cur.x, y = cur.y}
    local interp = table.interpolate(prev, cur, tickDelta / tickRate)
    return interp.x, interp.y
  end
  
  return 0, 0
end

function PlayerMain:poll()
  self.input.mx, self.input.my = mouseX(), mouseY()
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

  local state = table.copy(self)--ovw.players.history[self.id][tick - 1]
  if not state then return end
  
  table.merge(data, state)
  
  for i = ack + 1, tick - 1 do
    p = ovw.players:get(self.id, i)
    if p then
      state.input = p.input
      state:move()
      ovw.collision:updateClone(self.id, state)
    end
  end
  
  p = ovw.players:get(self.id, tick - 1)
  if p then
    table.merge({x = self.x, y = self.y}, p)
  end
  
  table.merge({x = state.x, y = state.y}, self)
end