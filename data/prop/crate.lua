local Crate = {}
Crate.name = 'Crate'
Crate.code = 'crate'

Crate.width = 64
Crate.height = 64
Crate.z = 32

Crate.collision = {}
Crate.collision.shape = 'rectangle'
Crate.collision.static = true
Crate.collision.tag = 'shortwall'

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

function Crate:activate(map)
  if not Crate.texture then
    local x, y, w, h = map.textures.crate:getViewport()
    Crate.texture = love.graphics.newCanvas(w, h)
    Crate.texture:renderTo(function()
      love.graphics.setColor(255, 255, 255)
      love.graphics.draw(map.atlas, map.textures.crate)
    end)
    Crate.texture:setWrap('repeat', 'repeat')
  end

  local cx, cy = self.x + self.width / 2, self.y + self.height / 2
  self.ulx = (((self.x) - cx) * math.cos(self.angle)) - (((self.y) - cy) * math.sin(self.angle)) + cx
  self.uly = (((self.x) - cx) * math.sin(self.angle)) + (((self.y) - cy) * math.cos(self.angle)) + cy
  self.urx = (((self.x + self.width) - cx) * math.cos(self.angle)) - (((self.y) - cy) * math.sin(self.angle)) + cx
  self.ury = (((self.x + self.width) - cx) * math.sin(self.angle)) + (((self.y) - cy) * math.cos(self.angle)) + cy
  self.llx = (((self.x) - cx) * math.cos(self.angle)) - (((self.y + self.height) - cy) * math.sin(self.angle)) + cx
  self.lly = (((self.x) - cx) * math.sin(self.angle)) + (((self.y + self.height) - cy) * math.cos(self.angle)) + cy
  self.lrx = (((self.x + self.width) - cx) * math.cos(self.angle)) - (((self.y + self.height) - cy) * math.sin(self.angle)) + cx
  self.lry = (((self.x + self.width) - cx) * math.sin(self.angle)) + (((self.y + self.height) - cy) * math.cos(self.angle)) + cy

  ctx.event:emit('collision.attach', {object = self})
  self.shape:rotate(self.angle)

  self.top = love.graphics.newMesh({
    {0, 0, 0, 0},
    {0, 0, 1, 0},
    {0, 0, 1, 1},
    {0, 0, 0, 1}
  }, self.texture)

  self.north = love.graphics.newMesh({
    {self.ulx, self.uly, 0, 0, 0, 0, 0},
    {self.urx, self.ury, 1, 0, 0, 0, 0},
    {0, 0, 1, 1},
    {0, 0, 0, 1}
  }, self.texture)

  self.south = love.graphics.newMesh({
    {0, 0, 0, 0},
    {0, 0, 1, 0},
    {self.lrx, self.lry, 1, 1, 0, 0, 0},
    {self.llx, self.lly, 0, 1, 0, 0, 0}
  }, self.texture)

  self.east = love.graphics.newMesh({
    {0, 0, 0, 0},
    {self.urx, self.ury, 1, 0, 0, 0, 0},
    {self.lrx, self.lry, 1, 1, 0, 0, 0},
    {0, 0, 0, 1}
  }, self.texture)

  self.west = love.graphics.newMesh({
    {self.ulx, self.uly, 0, 0, 0, 0, 0},
    {0, 0, 1, 0},
    {0, 0, 1, 1},
    {self.llx, self.lly, 0, 1, 0, 0, 0}
  }, self.texture)

  self.meshX = self.x
  self.meshY = self.y

  if ctx.view then ctx.view:register(self) end
end

function Crate:update()
  if ctx.view then
    if not self:inView() then return end
    local x1, y1 = ctx.view.x + ctx.view.width / 2, ctx.view.y + ctx.view.height / 2
    local x2, y2 = perim(x1, y1, self.x, self.y, self.width, self.height)
    self.depth = math.clamp(math.distance(x1, y1, x2, y2) * ctx.view.scale - 10 - self.z, -4096, -16)
  end

  if self.meshX ~= self.x or self.meshY ~= y then
    self:updateMesh()
  end
