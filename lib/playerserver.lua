PlayerServer = extend(Player)

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
  
  self.input.weapon = 1
  self.input.skill = 3
  self.input.reload = false

  self.shields = {}

  self.hurtHistory = {}
  self.helpHistory = {}
  
  self.ack = tick

  Player.activate(self)
end

function PlayerServer:deactivate()
  self.input = nil
  
  Player.deactivate(self)
end

function PlayerServer:update()
  self:time()  
  self:logic()
  self:slot()
  
  if self.health < self.maxHealth and not self.ded then
    local percentage = ((tick - self.lastHurt) - (3 / tickRate)) / (10 / tickRate)
    if percentage > 0 then
      percentage = (1 + (percentage * 7)) / 100
      self:heal({amount = self.maxHealth * percentage * tickRate})
    end
  end
end

function PlayerServer:time()
  self.ded = timer.rot(self.ded, function() ctx.net:emit(evtSpawn, {id = self.id}) end)
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
          playerHurt[v.from][2] = playerHurt[v.from][2] + v.amount * (1 - ((data.tick - v.tick) / (10 / tickRate)))
        end
      end
      
      table.sort(playerHurt, function(a, b)
        return a[2] > b[2]
      end)

      local assists = {}
      if playerHurt[1][2] > 0 then
        table.insert(assists, {id = playerHurt[1][1]})
        if playerHurt[2][2] > 0 then table.insert(assists, {id = playerHurt[2][1]}) end
      end

      ctx.net:emit(evtDead, {id = self.id, kill = data.from, assists = assists})
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

function PlayerServer:trace(data, ping)
  local t = data.tick
  data.tick = nil

  local rewindTo = t - ((ping / 1000) + interp) / tickRate
  if t > self.ack then
    
    -- Lag compensation
    local oldPos = {}
    ctx.players:with(ctx.players.active, function(p)
      if p.id ~= self.id then
        oldPos[p.id] = {p.x, p.y}
        local lerpd = ctx.players:get(p.id, rewindTo)
        if lerpd then
          p.x = lerpd.x
          p.y = lerpd.y
          p.shape:moveTo(p.x, p.y)
        end
      end
    end)

    local p = ctx.players:get(self.id, t)

    if p then
      self.ack = t
      p.input = data
      p:move()
      ctx.collision:resolve(p)
      p:turn()
      for i = t + 1, tick do
        local dst = ctx.players:get(self.id, i)
        table.merge(p, dst)
      end
   
      do
        local data = {}
        data.x = math.round(p.x)
        data.y = math.round(p.y)
        data.angle = math.round((math.deg(p.angle) + 360) % 360)

        local shield = 0
        table.each(p.shields, function(s) shield = shield + s.health end)
        data.health = math.round(p.health)
        data.shield = math.round(shield)

        data.id = p.id
        data.tick = t
        data.ack = self.ack
        ctx.net:emit(evtSync, data)
      end
    end

    -- Undo lag compensation
    ctx.players:with(ctx.players.active, function(p)
      if oldPos[p.id] then
        p.x, p.y = unpack(oldPos[p.id])
        p.shape:moveTo(p.x, p.y)
      end
    end)
  end
end

function PlayerServer:logic()
  -- Override by AI.
end

function PlayerServer:copy()
  return table.merge({
    input = table.copy(self.input)
  }, Player.copy(self))
end
