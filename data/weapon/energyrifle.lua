local EnergyRifle = extend(Weapon)

----------------
-- Meta
----------------
EnergyRifle.name = 'Energy Rifle'
EnergyRifle.code = 'energyrifle'
EnergyRifle.text = 'Bzzt.'
EnergyRifle.type = 'weapon'


----------------
-- Data
----------------
EnergyRifle.image = data.media.graphics.smg
EnergyRifle.scale = 1
EnergyRifle.damage = 20
EnergyRifle.fireTime = .35
EnergyRifle.reloadTime = 1.5
EnergyRifle.switchTime = .3
EnergyRifle.clip = 10
EnergyRifle.ammo = 50
EnergyRifle.recoil = 5
EnergyRifle.anchorx = 15
EnergyRifle.anchory = 7
EnergyRifle.tipx = 14
EnergyRifle.tipy = 0

----------------
-- Crosshair
----------------
function EnergyRifle:crosshair()
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

return EnergyRifle
