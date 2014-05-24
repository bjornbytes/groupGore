local Dusk = {}

Dusk.code = 'dusk'
Dusk.distance = 160
Dusk.speed = Dusk.distance * 10

function Dusk:activate()
  self.angle = self.owner.angle
  self.health = Dusk.health
  ctx.event:emit('sound.play', {sound = 'dash'})
end

function Dusk:update()
  self.owner.x = self.owner.x + math.dx(self.speed * tickRate, self.angle)
  self.owner.y = self.owner.y + math.dy(self.speed * tickRate, self.angle)
  ctx.event:emit('collision.move', {object = self.owner, x = self.owner.x, y = self.owner.y})
  ctx.collision:resolve(self.owner)
  if self.owner.inputs then
    table.insert(self.owner.inputs, {
      tick = tick + 1,
      reposition = {
        x = self.owner.x,
        y = self.owner.y
      }
    })
  end

  self.distance = self.distance - (self.speed * tickRate)
  if self.distance <= 0 then
    ctx.spells:deactivate(self)
  end
end

return Dusk