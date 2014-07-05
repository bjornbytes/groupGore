local Dagger = {}

Dagger.name = 'Dagger'
Dagger.code = 'dagger'
Dagger.text = 'Stabby'
Dagger.type = 'weapon'

Dagger.damage = 45
Dagger.cooldown = .8

function Dagger:activate(owner)
  self.timer = 0
  self.visions = {}
end

function Dagger:update(owner)
  self.timer = timer.rot(self.timer)
  ctx.players:each(function(p)
    if p.id ~= owner.id then
      self.visions[p.id] = self.visions[p.id] or 0
      if math.abs(math.anglediff(p.angle, math.direction(p.x, p.y, owner.x, owner.y))) > math.pi / 2 or owner.cloak > 0 or ctx.collision:lineTest(p.x, p.y, owner.x, owner.y, {tag = 'wall'}) then
        self.visions[p.id] = math.min(self.visions[p.id] + tickRate, 3)
      else
        self.visions[p.id] = math.max(self.visions[p.id] - tickRate, 0)
      end
    end
  end)
end

function Dagger:canFire(owner)
  return self.timer == 0
end

function Dagger:fire(owner)
  ctx.spells:activate(owner.id, data.spell.dagger, self.visions)
  self.timer = self.cooldown
end

function Dagger:draw(owner)
  if owner.id == ctx.id then
    local r, g, b, a = love.graphics.getColor()
    for i, v in pairs(self.visions) do
      local p = ctx.players:get(i)
      if p and not p.ded and p.team ~= owner.team and v == 3 then
        local alpha = p.alpha * (1 - (p.cloak / (p.team == ctx.players:get(ctx.id).team and 2 or 1)))
        love.graphics.setColor(150, 0, 0, 255 * alpha)
        love.graphics.setLineWidth(3)
        love.graphics.line(p.x - 10, p.y - 90, p.x + 10, p.y - 70)
        love.graphics.line(p.x - 10, p.y - 70, p.x + 10, p.y - 90)
        love.graphics.setLineWidth(1)
      end
    end
    love.graphics.setColor(r, g, b, a)
  end
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
