local PlasmaCannon = extend(Spell)
PlasmaCannon.code = 'plasmacannon'

function PlasmaCannon:activate(charge)
  local weapon = data.weapon.plasmacannon
  self.speed = 800 + (charge / weapon.maxCharge) * 3000
  self.damage = weapon.minDamage + (charge / weapon.maxCharge) * (weapon.maxDamage - weapon.minDamage)
  self.radius = 30 + (charge / weapon.maxCharge) * 120
  self.ded = false
  self:mirrorOwner()

  local dx, dy = self.owner.class.handx * self.owner.class.scale, self.owner.class.handy * self.owner.class.scale
  self.x = self.x + math.dx(dx, self.angle) - math.dy(dy, self.angle)
  self.y = self.y + math.dy(dx, self.angle) + math.dx(dy, self.angle)

  dx, dy = weapon.tipx * weapon.scale, weapon.tipy * weapon.scale
  self.x = self.x + math.dx(dx, self.angle) - math.dy(dy, self.angle)
  self.y = self.y + math.dy(dx, self.angle) + math.dx(dy, self.angle)

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

  ctx.event:emit('particle.create', {
    kind = 'muzzleFlash',
    vars = {
      owner = self.owner.id,
      weapon = 'energyrifle'
    }
  })

  self:playSound('pulse')

  local d = math.distance(self.owner.x, self.owner.y, self.x, self.y)
  if self:wallDistance(d) < d then self:die() end
end

function PlasmaCannon:update()
  if self.ded then return ctx.spells:deactivate(self) end

  self.prevx, self.prevy = self.x, self.y
  local dis = self.speed * tickRate
  local wall, d = ctx.collision:lineTest(self.x, self.y, self.x + math.dx(dis, self.angle), self.y + math.dy(dis, self.angle), {tag = 'wall'})
  if wall then dis = d end
  local tx, ty = self.x + math.dx(dis, self.angle), self.y + math.dy(dis, self.angle)

  local target, d = ctx.collision:lineTest(self.x, self.y, tx, ty, {tag = 'player', fn = function(p) return p.team ~= self.owner.team end, first = true})
  if target and d < dis then d = dis end
  if target or wall then
    self.x, self.y = self.x + math.dx(dis, self.angle), self.y + math.dy(dis, self.angle)
    local targets = ctx.collision:circleTest(self.x, self.y, self.radius, {tag = 'player', fn = function(p) return p.team ~= self.owner.team end, all = true})
    table.each(targets, function(p)
      ctx.net:emit(evtDamage, {id = p.id, amount = self.damage, from = self.owner.id, tick = tick})
      ctx.buffs:add(p, 'plasmasickness')
    end)
    ctx.event:emit('particle.create', {
      kind = 'plasmacannon',
      vars = {
        x = self.x,
        y = self.y,
        radius = self.radius
      }
    })
    self.ded = true
  else
    self.x, self.y = tx, ty
  end
end

function PlasmaCannon:draw()
  local g = love.graphics
  local x, y = math.lerp(self.prevx, self.x, tickDelta / tickRate), math.lerp(self.prevy, self.y, tickDelta / tickRate)
  g.setColor(0, 255, 255)
  g.circle('fill', x, y, 10)
end

return PlasmaCannon
