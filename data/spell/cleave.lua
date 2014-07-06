local Cleave = {}

Cleave.code = 'cleave'
Cleave.radius = 175
Cleave.hp = .5

function Cleave:activate()
  self.hp = Cleave.hp
  self.empowered = ctx.buffs:get(self.owner, 'overexertion')
  ctx.buffs:remove(self.owner, 'overexertion')

  self.targets = ctx.collision:circleTest(self.owner.x, self.owner.y, self.radius, {
    tag = 'player',
    fn = function(p) return p.team ~= self.owner.team end,
    all = true
  })

  table.each(self.targets, function(t)
    local damage = data.skill.cleave.damage
    if math.distance(self.owner.x, self.owner.y, t.x, t.y) > Cleave.radius * .65 then damage = damage / 2 end
    if self.empowered then damage = damage * 1.5 end
    ctx.net:emit(evtDamage, {id = t.id, amount = data.skill.cleave.damage, from = self.owner.id, tick = tick})
    if self.empowered then
      local d = math.distance(t.x, t.y, self.owner.x, self.owner.y) - self.owner.radius - t.radius
      local dir = math.direction(t.x, t.y, self.owner.x, self.owner.y)
      t.x = t.x + math.dx(d, dir)
      t.y = t.y + math.dy(d, dir)
      if t.inputs then
        table.insert(t.inputs, {
          tick = tick + 1,
          reposition = {
            x = t.x,
            y = t.y
          }
        })
      end
    end
  end)

  ctx.event:emit('sound.play', {sound = 'dash', x = self.owner.x, y = self.owner.y})
  if ctx.view then ctx.view:screenshake(5 * #self.targets) end
end

function Cleave:update()
  self.hp = timer.rot(self.hp, function() ctx.spells:deactivate(self) end)
end

function Cleave:draw()
  love.graphics.setColor(255, 255, 255, 50 * (self.hp / Cleave.hp))
  love.graphics.circle('fill', self.owner.x, self.owner.y, self.radius)
  love.graphics.circle('fill', self.owner.x, self.owner.y, self.radius * .65)
  love.graphics.setColor(255, 255, 255, 255 * (self.hp / Cleave.hp))
  love.graphics.circle('line', self.owner.x, self.owner.y, self.radius)
end

return Cleave