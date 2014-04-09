local Shotgun = {}

----------------
-- Meta
----------------
Shotgun.name = 'Shotgun'
Shotgun.code = 'shotgun'
Shotgun.text = 'It is a shotgun.  It blows people to bits.'
Shotgun.type = 'weapon'


----------------
-- Data
----------------
Shotgun.image = 'media/graphics/shotgun.png'
Shotgun.damage = 25
Shotgun.firerate = .65
Shotgun.reload = 2
Shotgun.clip = 4
Shotgun.ammo = 16
Shotgun.spread = .06
Shotgun.recoil = 6
Shotgun.count = 4
Shotgun.anchorx = 14
Shotgun.anchory = 4
Shotgun.tipx = 29
Shotgun.tipy = 0


----------------
-- Behavior
----------------
Shotgun.activate = function(self, shotgun)
  shotgun.timers = {}
  shotgun.timers.shoot = 0
  shotgun.timers.reload = 0
  
  shotgun.ammo = Shotgun.ammo
  shotgun.clip = Shotgun.clip
end

Shotgun.update = function(self, shotgun)
  shotgun.timers.shoot = timer.rot(shotgun.timers.shoot)
  shotgun.timers.reload = timer.rot(shotgun.timers.reload, function()
    local amt = math.min(Shotgun.clip, shotgun.ammo)
    shotgun.clip = amt
    shotgun.ammo = shotgun.ammo - amt
    if ovw.sound then ovw.sound:play('reload') end
  end)
  if self.input.reload and shotgun.clip < Shotgun.clip and shotgun.timers.reload == 0 then shotgun.timers.reload = Shotgun.reload end
end

Shotgun.canFire = function(self, shotgun)
  return shotgun.timers.shoot == 0 and shotgun.timers.reload == 0 and shotgun.clip > 0
end

Shotgun.fire = function(self, shotgun)
  ovw.spells:activate(self.id, data.spell.shotgun)
  
  shotgun.timers.shoot = shotgun.firerate
  shotgun.clip = shotgun.clip - 1
  if shotgun.clip == 0 then shotgun.timers.reload = Shotgun.reload end
  self.recoil = shotgun.recoil
end

Shotgun.draw = function(self, shotgun)
  local dir = self.angle
  local dx = self.class.handx - self.recoil
  local dy = self.class.handy
  love.graphics.draw(shotgun.image, self.x + math.dx(dx, dir) - math.dy(dy, dir), self.y + math.dy(dx, dir) + math.dx(dy, dir), dir, 1, 1, shotgun.anchorx, shotgun.anchory)
end

Shotgun.value = function(self, shotgun)
  return shotgun.timers.reload > 0 and (shotgun.timers.reload / Shotgun.reload) or 0
end

return Shotgun
