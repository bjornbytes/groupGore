local SMG = {}

----------------
-- Meta
----------------
SMG.name = 'SMG'
SMG.code = 'smg'
SMG.icon = 'media/graphics/icon.png'
SMG.text = 'It is a SMG.  It pumps people full of lead.'
SMG.type = 'weapon'


----------------
-- Data
----------------
SMG.damage = 14
SMG.firerate = .15
SMG.reload = 1.6
SMG.clip = 12
SMG.ammo = 240

SMG.activate = function(self, mySMG)
  mySMG.timers = {}
  mySMG.timers.shoot = 0
  mySMG.timers.reload = 0
  
  mySMG.ammo = SMG.ammo
  mySMG.clip = SMG.clip
end

SMG.update = function(self, mySMG)
  mySMG.timers.shoot = timer.rot(mySMG.timers.shoot, f.empty)
  mySMG.timers.reload = timer.rot(mySMG.timers.reload, function()
    local amt = math.min(SMG.clip, mySMG.ammo)
    mySMG.clip = amt
    mySMG.ammo = mySMG.ammo - amt
  end)
  if self.input.slot.reload and mySMG.timers.reload == 0 then mySMG.timers.reload = SMG.reload end
end

SMG.canFire = function(self, mySMG)
  return mySMG.timers.shoot == 0 and mySMG.timers.reload == 0 and mySMG.clip > 0
end

SMG.fire = function(self, mySMG)
  self:spell(data.spell.smg)
  mySMG.timers.shoot = mySMG.firerate
  mySMG.clip = mySMG.clip - 1
  if mySMG.clip == 0 then mySMG.timers.reload = SMG.reload end
end

return SMG