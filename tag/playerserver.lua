PlayerServer = {}
setmetatable(PlayerServer, {__index = Player})

function PlayerServer:activate()
  self.input = {}
  
  self.input.w = false
  self.input.a = false
  self.input.s = false
  self.input.d = false
  
  self.input.mx = 0
  self.input.my = 0
  self.input.l = false
  self.input.r = false
  
  self.input.wep = 1
  self.input.skl = 3
  self.input.rel = false
    
  Player.activate(self)
end

function PlayerServer:deactivate()
  self.input = nil
  
  Player.deactivate(self)
end

function PlayerServer:update()
  self:time()
  self:buff()
  self:move()
  self:turn()
  self:slot()
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
    if state then
      table.merge(table.except(data[idx], {'tick'}), state)
      state:move()
      state:turn()
      local dst = (i == tick) and self or Players.history[self.id][i]
      table.merge(table.except(data[idx], {'tick'}), dst)
    end
  end
end
