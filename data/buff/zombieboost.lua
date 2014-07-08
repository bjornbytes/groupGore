local ZombieBoost = {}

----------------
-- Meta
----------------
ZombieBoost.name = 'ZombieBoost'
ZombieBoost.code = 'zombieboost'
ZombieBoost.text = 'BRAINS!'
ZombieBoost.hide = false


----------------
-- Data
----------------
ZombieBoost.haste = 1.5
ZombieBoost.duration = 4

function ZombieBoost:activate()
  self.amount = self.owner.class.speed * self.haste
  self.decrease = (self.amount / self.duration) * tickRate
  self.owner.haste = self.owner.haste + self.amount
  self.timer = self.duration
end

function ZombieBoost:update()
  self.amount = self.amount - self.decrease
  self.owner.haste = self.owner.haste - self.decrease

  self.timer = timer.rot(self.timer, function()
    self.owner.haste = self.owner.haste - self.amount
    ctx.buffs:remove(self.owner, 'zombieboost')
  end)
end

function ZombieBoost:stack()
  self.owner.haste = self.owner.haste - self.amount
  self:activate()
end

return ZombieBoost
