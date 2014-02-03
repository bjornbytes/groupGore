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

  self.shields = {}

  self.hurtHistory = {}
  self.helpHistory = {}
  
  self.ack = tick
  self.lastHurt = tick

  self.auxVex = {}

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
      self:heal({amount = self.maxHealth * percentage * tickRate})
    end
  end
  
  local data, flag = {}, false
  if math.round(self.x) ~= prevx or math.round(self.y) ~= prevy then
    data.x = math.round(self.x)
    data.y = math.round(self.y)
    flag = true
  end

  if math.round((math.deg(self.angle) + 360) % 360) ~= prevangle then
    data.angle = math.round((math.deg(self.angle) + 360) % 360)
    flag = true
  end
  
  if math.round(self.health) ~= prevhp  or tick - self.lastHurt <= 1 then
    local shield = 0
    table.each(self.shields, function(s) shield = shield + s.health end)
    data.health = math.round(self.health)
    data.shield = math.round(shield)
    flag = true
  end
  
  if flag or math.random() < .02 then
    data.id = self.id
    data.tick = tick
    data.ack = self.ack
    ovw.net:emit(evtSync, data)
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
  if self.ded then return end

  local target = self.shields[1] or self

  while #self.hurtHistory > 0 and self.hurtHistory[1].tick < tick - (10 / tickRate) do
    table.remove(self.hurtHistory, 1)
  end
  table.insert(self.hurtHistory, {tick = data.tick, amount = data.amount, from = data.from})
  target.health = math.max(target.health - data.amount, 0)
  self.lastHurt = data.tick
  if target.health <= 0 then
    if target == self then
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
    else
      f.exe(self.shields[1].callback, self) 
      table.remove(self.shields, 1)
    end
  end
end

function PlayerServer:heal(data)
  self.health = math.min(self.health + data.amount, self.maxHealth)
end

function PlayerServer:spawn()
  table.clear(self.hurtHistory)
  table.clear(self.helpHistory)

  Player.spawn(self)
end

function PlayerServer:logic()
  -- Override by AI.
end