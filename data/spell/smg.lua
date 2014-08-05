local SMG = extend(Spell)
SMG.code = 'smg'

SMG.duration = .12

SMG.activate = function(self)
  self.timer = self.duration
  self.x = self.owner.x
  self.y = self.owner.y
  
  local dir = self.owner.angle
  
  local dx, dy = self.owner.class.handx * self.owner.class.scale, self.owner.class.handy * self.owner.class.scale
  self.x = self.x + math.dx(dx, dir) - math.dy(dy, dir)
  self.y = self.y + math.dy(dx, dir) + math.dx(dy, dir)
  
  dx, dy = data.weapon.smg.tipx * data.weapon.smg.scale, data.weapon.smg.tipy * data.weapon.smg.scale
  self.x = self.x + math.dx(dx, dir) - math.dy(dy, dir)
  self.y = self.y + math.dy(dx, dir) + math.dx(dy, dir)

  self.angle = self.owner.angle
  love.math.setRandomSeed(tick * 123456789 % (2 ^ 50), tick * 987654321 % (2 ^ 50))
  self.angle = self.angle - (data.weapon.smg.spread / 2) + (love.math.random() * data.weapon.smg.spread)
  self.len = 0
  local target = nil
  if not ctx.collision:lineTest(self.owner.x, self.owner.y, self.x, self.y, {tag = 'wall'}) then
    local hit, dis = ctx.collision:lineTest(self.x, self.y, self.x + math.dx(900, self.angle), self.y + math.dy(900, self.angle), {tag = 'wall', first = true})
    self.len = hit and dis or 900
    
    target = ctx.collision:lineTest(self.x, self.y, self.x + math.dx(self.len, self.angle), self.y + math.dy(self.len, self.angle), {
      tag = 'player',
      fn = function(p)
        return p.team ~= self.owner.team
      end,
      first = true
    })
  end

  if target then
    self.len = math.distance(self.x, self.y, target.x, target.y)
    ctx.net:emit(evtDamage, {id = target.id, amount = data.weapon.smg.damage, from = self.owner.id, tick = tick})
  end
  
  for _ = 1, 4 do
    ctx.event:emit('particle.create', {
      kind = 'spark',
      vars = {
        x = self.x,
        y = self.y,
        angle = self.angle + love.math.random() * 1.56 - .78
      }
    })
  end

  if not target and self.len < 900 then
    for _ = 1, 4 do
      ctx.event:emit('particle.create', {
        kind = 'spark',
        vars = {
          x = self.x + math.dx(self.len, self.angle),
          y = self.y + math.dy(self.len, self.angle),
          angle = self.angle + math.pi + love.math.random() * 2.08 - 1.04
        }
      })
    end
  end

  if target then
    for _ = 1, 4 do
      ctx.event:emit('particle.create', {
        kind = 'blood',
        vars = {
          x = target.x - 10 + love.math.random() * 20,
          y = target.y - 10 + love.math.random() * 20
        }
      })
    end
  end

  ctx.event:emit('particle.create', {
    kind = 'muzzleFlash',
    vars = {
      owner = self.owner.id,
      weapon = 'smg'
    }
  })

  ctx.event:emit('particle.create', {
    kind = 'shell',
    vars = {
      x = self.x,
      y = self.y,
      direction = self.owner.angle + love.math.random() * .8 - .4
    }
  })

  ctx.event:emit('sound.play', {sound = 'smg', x = self.x, y = self.y})
end

SMG.update = function(self)
	self:rot()
end

SMG.draw = function(self)
  local function doDraw()
    local alpha = self.timer / self.duration
    love.graphics.setColor(255, 255, 255, alpha * 255)
    love.graphics.line(self.x, self.y, self.x + math.cos(self.angle) * self.len, self.y + math.sin(self.angle) * self.len)
  end

  doDraw()
  ctx.effects:get('bloom'):render(doDraw)
end

return SMG
