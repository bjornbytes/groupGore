local Bloodlust = {}

----------------
-- Meta
----------------
Bloodlust.name = 'Bloodlust'
Bloodlust.code = 'bloodlust'
Bloodlust.text = 'This Brute is gaining health because he killed someone.'
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
  if ctx.view then ctx.view:register(self) end
end

function Bloodlust:deactivate()
  if ctx.view then ctx.view:unregister(self) end
end

function Bloodlust:update()
  self.healTimer = self.healTimer - 1
  if self.healTimer <= 0 then
    self.owner:heal({amount = self.heal * self.rate})
    self.healTimer = math.round(Bloodlust.rate / tickRate)
    self.timer = self.timer - self.rate
    if self.timer <= 0 then ctx.buffs:remove(self.owner, self.code) end
  end
end

function Bloodlust:draw()
  love.graphics.setColor(128, 0, 0, 128)
  local x, y, s = self.owner.drawX, self.owner.drawY, self.owner.drawScale
  love.graphics.circle('fill', x, y, self.owner.radius * s * (1 + math.sin((self.timer + self.healTimer) * 50) / 4))
end

function Bloodlust:stack()
  self.timer = self.duration
end

return Bloodlust
