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
    local hit, d = ovw.collision:lineTest(self.x, self.y, self.x + math.dx(len, ang), self.y + math.dy(len, ang), {tag = 'wall', first = true})
    len = hit and d or len
    
    hit = ovw.collision:lineTest(self.x, self.y, self.x + math.dx(len, ang), self.y + math.dy(len, ang), {
      tag = 'player',
      fn = function(p)
        return p.team ~= self.owner.team
      end,
      first = true
    })
    
    if hit then
      local p = hit.player
      len = hit.distance
      
      local n, f = self.len * .25, self.len * .75
      local l, h = data.weapon.shotgun.damage * .4, data.weapon.shotgun.damage * 1
      local damage = l + ((h - l) * ((f - math.clamp(len, n, f)) / f))
      ovw.net:emit(evtDamage, {id = p.id, amount = damage, from = self.owner.id, tick = tick})
    end
    
    table.insert(self.bullets, {
      dir = ang,
      dis = len
    })
    
    if ovw.particles and len < self.len then
      for _ = 1, 4 do
        ovw.particles:create('spark', {
          x = self.x + math.dx(len, ang),
          y = self.y + math.dy(len, ang),
          angle = i + math.pi + love.math.random() * 2.08 - 1.04
        })
      end
    end
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
    love.graphics.line(self.x, self.y, self.x + math.dx(bullet.dis, bullet.dir), self.y + math.dy(bullet.dis, bullet.dir))
  end
end

return Shotgun
