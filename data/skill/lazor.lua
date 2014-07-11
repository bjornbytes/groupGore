local Lazor = {}

Lazor.name = 'LAZOR'
Lazor.code = 'lazor'
Lazor.text = 'Ima firin\' Malaysia!'
Lazor.type = 'skill'

Lazor.cooldown = 10

function Lazor:activate()
  self.timer = 0
end

function Lazor:update(owner)
  self.timer = timer.rot(self.timer)
end

function Lazor:canFire()
  return self.timer == 0
end

function Lazor:fire(owner)
  ctx.spells:activate(owner.id, data.spell.lazor)
  self.timer = self.cooldown
end

function Lazor:draw(owner)
  if owner.id == ctx.id then
    --
  end
end

function Lazor:value(owner)
  return self.timer / self.cooldown
end

return Lazor
