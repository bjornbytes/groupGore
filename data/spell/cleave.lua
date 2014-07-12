local Cleave = extend(Spell)

Cleave.code = 'cleave'
Cleave.radius = 175
Cleave.duration = .5

function Cleave:activate()
  self.timer = Cleave.duration
	self:mirrorOwner()

  local empowered = ctx.buffs:get(self.owner, 'overexertion')
  ctx.buffs:remove(self.owner, 'overexertion')

	local damage = data.skill.cleave.damage * (empowered and 1.5 or 1)
	local enemies = self:enemiesInRadius()

	self:damage(enemies, function(enemy)
		return self:distanceTo(enemy) < Cleave.radius * .65 and damage or damage / 2
	end)

	if self.empowered then
		table.each(enemies, function(enemy)
			local dis = self:distanceTo(enemy) - self.owner.radius - enemy.radius
			local dir = math.direction(enemy.x, enemy.y, self.x, self.y)
			self:movePlayer(enemy, dis, {angle = dir})
		end)
	end

  ctx.event:emit('sound.play', {sound = 'dash', x = self.owner.x, y = self.owner.y})
end

function Cleave:update()
	self:rot()
end

function Cleave:draw()
  love.graphics.setColor(255, 255, 255, 50 * (self.hp / Cleave.hp))
	self:drawCircle('fill')
	self:drawCircle('fill', {radius = self.radius * .65})
  love.graphics.setColor(255, 255, 255, 255 * (self.hp / Cleave.hp))
	self:drawCircle('line'
end

return Cleave
