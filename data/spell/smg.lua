SMG = {}
SMG.code = 'smg'
SMG.hp = .1

SMG.activate = function(self)
  self.hp = SMG.hp
  self.x = self.owner.x
  self.y = self.owner.y
  self.angle = self.owner.angle + (math.pi / 2)
end

SMG.update = function(self)
  self.hp = timer.rot(self.hp, function() Spells:deactivate(self.id) end)
end

SMG.draw = function(self)
  love.graphics.setColor(255, 255, 255, (self.hp / SMG.hp) * 255)
  love.graphics.line(self.x, self.y, self.x + math.cos(self.angle) * 500, self.y + math.sin(self.angle) * 500)
  love.graphics.setColor(255, 255, 255, 255)
end

return SMG