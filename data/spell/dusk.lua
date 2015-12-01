local Dusk = extend(app.logic.spell)

Dusk.code = 'dusk'
Dusk.maxDistance = 300

function Dusk:activate(mx, my)
	self:mirrorOwner()

	local distance = math.min(self.maxDistance, math.distance(self.x, self.y, mx, my))
	local tx, ty = self.x + math.dx(distance, self.angle), self.y + math.dy(distance, self.angle)
	self.owner.x, self.owner.y = self:resolveCircle(tx, ty, self.owner.radius)

  self.owner.moving = true
  ctx.event:emit('collision.move', {object = self.owner, resolve = true})
  self.owner.moving = nil
	self:moveOwnerTo(self.owner.x, self.owner.y)

	self:playSound('dash')
	self:die()
end

return Dusk
