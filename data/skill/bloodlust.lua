local Bloodlust = {}

----------------
-- Meta
----------------
Bloodlust.name = 'Bloodlust'
Bloodlust.code = 'bloodlust'
Bloodlust.icon = 'media/graphics/icon.png'
Bloodlust.text = 'It is Bloodlust.  My wife for hire.'
Bloodlust.type = 'passive'


----------------
-- Behavior
----------------
Bloodlust.activate = function(self, myBloodlust)
  ovw.event:on(evtDead, self, function(self, data)
    if data.kill == self.id and data.id ~= self.id then
      ovw.buffs:add(gg.buff.bloodlust, self.id, self.id)
    end
  end)
end

return Bloodlust
