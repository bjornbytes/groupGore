local Blood = {}

Blood.name = 'Blood'
Blood.code = 'blood'

Blood.activate = function(self)
	self.alpha = .6 + love.math.random() * .4
	self.scale = .2 + love.math.random() * .2
	self.angle = love.math.random() * math.pi * 2
	self.image = data.media.graphics.effects['blood' .. love.math.random(4)]
end

Blood.update = function(self)
	self.alpha = self.alpha - tickRate * .1
	if self.alpha <= 0 then return true end
end

Blood.draw = function(self)
	love.graphics.setColor(255, 0, 0)
	love.graphics.draw(self.image, self.x, self.y, self.angle, self.scale, self.scale, self.image:getWidth() / 2, self.image:getHeight() / 2)
end

return Blood