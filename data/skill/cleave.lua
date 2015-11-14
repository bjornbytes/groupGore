local Cleave = {}

Cleave.name = 'Cleave'
Cleave.code = 'cleave'
Cleave.text = 'Spin2Win'
Cleave.type = 'skill'

Cleave.cooldown = 2
Cleave.damage = 55
Cleave.cost = 20

function Cleave:activate(owner)
  self.timer = 0
end

function Cleave:update(owner)
  self.timer = timer.rot(self.timer)
end

function Cleave:canFire(owner)
  return self.timer == 0 and owner.health > self.cost
end

function Cleave:fire(owner)
  ctx.spells:activate(owner.id, data.spell.cleave)
  ctx.net:emit(evtDamage, {id = owner.id, amount = self.cost, from = owner.id, tick = tick})
  self.timer = self.cooldown
end

function Cleave:value(owner)
  return self.timer / self.cooldown
end

return Cleave
