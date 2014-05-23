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
function Adrenaline:activate(owner)
  self.cooldown = 0
  self.active = false
end

function Adrenaline:update(owner)
  self.cooldown = timer.rot(self.cooldown)
end

function Adrenaline:canFire(owner)
  return self.cooldown == 0
end

function Adrenaline:fire(owner)
  if not self.active then
    ctx.buffs:add(owner, 'adrenaline')
    self.active = true
    self.cooldown = 1
  else
    ctx.buffs:remove(owner, 'adrenaline')
    self.active = false
    self.cooldown = Adrenaline.cooldown
  end
end

function Adrenaline:value(owner)
  return self.cooldown / (self.active and 1 or Adrenaline.cooldown)
end

return Adrenaline
