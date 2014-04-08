local Smokescreen = {}

Smokescreen.name = 'Smokescreen'
Smokescreen.code = 'smokescreen'
Smokescreen.text = 'Slow and blind enemies.'
Smokescreen.type = 'skill'

function Smokescreen:activate(smokescreen)
  smokescreen.cooldown = 0
end

function Smokescreen:update(smokescreen)
  
end

function Smokescreen:canFire(smokescreen)
  
end

function Smokescreen:fire(smokescreen)
  
end

function Smokescreen:value()
  return 0
end

return Smokescreen