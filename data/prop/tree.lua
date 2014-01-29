local Tree = {}
Tree.name = 'Tree'
Tree.code = 'tree'

Tree.update = function(self)
  if ovw.view then self.depth = -2000 + math.distance(ovw.view.x + ovw.view.w / 2, ovw.view.y + ovw.view.h / 2, self.x, self.y) end
end

Tree.draw = function(self)
	love.graphics.reset()
	local tree = ovw.map.graphics.tree
  local x, y = ovw.view:three(self.x, self.y, 100)
  if myId and ovw.players:get(myId) and ovw.players:get(myId).active then
    local p = ovw.players:get(myId)
    love.graphics.setColor(255, 255, 255, (math.clamp(math.distance(self.x, self.y, p.x, p.y), 60, 120) / 120) * 255)
  else
    love.graphics.setColor(255, 255, 255)
  end
	love.graphics.draw(tree, x, y, 0, .5, .5, tree:getWidth() / 2, tree:getHeight() / 2)
end

Tree.editor = {}
Tree.editor.boundingBox = function(self)
  local tree = ovw.map.graphics.tree
  local w, h = tree:getWidth() / 2, tree:getHeight() / 2
  return self.x - (w / 2), self.y - (h / 2), w, h
end

Tree.editor.dragTo = function(self, x, y)
  self.x, self.y = x, y
end

return Tree