local Wall = {}
Wall.name = 'Wall'
Wall.code = 'wall'

Wall.activate = function(self, map)
  ovw.collision:addWall(self.x, self.y, self.w, self.h)

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
  if ovw.view then self.depth = -self.y + math.distance(self.x, self.y, ovw.view.x + ovw.view.w / 2, ovw.view.y + ovw.view.h / 2) / 10 end
end

Wall.draw = function(self)
  love.graphics.setColor(0, 0, 0, 255)
  --love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
  
  local v = ovw.view
  local ulx, uly = v:three(self.x, self.y, self.z)
  local urx, ury = v:three(self.x + self.w, self.y, self.z)
  local llx, lly = v:three(self.x, self.y + self.h, self.z)
  local lrx, lry = v:three(self.x + self.w, self.y + self.h, self.z)

  self.top:setVertex(1, ulx, uly, 0, 0)
  self.top:setVertex(2, urx, ury, 1, 0)
  self.top:setVertex(3, lrx, lry, 1, 1)
  self.top:setVertex(4, llx, lly, 0, 1)
  
  love.graphics.setColor(255, 255, 255)
  local y2 = ovw.view.y + (ovw.view.h / 2)
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

  local x2 = ovw.view.x + (ovw.view.w / 2)
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

return Wall