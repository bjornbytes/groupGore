local StaticGrenade = {}

----------------
-- Meta
----------------
StaticGrenade.name = 'Static Grenade'
StaticGrenade.code = 'staticgrenade'
StaticGrenade.text = 'This unit is slowed and disarmed.'
StaticGrenade.hide = false


----------------
-- Data
----------------
StaticGrenade.disarmDuration = 1.75
StaticGrenade.slowDuration = 1.25

function StaticGrenade:activate()
  local stacks, buff = 0, ctx.buffs:get(self.owner, 'plasmasickness')
  stacks = buff and buff.stacks or 0
  self.owner.disarm = math.max(self.owner.disarm, self.disarmDuration)
  self.slowAmount = self.owner.class.speed * (.2 + (.2 * stacks))
  self.owner.haste = self.owner.haste - self.slowAmount
  self.timer = self.slowDuration
end

function StaticGrenade:deactivate()
  self.owner.haste = self.owner.haste + self.slowAmount
end

function StaticGrenade:update()
  self.timer = timer.rot(self.timer, function()
    ctx.buffs:remove(self.owner, 'staticgrenade')
  end)
end

return StaticGrenade
