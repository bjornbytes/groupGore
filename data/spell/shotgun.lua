local Shotgun = {}
Shotgun.code = 'shotgun'

Shotgun.hp = .2

Shotgun.activate = function(self)
  self.hp = Shotgun.hp
  self.x = self.owner.x
  self.y = self.owner.y
  self.bullets = {}
  for i = self.owner.angle - math.rad(6), self.owner.angle + math.rad(6), math.rad(3) do
    table.insert(self.bullets, {
      x = self.x,
      y = self.y,
      angle = i + (math.pi / 2)
    })
  end
end

Shotgun.update = function(self)
  self.hp = timer.rot(self.hp, function() Spells:deactivate(self.id) end)
  for k, bullet in pairs(self.bullets) do
    bullet.x = bullet.x + (math.cos(bullet.angle) * 2500 * tickRate)
    bullet.y = bullet.y + (math.sin(bullet.angle) * 2500 * tickRate)
  end
end

Shotgun.draw = function(self)
  love.graphics.setColor(255, 255, 255, (self.hp / Shotgun.hp) * 255)
  for _, bullet in pairs(self.bullets) do
    love.graphics.line(bullet.x, bullet.y, bullet.x + math.cos(bullet.angle) * 300, bullet.y + math.sin(bullet.angle) * 300)
  end
  love.graphics.setColor(255, 255, 255, 255)
end

return Shotgun