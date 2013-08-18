local Adrenaline = {}

----------------
-- Meta
----------------
Adrenaline.name = 'Adrenaline'
Adrenaline.code = 'adrenaline'
Adrenaline.text = 'Increases movespeed, drains health.'
Adrenaline.icon = 'media/graphics/icon.png'
Adrenaline.hide = false


----------------
-- Data
----------------
Adrenaline.drain = 20

Adrenaline.effects = {}
Adrenaline.effects.haste = .7


----------------
-- Behavior
----------------
Adrenaline.update = function(self, myAdrenaline)
	self:emit('hurt', {
		from = self.id,
		amount = Adrenaline.drain * tickRate
	})
end

return Adrenaline