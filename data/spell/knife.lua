local Knife = {}
Knife.code = 'knife'

Knife.hp = .1
Knife.radius = 10

Knife.activate = function(self)
	self.angle = self.owner.angle
  self.x = self.owner.x + math.dx(20, self.angle)
  self.y = self.owner.y + math.dy(20, self.angle)
  
  -- Deal damage.
  -- ovw.spells:deactivate(self)
end

Knife.update = function(self)
  self.hp = timer.rot(self.hp, function() ovw.spells:deactivate(self) end)
end

Knife.draw = function(self)
  love.graphics.setColor(255, 255, 255, (self.hp / Knife.hp) * 255)
  love.graphics.circle('line', self.x, self.y, Knife.radius)
end

return Knife
