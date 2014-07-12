local RocketBoots = extend(Spell)

RocketBoots.code = 'rocketboots'
RocketBoots.maxDistance = 410
RocketBoots.duration = 1
RocketBoots.radius = 100

function RocketBoots:activate(mx, my)
  self.timer = self.duration
  self.angle = self.owner.angle
  self.distance = math.min(self.maxDistance, math.distance(self.owner.x, self.owner.y, mx, my))
  self.tx, self.ty = self.owner.x + math.dx(self.distance, self.angle), self.owner.y + math.dy(self.distance, self.angle)
  self.owner.haste = -1000

  local s = 1
  local d = 10
  local tx, ty = self.tx, self.ty
  while ctx.collision:circleTest(tx, ty, self.owner.radius, {tag = 'wall'}) or tx <= 0 or ty <= 0 or tx >= ctx.map.width or ty >= ctx.map.height do
    tx = self.tx + math.dx(d * s, self.angle)
    ty = self.ty + math.dy(d * s, self.angle)
    s = -s
    if s == 1 then d = d + 10 end
  end
  if d > 10 or s == -1 then
    s = -s
    while not ctx.collision:circleTest(tx, ty, self.owner.radius, {tag = 'wall'}) do
      tx = self.tx + math.dx(d * s, self.angle)
      ty = self.ty + math.dy(d * s, self.angle)
      d = d - 1
    end
  end

  self.distance = math.distance(self.owner.x, self.owner.y, tx, ty)
  self.speed = self.distance / self.duration
  self.owner.z = 1
  self.zVel = 750
  self.zAcc = -1500
  self.empowered = ctx.buffs:get(self.owner, 'overexertion')
  ctx.buffs:remove(self.owner, 'overexertion')
end

function RocketBoots:update()
  self:moveOwner(self.speed * tickRate)
  self.owner.z = self.owner.z + self.zVel * tickRate
  self.zVel = self.zVel + self.zAcc * tickRate
  if self.owner.inputs then
    table.insert(self.owner.inputs, {
      tick = tick + 1,
      reposition = {
        x = self.owner.x,
        y = self.owner.y
      }
    })
  end

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
