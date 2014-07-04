local Dusk = {}

Dusk.name = 'Dusk'
Dusk.code = 'dusk'
Dusk.text = 'Move through the shadows.'
Dusk.type = 'skill'

Dusk.needsMouse = true
Dusk.targeted = true
Dusk.cooldown = 8

function Dusk:activate(owner)
  self.timer = 0
  self.targetAlpha = 0
end

function Dusk:update(owner)
  self.timer = timer.rot(self.timer)
  if self.timer > 1 and owner.cloak > 0 then self.timer = 1 end
  self.targetAlpha = math.lerp(self.targetAlpha, self.targeting and 1 or 0, math.min(10 * tickRate, 1))
end

function Dusk:canFire(owner)
  return self.timer == 0
end

function Dusk:fire(owner, mx, my)
  ctx.spells:activate(owner.id, data.spell.dusk, mx, my)
  self.timer = owner.cloak > 0 and 1 or self.cooldown
  self.targetAlpha = 0
end

function Dusk:gui(owner)
  if self.targetAlpha > 0 then
    local g, v = love.graphics, ctx.view
    ctx.view:worldPush()
    g.setColor(255, 255, 255, self.targetAlpha * 255)
    g.circle('line', owner.drawX, owner.drawY, data.spell.dusk.maxDistance)
    g.pop()
  end
end

function Dusk:value(owner)
  return self.timer / self.cooldown
end

return Dusk
