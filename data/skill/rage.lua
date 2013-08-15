local Rage = {}

----------------
-- Meta
----------------
Rage.name = 'Rage'
Rage.code = 'rage'
Rage.icon = 'media/graphics/icon.png'
Rage.text = 'All of myRage.'
Rage.type = 'skill'


----------------
-- Meta
----------------
Rage.max = 50


----------------
-- Behavior
----------------
function Rage.activate(self, myRage)
  myRage.amount = 0
  myRage.active = false
end

function Rage.update(self, myRage)
  --
end

function Rage.canFire(self, myRage)
  return myRage.amount == myRage.max and not myRage.active
end

function Rage.fire(self, myRage)
  if not myRage.active then
    Buff:add(self, data.buff.rage)
    myRage.active = true
  end
end

return Rage