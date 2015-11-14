Weapon = class()

function Weapon:activate(owner)
  self.timers = {}
  self.timers.shoot = 0
  self.timers.reload = 0
  self.timers.switch = 0

  self.currentAmmo = self.ammo
  self.currentClip = self.clip
end

function Weapon:update(owner)
  self.timers.shoot = timer.rot(self.timers.shoot)
  self.timers.reload = timer.rot(self.timers.reload, function()
    local amt = math.min(self.clip - self.currentClip, self.currentAmmo)
    self.currentClip = self.currentClip + amt
    self.currentAmmo = self.currentAmmo - amt
    ctx.event:emit('sound.play', {sound = 'reload', x = owner.x, y = owner.y})
  end)
  self.timers.switch = timer.rot(self.timers.switch)
end

function Weapon:draw(owner)
  local dir = owner.drawAngle
  local x, y, s = owner.drawX, owner.drawY, owner.drawScale
  local dx = owner.class.handx * owner.class.scale * s - owner.recoil
  local dy = owner.class.handy * owner.class.scale * s
  x = x + math.dx(dx, dir) - math.dy(dy, dir)
  y = y + math.dy(dx, dir) + math.dx(dy, dir)
  love.graphics.draw(self.image, x, y, dir, self.scale * s, self.scale * s, self.anchorx, self.anchory)
end

function Weapon:select(owner)
  self.timers.switch = self.switchTime
  ctx.event:emit('sound.play', {sound = 'switch', x = owner.x, y = owner.y})
end

function Weapon:canFire(owner)
  return self.timers.switch == 0 and self.timers.shoot == 0 and self.timers.reload == 0 and self.currentClip > 0
end

function Weapon:fire(owner)
  ctx.spells:activate(owner.id, data.spell[self.code])

  self.timers.shoot = self.fireTime
  self.currentClip = self.currentClip - 1
  if self.currentClip == 0 then self.timers.reload = self.reloadTime end
  owner.recoil = self.recoil
end

function Weapon:reload(owner)
  if self.currentClip < self.clip and self.timers.reload == 0 then
    self.timers.reload = self.reloadTime
  end
end

function Weapon:refillAmmo(owner)
  self.currentAmmo = math.min(self.currentAmmo + math.ceil(self.ammo / 4), self.ammo)
end

function Weapon:value(owner)
  if self.timers.switch > 0 then return self.timers.switch / self.switchTime
  elseif self.timers.reload > 0 then return self.timers.reload / self.reloadTime
  else return 0 end
end

function Weapon:ammoValue(owner)
  return self.currentClip, self.currentAmmo
end
