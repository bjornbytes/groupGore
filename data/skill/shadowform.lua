local Shadowform = {}

Shadowform.name = 'Shadowform'
Shadowform.code = 'shadowform'
Shadowform.text = 'Become one with the shadows.'
Shadowform.type = 'skill'

Shadowform.cooldown = 9

function Shadowform:activate(shadowform)
  shadowform.timer = 0
end

function Shadowform:update(shadowform)
  shadowform.timer = timer.rot(shadowform.timer, function()
    ctx.buffs:remove(self, 'shadowform')
  end)
end

function Shadowform:canFire(shadowform)
  return shadowform.timer == 0
end

function Shadowform:fire(shadowform)
  ctx.buffs:add(self, 'shadowform')
  shadowform.timer = shadowform.cooldown
end

function Shadowform:value(shadowform)
  return shadowform.timer / shadowform.cooldown
end

return Shadowform
