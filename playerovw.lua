Players = {}

Players.players = {}
Players.history = {}
Players.active = {}
Players.next = 1

function Players:activate(tag, class)
  if self.next == -1 then return nil end
  assert(self.next >= 1 and self.next <= 16)
  local p = self.players[self.next]
  
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
    --current:draw()
    local previous = self.history[current.id][tick - 1]
    if previous then
      table.interpolate(previous, current, tickDelta / tickRate):draw()
    end
  end)
end

function Players:mousepressed(x, y, b)
  self:get(myId).input.mouse[b] = true
end

function Players:mousereleased(x, y, b)
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
  self.next = nil
  for i = 1, 16 do
    self.active[i] = nil
    if not self.players[i].active then
      self.next = self.next or i
    else
      table.insert(self.active, i)
    end
  end
  self.next = self.next or -1
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

dir = 'data/class'
for _, file in ipairs(love.filesystem.enumerate(dir)) do
  if file:match('\.lua') then
    local class = love.filesystem.load(dir .. '/' .. file)()
    assert(class.name, 'No name for the class in ' .. file)
    assert(class.health, 'No health for the class in ' .. file)
    assert(class.speed, 'No speed for the class in ' .. file)
    assert(class.sprite, 'No sprite for the class in ' .. file)
    assert(class.slots, 'No slots for the class in ' .. file)
    
    class.sprite = love.graphics.newImage(class.sprite)
    for i = 1, 5 do
      class.slots[i] = love.filesystem.load(class.slots[i])()
    end
    
    _G[class.name] = class
  end
end