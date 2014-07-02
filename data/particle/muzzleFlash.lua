local MuzzleFlash = {}

MuzzleFlash.name = 'MuzzleFlash'
MuzzleFlash.code = 'muzzleFlash'

MuzzleFlash.activate = function(self)
  self.maxHealth = .2
  self.health = self.maxHealth
  self.scale = 2.5
  self.alpha = 1
  self.image = data.media.graphics.effects.muzzleFlash1
end

MuzzleFlash.update = function(self)
  self.health = self.health - tickRate
  if self.health <= 0 then return true
  elseif self.health < (self.maxHealth * .33) then
    self.image = data.media.graphics.effects.muzzleFlash2
  elseif self.health < (self.maxHealth * .67) then
    self.image = data.media.graphics.effects.muzzleFlash3
  end

  self.alpha = self.alpha - (1 / self.maxHealth) * tickRate
  self.scale = math.lerp(self.scale, 0.5, 5 * tickRate)

  local owner = ctx.players:get(self.owner)
  local weapon = data.weapon[self.weapon]
  local dir = owner.angle
  self.angle = dir
  
  local dx, dy = owner.class.handx * owner.class.scale, owner.class.handy * owner.class.scale
  self.x = owner.x + math.dx(dx, dir) - math.dy(dy, dir)
  self.y = owner.y + math.dy(dx, dir) + math.dx(dy, dir)
  
  dx, dy = weapon.tipx * weapon.scale, weapon.tipy * weapon.scale
  self.x = self.x + math.dx(dx, dir) - math.dy(dy, dir)
  self.y = self.y + math.dy(dx, dir) + math.dx(dy, dir)
end

MuzzleFlash.draw = function(self)
  love.graphics.setColor(255, 255, 255, self.alpha * 255)
  love.graphics.draw(self.image, self.x, self.y, self.angle, self.scale, self.scale, 0, self.image:getHeight() / 2)
end

return MuzzleFlash
