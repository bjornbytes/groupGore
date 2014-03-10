local Wall = {}
Wall.name = 'Wall'
Wall.code = 'wall'

Wall.activate = function(self, map)
  self.overwatch = map.overwatch
  if self.overwatch.collision then self.overwatch.collision:addWall(self.x, self.y, self.w, self.h) end

  self.top = love.graphics.newMesh({
    {0, 0, 0, 0},
    {0, 0, 1, 0},
    {0, 0, 1, 1},
    {0, 0, 0, 1}
  }, map.graphics.grass)

  self.north = love.graphics.newMesh({
    {self.x, self.y, 0, 0, 0, 0, 0},
    {self.x + self.w, self.y, 1, 0, 0, 0, 0},
    {0, 0, 1, 1},
    {0, 0, 0, 1}
  }, map.graphics.grass)

  self.south = love.graphics.newMesh({
    {0, 0, 0, 0},
    {0, 0, 1, 0},
    {self.x + self.w, self.y + self.h, 1, 1, 0, 0, 0},
    {self.x, self.y + self.h, 0, 1, 0, 0, 0}
  }, map.graphics.grass)

  self.east = love.graphics.newMesh({
    {0, 0, 0, 0},
    {self.x + self.w, self.y, 1, 0, 0, 0, 0},
    {self.x + self.w, self.y + self.h, 1, 1, 0, 0, 0},
    {0, 0, 0, 1}
  }, map.graphics.grass)

  self.west = love.graphics.newMesh({
    {self.x, self.y, 0, 0, 0, 0, 0},
    {0, 0, 1, 0},
    {0, 0, 1, 1},
    {self.x, self.y + self.h, 0, 1, 0, 0, 0}
  }, map.graphics.grass)

  self.depth = -5
end

Wall.update = function(self)
  local view = self.overwatch.view
  if view then self.depth = -1000 + math.distance(view.x + view.w / 2, view.y + view.h / 2, self.x, self.y) end
end

Wall.draw = function(self)
  love.graphics.setColor(0, 0, 0, 255)
  --love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
  
  local v = self.overwatch.view
  local ulx, uly = v:three(self.x, self.y, self.z)
  local urx, ury = v:three(self.x + self.w, self.y, self.z)
  local llx, lly = v:three(self.x, self.y + self.h, self.z)
  local lrx, lry = v:three(self.x + self.w, self.y + self.h, self.z)

  self.top:setVertex(1, ulx, uly, 0, 0)
  self.top:setVertex(2, urx, ury, 1, 0)
  self.top:setVertex(3, lrx, lry, 1, 1)
  self.top:setVertex(4, llx, lly, 0, 1)
  
  love.graphics.setColor(255, 255, 255)
  local y2 = self.overwatch.view.y + (self.overwatch.view.h / 2)
  if self.y > y2 then
    self.north:setVertex(3, urx, ury, 1, 1)
    self.north:setVertex(4, ulx, uly, 0, 1)
    love.graphics.draw(self.north, 0, 0)
  end

  if self.y + self.h < y2 then
    self.south:setVertex(1, llx, lly, 0, 0)
    self.south:setVertex(2, lrx, lry, 1, 0)
    love.graphics.draw(self.south, 0, 0)
  end

  local x2 = self.overwatch.view.x + (self.overwatch.view.w / 2)
  if self.x > x2 then
    self.west:setVertex(2, ulx, uly, 1, 0)
    self.west:setVertex(3, llx, lly, 1, 1)
    love.graphics.draw(self.west, 0, 0)
  end

  if self.x + self.w < x2 then
    self.east:setVertex(1, urx, ury, 0, 0)
    self.east:setVertex(4, lrx, lry, 0, 1)
    love.graphics.draw(self.east, 0, 0)
  end
  
  love.graphics.draw(self.top, 0, 0)
end

Wall.editor = {}
Wall.editor.boundingBox = function(self)
  return self.x, self.y, self.w, self.h
end

Wall.editor.dragTo = function(self, x, y)
  self.x, self.y = x, y
  
  self.north:setVertex(1, self.x, self.y, 0, 0, 0, 0, 0)
  self.north:setVertex(2, self.x + self.w, self.y, 1, 0, 0, 0, 0)

  self.south:setVertex(3, self.x + self.w, self.y + self.h, 1, 1, 0, 0, 0)
  self.south:setVertex(4, self.x, self.y + self.h, 0, 1, 0, 0, 0)

  self.east:setVertex(2, self.x + self.w, self.y, 1, 0, 0, 0, 0)
  self.east:setVertex(3, self.x + self.w, self.y + self.h, 1, 1, 0, 0, 0)

  self.west:setVertex(1, self.x, self.y, 0, 0, 0, 0, 0)
  self.west:setVertex(4, self.x, self.y + self.h, 0, 1, 0, 0, 0)
end

Wall.editor.scale = function(self, hx, hy, ew, eh, ox, oy, ow, oh)
  self.x, self.y = ox, oy
  self.w, self.h = ow, oh
  
  self.w = self.w + (ew * math.sign(hx))
  self.h = self.h + (eh * math.sign(hy))
  if hx < 0 then self.x = self.x + ew end
  if hy < 0 then self.y = self.y + eh end
  
  self.north:setVertex(1, self.x, self.y, 0, 0, 0, 0)
  self.north:setVertex(2, self.x + self.w, self.y, 1, 0, 0, 0, 0)

  self.south:setVertex(3, self.x + self.w, self.y + self.h, 1, 1, 0, 0, 0)
  self.south:setVertex(4, self.x, self.y + self.h, 0, 1, 0, 0, 0)

  self.east:setVertex(2, self.x + self.w, self.y, 1, 0, 0, 0, 0)
  self.east:setVertex(3, self.x + self.w, self.y + self.h, 1, 1, 0, 0, 0)

  self.west:setVertex(1, self.x, self.y, 0, 0, 0, 0, 0)
  self.west:setVertex(4, self.x, self.y + self.h, 0, 1, 0, 0, 0)
end

Wall.editor.save = function(self)
  return [[{
    kind = 'wall',
    x = ]] .. self.x .. [[,
    y = ]] .. self.y .. [[,
    w = ]] .. self.w .. [[,
    h = ]] .. self.h .. [[,
    z = ]] .. self.z .. [[
  }]]
end

return Wall