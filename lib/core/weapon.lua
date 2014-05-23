Weapon = class()

function Weapon:activate(owner)
  self.timers = {}
  self.timers.switch = 0
  self.timers.shoot = 0
  self.timers.reload = 0
  
  self.currentAmmo = self.ammo
  self.currentClip = self.clip
end

function Weapon:update(owner)
  self.timers.shoot = timer.rot(self.timers.shoot)
  self.timers.reload = timer.rot(self.timers.reload, function()
    local amt = math.min(self.clip - self.currentClip, self.currentAmmo)
    self.currentClip = self.currentClip + amt
    self.currentAmmo = self.currentAmmo - amt
    ctx.event:emit('sound.play', {sound = 'reload'})
  end)
end

function Weapon:draw(owner)
  local dir = owner.angle
  local dx = owner.class.handx - owner.recoil
  local dy = owner.class.handy
  local x = owner.x + math.dx(dx, dir) - math.dy(dy, dir)
  local y = owner.y + math.dy(dx, dir) + math.dx(dy, dir)
  love.graphics.draw(self.image, x, y, dir, 1, 1, self.anchorx, self.anchory)
end

function Weapon:select(owner)

end

function Weapon:canFire(owner)
  return self.timers.shoot == 0 and self.timers.reload == 0 and self.currentClip > 0
end

function Weapon:fire(owner)
  ctx.spells:activate(owner.id, data.spell[self.code])
  
  self.timers.shoot = self.fireSpeed
  self.currentClip = self.currentClip - 1
  if self.currentClip == 0 then self.timers.reload = self.reloadSpeed end
  owner.recoil = self.recoil
end

function Weapon:reload(owner)
  if self.currentClip < self.clip and self.timers.reload == 0 then
    self.timers.reload = self.reloadSpeed
  end
end

function Weapon:value(owner)
  return self.timers.reload > 0 and (self.timers.reload / self.reloadSpeed) or 0
end
