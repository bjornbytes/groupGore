local Smokescreen = {}

Smokescreen.name = 'Smokescreen'
Smokescreen.code = 'smokescreen'
Smokescreen.text = 'Slow and blind enemies.'
Smokescreen.type = 'skill'

Smokescreen.cooldown = 14

function Smokescreen:activate(smokescreen)
  smokescreen.timer = 0
end

function Smokescreen:update(smokescreen)
  smokescreen.timer = timer.rot(smokescreen.timer)
end

function Smokescreen:canFire(smokescreen)
  return smokescreen.timer == 0
end

function Smokescreen:fire(smokescreen)
  ovw.spells:activate(self.id, data.spell.smokescreen)
  smokescreen.timer = smokescreen.cooldown
end

function Smokescreen:value(smokescreen)
  return smokescreen.timer / smokescreen.cooldown
end

return Smokescreen