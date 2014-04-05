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
Rage.max = 200


----------------
-- Behavior
----------------
function Rage.activate(self, myRage)
  myRage.active = false
  ovw.event:on(evtDamage, function(data)
    if data.from == self.id and ovw.players:get(data.id).team ~= self.team then
      self.rage = math.min(self.rage + data.amount, myRage.max)
    end
  end)
end

function Rage.update(self, myRage)
  --
end

function Rage.canFire(self, myRage)
  return self.rage == myRage.max and not myRage.active
end

function Rage.fire(self, myRage)
  if not myRage.active then
    ovw.buffs:add(data.buff.rage, self.id, self.id)
    myRage.active = true
    self.rage = 0
  end
end

return Rage