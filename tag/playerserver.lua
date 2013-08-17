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
    self.syncBuffer[tick] = true
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
         :write(#state.events, 4)
      
      for j = 1, #state.events do
        Net:write(Player.events[state.events[j].e], 4)
      end
    end
  end
  
  table.clear(self.syncBuffer)
  self.syncFrom = tick + 1
end

function PlayerServer:time()
  self.ded = timer.rot(self.ded, function() self:emit('spawn') end)
  if self.ded == 0 then self.ded = false end
end

function PlayerServer:spell(kind)
  Player.spell(self, kind)
  Net:begin(Net.msgSpell)
     :write(self.id, 4)
     :write(kind.id, 6)
     :send(Net.clients, self.id)
end

function PlayerServer:trace(data)
  if #data == 0 then return end
  
  local idx = 1
  for i = data[1].tick, tick do
    if data[idx + 1] and data[idx + 1].tick == i then idx = idx + 1 end
    
    local state = table.copy(Players.history[self.id][i - 1] or Players.history[self.id][i])
    table.merge(table.except(data[idx], {'tick'}), state)
    state:update()
    local dst = (i == tick) and self or Players.history[self.id][i]
    table.merge(table.except(data[idx], {'tick'}), dst)
  end
end

function PlayerServer:emit(e, args)
  self:handle(e, args)
  table.insert(self.events, {
    e = e,
    args = args
  })
  if Players.history[self.id][tick] then self.syncBuffer[tick + 1] = true
  else self.syncBuffer[tick] = true end
end