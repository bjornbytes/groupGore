SMG = {}
SMG.code = 'smg'
SMG.hp = .12

SMG.activate = function(self)
  self.hp = SMG.hp
  self.x = self.owner.x
  self.y = self.owner.y
  
  local dir = self.owner.angle
  
  local dx, dy = self.owner.class.handx, self.owner.class.handy
  self.x = self.x + math.dx(dx, dir) - math.dy(dy, dir)
  self.y = self.y + math.dy(dx, dir) + math.dx(dy, dir)
  
  dx, dy = data.weapon.smg.tipx, data.weapon.smg.tipy
  self.x = self.x + math.dx(dx, dir) - math.dy(dy, dir)
  self.y = self.y + math.dy(dx, dir) + math.dx(dy, dir)
  
  self.angle = self.owner.angle
  self.angle = self.angle - (data.weapon.smg.spread / 2) + (2 * love.math.random() * data.weapon.smg.spread)
  local hit = ovw.collision:wallRaycast(self.x, self.y, self.angle, 900)
  self.len = hit and hit.distance or 900
  
  local hit = ovw.collision:playerRaycast(self.x, self.y, self.angle, {
    distance = self.len,
    team = 1 - self.owner.team,
    sort = true,
    all = false
  })

  if hit then
    local p = hit.player
    self.len = math.distance(self.x, self.y, p.x, p.y)
    ovw.net:emit(evtDamage, {id = p.id, amount = data.weapon.smg.damage, from = self.owner.id, tick = tick})
  end
  
  if ovw.particles then
    for _ = 1, 4 do
      ovw.particles:create('spark', {
        x = self.x,
        y = self.y,
        angle = self.angle + love.math.random() * 1.56 - .78
      })
    end
    
    if self.len < 900 then
      for _ = 1, 4 do
        ovw.particles:create('spark', {
          x = self.x + math.dx(self.len, self.angle),
          y = self.y + math.dy(self.len, self.angle),
          angle = self.angle + math.pi + love.math.random() * 2.08 - 1.04
        })
      end
    end
  end
  
  if ovw.sound then
    ovw.sound:play('smg')
  end
end

SMG.update = function(self)
  self.hp = timer.rot(self.hp, function() ovw.spells:deactivate(self) end)
end

SMG.draw = function(self)
  local alpha = self.hp / .12
  love.graphics.setColor(255, 255, 255, alpha * 255)
  love.graphics.line(self.x, self.y, self.x + math.cos(self.angle) * self.len, self.y + math.sin(self.angle) * self.len)
end

return SMG