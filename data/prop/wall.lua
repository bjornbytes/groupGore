local Wall = {}
Wall.name = 'Wall'
Wall.code = 'wall'

Wall.activate = function(self)
	ovw.collision:addWall(self.x, self.y, self.w, self.h)
end

Wall.draw = function(self)
	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
end

return Wall