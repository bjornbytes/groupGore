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
Adrenaline.effects = {}
Adrenaline.effects.haste = function(self) return (1 - (self.health / self.maxHealth)) * self.maxSpeed end
Adrenaline.effects.dot = 20

return Adrenaline