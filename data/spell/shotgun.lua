local Shotgun = {}
Shotgun.code = 'shotgun'

Shotgun.hp = .1

Shotgun.activate = function(self)
  self.hp = Shotgun.hp
  self.x = self.owner.x
  self.y = self.owner.y
  self.bullets = {}
  for i = self.owner.angle - math.rad(6), self.owner.angle + math.rad(6), math.rad(3) do
    table.insert(self.bullets, {
      angle = i + (math.pi / 2)
    })
  end
end

Shotgun.update = function(self)
  self.hp = timer.rot(self.hp, function() Spells:deactivate(self.id) end)
end

Shotgun.draw = function(self)
  love.graphics.setColor(255, 255, 255, (self.hp / Shotgun.hp) * 255)
  for _, bullet in pairs(self.bullets) do
    love.graphics.line(self.x, self.y, self.x + math.cos(bullet.angle) * 500, self.y + math.sin(bullet.angle) * 500)
  end
  love.graphics.setColor(255, 255, 255, 255)
end

return Shotgun