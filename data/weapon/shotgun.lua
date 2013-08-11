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
Shotgun.firerate = .65
Shotgun.reload = 2
Shotgun.clip = 4
Shotgun.ammo = 16

Shotgun.activate = function(self, myShotgun)
  myShotgun.timers = {}
  myShotgun.timers.shoot = 0
  myShotgun.timers.reload = 0
  
  myShotgun.ammo = Shotgun.ammo
  myShotgun.clip = Shotgun.clip
end

Shotgun.update = function(self, myShotgun)
  myShotgun.timers.shoot = timer.rot(myShotgun.timers.shoot, f.empty)
  myShotgun.timers.reload = timer.rot(myShotgun.timers.reload, function()
    local amt = math.min(Shotgun.clip, myShotgun.ammo)
    myShotgun.clip = amt
    myShotgun.ammo = myShotgun.ammo - amt
  end)
end

Shotgun.canFire = function(self, myShotgun)
  return myShotgun.timers.shoot == 0 and myShotgun.timers.reload == 0 and myShotgun.clip > 0
end

Shotgun.fire = function(self, myShotgun)
  self:spell(data.spell.shotgun)
  
  myShotgun.timers.shoot = myShotgun.firerate
  myShotgun.clip = myShotgun.clip - 1
  if myShotgun.clip == 0 then myShotgun.timers.reload = Shotgun.reload end
end

return Shotgun