end

function Crate:draw()
  if not self:inView() then return end

  local v = ctx.view
  local ulx, uly = v:three(self.ulx, self.uly, self.z)
  local urx, ury = v:three(self.urx, self.ury, self.z)
  local llx, lly = v:three(self.llx, self.lly, self.z)
  local lrx, lry = v:three(self.lrx, self.lry, self.z)
  local w, h = 1, 1

  self.top:setVertex(1, ulx, uly, 0, 0)
  self.top:setVertex(2, urx, ury, w, 0)
  self.top:setVertex(3, lrx, lry, w, h)
  self.top:setVertex(4, llx, lly, 0, h)

  love.graphics.setColor(255, 255, 255)
  local dif = math.anglediff(self.angle, math.direction(self.ulx, self.uly, v.x + (v.width / 2), v.y + (v.height / 2)))
  if dif < 0 then
    self.north:setVertex(3, urx, ury, w, h)
    self.north:setVertex(4, ulx, uly, 0, h)
    love.graphics.draw(self.north, 0, 0)
  end

  local dif = math.anglediff(self.angle, math.direction(self.llx, self.lly, v.x + (v.width / 2), v.y + (v.height / 2)))
  if dif > 0 then
    self.south:setVertex(1, llx, lly, 0, 0)
    self.south:setVertex(2, lrx, lry, w, 0)
    love.graphics.draw(self.south, 0, 0)
  end

  local dif = math.anglediff(self.angle + math.pi / 2, math.direction(self.ulx, self.uly, v.x + (v.width / 2), v.y + (v.height / 2)))
  if dif > 0 then
    self.west:setVertex(2, ulx, uly, w, 0)
    self.west:setVertex(3, llx, lly, w, h)
    love.graphics.draw(self.west, 0, 0)
  end

  local dif = math.anglediff(self.angle + math.pi / 2, math.direction(self.lrx, self.lry, v.x + (v.width / 2), v.y + (v.height / 2)))
  if dif < 0 then
    self.east:setVertex(1, urx, ury, 0, 0)
    self.east:setVertex(4, lrx, lry, 0, h)
    love.graphics.draw(self.east, 0, 0)
  end

  love.graphics.draw(self.top, 0, 0)
end

function Crate:inView()
  local x, y, w, h = self.x, self.y, self.width, self.height
  local v = ctx.view
  return x + w >= v.x and x <= v.x + v.width and y + h >= v.y and y <= v.y + v.height
end

function Crate:updateMesh()
  --[[local w, h = self.width / self.image:getWidth(), self.height / self.image:getHeight()

  self.north:setVertex(1, self.x, self.y, 0, 0, 0, 0, 0)
  self.north:setVertex(2, self.x + self.width, self.y, w, 0, 0, 0, 0)

  self.south:setVertex(3, self.x + self.width, self.y + self.height, w, h, 0, 0, 0)
  self.south:setVertex(4, self.x, self.y + self.height, 0, h, 0, 0, 0)

  self.east:setVertex(2, self.x + self.width, self.y, w, 0, 0, 0, 0)
  self.east:setVertex(3, self.x + self.width, self.y + self.height, w, h, 0, 0, 0)

  self.west:setVertex(1, self.x, self.y, 0, 0, 0, 0, 0)
  self.west:setVertex(4, self.x, self.y + self.height, 0, h, 0, 0, 0)

  self.meshX = self.x
  self.meshY = self.y]]
end

function Crate:__tostring()
  return [[{
    kind = 'crate',
    x = ]] .. self.x .. [[,
    y = ]] .. self.y .. [[,
    w = ]] .. self.width .. [[,
    h = ]] .. self.height .. [[,
    z = ]] .. self.z .. [[
  }]]
end

return Crate
