local Rage = {}

----------------
-- Meta
----------------
Rage.name = 'Rage'
Rage.code = 'rage'
Rage.icon = 'media/graphics/icon.png'
Rage.text = 'All of my Rage.'
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
  ovw.event:on(evtDamage, self, function(self, data)
    if data.from == self.id then
      myRage.amount = math.min(myRage.amount + data.amount, myRage.max)
    end
  end)
end

function Rage.update(self, myRage)
  --
end

function Rage.hud(self, myRage)
  love.graphics.setColor(255, 255, 255)
  love.graphics.print(myRage.amount, 0, 0)
end

function Rage.canFire(self, myRage)
  return myRage.amount == myRage.max and not myRage.active
end

function Rage.fire(self, myRage)
  if not myRage.active then
    ovw.buffs:add(data.buff.rage, self.id, self.id)
    myRage.active = true
  end
end

return Rage