SMGBullet = {}
SMGBullet.hp = .2

SMGBullet.activate = function(self)
  self.hp = SMGBullet.hp
  self.x = self.owner.x
  self.y = self.owner.y
  self.angle = self.owner.angle + (math.pi / 2)
  self.bullets = {}
end

SMGBullet.update = function(self)
  self.hp = timer.rot(self.hp, function() Spells:deactivate(self.id) end)
  self.x = self.x + (math.cos(self.angle) * 2500 * tickRate)
  self.y = self.y + (math.sin(self.angle) * 2500 * tickRate)
end

SMGBullet.draw = function(self)
  love.graphics.setColor(255, 255, 255, (self.hp / SMGBullet.hp) * 255)
  love.graphics.line(self.x, self.y, self.x + math.cos(self.angle) * 200, self.y + math.sin(self.angle) * 200)
  love.graphics.setColor(255, 255, 255, 255)
end

return SMGBullet