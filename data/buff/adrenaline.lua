local Adrenaline = {}

Adrenaline.name = 'Adrenaline'
Adrenaline.code = 'adrenaline'
Adrenaline.text = 'Increases movespeed, drains health.'
Adrenaline.icon = 'media/graphics/icon.png'
Adrenaline.hide = false

Adrenaline.effects = {}
Adrenaline.effects.haste = .4

Adrenaline.update = function(self, myAdrenaline)
	if self.hp > 15 * tickRate then
		self.hp = self.hp - (15 * tickRate)
	end
end

return Adrenaline