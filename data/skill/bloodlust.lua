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
Bloodlust.on = {}
Bloodlust.on['kill'] = function(self)
	Buff:add(self, data.buff.bloodlust)
end

return Bloodlust
