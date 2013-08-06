local Rage = {}

----------------
-- Meta
----------------
Rage.name = 'Rage'
Rage.icon = 'media/graphics/icon.png'
Rage.text = 'All of myRage.'
Rage.type = 'skill'


----------------
-- Data
---------------- Still gotta work out the specifics of this guy.
Rage.target = 'none'

function Rage.activate(self, myRage)
  myRage.amount = 0
  myRage.active = false
end

function Rage.update(self, myRage)
  --
end

function Rage.canFire(self, myRage)
  return myRage.amount == 50 and not myRage.active
end

function Rage.fire(self, myRage)
  if not myRage.active then
    self:addBuff(RageBuff)
    myRage.active = true
  end
end

return Rage