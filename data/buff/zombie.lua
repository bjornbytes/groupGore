local Zombie = {}

----------------
-- Meta
----------------
Zombie.name = 'Zombie'
Zombie.code = 'zombie'
Zombie.text = 'Brains.'
Zombie.hide = false


----------------
-- Data
----------------
function Zombie:activate()
  self.owner.haste = self.owner.haste - (self.owner.class.speed * .5)
  self.damageMultAmount = self.owner.damageOutMultiplier * .5
  self.owner.damageOutMultiplier = self.owner.damageOutMultiplier - self.damageMultAmount

end

function Zombie:deactivate()
  self.owner.haste = self.owner.haste + (self.owner.class.speed * .5)
  self.owner.damageOutMultiplier = self.owner.damageOutMultiplier + self.damageMultAmount
end

return Zombie
