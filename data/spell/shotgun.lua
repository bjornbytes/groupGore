local Shotgun = {}
Shotgun.code = 'shotgun'

Shotgun.hp = .1

Shotgun.activate = function(self)
  self.hp = Shotgun.hp
  self.x = self.owner.x
  self.y = self.owner.y
  
  local dir = self.owner.angle
  
  local dx, dy = self.owner.class.handx, self.owner.class.handy
  self.x = self.x + math.dx(dx, dir) - math.dy(dy, dir)
  self.y = self.y + math.dy(dx, dir) + math.dx(dy, dir)
  
  dx, dy = data.weapon.shotgun.tipx, data.weapon.shotgun.tipy
  self.x = self.x + math.dx(dx, dir) - math.dy(dy, dir)
  self.y = self.y + math.dy(dx, dir) + math.dx(dy, dir)
  
  self.len = 600
  self.bullets = {}
  
  for i = self.owner.angle - data.weapon.shotgun.spread, self.owner.angle + data.weapon.shotgun.spread + (.001), (2 * data.weapon.shotgun.spread / (data.weapon.shotgun.count - 1)) do
    local ang, len = i, self.len
    
    local x2, y2 = self.x + math.cos(ang) * len, self.y + math.sin(ang) * len
    local endx, endy = ovw.collision:checkLineWall(self.x, self.y, x2, y2, true)
    local wall = true
    if not endx then
      endx, endy = x2, y2
      wall = false
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
      local n, f = self.len * .25, self.len * .75
      local l, h = data.weapon.shotgun.damage * .4, data.weapon.shotgun.damage * 1
      local damage = l + ((h - l) * ((f - math.clamp(len, n, f)) / f))
      ovw.net:emit(evtDamage, {id = p.id, amount = damage, from = self.owner.id, tick = tick})
    elseif wall and ovw.particles then
      for _ = 1, 4 do
        ovw.particles:create('spark', {
          x = endx,
          y = endy,
          angle = i + math.pi + love.math.random() * 2.08 - 1.04
        })
      end
    end
    
    table.insert(self.bullets, {
      endx = endx,
      endy = endy
    })
  end
  
  if ovw.particles then
    for _ = 1, 4 do
      ovw.particles:create('spark', {
        x = self.x,
        y = self.y,
        angle = self.owner.angle + love.math.random() * 1.56 - .78
      })
    end
  end
  
  if ovw.sound then
    ovw.sound:play('shotgun')
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
end

return Shotgun
