local Shotgun = extend(app.core.spell)
Shotgun.code = 'shotgun'

Shotgun.duration = .1

Shotgun.activate = function(self)
  self.timer = self.duration
  self.x = self.owner.x
  self.y = self.owner.y

  local dir = self.owner.angle

  local dx, dy = self.owner.class.handx * self.owner.class.scale, self.owner.class.handy * self.owner.class.scale
  self.x = self.x + math.dx(dx, dir) - math.dy(dy, dir)
  self.y = self.y + math.dy(dx, dir) + math.dx(dy, dir)

  dx, dy = data.weapon.shotgun.tipx * data.weapon.shotgun.scale, data.weapon.shotgun.tipy * data.weapon.shotgun.scale
  self.x = self.x + math.dx(dx, dir) - math.dy(dy, dir)
  self.y = self.y + math.dy(dx, dir) + math.dx(dy, dir)


  self.len = 800
  self.bullets = {}

  if not ctx.collision:lineTest(self.owner.x, self.owner.y, self.x, self.y, {tag = 'wall'}) then
    local spread = data.weapon.shotgun.spread / (data.weapon.shotgun.count - 1)
    local initial = self.owner.angle - spread * ((data.weapon.shotgun.count - 1) / 2)
    for i = 1, data.weapon.shotgun.count do
      local ang, len = initial + ((i - 1) * spread), self.len
      local hit, d = ctx.collision:lineTest(self.x, self.y, self.x + math.dx(len, ang), self.y + math.dy(len, ang), {tag = 'wall', first = true})
      len = hit and d or len

      hit, d = ctx.collision:lineTest(self.x, self.y, self.x + math.dx(len, ang), self.y + math.dy(len, ang), {
        tag = 'player',
        fn = function(p)
          return p.team ~= self.owner.team
        end,
        first = true
      })

      if hit then
        local p = hit
        len = d

        local n, f = self.len * .25, self.len * .75
        local l, h = data.weapon.shotgun.damage * .4, data.weapon.shotgun.damage * 1
        local damage = l + ((h - l) * ((f - math.clamp(len, n, f)) / f))
        ctx.net:emit(app.core.net.events.damage, {id = p.id, amount = damage, from = self.owner.id, tick = tick})
      end

      table.insert(self.bullets, {
        dir = ang,
        dis = len
      })

      if not hit and len < self.len then
        for _ = 1, 4 do
          ctx.event:emit('particle.create', {
            kind = 'spark',
            vars = {
              x = self.x + math.dx(len, ang),
              y = self.y + math.dy(len, ang),
              angle = ang + math.pi + love.math.random() * 2.08 - 1.04
            }
          })
        end
      end

      if hit then
        for _ = 1, 4 do
          ctx.event:emit('particle.create', {
            kind = 'blood',
            vars = {
              x = hit.x - 10 + love.math.random() * 20,
              y = hit.y - 10 + love.math.random() * 20
            }
          })
        end
      end
    end
  end

  for _ = 1, 4 do
    ctx.event:emit('particle.create', {
      kind = 'spark',
      vars = {
        x = self.x,
        y = self.y,
        angle = self.owner.angle + love.math.random() * 1.56 - .78
      }
    })
  end

  ctx.event:emit('particle.create', {
    kind = 'muzzleFlash',
    vars = {
      owner = self.owner.id,
      weapon = 'shotgun'
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

  self:playSound('shotgun')
end

Shotgun.update = function(self)
  self:rot()
end

Shotgun.draw = function(self)
  local function doDraw()
    love.graphics.setColor(255, 255, 255, (self.timer / self.duration) * 255)
    for _, bullet in pairs(self.bullets) do
      love.graphics.line(self.x, self.y, self.x + math.dx(bullet.dis, bullet.dir), self.y + math.dy(bullet.dis, bullet.dir))
    end
  end

  doDraw()
  ctx.effects:get('bloom'):render(doDraw)
end

return Shotgun
