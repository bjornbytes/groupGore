PlayerServer = {}
setmetatable(PlayerServer, {__index = Player})

function PlayerServer:activate()
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

function PlayerServer:deactivate()
  self.input = nil
  
  Player.deactivate(self)
end

function PlayerServer:update()
  local prevx, prevy, prevang = self.x, self.y, self.angle
  self:time()
  self:buff()
  self:move()
  self:turn()
  self:slot()
  if prevx ~= self.x or prevy ~= self.y or prevang ~= self.angle then
    self.syncBuffer[tick ] = true
  end
end

function PlayerServer:sync()
  Net:write(self.id, 4)
     :write(table.count(self.syncBuffer), 6)
  
  for i = self.syncFrom, tick do
    if self.syncBuffer[i] then
      local state = Players.history[self.id][i]
      local ang = math.floor(math.deg(state.angle))
      if ang < 0 then ang = ang + 360 end
      Net:write(i, 16)
         :write(math.floor(state.x + .5), 16)
         :write(math.floor(state.y + .5), 16)
         :write(math.floor(ang), 9)
    end
  end
  
  table.clear(self.syncBuffer)
  self.syncFrom = tick + 1
end

function PlayerServer:time()
  self.ded = timer.rot(self.ded, function() self:respawn() end)
  if self.ded == 0 then self.ded = false end
end

function PlayerServer:spell(kind)
  Player.spell(self, kind)
  Net:begin(Net.msgSpell)
     :write(self.id, 4)
     :write(kind.id, 6)
     :send(Net.clients, self.id)
end

function PlayerServer:hurt(amount, from)
  if Player.hurt(self, amount, from) then
    if self.health <= 0 then self:die() end
  end
end

function PlayerServer:die()
  Player.die(self)
  Net:begin(Net.msgDie)
     :write(self.id, 4)
     :send(Net.clients)
end

function PlayerServer:respawn()
  Player.respawn(self)
  Net:begin(Net.msgRespawn)
     :write(self.id, 4)
     :send(Net.clients)
end

function PlayerServer:trace(data)
  if #data == 0 then return end
  
  -- Stick received input into previous states.
  local i = 1
  local first = data[i].tick
  repeat
    local state = Players.history[self.id][data[i].tick]
    table.merge(table.except(data[i], {'tick'}), state)
    i = i + 1
  until not data[i]
  
  -- Assume that the most recent input cascades forward to the present.
  local input = data[i - 1].input
  for t = data[i - 1].tick + 1, tick - 1 do
    table.merge({input = input}, Players.history[self.id][t])
  end
  
  -- Now we need to actually predict state from the inputs we just filled in.
  for t = first, tick - 1 do
    local state = Players.history[self.id][t]
    state:update()
    
    local dst = self
    if t < tick - 1 then dst = Players.history[self.id][t + 1] end

    dst.x = state.x
    dst.y = state.y

    self.syncBuffer[math.max(t, self.syncFrom)] = true
  end
end