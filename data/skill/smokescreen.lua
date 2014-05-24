local Smokescreen = {}

Smokescreen.name = 'Smokescreen'
Smokescreen.code = 'smokescreen'
Smokescreen.text = 'Hide under a cover of smoke.'
Smokescreen.type = 'skill'

Smokescreen.needsMouse = true
Smokescreen.cooldown = 14

function Smokescreen:activate(owner)
  self.timer = 0
end

function Smokescreen:update(owner)
  self.timer = timer.rot(self.timer)
end

function Smokescreen:canFire(owner)
  return self.timer == 0
end

function Smokescreen:fire(owner, mx, my)
  ctx.spells:activate(owner.id, data.spell.smokescreen, mx, my)
  self.timer = self.cooldown
end

function Smokescreen:value(owner)
  return self.timer / self.cooldown
end

return Smokescreen
