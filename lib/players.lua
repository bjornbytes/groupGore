Players = class()

function Players:init()
  local tags = {
    client = PlayerDummy,
    server = PlayerServer
  }
  
  self.players = {}
  self.active = {}
  
  for i = 1, 16 do
    self.players[i] = tags[ctx.tag]()
    self.players[i].id = i
  end
  
  ctx.event:on(evtLeave, function(data)
    self:deactivate(data.id)
  end)
  
  ctx.event:on(evtFire, function(data)
    local p = self:get(data.id)
    local slot = p.slots[data.slot]
    slot.fire(p, slot)
  end)
  
  ctx.event:on(evtClass, function(data)
    self:setClass(data.id, data.class, data.team)
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
    local p = self:get(data.id)
    p:die()
  end)
  
  ctx.event:on(evtSpawn, function(data)
    local p = self:get(data.id)
    p.ded = false
    p:spawn()
  end)
end

function Players:activate(id)
  self.players[id].active = true
  if ctx.view then ctx.view:register(self.players[id]) end
  self:refresh()
end

function Players:deactivate(id)
  self.players[id].active = false
  self.players[id]:deactivate()
  if ctx.view then ctx.view:unregister(self.players[id]) end
  self:refresh()
end

function Players:get(id, t)
  assert(id and self.players[id])
  return self.players[id]:get(t or tick)
end

function Players:with(ps, fn)
  if type(ps) == 'number' then
    fn(self:get(ps))
  elseif type(ps) == 'table' then
    for _, id in pairs(ps) do
      fn(self:get(id))
    end
  elseif type(ps) == 'function' then
    for id, _ in pairs(table.filter(self.players, ps)) do
      fn(self:get(id))
    end
  end
end

function Players:update()
  for i = 1, #self.active do
    self:get(self.active[i]):update()
  end
end

local function mouseHandler(self, x, y, b)
  if not ctx.id then return end
  local p = self:get(ctx.id)
  if not p.active then return end
  f.exe(p.mouseHandler, p, x, y, b)
end
Players.mousepressed = mouseHandler
Players.mousereleased = mouseHandler

local function keyHandler(self, key)
  if not ctx.id then return end
  local p = self:get(ctx.id)
  if not p.active then return end
  f.exe(p.keyHandler, p, key)
end
Players.keypressed = keyHandler
Players.keyreleased = keyHandler

function Players:setClass(id, class, team)
  local p = self.players[id]
  if not p.active then self:activate(id) end
  p.class = data.class[class]
  p.team = team
  for i = 1, 5 do setmetatable(p.slots[i], {__index = p.class.slots[i]}) end
  p:activate()
end

function Players:refresh()
  table.clear(self.active)
  for i = 1, 16 do
    if self.players[i].active then
      table.insert(self.active, i)
    end
  end
end

function Players:reset()
  Players:with(self.active, function(p)
    p:activate()
  end)
end
