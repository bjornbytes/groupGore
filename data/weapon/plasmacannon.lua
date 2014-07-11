local PlasmaCannon = {}

----------------
-- Meta
----------------
PlasmaCannon.name = 'Plasma Cannon'
PlasmaCannon.code = 'plasmacannon'
PlasmaCannon.text = 'Bwom.'
PlasmaCannon.type = 'weapon'


----------------
-- Data
----------------
PlasmaCannon.image = data.media.graphics.smg
PlasmaCannon.scale = 1
PlasmaCannon.targeted = true
PlasmaCannon.maxCharge = 1.5
PlasmaCannon.minDamage = 10
PlasmaCannon.maxDamage = 65
PlasmaCannon.fireTime = 1
PlasmaCannon.switchTime = .5
PlasmaCannon.ammo = 10
PlasmaCannon.recoil = 7
PlasmaCannon.anchorx = 15
PlasmaCannon.anchory = 7
PlasmaCannon.tipx = 14
PlasmaCannon.tipy = 0


----------------
-- Behavior
----------------

function PlasmaCannon:init()
  self.timers = {}
  self.timers.fire = 0
  self.timers.switch = 0

  self.currentAmmo = self.ammo

  self.charge = 0
end

function PlasmaCannon:update()
  self.timers.fire = timer.rot(self.timers.fire)
  self.timers.switch = timer.rot(self.timers.switch)

  if self.targeting then self.charge = math.min(self.charge + tickRate, self.maxCharge) end
end

function PlasmaCannon:draw()
  Weapon.draw(self)
end

function PlasmaCannon:select()
  Weapon.switch(self)
  self.charge = 0
end

function PlasmaCannon:canFire()
  return self.timers.fire == 0 and self.timers.switch == 0 and self.currentAmmo > 0
end

function PlasmaCannon:fire(owner)
  ctx.spells:activate(owner.id, data.spell.plasmacannon, self.charge)
  
  self.timers.shoot = self.fireTime
  self.currentAmmo = self.currentAmmo - 1
  self.charge = 0
  owner.recoil = self.recoil
end

function PlasmaCannon:refillAmmo(owner)
  self.currentAmmo = math.min(self.currentAmmo + math.ceil(self.ammo / 4), self.ammo)
end

function PlasmaCannon:value(owner)
  if self.timers.switch > 0 then return self.timers.switch / self.switchTime
  elseif self.timers.fire > 0 then return self.timers.fire / self.fireTime
  else return 0 end
end

function PlasmaCannon:ammoValue(owner)
  return self.currentAmmo
end


----------------
-- Crosshair
----------------
function PlasmaCannon:crosshair()
  local g, p, x, y = love.graphics, ctx.players:get(ctx.id), ctx.view:frameMouseX(), ctx.view:frameMouseY()
  local vx, vy, s = ctx.view:worldMouseX(), ctx.view:worldMouseY(), ctx.view.scale
  local d = math.distance(p.x, p.y, vx, vy)
  local len = 8 * s
  
  local dir = p.angle
  local dx, dy = p.class.handx * p.class.scale * s, p.class.handy * p.class.scale * s
  x = x + math.dx(dx, dir) - math.dy(dy, dir)
  y = y + math.dy(dx, dir) + math.dx(dy, dir)
  
  dx, dy = self.tipx * self.scale * s, self.tipy * self.scale * s
  x = x + math.dx(dx, dir) - math.dy(dy, dir)
  y = y + math.dy(dx, dir) + math.dx(dy, dir)

  local d2 = (math.distance(0, 0, p.class.handx, p.class.handy) * p.class.scale) + (math.distance(0, 0, self.tipx, self.tipy) * self.scale)
  x = x - math.dx(math.min(d2, d) * s, dir)
  y = y - math.dy(math.min(d2, d) * s, dir)

  local alpha = self.timers.switch > 0 and 128 or 255
  local factor = (1 - (math.clamp(tick - p.lastDamageDealt, 0, .4 / tickRate) / (.4 / tickRate))) ^ 2
  g.setColor(table.interpolate({255, 255, 255, alpha}, {255, 0, 0, alpha}, factor))
  g.line(x, y - len, x, y + len)
  g.line(x - len, y, x + len, y)
  g.line(x - len, y, x + len, y)
  g.line(x, y - len, x, y + len)
end

return PlasmaCannon
