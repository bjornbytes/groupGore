local BattleAxe = {}

BattleAxe.name = 'BattleAxe'
BattleAxe.code = 'battleaxe'
BattleAxe.text = 'Rawr!'
BattleAxe.type = 'weapon'

BattleAxe.damage = 45
BattleAxe.cooldown = 1.1

function BattleAxe:activate(owner)
  self.timer = 0
end

function BattleAxe:update(owner)
  self.timer = timer.rot(self.timer)
end

function BattleAxe:canFire(owner)
  return self.timer == 0
end

function BattleAxe:fire(owner)
  ctx.spells:activate(owner.id, data.spell.battleaxe)
  self.timer = self.cooldown
end

BattleAxe.reload = f.empty

function BattleAxe:crosshair()
  local g, p, b, x, y = love.graphics, ctx.players:get(ctx.id), data.spell.battleaxe, ctx.view:frameMouseX(), ctx.view:frameMouseY()
  local v = ctx.view
  local t = (self.timer / self.cooldown)
  local o = (t ^ 2 * ((1 + 1.6) * t - 1.6)) * (b.radius + 10)

  if math.distance(x, y, (p.x - v.x) * v.scale, (p.y - v.y) * v.scale) < b.distance * v.scale then
    x, y = p.x + math.dx(b.distance, p.angle) - v.x, p.y + math.dy(b.distance, p.angle) - v.y
    x, y = x * v.scale, y * v.scale
  end

  g.setColor(255, 255, 255, 255 * (1 - p.cloak / 2))
  g.setLineWidth(2)
  for i = 1, 4 do
    local ang = p.angle - math.pi / 4 + (i * math.pi / 2)
    local x1, y1 = x + math.dx(b.radius / 2 - 4 - o, ang), y + math.dy(b.radius / 2 - 4 - o, ang)
    local x2, y2 = x + math.dx(b.radius / 2 + 4 - o, ang), y + math.dy(b.radius / 2 + 4 - o, ang)
    g.line(x1, y1, x2, y2)
  end
  g.setLineWidth(1)
end

return BattleAxe
