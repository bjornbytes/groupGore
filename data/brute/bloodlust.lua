local Bloodlust = {}

----------------
-- Meta
----------------
Bloodlust.name = 'Bloodlust'
Bloodlust.icon = 'media/graphics/icon.png'
Bloodlust.text = 'It is Bloodlust.  My wife for hire.'
Bloodlust.type = 'passive'


----------------
-- Data
----------------
function Bloodlust.activate(self, myBloodlust)
  self.on('kill', function()
    self:addBuff(BloodlustBuff)
  end)
  
  self.on('assist', function()
    self:addBuff(BloddlustAssistBuff)
  end)
end

return Bloodlust