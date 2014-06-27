local Dagger = {}

Dagger.name = 'Dagger'
Dagger.code = 'dagger'
Dagger.text = 'Stabby'
Dagger.type = 'weapon'

Dagger.damage = 45
Dagger.cooldown = .8

function Dagger:activate(owner)
  self.timer = 0
end

function Dagger:update(owner)
  self.timer = timer.rot(self.timer)
end

function Dagger:canFire(owner)
  return self.timer == 0
end

function Dagger:fire(owner)
  ctx.spells:activate(owner.id, data.spell.dagger)
  self.timer = self.cooldown
end

Dagger.reload = f.empty

function Dagger:crosshair()
  local g, p, d, x, y = love.graphics, ctx.players:get(ctx.id), data.spell.dagger, ctx.view:frameMouseX(), ctx.view:frameMouseY()
  local v = ctx.view
  local t = (self.timer / self.cooldown)
  local o = (t ^ 2 * ((1 + 1.6) * t - 1.6)) * (d.radius + 10)

  if math.distance(x, y, (p.x - v.x) * v.scale, (p.y - v.y) * v.scale) < d.distance * v.scale then
    x, y = p.x + math.dx(d.distance, p.angle) - v.x, p.y + math.dy(d.distance, p.angle) - v.y
    x, y = x * v.scale, y * v.scale
  end

  g.setColor(255, 255, 255, 255 * (1 - p.cloak / 2))
  g.setLineWidth(2 + p.cloak)
  for i = 1, 4 do
    local ang = p.angle - math.pi / 4 + (i * math.pi / 2)
    local x1, y1 = x + math.dx(d.radius - 4 - o, ang), y + math.dy(d.radius - 4 - o, ang)
    local x2, y2 = x + math.dx(d.radius + 4 - o, ang), y + math.dy(d.radius + 4 - o, ang)
    g.line(x1, y1, x2, y2)
  end
  g.setLineWidth(1)
end

return Dagger
