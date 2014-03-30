Players = class()

function Players:init()
  local tags = {
    client = PlayerDummy,
    server = PlayerServer
  }
  
  self.players = {}
  self.active = {}
  self.history = {}
  
  self.tick = nil
  
  for i = 1, 16 do
    self.players[i] = Player:create()
    self.players[i].id = i
    self.history[i] = {}
    setmetatable(self.players[i], {__index = tags[ovw.tag]})
  end
  
  ovw.event:on(evtLeave, function(data)
    self:deactivate(data.id)
  end)
  
  ovw.event:on(evtFire, function(data)
    local p = self:get(data.id)
    local slot = p.slots[data.slot]
    slot.fire(p, slot)
  end)
  
  ovw.event:on(evtClass, function(data)
    self:setClass(data.id, data.class, data.team)
  end)
  
  ovw.event:on(evtDamage, function(data)
    local to, from = self:get(data.id), self:get(data.from)
    to:hurt(data)
    local oldAmt = data.amount
    data.amount = data.amount * from.lifesteal
    from:heal(data)
    data.amount = oldAmt
  end)
  
  ovw.event:on(evtDead, function(data)
    local p = self:get(data.id)
    p:die()
  end)
  
  ovw.event:on(evtSpawn, function(data)
    local p = self:get(data.id)
    p.ded = false
    p:spawn()
  end)
end

function Players:activate(id)
  assert(id >= 1 and id <= 16)
  self.players[id].active = true
  if ovw.view then ovw.view:register(self.players[id]) end
  if ovw.collision then ovw.collision:register(self.players[id]) end
  self:refresh()
end

function Players:deactivate(id)
  self.players[id].active = false
  self.players[id]:deactivate()
  if ovw.view then ovw.view:unregister(self.players[id]) end
  self:refresh()
end

function Players:get(id, t)
  if not id then return end
  t = t or self.tick or tick
  local f = math.floor(t)
	if t ~= f then
    local prev = self.history[id][f]
    local cur = self.history[id][math.ceil(t)]
    if cur and prev then
			return table.interpolate(prev, cur, t - f)
		end
    return nil
	end
  return t == tick and self.players[id] or self.history[id][t]
end

function Players:with(ps, fn)
  if type(ps) == 'number' then
    fn(self:get(ps))
  elseif type(ps) == 'table' then
    for _, id in ipairs(ps) do
      fn(self:get(id))
    end
  elseif type(ps) == 'function' then
    for id, _ in pairs(table.filter(self.players, ps)) do
      fn(self:get(id))
    end
  end
end

function Players:update()
  self:with(self.active, f.ego('update'))
  ovw.collision:update()
  self:with(self.active, function(p)
    self.history[p.id][tick] = table.copy(p)
    self.history[p.id][tick - (1 / interp + 5)] = nil
  end)
end

local function mouseHandler(self, x, y, b)
  if not myId then return end
  local p = self:get(myId)
  if not p.active then return end
  f.exe(p.mouseHandler, p, x, y, b)
end
Players.mousepressed = mouseHandler
Players.mousereleased = mouseHandler

local function keyHandler(self, key)
  if not myId then return end
  local p = self:get(myId)
  if not p.active then return end
  f.exe(p.keyHandler, p, key)
end
Players.keypressed = keyHandler
Players.keyreleased = keyHandler

function Players:setClass(id, class, team)
  local p = self:get(id)
  if not p.active then self:activate(id) end
  p.class = data.class[class]
  p.team = team
  for i = 1, 5 do setmetatable(p.slots[i], {__index = p.class.slots[i]}) end
  p:activate()
end

function Players:rewind(t)
  self.tick = t
end

function Players:unrewind()
  self.tick = nil
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
