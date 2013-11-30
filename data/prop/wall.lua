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

  self.south = love.graphics.newMesh({
    {0, 0, 0, 0},
    {0, 0, 1, 0},
    {self.x, self.y + self.h, 1, 1},
    {self.x + self.w, self.y + self.h, 0, 1}
  }, map.graphics.grass)

  self.depth = -5
end

Wall.update = function(self)
  if ovw.view then self.depth = -self.y + (math.distance(self.x + self.w / 2, self.y + self.h / 2, ovw.view.x + ovw.view.w / 2, ovw.view.y + ovw.view.h / 2) / 10) end
end

Wall.draw = function(self)
  love.graphics.setColor(0, 0, 0, 255)
  love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
  
  local v = ovw.view
  local ulx, uly = v:three(self.x, self.y, self.z)
  local urx, ury = v:three(self.x + self.w, self.y, self.z)
  local llx, lly = v:three(self.x, self.y + self.h, self.z)
  local lrx, lry = v:three(self.x + self.w, self.y + self.h, self.z)

  self.south:setVertex(1, llx, lly, 0, 0)
  self.south:setVertex(2, lrx, lry, 1, 0)
  self.south:setVertexMap(1, 2, 4, 3)

  self.top:setVertex(1, ulx, uly, 0, 0)
  self.top:setVertex(2, urx, ury, 1, 0)
  self.top:setVertex(3, lrx, lry, 1, 1)
  self.top:setVertex(4, llx, lly, 0, 1)
  
  love.graphics.setColor(255, 255, 255)
  love.graphics.draw(self.south, 0, 0)
  love.graphics.draw(self.top, 0, 0)
end

return Wall