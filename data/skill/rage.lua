local Rage = {}

----------------
-- Meta
----------------
Rage.name = 'Rage'
Rage.code = 'rage'
Rage.text = 'The Brute gains 20% lifesteal when below 50% health.'
Rage.type = 'passive'


----------------
-- Behavior
----------------
function Rage.activate(self, myRage)
  --
end

function Rage.update(self, myRage)
  if self.health < self.maxHealth * .5 then
    if not ovw.buffs:get(self, 'rage') then
      ovw.buffs:add(self, 'rage')
    end
  else
    ovw.buffs:remove(self, 'rage')
  end
end

return Rage