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
Adrenaline.drain = 10
Adrenaline.cooldown = 6

function Adrenaline.activate(self, myAdrenaline)
  myAdrenaline.cooldown = 0
  myAdrenaline.active = false
end

function Adrenaline.update(self, myAdrenaline)
  timer.rot(myAdrenaline.cooldown, f.empty)
  if myAdrenaline.active and self.hp > (Adrenaline.drain * tickRate) then
    self.hp = self.hp - (Adrenaline.drain * tickRate)
  end
end

function Adrenaline.canFire(self, myAdrenaline)
  return myAdrenaline.cooldown == 0
end

function Adrenaline.fire(self, myAdrenaline)
  if not myAdrenaline.active then
    self:addBuff(data.buff.adrenaline)
    myAdrenaline.active = true
  else
    self:removeBuff(data.buff.adrenaline)
    myAdrenaline.active = false
  end
end

return Adrenaline