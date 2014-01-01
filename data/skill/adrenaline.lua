local Adrenaline = {}

----------------
-- Meta
----------------
Adrenaline.name = 'Adrenaline'
Adrenaline.code = 'adrenaline'
Adrenaline.icon = 'media/graphics/icon.png'
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
function Adrenaline.activate(self, myAdrenaline)
  myAdrenaline.cooldown = 0
  myAdrenaline.active = false
end

function Adrenaline.update(self, myAdrenaline)
  myAdrenaline.cooldown = timer.rot(myAdrenaline.cooldown)
end

function Adrenaline.canFire(self, myAdrenaline)
  return myAdrenaline.cooldown == 0
end

function Adrenaline.fire(self, myAdrenaline)
  if not myAdrenaline.active then
    myAdrenaline.buff = ovw.buffs:add(data.buff.adrenaline, self.id, self.id)
    myAdrenaline.active = true
    myAdrenaline.cooldown = 1
  else
    myAdrenaline.buff.timer = tickRate / 2
    myAdrenaline.active = false
    myAdrenaline.cooldown = Adrenaline.cooldown
  end
end

return Adrenaline