PlayerServer = extend(Player)

function PlayerServer:activate()
  self.shields = {}

  self.hurtHistory = {}
  self.helpHistory = {}

  self.history = {}

  self.ack = tick

  Player.activate(self)
end

function PlayerServer:get(t)
  if not self.history then return self end

  while self.history[1] and self.history[1].tick < tick - 2 / tickRate do
    table.remove(self.history, 1)
  end

  if #self.history == 0 then return self end

  if self.history[#self.history].tick < t then return self end

  for i = #self.history, 1, -1 do
    if self.history[i].tick <= t then return self.history[i] end
  end
  
  return self.history[1]
end

function PlayerServer:update()
  if self.ded then return self:time() end

  self:time()
  self:logic()
  
  if self.health < self.maxHealth and not self.ded then
    local percentage = ((tick - self.lastHurt) - (3 / tickRate)) / (10 / tickRate)
    if percentage > 0 then
      percentage = (1 + (percentage * 7)) / 100
      self:heal({amount = self.maxHealth * percentage * tickRate})
    end
  end

  Player.update(self)
end

function PlayerServer:trace(data, ping)
  if data.tick > self.ack then
    
    -- Lag compensation
    local oldData = {}
    if ping > 0 then
      local target = data.tick - ((ping / 1000) + interp) / tickRate
      local t1 = math.floor(target)
      local factor = target - t1
      ctx.players:each(function(p)
        if p.id ~= self.id then
          oldData[p.id] = {p.x, p.y, p.angle}
          local s1, s2 = p:get(t1), p:get(t1 + 1)
          s1 = {x = s1.x, y = s1.y, angle = s1.angle}
          s2 = {x = s2.x, y = s2.y, angle = s2.angle}
          local lerpd = table.interpolate(s1, s2, factor)
          p.x = lerpd.x
          p.y = lerpd.y
          p.angle = lerpd.angle
          ctx.event:emit('collision.move', {object = p})
        end
      end)
    end

    self.ack = data.tick
    
    if not self.ded then
      self:move(data)
      self:turn(data)
      self:slot(data)
    end

    table.insert(self.history, setmetatable({
      x = self.x,
      y = self.y,
      z = self.z,
      angle = self.angle,
      tick = data.tick
    }, self.meta))

    -- sync
    local msg = {}
    msg.x = math.round(self.x * 10)
    msg.y = math.round(self.y * 10)
    msg.z = math.round(self.z)
    msg.angle = math.round((math.deg(self.angle) + 360) % 360)

    local shield = 0
    table.each(self.shields, function(s) shield = shield + s.health end)
    msg.health = math.round(self.health)
    msg.shield = math.round(shield)

    if data.slot then
      msg.weapon = self.weapon
      msg.skill = self.skill
    end

    msg.id = self.id
    msg.tick = tick
    msg.ack = self.ack
    ctx.net:emit(evtSync, msg)

    -- Undo lag compensation
    ctx.players:each(function(p)
      if oldData[p.id] then
        p.x, p.y, p.angle = unpack(oldData[p.id])
      end
    end)
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

PlayerServer.logic = f.empty
