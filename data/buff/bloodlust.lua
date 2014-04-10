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
end

function Bloodlust:update()
  self.healTimer = self.healTimer - 1
  if self.healTimer <= 0 then
    self.owner:heal({amount = self.heal * self.rate})
    self.healTimer = math.round(Bloodlust.rate / tickRate)
    self.duration = self.duration - self.rate
    if self.duration <= 0 then ovw.buffs:remove(self.owner, 'bloodlust') end
  end
end

return Bloodlust