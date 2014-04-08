local Shadowform = {}

Shadowform.name = 'Shadowform'
Shadowform.code = 'shadowform'
Shadowform.text = 'Become one with the shadows.'
Shadowform.type = 'skill'

function Shadowform:activate(shadowform)
  shadowform.cooldown = 0
end

function Shadowform:update(shadowform)
  
end

function Shadowform:canFire(shadowform)
  
end

function Shadowform:fire(shadowform)
  
end

function Shadowform:value()
  return 0
end

return Shadowform