local EnergyRifle = extend(Spell)
EnergyRifle.code = 'energyrifle'

EnergyRifle.image = data.media.graphics.effects.pulse
EnergyRifle.scale = 2
EnergyRifle.anchorx = 20
EnergyRifle.anchory = 2
EnergyRifle.speed = 1600

function EnergyRifle:activate()
  self:mirrorOwner()
  self:lerpInit()
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

  self:playSound('pulse')

  if ctx.collision:lineTest(self.owner.x, self.owner.y, self.x, self.y, {tag = 'wall'}) then
    ctx.spells:deactivate(self)
  end
end

function EnergyRifle:update()
  self:lerpUpdate()

  local distance = self.speed * tickRate
  local wallDistance = self:wallDistance(distance)
  local enemy = self:enemiesInLine(wallDistance)
  if enemy then
    ctx.buffs:add(enemy, 'plasmasickness')
    self:damage(enemy, data.weapon.energyrifle.damage)
  end

  self:move(wallDistance)
  if wallDistance < distance or enemy then self:die() end
end

function EnergyRifle:draw()
  local x, y = self:lerpGet()
  local function doDraw()
    love.graphics.setColor(255, 255, 255)
    self:drawImage({x = x, y = y})
  end

  doDraw()
  ctx.effects:get('bloom'):render(doDraw)
end

return EnergyRifle
