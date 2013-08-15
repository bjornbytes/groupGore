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
function Bloodlust.activate(self, myBloodlust)
	self:on(Players.event.kill, function()
		Buff:add(self, data.buff.bloodlust)
	end)
end

return Bloodlust