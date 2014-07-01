local Cleave = {}

Cleave.name = 'Cleave'
Cleave.code = 'cleave'
Cleave.text = 'Spin2Win'
Cleave.type = 'skill'

Cleave.cooldown = 2
Cleave.damage = 55

function Cleave:activate(owner)
  self.timer = 0
end

function Cleave:update(owner)
  self.timer = timer.rot(self.timer)
end

function Cleave:canFire(owner)
  return self.timer == 0
end

function Cleave:fire(owner)
  ctx.spells:activate(owner.id, data.spell.cleave)
  self.timer = self.cooldown
end

function Cleave:value(owner)
  return self.timer / self.cooldown
end

return Cleave