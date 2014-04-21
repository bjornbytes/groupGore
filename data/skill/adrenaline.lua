local Adrenaline = {}

----------------
-- Meta
----------------
Adrenaline.name = 'Adrenaline'
Adrenaline.code = 'adrenaline'
Adrenaline.text = 'It is Adrenaline.  It sucks.'
Adrenaline.type = 'skill'


----------------
-- Data
----------------
Adrenaline.target = 'none'
Adrenaline.cooldown = 6


----------------
-- Behavior
----------------
function Adrenaline.activate(self, adrenaline)
  adrenaline.cooldown = 0
  adrenaline.active = false
end

function Adrenaline.update(self, adrenaline)
  adrenaline.cooldown = timer.rot(adrenaline.cooldown)
end

function Adrenaline.canFire(self, adrenaline)
  return adrenaline.cooldown == 0
end

function Adrenaline.fire(self, adrenaline)
  if not adrenaline.active then
    ctx.buffs:add(self, 'adrenaline')
    adrenaline.active = true
    adrenaline.cooldown = 1
  else
    ctx.buffs:remove(self, 'adrenaline')
    adrenaline.active = false
    adrenaline.cooldown = Adrenaline.cooldown
  end
end

function Adrenaline.value(self, adrenaline)
  return adrenaline.cooldown / (adrenaline.active and 1 or Adrenaline.cooldown)
end

return Adrenaline
