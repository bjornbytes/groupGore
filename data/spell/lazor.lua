local Lazor = {}
Lazor.code = 'lazor'

Lazor.maxCharge = 1.2
Lazor.turnSpeed = .21
Lazor.width = 28

function Lazor:activate()
  self.charge = 0
  self.owner.haste = self.owner.haste - (self.owner.class.speed * .5)
  self.angle = self.owner.angle
  self.x, self.y = self.owner.x, self.owner.y
end

function Lazor:deactivate()
  self.owner.haste = self.owner.haste + (self.owner.class.speed * .5)
end

function Lazor:update()
  self.x, self.y = self.owner.x, self.owner.y
  local diff = math.anglediff(self.angle, self.owner.angle)
  self.angle = self.angle + math.min(math.abs(diff), self.turnSpeed * tickRate) * math.sign(diff)
  self.owner.angle = self.angle
  self.charge = self.charge + tickRate
  if self.charge >= self.maxCharge then
    local hit = {}
    local wall, dis = ctx.collision:lineTest(self.x, self.y, self.x + math.dx(2000, self.angle), self.y + math.dy(2000, self.angle), {tag = 'wall', first = true})
    dis = wall and dis or 2000
    for i = 1, 3 do
      local offset = -self.width / 2 + (self.width / 2) * (i - 1)
      local ox, oy = self.x + math.dx(offset, self.angle + math.pi / 2), self.y + math.dy(offset, self.angle + math.pi / 2)
      local x2, y2 = ox + math.dx(dis, self.angle), oy + math.dy(dis, self.angle)
      local targets = ctx.collision:lineTest(ox, oy, x2, y2, {tag = 'player', fn = function(p) return p.team ~= self.owner.team and not hit[p.id] end, all = true})
      table.each(targets, function(p)
        hit[p.id] = true
        local buff = ctx.buffs:get(p, 'plasmasickness')
        local damage = 70 + 50 * (buff and buff.stacks or 0)
        ctx.net:emit(evtDamage, {id = p.id, from = self.owner.id, amount = damage, tick = tick})
        ctx.buffs:remove(p, 'plasmasickness')
      end)
    end
    ctx.spells:deactivate(self)
  end
end

function Lazor:draw()
  love.graphics.setColor(255, 0, 0)
  love.graphics.setLineWidth(self.width * (self.charge / self.maxCharge))
  local wall, dis = ctx.collision:lineTest(self.x, self.y, self.x + math.dx(2000, self.angle), self.y + math.dy(2000, self.angle), {tag = 'wall', first = true})
  dis = wall and dis or 2000
  love.graphics.line(self.x, self.y, self.x + math.dx(dis, self.angle), self.y + math.dy(dis, self.angle))
  love.graphics.setLineWidth(1)
end

return Lazor
