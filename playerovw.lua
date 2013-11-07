Players = {}

Players.players = {}
Players.active = {}
Players.history = {}

function Players:activate(id, tag, class, team)
  assert(id >= 1 and id <= 16)
  local p = self.players[id]
  
  local tags = {
    main = PlayerMain,
    dummy = PlayerDummy,
    server = PlayerServer
  }
  assert(tags[tag])
  assert(not p.active)
  p.active = true
  setmetatable(p, {__index = tags[tag]})
  self:setClass(id, class, team)
  self:refresh()
  return id
end

function Players:deactivate(id)
  local p = self.players[id]
  assert(p.active)
  p.active = false
  p:deactivate()
  self:refresh()
end

function Players:get(id)
  return self.players[id]
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
  self:with(self.active, function(p)
    self.history[p.id][tick] = table.copy(p)
    self.history[p.id][tick - (1 / tick)] = nil
    table.clear(p.events)
  end)
end

function Players:draw()
  self:with(self.active, function(current)
    if current.ded then return end
    if current.id == myId then
      local previous = self.history[current.id][tick - 1]
      if previous then
        table.interpolate(previous, current, tickDelta / tickRate):draw()
      end
    else
      local t = tick - (interp / tickRate)
      local previous = self.history[current.id][t - 1]
      current = self.history[current.id][t]
      if current and previous then
        table.interpolate(previous, current, tickDelta / tickRate):draw()
      end
    end
  end)
end

local function mouseHandler(self, x, y, b)
  if not myId then return end
  local p = self:get(myId)
  f.exe(p.mouseHandler, p, x, y, b)
end
Players.mousepressed = mouseHandler
Players.mousereleased = mouseHandler

local function keyHandler(self, key)
  if not myId then return end
  local p = self:get(myId)
  f.exe(p.keyHandler, p, key)
end
Players.keypressed = keyHandler
Players.keyreleased = keyHandler

function Players:setClass(id, class, team)
  local p = self:get(id)
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

for i = 1, 16 do
  Players.players[i] = Player:create()
  Players.players[i].id = i
  
  Players.history[i] = {}
end

local dir
dir = '/tag'
for _, file in ipairs(love.filesystem.getDirectoryItems(dir)) do
  if file:match('player.*\.lua') then love.filesystem.load(dir .. '/' .. file)() end
end
