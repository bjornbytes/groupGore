local Wall = {}
Wall.name = 'Wall'
Wall.code = 'wall'

Wall.collision = {}
Wall.collision.shape = 'rectangle'
Wall.collision.static = true
Wall.collision.tag = 'wall'

local function perim(x, y, l, t, w, h)
  local r, b = l + w, t + h

  x, y = math.clamp(x, l, r), math.clamp(y, t, b)

  local dl, dr, dt, db = math.abs(x - l), math.abs(x - r), math.abs(y - t), math.abs(y - b)
  local m = math.min(dl, dr, dt, db)

  if m == dt then return x, t end
  if m == db then return x, b end
  if m == dl then return l, y end
  return r, y
end

function Wall:activate(map)
  ctx.event:emit('collision.attach', {object = self})

  self.image = data.media.graphics.map[map.wallTexture]
  self.image:setWrap('repeat', 'repeat')

  self.top = love.graphics.newMesh({
    {0, 0, 0, 0},
    {0, 0, 1, 0},
    {0, 0, 1, 1},
    {0, 0, 0, 1}
  }, self.image)

  self.north = love.graphics.newMesh({
    {self.x, self.y, 0, 0, 0, 0, 0},
    {self.x + self.width, self.y, 1, 0, 0, 0, 0},
    {0, 0, 1, 1},
    {0, 0, 0, 1}
  }, self.image)

  self.south = love.graphics.newMesh({
    {0, 0, 0, 0},
    {0, 0, 1, 0},
    {self.x + self.width, self.y + self.height, 1, 1, 0, 0, 0},
    {self.x, self.y + self.height, 0, 1, 0, 0, 0}
  }, self.image)

  self.east = love.graphics.newMesh({
    {0, 0, 0, 0},
    {self.x + self.width, self.y, 1, 0, 0, 0, 0},
    {self.x + self.width, self.y + self.height, 1, 1, 0, 0, 0},
    {0, 0, 0, 1}
  }, self.image)

  self.west = love.graphics.newMesh({
    {self.x, self.y, 0, 0, 0, 0, 0},
    {0, 0, 1, 0},
    {0, 0, 1, 1},
    {self.x, self.y + self.height, 0, 1, 0, 0, 0}
  }, self.image)

  self.meshX = self.x
  self.meshY = self.y

  self.depth = -5
  if ctx.view then ctx.view:register(self) end
end

function Wall:update()
  if ctx.view then
    if not self:inView() then return end
    local x1, y1 = ctx.view.x + ctx.view.width / 2, ctx.view.y + ctx.view.height / 2
    local x2, y2 = perim(x1, y1, self.x, self.y, self.width, self.height)
    self.depth = math.clamp(math.distance(x1, y1, x2, y2) * ctx.view.scale - 1000, -4096, -16)
  end

  if self.meshX ~= self.x or self.meshY ~= y then
    self:updateMesh()
  end
end

function Wall:draw()
  if not self:inView() then return end

  local v = ctx.view
  local ulx, uly = v:three(self.x, self.y, self.z)
  local urx, ury = v:three(self.x + self.width, self.y, self.z)
  local llx, lly = v:three(self.x, self.y + self.height, self.z)
  local lrx, lry = v:three(self.x + self.width, self.y + self.height, self.z)
  local w, h = self.width / self.image:getWidth(), self.height / self.image:getHeight()

  self.top:setVertex(1, ulx, uly, 0, 0)
  self.top:setVertex(2, urx, ury, w, 0)
  self.top:setVertex(3, lrx, lry, w, h)
  self.top:setVertex(4, llx, lly, 0, h)

  love.graphics.setColor(255, 255, 255)
  local y2 = ctx.view.y + (ctx.view.height / 2)
  if self.y > y2 then
    self.north:setVertex(3, urx, ury, w, h)
    self.north:setVertex(4, ulx, uly, 0, h)
    love.graphics.draw(self.north, 0, 0)
  end

  if self.y + self.height < y2 then
    self.south:setVertex(1, llx, lly, 0, 0)
    self.south:setVertex(2, lrx, lry, w, 0)
    love.graphics.draw(self.south, 0, 0)
  end

  local x2 = ctx.view.x + (ctx.view.width / 2)
  if self.x > x2 then
    self.west:setVertex(2, ulx, uly, w, 0)
    self.west:setVertex(3, llx, lly, w, h)
    love.graphics.draw(self.west, 0, 0)
  end

  if self.x + self.width < x2 then
    self.east:setVertex(1, urx, ury, 0, 0)
    self.east:setVertex(4, lrx, lry, 0, h)
    love.graphics.draw(self.east, 0, 0)
  end
  
  love.graphics.draw(self.top, 0, 0)
end

function Wall:inView()
  local x, y, w, h = self.x, self.y, self.width, self.height
  local v = ctx.view
  return x + w >= v.x and x <= v.x + v.width and y + h >= v.y and y <= v.y + v.height
end

function Wall:updateMesh()
  local w, h = self.width / self.image:getWidth(), self.height / self.image:getHeight()

  self.north:setVertex(1, self.x, self.y, 0, 0, 0, 0, 0)
  self.north:setVertex(2, self.x + self.width, self.y, w, 0, 0, 0, 0)

  self.south:setVertex(3, self.x + self.width, self.y + self.height, w, h, 0, 0, 0)
  self.south:setVertex(4, self.x, self.y + self.height, 0, h, 0, 0, 0)

  self.east:setVertex(2, self.x + self.width, self.y, w, 0, 0, 0, 0)
  self.east:setVertex(3, self.x + self.width, self.y + self.height, w, h, 0, 0, 0)

  self.west:setVertex(1, self.x, self.y, 0, 0, 0, 0, 0)
  self.west:setVertex(4, self.x, self.y + self.height, 0, h, 0, 0, 0)

  self.meshX = self.x
  self.meshY = self.y
end

function Wall:__tostring()
  return [[{
    kind = 'wall',
    x = ]] .. self.x .. [[,
    y = ]] .. self.y .. [[,
    w = ]] .. self.width .. [[,
    h = ]] .. self.height .. [[,
    z = ]] .. self.z .. [[
  }]]
end

return Wall
