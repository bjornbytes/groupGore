Weapon = class()

Weapon.activate = function(owner, self)
  self.timers = {}
  self.timers.shoot = 0
  self.timers.reload = 0
  
  self.currentAmmo = self.ammo
  self.currentClip = self.clip
end

Weapon.update = function(owner, self)
  self.timers.shoot = timer.rot(self.timers.shoot)
  self.timers.reload = timer.rot(self.timers.reload, function()
    local amt = math.min(self.clip - self.currentClip, self.currentAmmo)
    self.currentClip = self.currentClip + amt
    self.currentAmmo = self.currentAmmo - amt
    ctx.event:emit('sound.play', {sound = 'reload'})
  end)

  if owner.input.reload and self.currentClip < self.clip and self.timers.reload == 0 then
    self.timers.reload = self.reload
  end
end

Weapon.canFire = function(owner, self)
  return self.timers.shoot == 0 and self.timers.reload == 0 and self.currentClip > 0
end

Weapon.fire = function(owner, self)
  ctx.spells:activate(owner.id, data.spell[self.code])
  
  self.timers.shoot = self.firerate
  self.currentClip = self.currentClip - 1
  if self.currentClip == 0 then self.timers.reload = self.reload end
  owner.recoil = self.recoil
end

Weapon.draw = function(owner, self)
  local dir = owner.angle
  local dx = owner.class.handx - owner.recoil
  local dy = owner.class.handy
  local x = owner.x + math.dx(dx, dir) - math.dy(dy, dir)
  local y = owner.y + math.dy(dx, dir) + math.dx(dy, dir)
  love.graphics.draw(self.image, x, y, dir, 1, 1, self.anchorx, self.anchory)
end

Weapon.value = function(owner, self)
  return self.timers.reload > 0 and (self.timers.reload / self.reload) or 0
end
