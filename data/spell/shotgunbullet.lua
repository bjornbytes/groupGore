ShotgunBullet = {}
ShotgunBullet.hp = .2

ShotgunBullet.activate = function(self)
  self.hp = ShotgunBullet.hp
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

ShotgunBullet.update = function(self)
  self.hp = timer.rot(self.hp, function() Spells:deactivate(self.id) end)
  for k, bullet in pairs(self.bullets) do
    bullet.x = bullet.x + (math.cos(bullet.angle) * 2500 * tickRate)
    bullet.y = bullet.y + (math.sin(bullet.angle) * 2500 * tickRate)
  end
end

ShotgunBullet.draw = function(self)
  love.graphics.setColor(255, 255, 255, (self.hp / ShotgunBullet.hp) * 255)
  for _, bullet in pairs(self.bullets) do
    love.graphics.line(bullet.x, bullet.y, bullet.x + math.cos(bullet.angle) * 300, bullet.y + math.sin(bullet.angle) * 300)
  end
  love.graphics.setColor(255, 255, 255, 255)
end

return ShotgunBullet