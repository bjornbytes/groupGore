local SMG = extend(Weapon)

----------------
-- Meta
----------------
SMG.name = 'SMG'
SMG.code = 'smg'
SMG.text = 'It is a SMG.  It pumps people full of lead.'
SMG.type = 'weapon'


----------------
-- Data
----------------
SMG.image = data.media.graphics.smg
SMG.scale = 1
SMG.damage = 14
SMG.fireTime = .15
SMG.reloadTime = 1.6
SMG.switchTime = .5
SMG.clip = 12
SMG.ammo = 120
SMG.spread = .04
SMG.recoil = 3
SMG.anchorx = 15
SMG.anchory = 7
SMG.tipx = 14
SMG.tipy = 0

----------------
-- Crosshair
----------------
function SMG:crosshair()
  local g, p, x, y = love.graphics, ctx.players:get(ctx.id), ctx.view:frameMouseX(), ctx.view:frameMouseY()
  local vx, vy, s = ctx.view:worldMouseX(), ctx.view:worldMouseY(), ctx.view.scale
  local d = math.distance(p.x, p.y, vx, vy)
  local len = 4 * s
  
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

  local r = math.abs(math.atan(self.spread)) * math.max(math.distance(p.x, p.y, vx, vy) - d2, 0) * s

  g.setColor(255, 255, 255)
  g.circle('line', x, y, r )
  g.line(x, y - r - len, x, y - r + len)
  g.line(x - r - len, y, x - r + len, y)
  g.line(x + r - len, y, x + r + len, y)
  g.line(x, y + r - len, x, y + r + len)
end

return SMG
