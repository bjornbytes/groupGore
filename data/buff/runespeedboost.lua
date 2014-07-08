local RuneSpeedBoost = {}

----------------
-- Meta
----------------
RuneSpeedBoost.name = 'Rune Speed Boost'
RuneSpeedBoost.code = 'runespeedbost'
RuneSpeedBoost.text = 'Increases movespeed.'
RuneSpeedBoost.hide = false


----------------
-- Data
----------------
RuneSpeedBoost.haste = .2
RuneSpeedBoost.duration = 2

function RuneSpeedBoost:activate()
  self.amount = self.owner.class.speed * self.haste
  self.owner.haste = self.owner.haste + self.amount
	self.timer = self.duration
end

function RuneSpeedBoost:update()
	self.timer = timer.rot(self.timer, function()
		ctx.buffs:remove(self.owner, 'runespeedboost')
	end)

	local dec = (self.haste / self.duration) * tickRate
	self.amount = self.amount - dec
	self.owner.haste = self.owner.haste - dec
end

function RuneSpeedBoost:stack()
	self.owner.haste = self.owner.haste - self.amount
	self:activate()
end

return RuneSpeedBoost
