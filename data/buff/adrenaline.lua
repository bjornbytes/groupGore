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
Adrenaline.rate = .5

function Adrenaline:activate()
  self.amount = self.owner.maxSpeed * .6
  self.owner.maxSpeed = self.owner.maxSpeed + self.amount
  self.hurtTimer = 0
end

function Adrenaline:deactivate()
  self.owner.maxSpeed = self.owner.maxSpeed - self.amount
end

function Adrenaline:update()
  self.hurtTimer = self.hurtTimer - 1
  if self.hurtTimer <= 0 then
    ovw.net:emit(evtDamage, {id = self.owner.id, amount = Adrenaline.drain * Adrenaline.rate, from = self.owner.id, tick = tick})
    self.hurtTimer = math.round(Adrenaline.rate / tickRate)
  end
end

function Adrenaline:draw()
  -- purdy
end

return Adrenaline