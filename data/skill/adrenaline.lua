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
  myAdrenaline.cooldown = timer.rot(myAdrenaline.cooldown, f.empty)
end

function Adrenaline.canFire(self, myAdrenaline)
  return myAdrenaline.cooldown == 0
end

function Adrenaline.fire(self, myAdrenaline)
  if not myAdrenaline.active then
    ovw.buff:add(self, data.buff.adrenaline)
    myAdrenaline.active = true
    myAdrenaline.cooldown = 1
  else
    ovw.buff:remove(self, data.buff.adrenaline)
    myAdrenaline.active = false
    myAdrenaline.cooldown = Adrenaline.cooldown
  end
end

return Adrenaline