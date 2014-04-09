local Knife = {}
Knife.code = 'knife'
Knife.hp = .5

function Knife:activate()
  self.hp = Knife.hp
  
  self.angle = self.owner.angle
  self.x, self.y = self.owner.x + math.dx(32, self.angle), self.owner.y + math.dy(32, self.angle)
  self.target = ovw.collision:circleTest(self.x, self.y, 12, {
    tag = 'player',
    fn = function(p) return p.team ~= self.owner.team end
  })
  
  local backstab = false
  local shadowform = ovw.buffs:get(self.owner, 'shadowform')
  if self.target then
    backstab = math.abs(math.anglediff(self.target.angle, math.direction(self.target.x, self.target.y, self.owner.x, self.owner.y))) > math.pi / 2
    local damage = data.weapon.knife.damage
    if backstab then
      local multiplier = 2
      if shadowform then multiplier = multiplier + (1 - (self.target.health / self.target.maxHealth)) * 2 end
      damage = damage * multiplier
    end
    ovw.net:emit(evtDamage, {id = self.target.id, amount = damage, from = self.owner.id, tick = tick})
  end
  
  if ovw.sound then ovw.sound:play(backstab and 'backstab' or 'slash') end
end

function Knife:update()
  self.hp = timer.rot(self.hp, function() ovw.spells:deactivate(self) end)
end

function Knife:draw()
  local alpha = 255 * (self.hp / Knife.hp) * self.owner.visible
  love.graphics.setColor(self.target and {0, 255, 0, alpha * (100 / 255)} or {255, 0, 0, alpha * (100 / 255)})
  love.graphics.circle('fill', self.x, self.y, 12)
  love.graphics.setColor(self.target and {0, 255, 0, alpha} or {255, 0, 0, alpha})
  love.graphics.circle('line', self.x, self.y, 12)
end

return Knife