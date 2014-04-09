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
end

Bloodlust.update = function(self, myBloodlust)
  myBloodlust.time = timer.rot(myBloodlust.time)
end

Bloodlust.value = function(self, myBloodlust)
  local buff = ovw.buffs:get(self, 'bloodlust')
  if buff then
    return buff.timer / buff.duration
  end
  return 0
end

return Bloodlust
