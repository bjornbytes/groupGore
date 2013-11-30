local Tree = {}
Tree.name = 'Tree'
Tree.code = 'tree'

Tree.activate = function(self)
  self.depth = -self.y - 100
end

Tree.draw = function(self)
	love.graphics.reset()
	local tree = ovw.map.graphics.tree
	love.graphics.draw(tree, self.x, self.y, 0, .5, .5, tree:getWidth() / 2, tree:getHeight() / 2)
end

return Tree