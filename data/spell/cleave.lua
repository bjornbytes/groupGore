local Cleave = {}

Cleave.code = 'cleave'
Cleave.radius = 50

function Cleave:activate()
  self.targets = ctx.collision:circleTest(self.owner.x, self.owner.y, self.radius, {
    tag = 'player',
    fn = function(p) return p.team ~= self.owner.team end,
    all = true
  })

  table.each(self.targets, function(t)
    ctx.net:emit(evtDamage, {id = t.id, amount = data.skill.cleave.damage, from = self.owner.id, tick = tick})
  end)

  ctx.event:emit('sound.play', {sound = 'dash', x = self.owner.x, y = self.owner.y})
  if ctx.view then ctx.view:screenshake(5 * #self.targets) end
  ctx.spells:deactivate(self)
end

return Cleave