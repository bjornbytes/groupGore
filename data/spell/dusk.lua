local Dusk = {}

Dusk.code = 'dusk'
Dusk.maxDistance = 300

function Dusk:activate(mx, my)
  self.angle = self.owner.angle
  self.distance = math.min(self.maxDistance, math.distance(self.owner.x, self.owner.y, mx, my))
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

  self.owner.x, self.owner.y = tx, ty
  ctx.collision:update()
  if self.owner.inputs then
    table.insert(self.owner.inputs, {
      tick = tick + 1,
      reposition = {
        x = self.owner.x,
        y = self.owner.y
      }
    })
  end

  ctx.event:emit('sound.play', {sound = 'dash', x = self.owner.x, y = self.owner.y})
  ctx.spells:deactivate(self)
end

return Dusk
