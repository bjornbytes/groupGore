local Bloodlust = {}

----------------
-- Meta
----------------
Bloodlust.name = 'Bloodlust'
Bloodlust.code = 'bloodlust'
Bloodlust.text = 'It is Bloodlust.  My wife for hire.'
Bloodlust.type = 'passive'


----------------
-- Behavior
----------------
Bloodlust.activate = function(self, myBloodlust)
  ovw.event:on(evtDead, function(data)
    if data.kill == self.id and data.id ~= self.id then
      ovw.buffs:add(gg.buff.bloodlust, self.id, self.id)
    end
  end)

  myBloodlust.time = 0
end

Bloodlust.update = function(self, myBloodlust)
  myBloodlust.time = timer.rot(myBloodlust.time)
end

Bloodlust.value = function(myBloodlust)
  return myBloodlust.time / data.buff.bloodlust.duration
end

return Bloodlust
