local Tree = {}
Tree.name = 'Tree'
Tree.code = 'tree'

Tree.activate = function(self, map)
  self.scale = .5
  self.image = map.graphics.tree
  self.overwatch = map.overwatch
  self.depth = -5
end

Tree.update = function(self)
  if self.overwatch.view then self.depth = -2000 + math.distance(self.overwatch.view.x + self.overwatch.view.w / 2, self.overwatch.view.y + self.overwatch.view.h / 2, self.x, self.y) end
end

Tree.draw = function(self)
	love.graphics.reset()
  local x, y = self.overwatch.view:three(self.x, self.y, 100)
  if myId and self.overwatch.players:get(myId) and self.overwatch.players:get(myId).active then
    local p = self.overwatch.players:get(myId)
    love.graphics.setColor(255, 255, 255, (math.clamp(math.distance(self.x, self.y, p.x, p.y), 60, 120) / 120) * 255)
  else
    love.graphics.setColor(255, 255, 255)
  end
	love.graphics.draw(self.image, x, y, 0, self.scale, self.scale, self.image:getWidth() / 2, self.image:getHeight() / 2)
end

Tree.editor = {}
Tree.editor.boundingBox = function(self)
  local w, h = self.image:getWidth(), self.image:getHeight()
  return self.x - (self.scale * w / 2), self.y - (self.scale * h / 2), self.scale * w, self.scale * h
end

Tree.editor.dragTo = function(self, x, y)
  self.x, self.y = x + (self.image:getWidth() * self.scale / 2), y + (self.image:getHeight() * self.scale / 2)
end

Tree.editor.scale = function(self, hx, hy, ew, eh, ox, oy, ow, oh)
  ew = ew * hx
  eh = eh * hy
  self.scale = (ow / self.image:getWidth()) + (((ew + eh) / 2) / ow)
end

Tree.editor.save = function(self)
  return [[{
    kind = 'tree',
    x = ]] .. self.x .. [[,
    y = ]] .. self.y .. [[,
    scale = ]] .. self.scale .. [[
  }]]
end

return Tree