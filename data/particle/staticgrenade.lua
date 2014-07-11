local StaticGrenade = {}

StaticGrenade.name = 'StaticGrenade'
StaticGrenade.code = 'staticgrenade'

StaticGrenade.activate = function(self)
  self.health = .3
  self.alpha = 1
  self.depth = -9
  ctx.view:register(self)
end

StaticGrenade.update = function(self)
  self.health = self.health - tickRate
  if self.health <= 0 then return true end
  
  self.alpha = self.alpha - (1 / .3) * tickRate
end

StaticGrenade.draw = function(self)
  love.graphics.setColor(0, 255, 255, self.alpha * 255)
  love.graphics.circle('fill', self.x, self.y, self.radius)
end

return StaticGrenade

