local Smokescreen = {}

----------------
-- Meta
----------------
Smokescreen.name = 'Smokescreen'
Smokescreen.code = 'smokescreen'
Smokescreen.text = 'This unit is slowed.'
Smokescreen.icon = 'media/graphics/icon.png'
Smokescreen.hide = false


----------------
-- Data
----------------
function Smokescreen:activate()
  self.amount = self.owner.maxSpeed * .4
  self.owner.maxSpeed = self.owner.maxSpeed - self.amount
end

function Smokescreen:deactivate()
  self.owner.maxSpeed = self.owner.maxSpeed + self.amount
end

return Smokescreen