local Shotgun = extend(Weapon)

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
Shotgun.spread = math.rad(12)
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
  local g, p, x, y = love.graphics, ctx.players:get(ctx.id), love.mouse.getPosition()
  local vx, vy = ctx.view:mouseX(), ctx.view:mouseY()
  local d = math.distance(p.x, p.y, vx, vy)
  local alpha = 50 + ((300 - math.clamp(d - 200, 0, 300)) / 300) * 205
  
  local dir = p.angle
  local dx, dy = p.class.handx * p.class.scale, p.class.handy * p.class.scale
  x = x + math.dx(dx, dir) - math.dy(dy, dir)
  y = y + math.dy(dx, dir) + math.dx(dy, dir)
  
  dx, dy = self.tipx * self.scale, self.tipy * self.scale
  x = x + math.dx(dx, dir) - math.dy(dy, dir)
  y = y + math.dy(dx, dir) + math.dx(dy, dir)
  
  g.setColor(255, 255, 255, alpha)
  g.circle('line', x, y, math.abs(math.atan(self.spread / 2)) * math.distance(p.x, p.y, vx, vy))
end

return Shotgun
