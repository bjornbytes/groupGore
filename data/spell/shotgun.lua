local Shotgun = {}
Shotgun.code = 'shotgun'

Shotgun.hp = .1

Shotgun.activate = function(self)
  self.hp = Shotgun.hp
  self.x = self.owner.x
  self.y = self.owner.y
  self.len = 700
  self.bullets = {}
  
  for i = self.owner.angle - math.rad(6), self.owner.angle + math.rad(6), math.rad(3) do
    local ang, len = i + (math.pi / 2), self.len
    
    local endx, endy = self.x + math.cos(ang) * len, self.y + math.sin(ang) * len
    local targets = {}
    Players:with(function(p)
      return p.team ~= self.owner.team and math.hloca(self.x, self.y, endx, endy, p.x, p.y, p.size)
    end, function(p)
      table.insert(targets, {
        id = p.id,
        dist = math.distance(p.x, p.y, self.x, self.y)
      })
    end)
    
    table.sort(targets, function(a, b) return a.dist < b.dist end)
    if targets[1] then
      print('I HIT PLAYER NUMBER ' .. targets[1].id)
      local p = Players:get(targets[1].id)
      len = math.distance(self.x, self.y, p.x, p.y)
      p:hurt(30)
    end
    
    table.insert(self.bullets, {
      angle = i + (math.pi / 2),
      len = len
    })
  end
end

Shotgun.update = function(self)
  self.hp = timer.rot(self.hp, function() Spells:deactivate(self.id) end)
end

Shotgun.draw = function(self)
  love.graphics.setColor(255, 255, 255, (self.hp / Shotgun.hp) * 255)
  for _, bullet in pairs(self.bullets) do
    love.graphics.line(self.x, self.y, self.x + math.cos(bullet.angle) * bullet.len, self.y + math.sin(bullet.angle) * bullet.len)
  end
  love.graphics.setColor(255, 255, 255, 255)
end

return Shotgun