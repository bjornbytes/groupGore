local Dagger = extend(app.logic.spell)
Dagger.code = 'dagger'
Dagger.radius = 18
Dagger.distance = 45

function Dagger:activate(visions)
  self:mirrorOwner()
  self:move(self.distance)

  local backstabbed = false

  self:damageInRadius(function(enemy)
    local backstab = math.abs(math.anglediff(enemy.angle, math.direction(enemy.x, enemy.y, self.x, self.y))) > math.pi / 2
    local damage = data.weapon.dagger.damage
    if backstab then
      if visions[enemy.id] == 3 then damage = enemy.health
      else damage = damage * 2 end
    end
    if backstab and ctx.view then ctx.view:screenshake(25) end
    backstabbed = backstabbed or backstab
    return damage
  end)

	self:playSound(backstabbed and 'backstab' or 'slash')
	self:die()
end

return Dagger
