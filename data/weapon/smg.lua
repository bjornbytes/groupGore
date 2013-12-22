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
SMG.image = 'media/graphics/smg.png'
SMG.damage = 14
SMG.firerate = .15
SMG.reload = 1.6
SMG.clip = 12
SMG.ammo = 240
SMG.dx = 10
SMG.dy = 84
SMG.tipx = 4
SMG.tipy = 70


----------------
-- Behavior
----------------
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
  if self.input.reload and mySMG.clip < SMG.clip and mySMG.timers.reload == 0 then mySMG.timers.reload = SMG.reload end
end

SMG.canFire = function(self, mySMG)
  return mySMG.timers.shoot == 0 and mySMG.timers.reload == 0 and mySMG.clip > 0
end

SMG.fire = function(self, mySMG)
  ovw.spells:activate(self.id, data.spell.smg)
  mySMG.timers.shoot = mySMG.firerate
  mySMG.clip = mySMG.clip - 1
  if mySMG.clip == 0 then mySMG.timers.reload = SMG.reload end
end

SMG.draw = function(self, mySMG)
  local dir = self.angle
  local dx = mySMG.dx
  local dy = mySMG.dy
  love.graphics.draw(mySMG.image, self.x + math.dx(dx, dir) - math.dy(dy, dir), self.y + math.dy(dx, dir) + math.dx(dy, dir), dir, 1, 1, mySMG.tipx, mySMG.tipy)
end

return SMG