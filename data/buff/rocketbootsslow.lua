local RocketBootsSlow = {}

----------------
-- Meta
----------------
RocketBootsSlow.name = 'Rocket Boots Slow'
RocketBootsSlow.code = 'rocketbootsslow'
RocketBootsSlow.text = 'This unit is slowed from rocket boots.'
RocketBootsSlow.hide = false


----------------
-- Data
----------------
RocketBootsSlow.duration = 1.5

function RocketBootsSlow:activate()
  self.owner.haste = self.owner.haste + (self.owner.class.speed * -.6)
  self.timer = self.duration
end

function RocketBootsSlow:deactivate()
  self.owner.haste = self.owner.haste + (self.owner.class.speed * .6)
end

function RocketBootsSlow:update()
  self.timer = timer.rot(self.timer, function()
    ctx.buffs:remove(self.owner, 'rocketbootsslow')
  end)
end

return RocketBootsSlow
