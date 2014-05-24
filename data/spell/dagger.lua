local Dagger = {}
Dagger.code = 'dagger'
Dagger.hp = .5

function Dagger:activate(owner)
  self.hp = Dagger.hp
  
  self.angle = self.owner.angle
  self.x, self.y = self.owner.x + math.dx(35, self.angle), self.owner.y + math.dy(35, self.angle)
  self.target = ctx.collision:circleTest(self.x, self.y, 14, {
    tag = 'player',
    fn = function(p) return p.team ~= self.owner.team end
  })
  
  local backstab = false
  if self.target then
    backstab = math.abs(math.anglediff(self.target.angle, math.direction(self.target.x, self.target.y, self.owner.x, self.owner.y))) > math.pi / 2
    local damage = data.weapon.dagger.damage
    if backstab then damage = target.health end
    ctx.net:emit(evtDamage, {id = self.target.id, amount = damage, from = self.owner.id, tick = tick})
  end
  
  ctx.event:emit('sound.play', {sound = backstab and 'backstab' or 'slash'})
end

function Dagger:update(owner)
  self.hp = timer.rot(self.hp, function() ctx.spells:deactivate(self) end)
end

return Dagger
