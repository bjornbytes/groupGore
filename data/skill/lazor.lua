local Lazor = {}

Lazor.name = 'LAZOR'
Lazor.code = 'lazor'
Lazor.text = 'Ima firin\' Malaysia!'
Lazor.type = 'skill'

Lazor.targeted = true
Lazor.cooldown = 10

function Lazor:activate()
	self.timer = 0
	self.charge = 0
end

function Lazor:update()
	if self.targeting then
		self.charge = math.min(self.charge + tickRate, 1.2)
		if self.charge == 1.2 then
			self:fire()
		end
	else
		if self.charge > 0 then self.timer = self.cooldown / 2 end
		self.charge = 0
	end
end

function Lazor:canFire()
	return self.timer == 0
end

function Lazor:fire(owner)
	if self.charge == 1.2 then
		ctx.spells:activate(owner.id, data.spell.lazor)
		self.timer = self.cooldown
	else
		self.timer = self.cooldown / 2
	end
end

function Lazor:draw(owner)
	if owner.id == ctx.id then
		--
	end
end

function Lazor:crosshair()

end

return Lazor
