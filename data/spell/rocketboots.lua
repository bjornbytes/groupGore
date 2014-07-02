local RocketBoots = {}

RocketBoots.code = 'rocketboots'
RocketBoots.maxDistance = 410
RocketBoots.duration = 1

function RocketBoots:activate(mx, my)
  self.hp = self.duration
  self.angle = self.owner.angle
  self.distance = math.min(self.maxDistance, math.distance(self.owner.x, self.owner.y, mx, my))
  self.speed = self.distance / self.duration
  self.tx, self.ty = self.owner.x + math.dx(self.distance, self.angle), self.owner.y + math.dy(self.distance, self.angle)

  local s = 1
  local d = 10
  local tx, ty = self.tx, self.ty
  while ctx.collision:circleTest(tx, ty, self.owner.radius, {tag = 'wall'}) do
    tx = self.tx + math.dx(d * s, self.angle)
    ty = self.ty + math.dy(d * s, self.angle)
    s = -s
    if s == 1 then d = d + 10 end
  end

  self.distance = math.distance(self.owner.x, self.owner.y, tx, ty)
  self.owner.z = 200
end

function RocketBoots:update()
  self.owner.x, self.owner.y = self.owner.x + math.dx(self.speed * tickRate, self.angle), self.owner.y + math.dy(self.speed * tickRate, self.angle)
  if self.owner.inputs then
    table.insert(self.owner.inputs, {
      tick = tick + 1,
      reposition = {
        x = self.owner.x,
        y = self.owner.y
      }
    })
  end

  self.hp = timer.rot(self.hp, function()
    self.owner.z = 0
    ctx.spells:deactivate(self)
  end)
end

return RocketBoots
