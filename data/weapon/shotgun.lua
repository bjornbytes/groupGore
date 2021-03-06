local Shotgun = extend(app.logic.weapon)

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
Shotgun.image = data.media.graphics.shotgun
Shotgun.scale = .2
Shotgun.damage = 25
Shotgun.fireTime = .65
Shotgun.reloadTime = 2
Shotgun.switchTime = .75
Shotgun.clip = 4
Shotgun.ammo = 16
Shotgun.spread = math.rad(16)
Shotgun.recoil = 6
Shotgun.count = 4
Shotgun.anchorx = 191
Shotgun.anchory = 40
Shotgun.tipx = 246
Shotgun.tipy = -10

----------------
-- Crosshair
----------------
function Shotgun:crosshair()
  local g, p, x, y = love.graphics, ctx.players:get(ctx.id), ctx.view:frameMouseX(), ctx.view:frameMouseY()
  local vx, vy, s = ctx.view:worldMouseX(), ctx.view:worldMouseY(), ctx.view.scale
  local d = math.distance(p.x, p.y, vx, vy)
  local alpha = 50 + ((300 - math.clamp(d - 200, 0, 300)) / 300) * 205
  if self.timers.switch > 0 then alpha = alpha / 2 end

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

  local factor = (1 - (math.clamp(tick - p.lastDamageDealt, 0, .4 / tickRate) / (.4 / tickRate))) ^ 2
  g.setColor(table.interpolate({255, 255, 255, alpha}, {255, 0, 0, alpha}, factor))
  local radius = math.abs(math.atan(self.spread / 2)) * math.max(math.distance(p.x, p.y, vx, vy) - d2, 0) * s
  g.circle('line', x, y, radius)
end

return Shotgun
