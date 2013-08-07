SMG = {}
SMG.code = 'smg'
SMG.hp = .2

SMG.activate = function(self)
  self.hp = SMG.hp
  self.x = self.owner.x
  self.y = self.owner.y
  self.angle = self.owner.angle + (math.pi / 2)
  self.bullets = {}
end

SMG.update = function(self)
  self.hp = timer.rot(self.hp, function() Spells:deactivate(self.id) end)
  self.x = self.x + (math.cos(self.angle) * 2500 * tickRate)
  self.y = self.y + (math.sin(self.angle) * 2500 * tickRate)
end

SMG.draw = function(self)
  love.graphics.setColor(255, 255, 255, (self.hp / SMG.hp) * 255)
  love.graphics.line(self.x, self.y, self.x + math.cos(self.angle) * 200, self.y + math.sin(self.angle) * 200)
  love.graphics.setColor(255, 255, 255, 255)
end

return SMG