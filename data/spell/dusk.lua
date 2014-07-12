local Dusk = extend(Spell)

Dusk.code = 'dusk'
Dusk.maxDistance = 300

function Dusk:activate(mx, my)
	self:mirrorOwner()

	local distance = math.min(self.maxDistance, math.distance(self.x, self.y, mx, my))
	self:move(distance)

  local s = 1
  local d = 10
  local tx, ty = self.x, self.y
  while ctx.collision:circleTest(tx, ty, self.owner.radius, {tag = 'wall'}) or tx <= 0 or ty <= 0 or tx >= ctx.map.width or ty >= ctx.map.height do
    tx = self.x + math.dx(d * s, self.angle)
    ty = self.y + math.dy(d * s, self.angle)
    s = -s
    if s == 1 then d = d + 10 end
  end
  if d > 10 or s == -1 then
    s = -s
    while not ctx.collision:circleTest(tx, ty, self.owner.radius, {tag = 'wall'}) do
      tx = self.x + math.dx(d * s, self.angle)
      ty = self.y + math.dy(d * s, self.angle)
      d = d - 1
    end
  end

  self.owner.x, self.owner.y = tx, ty
  self.owner.moving = true
  ctx.collision:update()
  self.owner.moving = nil
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
