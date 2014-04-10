local Tree = {}
Tree.name = 'Tree'
Tree.code = 'tree'

Tree.collision = {}
Tree.collision.shape = 'circle'
Tree.collision.static = true

Tree.activate = function(self, map)
  if ovw.collision then ovw.collision:register(self) end
  self.image = map.graphics.tree
end

Tree.update = function(self)
  if ovw.view then self.depth = -2000 + math.distance(ovw.view.x + ovw.view.w / 2, ovw.view.y + ovw.view.h / 2, self.x, self.y) end
end

Tree.draw = function(self)
	love.graphics.reset()
  local x, y = ovw.view:three(self.x, self.y, 100)
  if ovw.id and ovw.players:get(ovw.id) and ovw.players:get(ovw.id).active then
    local p = ovw.players:get(ovw.id)
    love.graphics.setColor(255, 255, 255, (math.clamp(math.distance(self.x, self.y, p.x, p.y), 60, 120) / 120) * 255)
  else
    love.graphics.setColor(255, 255, 255)
  end
  love.graphics.draw(self.image, x, y, 0, self.radius / 20, self.radius / 20, self.image:getWidth() / 2, self.image:getHeight() / 2)
end

Tree.__tostring = function(self)
  return [[{
    kind = 'tree',
    x = ]] .. self.x .. [[,
    y = ]] .. self.y .. [[,
    radius = ]] .. self.radius .. [[
  }]]
end

return Tree
