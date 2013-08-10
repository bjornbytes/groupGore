Players = {}

Players.players = {}
Players.active = {}
Players.history = {}

function Players:activate(id, tag, class)
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
  p.class = class
  setmetatable(p, {__index = tags[tag]})
  for i = 1, 5 do setmetatable(p.slots[i], {__index = p.class.slots[i]}) end
  p:activate()
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
    for _, p in ipairs(table.filter(self.players, ps)) do
      fn(p)
    end
  end
end

function Players:update()
  self:with(self.active, f.ego('update'))
  self:with(self.active, function(p)
    self.history[p.id][tick] = table.copy(p)
    self.history[p.id][tick - (1 / tick)] = nil
  end)
end

function Players:draw()
  self:with(self.active, function(current)
    local previous = self.history[current.id][tick - 1]
    if previous then
      table.interpolate(previous, current, tickDelta / tickRate):draw()
    end
  end)
end

function Players:mousepressed(x, y, b)
  if not self:get(myId).active then return end
  self:get(myId).input.mouse[b] = true
end

function Players:mousereleased(x, y, b)
  if not self:get(myId).active then return end
  self:get(myId).input.mouse[b] = false
end

local function keyHandler(self, key)
  if not myId then return end
  local p = self:get(myId)
  f.exe(p.keyHandler, p, key)
end
Players.keypressed = keyHandler
Players.keyreleased = keyHandler

function Players:refresh()
  for i = 1, 16 do
    self.active[i] = nil
    if self.players[i].active then
      table.insert(self.active, i)
    end
  end
end

for i = 1, 16 do
  Players.players[i] = Player:create()
  Players.players[i].id = i
  
  Players.history[i] = {}
end

local dir
dir = '/tag'
for _, file in ipairs(love.filesystem.enumerate(dir)) do
  if file:match('player.*\.lua') then love.filesystem.load(dir .. '/' .. file)() end
end