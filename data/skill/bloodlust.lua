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
    if data.kill == self.id then
      ovw.buff:add(data.buff.bloodlust, self.id, self.id)
    end
  end)
end

return Bloodlust
