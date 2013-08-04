CollisionOvw = {}

local size = 64

CollisionOvw.grid = {}
CollisionOvw.gridSize = size
CollisionOvw.testCache = {}

function CollisionOvw:addWall(...)
  local x, y, w, h = ...
  for i = math.floor(x / size), math.floor((x + w) / size) - 1 do
    self.grid[i] = self.grid[i] or {}
    for j = math.floor(y / size), math.floor((y + h) / size) - 1 do
      self.grid[i][j] = {...}
    end
  end
end

function CollisionOvw:getTests(x, y)
  x, y = math.floor(x / 64), math.floor(y / 64)
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

function CollisionOvw:checkCircleWall(cx, cy, cr)
  local tests = self:getTests(cx, cy)
  if #tests == 0 then return false end
  for _, coords in pairs(tests) do
    if math.hcora(cx, cy, cr, unpack(coords)) then return coords end
  end
  return false
end

function CollisionOvw:checkPointWall(px, py)
  local tests = self:getTests(px, py)
  if #tests == 0 then return false end
  for _, coords in pairs(tests) do
    if math.inside(px, py, unpack(coords)) then return coords end
  end
  return false
end

function CollisionOvw:resolveCircle(x, y, r, step)
  local wall = self:checkCircleWall(x, y, r)
  if not wall then return x, y end
  
  wall = {x = wall[1], y = wall[2], w = wall[3], h = wall[4]}
  if x < wall.x then
    if y < wall.y then
      local d = math.direction(x, y, wall.x, wall.y) + math.pi * .5
      x = x - math.cos(d) * step
      y = y - math.sin(d) * step
    elseif y > wall.y + wall.h then
      local d = math.direction(x, y, wall.x, wall.y + wall.h) + math.pi * .5
      x = x - math.cos(d) * step
      y = y - math.sin(d) * step
    else
      local d = 0
      x = x - math.cos(d) * step
      y = y - math.sin(d) * step
    end
  elseif x > wall.x + wall.w then
    if y < wall.y then
      local d = math.direction(x, y, wall.x + wall.w, wall.y) + math.pi * .5
      x = x - math.cos(d) * step
      y = y - math.sin(d) * step
    elseif y > wall.y + wall.h then
      local d = math.direction(x, y, wall.x + wall.w, wall.y + wall.h) + math.pi * .5
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
      local d = 1.5 * math.pi
      x = x - math.cos(d) * step
      y = y - math.sin(d) * step
    end
  end
  
  return self:resolveCircle(x, y, r, step)
end