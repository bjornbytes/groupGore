local RocketBootsStun = {}

----------------
-- Meta
----------------
RocketBootsStun.name = 'Rocket Boots Stun'
RocketBootsStun.code = 'rocketbootsstun'
RocketBootsStun.text = 'This unit is stunned from rocket boots.'
RocketBootsStun.hide = false


----------------
-- Data
----------------
RocketBootsStun.duration = 1

function RocketBootsStun:activate()
  self.owner.stun = math.max(self.owner.stun, 1)
  self.timer = self.duration
end

function RocketBootsStun:update()
  self.timer = timer.rot(self.timer, function()
    ctx.buffs:remove(self.owner, 'rocketbootsstun')
  end)
end

return RocketBootsStun
