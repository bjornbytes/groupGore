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
function Adrenaline:activate()
  self.increase = self.owner.maxSpeed * .6
  self.owner.maxSpeed = self.owner.maxSpeed + self.increase
end

function Adrenaline:deactivate()
  self.owner.maxSpeed = self.owner.maxSpeed - self.increase
end

function Adrenaline:update()
  ovw.net:emit(evtDamage, {id = self.owner.id, amount = 20 * tickRate, from = self.owner.id, tick = tick})
end

function Adrenaline:draw()
  -- purdy
end

return Adrenaline