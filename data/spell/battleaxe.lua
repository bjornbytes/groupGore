local BattleAxe = {}
BattleAxe.code = 'battleaxe'
BattleAxe.hp = .5
BattleAxe.radius = 45
BattleAxe.distance = 85

function BattleAxe:activate(visions)
  self.hp = BattleAxe.hp
  
  self.angle = self.owner.angle
  self.x, self.y = self.owner.x + math.dx(self.distance, self.angle), self.owner.y + math.dy(self.distance, self.angle)
  self.targets = ctx.collision:circleTest(self.x, self.y, self.radius, {
    tag = 'player',
    fn = function(p) return p.team ~= self.owner.team end,
    all = true
  })
  
  table.each(self.targets, function(t)
    ctx.net:emit(evtDamage, {id = t.id, amount = data.weapon.battleaxe.damage, from = self.owner.id, tick = tick})
  end)
  
  ctx.event:emit('sound.play', {sound = 'dash', x = self.x, y = self.y})
  if ctx.view then ctx.view:screenshake(6) end
end

function BattleAxe:update()
  self.hp = timer.rot(self.hp, function() ctx.spells:deactivate(self) end)
end

function BattleAxe:draw()
  love.graphics.setColor(255, 255, 255, 50 * (self.hp / BattleAxe.hp))
  love.graphics.circle('fill', self.x, self.y, self.radius)
  love.graphics.setColor(255, 255, 255, 255 * (self.hp / BattleAxe.hp))
  love.graphics.circle('line', self.x, self.y, self.radius)
end

return BattleAxe
