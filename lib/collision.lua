Collision = class()

local size = 64

Collision.grid = {}
Collision.gridSize = size
Collision.testCache = {}
Collision.playerGrid = {}
Collision.players = {}

function Collision:addWall(...)
  local x, y, w, h = ...
  for i = math.floor(x / size), math.floor((x + w) / size) - 1 do
    self.grid[i] = self.grid[i] or {}
    for j = math.floor(y / size), math.floor((y + h) / size) - 1 do
      self.grid[i][j] = {...}
    end
  end
end

function Collision:getTests(x, y)
  x, y = math.floor(x / size), math.floor(y / size)
  if not self.testCache[x] or not self.testCache[x][y] then
    self.testCache[x] = self.testCache[x] or {}
    self.testCache[x][y] = {}
    for i = -1, 1 do
      for j = -1, 1 do
        if self.grid[x + i] and self.grid[x + i][y + j] then
          if not table.has(self.testCache[x][y], self.grid[x + i][y + j], true) then
            table.insert(self.testCache[x][y], self.grid[x + i][y + j])
          end
        end
      end
    end
  end
  return self.testCache[x][y]
end

function Collision:checkCircleWall(cx, cy, cr)
  local tests = self:getTests(cx, cy)
  if #tests == 0 then return false end
  for _, coords in pairs(tests) do
    if math.hcora(cx, cy, cr, unpack(coords)) then return coords end
  end
  return false
end

function Collision:checkPointWall(px, py)
  local tests = self:getTests(px, py)
  if #tests == 0 then return false end
  for _, coords in pairs(tests) do
    if math.inside(px, py, unpack(coords)) then return coords end
  end
  return false
end

function Collision:checkLineWall(x1, y1, x2, y2, intersect)
  local l, dis, dir = 0, math.distance(x1, y1, x2, y2), math.direction(x1, y1, x2, y2)
  local f = intersect and math.hlorax or math.hlora
  repeat
    local ex, ey = x1 + math.cos(dir) * l, y1 + math.sin(dir) * l
    local tests = self:getTests(ex, ey)
    for _, coords in pairs(tests) do
      local x, y = f(x1, y1, ex, ey, unpack(coords))
      if x then return x, y end
    end
    l = l + 50
  until l > dis
  
  local tests = self:getTests(x2, y2)
  for _, coords in pairs(tests) do
    local x, y = f(x1, y1, x2, y2, unpack(coords))
    if x then return x, y end
  end
  return false
end

function Collision:resolveCircleWall(x, y, r, step)
  local wall = self:checkCircleWall(x, y, r)
  if not wall then return x, y end
  
  wall = {x = wall[1], y = wall[2], w = wall[3], h = wall[4]}
  if x < wall.x then
    if y < wall.y then
      local d = math.direction(x, y, wall.x, wall.y)
      x = x - math.cos(d) * step
      y = y - math.sin(d) * step
    elseif y > wall.y + wall.h then
      local d = math.direction(x, y, wall.x, wall.y + wall.h)
      x = x - math.cos(d) * step
      y = y - math.sin(d) * step
    else
      local d = 0
      x = x - math.cos(d) * step
      y = y - math.sin(d) * step
    end
  elseif x > wall.x + wall.w then
    if y < wall.y then
      local d = math.direction(x, y, wall.x + wall.w, wall.y)
      x = x - math.cos(d) * step
      y = y - math.sin(d) * step
    elseif y > wall.y + wall.h then
      local d = math.direction(x, y, wall.x + wall.w, wall.y + wall.h)
      x = x - math.cos(d) * step
      y = y - math.sin(d) * step
    else
      local d = math.pi
      x = x - math.cos(d) * step
      y = y - math.sin(d) * step
    end
  else
    if y < wall.y then
      local d = math.pi * .5
      x = x - math.cos(d) * step
      y = y - math.sin(d) * step
    else
      local d = math.pi * 1.5
      x = x - math.cos(d) * step
      y = y - math.sin(d) * step
    end
  end
  
  return self:resolveCircleWall(x, y, r, step)
end

function Collision:resolveCirclePlayer(x, y, r, step, team, n)
  n = n or 0
  if n > 100 then return x, y end
  
  local players = {}
  local xx, yy = math.floor(x / size), math.floor(y / size)
  for i = -1, 1 do
    for j = -1, 1 do
      if self.playerGrid[xx + i] and self.playerGrid[xx + i][yy + j] then
        local node = self.playerGrid[xx + i][yy + j].head
        repeat
          if node.val.player.team ~= team then
            table.insert(players, node.val.player)
          end
          node = node.next
        until not node
      end
    end
  end
  
  if #players == 0 then return x, y end
  
  local free = true
  for i = 1, #players do
    local player = players[i]
    if math.hcoca(x, y, r, player.x, player.y, r) then
      local d = math.direction(x, y, player.x, player.y) + (math.pi / 2)
      x = x - math.cos(d) * step
      y = y - math.sin(d) * step
      free = false
    end
  end
  
  if free then return x, y end
  
  return self:resolveCirclePlayer(x, y, r, step, team, n + 1)
end

function Collision:refreshPlayer(p)
  local nx, ny
  if self.players[p.id] then
    local node = self.players[p.id]
    nx, ny = node.val.x, node.val.y
    self.playerGrid[nx][ny]:remove(node)
  end
  x, y = math.floor(p.x / size), math.floor(p.y / size)
  self.playerGrid[x] = self.playerGrid[x] or {}
  self.playerGrid[x][y] = self.playerGrid[x][y] or LinkedList.create()
  self.players[p.id] = self.playerGrid[x][y]:insert({
    player = p,
    x = x,
    y = y
  })
  if nx and ny and self.playerGrid[nx][ny].length == 0 then self.playerGrid[nx][ny] = nil end
end