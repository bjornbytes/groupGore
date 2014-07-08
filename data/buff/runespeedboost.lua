local RuneSpeedBoost = {}

----------------
-- Meta
----------------
RuneSpeedBoost.name = 'Rune Speed Boost'
RuneSpeedBoost.code = 'runespeedboost'
RuneSpeedBoost.text = 'Increases movespeed.'
RuneSpeedBoost.hide = false


----------------
-- Data
----------------
RuneSpeedBoost.haste = .5
RuneSpeedBoost.duration = 2

function RuneSpeedBoost:activate()
  self.amount = self.owner.class.speed * self.haste
  self.decrease = (self.amount / self.duration) * tickRate
  self.owner.haste = self.owner.haste + self.amount
  self.timer = self.duration
end

function RuneSpeedBoost:update()
  self.amount = self.amount - self.decrease
  self.owner.haste = self.owner.haste - self.decrease

  self.timer = timer.rot(self.timer, function()
    self.owner.haste = self.owner.haste - self.amount
    ctx.buffs:remove(self.owner, 'runespeedboost')
  end)
end

function RuneSpeedBoost:stack()
  self.owner.haste = self.owner.haste - self.amount
  self:activate()
end

return RuneSpeedBoost
