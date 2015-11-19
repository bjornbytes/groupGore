local RocketBoots = extend(app.logic.spell)

RocketBoots.code = 'rocketboots'
RocketBoots.maxDistance = 410
RocketBoots.duration = 1
RocketBoots.radius = 100

function RocketBoots:activate(mx, my)
  self.timer = self.duration
  self:mirrorOwner()
  self.owner.z = 1
  self.owner.haste = -1000
  self.zVel = 750
  self.zAcc = -1500
  self.empowered = ctx.buffs:get(self.owner, 'overexertion')
  ctx.buffs:remove(self.owner, 'overexertion')

  local distance = math.min(self.maxDistance, math.distance(self.owner.x, self.owner.y, mx, my))
  local tx, ty = self.x + math.dx(distance, self.angle), self.y + math.dy(distance, self.angle)
  self.distance = math.distance(self.x, self.y, self:resolveCircle(tx, ty, self.owner.radius))
  self.speed = self.distance / self.duration
end

function RocketBoots:update()
  self:moveOwner(self.speed * tickRate)
  self.owner.z = self.owner.z + self.zVel * tickRate
  self.zVel = self.zVel + self.zAcc * tickRate

  self:rot(function()
    self.owner.z = 0
    self.owner.haste = self.owner.haste + 1000
    self.x, self.y = self.owner.x, self.owner.y
    table.each(self:enemiesInRadius(), function(p)
      ctx.buffs:add(p, self.empowered and 'rocketbootsstun' or 'rocketbootsslow')
    end)
  end)
end

return RocketBoots
