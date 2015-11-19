local Adrenaline = {}

----------------
-- Meta
----------------
Adrenaline.name = 'Adrenaline'
Adrenaline.code = 'adrenaline'
Adrenaline.text = 'Increases movespeed, drains health.'
Adrenaline.hide = false


----------------
-- Data
----------------
Adrenaline.drain = 20
Adrenaline.rate = .5

function Adrenaline:activate()
  self.amount = self.owner.class.speed * .6
  self.owner.haste = self.owner.haste + self.amount
  self.hurtTimer = 0
end

function Adrenaline:deactivate()
  self.owner.haste = self.owner.haste - self.amount
end

function Adrenaline:update()
  self.hurtTimer = self.hurtTimer - 1
  if self.hurtTimer <= 0 then
    local amt = math.min(Adrenaline.drain * Adrenaline.rate, self.owner.health - 1)
    ctx.net:emit(app.core.net.events.damage, {id = self.owner.id, amount = amt, from = self.owner.id, tick = tick})
    self.hurtTimer = math.round(Adrenaline.rate / tickRate)
    for _ = 1, 8 do
      ctx.event:emit('particle.create', {
        kind = 'blood',
        vars = {
          x = self.owner.x - 25 + love.math.random(50),
          y = self.owner.y - 25 + love.math.random(50)
        }
      })
    end
  end
end

return Adrenaline
