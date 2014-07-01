local Dusk = {}

Dusk.name = 'Dusk'
Dusk.code = 'dusk'
Dusk.text = 'Move through the shadows.'
Dusk.type = 'skill'

Dusk.needsMouse = true
Dusk.cooldown = 8

function Dusk:activate(owner)
  self.timer = 0
end

function Dusk:update(owner)
  self.timer = timer.rot(self.timer)
  if self.timer > 1 and owner.cloak > 0 then self.timer = 1 end
end

function Dusk:canFire(owner)
  return self.timer == 0
end

function Dusk:fire(owner, mx, my)
  ctx.spells:activate(owner.id, data.spell.dusk, mx, my)
  self.timer = owner.cloak > 0 and 1 or self.cooldown
end

function Dusk:draw(owner)
  local r, g, b, a = love.graphics.getColor()
  love.graphics.setColor(255, 255, 255, 30)
  love.graphics.circle('line', owner.x, owner.y, data.spell.dusk.maxDistance)
  love.graphics.setColor(r, g, b, a)
end

function Dusk:value(owner)
  return self.timer / self.cooldown
end

return Dusk
