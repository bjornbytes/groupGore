local BattleAxe = extend(Spell)
BattleAxe.code = 'battleaxe'
BattleAxe.duration = .5
BattleAxe.radius = 45
BattleAxe.distance = 85

function BattleAxe:activate(visions)
  self.timer = BattleAxe.duration
	self:mirrorOwner()
	self:move(self.distance)
	self:damageInRadius(data.weapon.battleaxe.damage)
  self:playSound('dash')
end

function BattleAxe:update()
	self:rot()
end

function BattleAxe:draw()
  love.graphics.setColor(255, 255, 255, 50 * (self.timer / BattleAxe.duration))
	self:drawCircle('fill')
  love.graphics.setColor(255, 255, 255, 255 * (self.timer / BattleAxe.duration))
	self:drawCircle('line')
end

return BattleAxe
