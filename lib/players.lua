Players = class()
Players.max = 15

function Players:init()
  self.players = {}
  self.active = {}
  
  for i = 1, self.max do
    self.players[i] = ctx.tag == 'server' and PlayerServer() or PlayerDummy()
    self.players[i].id = i
  end
  
  ctx.event:on(evtLeave, function(data)
    self:deactivate(data.id)
  end)
  
  ctx.event:on(evtClass, function(data)
    self:setClass(data.id, data.class, data.team)
  end)
  
  ctx.event:on(evtFire, function(data)
    if data.id ~= ctx.id then
      local p = self:get(data.id)
      local slot = p.slots[data.slot]
      slot:fire(p)
    end
  end)
  
  ctx.event:on(evtDamage, function(data)
    local to, from = self:get(data.id), self:get(data.from)
    to:hurt(data)
    local oldAmt = data.amount
    data.amount = data.amount * from.lifesteal
    from:heal(data)
    data.amount = oldAmt
  end)
  
  ctx.event:on(evtDead, function(data)
    local p = self:get(data.id):die()
  end)
  
  ctx.event:on(evtSpawn, function(data)
    local p = self:get(data.id)
    p.ded = false
    p:spawn()
  end)
end

function Players:activate(id)
  if ctx.view then ctx.view:register(self.players[id]) end
  ctx.event:emit('collision.attach', {object = self.players[id]})
  table.insert(self.active, id)
end

function Players:deactivate(id)
  if ctx.view then ctx.view:unregister(self.players[id]) end
  ctx.event:emit('collision.detach', {object = self.players[id]})
  for i = 1, self.max do
    if self.active[i] == id then table.remove(self.active, i) break end
  end
end

function Players:get(id, t)
  return self.players[id]:get(t or tick)
end

function Players:each(fn)
  for i = 1, #self.active do
    fn(self:get(self.active[i]))
  end
end

function Players:update()
  self:each(f.ego('update'))
end

function Players:setClass(id, class, team)
  local p = self.players[id]
  if not table.has(self.active, id) then self:activate(id) end
  p.class = data.class[class]
  p.team = team
  for i = 1, 5 do setmetatable(p.slots[i], {__index = p.class.slots[i]}) end
  p:activate()
end
