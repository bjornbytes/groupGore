local Roll = {}

----------------
-- Meta
----------------
Roll.name = 'Roll'
Roll.code = 'roll'
Roll.icon = 'media/graphics/icon.png'
Roll.text = 'It is a roll, commonly topped with butter and/or jam.'
Roll.type = 'skill'


----------------
-- Data
----------------
Roll.target = 'none'
Roll.cooldown = 5
Roll.chargeCooldown = .5
Roll.charges = 2


----------------
-- Behavior
----------------
function Roll.activate(self, myRoll)
  myRoll.cooldown = 0
  myRoll.charges = Roll.charges
end

function Roll.update(self, myRoll)
  myRoll.cooldown = timer.rot(myRoll.cooldown, function()
    if myRoll.charges == 0 then
      myRoll.charges = Roll.charges
    end
  end)
end

function Roll.canFire(self, myRoll)
  return myRoll.cooldown == 0 and myRoll.charges > 0
end

function Roll.fire(self, myRoll)
  ovw.spells:activate(self.id, data.spell.roll)
  myRoll.charges = myRoll.charges - 1
  if myRoll.charges == 0 then myRoll.cooldown = Roll.cooldown
  else myRoll.cooldown = Roll.chargeCooldown end
end

return Roll