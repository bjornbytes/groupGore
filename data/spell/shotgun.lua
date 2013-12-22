local Shotgun = {}
Shotgun.code = 'shotgun'

Shotgun.hp = .1

Shotgun.activate = function(self)
  self.hp = Shotgun.hp
  self.x = self.owner.x
  self.y = self.owner.y
  
  local dir = self.owner.angle
  self.x = self.x + math.dx(data.weapon.shotgun.dx, dir) - math.dy(data.weapon.shotgun.dy, dir)
  self.y = self.y + math.dy(data.weapon.shotgun.dx, dir) + math.dx(data.weapon.shotgun.dy, dir)
  
  self.len = 600
  self.bullets = {}
  
  for i = self.owner.angle - .1, self.owner.angle + .1, .0625 do
    local ang, len = i + (math.pi / 2), self.len
    
    local x2, y2 = self.x + math.cos(ang) * len, self.y + math.sin(ang) * len
    local endx, endy = ovw.collision:checkLineWall(self.x, self.y, x2, y2, true)
    if not endx then
      endx, endy = x2, y2
    end
    
    local targets = {}
    ovw.players:with(function(p)
      return p.active and p.team ~= self.owner.team and math.hloca(self.x, self.y, endx, endy, p.x, p.y, p.size)
    end, function(p)
      table.insert(targets, {
        id = p.id,
        dist = math.distance(p.x, p.y, self.x, self.y)
      })
    end)
    
    table.sort(targets, function(a, b) return a.dist < b.dist end)
    if targets[1] then
      local p = ovw.players:get(targets[1].id)
      len = math.distance(self.x, self.y, p.x, p.y)
      ovw.net:emit(evtDamage, {id = p.id, amount = data.weapon.shotgun.damage, from = self.owner.id, tick = tick})
    end
    
    table.insert(self.bullets, {
      angle = i + (math.pi / 2),
      endx = endx,
      endy = endy
    })
  end
end

Shotgun.update = function(self)
  self.hp = timer.rot(self.hp, function() ovw.spells:deactivate(self) end)
end

Shotgun.draw = function(self)
  love.graphics.setColor(255, 255, 255, (self.hp / Shotgun.hp) * 255)
  for _, bullet in pairs(self.bullets) do
    love.graphics.line(self.x, self.y, bullet.endx, bullet.endy)
  end
  love.graphics.setColor(255, 255, 255, 255)
end

return Shotgun
