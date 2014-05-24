local Weapon = {}

Weapon.name = 'Dagger'
Weapon.code = 'dagger'
Weapon.text = 'Stabby'
Weapon.type = 'weapon'

Weapon.damage = 45
Weapon.cooldown = .8

function Weapon:activate(owner)
  self.timer = 0
end

function Weapon:update(owner)
  self.timer = timer.rot(self.timer)
end

function Weapon:canFire(owner)
  return self.timer == 0
end

function Weapon:fire(owner)
  ctx.spells:activate(self.id, data.spell.dagger)
  self.timer = self.cooldown
end

function Weapon:draw(owner)
  --
end

return Weapon
