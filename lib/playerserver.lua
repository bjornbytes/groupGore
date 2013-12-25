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

  self.hurtHistory = {}
  self.helpHistory = {}
  
  self.ack = tick
  
  self.lastHurt = tick
  
  Player.activate(self)
end

function PlayerServer:deactivate()
  self.input = nil
  
  Player.deactivate(self)
end

function PlayerServer:update()
  local prevx, prevy, prevangle, prevhp = math.round(self.x), math.round(self.y), math.round((math.deg(self.angle) + 360) % 360), math.round(self.health)
  
  self:time()
  self:move()
  self:turn()
  self:slot()

  self:logic()
  
  if self.health < self.maxHealth and not self.ded then
    local percentage = ((tick - self.lastHurt) - (3 / tickRate)) / (10 / tickRate)
    if percentage > 0 then
      percentage = (1 + (percentage * 7)) / 100
      self.health = self.health + math.min(self.maxHealth - self.health, self.maxHealth * percentage * tickRate)
    end
  end
  
  if math.round(self.x) ~= prevx or math.round(self.y) ~= prevy or math.round((math.deg(self.angle) + 360) % 360) ~= prevangle or math.round(self.health) ~= prevhp or tick - self.lastHurt <= 1 or tick % 100 == 0 then
    ovw.net:emit(evtSync, {
      id = self.id,
      tick = tick,
      ack = self.ack,
      x = math.round(self.x),
      y = math.round(self.y),
      angle = math.round((math.deg(self.angle) + 360) % 360),
      health = math.round(self.health)
    })
  end
end

function PlayerServer:time()
  self.ded = timer.rot(self.ded, function() ovw.net:emit(evtSpawn, {id = self.id}) end)
  if self.ded == 0 then self.ded = false end
end

function PlayerServer:spell(kind)
  Player.spell(self, kind)
end

function PlayerServer:hurt(data)
  if not self.ded then
    while #self.hurtHistory > 0 and self.hurtHistory[1].tick < tick - (10 / tickRate) do
      table.remove(self.hurtHistory, 1)
    end
    table.insert(self.hurtHistory, {tick = data.tick, amount = data.amount, from = data.from})
    self.health = self.health - data.amount
    self.lastHurt = data.tick
    if self.health <= 0 then
      self.ded = 5
      local playerHurt = {}
      for i = 1, 16 do playerHurt[i] = {i, 0} end
      playerHurt[data.from][2] = -1
      playerHurt[self.id][2] = -1
      for i, v in ipairs(self.hurtHistory) do
        if v.from ~= data.from and v.from ~= self.id then
          playerHurt[i][2] = playerHurt[i][2] + v.amount * (1 - ((data.tick - v.tick) / (10 / tickRate)))
        end
      end
      
      table.sort(playerHurt, function(a, b)
        return a[2] > b[2]
      end)

      local assists = {}
      if playerHurt[1][2] > 0 then
        table.insert(assists, playerHurt[1][1])
        if playerHurt[2][2] > 0 then table.insert(assists, {id = playerHurt[2][1]}) end
      end

      ovw.net:emit(evtDead, {id = self.id, kill = data.from, assists = assists})
    end
  end
end

function PlayerServer:spawn()
  table.clear(self.hurtHistory)
  table.clear(self.helpHistory)

  Player.spawn(self)
end

function PlayerServer:logic()
  -- Override by AI.
end