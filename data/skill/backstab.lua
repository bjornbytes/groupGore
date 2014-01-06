local Backstab = {}

----------------
-- Meta
----------------
Backstab.name = 'Backstab'
Backstab.code = 'backstab'
Backstab.icon = 'media/graphics/icon.png'
Backstab.text = 'Backsterb.'
Backstab.type = 'skill'


----------------
-- Data
----------------
Backstab.target = 'none'
Backstab.cooldown = 5


----------------
-- Behavior
----------------
function Backstab.activate(self, myBackstab)
  myBackstab.cooldown = 0
end

function Backstab.update(self, myBackstab)
  myBackstab.cooldown = timer.rot(myBackstab.cooldown)
end

function Backstab.canFire(self, myBackstab)
  return myBackstab.cooldown == 0
end

function Backstab.fire(self, myBackstab)
  --
end

return Backstab