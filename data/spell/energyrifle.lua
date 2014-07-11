local EnergyRifle = {}
EnergyRifle.code = 'energyrifle'

EnergyRifle.speed = 1800

function EnergyRifle:activate()
  self.x = self.owner.x
  self.y = self.owner.y
  self.prevx = self.x
  self.prevy = self.y
  self.angle = self.owner.angle
  self.ded = false
  
  local dx, dy = self.owner.class.handx * self.owner.class.scale, self.owner.class.handy * self.owner.class.scale
  self.x = self.x + math.dx(dx, self.angle) - math.dy(dy, self.angle)
  self.y = self.y + math.dy(dx, self.angle) + math.dx(dy, self.angle)
  
  dx, dy = data.weapon.energyrifle.tipx * data.weapon.energyrifle.scale, data.weapon.energyrifle.tipy * data.weapon.energyrifle.scale
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

  ctx.event:emit('sound.play', {sound = 'pulse', x = self.x, y = self.y})

  if ctx.collision:lineTest(self.owner.x, self.owner.y, self.x, self.y, {tag = 'wall'}) then
    ctx.spells:deactivate(self)
  end
end

function EnergyRifle:update()
  if self.ded then return ctx.spells:deactivate(self) end

  self.prevx, self.prevy = self.x, self.y
  local dis = self.speed * tickRate
  local wall, d = ctx.collision:lineTest(self.x, self.y, self.x + math.dx(dis, self.angle), self.y + math.dy(dis, self.angle), {tag = 'wall'})
  if wall then dis = d end
  local tx, ty = self.x + math.dx(dis, self.angle), self.y + math.dy(dis, self.angle)

  local target = ctx.collision:lineTest(self.x, self.y, tx, ty, {tag = 'player', fn = function(p) return p.team ~= self.owner.team end, first = true})
  if target then
    ctx.net:emit(evtDamage, {id = target.id, amount = data.weapon.energyrifle.damage, from = self.owner.id, tick = tick})
    ctx.buffs:add(target, 'plasmasickness')
  end

  self.ded = wall or target
  self.x, self.y = tx, ty
end

function EnergyRifle:draw()
  local x, y = math.lerp(self.prevx, self.x, tickDelta / tickRate), math.lerp(self.prevy, self.y, tickDelta / tickRate)
  local function doDraw()
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(data.media.graphics.effects.pulse, x, y, self.angle, 2, 2, 20, 2)
  end

  doDraw()
  ctx.effects:get('bloom'):render(doDraw)
end

return EnergyRifle
