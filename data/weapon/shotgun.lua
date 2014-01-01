local Shotgun = {}

----------------
-- Meta
----------------
Shotgun.name = 'Shotgun'
Shotgun.code = 'shotgun'
Shotgun.icon = 'media/graphics/icon.png'
Shotgun.text = 'It is a shotgun.  It blows people to bits.'
Shotgun.type = 'weapon'


----------------
-- Data
----------------
Shotgun.image = 'media/graphics/shotgun.png'
Shotgun.damage = 20
Shotgun.firerate = .65
Shotgun.reload = 2
Shotgun.clip = 4
Shotgun.ammo = 16
Shotgun.spread = .06
Shotgun.count = 4
Shotgun.dx = 8
Shotgun.dy = 92
Shotgun.tipx = 4
Shotgun.tipy = 77


----------------
-- Behavior
----------------
Shotgun.activate = function(self, myShotgun)
  myShotgun.timers = {}
  myShotgun.timers.shoot = 0
  myShotgun.timers.reload = 0
  
  myShotgun.ammo = Shotgun.ammo
  myShotgun.clip = Shotgun.clip
end

Shotgun.update = function(self, myShotgun)
  myShotgun.timers.shoot = timer.rot(myShotgun.timers.shoot)
  myShotgun.timers.reload = timer.rot(myShotgun.timers.reload, function()
    local amt = math.min(Shotgun.clip, myShotgun.ammo)
    myShotgun.clip = amt
    myShotgun.ammo = myShotgun.ammo - amt
  end)
  if self.input.reload and myShotgun.clip < Shotgun.clip and myShotgun.timers.reload == 0 then myShotgun.timers.reload = Shotgun.reload end
end

Shotgun.canFire = function(self, myShotgun)
  return myShotgun.timers.shoot == 0 and myShotgun.timers.reload == 0 and myShotgun.clip > 0
end

Shotgun.fire = function(self, myShotgun)
  ovw.spells:activate(self.id, data.spell.shotgun)
  
  myShotgun.timers.shoot = myShotgun.firerate
  myShotgun.clip = myShotgun.clip - 1
  if myShotgun.clip == 0 then myShotgun.timers.reload = Shotgun.reload end
end

Shotgun.draw = function(self, myShotgun)
  local dir = self.angle
  local dx = myShotgun.dx
  local dy = myShotgun.dy
  love.graphics.draw(myShotgun.image, self.x + math.dx(dx, dir) - math.dy(dy, dir), self.y + math.dy(dx, dir) + math.dx(dy, dir), dir, 1, 1, myShotgun.tipx, myShotgun.tipy)
end

return Shotgun
