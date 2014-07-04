local Smokescreen = {}

Smokescreen.name = 'Smokescreen'
Smokescreen.code = 'smokescreen'
Smokescreen.text = 'Hide under a cover of smoke.'
Smokescreen.type = 'skill'

Smokescreen.needsMouse = true
Smokescreen.targeted = true
Smokescreen.cooldown = 14

function Smokescreen:activate(owner)
  self.timer = 0
  self.targetAlpha = 0
end

function Smokescreen:update(owner)
  self.timer = timer.rot(self.timer)
  self.targetAlpha = math.lerp(self.targetAlpha, self.targeting and 1 or 0, math.min(10 * tickRate, 1))
end

function Smokescreen:canFire(owner)
  return self.timer == 0
end

function Smokescreen:fire(owner, mx, my)
  ctx.spells:activate(owner.id, data.spell.smokescreen, mx, my)
  self.timer = Smokescreen.cooldown
  self.targetAlpha = 0
end

function Smokescreen:gui(owner)
  if self.targetAlpha > 0 then
    local g, v = love.graphics, ctx.view
    g.setColor(255, 255, 255, self.targetAlpha * 255)
    g.circle('line', v:frameMouseX(), v:frameMouseY(), data.spell.smokescreen.radius)
  end
end

function Smokescreen:value(owner)
  return self.timer / self.cooldown
end

return Smokescreen
