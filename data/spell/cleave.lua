local Cleave = {}

Cleave.code = 'cleave'
Cleave.radius = 150
Cleave.hp = .5

function Cleave:activate()
  self.hp = Cleave.hp

  self.targets = ctx.collision:circleTest(self.owner.x, self.owner.y, self.radius, {
    tag = 'player',
    fn = function(p) return p.team ~= self.owner.team end,
    all = true
  })

  table.each(self.targets, function(t)
    local damage = data.skill.cleave.damage
    if math.distance(self.owner.x, self.owner.y, t.x, t.y) > Cleave.radius * .7 then damage = damage / 2 end
    ctx.net:emit(evtDamage, {id = t.id, amount = data.skill.cleave.damage, from = self.owner.id, tick = tick})
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
  love.graphics.circle('fill', self.owner.x, self.owner.y, self.radius * .7)
  love.graphics.setColor(255, 255, 255, 255 * (self.hp / Cleave.hp))
  love.graphics.circle('line', self.owner.x, self.owner.y, self.radius)
end

return Cleave