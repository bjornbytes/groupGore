local Bloodlust = {}

----------------
-- Meta
----------------
Bloodlust.name = 'Bloodlust'
Bloodlust.code = 'bloodlust'
Bloodlust.text = 'This Brute is gaining health because he killed someone.'
Bloodlust.icon = 'media/graphics/icon.png'
Bloodlust.hide = false


----------------
-- Data
----------------
Bloodlust.heal = 15
Bloodlust.rate = .25
Bloodlust.duration = 6

function Bloodlust:activate()
  self.timer = Bloodlust.duration
  self.healTimer = 0
  self.depth = 4
  if ovw.view then ovw.view:register(self) end
end

function Bloodlust:deactivate()
  if ovw.view then ovw.view:unregister(self) end
end

function Bloodlust:update()
  self.healTimer = self.healTimer - 1
  if self.healTimer <= 0 then
    self.owner:heal({amount = self.heal * self.rate})
    self.healTimer = math.round(Bloodlust.rate / tickRate)
    self.timer = self.timer - self.rate
    if self.timer <= 0 then ovw.buffs:remove(self.owner, 'bloodlust') end
  end
end

function Bloodlust:draw()
  love.graphics.setColor(128, 0, 0, 128)
  local x, y = self.owner:drawPosition()
  love.graphics.circle('fill', x, y, self.owner.radius * (1 + math.sin((self.timer + self.healTimer) * 50) / 4))
end

function Bloodlust:stack()
  self.timer = self.duration
end

return Bloodlust