local Skull = {}

Skull.name = 'Skull'
Skull.code = 'skull'

Skull.activate = function(self)
  self.health = 5
  self.scale = 1
  self.alpha = 1
  self.image = data.media.graphics.effects.skull
end

Skull.update = function(self)
  self.health = self.health - tickRate
  if self.health <= 0 then return true end
  
  self.scale = self.scale - .05 * tickRate
  self.alpha = self.alpha - .2 * tickRate
end

Skull.draw = function(self)
  love.graphics.setColor(255, 255, 255, self.alpha * 255)
  love.graphics.draw(self.image, self.x, self.y, self.angle, self.scale, self.scale, self.image:getWidth() / 2, self.image:getHeight() / 2)
end

return Skull
