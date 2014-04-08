local Rage = {}

----------------
-- Meta
----------------
Rage.name = 'Rage'
Rage.code = 'rage'
Rage.text = 'The brute has 20% additional lifesteal.'
Rage.icon = 'media/graphics/icon.png'
Rage.hide = false


----------------
-- Data
----------------
function Rage:activate()
  self.owner.lifesteal = self.owner.lifesteal + .2
end

function Rage:deactivate()
  self.owner.lifesteal = self.owner.lifesteal - .2
end

return Rage