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
SMG.damage = 14
SMG.fireTime = .15
SMG.reloadTime = 1.6
SMG.switchTime = .5
SMG.clip = 12
SMG.ammo = 120
SMG.spread = .03
SMG.recoil = 3
SMG.anchorx = 15
SMG.anchory = 7
SMG.tipx = 14
SMG.tipy = 0

----------------
-- Crosshair
----------------
function SMG:crosshair()
  local g, p, x, y = love.graphics, ctx.players:get(ctx.id), love.mouse.getPosition()
  local vx, vy = ctx.view:mouseX(), ctx.view:mouseY()
  local d = math.distance(p.x, p.y, vx, vy)
  
  local dir = p.angle
  local dx, dy = p.class.handx, p.class.handy
  x = x + math.dx(dx, dir) - math.dy(dy, dir)
  y = y + math.dy(dx, dir) + math.dx(dy, dir)
  
  dx, dy = self.tipx, self.tipy
  x = x + math.dx(dx, dir) - math.dy(dy, dir)
  y = y + math.dy(dx, dir) + math.dx(dy, dir)

  g.setColor(255, 255, 255)
  g.circle('line', x, y, math.abs(math.atan(self.spread)) * math.distance(p.x, p.y, vx, vy))
end

return SMG
